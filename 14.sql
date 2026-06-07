WITH customer_stats AS (
    SELECT
        customer_id,
        COUNT(order_id)                         AS order_count,
        AVG(CAST(total_amount AS INTEGER))      AS customer_avg,
        STDDEV(CAST(total_amount AS INTEGER))   AS customer_stddev
    FROM p2.orders
    WHERE status = 'completed'
      AND CAST(total_amount AS INTEGER) > 0
    GROUP BY customer_id
    HAVING COUNT(order_id) >= 5
),
suspicious_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.full_name,
        o.order_date::date                              AS order_date,
        CAST(o.total_amount AS INTEGER)                AS order_amount,
        ROUND(cs.customer_avg)                         AS customer_avg,
        ROUND(CAST(o.total_amount AS INTEGER)
              / NULLIF(cs.customer_avg::INTEGER, 0), 2)         AS ratio
    FROM p2.orders o
    JOIN p2.customers c     ON o.customer_id = c.customer_id
    JOIN customer_stats cs  ON o.customer_id = cs.customer_id
    WHERE o.status = 'completed'
      AND CAST(o.total_amount AS INTEGER) > 0
      AND CAST(o.total_amount AS INTEGER) > cs.customer_avg * 3
)
SELECT
    order_id,
    customer_id,
    full_name,
    order_date,
    order_amount::numeric,
    customer_avg::numeric,
    ratio::numeric
FROM suspicious_orders
ORDER BY ratio DESC;
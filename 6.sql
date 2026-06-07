SELECT
    c.customer_id,
    c.full_name,
    c.phone,
    c.email,
    MAX(o.order_date::date)  AS last_order_date,
    COUNT(o.order_id)        AS total_past_orders
FROM "p2"."customers" c
INNER JOIN "p2"."orders" o
    ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
  AND c.customer_id NOT IN (
        SELECT DISTINCT customer_id
        FROM "p2"."orders"
        WHERE order_date::date >= CURRENT_DATE - INTERVAL '60 days'
  )
GROUP BY
    c.customer_id,
    c.full_name,
    c.phone,
    c.email
HAVING COUNT(o.order_id) >= 3
   AND MAX(o.order_date::date) < CURRENT_DATE - INTERVAL '60 days';
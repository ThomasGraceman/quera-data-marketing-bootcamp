WITH monthly AS (
  SELECT DISTINCT customer_id, date_trunc('month', NULLIF(order_date,'')::timestamp) AS m
  FROM p2.orders
  WHERE status = 'completed' AND NULLIF(total_amount,'')::numeric > 0
    AND NULLIF(order_date,'')::timestamp >= CURRENT_DATE - INTERVAL '13 months'
),
counts AS (SELECT m, COUNT(DISTINCT customer_id) AS active_customers FROM monthly GROUP BY m),
retained AS (
  SELECT cur.m, COUNT(*) AS retained_from_prev_month
  FROM monthly cur
  JOIN monthly prev ON prev.customer_id = cur.customer_id
                   AND prev.m = cur.m - INTERVAL '1 month'
  GROUP BY cur.m
)
SELECT c.m AS month, c.active_customers,
       COALESCE(r.retained_from_prev_month,0) AS retained_from_prev_month,
       ROUND(100.0*COALESCE(r.retained_from_prev_month,0)
             /NULLIF(LAG(c.active_customers) OVER (ORDER BY c.m),0),2) AS retention_rate_pct
FROM counts c
LEFT JOIN retained r ON r.m = c.m
ORDER BY c.m;
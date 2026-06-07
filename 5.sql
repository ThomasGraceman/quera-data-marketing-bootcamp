SELECT
    o.store_branch,
    COUNT(o.order_id)        AS order_count,
    SUM(o.total_amount::numeric)      AS total_sales,
    AVG(o.total_amount::numeric)      AS avg_order_value
FROM p2.orders o
WHERE o.status = 'completed'
  AND o.total_amount::numeric > 0
  AND o.order_date::date  >= NOW()::DATE - interval '3 MONTH'
GROUP BY o.store_branch
HAVING COUNT(o.order_id) > 100
ORDER BY total_sales DESC;
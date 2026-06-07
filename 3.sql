SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity::numeric)                         AS total_qty,
    SUM(oi.quantity::numeric * oi.unit_price::numeric)         AS revenue
FROM p2.orders o
JOIN p2.order_items oi ON o.order_id    = oi.order_id
JOIN p2.products    p  ON oi.product_id = p.product_id
WHERE o.status = 'completed'
  AND CAST(o.total_amount AS numeric) > 0
  AND o.order_date::date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
  AND o.order_date::date <  DATE_TRUNC('month', CURRENT_DATE)
GROUP BY p.product_id, p.product_name
ORDER BY total_qty DESC
LIMIT 10;
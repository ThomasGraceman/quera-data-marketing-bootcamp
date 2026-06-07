SELECT
    p1.product_name                         AS product_1,
    p2.product_name                         AS product_2,
    COUNT(*)                                AS times_bought_together
FROM p2.orders o
JOIN p2.order_items oi1 ON o.order_id    = oi1.order_id
JOIN p2.order_items oi2 ON o.order_id    = oi2.order_id
                        AND oi1.product_id < oi2.product_id
JOIN p2.products p1     ON oi1.product_id = p1.product_id
JOIN p2.products p2     ON oi2.product_id = p2.product_id
WHERE o.status = 'completed'
  AND CAST(o.total_amount AS INTEGER) > 0
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) >= 50
ORDER BY times_bought_together DESC;
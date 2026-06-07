WITH category_stats AS (
    SELECT
        c.customer_id,
        c.full_name,
        cat.category_name,
        SUM(oi.quantity::numeric)                        AS items_bought,
        SUM(oi.quantity::numeric * oi.unit_price::numeric)        AS amount_spent
    FROM p2.customers c
    JOIN p2.orders o        ON c.customer_id  = o.customer_id
    JOIN p2.order_items oi  ON o.order_id     = oi.order_id
    JOIN p2.products p      ON oi.product_id  = p.product_id
    JOIN p2.categories cat  ON p.category_id  = cat.category_id
    WHERE o.status = 'completed'
      AND CAST(o.total_amount AS INTEGER) > 0
    GROUP BY c.customer_id, c.full_name, cat.category_name
),
ranked AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY items_bought DESC, amount_spent DESC
        ) AS rnk
    FROM category_stats
)
SELECT
    customer_id,
    full_name,
    category_name   AS top_category,
    items_bought,
    amount_spent
FROM ranked
WHERE rnk = 1
ORDER BY customer_id;
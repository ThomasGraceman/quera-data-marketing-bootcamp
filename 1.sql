SELECT customer_id, full_name, register_date::date AS reg_day
FROM p2.customers
WHERE register_date::date >= (SELECT MAX(register_date::date) FROM p2.customers) - INTERVAL '7 days'
ORDER BY register_date::date DESC;

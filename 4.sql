SELECT
    customer_id,
    full_name,
    phone,
    birth_date
FROM p2.customers
WHERE EXTRACT(MONTH FROM birth_date::date) = EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))
AND CAST(birth_date AS DATE) >= DATE '1950-01-01'
  AND birth_date IS NOT NULL
  AND phone IS NOT NULL;
WITH cust AS (
  SELECT 
    customer_id, 
    date_trunc('month', NULLIF(register_date, '')::timestamp) AS cohort_month
  FROM p2.customers
  WHERE NULLIF(register_date, '') IS NOT NULL
),
orders_m AS (
  SELECT DISTINCT 
    customer_id, 
    date_trunc('month', NULLIF(order_date, '')::timestamp) AS order_month
  FROM p2.orders
  WHERE status = 'completed' 
    AND NULLIF(total_amount, '')::numeric > 0
),
activity AS (
  -- محاسبه فاصله ماه‌ها بین ثبت‌نام و هر خرید (Month Offset)
  SELECT 
    cu.cohort_month, 
    cu.customer_id,
    (EXTRACT(YEAR FROM om.order_month) - EXTRACT(YEAR FROM cu.cohort_month)) * 12
    + (EXTRACT(MONTH FROM om.order_month) - EXTRACT(MONTH FROM cu.cohort_month)) AS m_off
  FROM cust cu
  JOIN orders_m om ON om.customer_id = cu.customer_id
),
sizes AS (
  -- محاسبه تعداد کل اعضای هر کوهورت
  SELECT cohort_month, COUNT(*) AS cohort_size 
  FROM cust 
  GROUP BY cohort_month
)
-- گزارش نهایی: محاسبه درصد بازگشت مشتری در ماه‌های ۰ تا ۳
SELECT 
  s.cohort_month, 
  s.cohort_size,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.m_off = 0 THEN a.customer_id END) / s.cohort_size, 1) AS month_0_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.m_off = 1 THEN a.customer_id END) / s.cohort_size, 1) AS month_1_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.m_off = 2 THEN a.customer_id END) / s.cohort_size, 1) AS month_2_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.m_off = 3 THEN a.customer_id END) / s.cohort_size, 1) AS month_3_pct
FROM sizes s
LEFT JOIN activity a ON a.cohort_month = s.cohort_month
GROUP BY s.cohort_month, s.cohort_size
ORDER BY s.cohort_month;
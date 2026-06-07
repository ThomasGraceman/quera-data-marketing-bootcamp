WITH base AS (
  SELECT 
      c.customer_id, 
      c.full_name,
      MAX(NULLIF(o.order_date,'')::timestamp)              AS last_order,
      COUNT(o.order_id)                                    AS frequency,
      COALESCE(SUM(NULLIF(o.total_amount,'')::numeric),0)  AS monetary
  FROM p2.customers c
  LEFT JOIN p2.orders o
         ON o.customer_id = c.customer_id
        AND o.status = 'completed'
        AND NULLIF(o.total_amount,'')::numeric > 0
  GROUP BY c.customer_id, c.full_name
),
scored AS (
  SELECT *,
         (CURRENT_DATE - last_order::date) AS recency_days,
         NTILE(5) OVER (ORDER BY last_order ASC)  AS r_score,
         NTILE(5) OVER (ORDER BY frequency ASC)   AS f_score,
         NTILE(5) OVER (ORDER BY monetary ASC)    AS m_score
  FROM base
  WHERE frequency > 0
)
SELECT 
    customer_id,
    full_name,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score::text || f_score::text || m_score::text) AS rfm_segment
FROM scored
ORDER BY customer_id;
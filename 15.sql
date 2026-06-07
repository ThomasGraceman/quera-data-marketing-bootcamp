WITH sends AS (
  SELECT campaign_id, customer_id, MIN(NULLIF(sent_at,'')::timestamp) AS sent_at
  FROM p2.campaign_sends
  WHERE LOWER(TRIM(opened))    IN ('true','t','1','yes')
    AND LOWER(TRIM(delivered)) IN ('true','t','1','yes')
  GROUP BY campaign_id, customer_id
),
attrib AS (
  SELECT o.order_id,o.total_amount::numeric AS amt, s.campaign_id,
         ROW_NUMBER() OVER (PARTITION BY o.order_id ORDER BY s.sent_at ASC) AS rn
  FROM p2.orders o
  JOIN sends s ON s.customer_id = o.customer_id
              AND o.order_date::timestamp >= s.sent_at
              AND NULLIF(o.order_date,'')::timestamp <  s.sent_at + INTERVAL '7 days'
  WHERE o.status = 'completed' AND o.total_amount::numeric > 0
),
first_attrib AS (SELECT order_id, amt, campaign_id FROM attrib WHERE rn = 1)
SELECT c.campaign_name, c.budget::numeric AS budget,
       COUNT(fa.order_id)             AS attributed_orders,
       COALESCE(SUM(fa.amt),0)        AS attributed_revenue,
       ROUND(100.0*(COALESCE(SUM(fa.amt),0)-c.budget::numeric)
             /c.budget::numeric,2) AS roi_pct
FROM p2.campaigns c
LEFT JOIN first_attrib fa ON fa.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.budget
SELECT
    camp.campaign_name,
    COUNT(DISTINCT cs.customer_id)                                                                AS unique_recipients,

    COUNT(DISTINCT CASE WHEN cs.delivered = 'True' THEN cs.customer_id END)                      AS delivered_count,
    COUNT(DISTINCT CASE WHEN cs.opened    = 'True' THEN cs.customer_id END)                      AS opened_count,
    COUNT(DISTINCT CASE WHEN cs.clicked   = 'True' THEN cs.customer_id END)                      AS clicked_count,

    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cs.delivered = 'True' THEN cs.customer_id END)
               / NULLIF(COUNT(DISTINCT cs.customer_id), 0), 2)                                   AS delivery_rate,

    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cs.opened = 'True' THEN cs.customer_id END)
               / NULLIF(COUNT(DISTINCT CASE WHEN cs.delivered = 'True' THEN cs.customer_id END), 0), 2) AS open_rate,

    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cs.clicked = 'True' THEN cs.customer_id END)
               / NULLIF(COUNT(DISTINCT CASE WHEN cs.opened = 'True' THEN cs.customer_id END), 0), 2)    AS click_rate

FROM p2.campaigns camp
JOIN p2.campaign_sends cs ON camp.campaign_id = cs.campaign_id
GROUP BY camp.campaign_id, camp.campaign_name
ORDER BY unique_recipients DESC;
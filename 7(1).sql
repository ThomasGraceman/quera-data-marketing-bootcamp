SELECT
	CASE
	    WHEN gender = 'F' THEN 'زن'
	    WHEN gender = 'f' THEN 'زن'
	    WHEN gender = 'Female' THEN 'زن'
	    WHEN gender = 'female' THEN 'زن'
	    WHEN gender = 'FEMALE' THEN 'زن'
	    WHEN gender = 'زن' THEN 'زن'
	    ELSE 'مرد'
	    END AS gender_group,
	COUNT(distinct "customers"."customer_id") AS customer_count,
	AVG(total_amount::int) AS avg_order_value,
	((SUM(total_amount::bigint) * 100)::float / (SELECT SUM(total_amount::bigint) FROM "p2"."orders"))::float AS order_share_pct
	
FROM "p2"."customers"
JOIN "p2"."orders" AS "Orders" 
    ON "p2"."customers"."customer_id" = "Orders"."customer_id"
WHERE "Orders"."status" != 'cancelled'
  AND "Orders"."total_amount"::int > 0
GROUP BY gender_group;
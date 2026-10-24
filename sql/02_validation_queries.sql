USE olist_ecommerce;

SELECT SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       COUNT(*) AS customers
FROM (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS n
    FROM dbo.vw_order_items
    WHERE order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp <  '2018-09-01'
    GROUP BY customer_unique_id
) t;
USE olist_ecommerce;
GO

CREATE OR ALTER VIEW dbo.vw_orders AS
SELECT o.order_id, c.customer_unique_id, c.customer_state,
       o.order_purchase_timestamp,
       o.order_delivered_customer_date,
       o.order_estimated_delivery_date,
       DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
       DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delay_days,
       CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0 END AS is_late,
       r.review_score
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT order_id, AVG(CAST(review_score AS FLOAT)) AS review_score
    FROM dbo.olist_order_reviews_dataset
    GROUP BY order_id
) r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;
GO

SELECT COUNT(*) AS orders,
       ROUND(AVG(CAST(delivery_days AS FLOAT)),1) AS avg_delivery_days,
       ROUND(AVG(CAST(is_late AS FLOAT))*100,1) AS late_pct,
       ROUND(AVG(review_score),2) AS avg_review_score
FROM dbo.vw_orders;
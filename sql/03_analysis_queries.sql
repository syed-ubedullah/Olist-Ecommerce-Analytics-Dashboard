USE olist_ecommerce;
GO

-- 1) Monthly revenue and orders (Jan 2017 - Aug 2018)
SELECT FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2) AS revenue
FROM dbo.vw_order_items
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- 2) Top 10 categories with revenue share
SELECT TOP 10 category,
       ROUND(SUM(price), 0) AS revenue,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1) AS revenue_pct
FROM dbo.vw_order_items
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY category
ORDER BY revenue DESC;

-- 3) Top 10 states by revenue with share
SELECT TOP 10 customer_state,
       ROUND(SUM(price), 0) AS revenue,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1) AS revenue_pct
FROM dbo.vw_order_items
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY customer_state
ORDER BY revenue DESC;

-- 4) One-time vs repeat customers
WITH cust AS (
    SELECT customer_unique_id,
           COUNT(DISTINCT order_id) AS orders,
           SUM(price) AS revenue
    FROM dbo.vw_order_items
    WHERE order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp <  '2018-09-01'
    GROUP BY customer_unique_id
)
SELECT CASE WHEN orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type,
       COUNT(*) AS customers,
       ROUND(AVG(revenue), 1) AS avg_revenue
FROM cust
GROUP BY CASE WHEN orders > 1 THEN 'Repeat' ELSE 'One-time' END;

-- 5) Review score by delivery status
SELECT delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review_score
FROM (
    SELECT CASE WHEN is_late = 0 THEN 'On time'
                WHEN delay_days <= 3 THEN 'Late: up to 3 days'
                WHEN delay_days <= 7 THEN 'Late: 4-7 days'
                ELSE 'Late: 8+ days' END AS delivery_status,
           review_score
    FROM dbo.vw_orders
    WHERE order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp <  '2018-09-01'
) t
GROUP BY delivery_status
ORDER BY avg_review_score DESC;

-- 6) Slowest states by average delivery days
-- (add HAVING COUNT(*) > 100 to ignore states with very few orders)
SELECT TOP 10 customer_state,
       COUNT(*) AS orders,
       ROUND(AVG(CAST(delivery_days AS FLOAT)), 1) AS avg_delivery_days
FROM dbo.vw_orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY customer_state
ORDER BY avg_delivery_days DESC;
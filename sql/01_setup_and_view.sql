USE olist_ecommerce;
GO

-- 1) Columns rename karo
IF COL_LENGTH('dbo.product_category_name_translation','column1') IS NOT NULL
    EXEC sp_rename 'dbo.product_category_name_translation.column1',
                   'product_category_name', 'COLUMN';
GO
IF COL_LENGTH('dbo.product_category_name_translation','column2') IS NOT NULL
    EXEC sp_rename 'dbo.product_category_name_translation.column2',
                   'product_category_name_english', 'COLUMN';
GO

-- 2) Galat header wali row delete karo
DELETE FROM dbo.product_category_name_translation
WHERE product_category_name = 'product_category_name';
GO

-- 3) View banao
CREATE OR ALTER VIEW dbo.vw_order_items AS
SELECT o.order_id, c.customer_unique_id, c.customer_state, c.customer_city,
       o.order_status, o.order_purchase_timestamp,
       o.order_delivered_customer_date, o.order_estimated_delivery_date,
       oi.product_id, oi.seller_id, oi.price, oi.freight_value,
       COALESCE(t.product_category_name_english,
                p.product_category_name, 'unknown') AS category
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_customers_dataset c    ON o.customer_id = c.customer_id
JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
LEFT JOIN dbo.olist_products_dataset p ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered';
GO

-- 4) Tests
SELECT COUNT(*) AS translation_rows FROM dbo.product_category_name_translation;

SELECT COUNT(*) AS rows_cnt,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(SUM(price),2) AS total_revenue
FROM dbo.vw_order_items;

SELECT TOP 10 category, COUNT(*) AS items, ROUND(SUM(price),0) AS revenue
FROM dbo.vw_order_items
GROUP BY category
ORDER BY revenue DESC;
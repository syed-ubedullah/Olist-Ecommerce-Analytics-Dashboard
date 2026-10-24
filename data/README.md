# Data

The raw data is not included in this repository. It belongs to Olist and is available on Kaggle:
[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Files used

| File | Rows | Used for |
|---|---|---|
| olist_customers_dataset.csv | 99,441 | Customers and locations |
| olist_orders_dataset.csv | 99,441 | Order status and timestamps |
| olist_order_items_dataset.csv | 112,650 | Price, freight, product and seller per item |
| olist_products_dataset.csv | 32,951 | Product category |
| olist_sellers_dataset.csv | 3,095 | Seller location |
| olist_order_payments_dataset.csv | 103,886 | Imported, not used in the dashboard |
| olist_order_reviews_dataset.csv | 99,224 | Review scores |
| product_category_name_translation.csv | 71 | English category names |

The geolocation file was not used.

## How to load

1. Download and extract the dataset from Kaggle.
2. In SQL Server, create a database named `olist_ecommerce`.
3. Import each CSV with the SSMS Import Flat File wizard and keep the default table names.
4. Run `sql/01_setup_and_view.sql`, which also fixes the header row of the category translation table.

Dataset credit: Olist.
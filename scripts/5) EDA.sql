/*
============================================================
🗂️ DataWarehouseAnalytics: Business Intelligence Framework
============================================================

Purpose:
This script initializes a centralized analytical environment for exploring 
product, sales, and customer data. It leverages curated Gold layer views 
and performs key dimension profiling, temporal analysis, and high-level 
aggregation across multiple metrics. Designed to support reporting, 
dashboarding, and strategic decision-making in a BI ecosystem.

Contents:
✅ Database Initialization
✅ Product Dimension Exploration
✅ Business Timeline Analysis
✅ Summary Metrics Computation
✅ Customer and Category-Level Aggregates

Author: Prem  
Target Role: Data Analyst / BI Developer  
Created: July 2025  
*/

-- 🧱 Create and Initialize Data Warehouse
CREATE DATABASE DataWarehouseAnalytics;
USE DataWarehouseAnalytics;

-- 📦 Dimension Exploration: Product Categories
SELECT DISTINCT 
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;

-- 🗓️ Date Exploration: Business Timeline
SELECT 
    MIN(order_date) AS First_order,
    MAX(order_date) AS Last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS Business_time_duration
FROM gold.fact_sales;

-- 📊 Key Metrics Summary
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Number of Customers', COUNT(DISTINCT customer_key) FROM gold.dim_customers;

-- 🌍 Total Customers by Country
SELECT CONCAT('Total Customers - ', country) AS measure_name, COUNT(DISTINCT customer_id) AS measure_value
FROM gold.dim_customers
GROUP BY country

UNION ALL

-- 🚻 Total Customers by Gender
SELECT CONCAT('Total Customers - ', gender), COUNT(DISTINCT customer_id)
FROM gold.dim_customers
GROUP BY gender

UNION ALL

-- 📦 Avg Products per Category
SELECT CONCAT('Avg Products - ', category), AVG(product_count)
FROM (
    SELECT category, COUNT(product_id) AS product_count
    FROM gold.dim_products
    GROUP BY category
) AS product_counts
GROUP BY category

UNION ALL

-- 💰 Total Revenue by Category
SELECT CONCAT('Total Revenue - ', category), SUM(sales_amount)
FROM (
    SELECT dp.category, fs.sales_amount
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp ON fs.product_key = dp.product_key
) AS sales_category
GROUP BY category

UNION ALL

-- 💳 Revenue by Customer
SELECT CONCAT('Customer Revenue - ', customer_id), SUM(sales_amount)
FROM (
    SELECT dc.customer_id, fs.sales_amount
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc ON fs.customer_key = dc.customer_key
) AS customer_sales
GROUP BY customer_id

UNION ALL

-- 🌐 Items Sold by Country
SELECT CONCAT('Items Sold - ', country), SUM(quantity)
FROM (
    SELECT dc.country, fs.quantity
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc ON fs.customer_key = dc.customer_key
) AS country_quantity
GROUP BY country;

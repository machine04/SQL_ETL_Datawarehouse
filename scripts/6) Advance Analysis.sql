/*
=======================================================================
📈 Temporal & Performance Analysis — DataWarehouseAnalytics Project
=======================================================================

Purpose:
This SQL script performs change-over-time and performance analytics using 
Gold-layer dimensional data. The focus is on identifying business trends, 
evaluating yearly product performance, and understanding category-level 
sales contributions. It supports insights for dashboards, reports, and 
strategic decision-making.

Key Highlights:
✅ Change Over Time Analysis
✅ Running Totals & Moving Averages
✅ Product-Level Performance vs. Historical Trends
✅ Contribution Metrics by Product Category

*/

-- 🧭 Use the Data Warehouse Analytics
USE DataWarehouseAnalytics;

-- 📊 Change Over Time: Annual Sales Trends
SELECT 
    YEAR(order_date) AS Order_year,
    SUM(sales_amount) AS Total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY Order_year;

-- 📈 Cumulative Analysis: Running Total & Moving Average by Year
SELECT  
    Order_year,
    total_sales,
    avg_price,
    SUM(total_sales) OVER (ORDER BY Order_year) AS Running_total,
    AVG(avg_price) OVER (ORDER BY Order_year) AS Moving_average
FROM (
    SELECT 
        DATETRUNC(YEAR, order_date) AS Order_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE DATETRUNC(YEAR, order_date) IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) t;

-- ⚖️ Performance Analysis: Yearly Product Performance Comparison
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS Order_year,
        p.product_name,
        SUM(f.sales_amount) AS Current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT  
    Order_year,
    product_name,
    Current_sales,
    AVG(Current_sales) OVER (PARTITION BY product_name) AS Avg_sales,
    Current_sales - AVG(Current_sales) OVER (PARTITION BY product_name) AS Diff_avg,
    CASE 
        WHEN Current_sales - AVG(Current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above_avg'
        WHEN Current_sales - AVG(Current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below_avg'
        ELSE 'avg'
    END AS Avg_change,
    LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_year) AS PY_sales,
    Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_year) AS Diff_py,
    CASE 
        WHEN Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_year) > 0 THEN 'Increasing'
        WHEN Current_sales - LAG(Current_sales) OVER (PARTITION BY product_name ORDER BY Order_year) < 0 THEN 'Decreasing'
        ELSE 'Neutral'
    END AS Diff_sales
FROM yearly_product_sales
ORDER BY product_name, Order_year;

-- 🧮 Contribution Analysis: Category Sales Distribution
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(f.sales_amount) AS Total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
    category,
    Total_sales,
    SUM(Total_sales) OVER () AS Overall_sales,
    CONCAT(
        ROUND(
            (CAST(Total_sales AS FLOAT) / SUM(Total_sales) OVER()) * 100, 2
        ), '%'
    ) AS Percentage_contribution
FROM category_sales
ORDER BY Percentage_contribution DESC;

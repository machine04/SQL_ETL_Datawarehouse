/* 
===============================================================
 CUSTOMER REPORT: gold.Customer_report
===============================================================
Purpose:
Aggregates customer-level metrics using transactional data from gold.fact_sales and profile data from gold.dim_customers.

Highlights:
- Combines sales and customer profile information
- Calculates total sales, orders, products, quantity, and lifespan
- Segments customers based on age and total sales into VIP, Regular, or New
- Adds behavioral metrics like recency, average order value, and monthly spend

Use Cases:
- Customer segmentation
- KPI dashboards for retention and performance
- Lifecycle and engagement analysis
*/

-- Your customer report SQL code here
-- 📄 Create Customer Report View
CREATE VIEW gold.Customer_report AS

-- 👤 Output Columns & Business Logic
SELECT 
  ca.customer_key,
  ca.customer_number,
  ca.customer_name,

  -- 🧓 Age Segmentation
  CASE
    WHEN ca.Age < 20 THEN 'Under 20'
    WHEN ca.Age BETWEEN 20 AND 29 THEN 'Above 20'
    WHEN ca.Age BETWEEN 30 AND 39 THEN 'Above 30'
    WHEN ca.Age BETWEEN 40 AND 49 THEN 'Above 40'
    ELSE 'Above 50'
  END AS Age_group,

  -- 📊 Aggregated Metrics
  ca.Total_sales,
  ca.Total_orders,
  ca.Total_quantity,
  ca.Total_product,
  ca.last_order_date,

  -- 🏅 Customer Classification
  CASE 
    WHEN ca.Total_sales > 5000 AND ca.Lifespan >= 12 THEN 'Vip'
    WHEN ca.Total_sales <= 5000 AND ca.Lifespan >= 12 THEN 'Regular'
    ELSE 'New' 
  END AS Customer_segment,

  -- ⏳ Behavioral Metrics
  DATEDIFF(month, ca.last_order_date, GETDATE()) AS recency,

  CASE 
    WHEN ca.Total_orders = 0 THEN 0 
    ELSE ca.Total_sales / ca.Total_orders 
  END AS Average_order_value,

  CASE 
    WHEN ca.Lifespan = 0 THEN 0
    ELSE ca.Total_sales / ca.Lifespan
  END AS Average_monthly_spend

-- 🧪 Source Aggregation Block
FROM (
  SELECT 
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(year, c.birthdate, GETDATE()) AS Age,
    SUM(f.sales_amount) AS Total_sales,
    COUNT(DISTINCT f.order_number) AS Total_orders,
    SUM(f.quantity) AS Total_quantity,
    COUNT(DISTINCT f.product_key) AS Total_product,
    MAX(f.order_date) AS last_order_date,
    DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS Lifespan
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
  WHERE f.order_date IS NOT NULL
  GROUP BY 
    c.customer_key,
    c.customer_number,
    c.first_name,
    c.last_name,
    c.birthdate
) AS ca;

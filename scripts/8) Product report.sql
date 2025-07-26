/* 
===============================================================
 PRODUCT REPORT: gold.Product_report
===============================================================
Purpose:
Generates product-level insights by joining sales data with product metadata from gold.product_info.

Highlights:
- Aggregates metrics like total orders, sales, quantity, and customer reach
- Calculates product lifespan, recency, average order and monthly revenue
- Segments products into High Performer, Mid Range, and Low Performer based on revenue

Use Cases:
- Product performance tracking
- Category optimization and pricing decisions
- Supply and demand reporting for business strategy
*/

-- Your product report SQL code here

CREATE VIEW gold.Product_report AS

-- 🧱 Stage 1: Enrich Product Transactions
WITH Product_info_enriched AS (
  SELECT 
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,
    f.order_number,
    f.order_date,
    f.sales_amount,
    f.quantity,
    f.customer_key
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
  WHERE f.order_date IS NOT NULL
),

-- 📦 Stage 2: Aggregate Product Metrics
product_aggregation AS (
  SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity_ordered,
    COUNT(DISTINCT customer_key) AS total_customers,
    MIN(order_date) AS first_sale_date,
    MAX(order_date) AS last_sale_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_in_months
  FROM Product_info_enriched
  GROUP BY 
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

-- 🧾 Final Selection: Calculated Metrics & Segmentation
SELECT 
  product_key,
  product_name,
  category,
  subcategory,
  cost,
  total_orders,
  total_sales,
  total_quantity_ordered,
  total_customers,
  lifespan_in_months,

  -- 🏅 Revenue Segmentation
  CASE 
    WHEN total_sales >= 100000 THEN 'High Performer'
    WHEN total_sales BETWEEN 30000 AND 99999 THEN 'Mid Range'
    ELSE 'Low Performer'
  END AS revenue_segment,

  -- ⏳ Recency in Months
  DATEDIFF(month, last_sale_date, GETDATE()) AS recency,

  -- 💰 Average Revenue per Order
  CASE 
    WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
  END AS avg_order_revenue,

  -- 📈 Average Monthly Revenue
  CASE 
    WHEN lifespan_in_months = 0 THEN 0
    ELSE total_sales / lifespan_in_months
  END AS avg_monthly_revenue

FROM product_aggregation;

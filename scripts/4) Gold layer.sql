-- 🏆 Gold Layer Views: Dimensional Modeling
-- These views transform curated Silver layer data into dimensional structures 
-- for analytics and reporting—covering customers, products, and sales facts.

-- 🎯 Customer Dimension View
CREATE VIEW Gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_key,
    ci.cst_id AS Customer_id,
    ci.cst_key AS Customer_number,
    ci.cst_firstname AS First_name,
    ci.cst_lastname AS Last_name,
    la.CNTRY AS Country,
    ci.cst_marital_status AS Marital_status,
    ca.BDATE AS Birth_date,
    CASE 
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.GEN, 'N/A')
    END AS Gender,
    ci.cst_create_date AS Create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 AS la ON ci.cst_key = la.CID;

-- 🛍️ Product Dimension View
CREATE VIEW Gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_id) AS Product_key,
    pi.prd_id AS Product_ID,
    pi.prd_key AS Product_number,
    pi.prd_nm AS Product_name,
    pi.prd_cost AS Product_cost,
    pi.prd_line AS Product_line,
    pi.cat_id AS Category_ID,
    pcg.CAT AS Category,
    pcg.SUBCAT AS Sub_category,
    pcg.MAINTENANCE,
    pi.prd_start_dt AS Product_start_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pcg ON pi.cat_id = pcg.ID
WHERE prd_end_dt IS NULL;

-- 📊 Sales Fact View
CREATE VIEW Gold.fact_sales AS
SELECT  
    sls_ord_num AS Order_number,
    pr.Product_key,
    cr.Customer_key,
    sls_order_dt AS Order_date,
    sls_ship_dt AS Ship_date,
    sls_due_dt AS Due_date,
    sls_price AS Price,
    sls_quantity AS Quantity,
    sls_sales AS Sales_amount
FROM silver.crm_sales_details AS sd
LEFT JOIN Gold.dim_products AS pr ON sd.sls_prd_key = pr.Product_number
LEFT JOIN Gold.dim_customers AS cr ON sd.sls_cust_id = cr.Customer_id;

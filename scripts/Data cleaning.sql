-- ✨ Stored Procedure: Silver Layer Transformation
-- This procedure applies data cleansing, standardization, and business logic to convert raw Bronze data 
-- into curated Silver tables for downstream analytics.

CREATE OR ALTER PROCEDURE Silver.load_silver
AS
BEGIN 
    PRINT '>>truncating table Silver.crm_cust_info';
    TRUNCATE TABLE Silver.crm_cust_info;

    PRINT '>>inserting data to Silver.crm_cust_info';
    INSERT INTO Silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'N/A'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'N/A'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
        FROM Bronze.crm_cust_info
    ) t
    WHERE flag = 1;

    DELETE FROM Silver.crm_cust_info
    WHERE cst_id IS NULL;

    -- Inserting data from Bronze.crm_prd_info to Silver.crm_prd_info
    PRINT '>>truncating table: Silver.crm_prd_info';
    TRUNCATE TABLE Silver.crm_prd_info;

    PRINT '>>inserting data: Silver.crm_prd_info';
    INSERT INTO Silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'N/A'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
    FROM DataWarehouse.Bronze.crm_prd_info;

    -- Inserting data from Bronze.crm_sales_details to Silver.crm_sales_details
    PRINT '>>truncating table: Silver.crm_sales_details';
    TRUNCATE TABLE Silver.crm_sales_details;

    PRINT '>>inserting data: Silver.crm_sales_details';
    INSERT INTO Silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_order_dt AS VARCHAR(50)) AS DATE) END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_ship_dt AS VARCHAR(50)) AS DATE) END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_due_dt AS VARCHAR(50)) AS DATE) END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity
             THEN ABS(sls_price) * sls_quantity
             ELSE sls_sales END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
             ELSE sls_price END AS sls_price
    FROM Bronze.crm_sales_details;

    -- ERP: Bronze.erp_cust_az12 → Silver.erp_cust_az12
    PRINT '>>truncating table: Silver.erp_cust_az12';
    TRUNCATE TABLE Silver.erp_cust_az12;

    PRINT '>>inserting data: Silver.erp_cust_az12';
    INSERT INTO Silver.erp_cust_az12(CID, BDATE, GEN)
    SELECT
        CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
             ELSE CID END AS CID,
        CASE WHEN BDATE > GETDATE() THEN NULL
             ELSE BDATE END AS BDATE,
        CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
             WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
             ELSE 'n/a' END AS GEN
    FROM Bronze.erp_cust_az12;

    -- ERP: Bronze.erp_loc_a101 → Silver.erp_loc_a101
    PRINT '>>truncating table: Silver.erp_loc_a101';
    TRUNCATE TABLE Silver.erp_loc_a101;

    PRINT '>>inserting data: Silver.erp_loc_a101';
    INSERT INTO Silver.erp_loc_a101(CID, CNTRY)
    SELECT
        REPLACE(CID, '-', '') AS CID,
        CASE
            WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
            WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
            ELSE CNTRY
        END AS CNTRY
    FROM Bronze.erp_loc_a101;

    -- ERP: Bronze.erp_px_cat_g1v2 → Silver.erp_px_cat_g1v2
    PRINT '>>truncating table: Silver.erp_px_cat_g1v2';
    TRUNCATE TABLE Silver.erp_px_cat_g1v2;

    PRINT '>>inserting data: Silver.erp_px_cat_g1v2';
    INSERT INTO Silver.erp_px_cat_g1v2(ID, CAT, SUBCAT, MAINTENANCE)
    SELECT
        ID,
        TRIM(CAT) AS CAT,
        TRIM(SUBCAT) AS SUBCAT,
        TRIM(MAINTENANCE) AS MAINTENANCE
    FROM Bronze.erp_px_cat_g1v2;
END;

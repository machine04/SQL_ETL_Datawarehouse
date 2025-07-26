-- 🔄 Stored Procedure: Bronze Layer Loader
-- This procedure automates bulk loading of raw CRM and ERP data into the Bronze layer tables.
-- Includes load tracking, error handling, and timing metrics for each operation.

CREATE PROCEDURE Bronze.load_bronze
AS
BEGIN
    DECLARE @bronze_start_time DATETIME, @bronze_end_time DATETIME;
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @bronze_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading bronze layer';
        PRINT '================================================';

        PRINT '-----------------------------------';
        PRINT 'Loading CRM tables';
        PRINT '-----------------------------------';

        -- CRM: cust_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.crm_cust_info';
        TRUNCATE TABLE Bronze.crm_cust_info;
        PRINT 'Inserting data into: Bronze.crm_cust_info';
        BULK INSERT Bronze.crm_cust_info
        FROM '<YourFilePathHere>\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        -- CRM: prd_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.crm_prd_info';
        TRUNCATE TABLE Bronze.crm_prd_info;
        PRINT 'Inserting data into: Bronze.crm_prd_info';
        BULK INSERT Bronze.crm_prd_info
        FROM '<YourFilePathHere>\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        -- CRM: sales_details
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.crm_sales_details';
        TRUNCATE TABLE Bronze.crm_sales_details;
        PRINT 'Inserting data into: Bronze.crm_sales_details';
        BULK INSERT Bronze.crm_sales_details
        FROM '<YourFilePathHere>\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        PRINT '-----------------------------------';
        PRINT 'Loading ERP tables';
        PRINT '-----------------------------------';

        -- ERP: cust_az12
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.erp_cust_az12';
        TRUNCATE TABLE Bronze.erp_cust_az12;
        PRINT 'Inserting data into: Bronze.erp_cust_az12';
        BULK INSERT Bronze.erp_cust_az12
        FROM '<YourFilePathHere>\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        -- ERP: loc_a101
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.erp_loc_a101';
        TRUNCATE TABLE Bronze.erp_loc_a101;
        PRINT 'Inserting data into: Bronze.erp_loc_a101';
        BULK INSERT Bronze.erp_loc_a101
        FROM '<YourFilePathHere>\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        -- ERP: px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT 'Truncating table: Bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
        PRINT 'Inserting data into: Bronze.erp_px_cat_g1v2';
        BULK INSERT Bronze.erp_px_cat_g1v2
        FROM '<YourFilePathHere>\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';

        SET @bronze_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Total Bronze Layer Load Duration: ' +
              CAST(DATEDIFF(SECOND, @bronze_start_time, @bronze_end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '================================================';
    END TRY
    BEGIN CATCH
        PRINT '==============================';
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        PRINT '==============================';
    END CATCH
END;

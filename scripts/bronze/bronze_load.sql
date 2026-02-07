USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    
    BEGIN TRY
        PRINT '=====================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=====================================';
        -- CRM
        PRINT '-------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------';

        
        PRINT('>> Truncating bronze.crm_cust_info')
        PRINT('>> Inserting bronze.crm_cust_info')
        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/data/cust_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';


        PRINT('>> Truncating bronze.crm_prd_info')
        PRINT('>> Inserting bronze.crm_prd_info')
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/data/prd_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';

        PRINT('>> Truncating bronze.crm_sales_details')
        PRINT('>> Inserting bronze.crm_sales_details')
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/data/sales_details.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';

        -- ERP 

        PRINT '-------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------------------';

        PRINT('>> Truncating bronze.erp_cust_az12')
        PRINT('>> Inserting bronze.erp_cust_az12')
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/data/cust_az12.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';

        PRINT('>> Truncating bronze.erp_loc_a101')
        PRINT('>> Inserting bronze.erp_loc_a101')
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/data/loc_a101.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';


        PRINT('>> Truncating bronze.erp_px_cat_g1v2')
        PRINT('>> Inserting bronze.erp_px_cat_g1v2')
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/data/px_cat_g1v2.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        PRINT '-------------------------------------';
    END TRY
    BEGIN CATCH
        PRINT '=====================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT '=====================================';
    END CATCH

END 
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_sliver
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT '=====================================';
        PRINT 'Loading Silver Layer';
        PRINT '=====================================';

        /* ===============================
           CRM CUSTOMER
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading CRM Customer';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_maritial_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_maritial_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_maritial_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE  
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS rn
            FROM bronze.crm_cust_info
        ) t
        WHERE rn = 1
          AND cst_id IS NOT NULL;

        /* ===============================
           CRM PRODUCT
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading CRM Product';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt,
            dwh_create_date
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                DATEADD(
                    DAY,
                    -1,
                    LEAD(prd_start_dt) OVER (
                        PARTITION BY prd_key
                        ORDER BY prd_start_dt
                    )
                ) AS DATE
            ),
            GETDATE()
        FROM bronze.crm_prd_info;

        /* ===============================
           CRM SALES
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading CRM Sales';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
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
            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112)
            END,
            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112)
            END,
            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112)
            END,
            CASE
                WHEN sls_sales IS NULL
                  OR sls_sales <= 0
                  OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL
                  OR sls_price <= 0
                  OR sls_price <> sls_sales / NULLIF(sls_quantity, 0)
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        /* ===============================
           ERP CUSTOMER
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading ERP Customer';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END as cid,
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END as bdate,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
                ELSE gen
            END as gen
        FROM bronze.erp_cust_az12;

        /* ===============================
           ERP LOCATION
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading ERP Location';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid, '-', ''),
            CASE
                WHEN NULLIF(
                        TRIM(
                            REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')
                        ),
                        ''
                     ) IS NULL
                THEN 'n/a'
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = 'DE'
                THEN 'Germany'
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
                     IN ('US', 'USA')
                THEN 'United States'
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
                     IN ('UK', 'GB', 'GBR')
                THEN 'United Kingdom'
                ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
            END
        FROM bronze.erp_loc_a101;

        /* ===============================
           ERP CATEGORY
        =============================== */
        PRINT '-------------------------------------';
        PRINT 'Loading ERP Category';
        PRINT '-------------------------------------';

        PRINT '>> Truncating silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        PRINT '=====================================';
        PRINT 'Silver Layer Load Completed Successfully';
        PRINT '=====================================';

    END TRY
    BEGIN CATCH
        PRINT '=====================================';
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT ERROR_MESSAGE();
        PRINT '=====================================';
        THROW;
    END CATCH
END;


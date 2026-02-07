-- crm cust_info

-- Checking for null values or duplicates in primary key

SELECT 
cst_id,COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 or cst_id is NULL;



-- Checking for unwanted spaces

SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- Data standardization and consistency
SELECT DISTINCT cst_maritial_status
FROM silver.crm_cust_info;



-- crm prd_info

-- Checking for null values or duplicates in primary key

SELECT prd_id,count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 or prd_id is NULL;


-- Checking for unwanted spaces

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Data standardization and consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check order of dates
SELECT *
FROM silver.crm_cust_info;
WHERE prd_end_dt < prd_start_dt;

DROP TABLE silver.crm_prd_info;


-- crm sales details

-- Checking for null values or duplicates in primary key

SELECT sls_id,count(*)
FROM bronze.crm_sales_details
GROUP BY prd_id
HAVING COUNT(*)>1 or prd_id is NULL;


-- Checking for unwanted spaces

SELECT prd_nm
FROM bronze.crm_sales_details
WHERE prd_nm != TRIM(prd_nm);

-- Data standardization and consistency
SELECT DISTINCT prd_line
FROM bronze.crm_sales_details

-- Check order of dates
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt;

-- erp cust
SELECT bdate FROM silver.erp_cust_az12
WHERE  bdate > GETDATE();



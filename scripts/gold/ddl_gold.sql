
-- Dimension Table
CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER()OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_maritial_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
     ELSE COALESCE(ca.gen,'n/a')
END as gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key= ca.cid
LEFT JOIN silver.erp_loc_a101 la 
ON la.cid=ca.cid;


SELECT * FROM silver.erp_px_cat_g1v2;


CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER()OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date

FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL; -- Filtering out all historical data


-- Fact table

CREATE VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_products pr 
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_key;
--Customer
CREATE VIEW gold.dim_customer AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	CASE 
		WHEN ci.cst_gndr = 'n/a' THEN COALESCE(ci.cst_gndr, 'n/a') -- CRM is the Master 
		ELSE ci.cst_gndr
	END as gender,
	ci.cst_marital_status as marital_status,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
FROM silver.crm_cust_info ci
LEFT JOIN	silver.erp_cust_az12 ca
ON			ci.cst_key = ca.cid
LEFT JOIN	silver.erp_loc_a101 la
ON			ci.cst_key = la.cid;
GO


--Product

CREATE VIEW gold.dim_product AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY pri.prd_start_dt, pri.prd_id) as product_key,
	pri.prd_id as product_id,
	pri.prd_key as product_number,
	pri.prd_nm as product_name,
	pri.cat_key as category_key,
	cat.cat as category,
	cat.subcat as subcategory,
	cat.maintenance,
	pri.prd_cost as cost,
	pri.prd_line as product_line,
	pri.prd_start_dt as start_date
FROM silver.crm_prd_info pri
LEFT JOIN	silver.erp_px_cat_g1v2 cat
ON			pri.cat_key = cat.id
WHERE pri.prd_end_dt is NULL;
GO

--Sales
CREATE VIEW gold.fact_sales AS
SELECT 
sls_ord_num,
pr.product_key,
ct.customer_key,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customer ct
ON sd.sls_cust_id = ct.customer_id
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
USE OrderPractise;
GO

--==================================================
--crm_cust_info

--Find wrong id's
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id is NULL

--Find not trimmed columns
SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


SELECT
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT * from [silver].[crm_cust_info]

select distinct cst_marital_status from [silver].[crm_cust_info]


--crm_prd_info

--Find wrong id's
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id is NULL

--Find not trimmed columns
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

SELECT
prd_line
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line)

--check prd_line data
select distinct prd_line from silver.crm_prd_info

--check prd_end_dt
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- crm_sales_details check

--check spaces
SELECT
	sls_prd_key
FROM silver.crm_sales_details
WHERE TRIM(sls_prd_key) != sls_prd_key

SELECT
	sls_ord_num
FROM silver.crm_sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num


--invalid dates format string in bronze layer
SELECT
	sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 OR len(sls_order_dt)!=8


--check price and sales
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE 
sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
OR sls_sales != (sls_price*sls_quantity)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL


-- check silver.erp_loc_a101

--check cid with '-'
SELECT cid 
FROM silver.erp_loc_a101
WHERE cid like '%-%'

--check cntry values
SELECT DISTINCT 
cntry
FROM silver.erp_loc_a101

--check silver.erp_px_cat_g1v2

SELECT * from silver.erp_px_cat_g1v2

--maintenance values (only yes or no)
SELECT DISTINCT maintenance from silver.erp_px_cat_g1v2

--cat and subcat values
SELECT DISTINCT cat FROM silver.erp_px_cat_g1v2

SELECT DISTINCT subcat FROM silver.erp_px_cat_g1v2

--spaces

SELECT cat 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(cat) != cat

SELECT subcat 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(subcat) != subcat

SELECT id 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(id) != id



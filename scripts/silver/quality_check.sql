
USE OrderPractise;
GO

--crm_cust_info

--Find wrong id's
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id is NULL

--Find not trimmed first names
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

--Find not trimmed first names
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

SELECT
prd_line
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line)

SELECT * from [silver].[crm_cust_info]

select distinct prd_line from silver.crm_prd_info

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- crm_sales_details check

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details


SELECT
	sls_prd_key
FROM bronze.crm_sales_details
WHERE TRIM(sls_prd_key) != sls_prd_key

SELECT
	sls_ord_num
FROM bronze.crm_sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num


--invalid dates
SELECT
	sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 OR len(sls_order_dt)!=8


--fix price and sales

SELECT
	sls_sales old_sales,
	sls_quantity,
	sls_price old_price,
	CASE 
		WHEN sls_sales<=0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price*sls_quantity)
		ELSE sls_sales
	END sls_sales,
	CASE
		WHEN sls_price <=0 OR sls_price IS NULL THEN ABS(sls_sales/sls_quantity)
		ELSE sls_price
	END sls_price
FROM bronze.crm_sales_details
WHERE 
sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
OR sls_sales != (sls_price*sls_quantity)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL


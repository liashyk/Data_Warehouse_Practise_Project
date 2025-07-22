

--trim
--fix keys (remove duplcates and nulls)
--replace F/M to Female, Male
--S/M to Single/Married

WITH clean_crm_cust_info 
AS (
	SELECT 
	cst_id,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) date_rn,
	cst_key, 
	TRIM(cst_firstname) as cst_firstname,
	TRIM(cst_lastname) as cst_lastname,
	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		Else 'n/a'
	END cst_marital_status,
	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		Else 'n/a'
	END cst_gndr,
	cst_create_date
	FROM bronze.crm_cust_info
	where cst_id is not null
)
insert silver.crm_cust_info (
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
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM clean_crm_cust_info
where date_rn = 1
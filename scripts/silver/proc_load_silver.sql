/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
	Clean and normalize data from from bronze layer and load it into silver layer
	
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/


USE OrderPractise;
GO

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

		SET @batch_start_time = GETDATE()
		PRINT '================================================';
		PRINT 'Loading SILVER Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		--trim
		--fix keys (remove duplcates and nulls)
		--replace F/M to Female, Male
		--S/M to Single/Married
		SET @start_time = GETDATE()s
		PRINT('>>Truncate TABLE silver.crm_cust_info');
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT('>>Load TABLE silver.crm_cust_info');
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
		where date_rn = 1;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'



		--replace - to _
		--divide prd_key to cat_key and prd-key
		--replace codes in prd_line
		--replace prd_end_dt with start of the next product
		SET @start_time = GETDATE()
		PRINT('>>Truncate TABLE silver.crm_prd_info');
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT('>>Load TABLE silver.crm_prd_info');
		INSERT silver.crm_prd_info(
			prd_id,
			cat_key,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-','_') as cat_key,
			SUBSTRING(prd_key, 7, len(prd_key)) as prd_key,
			prd_nm,
			COALESCE(prd_cost, 0) as prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' then 'Mountain'
				WHEN 'R' then 'Road'
				WHEN 'S' then 'Other Sales'
				WHEN 'T' then 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) prd_start_dt,
			CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC) AS DATE) prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'




		--Change %_dt to columns from INT to DATE
		--fix sales and price columns so they have values that >1 and sales = price * quantity
		SET @start_time = GETDATE()
		PRINT('>>Truncate table silver.crm_sales_details');
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT('>>Load table silver.crm_sales_details');
		INSERT silver.crm_sales_details (
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
				WHEN sls_order_dt <=0 or LEN(sls_order_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt as VARCHAR) AS DATE)
			END sls_order_dt,
			CASE 
				WHEN sls_ship_dt <=0 or LEN(sls_ship_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt as VARCHAR) AS DATE)
			END sls_ship_dt,
			CASE 
				WHEN sls_due_dt <=0 or LEN(sls_due_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_due_dt as VARCHAR) AS DATE)
			END sls_due_dt,

			CASE 
				WHEN sls_sales<=0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price*sls_quantity)
				ELSE sls_sales
			END sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price <=0 OR sls_price IS NULL THEN ABS(sls_sales/sls_quantity)
				ELSE sls_price
			END sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'


		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
		--replace gender with words
		--replace bdate  that in the future with nulls
		--remove "NASA" from cid
		SET @start_time = GETDATE()
		PRINT('>>Truncate table silver.erp_cust_az12');
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT('>>Load table silver.erp_cust_az12');
		INSERT silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE 
				WHEN cid LIKE 'NASA%' THEN SUBSTRING(cid, 4, len(cid))
				ELSE cid
			END cid,
			CASE 
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
			CASE UPPER(TRIM(gen)) 
				WHEN 'M' THEN 'Male'
				WHEN 'MALE' THEN 'Male'
				WHEN 'F' THEN 'Female'
				WHEN 'FEMALE' THEN 'Female'
				ELSE 'n/a'
			END gen 
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'


		--remove '-' and normalise countries
		SET @start_time = GETDATE()
		PRINT('>>Truncate table silver.erp_loc_a101');
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT('>>Load table silver.erp_loc_a101');
		INSERT silver.erp_loc_a101 (cid, cntry)
		SELECT
			REPLACE(cid, '-', '') cid,
			CASE 
				WHEN TRIM(cntry) in ('US', 'United States', 'USA') THEN 'United States'
				WHEN TRIM(cntry)  = 'DE' THEN 'Germany'
				WHEN TRIM(cntry)  = '' THEN NULL
				ELSE TRIM(cntry) 
			END cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'

		--no changes to data
		SET @start_time = GETDATE()
		PRINT('>>Truncate table silver.erp_px_cat_g1v2');
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT('>>Load table silver.erp_px_cat_g1v2');
		INSERT silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT * FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE()
		PRINT '>> load duration ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds'
		PRINT '---------'
		print '========================================='
		SET @batch_end_time = GETDATE()
		PRINT '>> Batch load duration ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR)+ ' seconds'
	END TRY
	BEGIN CATCH
		PRINT 'Error message: ' + ERROR_MESSAGE();
		PRINT 'Error message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error message: ' +  CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END


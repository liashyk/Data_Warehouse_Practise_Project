USE OrderPractise;
GO


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
FROM bronze.crm_sales_details

SELECT * from silver.crm_sales_details
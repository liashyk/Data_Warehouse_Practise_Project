USE OrderPractise;
GO

--fix gender
--fix bdate om year
--split cid

SELECT 
cid,
bdate,
gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.crm_cust_info

SELECT 
DISTINCT
bdate
FROM bronze.erp_cust_az12
ORDER BY bdate DESC;

EXEC sp_columns 'erp_cust_az12', 'bronze'
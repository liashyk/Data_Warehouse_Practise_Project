USE OrderPractise;
GO

--fix gender
--fix bdate om year
--split cid

SELECT 
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid LIKE 'S%'

SELECT * FROM silver.crm_cust_info
WHERE LEN(cst_key) != 10 ;

SELECT DISTINCT LEN(cid) FROM silver.crm_cust_info


--dates
SELECT 
DISTINCT
bdate
FROM silver.erp_cust_az12
ORDER BY bdate DESC;

--genders
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12
ORDER BY gen DESC;

EXEC sp_columns 'erp_cust_az12', 'bronze'


--fix years (goes 20 century)
SELECT DISTINCT
	bdate as old_bdate,
	CASE 
		WHEN bdate > '2099-12-31' THEN DATEFROMPARTS( YEAR(bdate)%100 + 1900, MONTH(bdate), DAY(bdate))
		ELSE bdate
	END bdate2
FROM bronze.erp_cust_az12
ORDER BY old_bdate DESC;

--fix genders

SELECT DISTINCT
	gen,
	CASE UPPER(TRIM(gen)) 
		WHEN 'M' THEN 'Male'
		WHEN 'MALE' THEN 'Male'
		WHEN 'F' THEN 'Female'
		WHEN 'FEMALE' THEN 'Female'
		ELSE 'n/a'
	END
FROM bronze.erp_cust_az12
ORDER BY gen DESC;



SELECT
cid,
CASE 
	WHEN LEN(cid) > 10 THEN SUBSTRING(cid, len(cid) - 10, 10)
	ELSE cid
END cid
FROM bronze.erp_cust_az12


--final

WITH cte as
(
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
	FROM bronze.erp_cust_az12

) 
SELECT TOP(100) * 
FROM cte
where cid in 
(SELECT cst_key FROM silver.crm_cust_info)


INSERT silver.erp_cust_az12 (cid,bdate,gen)
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
FROM bronze.erp_cust_az12
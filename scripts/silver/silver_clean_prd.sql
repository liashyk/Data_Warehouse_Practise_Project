
USE OrderPractise;
GO

--replace - to _
--divide prd_key to cat_key and prd-key
--replace codes in prd_line
--replace prd_end_dt with start of the next prooduct


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
FROM bronze.crm_prd_info

SELECT * from silver.crm_prd_info

TRUNCATE TABLE silver.crm_prd_info
SELECT* from silver.crm_prd_info
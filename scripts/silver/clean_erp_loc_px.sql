
--remove '-' and normalise countries
INSERT silver.erp_loc_a101 (cid, cntry)
SELECT
REPLACE(cid, '-', '') cid,
CASE 
	WHEN TRIM(cntry) in ('US', 'United States', 'USA') THEN 'United States'
	WHEN TRIM(cntry)  = 'DE' THEN 'Germany'
	WHEN TRIM(cntry)  = '' THEN NULL
	ELSE TRIM(cntry) 
END cntry
FROM bronze.erp_loc_a101

SELECT DISTINCT cntry from bronze.erp_loc_a101

INSERT silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT * FROM bronze.erp_px_cat_g1v2
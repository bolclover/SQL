-- deployment

select fi.* , 
case when New_existing_product_adj = 'Not yet define' and min_log_date is not null and year(min_log_date)<2022 then 'Existing Product' 
		when New_existing_product_adj = 'Không có date nào' and min_log_date is not null and year(min_log_date)<2022 then 'Existing Product'
else New_existing_product_adj end as New_existing_product
from 

(
WITH deployment_tracking AS (
    SELECT
        a.sku,
        launching_channel,
        a.launching_date,
        a.first_ordered_date,
        a.first_shipped_date,
        a.first_di_onboard_date,
        a.first_di_ordered_date,
        a.first_di_confirmed_date,
        a.first_po_di_quantity,
        a.first_etd_date,
        a.first_atd_date,
        a.first_eta_date,
        a.first_ata_date,
        a.estimated_first_stock_date,
        a.first_stock_available_date
    FROM (
        SELECT
            sku,
            MIN(launching_date) AS launching_date,
            MIN(first_ordered_date) AS first_ordered_date,
            MIN(first_shipped_date) AS first_shipped_date,
            MIN(first_di_onboard_date) AS first_di_onboard_date,
            MIN(first_di_ordered_date) AS first_di_ordered_date,
            MIN(first_di_confirmed_date) AS first_di_confirmed_date,
            MIN(first_po_di_quantity) AS first_po_di_quantity,
            MIN(first_etd_date) AS first_etd_date,
            MIN(first_atd_date) AS first_atd_date,
            MIN(first_eta_date) AS first_eta_date,
            MIN(first_ata_date) AS first_ata_date,
            MIN(estimated_first_stock_date) AS estimated_first_stock_date,
            MIN(first_stock_available_date) AS first_stock_available_date
        FROM deployment_process_tracking
        GROUP BY 1
    ) a
    LEFT JOIN deployment_process_tracking b ON a.sku = b.sku AND a.launching_date = b.launching_date
),

-- stock_inv
first_stock_available AS (
    SELECT
        sku,
        MIN(log_date) AS first_stock_available
    FROM full_inventory
    WHERE inventory > 0
    GROUP BY 1
),

min_log_date as (
select sku, min(log_date) as min_log_date from public_main.full_metrics_daily where label_currency = 'USD' and ordered_units >0
GROUP BY 1
)

SELECT dim.*,
    CASE
        WHEN launching_date >= DATE_ADD(CURRENT_DATE(), INTERVAL -3 MONTH) THEN '0-3 month'
        WHEN launching_date < DATE_ADD(CURRENT_DATE(), INTERVAL -3 MONTH) AND launching_date >= DATE_ADD(CURRENT_DATE(), INTERVAL -6 MONTH) THEN '3-6 month'
        WHEN launching_date < DATE_ADD(CURRENT_DATE(), INTERVAL -6 MONTH) AND launching_date >= DATE_ADD(CURRENT_DATE(), INTERVAL -12 MONTH) THEN '6-12 month'
        WHEN launching_date IS NULL THEN ''
        ELSE '>12 month'
    END AS PLC,
    CASE

        #list nay Db sai , sp ex mà launching /order 2023
        WHEN sku IN ('AAAG','GKK3','J62U','LFFY','NDCJ','VT8Y','WLD4','Z6WB') THEN 'Existing Product' 
				#Selectorized Dumbbell &nightstand 
        WHEN sku IN ('KRUX','P40Y','Q0ZF','R9SH','V1D2','ZH6G','HLMM','LANU','N6BM','NU9N','PFXR','QZPU','USQ8','WYKE') THEN 'New product 2023'
				#logic đúng
				#sell_stpe 
				WHEN subcategory IS NULL OR sell_type IN ('Combo','Multiple','Not sales') THEN 'Existing Product'
				WHEN (launching_date IS NULL AND first_ordered_date IS NULL) then 'Không có date nào' 
				when (launching_date IS not NULL AND first_ordered_date IS NULL) then 'Not yet define'
				WHEN YEAR(first_ordered_date) >=2022 THEN CONCAT('New Product ', YEAR(first_ordered_date))
			  WHEN (YEAR(first_ordered_date) <2022 and first_ordered_date is not null) then 'Existing Product'
				When company <> 'Y4A' then ''
        ELSE 'need to check'
    END AS New_existing_product_adj
FROM (
    SELECT
        a.sku,
        sku_detail,
        product_id,
        parent_sku,
        asin,
        walmart_item_id,
        company,
        brand,
        channel,
        product_name,
        team,
        root_category,
        main_category,
        category,
        subcategory,
        subcategory_1,
        life_cycle,
        is_active,
				cbm_master,
        published_status,
        sell_type,
        sell_status,
        image_url,
        created_at,
        first_stock_available,
        launching_channel,
        launching_date,
        first_ordered_date,
        first_shipped_date,
        first_di_onboard_date,
        first_di_ordered_date,
        first_di_confirmed_date,
        first_po_di_quantity,
        first_etd_date,
        first_atd_date,
        first_eta_date,
        first_ata_date,
        estimated_first_stock_date,
        first_stock_available_date,
				min_log_date
    FROM sc_main.dim_product a
    LEFT JOIN deployment_tracking b ON a.sku = b.sku
    LEFT JOIN first_stock_available c ON a.sku = c.sku
		LEFT JOIN min_log_date d on a.sku = d.sku 
) AS dim ) fi
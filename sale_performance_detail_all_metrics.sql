# highlight number 


SELECT
	CONCAT(
		'<font size="+2">',
		FORMAT( cast( SUM( CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END ) AS VARCHAR ), 0 ),
		'</font><br><br><hr><strong>Shipped Units</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( shipped_units ) AS VARCHAR ), 0 ),
		'</font><br><br><br><strong>Ordered Units</strong><br>',
		'<font size="+2">',
	FORMAT( cast( SUM( ordered_units ) AS VARCHAR ), 0 )) AS "Sales Units",
	CONCAT(
		'<font size="+2">',
		FORMAT( cast( SUM( CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
		COALESCE (
			FORMAT(
				cast(
					SUM( CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END )/ nullif( SUM( CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END ), 0 ) AS VARCHAR 
				),
				2 
			),
			'--' 
		),
		'<hr>Shipped GMV</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( shipped_gmv ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
		COALESCE ( FORMAT( cast( SUM( shipped_gmv )/ nullif( SUM( shipped_units ), 0 ) AS VARCHAR ), 2 ), '--' ),
		'<br><br>Ordered GMV</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( ordered_gmv ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
	COALESCE ( FORMAT( cast( SUM( ordered_gmv )/ nullif( SUM( ordered_units ), 0 ) AS VARCHAR ), 2 ), '--' )) AS "Sales GMV",
	CONCAT(
		'<font size="+2">',
		FORMAT( cast( SUM( CASE WHEN country = 'USA' THEN ordered_revenue ELSE shipped_revenue END ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
		COALESCE (
			FORMAT(
				cast(
					SUM( CASE WHEN country = 'USA' THEN ordered_revenue ELSE shipped_revenue END )/ nullif( SUM( CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END ), 0 ) AS VARCHAR 
				),
				2 
			),
			'--' 
		),
		'<hr>Shipped Revenue</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( shipped_revenue ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
		COALESCE ( FORMAT( cast( SUM( shipped_revenue )/ nullif( SUM( shipped_units ), 0 ) AS VARCHAR ), 2 ), '--' ),
		'<br><br>Ordered Revenue</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( ordered_revenue ) AS VARCHAR ), 2 ),
		'</font><br>ASP <strong>',
	COALESCE ( FORMAT( cast( SUM( ordered_revenue )/ nullif( SUM( ordered_units ), 0 ) AS VARCHAR ), 2 ), '--' )) AS "Sales Revenue",
	CONCAT(
		'<font size="+2">',
		FORMAT( cast( SUM( vc_promo_spend + coupon_spend + vm_promo_spend ) AS VARCHAR ), 2 ),
		'</font><br>%GMV <strong>',
		COALESCE (
			FORMAT(
				cast(
					SUM( vc_promo_spend + coupon_spend + vm_promo_spend )/ nullif( SUM( CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END ), 0 )* 100 AS VARCHAR 
				),
				2 
			),
			'--' 
		),
		'%</font><br><hr>VC Promotion</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( vc_promo_spend + coupon_spend ) AS VARCHAR ), 2 ),
		'</font><br><br><br><strong>VM Promotion</strong><br>',
		'<font size="+2">',
	FORMAT( cast( SUM( vm_promo_spend ) AS VARCHAR ), 2 )) AS "Promotion Spend",
	CONCAT(
		'<font size="+2">',
		FORMAT( cast( SUM( sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend ) AS VARCHAR ), 2 ),
		'</font><br>%GMV <strong>',
		COALESCE (
			FORMAT(
				cast(
					SUM( sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )/ nullif( SUM( CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END ), 0 )* 100 AS VARCHAR 
				),
				2 
			),
			'--' 
		),
		'%</font><br><hr>PPC</strong><br>',
		'<font size="+2">',
		FORMAT( cast( SUM( sb_spend + sbv_spend + sd_spend + sp_spend ) AS VARCHAR ), 2 ),
		'</font><br><br><br><strong>DSP</strong><br>',
		'<font size="+2">',
	FORMAT( cast( SUM( dsp_halo_spend + dsp_promoted_spend ) AS VARCHAR ), 2 )) AS "Ads Spend",
	CONCAT(
	CASE
			
			WHEN SUM(
				profit_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )) > 0 THEN
				CONCAT(
					'<font size="+2">',
					FORMAT(
						cast( SUM( profit_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )) AS VARCHAR ),
						2 
					)) ELSE CONCAT(
					'<font color="#F15A60" size="+2">',
					FORMAT(
						cast( SUM( profit_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )) AS VARCHAR ),
						2 
					)) 
			END,
			'</font><br>Margin <strong>',
			COALESCE (
				FORMAT(
					cast(
						SUM(
							profit_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend ))/(
						NULLIF( SUM( CASE WHEN country = 'USA' THEN ordered_revenue ELSE shipped_revenue END ), 0 ))* 100 AS VARCHAR 
					),
					2 
				),
				'--' 
			),
			'%</strong>',
			'</font><br><hr><strong>CM Internal</strong><br>',
			'<font size="+2">',
			FORMAT(
				cast( SUM( cm_internal_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )) AS VARCHAR ),
				2 
			),
			'</font><br>CM Internal/Revenue <strong>',
			COALESCE (
				FORMAT(
					cast(
						SUM(
							cm_internal_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend ))/(
						NULLIF( SUM( CASE WHEN country = 'USA' THEN ordered_revenue ELSE shipped_revenue END ), 0 ))* 100 AS VARCHAR 
					),
					2 
				),
				'--' 
			),
			'%</strong>',
			'</font><br><hr><strong>CM External</strong><br>',
			'<font size="+2">',
			FORMAT(
				cast( SUM( cm_external_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend )) AS VARCHAR ),
				2 
			),
			'</font><br>CM External/Revenue <strong>',
			COALESCE (
				FORMAT(
					cast(
						SUM(
							cm_external_ordered_shipped - ( vc_promo_spend + coupon_spend + vm_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend ))/(
						NULLIF( SUM( CASE WHEN country = 'USA' THEN ordered_revenue ELSE shipped_revenue END ), 0 ))* 100 AS VARCHAR 
					),
					2 
				),
				'--' 
			),
			'%</strong>' 
		) AS "Profit" 
	FROM
		(
		SELECT
			w.*,
			company,
			root_category,
			category,
			subcategory_1,
			subcategory,
			product_name,
			wa.wave,
		CASE
				
				WHEN w.channel = 'WM WFS' THEN
				'Walmart - Seller' 
				WHEN w.channel = 'WM DSV' THEN
				'Walmart - Supplier' 
				WHEN w.channel IN ( 'Local' ) THEN
				'Local' 
				WHEN w.channel IN ( 'FBA', 'FBM' ) THEN
				'Amazon - Seller' 
				WHEN w.channel LIKE '%AVC%' THEN
				'Amazon - Vendor' ELSE w.channel 
			END AS platform,
		CASE
				
				WHEN w.country = 'USA' THEN
				w.ordered_gross_profit ELSE w.shipped_gross_profit 
			END AS profit_ordered_shipped,
		CASE
				
				WHEN w.country = 'USA' THEN
				w.cm_internal_ordered ELSE w.cm_internal_shipped 
			END AS cm_internal_ordered_shipped,
		CASE
				
				WHEN w.country = 'USA' THEN
				w.cm_external_ordered ELSE w.cm_external_shipped 
			END AS cm_external_ordered_shipped,
		CASE
				
				WHEN dp.team = 'YDL' THEN
				'Innonet' 
				WHEN dp.team = 'YSL' THEN
				'Sales&Ops' 
				WHEN dp.team = 'HMD' THEN
				'HMD' ELSE dp.team 
			END AS Department 
		FROM
			hive.sc_main.full_metrics_daily w
			LEFT JOIN ( SELECT DISTINCT asin, country country_code, wave FROM hive.sc_main.final_sellin_price WHERE country != 'USA' AND is_active IS NULL ) wa ON w.asin = wa.asin 
			AND w.country = wa.country_code
			LEFT JOIN hive.sc_main.dim_product dp ON dp.sku = w.sku 
		WHERE
			log_date >= CAST( FROM_ISO8601_TIMESTAMP ( '2021-01-01T00:00:00' ) AS DATE ) 
		AND log_date <= CAST( FROM_ISO8601_TIMESTAMP ( '2023-07-01T00:00:00' ) AS DATE )) AS virtual_table WHERE log_date >= DATE '2023-06-01' 
		AND log_date < DATE '2023-06-18' 
		AND label_currency IN ( 'USD' ) 
		AND "Department" IN ( 'HMD', 'Innonet', 'Sales&Ops' ) 
		AND company IN ( 'Y4A' ) 
ORDER BY
	"Sales Units" DESC
	
	
	#### reals sale,gmv,rev 
	SELECT country AS country,
       platform AS platform,
       NULLIF(SUM(CASE
                      WHEN country = 'USA' THEN actual_ordered_units
                      ELSE actual_shipped_units
                  END), 0) AS `Sales`,
       COALESCE(CONCAT(CASE
                           WHEN SUM(CASE
                                        WHEN country = 'USA' THEN actual_ordered_units
                                        ELSE actual_shipped_units
                                    END)/SUM(fc_shipped_units) > DAY(DATE_SUB(CURDATE(), INTERVAL 2 DAY))/31 THEN '<font color="#43A047">'
                           ELSE '<font color="#F15A60">'
                       END, FORMAT(SUM(CASE
                                           WHEN country = 'USA' THEN actual_ordered_units
                                           ELSE actual_shipped_units
                                       END)/SUM(fc_shipped_units)*100, 2), '%'), '') AS `%Achieved Sales`,
       SUM(CASE
               WHEN country = 'USA' THEN actual_ordered_gmv
               ELSE actual_shipped_gmv
           END) AS `GMV`,
       COALESCE(CONCAT(CASE
                           WHEN SUM(CASE
                                        WHEN country = 'USA' THEN actual_ordered_gmv
                                        ELSE actual_shipped_gmv
                                    END)/SUM(fc_shipped_gmv) > DAY(DATE_SUB(CURDATE(), INTERVAL 2 DAY))/31 THEN '<font color="#43A047">'
                           ELSE '<font color="#F15A60">'
                       END, FORMAT(SUM(CASE
                                           WHEN country = 'USA' THEN actual_ordered_gmv
                                           ELSE actual_shipped_gmv
                                       END)/SUM(fc_shipped_gmv)*100, 2), '%'), '') AS `%Achieved GMV`,
       SUM(CASE
               WHEN country = 'USA' THEN actual_ordered_revenue
               ELSE actual_shipped_revenue
           END) AS `Revenue`,
       COALESCE(CONCAT(CASE
                           WHEN SUM(CASE
                                        WHEN country = 'USA' THEN actual_ordered_revenue
                                        ELSE actual_shipped_revenue
                                    END)/SUM(fc_shipped_revenue) > DAY(DATE_SUB(CURDATE(), INTERVAL 2 DAY))/31 THEN '<font color="#43A047">'
                           ELSE '<font color="#F15A60">'
                       END, FORMAT(SUM(CASE
                                           WHEN country = 'USA' THEN actual_ordered_revenue
                                           ELSE actual_shipped_revenue
                                       END)/SUM(fc_shipped_revenue)*100, 2), '%'), '') AS `%Achieved Revenue`,
       max(log_date) AS `Month`
FROM
  (SELECT w.*,
          asin,
          product_name,
          subcategory,
          company,
          category,
          root_category,
          case
              when w.channel like "%WM%" THEN "Walmart"
              when w.channel like "Wayfair" THEN "Wayfair"
              else "Amazon"
          end as platform,
          CASE
              WHEN dp.team = "YDL" THEN "Innonet"
              WHEN dp.team = "YSL" THEN "Sales&Ops"
              WHEN dp.team = "HMD" THEN "HMD"
              ELSE dp.team
          END as Department,
          case
              when w.country = "USA" then "USA"
              else "International"
          end as US_NonUS,
          CASE
              WHEN w.country = "USA" THEN w.actual_ordered_profit
              ELSE w.actual_shipped_profit
          END as actual_profit_ordered_shipped
   FROM public_main.full_okr w
   LEFT JOIN sc_main.dim_product dp USING (sku)
   where w.channel != 'Local') AS virtual_table
WHERE log_date >= STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND log_date < STR_TO_DATE('2023-07-01', '%Y-%m-%d')
  AND `Department` IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
GROUP BY country,
         platform
ORDER BY `Sales` DESC




####ads, promotion, profit 
SELECT country AS country,
       platform AS platform,
       sum(actual_promo_spent) AS `Promotion Spend`,
       COALESCE(CONCAT(CASE
                           WHEN SUM(actual_promo_spent)/SUM(fc_promo_spent) > DAY(DATE_SUB(CURDATE(), INTERVAL 2 DAY))/31 THEN '<font color="#43A047">'
                           ELSE '<font color="#F15A60">'
                       END, FORMAT(SUM(actual_promo_spent)/SUM(fc_promo_spent)*100, 2), '%'), '') AS `%Achieved Promotion`,
       sum(actual_dsp_spent) AS `DSP Spend`,
       sum(actual_ppc_spent) AS `PPC Spend`,
       COALESCE(CONCAT(CASE
                           WHEN (sum(actual_ppc_spent))/(sum(fc_ppc_spent)) >= 1 THEN '<font color="#43A047">'
                           ELSE '<font color="#F15A60">'
                       END, FORMAT((sum(actual_ppc_spent))/(sum(fc_ppc_spent))*100, 2), '%'), '') AS `%Achieved PPC`,
       (SUM(CASE
                WHEN country = 'USA' THEN actual_ordered_profit
                ELSE actual_shipped_profit
            END) - sum(actual_ppc_spent) - sum(actual_dsp_spent) - sum(actual_promo_spent)) AS `Profit`,
       COALESCE(CONCAT(CASE
                           WHEN (SUM(CASE
                                         WHEN country = 'USA' THEN actual_ordered_profit
                                         ELSE actual_shipped_profit
                                     END) - sum(actual_ppc_spent) - sum(actual_dsp_spent) - sum(actual_promo_spent)) - sum(fc_profit) >= 0 THEN '<font color="#43A047">$'
                           ELSE '<font color="#F15A60">-$'
                       END, FORMAT(ABS((SUM(CASE
                                                WHEN country = 'USA' THEN actual_ordered_profit
                                                ELSE actual_shipped_profit
                                            END) - SUM(actual_ppc_spent) - SUM(actual_dsp_spent) - SUM(actual_promo_spent)) - SUM(fc_profit)), 2)), '') AS `Profit (Actual - FC) `,
       sum(fc_profit) AS `Target Profit`,
       max(log_date) AS `Month`
FROM
  (SELECT w.*,
          asin,
          product_name,
          subcategory,
          company,
          category,
          root_category,
          case
              when w.channel like "%WM%" THEN "Walmart"
              when w.channel like "Wayfair" THEN "Wayfair"
              else "Amazon"
          end as platform,
          CASE
              WHEN dp.team = "YDL" THEN "Innonet"
              WHEN dp.team = "YSL" THEN "Sales&Ops"
              WHEN dp.team = "HMD" THEN "HMD"
              ELSE dp.team
          END as Department,
          case
              when w.country = "USA" then "USA"
              else "International"
          end as US_NonUS,
          CASE
              WHEN w.country = "USA" THEN w.actual_ordered_profit
              ELSE w.actual_shipped_profit
          END as actual_profit_ordered_shipped
   FROM public_main.full_okr w
   LEFT JOIN sc_main.dim_product dp USING (sku)
   where w.channel != 'Local') AS virtual_table
WHERE log_date >= STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND log_date < STR_TO_DATE('2023-07-01', '%Y-%m-%d')
  AND `Department` IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
GROUP BY country,
         platform
ORDER BY `Promotion Spend` DESC

	### sale by country 
	SELECT country AS country,
       channel AS channel,
       NULLIF(SUM(CASE
                      WHEN country = 'USA' THEN ordered_units
                      ELSE shipped_units
                  END), 0) AS "Sales"
FROM
  (SELECT w.*,
          company,
          root_category,
          category,
          subcategory_1,
          subcategory,
          product_name,
          wa.wave,
          CASE
              WHEN w.channel = 'WM WFS' THEN 'Walmart - Seller'
              WHEN w.channel = 'WM DSV' THEN 'Walmart - Supplier'
              WHEN w.channel IN ('Local') THEN 'Local'
              WHEN w.channel IN ('FBA',
                                 'FBM') THEN 'Amazon - Seller'
              WHEN w.channel LIKE '%AVC%' THEN 'Amazon - Vendor'
              ELSE w.channel
          END as platform,
          CASE
              WHEN w.country = 'USA' THEN w.ordered_gross_profit
              ELSE w.shipped_gross_profit
          END as profit_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_internal_ordered
              ELSE w.cm_internal_shipped
          END as cm_internal_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_external_ordered
              ELSE w.cm_external_shipped
          END as cm_external_ordered_shipped,
          CASE
              WHEN dp.team = 'YDL' THEN 'Innonet'
              WHEN dp.team = 'YSL' THEN 'Sales&Ops'
              WHEN dp.team = 'HMD' THEN 'HMD'
              ELSE dp.team
          END as Department
   FROM hive.sc_main.full_metrics_daily w
   LEFT JOIN
     (SELECT DISTINCT asin,
                      country country_code,
                      wave
      FROM hive.sc_main.final_sellin_price
      WHERE country !='USA'
        AND is_active IS NULL) wa on w.asin = wa.asin
   and w.country = wa.country_code
   LEFT JOIN hive.sc_main.dim_product dp on dp.sku = w.sku
   WHERE log_date >= CAST(FROM_ISO8601_TIMESTAMP('2021-01-01T00:00:00') AS DATE)
     AND log_date <= CAST(FROM_ISO8601_TIMESTAMP('2023-07-01T00:00:00') AS DATE)) AS virtual_table
WHERE log_date >= DATE '2023-06-01'
  AND log_date < DATE '2023-06-18'
  AND label_currency IN ('USD')
  AND "Department" IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
  AND company IN ('Y4A')
GROUP BY country,
         channel

### gmv by country 
SELECT country AS country,
       channel AS channel,
       NULLIF(SUM(CASE
                      WHEN country = 'USA' THEN ordered_gmv
                      ELSE shipped_gmv
                  END), 0) AS "GMV"
FROM
  (SELECT w.*,
          company,
          root_category,
          category,
          subcategory_1,
          subcategory,
          product_name,
          wa.wave,
          CASE
              WHEN w.channel = 'WM WFS' THEN 'Walmart - Seller'
              WHEN w.channel = 'WM DSV' THEN 'Walmart - Supplier'
              WHEN w.channel IN ('Local') THEN 'Local'
              WHEN w.channel IN ('FBA',
                                 'FBM') THEN 'Amazon - Seller'
              WHEN w.channel LIKE '%AVC%' THEN 'Amazon - Vendor'
              ELSE w.channel
          END as platform,
          CASE
              WHEN w.country = 'USA' THEN w.ordered_gross_profit
              ELSE w.shipped_gross_profit
          END as profit_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_internal_ordered
              ELSE w.cm_internal_shipped
          END as cm_internal_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_external_ordered
              ELSE w.cm_external_shipped
          END as cm_external_ordered_shipped,
          CASE
              WHEN dp.team = 'YDL' THEN 'Innonet'
              WHEN dp.team = 'YSL' THEN 'Sales&Ops'
              WHEN dp.team = 'HMD' THEN 'HMD'
              ELSE dp.team
          END as Department
   FROM hive.sc_main.full_metrics_daily w
   LEFT JOIN
     (SELECT DISTINCT asin,
                      country country_code,
                      wave
      FROM hive.sc_main.final_sellin_price
      WHERE country !='USA'
        AND is_active IS NULL) wa on w.asin = wa.asin
   and w.country = wa.country_code
   LEFT JOIN hive.sc_main.dim_product dp on dp.sku = w.sku
   WHERE log_date >= CAST(FROM_ISO8601_TIMESTAMP('2021-01-01T00:00:00') AS DATE)
     AND log_date <= CAST(FROM_ISO8601_TIMESTAMP('2023-07-01T00:00:00') AS DATE)) AS virtual_table
WHERE log_date >= DATE '2023-06-01'
  AND log_date < DATE '2023-06-18'
  AND label_currency IN ('USD')
  AND "Department" IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
  AND company IN ('Y4A')
GROUP BY country,
         channel


#### sale by channel 
SELECT DATE(log_date) AS __timestamp,
       IFNULL(sum(case
                      when channel like '%AVC DI%' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `AVC DI`,
       IFNULL(sum(case
                      when channel like '%AVC DS%' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `AVC DS`,
       IFNULL(sum(case
                      when channel like '%AVC WH%' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `AVC WH`,
       IFNULL(sum(case
                      when channel = 'AVC' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `AVC`,
       IFNULL(sum(case
                      when channel = 'FBA' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `FBA`,
       IFNULL(sum(case
                      when channel = 'FBM' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `FBM`,
       IFNULL(sum(case
                      when channel = 'WM DSV' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `WM DSV`,
       IFNULL(sum(case
                      when channel = 'WM WFS' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `WM WFS`,
       IFNULL(sum(case
                      when channel = 'Wayfair' then IF(country = 'USA', ordered_units, shipped_units)
                      else 0
                  end), 0) AS `Wayfair`
FROM
  (SELECT distinct w.*,
                   LOG_DATE AS 'shipped_date',
                   ORDERED_UNITS AS 'qty',
                   CASE
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='WM DSV' THEN '00A2E8'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='FBA' THEN 'FFAB91'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='Local' THEN '43A047'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='FBM' THEN 'F15A60'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='AVC DS' THEN 'FFD54F'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='AVC WH' THEN '81C784'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='AVC DI' THEN '43A047'
                       WHEN COUNTRY ='USA'
                            AND w.CHANNEL ='WM WFS' THEN '99D9EA'
                       WHEN COUNTRY ='CAN'
                            AND w.CHANNEL ='AVC DI' THEN 'BFD834'
                       WHEN COUNTRY ='CAN'
                            AND w.CHANNEL ='FBA' THEN 'BFD834'
                       WHEN COUNTRY ='AUS'
                            AND w.CHANNEL ='AVC DI' THEN 'FFAB91'
                       WHEN COUNTRY ='JPN'
                            AND w.CHANNEL ='AVC DI' THEN 'FFD54F'
                       WHEN COUNTRY ='MEX'
                            AND w.CHANNEL ='AVC DI' THEN 'A349A4'
                       WHEN COUNTRY ='MEX'
                            AND w.CHANNEL ='FBA' THEN 'A349A4'
                       WHEN COUNTRY ='ARE'
                            AND w.CHANNEL ='AVC DI' THEN 'ED1C24'
                       WHEN COUNTRY ='SGP'
                            AND w.CHANNEL ='AVC DI' THEN 'C8BFE7'
                       WHEN COUNTRY ='GBR'
                            AND w.CHANNEL ='AVC DI' THEN '00A2E8'
                       WHEN COUNTRY ='DEU'
                            AND w.CHANNEL ='AVC DI' THEN '99D9EA'
                       WHEN COUNTRY ='JPN'
                            AND w.CHANNEL ='FBA' THEN 'FFD54F'
                   END AS HTML_CODE,
                   company,
                   root_category,
                   category,
                   subcategory_1,
                   subcategory,
                   product_name,
                   CASE
                       WHEN created_at < date_sub(curdate(), interval 1 year) THEN 'Old Product'
                       ELSE 'New Product'
                   END product_status,
                   CASE
                       WHEN w.channel = "WM WFS" THEN "Walmart - Seller"
                       WHEN w.channel = "WM DSV" THEN "Walmart - Supplier"
                       WHEN w.channel IN ("Local") THEN "Local"
                       WHEN w.channel IN ("FBA",
                                          "FBM") THEN "Amazon - Seller"
                       WHEN w.channel LIKE "%AVC%" THEN "Amazon - Vendor"
                   END as platform,
                   CASE
                       WHEN w.country = "USA" THEN w.ordered_gross_profit
                       ELSE w.shipped_gross_profit
                   END as profit_ordered_shipped,
                   CASE
                       WHEN w.country = "USA" THEN w.cm_internal_ordered
                       ELSE w.cm_internal_shipped
                   END as cm_internal_ordered_shipped,
                   CASE
                       WHEN w.country = "USA" THEN w.cm_external_ordered
                       ELSE w.cm_external_shipped
                   END as cm_external_ordered_shipped,
                   CASE
                       WHEN dp.team = "YDL" THEN "Innonet"
                       WHEN dp.team = "YSL" THEN "Sales&Ops"
                       WHEN dp.team = "HMD" THEN "HMD"
                       ELSE dp.team
                   END as Department
   FROM public_main.sale_performance_by_channel w
   left join sc_main.dim_product dp using (sku)
   WHERE LABEL_CURRENCY='USD') AS virtual_table
WHERE log_date >= STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND log_date < STR_TO_DATE('2023-06-18', '%Y-%m-%d')
  AND label_currency IN ('USD')
  AND `Department` IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
  AND company IN ('Y4A')
GROUP BY DATE(log_date)
ORDER BY `AVC DI` DESC


## customer return 
SELECT date_trunc('day', CAST(log_date AS TIMESTAMP)) AS __timestamp,
       sum(customer_return) AS "Quantity Return"
FROM
  (SELECT w.*,
          company,
          root_category,
          category,
          subcategory_1,
          subcategory,
          product_name,
          wa.wave,
          CASE
              WHEN w.channel = 'WM WFS' THEN 'Walmart - Seller'
              WHEN w.channel = 'WM DSV' THEN 'Walmart - Supplier'
              WHEN w.channel IN ('Local') THEN 'Local'
              WHEN w.channel IN ('FBA',
                                 'FBM') THEN 'Amazon - Seller'
              WHEN w.channel LIKE '%AVC%' THEN 'Amazon - Vendor'
              ELSE w.channel
          END as platform,
          CASE
              WHEN w.country = 'USA' THEN w.ordered_gross_profit
              ELSE w.shipped_gross_profit
          END as profit_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_internal_ordered
              ELSE w.cm_internal_shipped
          END as cm_internal_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_external_ordered
              ELSE w.cm_external_shipped
          END as cm_external_ordered_shipped,
          CASE
              WHEN dp.team = 'YDL' THEN 'Innonet'
              WHEN dp.team = 'YSL' THEN 'Sales&Ops'
              WHEN dp.team = 'HMD' THEN 'HMD'
              ELSE dp.team
          END as Department
   FROM hive.sc_main.full_metrics_daily w
   LEFT JOIN
     (SELECT DISTINCT asin,
                      country country_code,
                      wave
      FROM hive.sc_main.final_sellin_price
      WHERE country !='USA'
        AND is_active IS NULL) wa on w.asin = wa.asin
   and w.country = wa.country_code
   LEFT JOIN hive.sc_main.dim_product dp on dp.sku = w.sku
   WHERE log_date >= CAST(FROM_ISO8601_TIMESTAMP('2021-01-01T00:00:00') AS DATE)
     AND log_date <= CAST(FROM_ISO8601_TIMESTAMP('2023-07-01T00:00:00') AS DATE)) AS virtual_table
WHERE log_date >= DATE '2023-06-01'
  AND log_date < DATE '2023-06-18'
  AND label_currency IN ('USD')
  AND "Department" IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
  AND company IN ('Y4A')
GROUP BY date_trunc('day', CAST(log_date AS TIMESTAMP))
ORDER BY "Quantity Return" DESC


### sale performance 
SELECT subcategory AS subcategory,
       SUM(case
               when country = 'USA' then (ordered_units)
               else (shipped_units)
           end) AS "Sales Units",
       sum(case
               when country = 'USA' then (ordered_gmv)
               else (shipped_gmv)
           end) AS "Sales GMV",
       sum(ordered_gmv)/nullif(sum(ordered_units), 0) AS "ASP",
       sum(glance_view) AS "Glance Views",
       sum(ordered_units)/nullif(sum(glance_view), 0) AS "CR",
       sum(dsp_halo_spend) + sum(dsp_promoted_spend) + sum(sb_spend) + sum(sbv_spend) + sum(sd_spend) + sum(sp_spend) + sum(vc_promo_spend) + sum(coupon_spend) + sum(vm_promo_spend) AS "Marketing Spend",
       sum(sb_spend) + sum(sbv_spend) + sum(sd_spend) + sum(sp_spend) AS "PPC Spend",
       sum(dsp_halo_spend) + sum(dsp_promoted_spend) AS "DSP Spend",
       sum(vm_promo_spend) + sum(vc_promo_spend) +sum(coupon_spend) AS "Promotion Spend",
       SUM(profit_ordered_shipped - (vm_promo_spend + coupon_spend + vc_promo_spend + sb_spend + sbv_spend + sd_spend + sp_spend + dsp_halo_spend + dsp_promoted_spend)) AS "Profit",
       sum(coupon_spend) AS "Coupon Spend"
FROM
  (SELECT w.*,
          company,
          root_category,
          category,
          subcategory_1,
          subcategory,
          product_name,
          wa.wave,
          CASE
              WHEN w.channel = 'WM WFS' THEN 'Walmart - Seller'
              WHEN w.channel = 'WM DSV' THEN 'Walmart - Supplier'
              WHEN w.channel IN ('Local') THEN 'Local'
              WHEN w.channel IN ('FBA',
                                 'FBM') THEN 'Amazon - Seller'
              WHEN w.channel LIKE '%AVC%' THEN 'Amazon - Vendor'
              ELSE w.channel
          END as platform,
          CASE
              WHEN w.country = 'USA' THEN w.ordered_gross_profit
              ELSE w.shipped_gross_profit
          END as profit_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_internal_ordered
              ELSE w.cm_internal_shipped
          END as cm_internal_ordered_shipped,
          CASE
              WHEN w.country = 'USA' THEN w.cm_external_ordered
              ELSE w.cm_external_shipped
          END as cm_external_ordered_shipped,
          CASE
              WHEN dp.team = 'YDL' THEN 'Innonet'
              WHEN dp.team = 'YSL' THEN 'Sales&Ops'
              WHEN dp.team = 'HMD' THEN 'HMD'
              ELSE dp.team
          END as Department
   FROM hive.sc_main.full_metrics_daily w
   LEFT JOIN
     (SELECT DISTINCT asin,
                      country country_code,
                      wave
      FROM hive.sc_main.final_sellin_price
      WHERE country !='USA'
        AND is_active IS NULL) wa on w.asin = wa.asin
   and w.country = wa.country_code
   LEFT JOIN hive.sc_main.dim_product dp on dp.sku = w.sku
   WHERE log_date >= CAST(FROM_ISO8601_TIMESTAMP('2021-01-01T00:00:00') AS DATE)
     AND log_date <= CAST(FROM_ISO8601_TIMESTAMP('2023-07-01T00:00:00') AS DATE)) AS virtual_table
WHERE log_date >= DATE '2023-06-01'
  AND log_date < DATE '2023-06-18'
  AND label_currency IN ('USD')
  AND "Department" IN ('HMD',
                       'Innonet',
                       'Sales&Ops')
  AND company IN ('Y4A')
GROUP BY subcategory
ORDER BY "Sales Units" DESC





	
	
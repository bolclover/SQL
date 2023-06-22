
select kpi.* 
				, case when country = 'USA' and `Source.Name` like '%AMZ%' and `Source.Name` not like '%furn%'  then 'US_SG_AMZ'  
							 when country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') THEN 'International' 
							 when country = 'USA' and `Source.Name` like '%WM%' and `Source.Name` not like '%furn%' and Channel in ('WM WFS', 'WM DSV')  then 'Walmart'
							 when country ='USA' and `Source.Name` like '%fur%' then 'Furniture'
							 else 'check' end as group_KPI			
				, CASE when country = 'USA' and `Source.Name` like '%AMZ%' and `Source.Name` not like '%furn%'  then 'US_SG_AMZ' 
							 when country = 'USA' and `Source.Name` like '%WM%' and `Source.Name` not like '%furn%' and Channel in ('WM WFS', 'WM DSV')  then 'Walmart - Sporting Goods'	
							 when country = 'USA' and `Source.Name` like '%WM%' and `Source.Name` like '%furn%' and Channel in ('WM WFS', 'WM DSV')  then 'Walmart - Furniture'	
							 when country = 'USA' and `Source.Name` like '%AMZ%' and `Source.Name` like '%furn%' and Channel in ('FBA','FBM','AVC','AVC DS','AVC WH','AVC DI')  then 'Furniture - Amazon'	
							 when country = 'USA' and `Source.Name` like '%WF%' and `Source.Name` like '%furn%' and Channel in ('Wayfair','WF')  then 'Furniture - Wayfair'
							 when country in ('CAN','MEX','JPN','ARE','SGP','AUS') then 'International-DIP6'
							 when country in ('DEU','GBR','ITA','FRA','ESP') THEN 'International-EUUK'
							 else 'check' end as line_KPI							
									
from 

(
with data_sg as 
(SELECT
      b.`Source.Name`,
      `Month`,
      b.Platform,
      log_date_key, COUNTRY,
      RANK() OVER ( PARTITION BY Platform, COUNTRY ORDER BY log_date_key DESC, `month` ) AS rank_12M 
    FROM
      forecast_version a
      JOIN dim_version b ON a.`Source.Name` = b.`Source.Name` 
    WHERE final_version = 'yes' 
		and a.`Source.Name` not like '%furn%' 
		and a.`Source.Name` not like '%sku%' 
		and `month` is not null
		and year(`month`) < 2024
    GROUP BY
      `source.name`, MONTH, Platform, log_date_key,country 
    ORDER BY
      log_date_key DESC 
			)
			

,data_fur as 
(SELECT
      b.`Source.Name`,
      `Month`,
      b.Platform,
      log_date_key, COUNTRY,
      RANK() OVER ( PARTITION BY Platform, COUNTRY ORDER BY log_date_key DESC, `month` ) AS rank_12M 
    FROM
      forecast_version a
      JOIN dim_version b ON a.`Source.Name` = b.`Source.Name` 
    WHERE final_version = 'yes' 
		and a.`Source.Name` like '%furn%' 
		and a.`Source.Name` not like '%sku%' 
		and a.`Source.Name` not like '%sport%' 
		and `month` is not null
		and year(`month`) < 2024
    GROUP BY
      `source.name`, MONTH, Platform, log_date_key,country 
    ORDER BY
      log_date_key DESC )

, data_nosku as 
(SELECT
      b.`Source.Name`,
      `Month`,
      b.Platform,
      log_date_key, COUNTRY,
      RANK() OVER ( PARTITION BY Platform, COUNTRY ORDER BY log_date_key DESC, `month` ) AS rank_12M 
    FROM
      forecast_version a
      JOIN dim_version b ON a.`Source.Name` = b.`Source.Name` 
    WHERE final_version = 'yes' 
		and a.`Source.Name` like '%sku%' 
		and `month` is not null
		and year(`month`) < 2024
    GROUP BY
      `source.name`, MONTH, Platform, log_date_key,country 
    ORDER BY
      log_date_key DESC )






 
SELECT
 c.`Source.Name`
,c.country
,c.channel
,c.`Month`
,c.SKU
,c.`Group Name`
,c.`Product Name`
,c.`Real sales`
,c.Revenue
,c.GMV
,c.SEM
,c.DSP
,c.Promotion
,c.Profit
,c.`Return`
,c.Cogs
,c.Referral
,c.COOP
,c.Freight
,c.MSF_and_DIP
,c.`Shipping fee`
,c.Insurance
,c.`SAS fee`
,c.`Fulfillment fee`
,c.`Storage`
,c.`Local Charge`
,c.Logistics
,c.`G&A`
,c.Chargebacks
,c.platform
,c.Subcategory
,c.Stratery
,c.product_type
,c.shooting
FROM
  forecast_version c
  left JOIN (
select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_sg a 
			WHERE `month`='2023-12-01'
			group by 2,3,4
			
			
		UNION all 
		
				select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-11-01'
			group by 2,3,4 
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-10-01'
			group by 2,3,4
			
			UNION 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-09-01'
			group by 2,3,4 
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_sg a 
			WHERE `month`='2023-08-01'
			group by 2,3,4
			
			UNION all  
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-07-01'
			group by 2,3,4
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-06-01'
			group by 2,3,4
			
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_sg a 
			WHERE `month`='2023-05-01'
			group by 2,3,4
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_sg a 
			WHERE `month`='2023-04-01'
			group by 2,3,4
	UNION all 
	
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		    data_sg a 
			WHERE `month`='2023-03-01'
			group by 2,3,4 
			
			UNION all
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		  data_sg a 
			WHERE `month`='2023-02-01'
			group by 2,3,4 
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		 data_sg a 
			WHERE `month`='2023-01-01'
			group by 2,3,4
			
			
			UNION all 
			
					select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		 data_fur a 
			WHERE `month`='2023-12-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-11-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-10-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-09-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-08-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-07-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-06-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-05-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-04-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-03-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-02-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_fur a 
			WHERE `month`='2023-01-01'
			group by 2,3,4 
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-12-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-11-01'
			group by 2,3,4 
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-10-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-09-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-08-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-07-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-06-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-05-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-04-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-03-01'
			group by 2,3,4
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-02-01'
			group by 2,3,4
			
			
			UNION all 
			
			select `Source.Name`,`month`,Platform,country, max(log_date_key)
		from 
		   data_nosku a 
			WHERE `month`='2023-01-01'
			group by 2,3,4
			
			
			
  ) d ON c.`Source.Name` = d.`Source.Name` AND c.`Month` = d.`Month` and c.Country = d.Country
	WHERE c.`Source.Name` = d.`Source.Name` AND c.`Month` = d.`Month` and c.Country = d.Country
	
) kpi 
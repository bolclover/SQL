delete from KPI_tracking_weekly
where  `Source.Name`='FC_sport_AMZ_USA_20230420_kpi.xlsx'

DELETE from test_KPI_month 
WHERE country ='USA'

update forecast_version
set sku='9e00'
WHERE sku='9'

update walmart_price_map 
set channel = 'WM DSV' WHERE Channel = 'AVC'


DELETE from forecast_version
where `Source.Name` = 'FC_furni_nosku_WF_USA_20230418_v4.1.xlsx'
update KPI_2023_sentFA_20230307 
set log_date = '2023-03-07' 
WHERE Platform = 'WM'

update KPI_tracking_monthly 
set Month ='2023-09-01'
WHERE Month ='Friday, September 1, 2023'


CREATE table KPI_month_test AS
 SELECT *
FROM(
	SELECT
		* 
	FROM
		smkt_main.KPI_tracking_monthly 
	WHERE
		`Month` IN ( '2023-01-01', '2023-02-01' ) 
		AND `Source.Name` = 'FC_sport_AMZ_USA_20230215.xlsx' UNION all
	SELECT
		* 
	FROM
		smkt_main.KPI_tracking_monthly 
	WHERE
	`Source.Name` IN ( 'FC_sport_AMZ_USA_20230316.xlsx', 'FC_sport_WM_USA_20230111.xlsx' ) 
	)a
	
	
	
	
	SELECT DISTINCT `First day of week` from KPI_tracking_weekly
	
	
update KPI_tracking_weekly
set `First day of week` ='2023-08-27'
WHERE `First day of week` ='Sunday, August 27, 2023'

CREATE table KPI_week_test AS
 SELECT *
FROM(
	SELECT
		* 
	FROM
		smkt_main.KPI_tracking_weekly
	WHERE
		`First day of week` in ('2023-01-01','2023-01-08','2023-01-15','2023-01-22','2023-01-29','2023-02-05','2023-02-12','2023-02-19','2023-02-26')
		AND `Source.Name` = 'FC_sport_AMZ_USA_20230215.xlsx'
		 UNION all
	SELECT
		* from 
		smkt_main.KPI_tracking_weekly
	WHERE
	`Source.Name` IN ( 'FC_sport_AMZ_USA_20230316.xlsx', 'FC_sport_WM_USA_20230111.xlsx' ) 
	)a



create table test_inventory_UTD as 
SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1


delete from KPI_tracking_monthly 



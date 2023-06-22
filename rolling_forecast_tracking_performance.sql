#total group theo month

#ver final 
select a.*,pic_sale,sale_team,pic_sem,sem_team from 
(
SELECT 
log_date 
,sku
,country 
,Platform
,group_KPI 
,sum(gmv) as gmv 
,sum(units) as units 
,sum(mkt_fee) as mkt_fee 
,sum(fc_units_daily) as fc_units_daily 
,sum(fc_gmv_daily) as fc_gmv_daily 
,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily 
,sum(promotion) as promotion 
,sum(sem) as sem 
,sum(fc_promotion_daily) as fc_promotion_daily 
,sum(fc_sem_daily) as fc_sem_daily 
from  

(


with tran_table as (



WITH date_update AS (
select platform, min(date_update) as date_update
from (

	SELECT
		channel,
	CASE
			WHEN date_update = CURRENT_DATE () THEN
			date_add( CURRENT_DATE (), INTERVAL - 1 DAY ) ELSE date_update 
		END AS date_update 
		, case when channel in ('FBA', 'FBM','AVC DS', 'AVC DS 2', 'AVC','AVC WH', 'AVC DI', 'AVC WH US', 'AVC DI US' ) then 'AMZ' 
				 when channel in ('WM DSV') then 'WM'
				 when channel in ('Wayfair') then 'WF' 
				 else ''
		 end as platform  
	FROM
	
		(
		SELECT DISTINCT
			channel,
			max( log_date ) AS date_update 
		FROM
			public_main.sale_performance_by_channel 
		WHERE
			channel IN ( 'FBA', 'FBM', 'WM DSV', 'AVC DS', 'AVC DS 2', 'AVC', 'WM WFS', 'Wayfair', 'AVC WH', 'AVC DI', 'AVC WH US', 'AVC DI US' ) 
			AND ordered_units <> 0 
		GROUP BY
			1 
		) a) c 
		group by 1
	)
 
 , tran_table as 
(
 select log_date,sku,country,Platform, gmv, units,fc_units_daily,fc_gmv_daily, fc_mkt_fee_daily, group_KPI,fc_promotion_daily,fc_sem_daily, sale_team,pic_sale,pic_sem,sem_team
 ,SUM(vm_promo_spend + vc_promo_spend + coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) AS mkt_fee
 ,sum(vm_promo_spend + vc_promo_spend + coupon_spend) as promotion 
 ,sum(sbv_spend + sp_spend + sd_spend + sb_spend) as sem 
from 
 (
   select a.*
				, case when (a.country = 'USA' 
										and b.root_category = 'Sporting Goods' 
										and b.team = 'YSL'
										and a.channel in ('FBA','FBM','AVC'))
										then 'US_SG_AMZ'  
										
								when (a.country = 'USA' 
										and b.root_category in('Sporting Goods','Furniture')
										and b.team = 'YSL'
										and a.channel in ('WM WFS', 'WM DSV'))
										then 'Walmart'
										
								when (#a.country = 'USA' 	and 
										b.root_category = 'Furniture' 
										and b.team = 'YSL')
										and a.channel in ('FBA','FBM','AVC','Wayfair')
										then 'Furniture' 
								when a.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') THEN 'International' 
							 else 'Deployment Lab' end as group_KPI
							  ,CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END AS units 
              ,CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END AS gmv 
		        	,case when a.channel in ('AVC','FBM','FBA') then 'AMZ'
			      when a.channel in ('WM WFS', 'WM DSV') then 'WM'
						when a.channel ='Wayfair' then 'WF'
						else "" end as Platform 
						,"" as fc_units_daily 
						,"" as fc_gmv_daily 
						,"" as fc_mkt_fee_daily 
						,"" as fc_promotion_daily 
						,"" as fc_sem_daily 
						
 from public_main.full_metrics_daily a

LEFT JOIN sc_main.dim_product b on a.sku = b.sku

where a.label_currency = 'USD' and year(log_date)>=2023 ) a GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12 )
 
 
 select * from
 (
 select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from tran_table a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'AMZ' 
 union all 
 
  select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from tran_table a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'WM' 
 union all 
  select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from tran_table a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'WF' ) c 
 where data_full= 'full' )


	,fc_month as 
	(
	
WITH date_update AS (
select platform, min(date_update) as date_update
from (

	SELECT
		channel,
	CASE
			WHEN date_update = CURRENT_DATE () THEN
			date_add( CURRENT_DATE (), INTERVAL - 1 DAY ) ELSE date_update 
		END AS date_update 
		, case when channel in ('FBA', 'FBM','AVC DS', 'AVC DS 2', 'AVC','AVC WH', 'AVC DI', 'AVC WH US', 'AVC DI US' ) then 'AMZ' 
				 when channel in ('WM DSV') then 'WM'
				 when channel in ('Wayfair') then 'WF' 
				 else ''
		 end as platform  
	FROM
	
		(
		SELECT DISTINCT
			channel,
			max( log_date ) AS date_update 
		FROM
			public_main.sale_performance_by_channel 
		WHERE
			channel IN ( 'FBA', 'FBM', 'WM DSV', 'AVC DS', 'AVC DS 2', 'AVC', 'WM WFS', 'Wayfair', 'AVC WH', 'AVC DI', 'AVC WH US', 'AVC DI US' ) 
			AND ordered_units <> 0 
		GROUP BY
			1 
		) a) c 
		group by 1
	)




,fc_month as

(SELECT 
	date as log_date
	,sku 
	,country 
	,Platform
	,`Source.Name`
	,case when platform in ('WF','AMZ') and `Source.Name` like '%fur%' and country = 'USA' then 'Furniture' 
	      when country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') then 'International'
				when Platform ='AMZ' and `Source.Name` like '%spo%' and Country ='USA' then 'US_SG_AMZ'
				when Platform ='WM' then 'Walmart'	
				else 'check' end as Group_KPI 
	,(sum(`real sales`)/day_fc) as fc_units_daily
	,(sum(gmv)/day_fc) as fc_gmv_daily
	,(sum(Promotion+sem+dsp)/day_fc) as fc_mkt_fee_daily
	,(sum(promotion)/day_fc) as fc_promotion_daily
	,(sum(sem)/day_fc) as fc_sem_daily 
	,"" as units 
	,"" as gmv
	,"" as mkt_fee
	,"" as promotion 
	,"" as sem 
	from 
	(
	SELECT a.*
	,DATE
	,day(last_day_of_month) as day_fc	
	 from KPI_tracking_monthly a 
	 left JOIN sc_main.dim_date b 
	 on a.`month` =b.first_day_of_month 
	 WHERE a.`month` is not null
	 ) a 
	 group by 1,2,3,4,5,6 )
	 
	 
	 
	 select * from
 (
 select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from fc_month a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'AMZ' 
 union all 
 
  select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from fc_month a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'WM' 
 union all 
  select a.* 
 ,case when log_date <= date_update then 'full' else '' end as data_full 
 from fc_month a 
 join date_update b 
 on a.platform =b.platform 
 where a.platform = 'WF' ) c 
 where data_full= 'full'
   ) 
	 
	 
	select log_date,sku,country,Platform, gmv, units, mkt_fee,promotion,sem,fc_units_daily,fc_gmv_daily , fc_mkt_fee_daily,fc_promotion_daily,fc_sem_daily, group_KPI  from tran_table 

	union all 
	select log_date,sku,country,Platform, gmv, units, mkt_fee,promotion,sem,fc_units_daily,fc_gmv_daily , fc_mkt_fee_daily,fc_promotion_daily,fc_sem_daily, group_KPI from fc_month


) a 
group by 1,2,3,4,5 ) a 
left JOIN 
(select log_date
			,sku
			,country
			,pic_sale
			,sale_team 
			,pic_sem 
			,sem_team
				,case when channel in ('AVC','FBM','FBA') then 'AMZ'
			      when channel in ('WM WFS', 'WM DSV') then 'WM'
						when channel ='Wayfair' then 'WF'
						else "" end as Platform 
		
from public_main.full_metrics_daily a
where year(log_date) >=2023 and label_currency = 'USD'
group by 1,2,3) b 
on a.log_date =b.log_date and a.Country =b.country and a.sku =b.sku and a.Platform=b.Platform
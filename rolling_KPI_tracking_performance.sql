#ver final 
select a.*,pic_sale,sale_team from 
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
from  

(

with tran_table as 
(
 select log_date,sku,country,Platform, group_KPI, sale_team, pic_sale 
 ,sum(gmv) as gmv 
 ,sum(units) as units 
 ,sum(fc_units_daily) as fc_units_daily
 ,sum(fc_gmv_daily) as fc_gmv_daily
 ,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily
 ,SUM(vm_promo_spend + vc_promo_spend + coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) AS mkt_fee
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
						
 from public_main.full_metrics_daily a

LEFT JOIN sc_main.dim_product b on a.sku = b.sku

where a.label_currency = 'USD' and year(log_date)>=2023 ) a GROUP BY 1,2,3,4,5 )
  
	,fc_daily as (
	SELECT
	group_KPI 
	, date as log_date
	,sku 
	,country 
	,Platform
	,(sum(fc_units_2)/day_fc) as fc_units_daily 
	,(sum(fc_gmv_2)/day_fc) as fc_gmv_daily
	,(sum(fc_mkt_fee_2)/day_fc) as fc_mkt_fee_daily
	,"" as units 
						,"" as gmv
						,"" as mkt_fee

	from 
	(
	SELECT a.*
	,DATE
	,day(last_day_of_month) as day_fc	
	 from KPI_FA_by_SKU a 
	 left JOIN sc_main.dim_date b 
	 on a.`month` =b.first_day_of_month 
	 WHERE a.`month` is not null
	 ) a 
	 WHERE version ='Bottom_up_ver2'
	 group by 1,2,3,4,5 ) 
	 
	 
	select log_date,sku,country,Platform, gmv, units, mkt_fee,fc_units_daily,fc_gmv_daily , fc_mkt_fee_daily, group_KPI  from tran_table 
	union all 
	select log_date,sku,country,Platform, gmv, units, mkt_fee,fc_units_daily,fc_gmv_daily , fc_mkt_fee_daily ,group_KPI from fc_daily 


) a 
group by 1,2,3,4,5 ) a 
left JOIN 
(select log_date
			,sku
			,country
			,pic_sale
			,sale_team 
				,case when channel in ('AVC','FBM','FBA') then 'AMZ'
			      when channel in ('WM WFS', 'WM DSV') then 'WM'
						when channel ='Wayfair' then 'WF'
						else "" end as Platform 
		
from public_main.full_metrics_daily a
where year(log_date) >=2023 and label_currency = 'USD'
group by 1,2,3) b 
on a.log_date =b.log_date and a.Country =b.country and a.sku =b.sku and a.Platform=b.Platform
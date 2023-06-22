#ver 6 by sku 

with tran_table as 
(select log_date
			,sku
			,country
			,pic_sale
			,sale_team 
      ,CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END AS final_units 
      ,CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END AS final_gmv 
			,case when channel in ('AVC','FBM','FBA') then 'AMZ'
			      when channel in ('WM WFS', 'WM DSV') then 'WM'
						when channel ='Wayfair' then 'WF'
						else "" end as Platform 
			,SUM(vm_promo_spend + vc_promo_spend + coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) AS mkt_fee
			

from public_main.full_metrics_daily a
where year(log_date) >=2023 and label_currency = 'USD'
group by 1,2,3,4,5,6,7,8
) 

,dim_product_total AS 
(SELECT * FROM sc_main.dim_product
  UNION ALL 
  SELECT * FROM smkt_main.dim_product_temp) 
	
	
,fc_daily as 
(select date
			,sku 
			,Country
			, source_name 
			,platform 
			,(fc_units/7) as fc_units_daily 
			,(fc_gmv/7) as fc_gmv_daily 
			,((fc_sem+fc_dsp+fc_promotion)/7) as fc_mkt_fee_daily 
			from 
(select date
			,b.`First day of week` as first_day_of_week 
			,sku  
			,country  
			,`Source.Name` as source_name
			,platform 
			,sum(`real sales`) as fc_units 
			,sum(GMV) as fc_gmv 
			,sum(sem) as fc_sem 
			,sum(dsp) as fc_dsp 
			,sum(promotion) as fc_promotion 
		
from sc_main.dim_date a 
left join KPI_tracking_weekly b 
on a.first_day_of_week =b.`First day of week`
group by 1,2,3,4,5,6 ) a 
where first_day_of_week is not null 
group by 1,2,3,4,5 ) 

,fc_monthly as (
select 
		date
		,sku
		,country
		,source_name 
		,platform 
		,(`real sales`/day_fc) as fc_units_daily
		,(gmv/day_fc) as fc_gmv_daily
		,((Promotion+sem+dsp)/day_fc) as fc_mkt_fee_daily
from 
(
select date
			,b.`month`
			,day(last_day_of_month) as day_fc
			,sku
			,country
			,`source.name` as source_name
			,platform 
			,sum(`Real sales`) as `Real sales` 
			,sum(gmv) as gmv
			,sum(sem) as sem 
			,sum(dsp) as dsp 
			,sum(promotion) as Promotion
from sc_main.dim_date a 
left join smkt_main.KPI_tracking_monthly b 
on b.`month`= a.first_day_of_month
WHERE b.`month` is not null 
group by 1,2,3,4,5,6,7
) a 
group by 1,2,3,4,5 ) 


select 
log_date
,a.sku 
,a.root_category 
,a.platform 
,a.country 
,source_name 
,pic_sale 
,sale_team
,sum(units) as units 
,sum(gmv) as gmv 
,sum(mkt_fee) as mkt_fee 
,sum(fc_units_daily) as fc_units_daily
,sum(fc_gmv_daily) as fc_gmv_daily
,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily
,case when a.country = 'USA' and a.root_category = 'Sporting Goods' and a.Platform = 'AMZ' then 'US_SG_AMZ'  
		  when source_name like '%AMZ_USA%' then 'US_SG_AMZ'
else 'check' end as group_KPI
		
from 
(select log_date 
			 ,a.sku 
			 ,a.root_category 
			 ,b.platform  
			 ,country
			 ,pic_sale 
			 ,sale_team
			 ,sum(final_units) as units 
			 ,sum(final_gmv) as gmv 
			 ,sum(mkt_fee) as mkt_fee 
			 
from dim_product_total a
left join tran_table b 
on a.sku = b.sku 
where company ='Y4A' and team ='YSL' and a.root_category = 'Sporting Goods' and b.Platform ='AMZ'
group by 1,2,3,4,5,6,7
) a 
left join fc_daily b 
on a.log_date = b.date and a.sku = b.sku and a.country = b.country and a.Platform = b.platform 
WHERE a.country not in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') 
and source_name like '%AMZ_USA%' and source_name not like '%fur%'
group by 1,2,3,4,5,6,7,8

UNION all 

select 
log_date
,a.sku 
,a.root_category 
,a.platform 
,a.country 
,source_name 
,pic_sale 
,sale_team
,sum(units) as units 
,sum(gmv) as gmv 
,sum(mkt_fee) as mkt_fee 
,sum(fc_units_daily) as fc_units_daily
,sum(fc_gmv_daily) as fc_gmv_daily
,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily
,case 
			when a.country = 'USA' and a.root_category in ('Sporting Goods','Furniture') and a.platform ='WM' then 'Walmart'
			when source_name like '%WM%' then 'Walmart'
else 'check' end as group_KPI
		
from 
(select log_date 
			 ,a.sku 
			 ,a.root_category 
			 ,b.platform  
			 ,country
			 ,pic_sale 
			 ,sale_team
			 ,sum(final_units) as units 
			 ,sum(final_gmv) as gmv 
			 ,sum(mkt_fee) as mkt_fee 
			 
from dim_product_total a
left join tran_table b 
on a.sku = b.sku 
where company ='Y4A' and team ='YSL' and a.root_category in ('Sporting Goods','Furniture') and b.Platform ='WM'
group by 1,2,3,4,5,6,7
) a 
left join fc_daily b 
on a.log_date = b.date and a.sku = b.sku and a.country = b.country and a.Platform = b.platform 
WHERE a.country not in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') and source_name like '%WM%' 
group by 1,2,3,4,5,6,7,8

union all 
select 
log_date
,a.sku 
,a.root_category 
,a.Platform
,a.country 
,source_name 
,pic_sale 
,sale_team
,sum(units) as units 
,sum(gmv) as gmv 
,sum(mkt_fee) as mkt_fee 
,sum(fc_units_daily) as fc_units_daily
,sum(fc_gmv_daily) as fc_gmv_daily
,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily
,case when a.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') then 'International'
else 'check' end as group_KPI
		
from 
(select log_date 
			 ,a.sku 
			 ,a.root_category 
			 ,b.platform
			 ,country
			 ,pic_sale 
			 ,sale_team
			 ,sum(final_units) as units 
			 ,sum(final_gmv) as gmv 
			 ,sum(mkt_fee) as mkt_fee 
			 
from dim_product_total a
left join tran_table b 
on a.sku = b.sku 
where company ='Y4A' and a.root_category in ('Sporting Goods') and  b.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP')
group by 1,2,3,4,5,6,7
) a 
left join fc_monthly b 
on a.log_date = b.date and a.sku = b.sku and a.country = b.country and a.Platform = b.Platform 
where a.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP')
group by 1,2,3,4,5,6,7,8 

union all 
select 
log_date
,a.sku 
,a.root_category 
,a.Platform
,a.country 
,source_name 
,pic_sale 
,sale_team
,sum(units) as units 
,sum(gmv) as gmv 
,sum(mkt_fee) as mkt_fee 
,sum(fc_units_daily) as fc_units_daily
,sum(fc_gmv_daily) as fc_gmv_daily
,sum(fc_mkt_fee_daily) as fc_mkt_fee_daily
,case when  a.Platform in ('AMZ','WF') then 'Furniture'
else 'check' end as group_KPI
		
from 
(select log_date 
			 ,a.sku 
			 ,a.root_category 
			 ,b.platform
			 ,country
			 ,pic_sale 
			 ,sale_team
			 ,sum(final_units) as units 
			 ,sum(final_gmv) as gmv 
			 ,sum(mkt_fee) as mkt_fee 
			 
from dim_product_total a
left join tran_table b 
on a.sku = b.sku 
where company ='Y4A' and team ='YSL' and a.root_category in ('Furniture') and b.Platform in ('AMZ','WF')
group by 1,2,3,4,5,6,7
) a 
left join fc_monthly b 
on a.log_date = b.date and a.sku = b.sku and a.country = b.country and a.Platform = b.Platform
where source_name like '%fur%' and source_name not like '%WM%' 
group by 1,2,3,4,5,6,7,8

with full_metrics as 
(select a.*
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
				 , case when country = "USA" then ordered_units else shipped_units end as final_units 
				 , case when country = "USA" then ordered_gmv else shipped_gmv end as final_gmv 
 from public_main.full_metrics_daily a
LEFT JOIN sc_main.dim_product b on a.sku = b.sku
where a.label_currency = 'USD' )

#all
#furniture
select g.date 
			,g.subcategory
			,g.country 
			,sum(g.fc_units_daily) as fc_units_daily
			,SUM(g.fc_gmv_daily) AS fc_gmv_daily
			,SUM(g.fc_mkt_fee_daily) AS fc_mkt_fee_daily
			,f.pic_sale
			,f.sale_team
			,SUM(f.units) AS units 
			,sum(f.gmv) as gmv 
			,sum(f.mkt_fee) mkt_fee 
			,case when date <> 0 then "furniture"
			else "" end as group_KPI

from  
(
select m.date 
				,m.Subcategory 
				,m.country 
				,sum(fc_units_daily) as fc_units_daily 
				,sum(fc_gmv_daily) as fc_gmv_daily 
				,sum(fc_promotion_daily) as fc_promotion_daily 
				,sum(fc_sem_daily) as fc_sem_daily 
				,sum(fc_dsp_daily) as fc_dsp_daily 
				,sum(fc_promotion_daily+fc_sem_daily+fc_dsp_daily) as fc_mkt_fee_daily

from (

select h.date, h.Subcategory,country,sum(fc_units_daily) as fc_units_daily ,sum(fc_gmv_daily) as fc_gmv_daily, sum(fc_promotion_daily) as fc_promotion_daily, sum(fc_sem_daily) as fc_sem_daily ,sum(fc_dsp_daily) as fc_dsp_daily
from 
(select date,sku,`Group Name` as Subcategory ,country,(`real sales`/7) as fc_units_daily,(gmv/7) as fc_gmv_daily, (Promotion/7) as fc_promotion_daily, (sem/7) as fc_sem_daily ,(dsp/7) as fc_dsp_daily 
from 
(
select date,b.`First day of week`,sku,`Group Name`,country,sum(`Real sales`) as `Real sales` , sum(gmv) as gmv, sum(sem) as sem ,sum(dsp) as dsp ,sum(promotion) as Promotion
from sc_main.dim_date a 
left join smkt_main.KPI_tracking_weekly b 
on b.`First day of week`= a.first_day_of_week
WHERE b.`First day of week` is not null and `Source.Name` like "%furn%" and `Source.Name` not like "%WM%"
group by 1,2,3,4,5
) a 
group by 1,2,3) h

left join sc_main.dim_product d 
on h.Subcategory=d.Subcategory
group by 1,2,3
) m 
group by 1,2,3
) g
left join 
(
select log_date 
,country
,c.subcategory
,pic_sale
,sale_team
,sum(final_units) as units
,sum(final_gmv) as gmv 
,sum(vm_promo_spend+vc_promo_spend+coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) as mkt_fee
from full_metrics b  
join sc_main.dim_product c 
on b.sku=c.sku 
where group_KPI= "furniture" and year(log_date)>=2023
group by 1,2,3,4,5
) f
on g.date=f.log_date and g.country=f.country and g.Subcategory=f.Subcategory
group by 1,2,3
union all 
#international
select g.date 
			,g.subcategory
			,g.country 
			,sum(g.fc_units_daily) as fc_units_daily
			,SUM(g.fc_gmv_daily) AS fc_gmv_daily
			,SUM(g.fc_mkt_fee_daily) AS fc_mkt_fee_daily
			,f.pic_sale
			,f.sale_team
			,SUM(f.units) AS units 
			,sum(f.gmv) as gmv 
			,sum(f.mkt_fee) mkt_fee 
			,case when date <> 0 then "International"
			else "" end as group_KPI

from  
(
select c.date 
				,d.Subcategory 
				,c.country 
				,sum(fc_units_daily) as fc_units_daily 
				,sum(fc_gmv_daily) as fc_gmv_daily 
				,sum(fc_promotion_daily) as fc_promotion_daily 
				,sum(fc_sem_daily) as fc_sem_daily 
				,sum(fc_dsp_daily) as fc_dsp_daily 
				,sum(fc_promotion_daily+fc_sem_daily+fc_dsp_daily) as fc_mkt_fee_daily

from (
select date,sku,country,(`real sales`/day_fc) as fc_units_daily,(gmv/day_fc) as fc_gmv_daily, (Promotion/day_fc) as fc_promotion_daily, (sem/day_fc) as fc_sem_daily ,(dsp/day_fc) as fc_dsp_daily 
from 
(
select date,b.`month`,day(last_day_of_month) as day_fc,sku,country,sum(`Real sales`) as `Real sales` , sum(gmv) as gmv, sum(sem) as sem ,sum(dsp) as dsp ,sum(promotion) as Promotion
from sc_main.dim_date a 
left join smkt_main.KPI_tracking_monthly b 
on b.`month`= a.first_day_of_month
WHERE b.`month` is not null and country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP')
group by 1,2,3,4,5
) a 
group by 1,2,3) c 
join sc_main.dim_product d 
on c.sku=d.sku 
group by 1,2,3

) g
left join 
(
select log_date 
,country
,c.subcategory
,pic_sale
,sale_team
,sum(final_units) as units
,sum(final_gmv) as gmv 
,sum(vm_promo_spend+vc_promo_spend+coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) as mkt_fee
from full_metrics b  
join sc_main.dim_product c 
on b.sku=c.sku 
where group_KPI= "International" and year(log_date)>=2023
group by 1,2,3,4,5
) f
on g.date=f.log_date and g.country=f.country and g.Subcategory=f.Subcategory
group by 1,2,3


union all 

#US_SG_AMZ
select g.date 
			,g.subcategory
			,g.country 
			,sum(g.fc_units_daily) as fc_units_daily
			,SUM(g.fc_gmv_daily) AS fc_gmv_daily
			,SUM(g.fc_mkt_fee_daily) AS fc_mkt_fee_daily
			,f.pic_sale
			,f.sale_team
			,SUM(f.units) AS units 
			,sum(f.gmv) as gmv 
			,sum(f.mkt_fee) mkt_fee 
			,case when date <> 0 then "US_SG_AMZ"
			else "" end as group_KPI

from  
(
select c.date 
				,d.Subcategory 
				,c.country 
				,sum(fc_units_daily) as fc_units_daily 
				,sum(fc_gmv_daily) as fc_gmv_daily 
				,sum(fc_promotion_daily) as fc_promotion_daily 
				,sum(fc_sem_daily) as fc_sem_daily 
				,sum(fc_dsp_daily) as fc_dsp_daily 
				,sum(fc_promotion_daily+fc_sem_daily+fc_dsp_daily) as fc_mkt_fee_daily

from (
select date,sku,country,(`real sales`/7) as fc_units_daily,(gmv/7) as fc_gmv_daily, (Promotion/7) as fc_promotion_daily, (sem/7) as fc_sem_daily ,(dsp/7) as fc_dsp_daily 
from 
(
select date,b.`First day of week`,sku,country,sum(`Real sales`) as `Real sales` , sum(gmv) as gmv, sum(sem) as sem ,sum(dsp) as dsp ,sum(promotion) as Promotion
from sc_main.dim_date a 
left join smkt_main.KPI_tracking_weekly b 
on b.`First day of week`= a.first_day_of_week
WHERE b.`First day of week` is not null and country='USA' and Channel in ('FBA','FBM','AVC','AVC DS','AVC DI','AVC WH') and `source.name` like '%sport%'
group by 1,2,3,4
) a 
group by 1,2,3) c 
join sc_main.dim_product d 
on c.sku=d.sku 
group by 1,2,3

) g
left join 
(
select log_date 
,country
,c.subcategory
,pic_sale
,sale_team
,sum(final_units) as units
,sum(final_gmv) as gmv 
,sum(vm_promo_spend+vc_promo_spend+coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) as mkt_fee
from full_metrics b  
join sc_main.dim_product c 
on b.sku=c.sku 
where group_KPI= "US_SG_AMZ" and year(log_date)>=2023
group by 1,2,3,4,5
) f
on g.date=f.log_date and g.country=f.country and g.Subcategory=f.Subcategory
group by 1,2,3
UNION all 
#walmart
select g.date 
			,g.subcategory
			,g.country 
			,sum(g.fc_units_daily) as fc_units_daily
			,SUM(g.fc_gmv_daily) AS fc_gmv_daily
			,SUM(g.fc_mkt_fee_daily) AS fc_mkt_fee_daily
			,f.pic_sale
			,f.sale_team
			,SUM(f.units) AS units 
			,sum(f.gmv) as gmv 
			,sum(f.mkt_fee) mkt_fee 
			,case when date <> 0 then "Walmart"
			else "" end as group_KPI

from  
(
select c.date 
				,d.Subcategory 
				,c.country 
				,sum(fc_units_daily) as fc_units_daily 
				,sum(fc_gmv_daily) as fc_gmv_daily 
				,sum(fc_promotion_daily) as fc_promotion_daily 
				,sum(fc_sem_daily) as fc_sem_daily 
				,sum(fc_dsp_daily) as fc_dsp_daily 
				,sum(fc_promotion_daily+fc_sem_daily+fc_dsp_daily) as fc_mkt_fee_daily

from (
select date,sku,country,(`real sales`/7) as fc_units_daily,(gmv/7) as fc_gmv_daily, (Promotion/7) as fc_promotion_daily, (sem/7) as fc_sem_daily ,(dsp/7) as fc_dsp_daily 
from 
(
select date,b.`First day of week`,sku,country,sum(`Real sales`) as `Real sales` , sum(gmv) as gmv, sum(sem) as sem ,sum(dsp) as dsp ,sum(promotion) as Promotion
from sc_main.dim_date a 
left join smkt_main.KPI_tracking_weekly b 
on b.`First day of week`= a.first_day_of_week
WHERE b.`First day of week` is not null and country='USA' and Channel in ('WM WFS', 'WM DSV')
group by 1,2,3,4
) a 
group by 1,2,3) c 
join sc_main.dim_product d 
on c.sku=d.sku 
group by 1,2,3

) g
left join 
(
select log_date 
,country
,c.subcategory
,pic_sale
,sale_team
,sum(ordered_units) as units
,sum(ordered_gmv) as gmv 
,sum(vm_promo_spend+vc_promo_spend+coupon_spend + sbv_spend + sp_spend + sd_spend + sb_spend + dsp_halo_spend + dsp_promoted_spend) as mkt_fee
from full_metrics b  
join sc_main.dim_product c 
on b.sku=c.sku 
where group_KPI= "Walmart" and year(log_date)>=2023
group by 1,2,3,4,5
) f
on g.date=f.log_date and g.country=f.country and g.Subcategory=f.Subcategory
group by 1,2,3
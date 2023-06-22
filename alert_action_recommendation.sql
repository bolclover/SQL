select * from 
(
SELECT 
			fi.sku
			,inventory
			,Platform
			,team
			,launching_date
			,first_ordered_date
			,first_shipped_date
			,New_existing_product
		  ,final_unit_last_week
		  ,weekleft_baseon_saleslastweek
			,discount_spend_last_week
			,ppc_spend_last_week
			,final_gmv_last_week
		  ,mkt_fee_total_last_week
			,final_mkt_gmv_total_last_week
			,fc_promo_last_week
			,fc_ppc_last_week
			,fc_gmv_last_week
			,fc_mkt_gmv_total_last_week
			,fc_unit_last_week
			,final_unit_1stmonth_LW
			,discount_spend_1stmonth_LW
			,ppc_spend_1stmonth_LW
			,mkt_fee_total_1stmonth_LW
			,final_gmv_1stmonth_LW
			,final_mkt_gmv_total_1stmonth_LW
			,final_unit_last_2week
			,discount_spend_last_2week
			,ppc_spend_last_2week
			, mkt_fee_total_last_2week
			,final_gmv_last_2week
      ,final_mkt_gmv_total_last_2week
			,fc_unit_1stmonth_LW
			,fc_promo_1stmonth_LW
			,fc_ppc_1stmonth_LW
			,fc_gmv_1stmonth_LW
			,fc_mkt_gmv_total_1stmonth_LW
			,ppc_gmv_last_week
			,ppc_gmv_last_2week
			,ppc_gmv_1stmonth_LW
			,case when Platform = 'AMZ' and team='YDL' then 'exclude_team'
			else 'ok_team'
			end as check_team
from 
(

select a1.sku
			, launching_date
			, first_ordered_date
			, first_shipped_date
			, New_existing_product
			,a2.inventory
		  ,a3.Platform
		  ,final_unit_last_week
		  ,weekleft_baseon_saleslastweek
			,discount_spend_last_week
			,ppc_spend_last_week
			,final_gmv_last_week
		  ,mkt_fee_total_last_week
			,final_mkt_gmv_total_last_week
			,fc_promo_last_week
			,fc_ppc_last_week
			,fc_gmv_last_week
			,fc_mkt_gmv_total_last_week
			,fc_unit_last_week
			,final_unit_1stmonth_LW
			,discount_spend_1stmonth_LW
			,ppc_spend_1stmonth_LW
			,mkt_fee_total_1stmonth_LW
			,final_gmv_1stmonth_LW
			,final_mkt_gmv_total_1stmonth_LW
			,final_unit_last_2week
			,discount_spend_last_2week
			,ppc_spend_last_2week
			, mkt_fee_total_last_2week
			,final_gmv_last_2week
      ,final_mkt_gmv_total_last_2week
			,fc_unit_1stmonth_LW
			,fc_promo_1stmonth_LW
			,fc_ppc_1stmonth_LW
			,fc_gmv_1stmonth_LW
			,fc_mkt_gmv_total_1stmonth_LW
			,ppc_gmv_last_week
			,ppc_gmv_last_2week
			,ppc_gmv_1stmonth_LW
			
from  
(select a.sku, min(launching_date) as launching_date, min(first_ordered_date) as first_ordered_date, min(first_shipped_date) as first_shipped_date,
case when year(first_ordered_date) >=2023 then "New Product 2023"
     when first_ordered_date BETWEEN "2022-01-01" and "2022-12-31" then "New Product 2022"
		 else "Existing Product"
		 end as New_existing_product
from sc_main.dim_product a 
left join sc_main.deployment_process_tracking b 
on a.sku=b.sku 
WHERE a.Company= "Y4A"  and a.root_category = "Sporting Goods" and b.country="USA"
group by sku) a1 
left join
(
 select sku, inventory 
 from 
 (
 SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
 from sc_main.full_inventory 
 GROUP BY log_date, sku ) a
 WHERE current_log_date = 1
) a2 on a1.sku = a2.sku 

left join 
(
select e.sku,platform, final_unit_last_week,discount_spend_last_week,ppc_spend_last_week,ppc_gmv_last_week, mkt_fee_total_last_week,final_gmv_last_week,final_mkt_gmv_total_last_week, inventory, (inventory/final_unit_last_week) as weekleft_baseon_saleslastweek
from 
(
SELECT sku,h.platform,sum(ordered_units) as final_unit_last_week 
,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week
,sum(sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as ppc_spend_last_week
, sum(ordered_gmv) as final_gmv_last_week
,sum(sb_ordered_gmv+sd_ordered_gmv+sp_ordered_gmv+sbv_ordered_gmv+ dsp_halo_ordered_gmv+dsp_promoted_ordered_gmv) as ppc_gmv_last_week
, sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as mkt_fee_total_last_week
,(sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend)/sum(ordered_gmv)) as final_mkt_gmv_total_last_week
from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from sc_main.dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAL-7 day)
) b
on a.first_day_of_week=b.first_day_of_week
) c
join smkt_main.dim_channel h on d.channel =h.channel
WHERE d.log_date= c.date and label_currency = "USD" and country = "USA"
GROUP BY sku, platform
) e
 join 
(SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1 ) f
on e.sku=f.sku
 ) a3 on a1.sku=a3.sku

left join 
(
select sku,platform,fc_unit_last_week,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_total_last_week
from 
(
select a.`First day of week` as first_day_of_week ,a.sku,platform, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAL-7 day) ) b
on a.`First day of week`= b.first_day_of_week
join smkt_main.dim_channel p on  a.channel=p.channel 
GROUP BY a.`First day of week`,a.sku
) g 
) a4 on a1.sku = a4.sku and a4.Platform=a3.Platform

 left join 
 
(
select e.sku,platform, final_unit_1stmonth_LW,discount_spend_1stmonth_LW,ppc_spend_1stmonth_LW,ppc_gmv_1stmonth_LW, mkt_fee_total_1stmonth_LW,final_gmv_1stmonth_LW,final_mkt_gmv_total_1stmonth_LW
from 
(
SELECT sku,h.platform,sum(ordered_units) as final_unit_1stmonth_LW 
,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_1stmonth_LW
,sum(sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as ppc_spend_1stmonth_LW
,sum(sb_ordered_gmv+sd_ordered_gmv+sp_ordered_gmv+sbv_ordered_gmv+ dsp_halo_ordered_gmv+dsp_promoted_ordered_gmv) as ppc_gmv_1stmonth_LW
, sum(ordered_gmv) as final_gmv_1stmonth_LW
, sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as mkt_fee_total_1stmonth_LW
,(sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend)/sum(ordered_gmv)) as final_mkt_gmv_total_1stmonth_LW
from public_main.full_metrics_daily d 
join 
(

SELECT a.date, a.first_day_of_month from sc_main.dim_date a 
join 
(
select date, first_day_of_week,first_day_of_month from sc_main.dim_date
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAL-7 day)
) b
on a.first_day_of_month=b.first_day_of_month
 )c
join smkt_main.dim_channel h on d.channel =h.channel
WHERE d.log_date= c.date and label_currency = "USD" and country = "USA"
GROUP BY sku, platform
) e
 ) a6 on a1.sku=a6.sku and a6.platform = a3.Platform
 
 left join 
 (
select e.sku,platform, final_unit_last_2week,discount_spend_last_2week,ppc_spend_last_2week,ppc_gmv_last_2week, mkt_fee_total_last_2week,final_gmv_last_2week,final_mkt_gmv_total_last_2week
from 
(
SELECT sku,h.platform,sum(ordered_units) as final_unit_last_2week 
,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_2week
,sum(sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as ppc_spend_last_2week
, sum(ordered_gmv) as final_gmv_last_2week
,sum(sb_ordered_gmv+sd_ordered_gmv+sp_ordered_gmv+sbv_ordered_gmv+ dsp_halo_ordered_gmv+dsp_promoted_ordered_gmv) as ppc_gmv_last_2week
, sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as mkt_fee_total_last_2week
,(sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend)/sum(ordered_gmv)) as final_mkt_gmv_total_last_2week
from public_main.full_metrics_daily d 
join 
(
select date, a.first_day_of_week from sc_main.dim_date a 
left join 
( 
select date as day_lw, first_day_of_week from sc_main.dim_date
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAL-14 day)
) b 
on a.first_day_of_week = b.first_day_of_week 

WHERE a.first_day_of_week = b.first_day_of_week 

union all 

select date, a.first_day_of_week from sc_main.dim_date a 
left join 
( 
select date as day_lw, first_day_of_week from sc_main.dim_date
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAL-7 day)
) b 
on a.first_day_of_week = b.first_day_of_week 

WHERE a.first_day_of_week = b.first_day_of_week 
) c
join smkt_main.dim_channel h on d.channel =h.channel
WHERE d.log_date= c.date and label_currency = "USD" and country = "USA"
GROUP BY sku, platform
) e
 ) a8 on a1.sku=a8.sku and a8.platform = a3.Platform
 
 
 left join 
(
select sku,platform,fc_unit_1stmonth_LW,fc_promo_1stmonth_LW,fc_ppc_1stmonth_LW,fc_gmv_1stmonth_LW,((fc_promo_1stmonth_LW+fc_ppc_1stmonth_LW)/fc_gmv_1stmonth_LW) as fc_mkt_gmv_total_1stmonth_LW
from 
(
select a.`First day of week` as first_day_of_week ,a.sku,platform, sum(Promotion) as fc_promo_1stmonth_LW,sum(sem) as fc_ppc_1stmonth_LW,sum(gmv) as fc_gmv_1stmonth_LW, sum(`Real sales`) as fc_unit_1stmonth_LW from smkt_main.test_KPI_week a
join 
(
select distinct a.`First day of week` from smkt_main.test_KPI_week a
WHERE a.`First day of week` <=DATE_ADD(CURRENT_DATE, INTERVAL-7 day) and month (a.`First day of week`) = month(DATE_ADD(CURRENT_DATE, INTERVAL-7 day)) and year(a.`First day of week`) = year(DATE_ADD(CURRENT_DATE, INTERVAL-7 day)) ) b
on a.`First day of week`= b.`First day of week`
join smkt_main.dim_channel p on  a.channel=p.channel 
GROUP BY a.sku
) g 
) a7 on a1.sku = a7.sku and a7.Platform=a3.Platform
) fi
left join sc_main.dim_product pro 
on fi.sku=pro.sku
) a10 
WHERE check_team = 'ok_team'
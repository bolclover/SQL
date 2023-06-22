select sku
			, launching_date
			, first_ordered_date
			, first_shipped_date
			, New_existing_product
			, inventory
			, platform
			, final_unit_last_week
		  , weekleft_baseon_saleslastweek
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
			,(final_unit_last_week - fc_unit_last_week)/fc_unit_last_week as actual_unit_LW_vs_fc
			,((final_mkt_gmv_total_last_week-fc_mkt_gmv_total_last_week)/fc_mkt_gmv_total_last_week ) as actual_mkt_gmv_total_LW_vs_FC
			,group_weekleft
			,group_airng_date
			,case when (final_unit_last_week - fc_unit_last_week)/fc_unit_last_week > 0 then "Vượt target realsales" 
		  else "Under target realsales" 
		  end as group_actual_unit_LW_vs_FC
			, case when mkt_fee_total_last_week = 0 then "No spend"
     when (final_mkt_gmv_total_last_week-fc_mkt_gmv_total_last_week)/fc_mkt_gmv_total_last_week >0     then "Vượt budget mkt/gmv"
		 else "Under budget mkt/gmv" 
		 end as group_actual_mkt_gmv_total_LW_vs_FC			
	
from 
(
select a1.sku
			, launching_date
			, first_ordered_date
			, first_shipped_date
			, New_existing_product
			,a2.inventory
			, case 
     when first_ordered_date is null and launching_date is null then "Chưa launching"
     when launching_date is not null and first_ordered_date is null and a2.inventory >0 
		 then  "Sales urgently check launching performance"
     else "Ok"
		 end as group_airng_date
		 ,a3.Platform
		 ,final_unit_last_week
		 ,weekleft_baseon_saleslastweek
		 , case when weekleft_baseon_saleslastweek >= 12 then "stock cover >=12M"
      else "stock cover <12M"
      end as group_weekleft
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
from  
(select a.sku, launching_date, first_ordered_date, first_shipped_date,
case when year(first_ordered_date) >=2023 then "New Product 2023"
     when first_ordered_date BETWEEN "2022-01-01" and "2022-12-31" then "New Product 2022"
		 else "Existing Product"
		 end as New_existing_product
from sc_main.dim_product a 
left join sc_main.deployment_process_tracking b 
on a.sku=b.sku 
WHERE a.Company= "Y4A" and a.team= "YSL" and a.root_category = "Sporting Goods" and b.country="USA") a1 
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
select e.sku,platform, final_unit_last_week,discount_spend_last_week,ppc_spend_last_week, mkt_fee_total_last_week,final_gmv_last_week,final_mkt_gmv_total_last_week, inventory, (inventory/final_unit_last_week) as weekleft_baseon_saleslastweek
from 
(
SELECT sku,h.platform,sum(ordered_units) as final_unit_last_week 
,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week
,sum(sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as ppc_spend_last_week
, sum(ordered_gmv) as final_gmv_last_week
, sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend) as mkt_fee_total_last_week
,(sum(vc_promo_spend+coupon_spend+ vm_promo_spend + sb_spend+sd_spend+sp_spend+sbv_spend+ dsp_halo_spend+dsp_promoted_spend)/sum(ordered_gmv)) as final_mkt_gmv_total_last_week
from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from sc_main.dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7
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
select first_day_of_week, sku,platform,fc_unit_last_week,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_total_last_week
from 
(
select a.`Month` as first_day_of_week ,a.sku,platform, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_month a
join 
(
select date, first_day_of_month from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
join smkt_main.dim_channel p on  a.channel=p.channel 
GROUP BY a.`First day of week`,a.sku
) g 
) a4 on a1.sku = a4.sku and a4.Platform=a3.Platform





 ) 
 
 
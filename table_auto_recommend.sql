create table test_inventory_UTD as 
SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1


/*remove DUPLICATE value- group_airing_date*/
select d.sku, d.launching_date, d.first_ordered_date, d.inventory,
case 
     when first_ordered_date is null and launching_date is null then "Chưa có airing"
     when launching_date is not null and first_ordered_date is null and inventory >0 then "Sales urgently check airing performance"
     else "Ok"
		 end as group_airng_date
from 
(
SELECT a.sku, 
			 b.Launching_date,
			 b.first_ordered_date,
			 c.inventory
from sc_main.dim_product a 
left JOIN sc_main.deployment_process_tracking b on a.sku=b.sku  
 left JOIN (
SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1
) c on a.sku=c.sku 
) d 

/*final_gmv_last_week group by day*/
SELECT log_date,sku,sum(ordered_gmv) as final_gmv from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7
) b
on a.first_day_of_week=b.first_day_of_week
) c
WHERE d.log_date= c.date
GROUP BY log_date,sku

/*final_gmv_last_week group by sku*/
SELECT sku,sum(ordered_gmv) as final_gmv from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7
) b
on a.first_day_of_week=b.first_day_of_week
) c
WHERE d.log_date= c.date
GROUP BY sku



/*group_weekleft*/
select sku, final_gmv, inventory,weekleft_baseon_saleslastweek,
case when weekleft_baseon_saleslastweek >= 12 then "stock cover >=12M"
else "stock cover <12M"
end as group_weekleft
 from 
(
select e.sku, final_gmv, inventory, (inventory/final_gmv) as weekleft_baseon_saleslastweek
from 
(
SELECT sku,sum(ordered_gmv) as final_gmv from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) e
 join 
(SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1 ) f
on e.sku=f.sku
 ) t 

/*discount_spend_last_week*/
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7
) b
on a.first_day_of_week=b.first_day_of_week
) c
WHERE d.log_date= c.date
GROUP BY sku

/*ppc_spend_last_week*/
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
join 
(
select a.date,a.first_day_of_week from dim_date a
join
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7
) b
on a.first_day_of_week=b.first_day_of_week
) c
WHERE d.log_date= c.date
GROUP BY sku


/*gmv_last_week*/
SELECT sku,sum(ordered_gmv) as final_gmv_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku



/*mkt_fee_woDSP_last_week*/
SELECT a.sku, discount_spend_last_week, ppc_spend_last_week, (discount_spend_last_week+ ppc_spend_last_week) as mkt_fee_woDSP_last_week
from 
(
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) a 
join 
(
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku ) b
on a.sku=b.sku 

/*fc_mkt_gmv_woDSP_last_week*/
select first_day_of_week, sku,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_woDSP_last_week
from 
(
select a.`First day of week` as first_day_of_week ,a.sku, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
GROUP BY a.`First day of week`,a.sku
) c 


/*final_mkt/gmv_woDSP_last_week*/

select x.sku,discount_spend_last_week,ppc_spend_last_week,final_gmv_last_week, ((discount_spend_last_week+ ppc_spend_last_week)/final_gmv_last_week) as final_mkt_gmv_woDSP_last_week
from 
(
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) x
join 
(
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) y on x.sku=y.sku 
join 
(

SELECT sku,sum(ordered_gmv) as final_gmv_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) z 
on x.sku= z.sku 


/*actual_mkt/gmv_LW_vs_fc*/
select t.sku,fc_mkt_gmv_woDSP_last_week, final_mkt_gmv_woDSP_last_week, ((final_mkt_gmv_woDSP_last_week-fc_mkt_gmv_woDSP_last_week)/fc_mkt_gmv_woDSP_last_week) as actual_mkt_gmv_LW_vs_fc
from 
(
select first_day_of_week, sku,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_woDSP_last_week
from 
(
select a.`First day of week` as first_day_of_week ,a.sku, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
GROUP BY a.`First day of week`,a.sku
) c 

) t
join (
select x.sku,discount_spend_last_week,ppc_spend_last_week,final_gmv_last_week, ((discount_spend_last_week+ ppc_spend_last_week)/final_gmv_last_week) as final_mkt_gmv_woDSP_last_week
from 
(
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) x
join 
(
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) y on x.sku=y.sku 
join 
(

SELECT sku,sum(ordered_gmv) as final_gmv_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) z 
on x.sku= z.sku ) k on t.sku=k.sku


/*grouo actual _mkt_gmv LW_FC*/
select k.sku,discount_spend_last_week, ppc_spend_last_week, mkt_fee_woDSP_last_week, fc_mkt_gmv_woDSP_last_week, final_mkt_gmv_woDSP_last_week, actual_mkt_gmv_LW_vs_fc,
case when mkt_fee_woDSP_last_week = 0 then "No spend"
     when actual_mkt_gmv_LW_vs_fc >0 then "Vượt budget mkt/gmv"
		 else "Under budget mkt/gmv" 
		 end as group_actual_mkt_gmv_woDSP_LW_vs_FC
from 
(
SELECT a.sku, discount_spend_last_week, ppc_spend_last_week, (discount_spend_last_week+ ppc_spend_last_week) as mkt_fee_woDSP_last_week
from 
(
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) a 
join 
(
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku ) b
on a.sku=b.sku 
) k 
left join 
(
select t.sku,fc_mkt_gmv_woDSP_last_week, final_mkt_gmv_woDSP_last_week, ((final_mkt_gmv_woDSP_last_week-fc_mkt_gmv_woDSP_last_week)/fc_mkt_gmv_woDSP_last_week) as actual_mkt_gmv_LW_vs_fc
from 
(
select first_day_of_week, sku,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_woDSP_last_week
from 
(
select a.`First day of week` as first_day_of_week ,a.sku, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
GROUP BY a.`First day of week`,a.sku
) c 

) t
join (
select x.sku,discount_spend_last_week,ppc_spend_last_week,final_gmv_last_week, ((discount_spend_last_week+ ppc_spend_last_week)/final_gmv_last_week) as final_mkt_gmv_woDSP_last_week
from 
(
SELECT sku,sum(vc_promo_spend+coupon_spend+ vm_promo_spend) as discount_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) x
join 
(
SELECT sku,sum(sb_spend+sd_spend+sp_spend+sbv_spend) as ppc_spend_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) y on x.sku=y.sku 
join 
(

SELECT sku,sum(ordered_gmv) as final_gmv_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) z 
on x.sku= z.sku ) k on t.sku=k.sku
) e 
on k.sku=e.sku

/*final_unit_last_week*/
SELECT sku,sum(ordered_units) as final_unit_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku

/* fc_unit_last_week*/
select  a.sku, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
GROUP BY a.sku


/*group_actual_unit_LW_FC*/
select  sku, final_unit_last_week, fc_unit_last_week, actual_unit_LW_vs_fc,
     case when actual_unit_LW_vs_fc > 0 then "Vượt target realsales" 
		 else "Under target realsales" 
		 end as group_actual_unit_LW_vs_FC 
from 
(
select d.sku, final_unit_last_week, fc_unit_last_week,  ((final_unit_last_week - fc_unit_last_week)/fc_unit_last_week) as actual_unit_LW_vs_fc
from 
( SELECT sku,sum(ordered_units) as final_unit_last_week from public_main.full_metrics_daily d 
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
WHERE d.log_date= c.date
GROUP BY sku
) d 
 join 
( select  a.sku, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
GROUP BY a.sku ) e 
on d.sku=e.sku ) f


#new version # 


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
			,fc_mkt_gmv_woDSP_last_week
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
select first_day_of_week, sku,platform,fc_unit_last_week,fc_promo_last_week,fc_ppc_last_week,fc_gmv_last_week,((fc_promo_last_week+fc_ppc_last_week)/fc_gmv_last_week) as fc_mkt_gmv_woDSP_last_week
from 
(
select a.`First day of week` as first_day_of_week ,a.sku,platform, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
join smkt_main.dim_channel p on  a.channel=p.channel 
GROUP BY a.`First day of week`,a.sku
) g 
) a4 on a1.sku = a4.sku and a4.Platform=a3.Platform



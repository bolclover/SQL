action_recommendation = 
if([group_airing_date]<>"",[group_airing_date],if(and([group_weekleft]="stock cover >=12M",[group_actual_mkt/gmv(woDSP)_LW_vs_FC]="Under budget mkt/gmv"),"Push sales",if(and([group_weekleft]="stock cover >=12M",[group_actual_mkt/gmv(woDSP)_LW_vs_FC]="Vượt budget mkt/gmv"),"SEM giải thích, sales review",if(and(and([group_weekleft]="stock cover >=12M",[group_actual_unit_LW_vs_FC]="Vượt target realsales"),[mkt_fee_woDSP_last_week]=0),"Sales review FC",if(and(and([group_weekleft]="stock cover >=12M",[group_actual_unit_LW_vs_FC]="Under target realsales"),[mkt_fee_woDSP_last_week]=0),"Push SEM",if(and([group_weekleft]="stock cover <12M",[group_actual_mkt/gmv(woDSP)_LW_vs_FC]="Vượt budget mkt/gmv"),"Tắt SEM, urgently request order",if(and(and([group_weekleft]="stock cover <12M",[group_actual_mkt/gmv(woDSP)_LW_vs_FC]= "Under budget mkt/gmv"),[group_actual_unit_LW_vs_FC]="Vượt target realsales"),"Sales urgently request order",if(and(and([group_weekleft]="stock cover <12M",[mkt_fee_woDSP_last_week]=0),[group_actual_unit_LW_vs_FC]="Vượt target realsales"),"Chuyển DS để lời hơn","Giảm SEM, urgently request order"))))))))


group_airing_date x
group_weekleft x
group_actual_mkt/gmv(woDSP)_LW_vs_FC  x
group_actual_unit_LW_vs_FC

 



group_airing_date = if(and(min('sc_main dim_product'[first_ordered_date])=0,min('sc_main dim_product'[airing_date])=0),"Chưa có airing",if(and(and(min('sc_main dim_product'[first_ordered_date])=0,[inventory_UTD] >0),min('sc_main dim_product'[airing_date])<>0),"Sales urgently check airing performance",""))

inventory_UTD = CALCULATE(sum('sc_main full_inventory'[inventory]),max('sc_main full_inventory'[log_date])=('sc_main full_inventory'[log_date]))

group_weekleft = if([weekleft_baseon_saleslastweek (<12w)]<12,"stock cover <12M","stock cover >=12M")

weekleft_baseon_saleslastweek (<12w) = iferror('sc_main full_inventory'[inventory_UTD]/[final_unit_last_week],"")


SELECT CURRENT_DATE(log_date),sku, sum(inventory) from sc_main.full_inventory

GROUP BY log_date,sku
create table test_inventory_UTD as 
SELECT * from (
SELECT sku, log_date, inventory,
 RANK() OVER(ORDER BY log_date desc) AS current_log_date
from sc_main.full_inventory 
GROUP BY log_date, sku ) a
WHERE current_log_date = 1

SELECT sku, max(log_date), inventory from sc_main.full_inventory
GROUP BY sku, inventory



group_airing_date = 

if(and(min('sc_main dim_product'[first_ordered_date])=0
,min('sc_main dim_product'[airing_date])=0),"Chưa có airing",
if(
and(
and(
min('sc_main dim_product'[first_ordered_date])=0,[inventory_UTD] >0),
min('sc_main dim_product'[airing_date])<>0),"Sales urgently check airing performance",""))


select sku, launching_date, first_ordered_date,inventory,
case 
     when first_ordered_date = 0 and launching_date = 0 then "Chưa có airing"
		 when launching_date <> 0 and first_ordered_date = 0 and c.nventory >0 then "Sales urgently check airing performance"
		 else "Ok"
		 end
from 
(
select a.sku, Launching_date, first_ordered_date, inventory from sc_main.deployment_process_tracking a 
join smkt_main.test_inventory_UTD b
on a.sku= b.sku )


select sku, launching_date, first_ordered_date,inventory,
case 




















     when first_ordered_date = 0 and launching_date = 0 then "Chưa có airing"
		 when launching_date <> 0 and first_ordered_date = 0 and c.nventory >0 then "Sales urgently check airing performance"
		 else "Ok"
		 end
from 
(
select a.sku, Launching_date, first_ordered_date, inventory from sc_main.deployment_process_tracking a 
join smkt_main.test_inventory_UTD b
on a.sku= b.sku ) c

select sku, launching_date, first_ordered_date,inventory,
case 
     when first_ordered_date = 0 and launching_date = 0 then "Chưa có airing"
     when launching_date <> 0 and first_ordered_date = 0 and c.inventory >0 then "Sales urgently check airing performance"
     else "Ok"
		 end as status
from 
(
select a.sku, Launching_date, first_ordered_date, inventory from sc_main.deployment_process_tracking a 
left join smkt_main.test_inventory_UTD b
on a.sku= b.sku ) c


select d.sku,d.asin, d.launching_date, d.first_ordered_date, d.inventory,
case 
     when first_ordered_date is null and launching_date is null then "Chưa có airing"
     when launching_date is not null and first_ordered_date is null and inventory >0 then "Sales urgently check airing performance"
     else "Ok"
		 end as group_airng_date
from 
(
SELECT a.sku, a.asin, 
			 b.Launching_date,
			 b.first_ordered_date,
			 c.inventory
from sc_main.dim_product a 
LEFT JOIN sc_main.deployment_process_tracking b on a.sku=b.sku and a.asin=b.asin 
left JOIN sc_main.full_inventory c on a.sku=c.sku and a.asin=c.asin 
WHERE a.company='Y4A' 
and a.root_category = 'Sporting Goods'
) d


group_weekleft = if([weekleft_baseon_saleslastweek (<12w)]<12,"stock cover <12M","stock cover >=12M")
weekleft_baseon_saleslastweek (<12w) = iferror('sc_main full_inventory'[inventory_UTD]/[final_unit_last_week],"")

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




group_actual_mkt/gmv(woDSP)_LW_vs_FC = if([mkt_fee_woDSP_last_week]=0,"No spend",if([actual_mkt/gmv_LW_vs_fc]>0,"Vượt budget mkt/gmv","Under budget mkt/gmv"))

mkt_fee_woDSP_last_week = [discount_spend_last_week]+[ppc_spend_last_week]


   discount_spend_last_week = 
var __Thisdaylastweek = TODAY()-7
var __Firstdaylastweek = LOOKUPVALUE( 'sc_main dim_date'[First_day_of_week],'sc_main dim_date'[date], __Thisdaylastweek)
return CALCULATE([discount_spend_byDA],KEEPFILTERS(__Firstdaylastweek = 'sc_main dim_date'[first_day_of_week]))

discount_spend_byDA = sum('public_main full_metrics_daily'[vc_promo_spend])+sum('public_main full_metrics_daily'[coupon_spend])+sum('public_main full_metrics_daily'[vm_promo_spend])

ppc_spend_last_week = 
var __Thisdaylastweek = TODAY()-7
var __Firstdaylastweek = LOOKUPVALUE( 'sc_main dim_date'[First_day_of_week],'sc_main dim_date'[date], __Thisdaylastweek)
return CALCULATE([ppc_spend],KEEPFILTERS(__Firstdaylastweek = 'sc_main dim_date'[first_day_of_week]))

ppc_spend = sum('public_main full_metrics_daily'[sb_spend])+sum('public_main full_metrics_daily'[sd_spend])+sum('public_main full_metrics_daily'[sp_spend])+sum('public_main full_metrics_daily'[sbv_spend])

actual_mkt/gmv_LW_vs_fc = IFERROR(([final_mkt/gmv_woDSP_last_week]-[fc_mkt/gmv_woDSP_last_week])/[fc_mkt/gmv_woDSP_last_week],"")
final_mkt/gmv_woDSP_last_week = iferror(([discount_spend_last_week]+[ppc_spend_last_week])/[final_gmv_last_week],"")

fc_mkt/gmv_woDSP_last_week = iferror(([fc_promo_last_week]+[fc_ppc_last_week])/[fc_gmv_last_week],"")


fc_promo_last_week = 
var __Thisdaylastweek = TODAY()-7
var __Firstdaylastweek = LOOKUPVALUE( 'sc_main dim_date'[First_day_of_week],'sc_main dim_date'[date], __Thisdaylastweek)
return CALCULATE(sum('KPI tracking-weekly'[Promotion]),KEEPFILTERS(__Firstdaylastweek = 'sc_main dim_date'[first_day_of_week]))



SELECT a.sku, discount_spend_last_week, ppc_spend_last_week, (discount_spend_last_week+ ppc_spend_last_week) as mkt_fee_woDSP_last_week
from 
(
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
) a 
join 
(
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
GROUP BY sku ) b
on a.sku=b.sku 





SELECT sku,sum() as ppc_spend_last_week from test_KPI_week d 
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
-------

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



select DISTINCT channel from smkt_main.test_KPI_month


update test_KPI_month
set Channel = "AVC" 
WHERE channel = "AVC DS"










select a.`First day of week` as first_day_of_week ,a.sku,platform, sum(Promotion) as fc_promo_last_week,sum(sem) as fc_ppc_last_week,sum(gmv) as fc_gmv_last_week, sum(`Real sales`) as fc_unit_last_week from smkt_main.test_KPI_week a
join 
(
select date, first_day_of_week from sc_main.dim_date
WHERE date = CURRENT_DATE()-7 ) b
on a.`First day of week`= b.first_day_of_week
join smkt_main.dim_channel p on  a.channel=p.channel 
GROUP BY a.`First day of week`,a.sku











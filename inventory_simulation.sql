select 
`month` as first_day_of_month
,a.sku 
,a.country 
,`Source.Name`
,inventory 
,inventory_amazon
,inventory_walmart
,inventory_yes4all
,incoming
,incoming_amazon
,incoming_yes4all
,incoming_walmart 
,sum(`Real sales`) as fc_unit_sum_channel  

 from forecast_version a 
 left join 
(
#lay 3 month inv_inc 
WITH A AS(
select DISTINCT
 b.first_day_of_month
 ,a.sku as SKU
 ,a.country
 ,sum(a.inventory) as inventory
 ,sum(a.inventory_amazon) as inventory_amazon
 ,sum(a.inventory_walmart) as inventory_walmart
 ,sum(a.inventory_yes4all) as inventory_yes4all
 , 0 as incoming
 , 0 as incoming_amazon
 , 0 as incoming_yes4all
 , 0 as incoming_walmart

from (select distinct first_day_of_month from sc_main.dim_date) b

left join sc_main.full_inventory a on a.log_date = b.first_day_of_month

where b.first_day_of_month >= date_add(CURRENT_DATE, INTERVAL -28 day)
and a.sku is not null 
and a.sku <> "0"
and a.sku = a.asin
GROUP BY b.first_day_of_month,a.sku,a.country

UNION ALL

select DISTINCT 
c.first_day_of_month
,d.sku as SKU,
d.country
,0 as inventory
,0 as inventory_amazon
,0 as inventory_walmart
,0 as inventory_yes4all
, SUM(d.incoming) AS incoming
, sum(d.incoming_amazon) as incoming_amazon
, sum(d.incoming_yes4all) as incoming_yes4all
, sum(d.incoming_walmart) as incoming_walmart 
from (select distinct first_day_of_month from sc_main.dim_date) c 

LEFT JOIN sc_main.inventory_simulation_by_month d on c.first_day_of_month = d.first_day_of_month
where d.max_first_day_of_month <= d.first_day_of_month
and d.sku is not null 
and d.sku <> "0"
GROUP BY c.first_day_of_month, d.sku, d.country
)
, this_month as
(select first_day_of_month
from
(select DISTINCT first_day_of_month,date from sc_main.dim_date 
WHERE date = CURRENT_DATE()
union 
select DISTINCT first_day_of_month,date from sc_main.dim_date 
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAl 1 month) 
union 
select DISTINCT first_day_of_month,date from sc_main.dim_date 
WHERE date = DATE_ADD(CURRENT_DATE, INTERVAl 2 month) 
) a )

SELECT a. first_day_of_month
,SKU
,country 
,sum(inventory) as inventory
,sum(inventory_amazon) as inventory_amazon
,sum(inventory_walmart) as inventory_walmart
,sum(inventory_yes4all) as inventory_yes4all
,SUM(incoming) AS incoming
,sum(incoming_amazon) as incoming_amazon
,sum(incoming_yes4all) as incoming_yes4all
,sum(incoming_walmart) as incoming_walmart 
,'' as fc_unit_sumchannel  
FROM A a  
join this_month b  
on a.first_day_of_month =b.first_day_of_month  
GROUP BY 1,2,3
) b 

on a.`Month`= b.first_day_of_month and a.sku=b.sku and a.country =b.Country 
WHERE first_day_of_month is not null
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
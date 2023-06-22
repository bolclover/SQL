select d.year_month_
,d.subcategory
, brand 
,share_tool_fix 
, total_tool 
,revised_mks
from 

(
SELECT a.year_month_, a.subcategory, brand,(total_brand/total_tool) as share_tool_fix ,total_tool
from 
(select year_month_, subcategory
, sum(sales_this_month) as total_tool
from competitor_performance_monthly
GROUP BY 1,2) a 
left join 
(select year_month_,brand, subcategory
, sum(sales_this_month) as total_brand
from competitor_performance_monthly
GROUP BY 1,2,3
) b  
on a.year_month_=b.year_month_ and a.subcategory=b.subcategory ) d 
 left join 

(
select year_month_
,subcategory
, case when units = 0 and share_tool = 0 then sales_this_month
        when units > 0 and share_tool = 0 then (sales_this_month + units) 
				When units = 0 and share_tool > 0  and gap_tool < 0 then 0
				When units = 0 and share_tool > 0  and gap_tool > 0 then gap_tool
        else (units/share_tool)
end as revised_mks 

from 

(
select a.year_month_,a.subcategory, sales_this_month,sales_this_month_brand,(sales_this_month - sales_this_month_brand) as gap_tool,(sales_this_month_brand/sales_this_month) as share_tool,units, (sales_this_month - (sales_this_month_brand - units)) as revised_Msize
from  
(
select year_month_,subcategory, sum(sales_this_month) as sales_this_month from public_main.competitor_performance_monthly a
GROUP BY 1,2
) a 
left join 
(
select year_month_,subcategory, sum(sales_this_month) as sales_this_month_brand from public_main.competitor_performance_monthly b
WHERE brand ='Yes4All'
GROUP BY 1,2
) b 
on a.year_month_=b.year_month_ and a.subcategory =b.subcategory
 left JOIN 
(
select LEFT(log_date,7) as yearmonth,subcategory, sum(ordered_units) as units from full_metrics_daily a 
join sc_main.dim_product b 
on a.sku=b.sku 
WHERE label_currency = 'USD' and country = 'USA' and company='Y4A' and team ='YSL' and root_category = 'Sporting Goods' and a.channel in ('AVC','FBA','FBM')
group by yearmonth,subcategory ) c
on a.year_month_=c.yearmonth and a.subcategory=c.subcategory)
 x ) e 
 ON d.year_month_= e.year_month_ and d.subcategory =e.subcategory
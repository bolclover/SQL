
select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
            , min(log_date) AS first_ordered_date
            , null as first_shipped_date 
            from full_metrics_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd' and country = 'USA' 
group by sku

UNION ALL

select sku
            , null AS first_ordered_date
            , min(log_date) as first_shipped_date 
            from full_metrics_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd' and country = 'USA'
group by sku
)
select sku, min(first_ordered_date) as first_ordered_date, min(first_shipped_date) as first_shipped_date
,DATEDIFF(min(first_shipped_date),min(first_ordered_date)) as datediff 
from first_order_ship_date
group by sku
ORDER BY datediff desc
) a 
join sc_main.dim_product b 
on a.sku= b.sku
where company= 'Y4A' and channel!= 'local' and team = 'YSL' and sell_type <> 'Combo'
and root_category = 'Sporting Goods'and year(a.first_ordered_date)>=2022





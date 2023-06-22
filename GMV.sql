select log_date,ordered_gmv from full_metrics_daily a 
join sc_main.dim_product b on a.sku= b.sku
where b.company='Y4A' 
and a.channel<> 'local' 
and a.label_currency = 'usd' 
and a.log_date >='2022-01-01'
and b.root_category = 'Sporting Goods'
and b.subcategory is not null 
and a.country = 'USA'
and b.team = 'YSL'
AND a.channel in ('AVC','FBA','FBM')
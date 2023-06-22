select DISTINCT channel, count(sku) as countsku from sale_performance_by_channel
GROUP BY channel

SELECT DISTINCT week from wbr_full_inventory
order by week desc




SELECT
	sku,
	sum( ordered_units ) AS orderunits,
	sum( sb_spend ) AS spendbybrand,
	sum( sb_clicks ) AS clickbybrand,
	sum( sb_orders ) AS orderbybrand 
FROM
	full_metrics_daily
GROUP BY sku

select sku,sum(glance_view)
from full_metrics_daily
where log_date BETWEEN '2022-01-01' and '2022-12-30'
GROUP BY sku
select status, COUNT(asin) as countofasin from ads_ineligible_tracking
group by status




select ads_ineligible_tracking.date_db, ads_ineligible_tracking.account_idads_ineligible_trackingads_ineligible_tracking

select DISTINCT(date_db), count(asin) from ads_ineligible_tracking
group by date_db
order by date_db desc
ads_ineligible_tracking
full_metrics_daily
market_tracking
sale_performance_by_channel
wbr_full_inventory
wbr_full_inventory_last_day
wbr_full_metric_daily
wbr_full_okr
select COUNTRY, count(asin), count(DISTINCT(ASIN)) FROM full_metrics_daily
WHERE log_date = '2023-03-01'
GROUP BY COUNTRY 

SELECT DISTINCT country FROM full_metrics_daily
WHERE YEAR(log_date)='2023' AND MONTH(LOG_DATE)='2'

SELECT * FROM full_metrics_daily 
WHERE country='are' and log_date='2023-02-27' and sku='szze'

SELECT * FROM full_metrics_daily 
WHERE country='are' and log_date='2023-03-01' and sku='szze'

select log_date, count(asin) from full_metrics_daily
group by log_date 
order by log_date desc

SELECT country,COUNT(asin) ,count(DISTINCT(asin)),sum(ordered_units), sum(shipped_units) FROM full_metrics_daily 
WHERE (log_date)='2023-02-26' 
group by country


select country, COUNT(sku)  FROM full_metrics_daily 
WHERE  label_currency = 'usd' and log_date = '2022-10-27'
group by country 

SELECT * FROM full_metrics_daily 
WHERE country='can' and log_date ='2023-02-26' 

select brand, country,sum(sales) from market_tracking
group by brand, country
SELECT DISTINCT country from market_tracking
SELECT count(DISTINCT(brand)) from market_tracking

select country, count(sku) from sale_performance_by_channel
where label_currency = 'usd' and log_date = '2022-10-27'
group by country

select a.country, COUNT(DISTINCT(a.sku)), COUNT(DISTINCT(b.sku))
from sale_performance_by_channel a 
join full_metrics_daily b 
on a.country= b.country AND a.log_date=b.log_date and a.label_currency=b.label_currency
WHERE year(a.log_date)='2022' and a.label_currency = 'usd'
GROUP BY a.country


SELECT
	a.country,
	sum(a.ordered_units)
FROM
	sale_performance_by_channel a
	 
WHERE
	a.log_date BETWEEN '2023-03-01' AND '2023-03-03' 
	AND a.label_currency = 'usd' 
GROUP BY
	a.country
	

	
	SELECT
	b.country,
	
	sum(b.ordered_units) 
FROM
	
	full_metrics_daily b 
	
WHERE
	b.log_date BETWEEN '2022-03-01' AND '2022-03-31' 
	AND b.label_currency = 'usd' 
GROUP BY
	b.country
	
	select country, sum(inventory) from wbr_full_inventory
	where date BETWEEN '2022-02-01' and '2022-02-01'
	


select date, sum(inventory) from wbr_full_inventory
	where date ='2023-02-26'
	group by date
	
	
	select DISTINCT date, SUM(inventory) from wbr_full_inventory_last_day
	order by date desc
	
	
	
	
SELECT
	country_code, sum(ordered_units) 
FROM
	wbr_full_metric_daily
	
WHERE
	date_db BETWEEN '2022-03-01' AND '2022-03-31' 
	AND label_currency = 'usd' 
GROUP BY
	country_code
	
	
SELECT
	a.country_code,
	orderwbr_full_metrics_daily ,
	orderwbr_okr 
FROM
	( 
	SELECT
    country_code, sum(ordered_units) as orderwbr_full_metrics_daily
FROM
    wbr_full_metric_daily
    
WHERE
    date_db BETWEEN '2022-03-01' AND '2022-03-31' 
    AND label_currency = 'usd' 
		and channel !='local'
GROUP BY
    country_code 
	 ) a
	LEFT JOIN 
	( SELECT country, sum( actual_ordered_units ) AS orderwbr_okr 
	FROM wbr_full_okr 
	WHERE date_db BETWEEN '2022-03-01' AND '2022-03-31'
	GROUP BY country ) b 
	ON a.country_code = b.country


SELECT
    country_code, sum(ordered_units) 
FROM
    public_main.wbr_full_metric_daily a
LEFT JOIN sc_main.dim_product using (sku)
    
WHERE
    date_db BETWEEN '2022-03-01' AND '2022-03-31' 
    AND label_currency = 'USD' 
    AND company = 'Y4A'
    AND a.channel != 'Local'

GROUP BY
    country_code
		
select country, sum(ordered_units) from full_metrics_daily 
    
WHERE
    log_date BETWEEN '2022-03-01' AND '2022-03-31' 
    AND label_currency = 'USD' 
 
GROUP BY
    country


SELECT channel, COUNT(sku) from wbr_full_okr
WHERE date_db BETWEEN '2022-03-01' AND '2022-03-31'
group by channel

select channel,count(sku) from wbr_full_metric_daily
WHERE date_db BETWEEN '2022-03-01' AND '2022-03-31' 
group by channel



SELECT
    country_code, sum(ordered_units) 
FROM
    wbr_full_metric_daily
    
WHERE
    date_db BETWEEN '2022-03-01' AND '2022-03-31' 
    AND label_currency = 'usd' 
GROUP BY
    country_code


full_metrics_daily
sale_performance_by_channel
wbr_full_metric_daily
wbr_full_okr

/*wbr_full_metric_daily*/
select country_code, sum(sb_spend) from public_main.wbr_full_metric_daily a
join sc_main.dim_product 
using (sku) 
WHERE date_db BETWEEN '2022-04-01' and '2022-04-30'
and a.channel !='local' and company = 'Y4A'
and label_currency ='USD'
GROUP BY country_code
/*wbr_full_okr*/
select country, sum(actual_ordered_gmv) from wbr_full_okr a 
join sc_main.dim_product b 
on a.sku=b.sku 
WHERE date_db BETWEEN '2022-04-01' and '2022-04-30'
and a.channel !='local' and company = 'Y4A'
GROUP BY country

/*full_metrics_daily*/
select country, sum(sb_spend) from public_main.full_metrics_daily a 
join sc_main.dim_product b 
on a.sku=b.sku
WHERE a.log_date BETWEEN '2022-04-01' and '2022-04-30'
and a.channel !='local' and b.company = 'Y4A'
and a.label_currency ='USD'
GROUP BY country
/*sale_performance_by_channel*/
select country,sum(ordered_units) from public_main.sale_performance_by_channel a 
join sc_main.dim_product b 
on a.sku=b.sku 
WHERE a.log_date BETWEEN '2022-04-01' and '2022-04-30'
and a.channel !='local' and b.company = 'Y4A'
and a.label_currency ='USD'
GROUP BY country

/*full_metrics_daily*/
select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
			, min(log_date) AS first_ordered_date
			, null as first_shipped_date 
			from full_metrics_daily
where ordered_units <>0 and ordered_units is not null
group by sku

UNION ALL

select sku
			, null AS first_ordered_date
			, min(log_date) as first_shipped_date 
			from full_metrics_daily
where shipped_units <>0 and shipped_units is not null
group by sku
)
select sku, min(first_ordered_date) as first_ordered_date, min(first_shipped_date) as first_shipped_date
,DATEDIFF(min(first_shipped_date),min(first_ordered_date)) as datediff 
from first_order_ship_date
group by sku
ORDER BY datediff desc ) a
join sc_main.dim_product b 
on a.sku= b.sku
where company='Y4A' and channel!='local' 


/*wbr_full_metric_daily*/
select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
			, min(date_db) AS first_ordered_date
			, null as first_shipped_date 
			from wbr_full_metric_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd'
group by sku

UNION ALL

select sku
			, null AS first_ordered_date
			, min(date_db) as first_shipped_date 
			from wbr_full_metric_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd'
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
where company='Y4A' and channel!='local' 




select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
			, min(log_date) AS first_ordered_date
			, null as first_shipped_date 
			from full_metrics_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd'
group by sku

UNION ALL

select sku
			, null AS first_ordered_date
			, min(log_date) as first_shipped_date 
			from full_metrics_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd'
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
where company='Y4A' and channel!='local' and a.sku= 'A4PY'

select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
      , min(date_db) AS first_ordered_date
      , null as first_shipped_date 
      from wbr_full_metric_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd'
group by sku

UNION ALL

select sku
      , null AS first_ordered_date
      , min(date_db) as first_shipped_date 
      from wbr_full_metric_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd'
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
where company='Y4A' and channel!='local' and a.sku = 'A4PY'



select DISTINCT log_date from full_metrics_daily



select asin,sku, date_db, CONCAT(month(date_db),'/',year(date_db)), 
channel, country_code,sb_impressions,sb_clicks,sb_ordered_units,sb_orders,sb_spend,sd_impressions,sd_clicks,sd_ordered_units,sd_orders,sd_spendressions,sp_clicks,sp_ordered_units,sp_orders,sp_spend,sbv_impressions,sbv_clicks,sbv_ordered_units,sbv_orders,sbv_spend,
from wbr_full_metric_daily
WHERE label_currency = 'USD'and channel <> 'local'

select DISTINCT channel from wbr_full_metric_daily
where country_code ='Usa'


select country, sale_team from full_metrics_daily
where sale_team is not null
group by country,sale_team

select sku, sale_team from full_metrics_daily
where sale_team = 'commando proje'

select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
      , min(date_db) AS first_ordered_date
      , null as first_shipped_date 
      from wbr_full_metric_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd'
group by sku

UNION ALL

select sku
      , null AS first_ordered_date
      , min(date_db) as first_shipped_date 
      from wbr_full_metric_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd'
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
where company='Y4A' and channel!='local' and a.sku = 'A4PY'




select a.sku,b.product_name, a.first_ordered_date,a.first_shipped_date,a.datediff
 from (
WIth first_order_ship_date as 
(select sku
            , min(log_date) AS first_ordered_date
            , null as first_shipped_date 
            from full_metrics_daily
where ordered_units <>0 and ordered_units is not null and label_currency='usd'
group by sku

UNION ALL

select sku
            , null AS first_ordered_date
            , min(log_date) as first_shipped_date 
            from full_metrics_daily
where shipped_units <>0 and shipped_units is not null and label_currency='usd'
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
where company='Y4A' and channel!='local' and a.sku= 'A4PY'



select sum(ordered_gmv) from full_metrics_daily a 
join sc_main.dim_product b on a.sku= b.sku
where b.company='Y4A' 
and a.channel<> 'local' 
and a.label_currency = 'usd' 
and a.log_date BETWEEN '2022-01-01' and '2022-12-31'
and b.root_category = 'Sporting Goods'
and b.subcategory is not null 
and a.country = 'USA'
and b.team = 'YSL'

select sum(ordered_gmv) from wbr_full_metric_daily a 
join sc_main.dim_product b on a.sku= b.sku
where b.company='Y4A' 
and a.channel<> 'local' 
and a.label_currency = 'usd' 
and a.date_db BETWEEN '2022-01-01' and '2022-12-31'
and b.root_category = 'Sporting Goods'
and b.subcategory is not null 
and a.country_code = 'USA'
and b.team = 'YSL'

select sum(ordered_gmv) from full_metrics_daily a 
join sc_main.dim_product b on a.sku= b.sku
where b.company='Y4A' 
and a.channel<> 'local' 
and a.label_currency = 'usd' 
and a.log_date BETWEEN '2022-01-01' and '2022-12-31'
and b.root_category = 'Sporting Goods'
and b.subcategory is not null 
and a.country = 'USA'
and b.team = 'YSL'

select DISTINCT channel from full_metrics_daily




select date_db, sum(ordered_units) from wbr_full_metric_daily
GROUP BY date_db
ORDER BY date_db desc



select * from full_metrics_daily
where year(log_date) >= 2022 and label_currency = 'USD' and country = 'USA'



select log_date, sku, sum(ordered_gmv) from full_metrics_daily
WHERE YEAR(LOG_DATE)=2023 AND SKU='AAZX'
group by log_date,sku
ORDER BY LOG_DATE DESC


select date_db, sku, sum(ordered_gmv) from wbr_full_metric_daily
WHERE YEAR(date_db)=2023 AND SKU='AAZX'
group by date_db,sku
ORDER BY date_db DESC


SELECT sku,channel, sum(ordered_units) from full_metrics_daily
WHERE sku ='03NF' and label_currency = "USD" and country = "USA" and log_date BETWEEN '2023-03-19' and '2023-03-25'
group by sku,channel

select DISTINCT channel from dim_product












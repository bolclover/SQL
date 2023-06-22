
	 WITH Y AS (select sum(ordered_units) as ordered_units_1st_day
, 1 as ref

from public_main.full_metrics_daily

where log_date =DATE_ADD(CURRENT_DATE, INTERVAL-6 day)
and country = 'USA'
and Channel in ('AVC','FBA','FBM') )

,X AS 
(select distinct log_date
    ,sum(ordered_units) as ordered_units
    ,1 as ref 

from public_main.full_metrics_daily

where log_date < CURRENT_DATE
and log_date >= DATE_ADD(CURRENT_DATE, INTERVAL-6 day)
and country = 'USA'
and Channel in ('AVC','FBA','FBM')

group by log_date)

select max(log_date) as date_update FROM
(

SELECT 
X.log_date
,X.ordered_units
,Y.ordered_units_1st_day
,X.ref 
,case when (X.ordered_units/Y.ordered_units_1st_day) >0.8 then 'full' else null end as data_check
FROM X

left join Y on X.ref=Y.ref) Z

where Z.data_check = 'full'




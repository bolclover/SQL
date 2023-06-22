with fc_month as (

select a.`source.name`, a.`month` as log_date ,a.sku,a.platform,a.country,a.sem as fc_sem, a.dsp as fc_dsp, a.promotion as fc_promotion ,a.`real sales` as fc_units,a.gmv as fc_gmv,group_check,rank_check,
case when a.platform in ('WF','AMZ') and a.`Source.Name` like '%fur%' and a.country = 'USA' then 'Furniture' 
	   when a.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') then 'International'
		 when a.Platform ='AMZ' and a.`Source.Name` not like '%fur%' and a.Country ='USA' then 'US_SG_AMZ'
		 when a.Platform ='WM' then 'Walmart'	
		 else 'check' end as Group_KPI   
		 #,'' as units ,'' as gmv ,'' as vm_promo_spend ,'' as vc_promo_spend,'' as coupon_spend,'' as	sbv_spend,'' as	sp_spend,'' as sd_spend ,'' as sb_spend,'' as dsp_halo_spend,'' as dsp_promoted_spend,'' as pic_sale , '' as sale_team, '' as pic_sem, '' as sem_team 
from forecast_version a
join 
(
select a.* 
, DENSE_RANK() over (PARTITION by group_check, `Source.Name` ORDER BY `Month`) as rank_check 
from 
(
select DISTINCT a.`Source.Name`,`Month`,country,platform
,case when Platform = 'AMZ' and country = 'USA' and a.`source.name` not like '%fur%' then 'AMZ_US_SG' 
		  when Platform = 'AMZ' and country = 'USA' and a.`source.name` like '%fur%' then 'AMZ_US_FUR'
	    when Platform = 'AMZ' and country = 'CAN' then 'AMZ_CAN_SG'
			when Platform = 'AMZ' and country = 'JPN' then 'AMZ_JPN_SG'
			when Platform = 'AMZ' and country = 'MEX' then 'AMZ_MEX_SG'
			when Platform = 'AMZ' and country = 'SGP' then 'AMZ_SGP_SG'
			when Platform = 'AMZ' and country = 'AUS' then 'AMZ_AUS_SG'
			when Platform = 'AMZ' and country = 'ARE' then 'AMZ_ARE_SG'
			when Platform = 'AMZ' and country = 'DEU' then 'AMZ_DEU_SG'
			when Platform = 'AMZ' and country = 'GBR' then 'AMZ_GBR_SG'
			when Platform = 'AMZ' and country = 'ITA' then 'AMZ_ITA_SG'
			when Platform = 'AMZ' and country = 'FRA' then 'AMZ_FRA_SG'
			when Platform = 'AMZ' and country = 'ESP' then 'AMZ_ESP_SG'
			when Platform = 'WM'  and country = 'USA' and a.`source.name` not like '%fur%' then 'WM_US_SG'
			when Platform = 'WM'  and country = 'USA' and a.`source.name` like '%fur%' then 'WM_US_FUR'
			when Platform = 'WF' and country = 'USA' then 'WF_US_FUR'
			else '' end as group_check 
from 
(
select `Source.Name` from dim_version 
where fc_rolling = 'yes' ) a 
left join forecast_version b  
on a.`Source.Name`=b.`Source.Name` where `month` is not null ) a ) b on a.`source.name`=b.`source.name` and a.`month`=b.`month` and a.Country =b.country and a.Platform = b.Platform 
where rank_check = 1)

,tran_table as 
( SELECT first_day_of_month as log_date
			,sku
			,Country
			,platform 
			,group_kpi 
			,sum(units) as units 
			,sum(gmv) as gmv 
			,sum(vm_promo_spend) as vm_promo_spend
			,sum(vc_promo_spend) as vc_promo_spend
			,sum(coupon_spend) as coupon_spend
			,sum(sbv_spend) as sbv_spend
			,sum(sp_spend) as sp_spend
			,sum(sd_spend) as sd_spend
			,sum(sb_spend) as sb_spend
			,sum(dsp_halo_spend) as dsp_halo_spend
			,sum(dsp_promoted_spend) as dsp_promoted_spend
			,pic_sale,sale_team,pic_sem,sem_team
			from 
(select a.*
				, case when (a.country = 'USA' 
										and b.root_category = 'Sporting Goods' 
										and b.team = 'YSL'
										and a.channel in ('FBA','FBM','AVC'))
										then 'US_SG_AMZ'  
										
								when (a.country = 'USA' 
										and b.root_category in('Sporting Goods','Furniture')
										and b.team = 'YSL'
										and a.channel in ('WM WFS', 'WM DSV'))
										then 'Walmart'
										
								when (#a.country = 'USA' 	and 
										b.root_category = 'Furniture' 
										and b.team = 'YSL')
										and a.channel in ('FBA','FBM','AVC','Wayfair')
										then 'Furniture' 
								when a.country in ('CAN','MEX','JPN','ARE','SGP','AUS','DEU','GBR','ITA','FRA','ESP') THEN 'International' 
							 else 'Deployment Lab' end as group_KPI
							  ,CASE WHEN country = 'USA' THEN ordered_units ELSE shipped_units END AS units 
              ,CASE WHEN country = 'USA' THEN ordered_gmv ELSE shipped_gmv END AS gmv 
		        	,case when a.channel in ('AVC','FBM','FBA') then 'AMZ'
			      when a.channel in ('WM WFS', 'WM DSV') then 'WM'
						when a.channel ='Wayfair' then 'WF'
						else "" end as Platform 
						, c.date 
						, first_day_of_month 
 from public_main.full_metrics_daily a
LEFT JOIN sc_main.dim_product b on a.sku = b.sku
join sc_main.dim_date c on a.log_date =c.date
where a.label_currency = 'USD' and year(log_date)>=2023 and company = 'Y4A' 
) a group by 1,2,3,4,5) 




select `source.name`,a.log_date,a.sku, a.platform,a.country,a.group_kpi
,sum(fc_sem) as fc_sem 
,sum(fc_dsp) as fc_dsp
,sum(fc_promotion) as fc_promotion
,sum(fc_units) as fc_units
,sum(fc_gmv) as fc_gmv 
,sum(units) as units
,sum(gmv) as gmv 
,sum(vm_promo_spend) as vm_promo_spend
,sum(vc_promo_spend) as vc_promo_spend
,sum(coupon_spend) as coupon_spend
,sum(sbv_spend) as sbv_spend
,sum(sp_spend) as sp_spend
,sum(sd_spend) as sd_spend
,sum(sb_spend) as sb_spend
,sum(dsp_halo_spend) as dsp_halo_spend
,sum(dsp_promoted_spend) as dsp_promoted_spend
,pic_sale,sale_team,pic_sem,sem_team 
from 
(select `source.name`,log_date,sku, platform,country,group_kpi
,sum(fc_sem) as fc_sem 
,sum(fc_dsp) as fc_dsp
,sum(fc_promotion) as fc_promotion
,sum(fc_units) as fc_units
,sum(fc_gmv) as fc_gmv 
from fc_month 
group by 1,2,3,4,5,6 ) a 
 left join 
 ( select log_date,sku,platform,country,group_kpi
,sum(units) as units
,sum(gmv) as gmv 
,sum(vm_promo_spend) as vm_promo_spend
,sum(vc_promo_spend) as vc_promo_spend
,sum(coupon_spend) as coupon_spend
,sum(sbv_spend) as sbv_spend
,sum(sp_spend) as sp_spend
,sum(sd_spend) as sd_spend
,sum(sb_spend) as sb_spend
,sum(dsp_halo_spend) as dsp_halo_spend
,sum(dsp_promoted_spend) as dsp_promoted_spend
,pic_sale,sale_team,pic_sem,sem_team 
from tran_table a
group by 1,2,3,4,5) b 
on a.log_date = b.log_date and a.sku = b.sku and a.country= b.country and a.Platform=b.Platform and a.group_KPI= b.group_KPI
GROUP BY 1,2,3,4,5,6 
 

select `Source.Name`,Platform,log_date_key,
RANK() OVER(PARTITION by Platform ORDER BY log_date_key desc) as rank_date
 from 
(
select `Source.Name`, final_version,Platform, log_date_key from dim_version
WHERE final_version = 'yes'
) a 
WHERE `Source.Name` like  '%AMZ_USA%' 
   or `Source.Name` like '%WM_USA%' 
   or `Source.Name` like '%USA_WM%' 
   or `Source.Name` like '%USA_AMZ%'
	 or `Source.Name` not like '%fur%'
	 
	 
  select * from forecast_version c 
	LEFT JOIN 
	(
	select `Source.Name`,`Month`
	from (
	select b.`Source.Name`,`Month`,b.Platform,log_date_key, RANK() OVER( ORDER BY log_date_key desc, `month`) as rank_12M from forecast_version a 
	join dim_version b 
	on a.`Source.Name`=b.`Source.Name`
	WHERE final_version= 'yes'and Country = 'USA'
	and (b.`Source.Name` like '%AMZ_USA%' 
	or b.`Source.Name` like '%USA_AMZ%')
	and b.`Source.Name` not like '%furni%'
	GROUP BY `source.name`,month, Platform,log_date_key
	ORDER BY log_date_key desc ) a
	WHERE rank_12M BETWEEN 1 and 12 ) d
	on c.`Source.Name`=d.`Source.Name` and c.`Month`=d.`Month`
	
	
	
	
	
	------
SELECT
	* 
FROM
	forecast_version c
	LEFT JOIN (
	SELECT
		`Source.Name`,
		`Month` 
	FROM
		(
		SELECT
			b.`Source.Name`,
			`Month`,
			b.Platform,
			log_date_key,
			RANK() OVER ( PARTITION BY Platform ORDER BY log_date_key DESC, `month` ) AS rank_12M 
		FROM
			forecast_version a
			JOIN dim_version b ON a.`Source.Name` = b.`Source.Name` 
		WHERE
			final_version = 'yes' 
			AND Country = 'USA' 
			AND ( b.`Source.Name` LIKE '%AMZ_USA%' OR b.`Source.Name` LIKE '%USA_AMZ%' OR b.`Source.Name` LIKE '%WM_USA%' OR b.`Source.Name` LIKE '%USA_WM%' ) 
			AND b.`Source.Name` NOT LIKE '%furni%' 
		GROUP BY
			`source.name`,
			MONTH,
			Platform,
			log_date_key 
		ORDER BY
			log_date_key DESC 
		) c 
	WHERE
		rank_12M BETWEEN 1 
		AND 12 
	) d ON c.`Source.Name` = d.`Source.Name` 
	AND c.`Month` = d.`Month`
	
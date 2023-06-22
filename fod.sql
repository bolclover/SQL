SELECT
	d.sku,
	d.product_name,
	d.first_ordered_date AS FOD_wbr,
	d.first_shipped_date AS FSD_wbr,
	e.first_ordered_date AS FOD_depDA,
	e.first_shipped_date AS FSD_depDA 
FROM
	(
	SELECT
		a.sku,
		b.product_name,
		a.first_ordered_date,
		a.first_shipped_date,
		a.datediff 
	FROM
		(
			WITH first_order_ship_date AS (
			SELECT
				sku,
				min( log_date ) AS first_ordered_date,
				NULL AS first_shipped_date 
			FROM
				full_metrics_daily 
			WHERE
				ordered_units <> 0 
				AND ordered_units IS NOT NULL 
				AND label_currency = 'usd' 
				AND country = 'USA' 
			GROUP BY
				sku UNION ALL
			SELECT
				sku,
				NULL AS first_ordered_date,
				min( log_date ) AS first_shipped_date 
			FROM
				full_metrics_daily 
			WHERE
				shipped_units <> 0 
				AND shipped_units IS NOT NULL 
				AND label_currency = 'usd' 
				AND country = 'USA' 
			GROUP BY
				sku 
			) SELECT
			sku,
			min( first_ordered_date ) AS first_ordered_date,
			min( first_shipped_date ) AS first_shipped_date,
			DATEDIFF(
				min( first_shipped_date ),
			min( first_ordered_date )) AS datediff 
		FROM
			first_order_ship_date 
		GROUP BY
			sku 
		ORDER BY
			datediff DESC 
		) a
		JOIN sc_main.dim_product b ON a.sku = b.sku 
	WHERE
		company = 'Y4A' 
		AND channel != 'local' 
		AND team = 'YSL' 
		AND sell_type <> 'Combo' 
		AND root_category = 'Sporting Goods' 
	) d
	LEFT JOIN sc_main.deployment_process_tracking e ON d.sku = e.sku SELECT
	* 
FROM
	sc_main.deployment_process_tracking SELECT
	a.sku,
	b.product_name,
	a.first_ordered_date,
	a.first_shipped_date,
	a.datediff 
FROM
	(
		WITH first_order_ship_date AS (
		SELECT
			sku,
			min( log_date ) AS first_ordered_date,
			NULL AS first_shipped_date 
		FROM
			full_metrics_daily 
		WHERE
			ordered_units <> 0 
			AND ordered_units IS NOT NULL 
			AND label_currency = 'usd' 
			AND country = 'USA' 
		GROUP BY
			sku UNION ALL
		SELECT
			sku,
			NULL AS first_ordered_date,
			min( log_date ) AS first_shipped_date 
		FROM
			full_metrics_daily 
		WHERE
			shipped_units <> 0 
			AND shipped_units IS NOT NULL 
			AND label_currency = 'usd' 
			AND country = 'USA' 
		GROUP BY
			sku 
		) SELECT
		sku,
		min( first_ordered_date ) AS first_ordered_date,
		min( first_shipped_date ) AS first_shipped_date,
		DATEDIFF(
			min( first_shipped_date ),
		min( first_ordered_date )) AS datediff 
	FROM
		first_order_ship_date 
	GROUP BY
		sku 
	ORDER BY
		datediff DESC 
	) a
	JOIN sc_main.dim_product b ON a.sku = b.sku 
WHERE
	company = 'Y4A' 
	AND channel != 'local' 
	AND team = 'YSL' 
	AND sell_type <> 'Combo' 
	AND root_category = 'Sporting Goods' SELECT
	sku,
	min(
		sc_main 
	FROM
		sc_main.deployment_process_tracking SELECT
		sku,
		channel,
		country,
		min( log_date ) 
	FROM
		full_metrics_daily 
	WHERE
		sku IN ( 'FVXS', 'WLD4', 'Z6WB' ) 
	GROUP BY
		1,
	2,
	3
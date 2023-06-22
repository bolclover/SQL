WITH milestones_date as 
(SELECT DISTINCT sku, min(log_date) as booking_date, NULL AS 1st_ds_order_date  FROM `full_inventory`
where booking_avc_ds is not null
group by sku

UNION ALL  

Select sku, NULL AS booking_date, min(created_at) as 1st_ds_order_date from customer_order_avc_ds
where created_at is not NULL
group by sku

)

select a.sku
			,a.product_name
			,a.life_cycle
			,min(milestones_date.1st_ds_order_date) as 1st_ds_order_date
			,min(milestones_date.booking_date) as booking_date
			 from dim_product a
left join milestones_date on milestones_date.sku = a.sku

group by a.sku
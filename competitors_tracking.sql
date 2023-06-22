### competitor 
SELECT DATE(DATE_SUB(date_db, INTERVAL DAYOFMONTH(date_db) - 1 DAY)) AS __timestamp,
       label_brand AS `Brand`,
       sum(sales_this_month) AS `Sales`
FROM
  (with product_table as
     (select subcategory,
             category,
             root_category,
             company
      from sc_main.dim_product
      group by 1,
               2,
               3) SELECT date_db,
                         asin_cmp asin,
                         upper(cpt.brand) brand,
                         upper(cpt.label_brand) label_brand,
                         upper(cpt.label_brand_est) label_brand_est,
                         country_code country,
                         max(sales_this_month) sales_this_month,
                         max(sales_this_month_est) sales_this_month_est,
                         avg(median_price_amz_this_month) price_amz_this_month,
                         avg(median_price_seller_this_month) price_seller_this_month,
                         avg(median_sale_rank_this_month) sale_rank_this_month,
                         max(review_this_month) review_this_month,
                         avg(median_rating_this_month) rating_this_month,
                         max(sales_last_month) sales_last_month,
                         avg(median_price_amz_last_month) price_amz_last_month,
                         avg(median_price_seller_last_month) price_seller_last_month,
                         max(median_sale_rank_last_month) sale_rank_last_month,
                         max(review_last_month) review_last_month,
                         max(median_rating_last_month) median_rating_last_month,
                         max(inventory_this_month) inventory_this_month,
                         max(avg_sale_180_this_month) avg_sale_180_this_month,
                         max(inventory_last_month) inventory_last_month,
                         max(avg_sale_180_last_month) avg_sale_180_last_month,
                         max(category) category,
                         max(cpt.subcategory) subcategory,
                         max(root_category) root_category,
                         max(cdi.title) title,
                         max(CONCAT('<img src="https://m.media-amazon.com/images/I/', substring_index(cdi.image, ';', -1), '" alt="competitor image" />')) image,
                         max(case
                                 when country_code = "USA" then "amazon.com/dp/"
                                 when country_code = "CAN" then "amazon.ca/dp/"
                                 when country_code = "JPN" then "amazon.co.jp/dp/"
                                 when country_code = "DEU" then "amazon.de/dp/"
                                 when country_code = "GBR" then "amazon.co.uk/dp/"
                             end) as link_product
   FROM public_main.competitor_performance_monthly as cpt
   LEFT JOIN product_table as dp on cpt.subcategory = dp.subcategory
   left join public_main.competitor_detail_info as cdi on cdi.country = country_code
   and cdi.asin = cpt.asin_cmp
   where label_brand is not null
     and cpt.brand != "0"
     and dp.company = 'Y4A'
     and root_category in ('Sporting Goods',
                           'Furniture')
   GROUP BY asin_cmp,
            date_db,
            cpt.brand,
            country_code,
            cpt.label_brand,
            cpt.label_brand_est) AS virtual_table
WHERE date_db >= STR_TO_DATE('2022-06-01', '%Y-%m-%d')
  AND date_db < STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND country IN ('USA')
  AND root_category IN ('Sporting Goods')
  AND brand != '0'
GROUP BY label_brand,
         DATE(DATE_SUB(date_db, INTERVAL DAYOFMONTH(date_db) - 1 DAY))
ORDER BY `Sales` DESC



## top 10 competior 


SELECT DATE(DATE_SUB(date_db, INTERVAL DAYOFMONTH(date_db) - 1 DAY)) AS __timestamp,
       label_brand AS label_brand,
       sum(sales_this_month) AS `Sales`
FROM
  (with product_table as
     (select subcategory,
             category,
             root_category,
             company
      from sc_main.dim_product
      group by 1,
               2,
               3) SELECT date_db,
                         asin_cmp asin,
                         upper(cpt.brand) brand,
                         upper(cpt.label_brand) label_brand,
                         upper(cpt.label_brand_est) label_brand_est,
                         country_code country,
                         max(sales_this_month) sales_this_month,
                         max(sales_this_month_est) sales_this_month_est,
                         avg(median_price_amz_this_month) price_amz_this_month,
                         avg(median_price_seller_this_month) price_seller_this_month,
                         avg(median_sale_rank_this_month) sale_rank_this_month,
                         max(review_this_month) review_this_month,
                         avg(median_rating_this_month) rating_this_month,
                         max(sales_last_month) sales_last_month,
                         avg(median_price_amz_last_month) price_amz_last_month,
                         avg(median_price_seller_last_month) price_seller_last_month,
                         max(median_sale_rank_last_month) sale_rank_last_month,
                         max(review_last_month) review_last_month,
                         max(median_rating_last_month) median_rating_last_month,
                         max(inventory_this_month) inventory_this_month,
                         max(avg_sale_180_this_month) avg_sale_180_this_month,
                         max(inventory_last_month) inventory_last_month,
                         max(avg_sale_180_last_month) avg_sale_180_last_month,
                         max(category) category,
                         max(cpt.subcategory) subcategory,
                         max(root_category) root_category,
                         max(cdi.title) title,
                         max(CONCAT('<img src="https://m.media-amazon.com/images/I/', substring_index(cdi.image, ';', -1), '" alt="competitor image" />')) image,
                         max(case
                                 when country_code = "USA" then "amazon.com/dp/"
                                 when country_code = "CAN" then "amazon.ca/dp/"
                                 when country_code = "JPN" then "amazon.co.jp/dp/"
                                 when country_code = "DEU" then "amazon.de/dp/"
                                 when country_code = "GBR" then "amazon.co.uk/dp/"
                             end) as link_product
   FROM public_main.competitor_performance_monthly as cpt
   LEFT JOIN product_table as dp on cpt.subcategory = dp.subcategory
   left join public_main.competitor_detail_info as cdi on cdi.country = country_code
   and cdi.asin = cpt.asin_cmp
   where label_brand is not null
     and cpt.brand != "0"
     and dp.company = 'Y4A'
     and root_category in ('Sporting Goods',
                           'Furniture')
   GROUP BY asin_cmp,
            date_db,
            cpt.brand,
            country_code,
            cpt.label_brand,
            cpt.label_brand_est) AS virtual_table
INNER JOIN
  (SELECT label_brand AS label_brand__,
          sum(sales_this_month) AS mme_inner__
   FROM
     (with product_table as
        (select subcategory,
                category,
                root_category,
                company
         from sc_main.dim_product
         group by 1,
                  2,
                  3) SELECT date_db,
                            asin_cmp asin,
                            upper(cpt.brand) brand,
                            upper(cpt.label_brand) label_brand,
                            upper(cpt.label_brand_est) label_brand_est,
                            country_code country,
                            max(sales_this_month) sales_this_month,
                            max(sales_this_month_est) sales_this_month_est,
                            avg(median_price_amz_this_month) price_amz_this_month,
                            avg(median_price_seller_this_month) price_seller_this_month,
                            avg(median_sale_rank_this_month) sale_rank_this_month,
                            max(review_this_month) review_this_month,
                            avg(median_rating_this_month) rating_this_month,
                            max(sales_last_month) sales_last_month,
                            avg(median_price_amz_last_month) price_amz_last_month,
                            avg(median_price_seller_last_month) price_seller_last_month,
                            max(median_sale_rank_last_month) sale_rank_last_month,
                            max(review_last_month) review_last_month,
                            max(median_rating_last_month) median_rating_last_month,
                            max(inventory_this_month) inventory_this_month,
                            max(avg_sale_180_this_month) avg_sale_180_this_month,
                            max(inventory_last_month) inventory_last_month,
                            max(avg_sale_180_last_month) avg_sale_180_last_month,
                            max(category) category,
                            max(cpt.subcategory) subcategory,
                            max(root_category) root_category,
                            max(cdi.title) title,
                            max(CONCAT('<img src="https://m.media-amazon.com/images/I/', substring_index(cdi.image, ';', -1), '" alt="competitor image" />')) image,
                            max(case
                                    when country_code = "USA" then "amazon.com/dp/"
                                    when country_code = "CAN" then "amazon.ca/dp/"
                                    when country_code = "JPN" then "amazon.co.jp/dp/"
                                    when country_code = "DEU" then "amazon.de/dp/"
                                    when country_code = "GBR" then "amazon.co.uk/dp/"
                                end) as link_product
      FROM public_main.competitor_performance_monthly as cpt
      LEFT JOIN product_table as dp on cpt.subcategory = dp.subcategory
      left join public_main.competitor_detail_info as cdi on cdi.country = country_code
      and cdi.asin = cpt.asin_cmp
      where label_brand is not null
        and cpt.brand != "0"
        and dp.company = 'Y4A'
        and root_category in ('Sporting Goods',
                              'Furniture')
      GROUP BY asin_cmp,
               date_db,
               cpt.brand,
               country_code,
               cpt.label_brand,
               cpt.label_brand_est) AS virtual_table
   WHERE country IN ('USA')
     AND root_category IN ('Sporting Goods')
     AND brand != '0'
     AND date_db >= STR_TO_DATE('2022-06-01', '%Y-%m-%d')
     AND date_db < STR_TO_DATE('2023-06-01', '%Y-%m-%d')
   GROUP BY label_brand
   ORDER BY sum(sales_this_month) DESC
   LIMIT 10) AS anon_1 ON label_brand = label_brand__
WHERE date_db >= STR_TO_DATE('2022-06-01', '%Y-%m-%d')
  AND date_db < STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND country IN ('USA')
  AND root_category IN ('Sporting Goods')
  AND brand != '0'
GROUP BY label_brand,
         DATE(DATE_SUB(date_db, INTERVAL DAYOFMONTH(date_db) - 1 DAY))
ORDER BY `Sales` DESC



## sale by brand 
SELECT sum(sales_this_month) AS `Total Sales`,
       sum(sales_this_month) - sum(sales_last_month) AS `Sales (Gap W Last Month)`,
       sum(sales_this_month)/sum(sales_last_month) - 1 AS `Sales (MoM)`,
       concat(format(count(distinct CASE
                                        when ((COALESCE(price_amz_this_month, price_seller_this_month)/COALESCE(price_amz_last_month, price_seller_last_month) - 1) <= -0.15) then asin
                                    end), 0), "/", format(count(DISTINCT asin), 0)) AS `# Asin Has Decrease Price `
FROM
  (with product_table as
     (select subcategory,
             category,
             root_category,
             company
      from sc_main.dim_product
      group by 1,
               2,
               3) SELECT date_db,
                         asin_cmp asin,
                         upper(cpt.brand) brand,
                         upper(cpt.label_brand) label_brand,
                         upper(cpt.label_brand_est) label_brand_est,
                         country_code country,
                         max(sales_this_month) sales_this_month,
                         max(sales_this_month_est) sales_this_month_est,
                         avg(median_price_amz_this_month) price_amz_this_month,
                         avg(median_price_seller_this_month) price_seller_this_month,
                         avg(median_sale_rank_this_month) sale_rank_this_month,
                         max(review_this_month) review_this_month,
                         avg(median_rating_this_month) rating_this_month,
                         max(sales_last_month) sales_last_month,
                         avg(median_price_amz_last_month) price_amz_last_month,
                         avg(median_price_seller_last_month) price_seller_last_month,
                         max(median_sale_rank_last_month) sale_rank_last_month,
                         max(review_last_month) review_last_month,
                         max(median_rating_last_month) median_rating_last_month,
                         max(inventory_this_month) inventory_this_month,
                         max(avg_sale_180_this_month) avg_sale_180_this_month,
                         max(inventory_last_month) inventory_last_month,
                         max(avg_sale_180_last_month) avg_sale_180_last_month,
                         max(category) category,
                         max(cpt.subcategory) subcategory,
                         max(root_category) root_category,
                         max(cdi.title) title,
                         max(CONCAT('<img src="https://m.media-amazon.com/images/I/', substring_index(cdi.image, ';', -1), '" alt="competitor image" />')) image,
                         max(case
                                 when country_code = "USA" then "amazon.com/dp/"
                                 when country_code = "CAN" then "amazon.ca/dp/"
                                 when country_code = "JPN" then "amazon.co.jp/dp/"
                                 when country_code = "DEU" then "amazon.de/dp/"
                                 when country_code = "GBR" then "amazon.co.uk/dp/"
                             end) as link_product
   FROM public_main.competitor_performance_monthly as cpt
   LEFT JOIN product_table as dp on cpt.subcategory = dp.subcategory
   left join public_main.competitor_detail_info as cdi on cdi.country = country_code
   and cdi.asin = cpt.asin_cmp
   where label_brand is not null
     and cpt.brand != "0"
     and dp.company = 'Y4A'
     and root_category in ('Sporting Goods',
                           'Furniture')
   GROUP BY asin_cmp,
            date_db,
            cpt.brand,
            country_code,
            cpt.label_brand,
            cpt.label_brand_est) AS virtual_table
WHERE date_db >= STR_TO_DATE('2023-05-01', '%Y-%m-%d')
  AND date_db < STR_TO_DATE('2023-06-01', '%Y-%m-%d')
  AND country IN ('USA')
  AND root_category IN ('Sporting Goods')
  AND (((sales_this_month/sales_last_month -1) >= 0.2))



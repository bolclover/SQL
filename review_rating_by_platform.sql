SELECT DATE(review_date) AS review_date,
       link_asin AS link_asin,
       band AS band,
       CASE
           WHEN review_rating = 1 THEN '1'
           WHEN review_rating = 2 THEN '2'
           WHEN review_rating = 3 THEN '3'
           WHEN review_rating = 4 THEN '4'
           WHEN review_rating = 5 THEN '5'
       END AS `Rating`,
       COALESCE(CONCAT('<a href="', review_link, '" target="_blank">', review_title, '</a><br>', review_content), CONCAT('<a href="', review_link, '" target="_blank">Detail</a><br>')) AS review,
       verify_purchase AS verify_purchase,
       reviewer_name AS reviewer_name,
       reviewer_location AS reviewer_location,
       issue AS issue,
			 sku,
			 company,
			 asin,
			 country,
			 platform
FROM
  (SELECT r.sku,
          r.company,
          r.asin,
          r.product_name,
          r.style_size,
          r.style_color,
          r.review_rating,
          r.review_link,
          r.review_title,
          r.review_date,
          r.reviewer_location,
          r.review_content,
          r.reviewer_name,
          REPLACE(REPLACE(TRIM(CONCAT(CASE
                                          WHEN verify_purchase = 1 THEN '- Verified Purchase'
                                          ELSE ''
                                      END, '<br>', CASE
                                                       WHEN is_top_1000_reviewer = 1 THEN '- Top 1000 Reviewer'
                                                       ELSE ''
                                                   END, '<br>', CASE
                                                                    WHEN is_top_500_reviewer = 1 THEN '- Top 500 Reviewer'
                                                                    ELSE ''
                                                                END, '<br>', CASE
                                                                                 WHEN is_vine_voice = 1 THEN '- Vine Voice'
                                                                                 ELSE ''
                                                                             END)), '<br><br>', '<br>'), '<br><br>', '<br>') verify_purchase,
          r.country,
          'Amazon - Vendor' platform,
                            CASE
                                WHEN dp.team = "YDL" THEN "Innonet"
                                WHEN dp.team = "YSL" THEN "Sales&Ops"
                                WHEN dp.team = "HMD" THEN "HMD"
                                ELSE dp.team
                            END as Department,
                            dp.subcategory,
                            dp.category,
                            dp.root_category,
                            dp.life_cycle,
                            CASE
                                WHEN dp.created_at < date_sub(curdate(), interval 1 year) THEN 'Old Product'
                                ELSE 'New Product'
                            END product_status,
                            COALESCE(issue, '') issue,
                            CASE band_total_gmv
                                WHEN 'A' THEN 'A - Top 30% GMV'
                                WHEN 'B' THEN 'B - Top 60% GMV'
                                ELSE 'C - Other'
                            END band,
                            CONCAT('<a href="', SUBSTRING_INDEX(review_link, 'gp/', 1), 'dp/', r.asin, '?th=1&psc=1" target="_blank">', r.asin, '</a><br>', r.product_name) link_asin
   FROM sc_main.amazon_review_product r
   LEFT JOIN
     (SELECT review_link,
             GROUP_CONCAT(issue SEPARATOR '<br>') issue
      FROM amazon_review_classify
      GROUP BY 1) ir USING (review_link)
   LEFT JOIN sc_main.dim_product dp USING (sku)
   LEFT JOIN
     (SELECT sku,
             country,
             band_total_gmv
      FROM sku_profile_customer_order_last_day) b USING (sku,
                                                         country)
   UNION ALL SELECT dp.sku,
                    dp.company,
                    o.asin,
                    dp.product_name,
                    '',
                    dp.size,
                    r.review_rating,
                    'https://www.amazon.com/sp?ie=UTF8&seller=A7BDHNKH3IXDW',
                    'Review in idzo storefront',
                    r.review_date,
                    r.reviewer_location,
                    r.review_content,
                    o.ship_to_name,
                    r.verify_purchase,
                    r.country,
                    'Amazon - Seller' platform,
                                      CASE
                                          WHEN dp.team = "YDL" THEN "Innonet"
                                          WHEN dp.team = "YSL" THEN "Sales&Ops"
                                          WHEN dp.team = "HMD" THEN "HMD"
                                          ELSE dp.team
                                      END as Department,
                                      dp.subcategory,
                                      dp.category,
                                      dp.root_category,
                                      dp.life_cycle,
                                      CASE
                                          WHEN dp.created_at < date_sub(curdate(), interval 1 year) THEN 'Old Product'
                                          ELSE 'New Product'
                                      END product_status,
                                      '' issue,
                                         CASE band_total_gmv
                                             WHEN 'A' THEN 'A - Top 30% GMV'
                                             WHEN 'B' THEN 'B - Top 60% GMV'
                                             ELSE 'C - Other'
                                         END band,
                                         CONCAT('<a href="https://www.amazon.com/dp/', o.asin, '?th=1&psc=1" target="_blank">', o.asin, '</a><br>', dp.product_name)
   FROM sc_main.amazon_seller_review_product r
   LEFT JOIN customer_order_asc o USING (amazon_order_id,
                                         country)
   LEFT JOIN sc_main.dim_product dp USING (sku)
   LEFT JOIN
     (SELECT sku,
             country,
             band_total_gmv
      FROM sku_profile_customer_order_last_day) b USING (sku,
                                                         country)
   UNION ALL SELECT dp.sku,
                    dp.company,
                    r.walmart_item_id,
                    dp.product_name,
                    '',
                    dp.size,
                    r.review_rating,
                    CONCAT('https://www.walmart.com/reviews/product/', r.walmart_item_id, '?filter='),
                    r.review_title,
                    r.review_date,
                    'United States',
                    r.review_content,
                    r.reviewer_name,
                    r.verify_purchase,
                    r.country,
                    'Walmart - Supplier' platform,
                                         CASE
                                             WHEN dp.team = "YDL" THEN "Innonet"
                                             WHEN dp.team = "YSL" THEN "Sales&Ops"
                                             WHEN dp.team = "HMD" THEN "HMD"
                                             ELSE dp.team
                                         END as Department,
                                         dp.subcategory,
                                         dp.category,
                                         dp.root_category,
                                         dp.life_cycle,
                                         CASE
                                             WHEN dp.created_at < date_sub(curdate(), interval 1 year) THEN 'Old Product'
                                             ELSE 'New Product'
                                         END product_status,
                                         '' issue,
                                            CASE band_total_gmv
                                                WHEN 'A' THEN 'A - Top 30% GMV'
                                                WHEN 'B' THEN 'B - Top 60% GMV'
                                                ELSE 'C - Other'
                                            END band,
                                            CONCAT('<a href="https://www.walmart.com/ip/', r.walmart_item_id, '" target="_blank">', r.walmart_item_id, '</a><br>', dp.product_name)
   FROM sc_main.walmart_review_product r
   LEFT JOIN sc_main.dim_product dp USING (sku)
   LEFT JOIN
     (SELECT sku,
             country,
             band_total_gmv
      FROM sku_profile_customer_order_last_day) b USING (sku,
                                                         country)) AS virtual_table
WHERE 
  `Department` IN ('Sales&Ops')
  AND company IN ('Y4A')
GROUP BY DATE(review_date),
         link_asin,
         band,
         CASE
             WHEN review_rating = 1 THEN '1'
             WHEN review_rating = 2 THEN '2'
             WHEN review_rating = 3 THEN '3'
             WHEN review_rating = 4 THEN '4'
             WHEN review_rating = 5 THEN '5'
         END,
         COALESCE(CONCAT('<a href="', review_link, '" target="_blank">', review_title, '</a><br>', review_content), CONCAT('<a href="', review_link, '" target="_blank">Detail</a><br>')),
         verify_purchase,
         reviewer_name,
         reviewer_location,
         issue,
         sku,
			 company,
			 asin,
			 country,
			 platform
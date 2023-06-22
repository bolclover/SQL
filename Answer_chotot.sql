**2.Tạo Table CHOTOT_2 như sau
---2
CREATE TABLE chotot_2 
    (
    region nvarchar(150),
    income varchar(50)
    )


INSERT INTO chotot_2
  ("region", "income")
VALUES
 ('Dong Nam Bo', 'High'),
 ('Quang Nam Da Nang','Medium'),
 ('Hai Phong - Nam Dinh - Thai Binh','low'),
 ('Tay Nam Bo','Low'),
 ('Nam Trung Bo','Medium'),
 ('Tay Nguyen','Medium'),
 ('Dong Bac','Medium'),
 ('Tay Bac','Medium'),
 ('Hanoi','High'),
 ('TP HCM','High')


---3--Ở cột Region, update các giá trị Đông Nam Bộ và DNB thành Dong Nam Bo để đảm bảo consistent


 update chotot_SQLtest
 set Region='Dong Nam Bo'
 where region in('Đông Nam Bộ','DNB')
 --4-- Có bao nhiêu Contact_Private_Sellers theo từng Platform
 select platform 
        ,count(contact_Private_Sellers) as count_countact
 from chotot_SQLtest
 group by platform

 --5. Từ table CHOTOT và CHOTOT2, tính tổng Contact_Pro_Sellers theo từng Regions với điều kiện sau:

Chỉ lấy Regions có Income High hoặc Medium
Platform không bao gồm Chotot Desktop
select a. region 
        ,sum([Contact_Pro_Sellers]) as sum_of_pro_seller
from chotot_SQLtest a
left join chotot_2 b
on a.region=b.region
where (income='high' or income='Medium') and PLATFORM <>'Chotot Desktop'
group by a.region

There are 2 types of sellers on Chotot, namely Pro Seller (company/shop/brand) and Private Seller (all of sellers who are not company/shop/brand). A contact is defined when the buyer Call/SMS/Email/Chat with a Seller. This table contains the data of contact sellers on all Chotot platforms from 1/1/2016 to 31/3/2016. ​

--1--What are the top 3 regions with highest number of private sellers contacts by each platform?


with table_rank as 
(
    select platform
        ,region
        ,countpriseller
        ,rank() over(partition by platform order by countpriseller desc) as top_seller
    from
    (
    select platform
            ,region
            ,count(Contact_Private_Sellers) as countpriseller
    from chotot_SQLtest
    group by PLATFORM, region
    ) a
)
select* from table_rank where top_seller <4

--2  --What are the top 3 regions that prefer buying from the Pro sellers? ​


with table_rank as
(
    select region
    , countproseller
    ,rank()over(order by countproseller desc) as rankproseller 
     from
    (
    select region
    ,count(Contact_Pro_Sellers) as countproseller
    from ChoTot_SQLtest
    group by region 
    ) a
)
select * from table_rank
 where rankproseller <4


 ---3---For each day, what are the region with highest number of seller?​


with table3 as
(
    select each_day
    ,region
    ,sum_seller
    ,rank() over(partition by each_day order by sum_seller desc) as rank_sum 
    from
    (
        select each_day,region,sum(total_seller)as sum_seller
        from
        (select day(date) as each_day
        , region
        ,([Contact_Private_Sellers] +[Contact_Pro_Sellers]) as total_seller 
        from ChoTot_SQLtest
        ) a
    group by each_day,region
    ) b
)
select each_day,region,sum_seller from table3
where rank_sum=1

--4 ---For each month, please make 3 columns


with table4 as
(
    select month_col
    ,[TP HCM]
    ,[Hanoi]
    from
        (
        select month_col
        , region
        , sum(total_seller) as sum_seller
        from
            (
            select month(date) as month_col
            , region
            ,([Contact_Private_Sellers] +[Contact_Pro_Sellers]) as total_seller 
            from ChoTot_SQLtest
            where region in('hanoi','TP HCM')
            )a
        group by month_col, region 
        ) b
    pivot (sum(sum_seller) for region in ([TP HCM],[Hanoi])) as pivottable
)

select 
    [TP HCM]
    , Hanoi

    ,case when (Hanoi >=[TP HCM]*0.45) then  'HN has more than 45% sellers of HCM'
        else 'HN has less than 45% sellers of HCM'
        end as HN_situation
from table4
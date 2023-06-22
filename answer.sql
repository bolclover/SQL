select c.contest_id
      ,c.hacker_id
      ,c.name
      ,sum(total_submissions) as total_submissions
      ,sum(total_accepted_submissions) as total_accepted_submissions
      ,sum(total_views) as total_views
      ,sum(total_unique_views) as total_unique_views
from Contests_table c
join colleges_table d 
on c.contest_id = d.contest_id
join challenge_table e 
on d.college_id = e.college_id
left join 
     (select challenge_id
        ,sum(total_views) as total_views
        ,sum(total_unique_views) as total_unique_views
      from view_status_table
      group by challenge_id) a
on e.challenge_id = a.challenge_id
left join 
      (select challenge_id 
        ,sum(total_submissions) as total_submissions   
        ,sum(total_accepted_submissions) as total_accepted_submissions
       from submission_status_table 
        group by challenge_id ) b
on e.challenge_id = b.challenge_id
group by c.contest_id
        ,c.hacker_id
        ,c.name
HAVING (sum(total_submissions) + sum(total_accepted_submissions) + sum(total_views) + sum(total_unique_views) ) <> 0
order by contest_id 


Exercise 2

import pandas as pd 
import numpy as np 
df_datamobile = pd.read_csv("Automobile_data.csv")
df_missing = df_datamobile.replace(["?","n.a"],np.NAN)
value_counts =df_datamobile['company'].value_counts()
print(value_counts)
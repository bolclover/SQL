
fc_realsale average per Month = 
AVERAGEX(
	KEEPFILTERS(VALUES('sc_main dim_date_fc'[date].[Month])),
	CALCULATE(SUM('Forecast version'[Real sales]))
) 

check_new_group = IF(min('sc_main dim_product'[first_shipped_date])=0,"Pass",if((TODAY()-min('sc_main dim_product'[first_shipped_date]))/30<=3,"Pass","")) 

fc_realsale average per Month = 
AVERAGEX(
	KEEPFILTERS(VALUES('sc_main dim_date_fc'[date].[Month])),
	CALCULATE(SUM('Forecast version'[Real sales]))
)   


fc_mkt_fee = sum('Forecast version'[DSP])+sum('Forecast version'[SEM])+sum('Forecast version'[Promotion])


compare_CPU_average = iferror(([fc_CPU]-[CPU(final)])/[CPU(final)],"")


compare_CPU_median = iferror(([fc_CPU]-[final_CPU median per Month])/[final_CPU median per Month],"")  
 
 
 compare_CPU_last_month = iferror(([fc_CPU]-[final_CPU_last_month(mono)])/[final_CPU_last_month(mono)],"") 
 
 compare_CPU_average = iferror(([fc_CPU]-[CPU(final)])/[CPU(final)],"") 
 


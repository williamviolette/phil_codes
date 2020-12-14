* ibnet.do

	
	


	use /Users/williamviolette/Documents/Philippines/data/ibnet.dta, clear

tab r_3b_utility_ownership
* 94% are over 50% publicly owned



	tab r_p5_utilitys_planning_process

	g r_p5_d 	   = "none" if r_p5_utilitys_planning_process==1
	replace r_p5_d = "1 yr" if r_p5_utilitys_planning_process==2
	replace r_p5_d = "1 + 3-5 yrs"  if r_p5_utilitys_planning_process==3
	replace r_p5_d = "1 + 10 yrs"  if r_p5_utilitys_planning_process==4


	tab r_p6_tariff_calculation

	g r_p6_d 	   = "company" if r_p6_tariff_calculation==1
	replace r_p6_d = "regulator" if r_p6_tariff_calculation==2
	replace r_p6_d = "ministry"  if r_p6_tariff_calculation==3
	replace r_p6_d = "municipality"  if r_p6_tariff_calculation==4
	replace r_p6_d = "other"  if r_p6_tariff_calculation==5


	tab r_p7_final_tariff

	g r_p7_d 	   = "company"       if  r_p7_final_tariff==1
	replace r_p7_d = "regulator"     if  r_p7_final_tariff==2
	replace r_p7_d = "ministry"      if  r_p7_final_tariff==3
	replace r_p7_d = "municipality"  if  r_p7_final_tariff==4
	replace r_p7_d = "other"         if  r_p7_final_tariff==5


	drop if r_p5_utilitys_planning_process==.  |  r_p6_tariff_calculation==.  |  r_p7_final_tariff==. 



public_ownership = 





* g high_power = r_p6_d!="company"  &  r_p7_final_tariff!="company"  &  


	g r_combo = "calc: " + r_p6_d  + " final: " + r_p7_d

g o=1
gegen os=sum(o), by(r_combo)

gegen rc=group(r_combo)

	replace r_combo="" if os<=10

destring r_c4_monthly_bill_6m3 r_140_posted_tariff_water_m3_pop, replace  ignore(",")


gegen mbill = mean(r_c4_monthly_bill_6m3), by(r_combo)

twoway bar mbill rc




tab r_p6_d

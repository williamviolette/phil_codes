
	use  "${database}clean/mcf/2015/0200_052015_1.dta", clear	
		foreach r in 0200 0300 0400 0500 0600 0700 0800 0900 1000 1100 1200 1700 {
			qui append using  "${database}/clean/mcf/2015/`r'_052015_1.dta"
			}
		drop if Col3=="Row Count"
		ren Col19 create_date
		rename Col12 conacct
		rename Col10 mru
		ren Col21 city
		g year = substr(create_date,1,4)
		g month = substr(create_date,6,2)
		destring year month, replace force
		g date_c = ym(year,month)
		destring conacct mru, force replace
			duplicates drop conacct, force
			keep conacct mru city date_c
			drop if mru==. | conacct==.
	save "${temp}mcf_2015_mru_1.dta", replace	
	
	
	
use "${phil_folder}savings/temp/savings_sample.dta", clear
	
	drop billclass
	
	duplicates drop conacct, force
	
	merge 1:1 conacct using "${temp}mcf_2015_mru_1.dta"
	drop if _merge==1
	g M = _merge==3
	
	keep if date_c<=620
	
	egen MM=mean(M), by(mru)
	keep if MM>0
	
	* hist MM, discrete
	
	lab var hhsize "HH Size"	
	lab var hhemp "Total Empl."
	lab var age "Age HoH"	
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
*	lab var duplex "Duplex"
	lab var low_skill "Low Skill Emp."
*	lab var INC "Inc. USD/Mo. (Imputed)"
		lab var SHH "HHs per Connection"
	lab var mc "Mean Consumption (m3)"
	
	lab var MM "Percent Surveyed"

	sum MM, detail		
		reg MM mc SHH hhsize age hhemp low_skill house_1 house_2 if MM>`=r(p1)' & MM<`=r(p99)', robust cluster(mru)
	sum MM, detail		
		
		outreg2 using "${output}paws_sampling.tex", tex(frag) ///
		replace addtext("Mean Coverage","`=round(r(mean),.01)'","Std. Dev. Coverage","`=round(r(sd),.01)'","Cluster MRU","Yes") ///
		addnote("2,947 Meter Reading Units (MRUs)") label 
		
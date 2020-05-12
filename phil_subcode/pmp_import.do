* pmp_import.do



cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_ogc_fid_ind ON `1' (OGC_FID);"), dsn("phil")
end





	use "${complaintdata}cc_12_2012_all.dta", clear
	 	g year="2012"
		g month="01"
	foreach r in 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_2012_all.dta", force
		replace month="`r'" if month==""
		replace year="2012" if year==""
	}
	foreach z in 2013  {
	foreach r in 01 02 03 04   10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
			replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2014 {
	foreach r in 01 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2015 {
	foreach r in 01 02 03 04 05 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}	
	ren contract conacct1
	replace conacct=conacct1 if conacct1!=""
		ren classificationcode class
		destring conacct year month, replace force
	*	duplicates drop conacct year month, force
		drop if conacct==.

	replace type=var24 if type=="" & var24!=""
	replace type=lower(type)
	replace title=lower(title)

	keep type class conacct year month resolution issue typecode title
	replace resolution=lower(resolution)
	replace issue=lower(issue)
	format resol %100s


	
	g ugl_r=regexm(resolution,"ugl")==1
		replace ugl_r=0 if regexm(resolution," no ")==1
	g leak_r=regexm(resolution,"leak")==1
		replace leak_r=0 if regexm(resolution," no ")==1

	replace ugl_r = 0  if regexm(class,"WAAV")==1
	replace leak_r= 0 if regexm(class,"WAAV")==1

keep if ugl_r==1 | leak_r==1
g date= ym(year,month)
keep conacct date
duplicates drop conacct date, force

save "${temp}demand_leak.dta", replace


use "${temp}demand_leak.dta", clear

keep conacct 
duplicates drop conacct, force

gentable ln 

* browse if regexm(resolution,"ugl")==1
* browse if ugl_r==1
* browse if leak_r==1

	* 	replace leak_r=0 if regexm(class,"WAAV")==1
	* g ugl_i=regexm(issue,"ugl")==1
	* 	replace ugl_i=0 if regexm(issue,"no ugl")==1
	* g leak_i=regexm(issue,"leak")==1
	* 	replace leak_i=0 if regexm(issue,"no leak")==1
	* 	replace leak_i=0 if regexm(class,"WAAV")==1
  *   g break_i = ( regexm(issue,"break")==1 | regexm(issue,"damage")==1 ) & regexm(issue,"pipe")==1
		* replace break_i=0 if regexm(class,"WAAV")==1
  *   g break_r = ( regexm(resolution,"break")==1 | regexm(resolution,"damage")==1 ) & regexm(resolution,"pipe")==1
		* replace break_r=0 if regexm(class,"WAAV")==1
		
	* g vertical_r=regexm(resolution,"vertical")==1
	* g vertical_i = regexm(issue,"vertical")==1

	* 	g LEAK_OLD=(ugl_r==1 | leak_r==1 | ugl_i==1 | leak_i==1)
	* 	g VERTICAL=(vertical_r==1 | vertical_i==1)
	* 	g BILL=regexm(resolution,"excessive")==1 | regexm(issue,"excessive")==1 | typecode=="B0001" | regexm(type,"excessive")==1 | regexm(title,"excessive")==1  

	* g LEAK=(ugl_r==1 | leak_r==1 | ugl_i==1 | leak_i==1 | break_i==1 | break_r==1 | vertical_r==1 | vertical_i==1)
	







import delimited using "${data}gis/TELEM_PMP/Central A PMPs 2012 to present under.csv", delimiter(",") clear

ren pmpnames pmp
global zc=630

forvalues r=2(1)65 {
ren v`r' ps$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long ps, i(pmp) j(date)
	drop if pmp==""
	drop if ps==.

save "${temp}pmp_ca.dta", replace


import delimited using "${data}gis/TELEM_PMP/Central B PMPs 2012 to present under.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=630

forvalues r=2(1)64 {
ren v`r' ps$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long ps, i(pmp) j(date)
	drop if pmp==""
	drop if ps==.

save "${temp}pmp_cb.dta", replace



import delimited using "${data}gis/TELEM_PMP/North District PMPs 2012 to present under.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=628

forvalues r=2(1)38 {
ren v`r' ps$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long ps, i(pmp) j(date)
	drop if pmp==""
	drop if ps==.

save "${temp}pmp_nd.dta", replace


import delimited using "${data}gis/TELEM_PMP/South District PMPs 2012 to present under.csv", delimiter(",") clear

ren pmp pmp
destring v*, replace force
global zc=630

forvalues r=2(1)65 {
ren v`r' ps$zc
global zc = $zc + 1
}

replace pmp = subinstr(pmp,"\","",.)
replace pmp = subinstr(pmp,"PISYSTEMSVR","",.)
replace pmp = regexs(1) if regexm(pmp,"(.+-[0-9]) ")

duplicates drop pmp, force
	reshape long ps, i(pmp) j(date)
	drop if pmp==""
	drop if ps==.

save "${temp}pmp_sd.dta", replace

use "${temp}pmp_ca.dta", clear
	append using "${temp}pmp_cb.dta"
	append using "${temp}pmp_nd.dta"
	append using "${temp}pmp_sd.dta"
	keep if date<=664
save "${temp}pmp_under_total.dta", replace





import delimited using "${data}gis/TELEM_PMP/central_a.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=630

forvalues r=2(1)65 {
ren v`r' pmean$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long pmean, i(pmp) j(date)
	drop if pmp==""
	drop if pmean==.

save "${temp}pmp_ca_mean.dta", replace




import delimited using "${data}gis/TELEM_PMP/central_b.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=630

forvalues r=2(1)64 {
ren v`r' pmean$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long pmean, i(pmp) j(date)
	drop if pmp==""
	drop if pmean==.

save "${temp}pmp_cb_mean.dta", replace



import delimited using "${data}gis/TELEM_PMP/north.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=628

forvalues r=2(1)41 {
ren v`r' pmean$zc
global zc = $zc + 1
}

replace pmp = regexs(1) if regexm(pmp,"^(.+-[0-9]) ")
duplicates drop pmp, force
	reshape long pmean, i(pmp) j(date)
	drop if pmp==""
	drop if pmean==.

save "${temp}pmp_nd_mean.dta", replace


import delimited using "${data}gis/TELEM_PMP/south.csv", delimiter(",") clear

drop if _n<=3
ren v1 pmp
destring v*, replace force
global zc=630

forvalues r=2(1)36 {
ren v`r' pmean$zc
global zc = $zc + 1
}

replace pmp = subinstr(pmp,"\","",.)
replace pmp = subinstr(pmp,"PISYSTEMSVR","",.)
replace pmp = regexs(1) if regexm(pmp,"(.+-[0-9]) ")

duplicates drop pmp, force
	reshape long pmean, i(pmp) j(date)
	drop if pmp==""
	drop if pmean==.
	drop v*
save "${temp}pmp_sd_mean.dta", replace



use "${temp}pmp_ca_mean.dta", clear
	append using "${temp}pmp_cb_mean.dta"
	append using "${temp}pmp_nd_mean.dta"
	append using "${temp}pmp_sd_mean.dta"
	keep if date<=664
save "${temp}pmp_mean_total.dta", replace


use  "${temp}pmp_mean_total.dta", clear

	merge 1:1 pmp date using "${temp}pmp_under_total.dta"
	keep if _merge==3
	drop _merge

	g pmp1 = regexs(1) if regexm(pmp,"^[0-9][0-9]-(.+)-PM-.+")
	drop pmp
	ren pmp1 pmp

	duplicates drop pmp date, force
save "${temp}pmp_total.dta", replace

keep pmp
duplicates drop pmp, force
save "${temp}pmp_total_temp.dta", replace




odbc load, exec("SELECT OGC_FID, pmp_id FROM pmp")  dsn("phil") clear
 
g pmp=""
foreach v in CAN CAS CAV CLP COM FRV MAN MLP MUN NOV PAM PQE QUI RSV SAM SMA TDO VAL {
	replace pmp = regexs(1) if regexm(pmp_id,"^.+(`v'[0-9][0-9][A-Z])") & pmp==""
}

merge m:1 pmp using "${temp}pmp_total_temp.dta"
	keep if _merge==3
	drop _merge

keep OGC_FID pmp

gentable pmp_link


*** RUN DISTANCE TO PMP HERE ! *** in PRESSURE.py !!!!



odbc load, exec("SELECT P.conacct, P.distance, PM.pmp  FROM pmp_dist AS P JOIN pmp_link AS PM ON P.OGC_FID = PM.OGC_FID ")  dsn("phil") clear
 
save "${temp}pmp_distance_link.dta", replace

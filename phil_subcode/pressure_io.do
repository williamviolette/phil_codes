* pressure_io.do



* use "${data}backup_cbms/2005/pasay_hh_fin.dta", clear


* use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear



use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear

	g datest=string(int_date,"%18.0g")
	g month = substr(datest,1,1) if length(datest)==7
	replace month = substr(datest,1,2) if length(datest)==8
	g year = substr(datest,-4,4)
	destring month year, replace
	g date=ym(year,month)

duplicates drop hcn, force

* keep if source_water == 1

ren source_water source_water
ren water water
ren ave_water bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

keep hcn source_water water bill hhsize hhemp inc ofw year brgy low_wsupp

replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_pressure_2011.dta", replace


use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear

	g datest=string(int_date,"%18.0g")
	g month = substr(datest,1,1) if length(datest)==7
	replace month = substr(datest,1,2) if length(datest)==8
	g year = substr(datest,-4,4)
	destring month year, replace
	g date=ym(year,month)

ren water water
	replace water_price=. if water_price==0
	replace water_price= water_price/100

ren water_price bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

keep hcn water bill hhsize hhemp inc ofw year brgy

duplicates drop hcn, force


replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_pressure_2008.dta", replace




use "${temp}cbms_temp_pressure_2011.dta", clear
	append using "${temp}cbms_temp_pressure_2008.dta"

	merge m:1 year brgy using  "${temp}brgy_year_water.dta", keep(1 3) nogen


g pd= water==1
g sd = water==2

areg pd YF i.year, a(hcn) cluster(brgy) r
areg sd YF i.year, a(hcn) cluster(brgy) r


areg hhsize YF i.year, a(hcn) cluster(brgy) r
areg hhsize  YF i.year, a(hcn) cluster(hcn) r






foreach v in 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
use "${data}list of business 2003-2015/b`v'.dta", clear

g water = regexm(nature,"Water")==1
g whole = regexm(nature,"Whole")==1
g sari = regexm(nature,"Sari")==1 | regexm(nature,"Snack")
g retail=regexm(nature,"Retail")==1
g tot=1

foreach var of varlist water whole sari retail tot {
	gegen `var'_b = sum(`var'), by(brgyno)
	drop `var'
}
gegen tb=tag(brgyno)
keep if tb==1
drop tb
ren brgyno brgy
keep year brgy *_b

save "${temp}b_`v'.dta", replace

}

use "${temp}b_2003.dta", clear
erase "${temp}b_2003.dta"
foreach v in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
	append using "${temp}b_`v'.dta"
	erase "${temp}b_`v'.dta"
}

save "${temp}b_tot.dta", replace




use "${data}paws/clean/full_sample_b_1.dta", clear
* merge m:1 conacct using "${temp}conacct_rate.dta"

g no_flow=flow_noon_6=="Wala"
g yes_flow = flow_noon_6=="Malakas"
destring flow_hrs, replace force
replace flow_hrs = . if flow_hrs==0

g yr=substr(interview_completion_date,1,4)
g mn=substr(interview_completion_date,6,2)
destring yr mn, replace force
g date=ym(yr,mn)

g year = yr

gegen NF = mean(no_flow), by(barangay_id year)
gegen YF = mean(yes_flow), by(barangay_id year)
gegen FH = mean(flow_hrs), by(barangay_id year)
duplicates drop barangay_id year, force

g bst=string(barangay_id,"%12.0g")
g city=substr(bst,1,4)
keep if city=="7605"
g brgy=substr(bst,-3,3)
destring brgy, replace force

keep year brgy NF YF FH

save "${temp}brgy_year_water.dta", replace






use "${temp}b_tot.dta", clear

	merge 1:1 year brgy using "${temp}brgy_year_water.dta", keep(1 3) nogen


sort brgy year
foreach var of varlist NF YF FH {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/3 {
		by brgy: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by brgy: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
}


areg tot_b NF YF  i.year, a(brgy) cluster(brgy)

areg water_b NF YF  i.year, a(brgy) cluster(brgy)

areg sari_b  NF YF  i.year, a(brgy) cluster(brgy)

areg retail_b NF YF  i.year, a(brgy) cluster(brgy)











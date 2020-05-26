* pressure_io.do



* use "${data}backup_cbms/2005/pasay_hh_fin.dta", clear


* use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear

use "${temp}MMR_total.dta", clear
	merge m:1 bar using "${temp}brgy_pipe_date.dta", keep(1 3) nogen
g date=ym(year,month)
gegen bg=group(bar)
tsset bg date
tsfill, full
replace M=0 if M==.
drop bar year month
foreach var of varlist year_inst length shr {
gegen `var'_max=max(`var'), by(bg)
drop `var'
ren `var'_max `var'
}
g dated=dofm(date)
g year=year(dated)
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10
g Mp=M>0 & M<.
gegen Mps=sum(Mp), by(bg)
g post = year>year_inst
areg MS post i.year if yt==1 & MS<200 & MS>0, a(bg) cluster(bg) r
areg M post i.year if M<10 & M>0, a(bg) cluster(bg) r
gegen MS = sum(M), by(year bg)
gegen yt=tag(bg year)
areg MS i.pT i.year if yt==1 & Mps>=40, a(bg) cluster(bg) r
coefplot, vertical keep(*pT*)
areg M i.pT i.date , a(bg) cluster(bg) r
coefplot, vertical keep(*pT*)
g post = year>year_inst & year_inst>2009
areg M post i.year, a(bg) cluster(bg) r
areg M post i.year if year_inst>2009 & MS>40, a(bg) cluster(bg) r
areg my i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical










use "${temp}paws_aib.dta", clear

	replace year=2008 if year<2008

		merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
			drop ba zone_code dc-bus
		merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

	g o=1
	gegen ys=sum(o), by(year_inst barangay_id)
	gegen mys=max(ys), by(barangay_id)
	keep if ys==mys

	keep year_inst barangay_id
	duplicates drop barangay_id, force

	g bst=string(barangay_id,"%12.0g")
	g city=substr(bst,1,4)
	keep if city=="7605"
	g brgy=substr(bst,-3,3)
	destring brgy, replace force
	keep brgy year_inst
save "${temp}pipes_paws_cbms.dta", replace



* use "${data}backup_cbms/2005/pasay_mem_fin_1.dta", clear
* use "${data}backup_cbms/2005/pasay_hh_fin_1.dta", clear


* use "${data}backup_cbms/2011/pasay_final2011_mem_1.dta", clear


use "${data}backup_cbms/2011/pasay_final2011_hh_1.dta", clear

	g datest=string(int_date,"%18.0g")
	g month = substr(datest,1,1) if length(datest)==7
	replace month = substr(datest,1,2) if length(datest)==8
	g year = substr(datest,-4,4)
	destring month year, replace
	g date=ym(year,month)

duplicates drop hcn, force

* keep if source_water == 1
g sick=gsick==1

ren source_water source_water
ren water water
ren ave_water bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

g elec_price =. if elec_bill==0
replace elec_price =elec_bill/100
replace elec_price=. if elec_price>6000


keep hcn source_water water bill hhsize hhemp inc ofw year brgy low_wsupp sick elec_price water_supply s_*

replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_pressure_2011.dta", replace




* use "${data}backup_cbms/2008/pasay_memfinal08_1.dta", clear

use "${data}backup_cbms/2008/pasay_hhfinal08_1.dta", clear

	g datest=string(int_date,"%18.0g")
	g month = substr(datest,1,1) if length(datest)==7
	replace month = substr(datest,1,2) if length(datest)==8
	g year = substr(datest,-4,4)
	destring month year, replace
	g date=ym(year,month)

ren water water
	replace water_price=. if water_price==0
	replace water_price= water_price/100

g elec_price =. if elec_bill==0
replace elec_price =elec_bill/100
replace elec_price=. if elec_price>6000

ren water_price bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

g sick = wsick==1

keep hcn water bill elec_price hhsize hhemp inc ofw year brgy sick

duplicates drop hcn, force


replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_pressure_2008.dta", replace




use "${temp}cbms_temp_pressure_2011.dta", clear
g wave=2
	append using "${temp}cbms_temp_pressure_2008.dta"
replace wave=1 if wave==.


	merge m:1 brgy using "${temp}pipes_paws_cbms.dta", keep(1 3) nogen




g post = year_inst>=2009 & year_inst<=2011 & year>year_inst

g post_placebo = year_inst<2007 & year>2009

g pd= water==1
g sd = water==2
g o=1
gegen ws=sum(o), by(water)

g w11_id=water if wave==2
gegen w11=max(w11_id), by(hcn)
g w08_id=water if wave==1
gegen w08=max(w08_id), by(hcn)
gegen minc=mean(inc), by(hcn)

g ww=water==1 | water==2

* foreach var of varlist s_* {
* 	g `var'_id = 0 if `var'!=.
* 	replace `var'_id = 1 if `var'==1
* }

g water_increase = 0 if water_supply!=.
replace water_increase=1 if water_supply==2

areg ww post hhsize inc hhemp i.year, a(brgy) cluster(brgy) r


areg elec_price post hhsize inc hhemp i.year, a(brgy) cluster(brgy) r


areg elec_price post  i.year, a(hcn) cluster(brgy) r
areg elec_price post  i.year, a(brgy) cluster(brgy) r


reg water_increase post, cluster(brgy) r


* foreach var of varlist s_*_id {
* areg `var' water_increase, cluster(brgy) r a(brgy)
* }



areg elec_price post hhsize inc hhemp i.year if w11==1 , a(hcn) cluster(brgy) r





areg elec_price i.water hhsize inc hhemp i.year , a(brgy) cluster(brgy) r





areg elec_price post i.year if minc>15000, a(brgy) cluster(brgy) r
areg bill post  i.year , a(brgy) cluster(brgy) r



areg bill post hhsize inc hhemp i.year , a(brgy) cluster(brgy) r


areg bill post hhsize inc hhemp i.year if w11==1 | w11==14, a(brgy) cluster(brgy) r


areg bill post hhsize inc hhemp i.year, a(hcn) cluster(brgy) r



areg bill post i.year if w11==1, a(hcn) cluster(brgy) r

areg bill post i.year if w11==14, a(hcn) cluster(brgy) r



areg bill post hhsize inc hhemp i.year if , a(brgy) cluster(brgy) r


areg sick post hhsize inc hhemp  i.year, a(hcn) cluster(brgy) r


areg sick post hhsize inc hhemp  i.year, a(hcn) cluster(brgy) r
areg sick post hhsize inc hhemp  i.year if w11==1 | w11==2, a(hcn) cluster(brgy) r
areg sick post hhsize inc hhemp  i.year if w11==14, a(hcn) cluster(brgy) r


areg sick post hhsize inc hhemp  i.year, a(hcn) cluster(brgy) r




areg ww post_placebo i.year, a(brgy) cluster(brgy) r







use "${temp}cbms_temp_pressure_2011.dta", clear
	append using "${temp}cbms_temp_pressure_2008.dta"


	merge m:1 year brgy using  "${temp}brgy_year_water.dta", keep(1 3) nogen


g pd= water==1
g sd = water==2

g ww=water==1 | water==2

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











* pressure_analysis_geo_het_clean.do

*** YES paws 
 * MRUs:   	 - over 10 early accounts
 		*	 - at least 10 paws respondents FOR WAVES 4 AND 5 (to calculate SHH)  *** BUT : SHH is key for calculating PER HH demand
 		*    - HAS a pipe improvement BEFORE paws survey!
 	 	* 	 - (or NOT: can also calculate density with MRU area) match with Barangay demographics

 * PAWS set
 		*    - only/all PAWS accounts (need flexible expansion)

*** PAWS SET:
	* - only waves 4 and 5 (FOR SHH)

use "${data}paws/clean/full_sample_b_1.dta", clear
		keep if wave>3
		g year=substr(interview,1,4)
		destring year, replace force
		replace year = 2008 if year<=2008 
		destring shr_hh_extra, replace force
			g SHH = shr_hh_extra
			replace SHH=. if SHH>10
			replace SHH = 0 if SHH==.
			replace SHH = SHH+1
		keep if SHH!=.

		g single = regexm(house,"Single house")==1
		g apartment = regexm(house,"Apartment")==1
		g sub=regexm(house,"Subdivided")==1

		destring job, replace force
		g low_skill = job==1 | job==0

		destring hhsize, replace force
		replace hhsize=. if hhsize>12
		destring hhemp, replace force
		replace hhemp=. if hhemp>12

		g emp_shr=hhemp/hhsize

	sort conacct wave
	by conacct: g tn=_n
	gegen tnm=max(tn), by(conacct)
	keep if tn==tnm
	keep conacct SHH year single apartment sub emp_shr hhsize hhemp low_skill
save "${temp}paws_conacct_ep.dta", replace

**** PAWS WITH AT LEAST 12 MONTHS OF DATA
use "${temp}bill_paws_full.dta", clear
	g cnm=c!=.
	gegen cnms=sum(cnm), by(conacct)
	drop if cnms<12
	keep conacct
	duplicates drop conacct, force
save "${temp}paws_conacct_over_12_months.dta", replace	

*** ONLY MRUs with AT LEAST 10 PAWS *** CONACCT_RATE DROPS 2% of OBSERVATIONS, WHICH MIGHT MATTER LATER
use "${temp}paws_conacct_ep.dta", clear
	merge 1:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	merge 1:1 conacct using "${temp}paws_conacct_over_12_months.dta", keep(3) nogen
	bys mru: g mN=_N
	keep if mN>=10
	gegen shhm=mean(SHH), by(mru)
	gegen max_year=max(year), by(mru)
	duplicates drop mru, force
	keep mru max_year shhm
save "${temp}paws_mru_ep.dta", replace


*** MRU SET:
use "${temp}conacct_rate.dta", clear
	drop if ba==1700
		keep datec mru ba
	g o=1
	gegen new=sum(o), by(mru datec)
	g pre_id= 1 if datec<550
	gegen pres=sum(pre_id), by(mru)
	keep if pres>=10
	keep mru ba
	duplicates drop mru, force
		*** AT LEAST 10 PAWS! ***
		merge 1:1 mru using "${temp}paws_mru_ep.dta", keep(3) nogen
		*** KEEP IF PIPE CHANGE OCCURS BEFORE PAWS ***
		merge 1:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	drop if year_inst>max_year
	keep mru ba max_year shhm
save "${temp}mru_set_ep.dta", replace


use "${temp}activem.dta", clear
	keep if date==660
	keep mru aressum 
		fmerge m:1 mru using  "${temp}mru_set_ep.dta", keep(3) nogen
	g pop = aressum*shhm
	keep mru pop
save "${temp}mru_pop.dta", replace






use "${temp}bill_paws_full.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop ba zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using  "${temp}mru_set_ep.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge m:1 conacct using "${temp}paws_conacct_ep.dta", keep(3) nogen
	drop year
	fmerge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen
	fmerge m:1 mru using "${temp}mru_area.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}mru_pop.dta", keep(3) nogen


**** TRY COMPOSITION EFFECT! ****
* g datedc=dofm(datec)
* g yearc=year(datedc)
* drop datedc

* g pTc = yearc-year_inst
* replace pTc=1000 if pTc>6 | pTc<-6
* replace pTc=pTc+10
* replace pTc=1010 if yearc==2005

* gegen tc = tag(conacct)

* gegen cm = mean(c), by(conacct)


* reg cm i.pTc yearc i.ba if tc==1 & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* reg low_skill i.pTc yearc i.ba if tc==1 & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* reg sub i.pTc yearc i.ba if tc==1  & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* * reg apartment i.pTc yearc i.ba if tc==1  & (pTc<=12 | pTc>100), cluster(conacct)
* *  	coefplot, vertical keep(*pTc*)

* reg hhemp i.pTc yearc i.ba if tc==1 & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* reg hhsize i.pTc yearc i.ba if tc==1 & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)
* reg emp_shr i.pTc yearc i.ba if tc==1 & (pTc<=12 | pTc>100), cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* xi: reg apartment i.pTc i.yearc*i.ba if pTc<=11
* 	coefplot, vertical keep(*pTc*)



sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g post_rs = date>date_rs & date<.

replace c=. if c>200
replace amount=. if amount<10 | amount>5000

g dated=dofm(date)
g year=year(dated)

g p = amount/c
sum p, detail
replace p = . if p>`=r(p99)'

g pmiss=p==.

sort pmiss year c class
by   pmiss year c class: g cn=_n

g p_res_set = p if cn==1 & c<=80 & class==1
g p_sem_set = p if cn==1 & c<=80 & class==2

reg p_res_set c
mat eres=e(b)
g pi_res = eres[1,2]
g pr_res = eres[1,1]

reg p_sem_set c
mat esem=e(b)
g pi_sem = esem[1,2]
g pr_sem = esem[1,1]

g pi = pi_res if class==1
replace pi = pi_sem if class==2
g pr = pr_res if class==1
replace pr = pr_sem if class==2

g post = year>=year_inst & year_inst<.

g cadj = c/SHH

drop if cadj==.
drop if pi==.
drop if post==.
drop if date==.

*** HETEROGENEITY BY AFTER PIPE FIX!?
g pi_post = pi*post
areg cadj pi post pi_post i.date, a(conacct) cluster(conacct)

******* LESS SENSITIVE TO PRICE AFTER!

areg cadj pi post i.date, a(conacct)
predict fe, xbd

mat bb=e(b)
g alpha1hat = -bb[1,1]
g thetahat = bb[1,2] 
g alpha0_1hat = fe + alpha1hat*pi - thetahat*post

g denom = (2*alpha1hat*pr_res-1)

g alpha0_1 = -alpha0_1hat/denom
g alpha1 = -alpha1hat/denom
g theta  = -thetahat/denom

gegen alpha0 = mean(alpha0_1), by(conacct)


* reg apartment i.pTc yearc i.ba if pTc<13, cluster(conacct)
*  	coefplot, vertical keep(*pTc*)

* reg SHH i.pTc yearc i.ba if pTc<13, cluster(conacct)
*  	coefplot, vertical keep(*pTc*)


xi: reg alpha0 i.pTc i.yearc*i.ba if pTc<13, cluster(conacct)
 	coefplot, vertical keep(*pTc*)



keep conacct mru pi_res pr_res alpha0 alpha1 theta SHH single apartment datec
order conacct mru pi_res pr_res alpha0 alpha1 theta SHH single apartment datec


	duplicates drop conacct, force
	expand SHH
	sort conacct
	by conacct: g hnum = _n
sort mru conacct hnum

export delimited "${temp}conacct_sample.csv", delimiter(",") replace

preserve 
		keep mru
		duplicates drop mru, force
	save "${temp}mru_sample.dta", replace
restore

preserve
	keep mru SHH single apartment popd
	foreach var of varlist SHH single apartment popd {
		gegen `var'M=mean(`var'), by(mru)
		drop `var'
	}
	duplicates drop mru, force
	save "${temp}mru_demo1.dta", replace
restore





use "${temp}activem.dta", clear
	
	fmerge m:1 mru using  "${temp}mru_set_ep.dta", keep(3) nogen
	*** JUST TO DOUBLECHECK ***
	fmerge m:1 mru using "${temp}mru_sample.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)
g month=month(dated)
* keep if year<=2011

 * gegen nc = mean(aressum), by(year mru)
keep if month==7
ren aressum nc
	gegen ym=tag(year mru)
	keep if ym==1
	drop ym

	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

g post = year>=year_inst

replace nc=nc*shhm

replace year = year-2000

reg nc post i.ba year, cluster(mru) r

* tab ba
replace ba = 800 if ba>=800
egen bag = group(ba)
drop ba
ren bag ba
sort mru year
keep   mru year post ba nc
order  mru year post ba nc
export delimited "${temp}mru_sample.csv", delimiter(",") replace

merge m:1 mru using "${temp}mru_demo1.dta", keep(3) nogen


reg nc post i.ba year, cluster(mru) r

foreach var of varlist *M {
	g `var'_post = `var'*post
}

g ln_nc = log(nc)

reg nc post SHHM popdM singleM apartmentM *_post i.ba year, cluster(mru) r
areg nc post SHHM popdM singleM apartmentM *_post i.ba year, cluster(mru) r a(mru)

reg ln_nc post SHHM popdM singleM apartmentM *_post i.ba year, cluster(mru) r
areg ln_nc post SHHM popdM singleM apartmentM  *_post i.ba year, cluster(mru) r a(mru)


reg nc post  singleM apartmentM singleM_post apartmentM_post i.ba year, cluster(mru) r
areg nc post  singleM apartmentM   singleM_post apartmentM_post i.ba year, cluster(mru) r a(mru)


reg ln_nc post  singleM apartmentM singleM_post apartmentM_post i.ba year, cluster(mru) r
areg ln_nc post  singleM apartmentM   singleM_post apartmentM_post i.ba year, cluster(mru) r a(mru)




reg ln_nc post SHHM singleM apartmentM SHHM_post singleM_post apartmentM_post i.ba year, cluster(mru) r
areg ln_nc post SHHM singleM apartmentM  SHHM_post singleM_post apartmentM_post i.ba year, cluster(mru) r a(mru)



areg nc post *_post i.ba year, cluster(mru) r a(mru)
areg nc post *_post i.ba year if year<=2011, cluster(mru) r a(mru)

areg ln_nc post *_post i.ba year if year<=2011, cluster(mru) r a(mru)
areg ln_nc post *_post i.ba year , cluster(mru) r a(mru)




reg nc *M post *_post i.ba year, cluster(mru) r



reg ln_nc post *_post i.ba year, cluster(mru) r

reg ln_nc *M post *_post i.ba year, cluster(mru) r



* areg cadj padj post i.date, a(conacct) cluster(mru) r











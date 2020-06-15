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
	sort conacct wave
	by conacct: g tn=_n
	gegen tnm=max(tn), by(conacct)
	keep if tn==tnm
	keep conacct SHH year
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





use "${temp}bill_paws_full.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop ba zone_code dc-bus
	fmerge m:1 mru using  "${temp}mru_set_ep.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge m:1 conacct using "${temp}paws_conacct_ep.dta", keep(3) nogen
	drop year
	merge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g post_rs = date>date_rs & date<.

replace c=. if c>200
replace amount=. if amount<10 | amount>5000

g p = amount/c
sum p, detail
replace p = . if p>`=r(p99)'

sum c, detail
global c_25p=`=r(p25)'
global c_50p=`=r(p50)'
global c_75p=`=r(p75)'

	sum p if c<$c_25p & class==1, detail
		global p_q1=`=r(mean)'
	sum p if c>=$c_25p & c<$c_50p & class==1, detail
		global p_q2=`=r(mean)'
	sum p if c>=$c_50p & c<$c_75p & class==1, detail
		global p_q3=`=r(mean)'
	sum p if c>=$c_75p & class==1, detail
		global p_q4=`=r(mean)'

g p_r = ($p_q1 + $p_q2 + $p_q3 + $p_q4)/4

	sum p if c<$c_25p & class==2, detail
		global p2_q1=`=r(mean)'
	sum p if c>=$c_25p & c<$c_50p & class==2, detail
		global p2_q2=`=r(mean)'
	sum p if c>=$c_50p & c<$c_75p & class==2, detail
		global p2_q3=`=r(mean)'
	sum p if c>=$c_75p & class==2, detail
		global p2_q4=`=r(mean)'

g p_s = ($p2_q1 + $p2_q2 + $p2_q3 + $p2_q4)/4

g pm = p_r if class==1
replace pm = p_s if class==2
g padj = p_r
replace padj = p_s if post_rs==1

g dated=dofm(date)
g year=year(dated)

g post = year>=year_inst & year_inst<.

g cadj = c/SHH

drop if cadj==.
areg cadj pm   post i.date, a(conacct)
predict fe, xbd

mat bb=e(b)
g alpha1 = bb[1,1]
g theta = bb[1,2] 
g alpha0_1 = fe - alpha1*pm - theta*post

gegen alpha0 = mean(alpha0_1), by(conacct)

keep conacct mru p_r alpha0 alpha1 theta SHH
order conacct mru p_r alpha0 alpha1 theta SHH
	duplicates drop conacct, force
	expand SHH
	sort conacct
	by conacct: g hnum = _n
sort mru conacct hnum

export delimited "${temp}conacct_sample.csv", delimiter(",") replace
	keep mru
	duplicates drop mru, force
save "${temp}mru_sample.dta", replace





use "${temp}activem.dta", clear
	
	fmerge m:1 mru using  "${temp}mru_set_ep.dta", keep(3) nogen
	*** JUST TO DOUBLECHECK ***
	fmerge m:1 mru using "${temp}mru_sample.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)
g month=month(dated)
keep if year<=2011

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
keep mru year post ba nc
order  mru year post ba nc
export delimited "${temp}mru_sample.csv", delimiter(",") replace




* areg cadj padj post i.date, a(conacct) cluster(mru) r







* gegen class_max=max(class), by(conacct)
* gegen class_min=min(class), by(conacct)

* drop if class_max>=3

* sort conacct date
* by conacct: replace class=class[_n-1] if class==.










use "${temp}activem.dta", clear

	merge 1:1 mru date using "${temp}dcm.dta", keep(1 3) nogen
	merge 1:1 mru date using "${temp}billm.dta", keep(1 3) nogen
	merge 1:1 mru date using "${temp}pay.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_set_ep.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
	merge 1:1 mru date using  "${temp}mru_inst.dta", keep(1 3) nogen
g dated=dofm(date)
g year=year(dated)

keep if year<=max_year

g pT = year-year_inst
replace pT=1000 if pT>12 | pT<-6
gegen min_pT=min(pT), by(mru)
gegen max_pT=max(pT), by(mru)
replace pT=pT+10
replace pT=1 if pT==1010

foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	gegen `var'_y=mean(`var'), by(mru year)
}
foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	gegen `var'_M=mean(`var'), by(pT)
}
g oset = min_pT<=-3 & max_pT>=3 & max_pT<1000
foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	g `var'_o = `var' if oset==1
	gegen `var'_O=mean(`var'_o), by(pT)
	drop `var'_o
}


gegen yt   = tag(mru year)
gegen ptt=tag(pT)

g post = year>year_inst
g posta=year>=year_inst
g p1 = year>=year_inst & year<=year_inst+2
g p2 = year>year_inst+2 & year<.
g treat = min_pT<0
g post_treat=post*treat


twoway scatter pay_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter payc_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter pays_M pT if		 	ptt==1 & pT>=6 & pT<=16

twoway scatter asum_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter cpanel_M pT if 		ptt==1 & pT>=6 & pT<=16
sum asum_M if pT==10
sum asum_M if pT==10


twoway scatter asum_M pT if		 	ptt==1 & pT>=6 & pT<=16


sum aressum if pT==9  | pT==8
sum aressum if pT==11 | pT==12


reg aressum post i.year if pT>=8 & pT<=12 & yt==1


reg aressum_y post year i.ba if yt==1, cluster(mru) r 

























use "${temp}bill_paws_full.dta", clear
		tsset conacct date
		tsfill, full
	merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
	merge m:1 mru 	  using "${temp}mru_set.dta", keep(3) nogen

		gegen mt=tag(mru)
		count if mt==1


  disp  52000/2800



	g date_m=date if c!=.
	gegen md=min(date_m), by(conacct)
	drop if date<md

replace c=. if c>200
gegen class_max=max(class), by(conacct)
gegen class_min=min(class), by(conacct)

drop if class_max>=3

sort conacct date
by conacct: replace class=class[_n-1] if class==.


sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)


g rs = date_rs!=.
g cnm=c!=.
g price_post = date>date_rs & date<.


gegen cnms=sum(cnm), by(conacct)
g DC = cnms<=48


cap drop T
g T = date-date_rs
replace T = 1000 if T<-36 | T>36
replace T = T+100

g TM = T==1100
g T1 = T
replace T1 = 0 if T==1100

g T2 = T1
replace T2 = 0 if T2>100

reg DC rs class_max



areg c price_post i.date, a(conacct)
predict fe, d



reg c price_post TM T1 T2 i.class_max i.class_min,  r

areg c price_post i.date, a(conacct)


areg c price_post i.date, a(conacct)


areg c i.T i.date, a(conacct)
coefplot, vertical keep(*T*)


* areg cnm i.T i.date, a(conacct)
* coefplot, vertical keep(*T*)
* reg c i.T
* coefplot, vertical keep(*T*)







use "${temp}paws_aib.dta", clear

replace year=2008 if year<2008

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
		drop ba zone_code dc-bus
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
	merge m:1 conacct using "${temp}ai_conacct.dta", keep(1 3) nogen
	g ai=nat_ill!=.
g post = 0 if  year<year_inst  & year_inst!=.
replace post = 1 if  year>=year_inst & year_inst!=.

replace age = 99 if age>99
replace me =. if me>5000
replace wrs=. if wrs>500
g well = wrs_type==2
replace well=. if wave==5
g rs = wrs_type==1

foreach var of varlist pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr pf_flow_compl pf_flow_qual pf_qual_flow {
	replace `var'=. if `var'==0 
	replace `var'=0 if `var'==2
}

g pT = year-year_inst
replace pT=1000 if pT>10 | pT<-4
gegen min_pT = min(pT), by(mru)
replace pT=pT+10
replace pT=1 if pT==1010

gegen yt=tag(mru year)
gegen yesy=mean(yes_flow), by(mru year)

foreach var of varlist yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp shr {
	gegen `var'_y=mean(`var'), by(mru year)
}

g o=1
gegen mru_c=sum(o), by(mru)
keep if mru_c>10

g low_class=sclass=="D" | sclass=="E"

g thh=hhsize
replace thh=hhsize+hho if hho!=.

foreach var of varlist sub single hhsize hhemp low_class thh {
	gegen `var'_mru = mean(`var'), by(mru)
	sum `var'_mru, detail
	g `var'_mruh = `var'_mru>`=r(mean)' & `var'_mru<.
}

reg  single age hhsize hhemp low_class 
areg single age hhsize hhemp low_class , a(mru)

reg low_class  single
reg low_class  single_mru

reg me i.hhsize i.hho
reg me i.hhsize i.hho i.year
areg me i.hhsize i.hho i.year age, a(mru)

reg well sub single age hhsize hhemp low_class 
xi: reg me single sub age hhsize hhemp i.sclass

* xi: areg yes_flow_y i.post*sub_mruh i.post*single_mruh i.year*i.ba  , a(mru) cluster(mru) r
* xi: areg no_flow_y i.post*sub_mruh i.post*single_mruh i.year*i.ba  , a(mru) cluster(mru) r
* xi: areg flow_hrs_y i.post*sub_mruh i.post*single_mruh i.year*i.ba  , a(mru) cluster(mru) r

keep mru *_mru *_mruh

duplicates drop mru, force

save "${temp}mru_house.dta", replace





use "${temp}activem.dta", clear

	merge 1:1 mru date using "${temp}dcm.dta", keep(1 3) nogen
	merge 1:1 mru date using "${temp}billm.dta", keep(1 3) nogen
	merge 1:1 mru date using "${temp}pay.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
	merge 1:1 mru date using  "${temp}mru_inst.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_house.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_demo.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>12 | pT<-6
gegen min_pT=min(pT), by(mru)
gegen max_pT=max(pT), by(mru)
replace pT=pT+10
replace pT=1 if pT==1010

foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	gegen `var'_y=mean(`var'), by(mru year)
}
foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	gegen `var'_M=mean(`var'), by(pT)
}
g oset = min_pT<=-3 & max_pT>=3 & max_pT<1000
foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct  minst mbnk mnapc pay pays payc {
	g `var'_o = `var' if oset==1
	gegen `var'_O=mean(`var'_o), by(pT)
	drop `var'_o
}


gegen yt   = tag(mru year)
gegen ptt  = tag(pT)

g post = year>year_inst
g posta=year>=year_inst
g p1 = year>=year_inst & year<=year_inst+2
g p2 = year>year_inst+2 & year<.
g treat = min_pT<0
g post_treat=post*treat

g ln_ay=log(aressum_y)
g ln_cmean=log(cmean)

g no_rent = 1-rent
g no_apt = 1-apartment

foreach var of varlist *_mruh *_mru single duplex apartment pop_density pop age hs_grad post_grad college_grad emp prof_emp low_emp pipe_shr well_peddler own rent squat  no_rent no_apt {
	cap drop `var'_post
	g `var'_post=`var'*post
}

g tot = thh_mru*aressum
g tot_pop=tot/pop
sum tot_pop if year==2008
sum tot_pop if year==2015

reg tot_pop posta pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year i.ba , cluster(mru) r

reg tot_pop posta  i.year i.ba , cluster(mru) r


reg aressum posta  i.year i.ba , cluster(mru) r

reg tot posta  i.year i.ba , cluster(mru) r

reg pop posta  i.year i.ba if tot_pop<4, cluster(mru) r


xi: areg tot_pop posta  i.year*i.ba  , cluster(mru) r a(mru)


* g aper=aressum/mru_area
* reg aper pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year if year==2009 | year==2008, cluster(mru) r


reg cmean pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year if year==2009 | year==2008, cluster(mru) r

xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1  &  pop_density<.25 , a(mru) cluster(mru) r 



xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1  , a(mru) cluster(mru) r 

xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  i.year*i.ba if yt==1  , a(mru) cluster(mru) r 



xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1  &  pop_density<.25 , a(mru) cluster(mru) r 

xi: areg ln_cmean post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1  &  pop_density<.25 , a(mru) cluster(mru) r 




xi: areg ln_ay post pop_density_post  single_post duplex_post  rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post i.year*i.ba if yt==1  &  pop_density<.25  , a(mru) cluster(mru) r 








xi: areg ln_ay post   i.year*i.ba if yt==1   , a(mru) cluster(mru) r 




xi: areg aressum_y post duplex_post apartment_post age_post college_grad_post prof_emp_post i.year*i.ba if yt==1   , a(mru) cluster(mru) r 


xi: areg aressum_y post *_mru_post i.year*i.ba if yt==1   , a(mru) cluster(mru) r 




xi: areg aressum_y post i.year*i.ba if yt==1   , a(mru) cluster(mru) r 

xi: areg ln_ay post i.year*i.ba if yt==1   , a(mru) cluster(mru) r 

xi: areg ln_ay i.post*i.sub_mruh i.post*i.single_mruh i.year*i.ba if yt==1   , a(mru) cluster(mru) r 



xi: areg aressum_y i.pT i.year*i.ba if yt==1   , a(mru) cluster(mru) r 
 	coefplot, keep(*pT*) vertical

xi: areg aressum_y i.pT i.year*i.ba if yt==1 & sub_mruh==1   , a(mru) cluster(mru) r 
 	coefplot, keep(*pT*) vertical


xi: areg aressum_y i.pT i.year*i.ba if yt==1 & sub_mruh==0   , a(mru) cluster(mru) r 
 	coefplot, keep(*pT*) vertical






twoway scatter pay_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter payc_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter pays_M pT if		 	ptt==1 & pT>=6 & pT<=16

twoway scatter asum_M pT if		 	ptt==1 & pT>=6 & pT<=16
twoway scatter cpanel_M pT if 		ptt==1 & pT>=6 & pT<=16
sum asum_M if pT==10
sum asum_M if pT==10


* twoway scatter csumlow_M pT if 		ptt==1 & pT>=6 & pT<=16
* twoway scatter clow_M pT if 		ptt==1 & pT>=6 & pT<=16
* twoway scatter cmean_M pT if 		ptt==1 & pT>=6 & pT<=16
* twoway scatter asum_M pT if		 	ptt==1 & pT>=6 & pT<=30
* twoway scatter clow_M pT if 		ptt==1 

twoway scatter cpanel_M pT if 		ptt==1 





* areg aressum_y i.pT i.year if yt==1   , a(mru) cluster(mru) r 
* 	coefplot, keep(*pT*) vertical
* graph export "${temp}aressum_y_year.pdf", as(pdf) replace











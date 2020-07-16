* pressure_analysis_geo_het_clean.do



**** ARE THE READINGS CORRELATED*!? YES but not CrazY!
* use "${temp}rem.dta", clear
* merge m:1 mru using "${temp}mru_set_big.dta", keep(3) nogen
* merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
* g dated=dofm(date)
* g year=year(dated)
* g pT = year-year_inst
* replace pT=1000 if pT>6 | pT<-6
* replace pT=pT+10
* replace pT=1 if pT==1010

* gegen dmm=mean(rem), by(pT)
* gegen tt=tag(pT)
* twoway scatter dmm pT if tt==1

* xi: areg rem i.pT i.year*i.ba, a(mru)  r
* 	coefplot, vertical keep(*pT*)
* xi: areg reme i.pT i.year*i.ba, a(mru)  r
* 	coefplot, vertical keep(*pT*)


**** ARE THE CONNECTIONS TOO CLOSE!? **** NOT! for mruset!
* use "${temp}conacct_rate.dta", clear
* 	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
* 	merge 1:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen

* g dated=dofm(datec)
* g year=year(dated)

* g pT = year-year_inst
* replace pT=1000 if pT>6 | pT<-6
* replace pT=pT+10
* replace pT=1 if pT==1010
* gegen dmm=mean(distance), by(pT)
* gegen tt=tag(pT)
* twoway scatter dmm pT if tt==1
* xi: areg distance i.pT i.year*i.ba, a(pipe_id) cl(pipe_id) r
* coefplot, vertical keep(*pT*)

**** ARE THE CONNECTIONS CLOSE TO PRIMARY PIPE?!? **** NOT! for mruset!
* use "${temp}conacct_rate.dta", clear
* 	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
* 	merge 1:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen
* 		ren distance distance3
* 		ren year_inst year_inst3
* 		ren pipe_id pipe_id3
* 	merge 1:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(3) nogen
* 		drop year_inst pipe_id
* 		ren distance distance2
* 		ren *3 *

* g dated=dofm(datec)
* g year=year(dated)

* g pT = year-year_inst
* replace pT=1000 if pT>6 | pT<-6
* replace pT=pT+10
* replace pT=1 if pT==1010

* gegen dmm=mean(distance2), by(pT)
* gegen tt=tag(pT)

* twoway scatter dmm pT if tt==1
* xi: areg distance2 i.pT i.year*i.ba, a(pipe_id) cl(pipe_id) r
* coefplot, vertical keep(*pT*)




*** NOT AMAZING PATTERNS BY DAY ! ***

* use "${temp}dayc.dta", clear

* 	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
* 	keep conacct dayc mru
* 	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

* g year = year(dayc)
* drop if year==2005

* g o=1
* g y1 = mdy(o,o,year)
* g dt=dayc-y1


* g treat=year_inst==year & year!=.

* gegen nt=sum(o), by(dt treat)
* gegen tt=tag(dt treat)

* scatter nt dt if tt==1 & treat==0 & nt<4000|| scatter nt dt if tt==1 & treat==1, yaxis(2)

* use "${temp}dayc.dta", clear

* 	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
* 	keep conacct dayc mru
* 	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

* g year = year(dayc)
* drop if year==2005
* g o=1
* gegen dayt=sum(o), by(dayc mru)

* gegen ds=sum(o), by(year mru)
* gegen daytm=max(dayt), by(year mru)
* g dm = daytm/ds 

* duplicates drop mru year, force

* g pT = year-year_inst
* replace pT=1000 if pT>6 | pT<-6
* replace pT=pT+10
* replace pT=1 if pT==1010

* gegen dmm=mean(dm), by(pT)
* gegen tt=tag(pT)

* twoway scatter dmm pT if tt==1





*** R TO S ANALYSIS!! 


use "${temp}bill_paws_full.dta", clear

	gegen tc=tag(conacct)
	count if tc==1


tsset conacct date
tsfill, full

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


g anres=asum-aressum


reg tot_pop posta pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year i.ba , cluster(mru) r

reg tot_pop posta  i.year i.ba , cluster(mru) r


reg aressum posta  i.year i.ba , cluster(mru) r

reg tot posta  i.year i.ba , cluster(mru) r

reg pop posta  i.year i.ba if tot_pop<4, cluster(mru) r



xi: areg tot_pop posta  i.year*i.ba  , cluster(mru) r a(mru)


* g aper=aressum/mru_area
* reg aper pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year if year==2009 | year==2008, cluster(mru) r


reg cmean pop_density no_apt no_rent age hs_grad college_grad prof_emp low_emp i.year if year==2009 | year==2008, cluster(mru) r



xi: reg aressum post pop_density no_apt no_rent  age hs_grad college_grad prof_emp low_emp ///
pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post ///
 i.year*i.ba if yt==1 , cluster(mru) r 




reg aressum post pop_density no_apt no_rent  age hs_grad college_grad prof_emp low_emp ///
pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post ///
 year i.ba if yt==1 , cluster(mru) r 


reg ln_ay post pop_density no_apt no_rent  age hs_grad college_grad prof_emp low_emp ///
pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post ///
 year i.ba if yt==1 , cluster(mru) r 


xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1 , a(mru) cluster(mru) r 

xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1 & sub_mru!=.  , a(mru) cluster(mru) r 

xi: areg ln_ay post pop_density_post no_apt_post no_rent_post  age_post hs_grad_post college_grad_post prof_emp_post low_emp_post  i.year*i.ba if yt==1  &  pop_density<.25 , a(mru) cluster(mru) r 







xi: areg ln_ay post *_mru_*post i.year*i.ba if yt==1  , a(mru) cluster(mru) r 




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


 areg anres i.pT i.year  , a(mru)  r 
 	coefplot, keep(*pT*) vertical
 	
 areg aressum i.pT i.year  , a(mru)  r 
 	coefplot, keep(*pT*) vertical


xi: areg payc_y i.pT i.year*i.ba if yt==1   , a(mru) cluster(mru) r 
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











* pressure.do

* use "${temp}mru_pop.dta", clear

		* merge 1:1 conacct using "${temp}cf_inst.dta"
		* 		drop if _merge==2
		* 		drop _merge


odbc load, exec("SELECT * FROM mru")  dsn("phil") clear  
		keep mru area
		duplicates drop mru, force
		ren mru mru
		destring mru, replace force
		drop if mru==.
save "${temp}mru_area.dta", replace


 use "${temp}activem.dta", clear
 keep if date==660
 drop date
 save "${temp}activem_660.dta", replace




use "${temp}conacct_rate.dta", clear

	merge m:1 mru using "${temp}mru_area.dta", keep(3) nogen

	gegen mrudc=min(datec), by(mru)
	g oid = datec>=mrudc & datec<=mrudc+12
	gegen ods=sum(oid), by(mru mrudc)
	drop if ods<=5

replace ods = ods/area

duplicates drop mru, force

	merge 1:1 mru using  "${temp}activem_660.dta", keep(3) nogen
	merge 1:1 mru using "${temp}mru_pop.dta", keep(1 3) nogen

* THAT'S A LOT OF MEASUREMENT ERROR!

g asum_pop = asum/pop
replace asum_pop=. if asum_pop>2
sum asum_pop, detail


* preserve
* 	keep mru mrudc
* 		odbc exec("DROP TABLE IF EXISTS mrudc;"), dsn("phil")
* 			odbc insert, table("mrudc") dsn("phil") create
* restore		

gegen mmdc=mean(ods), by(mrudc ba)
gegen mmtt=tag(mrudc ba)


g post = mrudc>600 
replace post = mrudc>612 if ba!=1700

g asum_area = asum/area
replace asum_area=. if asum_area>.027
gegen mma=mean(asum_area), by(mrudc ba)

gegen mmat=mean(asum_area), by(mrudc)
gegen mdct=tag(mrudc)


areg asum_area post if ba==1700 & mrudc>=590 & mrudc<=610 , a(zone_code)

areg asum_area post if ba==1700 & mrudc>=580 & mrudc<=620 , a(zone_code)


areg asum post if ba==1700 & mrudc>=580 & mrudc<=620 , a(zone_code)


areg ods post if ba==1700 & mrudc>=580 & mrudc<=620 , a(zone_code)



reg area post if area<=500000 &  ba==1700 & mrudc>=590 & mrudc<=610 
reg pop post if area<=500000 &  ba==1700 & mrudc>=590 & mrudc<=610 



twoway scatter mmdc mrudc if mmtt==1 & ///
(ba==300 | ba==1100 | ba==800 | ba==1200 | ba==1700) & datec>545 & datec<=640, ///
 by(ba) xline(612)


twoway scatter mmdc mrudc if mmtt==1 & datec>545 & datec<=640,  by(ba) 
twoway scatter mmdc mrudc if mmtt==1 & ba==1700



sum mmdc if ba==1700 & mrudc>=580 & mrudc<=600 
sum mmdc if ba==1700 & mrudc>=600 & mrudc<=620



twoway scatter mmat mrudc if mdct==1



twoway scatter mma mrudc if mmtt==1 & datec>545 & datec<=640 & ba==1700 || ///
	   scatter mmdc mrudc if mmtt==1 & datec>545 & datec<=640 & ba==1700

twoway scatter mma mrudc if mmtt==1 & datec>545 & datec<=640 & ba==300 || ///
	   scatter mmdc mrudc if mmtt==1 & datec>545 & datec<=640 & ba==300

twoway scatter mma mrudc if mmtt==1 & datec>545 & datec<=640 & ba==1100 || ///
	   scatter mmdc mrudc if mmtt==1 & datec>545 & datec<=640 & ba==1100

twoway scatter mma mrudc if mmtt==1 & datec>545 & datec<=640 & ba==800 || ///
	   scatter mmdc mrudc if mmtt==1 & datec>545 & datec<=640 & ba==800



sum asum_area if ba==1700 & mrudc>=590 & mrudc<=600 
sum asum_area  if ba==1700 & mrudc>=600 & mrudc<=610

sum asum_pop if ba==1700 & mrudc>=590 & mrudc<=600 
sum asum_pop  if ba==1700 & mrudc>=600 & mrudc<=610



twoway scatter mma mrudc if mmtt==1 & datec>545 & datec<=640,  by(ba) 






reg asum_area post if  mrudc>=550 & mrudc<=640 
reg area post if area<=500000 &   mrudc>=550 & mrudc<=640
reg pop post if area<=500000 &  mrudc>=550 & mrudc<=640 




reg asum_area post mrudc
reg asum_area post mrudc if ba==1700


reg asum_area post if mrudc>=580 & mrudc<=620 
reg asum_area post if ba==1700 & mrudc>=580 & mrudc<=620 







use "${temp}conacct_rate.dta", clear
	gegen datecm =min(datec), by(mru)
	gegen mt=tag(mru)
	keep if mt==1
	keep datecm mru ba
save "${temp}mru_datecm.dta", replace


use "${temp}conacct_rate.dta", clear
	gegen datecm =min(datec), by(mru)
	drop if datecm<550
	keep if datec<=datecm+6
	g o =1
	gegen totc = sum(o), by(mru)
	gegen mt=tag(mru)
	keep if mt==1

	drop if totc<10

	keep datecm mru totc ba

	* merge 1:1 mru using "${temp}mru_pop.dta", keep(3) nogen

	g dens=totc/pop

	replace dens=. if dens>8

	gegen dm = mean(dens), by(datecm )
	gegen dt=tag(datecm)

	twoway scatter dm datecm if dt==1 


	lowess dens datecm if datecm>580 & datecm<610

** QUICK TNPL! 










use "${temp}conacct_rate.dta", clear

drop if ba==1700

	keep datec mru ba
g o=1
gegen new=sum(o), by(mru datec)

g pre_id= 1 if datec<550
gegen pres=sum(pre_id), by(mru)

keep if pres>10
keep if datec>550
drop o
duplicates drop mru datec, force
tsset mru datec
tsfill, full
replace new=0 if new==.

gegen ba1=max(ba), by(mru)
drop ba
ren ba1 ba

keep mru datec new ba

save "${temp}mru_new.dta", replace

use "${temp}mru_new.dta", clear
keep mru ba
duplicates drop mru, force
save "${temp}mru_set.dta", replace



* use "${temp}activem.dta", clear
* 	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
* 	merge m:1 mru using "${temp}mru_cf.dta", keep(3) nogen
* gegen am=mean(asum), by(date mrub)
* gegen dt=tag(date mrub)
* twoway scatter am date if dt==1 & mrub==0 || ///
* 	   scatter am date if dt==1 & mrub==1
* g post = date>595
* g treat=mrub==1
* g post_treat=post*treat
* reg asum post treat post_treat


use "${temp}activem.dta", clear

	merge 1:1 mru date using "${temp}dcm.dta", keep(1 3) nogen
	merge 1:1 mru date using "${temp}billm.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>10 | pT<-3
gegen min_pT=min(pT), by(mru)
replace pT=pT+10
replace pT=1 if pT==1010

foreach var of varlist cpanel asum aressum csum cmean cread clow csumlow bm dct {
	gegen `var'_y=mean(`var'), by(mru year)
}
gegen yt   = tag(mru year)

xi: areg asum_y i.pT i.year*i.ba if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

xi: areg csum_y i.pT i.year*i.ba if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

xi: areg clow_y i.pT i.year*i.ba if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical


xi: areg cmean_y i.pT i.year*i.ba if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

xi: areg bm_y i.pT i.year*i.mun if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

xi: areg dct_y i.pT i.year*i.mun if yt==1, a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical






use "${temp}paws_aib.dta", clear

replace year=2008 if year<2008

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
		drop ba zone_code dc-bus
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

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
replace pT=1000 if pT>6 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

gegen yt=tag(mru year)
gegen yesy=mean(yes_flow), by(mru year)

foreach var of varlist yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp S hho {
	gegen `var'_y=mean(`var'), by(mru year)
}

xi: areg yes_flow_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)
xi: areg no_flow_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)
xi: areg flow_hrs_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)
xi: areg B_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)
xi: areg S_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg hho_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

* xi: areg yes_flow i.pT i.year*i.ba, a(conacct) r *** ROBUST TO INDIVIDUAL FIXED EFFECTS
* 	coefplot, vertical keep(*pT*)
* xi: areg no_flow i.pT i.year*i.ba, a(conacct) r
* 	coefplot, vertical keep(*pT*)



*** NOT ENOUGH PRE/POST PERIOD FOR BILL AND SUPP

	odbc load, exec("SELECT * FROM pipes_dma_int")  dsn("phil") clear  
		keep if pipe_class=="TERTIARY"
		destring year_inst, replace force
		ren int_length length
		egen ly=sum(length), by(dma_id year_inst)
		egen max_l=max(ly), by(dma_id)
		egen total_mru=sum(length), by(dma_id)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		keep length year_inst dma_id shr
		duplicates drop dma_id, force
		g str25 dma = dma_id
		drop dma_id
	save "${temp}pipe_year_old_dma.dta", replace
	


use "${temp}nrw.dta", clear

merge m:1 dma using "${temp}pipe_year_old_dma.dta", keep(1 3) nogen

g ba_id=substr(dma,4,3)
replace ba_id = lower(ba_id)
gegen ba=group(ba_id)

		g dated=dofm(date)
		g year=year(dated)
		drop dated

	g pT = year-year_inst
	replace pT=1000 if pT>6 | pT<-4
	replace pT=pT+10
	replace pT=1 if pT==1010

	gegen mpT=min(pT), by(dma)
	* replace pT=1010 if mpT>=10	
	* replace pT=1010 if shr<.7

	gegen dg = group(dma)

	g nrw = 1 - (bill/supp)
	replace nrw=0 if nrw<0

	gegen yt=tag(dg year)

gegen nrwm=mean(nrw), by(dg year)
gegen billm=mean(bill), by(dg year)
gegen suppm=mean(supp), by(dg year)


g ln_billm=log(billm)
g ln_suppm=log(suppm)

xi: areg nrwm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg billm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg suppm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg ln_billm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg ln_suppm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical












use "${temp}conacct_rate.dta", clear

	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
	merge m:1 conacct using "${temp}ai_conacct.dta", keep(1 3) nogen

	keep datec mru nat_ill ba
	drop if mru==.

g ill_id=nat_ill!=.
g ill_tcd_id=nat_ill==10015 | nat_ill==10006
gegen ill=sum(ill_id), by(mru datec)
gegen ill_tcd=sum(ill_tcd_id), by(mru datec)

duplicates drop mru datec, force
tsset mru datec
tsfill, full
replace ill=0 if ill==.
replace ill_tcd=0 if ill_tcd==.

gegen ba1=max(ba), by(mru)
drop ba
ren ba1 ba
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
g dated=dofm(date)
g year=year(dated)
g pT = year-year_inst
replace pT=1000 if pT>4 | pT<-6
replace pT=pT+10

g n_id = ill-ill_tcd
gegen mi=mean(ill), by(mru year)
gegen ni=mean(n_id), by(mru year)
gegen mit=mean(ill_tcd), by(mru year)
gegen yt=tag(mru year)

g post = year>=year_inst & year<.

xi: areg ni i.pT i.year*i.ba if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical
xi: areg mit i.pT i.year*i.ba if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical
* xi: areg ni i.pT i.year*i.ba if yt==1 & year<2010, a(mru) cluster(mru) r 
* 	coefplot, keep(*pT*) vertical
* xi: areg mit i.pT i.year*i.ba if yt==1 & year<2010, a(mru) cluster(mru) r 
* 	coefplot, keep(*pT*) vertical



***  WHO CONNECTS!?
use "${temp}conacct_rate.dta", clear
	merge 1:m conacct using "${temp}paws_aib.dta", keep(3) nogen
	duplicates drop conacct, force
	keep if datec>550

	merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen

	drop date year
	ren datec date

	g dated=dofm(date)
	g year=year(dated)

	g pT = year-year_inst
	replace pT=1000 if pT>6 | pT<-6
	replace pT=pT+10

	g pre = pT>=7 & pT<=9
	g pip = pT==10
	g pos = pT>=11 & pT<=13
	replace job = 0 if job==.
	tab sclass, g(s_)

	reg pip hhsize hhemp age sub single  i.job if pT>=4 & pT<=10, cluster(conacct) r 

	reg pip hhsize hhemp age sub single  i.job s_* if pT>=7 & pT<=10, cluster(conacct) r 

	reg pip hhsize hhemp age sub single  i.job s_* if pT>=7 & pT<=13, cluster(conacct) r 
	reg pip hhsize hhemp age sub single  i.job s_* if pT!=1010, cluster(conacct) r 



use "${temp}paws_aib.dta", clear

replace year=2008 if year<2008

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
		drop ba zone_code dc-bus
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

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
replace pT=pT+10
replace pT=1 if pT==1010

gegen yt=tag(mru year)
gegen yesy=mean(yes_flow), by(mru year)

foreach var of varlist yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp shr {
	gegen `var'_y=mean(`var'), by(mru year)
}


* xi: areg yes_flow i.pT i.year*i.ba, a(conacct) r
* 	coefplot, vertical keep(*pT*)
* xi: areg no_flow i.pT i.year*i.ba, a(conacct) r
* 	coefplot, vertical keep(*pT*)



xi: areg yes_flow_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg no_flow_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg flow_hrs_y i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg B_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg drum_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)


xi: areg shr_y i.pT i.year*i.ba , a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)



* xi: areg hhsize_y i.pT i.year*i.ba , a(mru) cluster(mru) r
* 	coefplot, vertical keep(*pT*)
* xi: areg hhemp_y i.pT i.year*i.ba , a(mru) cluster(mru) r
* 	coefplot, vertical keep(*pT*)




gegen BM=max(B), by(conacct)
gegen PM=min(post), by(barangay_id)
gegen YB=mean(yes_flow), by(barangay_id year)
gegen NB=mean(no_flow), by(barangay_id year)
gegen HB=mean(flow_hrs), by(barangay_id year)
gegen CB=mean(color), by(barangay_id year)
gegen MB=mean(smell), by(barangay_id year)
gegen TB=mean(taste), by(barangay_id year)
gegen SB=mean(stuff), by(barangay_id year)

g B_YB=B*YB
g B_no_flow  = B*no_flow
g B_yes_flow = B*yes_flow
g B_flow_hrs = B*flow_hrs
g drum_yes_flow = drum*yes_flow
g drum_post = drum*post

*** WATER FLOW
areg yes_flow post i.year, a(barangay_id) cluster(barangay_id)
areg no_flow  post i.year, a(barangay_id) cluster(barangay_id)
areg flow_hrs post i.year, a(barangay_id) cluster(barangay_id)

areg color post i.year, a(barangay_id) cluster(barangay_id)
areg smell post i.year, a(barangay_id) cluster(barangay_id)
areg taste post i.year, a(barangay_id) cluster(barangay_id)
areg stuff post i.year, a(barangay_id) cluster(barangay_id)

*** BEHAVIORAL
areg drink post i.year , a(barangay_id) cluster(barangay_id)
areg boil post i.year , a(barangay_id) cluster(barangay_id)

*** WATER STORAGE
areg B post i.year, a(barangay_id) cluster(barangay_id)
areg drum post i.year, a(barangay_id) cluster(barangay_id)
areg balde post i.year, a(barangay_id) cluster(barangay_id)
areg gallon post i.year, a(barangay_id) cluster(barangay_id)

*** USAGE  (need to switch clustering)
areg me  post i.year,  a(barangay_id) cluster(mru)
areg wrs post i.year, a(barangay_id) cluster(mru)   // spend less
areg well post i.year, a(barangay_id) cluster(mru)  // LESS GOING TO WELLS AS SECONDARY!
* areg rs post i.year , a(barangay_id) cluster(mru) // no effect on usage of WRS

areg pf_cont_day_pr     post i.year,  a(barangay_id) cluster(mru)
areg pf_cont_night_pr   post i.year,  a(barangay_id) cluster(mru)
areg pf_day_pr_night_pr post i.year,  a(barangay_id) cluster(mru)

areg pf_flow_compl  post i.year,  a(barangay_id) cluster(mru) 
areg pf_flow_qual   post i.year,  a(barangay_id) cluster(mru) 
areg pf_qual_flow   post i.year,  a(barangay_id) cluster(mru) 



areg me B post i.year,  a(conacct) cluster(conacct)  // 42  (but predicted to be only 16)
areg me drum post i.year,  a(conacct) cluster(conacct)  // 42  (but predicted to be only 16)

*** RELIABILITY IS NOT DRIVING QUANTITY INCREASE! ***

areg YB post i.year,  a(barangay_id) cluster(mru) // .16
areg me YB i.year,  a(barangay_id) cluster(mru)  // 100
areg me post i.year,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)

areg me post i.year,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)
areg me post YB NB i.year,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)
		** MORE THAN ACTING THROUGH FLOW! 
* areg me post i.year,  a(conacct) cluster(mru)  // 42  (but predicted to be only 16)
* areg me post YB NB i.year,  a(conacct) cluster(mru)  // 42  (but predicted to be only 16)

* areg me  MB TB SB i.year,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)
* areg me drink i.year,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)
* areg stop_freq  post i.year if stop_freq<10,  a(barangay_id) cluster(mru)  // 42  (but predicted to be only 16)




* sort conacct year
*  by conacct: g BC=B[_n]-B[_n-1]
*  by conacct: g MEC=me[_n]-me[_n-1]
* reg MEC BC post i.year

* areg me drum drum_post post i.year, a(barangay_id) cluster(barangay_id)
* areg me drum drum_yes_flow yes_flow post i.year, a(barangay_id) cluster(barangay_id)


areg stop_big post i.year, a(barangay_id) cluster(barangay_id)
areg stop_freq post i.year, a(barangay_id) cluster(barangay_id)
areg stop_length post i.year, a(barangay_id) cluster(barangay_id)

reg me B flow_hrs B_flow_hrs  hhemp hhsize sub single hho age post i.year,   cluster(mru)
reg me B no_flow  B_no_flow  hhemp hhsize sub single hho age  post i.year,   cluster(mru)
reg me B yes_flow B_yes_flow hhemp hhsize sub single hho age   post i.year, cluster(mru)
areg me B post i.year if yes_flow==0,   a(barangay_id) cluster(mru)
areg me B post i.year if yes_flow==1,   a(barangay_id) cluster(mru)
areg me B B_YB post i.year,   a(barangay_id) cluster(mru)
areg me B post i.year if YB,   a(barangay_id) cluster(mru)
areg me B post i.year if no_flow==0,   a(barangay_id) cluster(mru)
areg me B post i.year if no_flow==1,   a(barangay_id) cluster(mru)
areg me B post i.year if yes_flow==0,   a(barangay_id) cluster(mru)
areg me B post i.year if yes_flow==1,   a(barangay_id) cluster(mru)
areg me B B_YB YB post i.year,   a(barangay_id) cluster(mru)
areg me B i.year if PM==0 & post==0,   a(barangay_id) cluster(mru)
areg me B i.year if PM==0 & post==1,   a(barangay_id) cluster(mru)
areg me B hhsize hhemp sub single age i.year if PM==0 & post==0,   a(barangay_id) cluster(mru)
areg me B hhsize hhemp sub single age i.year if PM==0 & post==1,   a(barangay_id) cluster(mru)
areg me color post i.year, a(barangay_id) cluster(barangay_id)
areg me smell post i.year, a(barangay_id) cluster(barangay_id)
areg me taste post i.year, a(barangay_id) cluster(barangay_id)
areg me stuff post i.year, a(barangay_id) cluster(barangay_id)




* areg booster_need  yes_flow i.year,  a(barangay_id) cluster(mru) 
* areg booster_use  yes_flow  i.year,  a(barangay_id) cluster(mru) 


	* areg yes_flow i.year_inst i.wave if year_inst<=2007 & year_inst>=2000, a(barangay_id)
	* coefplot, vertical keep(*year_inst*)


* sub single hhsize hhemp age
foreach var of varlist sub single hhsize hhemp age {
	cap drop post_`var'
	g post_`var'=post*`var'
	cap drop control_`var'
	g control_`var' = `var'
}

areg yes_flow 	control_*  post post_*  i.year, a(barangay_id) cluster(mru)
areg no_flow 	control_*  post post_*  i.year, a(barangay_id) cluster(mru)
areg flow_hrs 	control_*  post post_*  i.year, a(barangay_id) cluster(mru)


areg me control_*  post post_* i.year, a(barangay_id) cluster(mru)


areg me 		control_sub control_single post post_sub post_single  i.year, a(barangay_id) cluster(mru)


g B_post = B*post

areg me B post B_post i.year, a(barangay_id) cluster(mru)



areg drink 	post i.year, a(barangay_id) cluster(mru)
areg boil 	post i.year, a(barangay_id) cluster(mru)
areg hho 	post i.year, a(barangay_id) cluster(mru)






use "${temp}bill_paws_full.dta", clear

		merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen

* replace c = . if c>400


	g dated=dofm(date)
	g year=year(dated)
		drop dated

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

areg cy i.pT i.year if yt==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical


areg cy i.pT i.year if yt==1 & class>=2 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 & class==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical





use "${temp}bill_paws_full.dta", clear

* replace c = . if c>100
* 	gegen mclass=max(class), by(conacct)
* 	keep if mclass<=2
* 	drop mclass

		* merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen

	keep c date conacct

		* use  "${temp}npaws_bill.dta", clear
		* tsset conacct date
		* tsfill, full

		merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
		drop year

		merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen


g B1 = B if wave==3
gegen BM=max(B1), by(conacct)

	g dated=dofm(date)
	g year=year(dated)
		drop dated


g post = year>year_inst
g BM_post = post*BM

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)


areg cy post BM_post i.year if yt==1 , a(conacct) cluster(conacct) r 


areg cy i.pT i.year if yt==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical









* NRW * "${temp}conacct_dma_link.dta"




use "${temp}conacct_rate.dta", clear

drop if ba==1700

	keep datec mru
g o=1
gegen new=sum(o), by(mru datec)

g pre_id= 1 if datec<550
gegen pres=sum(pre_id), by(mru)

keep if pres>10
keep if datec>550
drop o
duplicates drop mru datec, force
tsset mru datec
tsfill, full
replace new=0 if new==.
replace new=. if new>50

merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=sum(new), by(mru year)
gegen yt=tag(mru year)

keep if yt==1
keep if pT==10 | pT==10-1

sort mru pT
by mru: g jump = cy[_n]-cy[_n-1]

keep if jump!=.
keep jump mru
save "${temp}mru_jump.dta", replace









use "${temp}nrw.dta", clear

	areg bill acct i.date, a(dma) cluster(dma)
	areg supp acct i.date, a(dma) cluster(dma)

	g bill_cu = bill*1000*30
	g supp_cu = supp*1000*30

	areg bill_cu acct i.date, a(dma) cluster(dma)
	areg supp_cu acct i.date, a(dma) cluster(dma)

g nrw= 1- bill/supp

	areg nrw acct i.date, a(dma) cluster(dma)







use "${temp}mru_dma_link.dta", clear

	merge m:1 mru using "${temp}mru_jump.dta"
	gegen mjump=max(jump), by(dma)

	merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
	gegen my=max(year_inst), by(dma)
	keep my mjump dma
	duplicates drop dma, force

	merge 1:m dma using "${temp}nrw.dta", keep(1 3) nogen

		g dated=dofm(date)
		g year=year(dated)
		drop dated

	g pT = year-my
	replace pT=1000 if pT>6 | pT<-6
	replace pT=pT+10

	g nrw = 1 - (bill/supp)


	g post = year>=my & year<.
	g acct_post = acct*post

	tab pT, g(tab_pT_)
	foreach var of varlist tab_pT_* {
		g `var'_acct = `var'*acct
	}

	areg bill acct tab_* i.date, a(dma) cluster(dma) r


	areg supp acct tab_* i.date, a(dma) cluster(dma) r
		coefplot, keep(tab*acct) vertical

	areg acct i.pT i.date, a(dma) cluster(dma) r
		coefplot, keep(*pT*) vertical

	areg supp acct acct_post post i.date, a(dma) cluster(dma) r

	areg supp post i.date, a(dma) cluster(dma) r


	areg bill post i.date, a(dma) cluster(dma) r

	areg acct post i.date, a(dma) cluster(dma) r



	gegen nrwm=mean(nrw), by(dma year)
	gegen billm=mean(bill), by(dma year)
	gegen suppm=mean(supp), by(dma year)

	g ln_b = log(billm)
	g ln_s = log(suppm)

	egen dg=group(dma)
	gegen yt = tag(dma year)

	keep if yt==1

	sort dma year
	by dma: g billm_ch = billm[_n]-bill[_n-1]
	by dma: g suppm_ch = suppm[_n]-suppm[_n-1]

	twoway scatter suppm_ch mjump if pT==10

	reg suppm_ch mjump if pT == 10


	areg nrwm i.pT i.year if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

	areg nrwm i.pT i.year if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical




	areg billm i.pT i.year if yt==1 , a(dg) cluster(dg) r 
		coefplot, keep(*pT*) vertical

	areg suppm i.pT i.year if yt==1 , a(dg) cluster(dg) r 
		coefplot, keep(*pT*) vertical



	areg nrwm post i.year if yt==1 , a(dg) cluster(dg) r 

	areg billm post i.year if yt==1 , a(dg) cluster(dg) r 
	areg suppm post i.year if yt==1 , a(dg) cluster(dg) r 

	areg ln_b post i.year if yt==1 , a(dg) cluster(dg) r 
	areg ln_s post i.year if yt==1 , a(dg) cluster(dg) r 





** MORE RECORDED DISCONNECTIONS! **

use "${temp}dcm.dta", clear

tsset mru date
tsfill, full
replace dct=0 if dct==.

merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10


gegen cy=sum(dct), by(mru year)
gegen yt=tag(mru year)

g post = year>=year_inst & year<.

areg cy i.pT i.year if yt==1 & cy<2000 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

	* missing from pipe replacement! (likely)..  MRU set deals with it


use "${temp}billm.dta", clear

tsset mru date
tsfill, full
replace bm=0 if bm==.

merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10


gegen cy=sum(bm), by(mru year)
gegen yt=tag(mru year)

g post = year>=year_inst & year<.

areg cy i.pT i.year if yt==1 & cy<2000 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

	* missing from pipe replacement! (likely).. 



*** THIS SHOWS THAT SHARING CONNECTIONS GO WAYYYY DOWN! ***

use "${temp}nshr_full.dta", clear

		g dated=dofm(date)
		g year=year(dated)
		drop dated

	g pT = year-year_inst
	replace pT=1000 if pT>6 | pT<-6
	replace pT=pT+10


	g dT = date-datec

		keep if datec>590

	gegen gt=tag(dT)

	replace c_1=. if c_1>200
	replace c_2=. if c_2>200

	* egen cm=rowmean(c_1 c_2)
	* replace cm=c_1 if cm==. & c_1!=.
	* replace cm=c_2 if cm==. & c_2!=.

	g cm = c_1
	gegen cmm = mean(cm), by(dT)

	twoway scatter cmm dT if gt==1 & dT>=-12 & dT<=12

	g c_pre_id = cm if dT<0  & dT>=-6 
	g c_post_id= cm if dT>=3 & dT<=9
	gegen c_pre = mean(c_pre_id), by(conacct)
	gegen c_post = mean(c_post_id), by(conacct)

	g c_diff =c_pre-c_post

	g c_pre_id10 = c_10 if dT<0  & dT>=-6 
	g c_post_id10= c_10 if dT>=3 & dT<=9
	gegen c_pre10 = mean(c_pre_id10), by(conacct)
	gegen c_post10 = mean(c_post_id10), by(conacct)
	g c_diff10 =c_pre10-c_post10

	sum c_diff
	sum c_diff10


	cap drop pTa
	cap drop c_diffm
	cap drop pTtag

	g pTa= yearc-year_inst
	gegen c_diffm=mean(c_diff), by(pTa)
	gegen c_diffm10=mean(c_diff10), by(pTa)
	gegen pTtag=tag(pTa)

	twoway scatter c_diffm pTa if pTtag==1 & pTa>=-5 & pTa<=5 || ///
		 scatter c_diffm10 pTa if pTtag==1 & pTa>=-5 & pTa<=5

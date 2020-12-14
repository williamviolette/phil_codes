* pressure.do

* WHEN TO REPLACE PIPES?  
* 		DO NRW IDEA
* counterfactuals:
*  straight monopoly, monopoly with fixed price, quality standards (ie. target NRW?) ?

* low-powered incentive: costs are covered and the utility believes that
* high-powered incentive: imagine that the utility expects a change in regulation 
* 		where the regulator doesn't commit to covering costs

* dynamics too?!




* GO ALL DMA BY MATCHING MRU TO DMA~!



grstyle init
grstyle set imesh, horizontal





use "${temp}final_analysis.dta", clear

keep if cv!=.
replace treated=0 if shr<.8
replace post_treated=0 if shr<.8
g paws=smell!=.

*** KEEP ONLY MRUs WITH PIPE-REPLACEMENTS?

merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen
merge m:1 mru using "${temp}mru_zone_code.dta", keep(3) nogen

g paws_pre = paws==1 & treated==1 & post==0
g paws_post = paws==1 & treated==1 & post==1

keep paws_pre paws_post mru zone_code

levelsof zone_code

g zm =.
global tt = 1
foreach v in `=r(levels)' {
replace zm = $tt if zone_code==`v'
gegen ppre =sum(paws_pre), by(zm)
gegen ppost=sum(paws_post), by(zm)

sum ppre if zm==$tt
global premean=`=r(mean)'
sum ppost if zm==$tt
global postmean=`=r(mean)'

if $premean>100 & $postmean>100 {
	global tt = $tt + 1
}
cap drop ppre
cap drop ppost
}

drop paws_pre paws_post
sum zm
replace zm=`=r(max)'-1 if zm==`=r(max)'

duplicates drop mru, force

save "${temp}id_set.dta", replace






*** Do cost savings by percentage and starting point??


use "${temp}final_analysis.dta", clear

keep if cv!=.
replace treated=0 if shr<.8
replace post_treated=0 if shr<.8

	replace amount = . if amount<0 | amount>60*200

replace inc = inc/10000

g paws=smell!=.

gegen ctag=tag(conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

	merge m:1 mru using "${temp}id_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen
	merge m:1 mru using "${temp}mru_dma_link.dta", keep(1 3) nogen
	merge m:1 dma using "${temp}capex_dma_full.dta", keep(1 3) nogen

g cper = (1000000/1000)*(cost/pipe_l)
sum cper, detail
replace cper=. if cper<=`=r(p1)' | cper>=`=r(p99)'

gegen cper_m   = mean(cper),   by(zm)
gegen length_m = mean(length), by(zm)
gegen accts_m  = mean(accts),  by(zm)
gegen sho_m    = mean(SHO),    by(zm)

g fc = cper_m*length_m/(accts_m*sho_m)


g CPe = .
levelsof zm
foreach v in `=r(levels)' {
	sum cper if zm==`v'
	* sum fc if zm==`v'
	replace CPe=`=r(mean)' in `v'
}

levelsof zm
foreach v in `=r(levels)' {
	g ZM_`v'_post_treated=post_treated==1 & zm==`v'
}

reghdfe B  ZM_*_post_treated [pweight=SHO] if paws==1, a(mru date) cluster(mru)
mat def be = e(b)

reghdfe cv ZM_*_post_treated [pweight=SHO], a(conacct date) cluster(mru)
mat def ce = e(b)

reghdfe amount ZM_*_post_treated [pweight=SHO] if amount<=60*50, a(conacct date) cluster(mru)
mat def ae = e(b)

reghdfe no_flow ZM_*_post_treated [pweight=SHO], a(mru date) cluster(mru)
mat def ne = e(b)

* reghdfe color ZM_*_post_treated [pweight=SHO], a(mru date) cluster(mru)
* reghdfe taste ZM_*_post_treated [pweight=SHO], a(mru date) cluster(mru)
* reghdfe smell ZM_*_post_treated [pweight=SHO], a(mru date) cluster(mru)

* levelsof zm
* foreach r in `=r(levels)' {
* 	disp "THE ZONE IS `r'"
* 	sum no_flow if post==0 & zm==`r'
* 	* sum no_flow if post==1 & zm==`r'
* }


g Be = .
g Ce = .
g Ae = .
g NFe = .
levelsof zm
foreach r in `=r(levels)' {
	replace Be = be[1,`r'] in `r'
	replace Ce = ce[1,`r'] in `r'
	replace Ae = ae[1,`r'] in `r'
	replace NFe = ne[1,`r'] in `r'
}


g CVe = .
g NFm  = .
levelsof zm
foreach r in `=r(levels)' {
qui mean cv [pweight = SHO ] if zm==`r'
matrix ee=e(b)
replace CVe=ee[1,1] in `r'
qui mean no_flow [pweight = SHO ] if zm==`r' & post_treated==1
matrix ee=e(b)
replace NFm=ee[1,1] in `r'
}


browse CVe Ce Be Ae CPe

g CSe = CVe*Ce/.6
g BSe = -Be*486


preserve	
	keep  CSe BSe Ae CPe NFm NFe
	order CSe BSe Ae CPe NFm NFe
	keep if CSe!=.
	export delimited using "${temp}mat_counter.csv", delimiter(",") replace
restore



twoway scatter Be Ce







use "${temp}final_analysis.dta", clear
keep if cv!=.
	merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen

gegen SHOm=mean(SHO), by(mru)

g hh_per = SHOm*accts
keep mru hh_per
duplicates drop mru, force

save "${temp}mru_hh_per.dta", replace




use "${temp}comm_amountm.dta", clear
	drop billclass_key
	fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
	keep amount date billclass_key conacct mru datec bus
	ren billclass_key billclass

	fmerge m:1 conacct date using "${temp}comm_billm.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}mru_hh_per.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}id_set.dta", keep(3) nogen

	g dated=dofm(date)
	g year=year(dated)

	g post = year>=year_inst & year_inst<.
	gegen minpost=min(post), by(mru)
	g treated=minpost==0
	g post_treated = post*treated

replace treated=0 if shr<.8
replace post_treated=0 if shr<.8

	drop if date==653

sum c, detail
keep if c<`=r(p95)'
replace amount = . if amount<=0 | amount>=`=r(p95)*80'

	merge m:1 mru using "${temp}id_set.dta", keep(1 3) nogen

gegen ctag=tag(conacct)
gegen ctot=sum(ctag), by(mru)

g cshr = ctot/hh_per
gegen cshr_zone = mean(cshr), by(zone_code)


levelsof zm
foreach v in `=r(levels)' {
	g ZM_`v'_post_treated=post_treated==1 & zm==`v'
}

levelsof zm
foreach v in `=r(levels)' {
	sum cshr if zm==`v'
}

reghdfe amount ZM_*_post_treated , a(conacct date) cluster(mru)
mat def mca = e(b)

g CSHR = .
g CAMT = .

levelsof zm
foreach v in `=r(levels)' {
	sum cshr if zm==`v'
	replace CSHR=`=r(mean)' in `v'
	replace CAMT=mca[1,`v'] in `v'
}

preserve	
	keep  CSHR CAMT
	order CSHR CAMT
	keep if CSHR!=.
	export delimited using "${temp}mat_counter_comm.csv", delimiter(",") replace
restore


* * if $do_est == 1 {
* reghdfe c      post_treated , a(conacct date) cluster(mru)
* 	* estimates save "${temp}c3", replace
* reghdfe amount post_treated , a(conacct date) cluster(mru)
* 	* estimates save "${temp}c4", replace
* * }
* * g wrs = regexm(bus,"Water")==1
* * g house=regexm(bus,"House")==1
* * g office=regexm(bus,"Office")==1 | regexm(bus,"Commercial")==1 
* * reghdfe amount post_treated  if wrs==1, a(conacct date) cluster(mru)
* * reghdfe amount post_treated  if house==1, a(conacct date) cluster(mru)
* * reghdfe amount post_treated  if office==1, a(conacct date) cluster(mru)
* levelsof zm
* foreach v in `=r(levels)' {
* 	qui sum cshr if zm==`v'
* 	disp mca[1,`v']*`=r(mean)'
* }
* g post_treated0 = post_treated==1 & zm==.
* reghdfe c   post_treated   ZM_*_post_treated , a(conacct date) cluster(mru)
* reghdfe amount  ZM_*_post_treated if wrs==1, a(conacct date) cluster(mru)
* reghdfe amount  post_treated0 ZM_*_post_treated if wrs==1, a(conacct date) cluster(mru)
* reghdfe amount   ZM_*_post_treated if wrs==1, a(conacct date) cluster(mru)
* reghdfe amount ZM_*_post_treated if amount<=12000, a(conacct date) cluster(mru)
* *** Current | Cost Plus | Price Cap | Monopoly w/ Price Adj.
* *** depends on delta + pipe decay over time







use "${temp}final_analysis.dta", clear

keep if cv!=.

replace inc = inc/10000

g paws=smell!=.

gegen ctag=tag(conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

merge m:1 mru using "${temp}pipe_year_decom_nold.dta", keep(1 3) nogen


* hist year_inst_decom
* replace year_inst_decom=round(year_inst_decom,5)

replace year_inst_decom=year_inst-year_inst_decom
replace year_inst_decom=. if year_inst_decom<=0
replace year_inst_decom=round(year_inst_decom,5)

levelsof year_inst_decom


foreach v in `=r(levels)' {
	g ZM_`v'_post_treated = post_treated==1 & year_inst_decom==`v'
}

reghdfe cv ZM_* , a(conacct date)



reghdfe cv ZM_18_post_treated-ZM_30_post_treated, a(conacct date)



reghdfe cv post_treated [pweight=SHO] if year_inst_decom<1995, a(mru date)

reghdfe cv post_treated [pweight=SHO] , a(mru date)







*** NO HETEROGENETIY IN COST SAVINGS! 

* use "${temp}id_set.dta", clear
* 	keep zone_code zm
* 	duplicates drop zone_code, force
* 	drop if zone_code==.
* 	keep zone_code zm
* save "${temp}id_zone_set.dta", replace




use "${temp}mru_dma_link.dta", clear
	merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen
	* 1.4 is mean SHO

	gegen acct_dma=sum(accts), by(dma)
	g dma_pop=acct_dma*1.4

	merge m:1 mru using "${temp}id_set.dta", keep(3) nogen

	duplicates drop dma, force
	keep  dma  dma_pop zm

	merge 1:m dma using "${temp}pipe_year_old_dma.dta", keep(3) nogen
	merge 1:m dma using "${temp}nrw.dta", keep(3) nogen
	g dated=dofm(date)
	g year=year(dated)

g scaling_term = dma_pop

g post = year>=year_inst & year_inst<.
gegen minpost=min(post), by(dma)
g treated=minpost==0
g post_treated=post*treated
replace treated=0 if shr<.8
replace post_treated=0 if shr<.8


replace bill = 1000*30*bill/scaling_term
replace supp = 1000*30*supp/scaling_term

sum supp, detail
replace supp=. if supp>`=r(p99)' | supp<`=r(p1)'


sum bill, detail

g ln_bill = log(bill)
g ln_supp = log(supp)

g nrw=1-(bill/supp)

g supp5=supp*5
g ln_supp5=log(supp5)

* areg bill post_treated i.date, a(dma) cluster(dma) r

reghdfe supp5 post_treated, a(dma date) cluster(dma)

* reghdfe ln_supp5 post_treated, a(dma date) cluster(dma)
* mat def ee = e(b)

* reghdfe nrw post_treated, a(dma date) cluster(dma)

* g pre_treated=treat==1 & post==0

* g NRW = .
* levelsof zm
* foreach v in `=r(levels)' {
* 	sum supp5 if zm==`v' & post==1
* 	disp `=r(mean)'*abs(ee[1,1])/(1-abs(ee[1,1]))
* 	replace NRW = `=r(mean)'*abs(ee[1,1])/(1-abs(ee[1,1]))  in `v'
* }

* preserve	
* 	keep  NRW
* 	order NRW
* 	keep if NRW!=.
* 	export delimited using "${temp}mat_counter_nrw.csv", delimiter(",") replace
* restore
* x = y - e*y  => (1-e)*y = x   y = (x/(1-e)) => effect is e/(1-e)*x




* foreach v in `=r(levels)' {
* 	g ZM_`v'_post_treated=post_treated==1 & zm==`v'
* }
* areg supp5 ZM_*_post_treated i.date, a(dma) cluster(dma) r



* areg supp5 post_treated i.date, a(dma) cluster(dma) r
* est save "${temp}nrw_supp", replace
* areg nrw post_treated i.date, a(dma) cluster(dma) r


/*
*** TRY DOING A BUSINESS AREA ID!

use "${temp}final_analysis.dta", clear

keep if cv!=.

g paws=smell!=.

gegen datem=min(date), by(conacct)

merge m:1 mru using "${temp}mru_zone_code.dta", keep(3) nogen
merge m:1 mru using "${temp}mru_dma_link.dta", keep(3) nogen
g paws_pre = paws==1 & treated==1 & post==0
g paws_post = paws==1 & treated==1 & post==1

gegen ppre = sum(paws_pre), by(zone_code)
gegen ppost=sum(paws_post), by(zone_code)

keep if ppre>50 & ppre<. & ppost>50 & ppost<.

gegen ztag=tag(zone_code post_treated)
bys post_treated ztag: g zi = _n
g zii = zi if ztag==1 & post_treated==1
gegen zm=max(zii), by(zone_code)

fmerge m:1 ba using "${temp}ba_name.dta", keep(3) nogen

* replace ba = 1 if ba_name=="Cavite" | regexm(ba_name,"Muntinlupa")==1 | regexm(ba_name,"Paranaque")==1
replace ba = 2 if regexm(ba_name,"Fairview")==1 | regexm(ba_name,"North Caloocan")==1 | regexm(ba_name,"Novaliches")==1
replace ba = 2 if ba==1000 | ba==400 | ba==200

g ba1=.
replace ba1 = 1 if ba==500
replace ba1 = 2 if ba==600
replace ba1 = 3 if ba==700
replace ba1 = 4 if ba==2
drop ba
ren ba1 ba

keep mru dma ba zone_code zm
duplicates drop mru, force

save "${temp}id_set.dta", replace


use "${temp}id_set.dta", clear
	drop mru
	duplicates drop dma, force
save "${temp}id_dma_set.dta", replace



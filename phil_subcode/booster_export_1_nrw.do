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




*** BA HETEROGENEITY ***

use "${temp}final_analysis.dta", clear

keep if cv!=.

replace inc = inc/10000

g paws=smell!=.

fmerge m:1 ba using "${temp}ba_name.dta", keep(3) nogen


replace ba = 1 if ba_name=="Cavite" | regexm(ba_name,"Muntinlupa")==1 | regexm(ba_name,"Paranaque")==1
replace ba = 2 if regexm(ba_name,"Fairview")==1 | regexm(ba_name,"North Caloocan")==1 | regexm(ba_name,"Novaliches")==1


**** HOUSEHOLD SAMPLE! ****
* keep conacct SHO date 

gegen ctag=tag(conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

gegen ztag=tag(ba post_treated)
bys post_treated ztag: g zi = _n
g zii = zi if ztag==1 & post_treated==1
gegen zm=max(zii), by(ba)

replace zm=12 if zm==.
tab zm, g(ZM_)
drop ZM_12



foreach var of varlist ZM_* {
	g `var'_post_treated=`var'*post_treated
}

reghdfe cv ZM_*_post_treated [pweight=SHO], a(conacct date) cluster(mru)


reghdfe B ZM_*_post_treated [pweight=SHO] if paws==1, a(mru date) cluster(mru)






use "${temp}final_analysis.dta", clear

keep if cv!=.

replace inc = inc/10000

g paws=smell!=.

**** HOUSEHOLD SAMPLE! ****
* keep conacct SHO date 

gegen ctag=tag(conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

merge m:1 mru using "${temp}mru_zone_code.dta", keep(3) nogen

g paws_pre = paws==1 & treated==1 & post==0
g paws_post = paws==1 & treated==1 & post==1

gegen ppre = sum(paws_pre), by(zone_code)
gegen ppost=sum(paws_post), by(zone_code)

keep if ppre>50 & ppre<. & ppost>50 & ppost<.

gegen ztag=tag(zone_code post_treated)
bys post_treated ztag: g zi = _n
g zii = zi if ztag==1 & post_treated==1
gegen zm=max(zii), by(zone_code)

replace zm=0 if zm==.
tab zm, g(ZM_)


foreach var of varlist ZM_* {
	g `var'_post_treated=`var'*post_treated
}

reghdfe B ZM_*_post_treated [pweight=SHO] if paws==1, a(mru date) cluster(mru)

mat def be = e(b)

reghdfe cv ZM_*_post_treated [pweight=SHO], a(conacct date) cluster(mru)

mat def ce = e(b)


g Be = .
g Ce = .
forvalues r=1/23 {
	replace Be = be[1,`r'] in `r'
	replace Ce = ce[1,`r'] in `r'
}

g nn=_n


twoway scatter Be Ce









	use "${temp}capex_raw.dta", clear

	keep var4 var3 var5 var9 var10 var39 
	keep if var3!=""

	ren var5 capex_year
	destring capex_year, replace force

	g yr_d = "20"+substr(var3,1,2)
	destring yr_d, replace force
	replace yr_d=. if yr_d==20

	g yr_c = "20"+substr(var39,1,2)
	destring yr_c, replace force
	replace yr_c=. if yr_c==20

	ren yr_d year_d
	ren yr_c year_c
	ren var4 dma

	ren var9 cost
	ren var10 pipe_l

	replace cost = regexs(1) if regexm(cost,"(.+)/") 
	replace pipe_l = regexs(1) if regexm(pipe_l,"(.+)/")

	destring pipe_l cost, replace force
	drop if pipe_l==. | cost==.

	g cost_per = cost/pipe_l
	
	sum cost
	sum pipe_l
	sum cost_per, detail
	disp `=r(mean)'*1000000

	hist cost_per if cost_per < .5



	* units are million PhP




* reg B hhsize hhemp single sub


use "${temp}conacct_rate.dta", clear
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	g o = 1
	gegen MS = sum(o), by(mru)
	gegen mt = tag(mru)
	sum MS if mt==1
	* 275 accounts	
g res = billclass_key<=2
sum res
* odbc load, exec("SELECT * FROM dma")  dsn("phil") clear  
* 	destring mru, replace force






use "${temp}pipe_year_old_dma.dta", clear
	merge 1:m dma using "${temp}nrw.dta", keep(3) nogen
	g dated=dofm(date)
	g year=year(dated)

gegen dtag=tag(dma)

* 275 connections per MRU
* 5043 MRUs, 1324 DMAs
* 1.41 HHs per connection

g scaling_term = 1.41*(275*5043)/1324

g post = year>=year_inst & year_inst<.
gegen minpost=min(post), by(dma)
g treated=minpost==0
g post_treated=post*treated

* gegen last_date=max(date), by(dma)
* g acct_last_id = acct if last_date==date
* gegen acct_last = max(acct_last_id), by(dma)

replace bill = 1000*30*bill/scaling_term
replace supp = 1000*30*supp/scaling_term

sum bill, detail

g ln_bill = log(bill)
g ln_supp = log(supp)

g nrw=1-(bill/supp)

g supp5=supp*5

	* .8 km * .19 million PhP/km = 152,000 PhP per MRU  ==  760 PhP per person

	* 220 users * 400 PhP === Outstanding investment! 

	* 5 yrs in between 


*** SHARING INCREASES WITH PIPE FIXES! (but only by a tiny amount..)

**  new accounts are still a mystery........... ( and come into play with uncertainty over pipe fixes... )


* IV IDEA



use "${temp}final_analysis.dta", clear

keep if cv!=.

drop year_inst

merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen



g post = year>=year_inst & year_inst<.
gegen minpost=min(post), by(dma)

g pT = year-year_inst
replace pT=. if pT>6 | pT<-6
replace pT=. if minpost!=0
gegen ptag=tag(pT)
* gegen mcv = mean(cv), by(pT)

asgen mcv = cv , w(SHO) by(pT)

twoway scatter mcv pT if ptag==1 & pT>=-4 & pT<=6, ylabel(18(1)22) 


drop if year_inst<1980

gegen mv = mean(cv), by(year_inst)
gegen ytag=tag(year_inst)


twoway scatter mv year_inst if ytag==1


areg cv i.year_inst, a(mru)







use "${temp}final_analysis.dta", clear

keep if cv!=.

replace inc = inc/10000

gegen mt=tag(mru)
sum length_tot if mt==1 & treated==1

g paws=smell!=.

**** HOUSEHOLD SAMPLE! ****
* keep conacct SHO date 

gegen ctag=tag(conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

	fmerge m:1 mru using "${temp}mru_dma_link.dta", keep(3) nogen

	ren length length_mru
	ren year_inst year_inst_mru
	ren shr shr_mru
	fmerge m:1 dma using "${temp}pipe_year_old_dma.dta", keep(3) nogen


	* fmerge m:1 conacct using "${temp}conacct_dma_link.dta", keep(3) nogen

	merge m:1 dma date using "${temp}nrw.dta", keep(1 3) nogen




* gegen fm=mean(yes_flow), by(year_inst)
* gegen ytag=tag(year_inst)

* twoway scatter fm year_inst if ytag==1 & year_inst>10



g scaling_term = 1.41*(275*5043)/1324

replace bill = 1000*30*bill/scaling_term
replace supp = 1000*30*supp/scaling_term

sum bill, detail

g ln_bill = log(bill)
g ln_supp = log(supp)

g nrw=1-(bill/supp)
replace nrw=. if nrw<0 | nrw>1

g year_post= year - year_inst


g pT = year-year_inst
replace pT=. if pT>6 | pT<-6
replace pT=. if minpost!=0
gegen ptag=tag(pT)
* gegen mcv = mean(cv), by(pT)

sum nrw if pT<0
g nrw_pre = nrw if pT<0



drop nc* N_* yes_flow_pre yfm

g yes_flow_pre = yes_flow if post_treated==0
gegen yfm = mean(yes_flow_pre), by(mru)
egen nc = cut(yfm), at(0(.1)1)
gegen ncm=max(nc), by(dma)

tab ncm, g(N_)
foreach var of varlist N_* {
	g `var'_post_treated=`var'*post_treated
}

reghdfe cv N_*post_treated post_treated , absorb(conacct date)






asgen mcv = cv , w(SHO) by(pT)

twoway scatter mcv pT if ptag==1 & pT>=-4 & pT<=6, ylabel(18(1)22) 


reg cv nrw i.date
reg cv nrw i.date if nrw<.7

reghdfe cv post_treated, absorb(conacct date)
reghdfe nrw post_treated, absorb(conacct date)

ivreghdfe cv (nrw=post_treated), absorb(conacct date) cluster(mru)






gegen y_nrw = mean(nrw), by(year_post)
gegen cv_nrw = mean(cv), by(year_post)

gegen yptag=tag(year_post)

twoway scatter cv_nrw year_post if yptag==1 & year_post<500
twoway scatter y_nrw  year_post if yptag==1 & year_post<500



reghdfe cv nrw, absorb(conacct date) cluster(mru)
reghdfe cv nrw, absorb(date) cluster(mru)

reghdfe cv nrw if year_inst<2000, absorb(date) cluster(mru)
reghdfe cv nrw if year_inst<2007, absorb(date) cluster(mru)
reghdfe cv nrw if year_inst>2007, absorb(date) cluster(mru)

reghdfe nrw post_treated, absorb(conacct date) cluster(mru)
reghdfe cv  post_treated, absorb(conacct date) cluster(mru)

disp 1.8/.15



gegen nrg = cut(nrw), at(0(.05)1)
gegen cvg=mean(cv), by(nrg)
gegen nrtag=tag(nrg)
twoway scatter cvg nrg if nrtag==1





*                       |          kg
*               ba_name |         0          1 |     Total
* ----------------------+----------------------+----------
*                Cavite |       355        169 |       524 
* Fairview-Commonwealth |        86        402 |       488 
*       Malabon-Navotas |        13        278 |       291 
*  Muntinlupa-Las Pinas |       515        128 |       643 
*        North Caloocan |       240        212 |       452 
* Novaliches-Valenzuela |       153        344 |       497 
*             Paranaque |       261        268 |       529 
*     Quirino-Roosevelt |        16        495 |       511 
*              Sampaloc |         9        333 |       342 
*        South Caloocan |         9        339 |       348 
* South Manila-Pasay/.. |        37        396 |       433 
*                 Tondo |        17        415 |       432 
* ----------------------+----------------------+----------
*                 Total |     1,711      3,779 |     5,490 



use "${temp}pipe_year_old_dma.dta", clear
	* merge m:1 dma using "${temp}old_dma.dta", keep(3) nogen
	merge 1:m dma using "${temp}nrw.dta", keep(3) nogen
	g dated=dofm(date)
	g year=year(dated)

g ba = substr(dma,4,3)
gegen dg=group(dma)
drop dma
ren dg dma


gegen dtag=tag(dma)

* 275 connections per MRU
* 5043 MRUs, 1324 DMAs
* 1.41 HHs per connection

g scaling_term = 1.41*(275*5043)/1324

g post = year>=year_inst & year_inst<.
gegen minpost=min(post), by(dma)
g treated=minpost==0
g post_treated=post*treated


replace bill = 1000*30*bill/scaling_term
replace supp = 1000*30*supp/scaling_term

sum bill, detail

g ln_bill = log(bill)
g ln_supp = log(supp)

g nrw=1-(bill/supp)

g supp5=supp*5


keep if year>year_inst
keep if year_inst>1900

keep if date>=648


gegen m_nrw = mean(nrw), by(year_inst)
gegen ytag=tag(year_inst)

twoway scatter m_nrw year_inst if ytag==1 & year_inst>1900

* keep if year_inst>=2007


g year_post = year - year_inst

gegen y_nrw = mean(nrw), by(year_post)
gegen yptag=tag(year_post)


g o=1
gegen cN=sum(o), by(year_post)

twoway scatter y_nrw year_post if yptag==1 & year_post<40 || ///
	scatter cN year_post if yptag==1 & year_post<40, yaxis(2)


twoway scatter y_nrw year_post if yptag==1 & year_post<40

reg nrw year_post


twoway scatter y_nrw year_post if yptag==1 & year_post<40 & cN>100


tab year year_post if year_post<=10








g dma_g = dma if minpost==0
tab dma_g, g(D_)
foreach var of varlist D_* {
	replace `var'=0 if `var'==.
	g treated_`var' = `var'*post_treated
}


tab minpost if dtag==1

reghdfe nrw treated_D* , absorb(dma date) cluster(dma)
coefplot, vertical


reghdfe nrw post_treated, absorb(dma date) cluster(dma)





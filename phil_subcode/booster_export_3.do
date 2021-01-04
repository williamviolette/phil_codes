* pressure.do

* WHEN TO REPLACE PIPES?  
* 		DO NRW IDEA
* counterfactuals: straight monopoly, monopoly with fixed price, quality standards (ie. target NRW?) ?







grstyle init
grstyle set imesh, horizontal


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

areg bill post_treated i.date, a(dma) cluster(dma) r
	est sto nrw1
		sum bill, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
areg supp post_treated i.date, a(dma) cluster(dma) r
	est sto nrw2
		sum supp, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
* est save "${temp}nrw_supp", replace

areg supp5 post_treated i.date, a(dma) cluster(dma) r
	est sto nrw2
		sum supp, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
est save "${temp}nrw_supp", replace

* areg ln_bill post_treated i.date, a(dma) cluster(dma) r
* 	est sto nrw3
* 		sum ln_bill, detail
* 		estadd scalar varmean = `r(mean)'
* 		estadd local  ctrl_time1 "\checkmark"
* 		estadd local  ctrl_place "\checkmark"
* areg ln_supp post_treated i.date, a(dma) cluster(dma) r
* 	est sto nrw4
* 		sum ln_supp, detail
* 		estadd scalar varmean = `r(mean)'
* 		estadd local  ctrl_time1 "\checkmark"
* 		estadd local  ctrl_place "\checkmark"
areg nrw post_treated i.date, a(dma) cluster(dma) r
	est sto nrw5
		sum nrw, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"

	lab var post_treated "After Pipe Replacement"

	estout nrw1 nrw2 nrw5  using "${output}nrw.tex", replace  style(tex) ///
	 keep(  post_treated  ) ///
	order(  post_treated  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N  , ///
		  labels( "Mean"  "$\text{R}^{2}$"  "N"  )  ///
		    fmt( %12.2fc   %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


	* estout nrw1 nrw2 nrw3 using "${output}nrw.tex", replace  style(tex) ///
	*  keep(  post_treated  ) ///
	* order(  post_treated  ) ///
	* 	  label noomitted ///
	* 	  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
	* 	  stats( varmean ctrl_time1 ctrl_place r2 N  , ///
	* 	  labels( "Mean" "Calendar Month FE"  "Household FE" "$\text{R}^{2}$"  "N"  )  ///
	* 	    fmt( %12.2fc  %12s   %12s  %12.3fc %12.0fc  )   ) ///
	* 	  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 





	* .8 km * .19 million PhP/km = 152,000 PhP per MRU  ==  760 PhP per person

	* 220 users * 400 PhP === Outstanding investment! 

	* 5 yrs in between 


*** SHARING INCREASES WITH PIPE FIXES! (but only by a tiny amount..)

**  new accounts are still a mystery........... ( and come into play with uncertainty over pipe fixes... )











global do_est = 1 


use "${temp}final_analysis.dta", clear

replace treated=0 if shr<.8
replace post_treated=0 if shr<.8

 keep if cv!=.

replace inc = inc/10000

* gegen mt=tag(mru)
* sum length_tot if mt==1 & treated==1

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



* g yp = year-year_inst
* tab yp if post_treated==1
* forvalues r=1/6 {
* g pt_`r' = yp==`r' & post_treated==1
* }
* reghdfe cv pt_*, a(conacct date) cluster(mru)
	

*** TRY CONTROLLING FOR PRETRENDS FOR ELASTICITY

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
by conacct: g s_to_r_id = class[_n]==2 & class[_n+1]==1
replace s_to_r_id=. if date_sr_id==577
replace date_sr_id=. if date_sr_id==577
gegen date_sr=min(date_sr_id), by(conacct)

g Trs = date-date_rs
g Tsr = date-date_sr


		* areg cv post_treated pa_adj  i.date [pweight = SHO] , a(conacct) 

*** HOW TO BEST CONTROL FOR TRENDS?!
g Trs_pre = Trs if Trs<0
replace Trs_pre = 0 if Trs_pre==. 
g Trs_post = Trs if Trs>0
replace Trs_post = 0 if Trs_post==. 
g rs_post = Trs>0 & Trs<.

g Trs_pre2=Trs_pre^2
g Trs_post2=Trs_post^2
g Trs_pre3=Trs_pre^3
g Trs_post3=Trs_post^3

g Tsr_pre = Tsr if Tsr<0
replace Tsr_pre = 0 if Tsr_pre==. 
g Tsr_post = Tsr if Tsr>0
replace Tsr_post = 0 if Tsr_post==. 

lab var Trs_pre "t pre P ch"
lab var Trs_post "t post P ch"

lab var Trs_pre2 "t sq pre P ch"
lab var Trs_post2 "t sq post P ch"

lab var Trs_pre3 "t cu pre P ch"
lab var Trs_post3 "t cu post P ch"





set seed 15


global bno=10
mat def ef = J($bno,3,0)

forvalues r = 1/$bno {
	global tag = "_`r'"
	preserve
		keep mru
		gegen mtag=tag(mru)
		keep if mtag==1
		drop mtag
		bsample
		duplicates tag mru, g(D)
		duplicates drop mru, force
		replace D = D+1 
		save "${temp}boot_temp.dta", replace
	restore

	preserve
		merge m:1 mru using "${temp}boot_temp.dta", keep(3) nogen

		sort mru conacct date
		expand D
		sort mru conacct date
		by mru conacct date: g dn=_n

		gegen conacct1=group(conacct dn)

		ivreghdfe cv post_treated  Trs_pre Trs_post (pa_adj = rs_post )  [pweight = SHO], absorb(conacct1 date)  cluster(mru) 
		* areg cv post_treated pa_adj i.date [pweight = SHO] , a(conacct1) 
		est save "${temp}cv_b`r'", replace
		* est sto cv_b`r'
		qui mean cv [pweight = SHO ] 
		est save "${temp}mm_b`r'", replace
  *   	mat j=e(b)
		* estadd scalar varmean = `=j[1,1]'

		ivreghdfe B post_treated  Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1  , absorb(conacct1 date)  cluster(mru) 
		* areg B post_treated pa_adj i.date [pweight = SHO] if paws==1, a(conacct1)
		est save "${temp}bb_b`r'", replace

	restore
}


global F = 486

forvalues r=1/$bno {
est use "${temp}cv_b`r'"
	mat def bb=e(b)
	global dqdr = bb[1,2]
	global alpha = bb[1,1]

est use "${temp}bb_b`r'"
	mat def bb=e(b)
	global dbdr = bb[1,2]
est use "${temp}mm_b`r'"
	mat def bb=e(b)
	global wstar = bb[1,1]

mat ef[`r',1] =  $dqdr*($wstar/-$alpha)
mat ef[`r',2] = -$dbdr*$F
mat ef[`r',3] =  $dqdr*($wstar/-$alpha) -$dbdr*$F
}


preserve
	clear
	svmat ef 
    sum ef1
    local value1=string(`=r(sd)',"%12.1fc")
    sum ef2
    local value2=string(`=r(sd)',"%12.1fc")
    sum ef3
    local value3=string(`=r(sd)',"%12.1fc")

    file open newfile using "${output}sd_welfare.tex", write replace
    file write newfile "(`value1') & (`value2') & (`value3')"
    file close newfile    
restore


	if $do_est == 1 {
		ivreghdfe cv post_treated  Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		* areg cv post_treated pa_adj  ///
		*  i.date [pweight = SHO] , a(conacct) cluster(mru) r
			est save "${temp}cv1", replace

		ivreghdfe B post_treated  Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
		* areg B post_treated pa_adj  ///
		*  i.date [pweight = SHO] if paws==1, a(conacct) cluster(mru) r
			est save "${temp}cv2", replace
	}


* areg B pa_adj post_treated Trs_pre Trs_post i.date if paws==1, a(mru)
* ivreghdfe  B pa_adj post_treated Trs_pre Trs_post i.date if paws==1, a(mru)


	qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv1"
		mat ee=e(b)
		estadd scalar varmean = `=j[1,1]'
		global cm = `=j[1,1]'
			global cm_st = string(`=j[1,1]',"%12.1fc")
		    file open newfile using "${output}cm.tex", write replace
    		file write newfile " $cm_st  "
    		file close newfile 
    	global dqdrm = `=ee[1,2]'
			global dqdr_st = string(`=ee[1,1]',"%12.2fc")
		    file open newfile using "${output}dqdrm.tex", write replace
    		file write newfile " $dqdr_st  "
    		file close newfile 
    	global alpham = `=ee[1,1]'
			global alpha_st = string(`=ee[1,2]',"%12.2fc")
		    file open newfile using "${output}alpham.tex", write replace
    		file write newfile " $alpha_st  "
    		file close newfile 
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv1s", replace

	qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv2"
		mat ee=e(b)
			global bm = `=j[1,1]'
			global bm_st = string(`=j[1,1]',"%12.1fc")
		    file open newfile using "${output}bm.tex", write replace
    		file write newfile " $bm_st "
    		file close newfile 

    		global dbdrm = `=ee[1,2]'
			global dbdr_st = string(`=ee[1,2]',"%12.2fc")
		    file open newfile using "${output}dbdrm.tex", write replace
    		file write newfile " $dbdr_st  "
    		file close newfile 
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv2s", replace

    local value1=string(`=$dqdrm*($cm/-$alpham)',"%12.1fc")
    local value2=string(`=-$dbdrm*$F',"%12.1fc")
    local value3=string(`=($dqdrm*($cm/-$alpham)) -$dbdrm*$F',"%12.1fc")

	file open newfile using "${output}est_welfare.tex", write replace
    file write newfile " `value1' & `value2' & `value3'"
    file close newfile   


	forvalues r=1/2 {
		est use "${temp}cv`r's"
		est sto cv`r's
	}

estout cv1s cv2s using "${output}reg.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj  ) ///
	order(  post_treated pa_adj  ) ///
		  label noomitted ///
		  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N dataset , ///
		  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


estout cv1s cv2s using "${output}reg_full.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj Trs_pre Trs_post ) ///
	order(  post_treated pa_adj Trs_pre Trs_post ) ///
		  label noomitted ///
		  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N dataset , ///
		  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


estout cv1s cv2s using "${output}reg_stars.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj  ) ///
	order(  post_treated pa_adj  ) ///
		  label noomitted ///
		  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N dataset , ///
		  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) 

ivreghdfe cv post_treated  Trs_pre Trs_post Trs_pre2 Trs_post2 Trs_pre3 Trs_post3 (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 




	if $do_est == 1 {
		ivreghdfe cv post_treated post_treated_* hhsize hhemp good_job sub single Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		* areg cv post_treated pa_adj post_treated_* hhsize hhemp good_job sub single ///
		*  i.date [pweight = SHO] , a(conacct) cluster(mru) r	
		 est save "${temp}cv1h", replace
		ivreghdfe cv post_treated inc__post_treated inc Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		* areg cv post_treated pa_adj inc__post_treated inc  ///
		*  i.date [pweight = SHO] , a(conacct) cluster(mru) r
		 est save "${temp}cv2h", replace
		ivreghdfe B post_treated post_treated_* hhsize hhemp good_job sub single Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
		* areg B post_treated pa_adj post_treated_*  hhsize hhemp good_job sub single ///
		*  i.date [pweight = SHO]  if  paws==1, a(mru) cluster(mru) r
		 est save "${temp}cv3h", replace
		ivreghdfe B post_treated inc__post_treated inc Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
		* areg B post_treated pa_adj inc__post_treated inc  ///
		*  i.date [pweight = SHO] if paws==1, a(mru) cluster(mru) r
		 est save "${temp}cv4h", replace
	}

		qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv1h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv1hs", replace

		qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv2h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv2hs", replace

		qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv3h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv3hs", replace

		qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv4h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv4hs", replace



	forvalues r=1/4 {
		est use "${temp}cv`r'hs"
		est sto cv`r'hs
	}


lab var post_treated "Post"

estout cv1hs cv2hs cv3hs cv4hs using "${output}reghet.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj  ///
	 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
	 		hhsize hhemp good_job sub single inc  ) ///
	order(  post_treated pa_adj ///
			post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
	 		hhsize hhemp good_job sub single inc ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
		  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


estout cv1hs cv2hs cv3hs cv4hs using "${output}reghet_stars.tex", replace  style(tex) ///
	 keep(  post_treated   ///
	 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
	 		hhsize hhemp good_job sub single inc  ) ///
	order(  post_treated  ///
			post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
	 		hhsize hhemp good_job sub single inc ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
		  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) 


estout cv1hs cv3hs using "${output}reghet_stars_int.tex", replace  style(tex) ///
	 keep(  post_treated   ///
	 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single  ) ///
	order(  post_treated  ///
			post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single   ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
		  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) 




sum pa_adj, detail
* 21 PhP
* PER MRU : 152,000 PhP
* SURPLUS : 250 accounts * avg HHs (1.4) * HH surplus (1.8*(22/.15) use + .2*480 boost  ) 
* = ( 264 use + 96 boost )* 350 
* = 92,400 use + 33,600 boost
* PROFITS : 250 accounts * 3.7 c per account * (21 price - 5 mc) = 14,680 PhP per MRU (12 months, paid for!)
*** World Bank reports on NRW
*** Water and sanitation benefits!?





cap prog drop print_mean2
program print_mean2
    qui mean `2' [pweight = SHO ] if treated==1 & post==0 & paws==1
    mat j=e(b)
    local value1=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if treated==1 & post==1 & paws==1
    mat j=e(b)
    local value2=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if paws==1
    mat j=e(b)
    local value3=string(`=j[1,1]*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


cap prog drop print_mean2n
program print_mean2n
    qui sum `2' if minpost==0 & post==0, detail 
    local value1=string(`=r(N)*`4'',"`3'")
    qui sum `2' if minpost==0 & post==1, detail 
    local value2=string(`=r(N)*`4'',"`3'")
    qui sum `2', detail 
    local value3=string(`=r(N)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end




use "${temp}final_analysis.dta", clear

g paws=smell!=.

preserve 
	g no_flow_6mid = fl_6_mid==1
	g yes_flow_6mid = fl_6_mid==4
	g taste_smell= taste==1 | smell==1
	replace booster_use = . if booster_use>=24
	g deepwell = wrs_type==2
	g station = wrs_type==1

	keep if paws==1
	g SHO1=SHO-1

	print_mean2 flow_hrs flow_hrs  "%10.2fc" 1
	print_mean2 stop_freq stop_freq  "%10.2fc" 1
	print_mean2 yes_flow_6mid  yes_flow_6mid  "%10.2fc" 1
	print_mean2 no_flow_6mid  no_flow_6mid    "%10.2fc" 1
	print_mean2 foreign_bodies  stuff    "%10.2fc" 1
	print_mean2 discolored  color        "%10.2fc" 1
	print_mean2 taste_smell taste_smell  "%10.2fc" 1

	print_mean2 booster  B "%10.2fc" 1
	print_mean2 booster_use  booster_use "%10.2fc" 1
	print_mean2 drum  drum "%10.2fc" 1
	print_mean2 filter  filter "%10.2fc" 1

	print_mean2 station   station   "%10.2fc" 1
	print_mean2 deepwell  deepwell  "%10.2fc" 1
	print_mean2 wrs_exp   wrs       "%10.2fc" 1
	print_mean2 drink  drink  "%10.2fc" 1
	print_mean2 boil   boil   "%10.2fc" 1

	print_mean2 hhsize  hhsize   "%10.2fc" 1
	print_mean2 hhemp  hhemp   "%10.2fc" 1
	print_mean2 good_job  good_job   "%10.2fc" 1
	print_mean2 sub  sub   "%10.2fc" 1
	print_mean2 single single  "%10.2fc" 1
	print_mean2 SHO   SHO1   "%10.2fc" 1

	print_mean2n pawsn B "%10.0fc" 1
restore


g class_ch=class_max!=class_min


sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g cch = 1 if class_max==class_min & class==1
replace cch=2 if class_max==class_min & class==2
replace cch=3 if date_rs!=.

cap prog drop print_mean2s
program print_mean2s
    qui mean `2' [pweight = SHO ] if cch==1 & paws==1
    mat j=e(b)
    local value1=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if cch==2  & paws==1
    mat j=e(b)
    local value2=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if cch==3  & paws==1
    mat j=e(b)
    local value3=string(`=j[1,1]*`4'',"`3'")
    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


cap prog drop print_mean2Ns
program print_mean2Ns
    qui sum `2' if cch==1 & paws==1, detail 
    local value1=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==2 &  paws==1, detail 
    local value2=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==3 &  paws==1, detail 
    local value3=string(`=r(N)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


g SHO1=SHO
replace SHO1=SHO1-1

print_mean2s cv_rs  cv   "%10.2fc" 1
print_mean2s hhsize_rs  hhsize   "%10.2fc" 1
print_mean2s hhemp_rs  hhemp   "%10.2fc" 1
print_mean2s good_job_rs  good_job   "%10.2fc" 1
print_mean2s sub_rs  sub   "%10.2fc" 1
print_mean2s single_rs single  "%10.2fc" 1
print_mean2s SHO_rs   SHO1   "%10.2fc" 1

print_mean2Ns N_rs  hhsize   "%10.0fc" 1








use "${temp}final_analysis.dta", clear



g pT = year-year_inst
replace pT=. if pT>6 | pT<-6
replace pT=. if minpost!=0
gegen ptag=tag(pT)
* gegen mcv = mean(cv), by(pT)

asgen mcv = cv , w(SHO) by(pT)

label var mcv "Water Use per Household (m3)"
label var pT  "Years to Pipe Replacement"

    mean cv [pweight = SHO ] if pT>=-4 & pT<0
    mat j=e(b)
    global c_pre = j[1,1]
    local value=string($c_pre ,"%12.1fc")
    file open newfile using "${output}c_pre.tex", write replace
    file write newfile "`value'"
    file close newfile   

    mean cv [pweight = SHO ] if pT>=0 & pT<=6
    mat j=e(b)
    global c_post = j[1,1]
    local value=string($c_post,"%12.1fc")
    file open newfile using "${output}c_post.tex", write replace
    file write newfile "`value'"
    file close newfile   

    local value=string($c_post - $c_pre ,"%12.1fc")
    file open newfile using "${output}c_diff.tex", write replace
    file write newfile "`value'"
    file close newfile   

	local value=string(100*($c_post - $c_pre)/$c_pre ,"%12.0fc")
    file open newfile using "${output}c_diff_per.tex", write replace
    file write newfile "`value'"
    file close newfile   


twoway scatter mcv pT if ptag==1 & pT>=-4 & pT<=6, ylabel(18(1)22) ///
	note("Avg. Pre:  `=string($c_pre ,"%12.1fc")'    Avg. Post:  `=string($c_post ,"%12.1fc")' ")
graph export "${output}pipe_cons.pdf", as(pdf) replace 



g pTn = year - year_inst
replace pTn = . if treated!=1
replace pTn=10 if pTn==.
replace pTn=pTn+10

areg cv i.pTn i.date [pweight = SHO] , a(conacct) cluster(mru)
coefplot, vertical keep(*pTn*)

preserve
	parmest, fast
	g time = regexs(1) if regexm(parm,"(^[0-9]+).pTn")
	destring time, replace
	keep if time!=.
	replace time= time-10
	lab var time "Years to Pipe Replacement"
	twoway rcap max95 min95 time || scatter estimate time , legend(off)
	graph export "${output}time_to_event.pdf", as(pdf) replace
restore







use "${temp}final_analysis.dta", clear

****** R TO S ANALYSIS ! ********
sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)


g year_rs_id = year if r_to_s_id==1
* replace year_rs_id=. if year_rs_id==577
gegen year_rs = min(year_rs_id), by(conacct)

by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
gegen date_sr=min(date_sr_id), by(conacct)

by conacct: g year_sr_id = year if class[_n]==2 & class[_n+1]==1
gegen year_sr=min(year_sr_id), by(conacct)


cap drop Trs
cap drop Tsr
cap drop cv_rs
cap drop cv_sr
cap drop rstag
cap drop srtag

* g Trs = year-year_rs
* replace Trs=. if Trs>6 | Trs<-6
* g Tsr = year-year_sr
* replace Tsr=. if Tsr>6 | Tsr<-6

g Trs = date-date_rs
replace Trs=. if Trs>42 | Trs<-42
g Tsr = date-date_sr
replace Tsr=. if Tsr>42 | Tsr<-42

asgen cv_rs =cv, by(Trs) w(SHO)
asgen cv_sr =cv, by(Tsr) w(SHO)

gegen rstag=tag(Trs)
gegen srtag=tag(Tsr)

lab var cv_rs "Usage (m3) per Household-Month"
lab var cv_sr "High Price to Regular Price"

lab var Trs "Months to Price Change"
lab var Tsr "Months to Price Change"

sum pa_adj if sem==1
sum pa_adj if sem==0

gegen pa_adjm=mean(pa_adj), by(Trs)
lab var pa_adjm "PhP per m3"

twoway scatter cv_rs Trs if rstag==1 & Trs>=-24 & Trs<=24 || ///
	 scatter pa_adjm Trs if rstag==1 & Trs>=-24 & Trs<=24 , yaxis(2) ms(diamond)  ///
	legend(order(1 "Usage" 2 "Price") symx(6) col(1) ///
    ring(0) position(3) bm(medium) rowgap(small)  ///
    colgap(small) size(*.95) region(lwidth(none)))


graph export "${output}r_to_s_only_graph.pdf", as(pdf) replace





twoway 	scatter cv_sr Tsr if srtag==1 & Tsr>=-36 & Tsr<=36,  msymbol(triangle) msize(medium)  || ///
		scatter cv_rs Trs if rstag==1 & Trs>=-36 & Trs<=36,   ///
		legend(order(2 "Regular Price to High Price" 1 "High Price to Regular Price") symx(6) col(1) ///
    ring(0) position(2) bm(medium) rowgap(small)  ///
    colgap(small) size(*.95) region(lwidth(none)))

graph export "${output}r_to_s_graph.pdf", as(pdf) replace



cap drop TrsD
cap drop TsrD

g TrsD= Trs + 100
	replace TrsD=200 if TrsD==.

g TsrD= Tsr + 100
	replace TsrD=200 if TsrD==.

areg cv i.TrsD i.TsrD i.date, a(conacct)
	coefplot, vertical keep(*TrsD* *TsrD*)




foreach v in rs {
	 * local v "rs"

    mean cv_`v' [pweight = SHO ] if `v'tag==1 & T`v'>=-4 & T`v'<0
	    mat j=e(b)
	    global c_pre_`v' = j[1,1]
	    local value=string(${c_pre_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_pre_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile    
	mean cv_`v' if `v'tag==1 & T`v'>=0 & T`v'<=4
	    mat j=e(b)
	    global c_post_`v' = j[1,1]
	    local value=string(${c_post_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_post_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   

	    local value=string(${c_post_`v'} - ${c_pre_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_diff_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   

		local value=string(100*(${c_post_`v'} - ${c_pre_`v'} )/${c_pre_`v'} ,"%12.0fc")
	    file open newfile using "${output}c_diff_per_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   
}











use "${temp}final_analysis.dta", clear

	replace amount = . if amount<0 | amount>60*200

	replace c = c/SHO
	replace amount = amount/SHO

	if $do_est == 1 {
	reghdfe c post_treated [pweight=SHO], a(conacct date) cluster(mru)
	estimates save "${temp}c1", replace
	reghdfe amount post_treated [pweight=SHO], a(conacct date) cluster(mru)
	estimates save "${temp}c2", replace
	}

	estimates use "${temp}c1"
		sum c, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_dataset "Residential"
	estimates save "${temp}c1s", replace

	estimates use "${temp}c2"
		sum amount, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_dataset "Residential"
	estimates save "${temp}c2s", replace


est use "${temp}nrw_supp"
est sto supp

est use "${temp}c2s"
est sto bill

lab var post_treated "After Pipe Replacement"

	estout bill supp  using "${output}savings.tex", replace  style(tex) ///
	 keep(  post_treated  ) ///
	order(  post_treated  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N  , ///
		  labels( "Mean"  "$\text{R}^{2}$"  "N"  )  ///
		    fmt( %12.2fc   %12.3fc %12.0fc  )   ) 




use "${temp}comm_amountm.dta", clear
	drop billclass_key
	fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
	keep amount date billclass_key conacct mru datec
	ren billclass_key billclass

	fmerge m:1 conacct date using "${temp}comm_billm.dta", keep(3) nogen
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

	g dated=dofm(date)
	g year=year(dated)

	g post = year>=year_inst & year_inst<.
	gegen minpost=min(post), by(mru)
	g treated=minpost==0
	g post_treated = post*treated

	drop if date==653

sum c, detail
keep if c<`=r(p95)'
replace amount = . if amount<=0 | amount>=`=r(p95)*80'



if $do_est == 1 {
areg c      post_treated i.date , a(conacct) cluster(mru) r
	estimates save "${temp}c3", replace
areg amount post_treated i.date , a(conacct) cluster(mru) r
	estimates save "${temp}c4", replace
}


	estimates use "${temp}c3"
		sum c, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_dataset "Commercial"
	estimates save "${temp}c3s", replace

	estimates use "${temp}c4"
		sum amount, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_dataset "Commercial"
	estimates save "${temp}c4s", replace


	lab var post_treated "After Pipe Replacement"


	forvalues r=1/4 {
		est use "${temp}c`r's"
		est sto c`r's
	}

	estout c1s c2s c3s c4s using "${output}profitreg.tex", replace  style(tex) ///
	 keep(  post_treated  ) ///
	order(  post_treated  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  ctrl_dataset r2 N  , ///
		  labels( "Mean" "Connection Type" "$\text{R}^{2}$"  "N"  )  ///
		    fmt( %12.2fc  %12s  %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

	* estout c1s c2s c3s c4s using "${output}profitreg.tex", replace  style(tex) ///
	*  keep(  post_treated  ) ///
	* order(  post_treated  ) ///
	* 	  label noomitted ///
	* 	  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
	* 	  stats( varmean ctrl_time1 ctrl_place ctrl_dataset r2 N  , ///
	* 	  labels( "Mean" "Calendar Month FE"  "Household FE" "Connection" "$\text{R}^{2}$"  "N"  )  ///
	* 	    fmt( %12.2fc  %12s   %12s %12s  %12.3fc %12.0fc  )   ) ///
	* 	  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 








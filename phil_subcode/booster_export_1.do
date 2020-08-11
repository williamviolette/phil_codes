* pressure.do


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


* odbc load, exec("SELECT * FROM dma")  dsn("phil") clear  
* 	destring mru, replace force






use "${temp}pipe_year_old_dma.dta", clear
	merge 1:m dma using "${temp}nrw.dta", keep(3) nogen
	g dated=dofm(date)
	g year=year(dated)

gegen dtag=tag(dma)

g scaling_term = (270*5043)/1324

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



		use "${data}paws/clean/full_sample_b_1.dta", clear

		destring may_exp_extra, replace force
		ren may_exp_extra me

		foreach v in 6_noon noon_6 6_mid mid_6 {
			g fl_`v' = 1 if flow_`v'=="Wala"
			replace fl_`v'=2 if flow_`v'=="Mahina"
			replace fl_`v'=3 if flow_`v'=="Katamtaman"
			replace fl_`v'=4 if flow_`v'=="Malakas"
		}

		replace drink_freq="3" if drink_freq=="Palagi"
		replace drink_freq="2" if drink_freq=="Madalas"
		replace drink_freq="1" if drink_freq=="Minsan"

		replace filter="1" if filter=="Oo"
		replace filter="0" if filter=="Hindi"

		destring drink_freq filter, replace force
		g yes_flow = flow_noon_6=="Malakas"
		g no_flow=flow_noon_6=="Wala"
		destring flow_hrs, replace force
		replace flow_hrs = . if flow_hrs==0

		g yr=substr(interview_completion_date,1,4)
		g mn=substr(interview_completion_date,6,2)
		destring yr mn, replace force
		g date=ym(yr,mn)
		ren yr year
		drop mn

		g balde= storage=="Balde"
		g drum= storage=="Drum"
		g gallon= storage=="Galon"

		destring hhsize, replace force
		g hhsize1 = hhsize
		replace hhsize1=. if hhsize>12

		destring shr_hh_extra, replace force
		ren shr_hh_extra SHO
		replace SHO=1 if SHO==. & wave==4
		replace SHO=4 if SHO>4 & SHO<.
 			g SHH = shr_num_extra
			destring SHH, replace force
			g hho= SHH - hhsize1
			replace hho=0 if hho<0
		replace SHO = 2 if hho>0 & hho<=5 & wave==3
		replace SHO = 3 if hho>5 & hho<=11 & wave==3
		replace SHO = 4 if hho>11 & hho<. & wave==3
		replace SHO = 1 if hho==0 & wave==3

		g B = booster=="Oo"
		g S = storage!=""
		destring hhemp, replace force

			drop age
			ren age age
			destring age, replace force
		
		**** KEY DROP SECTION ****
		drop if hhemp>12
		drop if hhsize>16
		drop if SHO==.
		* drop if age>100 | age<12
		

			g sub=regexm(house,"Subdivided")==1
			g single=regexm(house,"Single house")==1

			ren drink drink_id
			g drink = 0 if drink_id=="Hindi"
			replace drink = 1 if drink_id=="Oo"
			ren boil boil_id
			g boil = 0 if boil_id=="Hindi"
			replace boil = 1 if boil_id == "Oo"

			destring wrs_exp_extra alt_src_extra, replace force
			g wrs = alt_src_extra
			replace wrs = wrs_exp_extra if wrs==. & wrs_exp_extra!=.

			g wrs_type = 1 if regexm(alt_src,"refill")==1
			replace wrs_type = 2 if regexm(alt_src,"Deep")==1 | regexm(alt_src,"Pribado")==1  | regexm(alt_src,"Iba pang")==1
			replace wrs_type = 0 if wrs_type==.

			destring job, replace force
			ren class sclass

		keep date year me conacct  SHO drink_freq filter fl_* hhsize drink boil wrs wrs_type no_flow yes_flow flow_hrs barangay B S wave balde drum gallon sub single hhemp hho job age  sclass

		merge 1:1 conacct wave using "${temp}paws_prefs_b.dta", keep(1 3) nogen

		ren pf_qual_flow pf_qual_compl
		recode booster_need (0 = 1) (1=0)
			duplicates drop conacct date, force
		save "${temp}paws_aib1.dta", replace














use "${temp}bill_paws_full_ts.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2
gegen class_min=min(class), by(conacct)

	fmerge m:1 conacct date using "${temp}paws_aib1.dta", keep(1 3) nogen
	drop year
	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop if date<datec
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen

	g amt = amount if amount>0 & amount<10000

g dated=dofm(date)
g year=year(dated)

g post = year>=year_inst & year_inst<.
g sem = class==2

gegen minpost=min(post), by(mru)
g treated=minpost==0

g month = month(dated)

g w3_id = wave==3
g w4_id = wave==4
g w5_id = wave==5
gegen w3=max(w3_id), by(conacct)
gegen w4=max(w4_id), by(conacct)
gegen w5=max(w5_id), by(conacct)
drop w3_id w4_id w5_id

g good_job =  job>=3 & job<.

g booster_use1= booster_use
replace booster_use1=. if booster_use==24
sum booster_use1, detail


sum B if post==0 & minpost==0
global rpre=`=r(mean)'
sum B if post==1 & minpost==0
global rpost=`=r(mean)'
disp $rpost-$rpre

* sum c, detail 
g mc = 28 // plug in AVERAGE consumption

g p1 = amt/c
replace p1 = . if p1<5 | p1>100
replace p1= . if c!=mc

gegen pa = mean(p1), by(date class)

g pa_adj = pa
replace pa_adj = 15.6 if (date==584 | date==585)  &  class==1
replace pa_adj = 21 if (date==584 | date==585 | date==587 | date==588 | date==590 | date==591)  &  class==2

* gegen dct=tag(class date)
* twoway scatter pa_adj date if dct==1


foreach v in B  filter drum SHO hho hhsize sub single hhemp good_job {
	g `v'_3_id = `v' if wave==3
	g `v'_4_id = `v' if wave==4
	g `v'_5_id = `v' if wave==5
	
	gegen `v'_3 = max(`v'_3_id), by(conacct)
	gegen `v'_4 = max(`v'_4_id), by(conacct)
	gegen `v'_5 = max(`v'_5_id), by(conacct)
	drop  `v'_3_id `v'_4_id `v'_5_id

	replace `v' = `v'_3 if year<=2010 & w3==1 & w4==0 & w5==0
	replace `v' = `v'_4 if year<=2010 & w3==0 & w4==1 & w5==0
	replace `v' = `v'_5 if year>=2010 & w3==0 & w4==0 & w5==1

	replace `v' = `v'_4 if year<2010  & w3==0 & w4==1 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==0 & w4==1 & w5==1

	replace `v' = `v'_3 if year<2010  & w3==1 & w4==0 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==1 & w4==0 & w5==1

	replace `v' = `v'_3 if year<2009  & w3==1 & w4==1 & w5==0
	replace `v' = `v'_4 if year>=2009 & w3==1 & w4==1 & w5==0

	replace `v' = `v'_3 if year==2008 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_4 if year==2009 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_5 if year==2010 & w3==1 & w4==1 & w5==1

	drop `v'_3 `v'_4 `v'_5
}

* g class_change = class_max!=class_min
	* reg c  post B pa_adj i.class_max class_change treated i.date 
	* reg c  post B pa_adj i.class_max class_change treated  hhsize hhemp good_job  i.date
	* areg c post pa_adj  i.class_max class_change i.date,  a(mru)
	* areg c post pa_adj i.date,  a(conacct)

g tot_hh =  hho+hhsize
g c_shr  = hhsize/tot_hh

g cv = c*c_shr

cap drop rng_id 
cap drop md
cap drop cn
cap drop rd

set seed 3
g rng_id = runiform()
gegen md=min(date), by(conacct)
replace md = 0 if md==date
sort md rng_id conacct
g cn=_n
gegen rd = min(cn), by(conacct)

g cch = class_max==class_min
sort cch md rng_id conacct
by cch: g cnch=_n
gegen rdch=min(cnch), by(conacct)

	foreach var of varlist  cv B post pa_adj year month  class_max class_min hhsize hhemp good_job  SHO {
		drop if `var'==.
	}

	drop if date==653
	g post_treated=post*treated

// drops 2% of observations, likely measurement error!
keep if c<200

save "${temp}final_analysis.dta", replace





global do_est = 1 


use "${temp}final_analysis.dta", clear


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

g post_treated_hhsize= post_treated*hhsize
g post_treated_hhemp= post_treated*hhemp
g post_treated_good_job= post_treated*good_job
g post_treated_sub = post_treated*sub
g post_treated_single = post_treated*single

	lab var post_treated "After Pipe Replacement"
	lab var B "Use Booster Pump"
	lab var cv "Usage per Household (m3)"

	lab var pa_adj "Avg. Price (PhP)"
	lab var clmax "Ever High Price"
	lab var semm "Change High to Low Price"
	lab var resm "Change Low to High Price"
	lab var hhsize "Household Size"
	lab var hhemp "Employed Household Members"
	lab var good_job "High Skilled Employment"
	lab var sub "Subdivided House/Duplex"
	lab var single "Freestanding House"

	if $do_est == 1 {
	areg cv post_treated pa_adj  ///
	hhsize hhemp good_job sub single ///
	clmax semm resm ///
	 i.date [pweight = SHO] , a(mru) cluster(mru) r
		est save "${temp}cv1", replace

	areg cv post_treated pa_adj  ///
	 i.date [pweight = SHO] , a(conacct) cluster(mru) r
		est save "${temp}cv2", replace

	areg B post_treated pa_adj  ///
	hhsize hhemp good_job sub single ///
	clmax semm resm ///
	 i.date [pweight = SHO] if paws==1, a(mru) cluster(mru) r
		est save "${temp}cv3", replace
	}

	est use "${temp}cv1"
		sum cv, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local dataset "Billing Panel"
	est save "${temp}cv1s", replace

	est use "${temp}cv2"
		sum cv, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv2s", replace

	est use "${temp}cv3"
		sum B if paws==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv3s", replace


	forvalues r=1/3 {
		est use "${temp}cv`r's"
		est sto cv`r's
	}

estout cv1s cv2s cv3s using "${output}reg.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj  hhsize hhemp good_job sub single clmax semm resm ) ///
	order(  post_treated pa_adj  hhsize hhemp good_job sub single clmax semm resm  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean ctrl_time1 ctrl_place ctrl_ind r2 N  dataset , ///
		  labels( "Mean" "Calendar Month FE"  "Small-Area FE" "Household FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
		    fmt( %12.2fc  %12s   %12s %12s  %12.3fc %12.0fc %12s  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 







		* eststo cv4
		* sum cv if e(sample)==1, detail
		* estadd scalar varmean = `r(mean)'
		* estadd local  ctrl_time1 "\checkmark"
		* estadd local  ctrl_place ""
		* estadd local  ctrl_ind "\checkmark"
		* estadd local dataset "Billing Panel"


sum pa_adj, detail
* 21 PhP


* PER MRU : 152,000 PhP

* SURPLUS : 250 accounts * avg HHs (1.4) * HH surplus (1.8*(22/.15) use + .2*480 boost  ) 
* = ( 264 use + 96 boost )* 350 
* = 92,400 use + 33,600 boost

* PROFITS : 250 accounts * 3.7 c per account * (21 price - 5 mc) = 14,680 PhP per MRU (12 months, paid for!)

*** World Bank reports on NRW
*** Water and sanitation benefits!?

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





use "${temp}final_analysis.dta", clear

	replace amount = . if amount<0 | amount>60*200

	if $do_est == 1 {
	areg c post_treated i.date , a(conacct) cluster(mru) r
	estimates save "${temp}c1", replace
	areg amount post_treated i.date , a(conacct) cluster(mru) r
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








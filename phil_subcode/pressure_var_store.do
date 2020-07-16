


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
		replace hhsize=. if hhsize>12

		g B = booster=="Oo"
		g S = storage!=""
		destring hhemp, replace force
		replace hhemp=. if hhemp>12
			g SHH = shr_num_extra
			destring SHH, replace force
			g hho= SHH - hhsize
			replace hhsize = . if hhsize>12
			replace hho = . if hho<0 | hho>14

			drop age
			ren age age
			destring age, replace force
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


		keep date year me conacct drink_freq filter fl_* hhsize drink boil wrs wrs_type no_flow yes_flow flow_hrs barangay B S wave balde drum gallon sub single hhemp hho job age  sclass

		merge 1:1 conacct wave using "${temp}paws_prefs_b.dta", keep(1 3) nogen

		ren pf_qual_flow pf_qual_compl
		recode booster_need (0 = 1) (1=0)
			duplicates drop conacct date, force
		save "${temp}paws_aib1.dta", replace




use "${temp}paws_aib1.dta", clear

replace year=2008 if year<2008

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
		drop ba zone_code dc-bus
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

g post = 0 if  year<year_inst  & year_inst!=.
replace post = 1 if  year>=year_inst & year_inst!=.
g postf = 0 if  year<=year_inst  & year_inst!=.
replace postf = 1 if  year>year_inst & year_inst!=.

replace age = 99 if age>99
replace me =. if me>5000
replace wrs=. if wrs>500
g well = wrs_type==2
replace well=. if wave==5
g rs = wrs_type==1
replace stop_freq = 0 if stop_freq==.
replace stop_freq = 5 if stop_freq>5 & stop_freq<.
replace stop_length=. if stop_length>24


foreach var of varlist pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr pf_flow_compl pf_flow_qual pf_qual_flow {
	replace `var'=. if `var'==0 
	replace `var'=0 if `var'==2
}

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

gegen yt=tag(mru year)
gegen ptt=tag(pT)
gegen minpost=min(post), by(mru)

foreach var of varlist fl_* {
	g y`var'=`var'==4
}

foreach var of varlist yfl* fl_*  yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp S hho {
	gegen `var'_y=mean(`var'), by(mru year)
}

foreach var of varlist yfl* fl_*  yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp S hho {
	gegen `var'_M=mean(`var'), by(pT)
}



twoway scatter yes_flow_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter no_flow_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter B_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter hho_M pT if ptt==1 & pT>=6 & pT<=16

twoway scatter hhemp_M pT if ptt==1 & pT>=6 & pT<=16



areg yfl_6_noon_y post i.year, a(mru) cluster(mru) r
areg yfl_noon_6_y post i.year, a(mru) cluster(mru) r
areg yfl_6_mid_y post i.year, a(mru) cluster(mru) r
areg yfl_mid_6_y post i.year, a(mru) cluster(mru) r


areg flow_hrs_y post i.year, a(mru) cluster(mru) r


areg stop_freq postf i.year , a(mru) cluster(mru) r
areg stop_length postf i.year , a(mru) cluster(mru) r



areg drink_freq postf i.year , a(mru) cluster(mru) r
areg filter postf i.year , a(mru) cluster(mru) r
areg boil postf i.year , a(mru) cluster(mru) r

areg drink postf i.year , a(mru) cluster(mru) r


xi: areg drink i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg filter i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

xi: areg stop_freq i.pT i.year*i.ba, a(mru) cluster(mru) r
	coefplot, vertical keep(*pT*)

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





use "${temp}bill_paws_full.dta", clear
	tsset conacct date
	tsfill, full
		fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
		drop if date<datec
	keep c conacct date class read
save "${temp}bill_paws_full_ts.dta"




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

g dated=dofm(date)
g year=year(dated)

* foreach var of varlist B {
* 	replace `var'=`var'[_n+1] if `var'==. 
* }

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g pT1 = pT
replace pT1=1 if year_inst<=2008


g pTl = year-year_inst
replace pTl=1000 if pTl>6 | pTl<-6
replace pTl=pTl+10
replace pTl=1 if pTl==1010

g pTl1 = pTl
replace pTl1 = 1 if year_inst<=2008


g post = year>=year_inst & year<.
g postf = year>year_inst & year<.

g d3_id = drum if wave==3
gegen d3 = max(d3_id), by(conacct)


g B_post = B*post


g B_pre_id = B if post==0
gegen B_pre = max(B_pre_id), by(conacct)
g B_pre_post = B_pre*post

g B_no_pre = B_pre==0
g B_no_pre_post = post*B_no_pre

gegen mB=max(B), by(conacct)
gegen mD=max(drink), by(conacct)
gegen mDR=max(drum), by(conacct)


gegen minpost=min(post), by(mru)

gegen cy=mean(c), by(year conacct)
gegen csy=sd(c), by(year conacct)
replace csy=. if csy>50

gegen tc=tag(year conacct)
gegen year_ba=group(year ba)

g ln_cy=log(cy)

g FP_id = pf_flow_compl==1 & pf_flow_qual==1
gegen FP=max(FP_id), by(conacct)
g QP_id = pf_qual_compl==1 & pf_flow_qual==2
gegen QP=max(QP_id), by(conacct)

g c_pre_id = c if date<=600
gegen c_pre = mean(c_pre_id), by(conacct)


g c_pn_id = c if date<=600 & post==0
gegen c_pn = mean(c_pn_id), by(conacct)
g post_c_pn=post*c_pn

gegen yes_flow_M = mean(yes_flow), by(mru year)

gegen mhhsize=max(hhsize), by(conacct)
g post_mhhsize=post*mhhsize

foreach var of varlist pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr pf_flow_compl pf_flow_qual pf_qual_compl {
	replace `var'=. if `var'==0
	replace `var'=0 if `var'==2
}

g good_job = job==3 | job==4
gegen mgood_job=max(good_job), by(conacct)
g mgood_job_post = mgood_job*post

gegen mhhemp=max(hhemp), by(conacct)
g mhhemp_post = mhhemp*post


***** Booster THEORY ******
* 1) cross-section: booster users consume 3.5 more ;  post leads to 3.5 more
areg c post mB i.year , a(mru) 
* 2) booster and non-booster both increase by the same 3.5 amount (and 13%) from post (with and without FEs)
areg ln_c B_no_pre_post B_pre_post  i.year  , a(conacct) 
areg c B_no_pre_post B_pre_post  i.year  , a(conacct) 
areg ln_c B_no_pre_post B_pre_post B_pre i.year  , a(mru) 
areg c B_no_pre_post B_pre_post B_pre i.year  , a(mru)
* 3) booster use declines steeply post (21% decline)
areg B post i.year  , a(mru) 

* 4) do boosters become less effective after? NO! they APPEAR more effective!
areg c B i.year if post==0, a(mru)
areg c B i.year if post==1, a(mru)

* 5) how does the booster correlation evolve?
areg c B post B_post i.year, a(mru)
areg c B_pre post B_pre_post i.year, a(mru)
areg ln_c post B_pre_post i.year, a(conacct)

* 6) not great preference correlations unfortunately
reg B pf_flow_compl pf_flow_qual pf_qual_compl i.year if  post==0
reg B pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr i.year if  post==0


**** BOOSTER THEORY! **** (a little bit complex... needs Roy model in the end)

* SUPER correlated with yes_flow (2% with; 30% without)  *  little correlation with hhsize
sum B if yes_flow==1
sum B if yes_flow==0
sum hhsize if B==1 & post==0
sum hhsize if B==0 & post==0  // basically no difference
sum good_job if B==1 & post==0
sum good_job if B==0 & post==0  // some difference (10% of mean; 33% of std-dev)
sum B if good_job==0
sum B if good_job==1  // HUGE SES CORRELATION! 
sum hho if B==1 & post==0
sum hho if B==0 & post==0  // some difference (20% of mean; 8% of std-dev)
sum sub if B==1 & post==0
sum sub if B==0 & post==0  // some difference (50% of mean; 20% of std-dev)

sum c if hhsize>=7 & c<200
sum c if hhsize<=3 & c<200 // 19% difference

* reduces booster use and need
areg booster_need post i.year , a(mru) 
areg booster_use post i.year , a(mru) 

* theories: 
* [POSSIBLY REJECT] Booster has NO effect on quantity consumed AND large-users select into boosters
	* not consistent with basically zero correlation between hhsize and booster
	* but! hhsize doesn't explain a lot of consumption (job, hho, sub differences)
	* people are just great at not letting reliability affect their consumption?
	* outages don't happen that often

* [REJECT] Booster provides a benefit that is unrelated to pipe fixes (ie. pressure/reliability?)
	* not consistent with booster use plummeting after pipe fixes

* [LIKELY REJECT] Booster provides a partial fix to households with especially bad pressure; new pipes provide full fixes
	* but why do boosters use more at baseline; then even more once pipes are fixed??  pipes would need
	* to be extra fixed relative to immediate neighbors (go back into pipe distances?)

* [LIKELY ACCEPT] people that buy boosters are just super sensitive to pressure
	* boosters provide a big discrete jump in pressure -> use more before (and after)
	* people that keep using their boosters are also most sensitive to pressure!
		* boosters may be complementary to pipe fixes! pressure isn't perfect after either!
	* EXPLAIN 1) boosters improve pressure
	* EXPLAIN 2) pipe-fixes also improve pressure, but are not perfect substitutes to booster pumps for pressure
	* EXPLAIN 3) you only need so much pressure so a lot of people disinvest
		* assume heterogeneous taste for pressure
		* can maybe estimate with a modified Roy model


**** VARIATION THEORY TIME! ****

* 1) variation increases with c at rate 0.18!  maybe use CV?
reg csy c

* 2) we should see clear patterns when flow is VERY low!

g low_flow = flow_hrs<18
replace low_flow = . if flow_hrs==.
gegen no_flow_m =mean(no_flow), by(mru year)
gegen low_flow_m = mean(low_flow), by(mru year)

tab fl_6_mid, g(fd_)
foreach var of varlist fd_* {
	gegen `var'_m=mean(`var'), by(mru)
}


reg c Bm fd_1_m fd_2_m fd_3_m i.year
reg csy Bm fd_1_m fd_2_m fd_3_m  i.year
reg csy Bm c fd_1_m fd_2_m fd_3_m   i.year

reg c B no_flow i.year
reg csy B no_flow i.year
reg csy B c no_flow  i.year

reg c Bm no_flow_m i.year
reg csy Bm no_flow_m i.year
reg csy Bm c no_flow_m  i.year




*** flow hrs is a weird measure... ***
* reg c B low_flow i.year
* reg csy B low_flow i.year
* reg csy B c low_flow  i.year

* reg c Bm low_flow_m i.year
* reg csy Bm low_flow_m i.year
* reg csy Bm c low_flow_m  i.year

* g B_low_flow= B*low_flow



reg c B i.year if post==0 & flow_hrs<18
reg csy B   i.year if post==0 & flow_hrs<18
reg csy B c  i.year if post==0 & flow_hrs<18


reg c B low_flow B_low_flow post i.year 
reg csy B low_flow B_low_flow  post i.year  if year!=year_inst
reg csy B c low_flow B_low_flow post i.year if year!=year_inst





* 2) why are mru and ind fe's different?
	* maybe not enough variation for ind FE!? No, they skyrocket at year==year_inst (as we would expect!)







**** EVENT STUDY! 
* MRU

areg csy post i.year if year!=year_inst, a(mru)

areg csy post B i.year if year!=year_inst, a(mru)

areg csy post mB i.year if year!=year_inst, a(mru)

areg csy c post mB i.year if year!=year_inst, a(mru) cluster(mru)


* INDIVIDUAL FE! 
areg c post i.year if year!=year_inst, a(conacct)
areg csy post i.year if year!=year_inst, a(conacct) // close to just MRU fe..



areg csy c B post i.year if year!=year_inst, a(mru)




reg csy B  c i.year  if post==0
reg csy B  c flow_hrs i.year if post==0







**** HHSIZE/DEMAND THEORY ****
** gradients aren't that big to get worked up about; 
*   only strong one is with "good job" which likely reflects how rich folks
*   live in apartment buildings with water towers...

*** 1) Small users/small households have bigger increases
areg c post post_c_pn i.year , a(conacct) cluster(mru)
areg c post post_mhhsize i.year , a(conacct) cluster(mru)
areg c     post i.year if mhhsize<=3, a(conacct) 
areg c     post i.year if mhhsize>=7, a(conacct) 
areg ln_c     post i.year if mhhsize<=3, a(conacct) 
areg ln_c     post i.year if mhhsize>=7, a(conacct) 

*** 2) hhsize is not correlated with storage investments
areg hhsize filter B drum sub single i.year if post==0, a(conacct)
areg hhsize filter B drum sub single post i.year, a(conacct)

*** 3) maybe stronger preference for day usage over night usage among big hh's
reg hhsize pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr i.year , cluster(conacct)
reg hhsize pf_flow_compl pf_flow_qual pf_qual_compl i.year, cluster(conacct)

*** 4) nothing interesting
areg wrs post post_mhhsize i.year , a(conacct) cluster(mru)

*** 5) gradient becomes LESS steep!
areg c mhhsize post post_mhhsize i.year, a(mru) cluster(mru)
areg c mgood_job post mgood_job_post i.year, a(mru) cluster(mru)
areg c post  mgood_job mgood_job_post mhhemp mhhemp_post mhhsize post_mhhsize i.year, a(mru)

reg B hhemp hhsize good_job

g B_drum_id = B==1 | drum==1
gegen B_drum = max(B_drum_id), by(conacct)
g B_drum_filter_id=B==1 | drum==1 | filter==1
gegen B_drum_filter=max(B_drum_filter_id), by(conacct)

areg B_drum hhemp hhsize good_job post i.year, a(mru) cluster(conacct)
reg  drum hhemp hhsize good_job i.year if post==0

reg B_drum_filter  hhemp hhsize good_job i.year if post==0

areg c post  mgood_job mgood_job_post mhhemp mhhemp_post mhhsize post_mhhsize i.year if B_drum_filter==0 , a(mru)
areg c post  mhhsize post_mhhsize i.year , a(mru) cluster(mru)
areg c post  mhhsize post_mhhsize i.year if B_drum==0, a(mru) cluster(mru)
areg c post  mgood_job mgood_job_post mhhemp mhhemp_post mhhsize post_mhhsize i.year , a(mru) cluster(mru)
areg c post  mgood_job mgood_job_post mhhemp mhhemp_post mhhsize post_mhhsize i.year if B_drum==0 , a(mru) cluster(mru)


*** COMPLEMENTARY INVESTMENTS ARE LIKELY part of the story! NO disproven above...
** IT IS complementary investments!! **
* reg yes_flow hhsize good_job hhemp if post==0

* Theories:
* [UNLIKELY] small households have less economies of scale (fewer people to manage water storage)
	* not really! hhsize uncorrelated with investments in helpers
	* maybe preference for day over night..
* [UNLIKELY] fixed water usage (ie. cleaning) is more sensitive than per person usage (ie. cooking, showering)
	* unlikely; seems like it should go the other way; not just for hhsize, for all demand shifters...
* [REJECT] small households can easily substitute to other sources
	* no strong evidence (magnitudes small even)
* [REJECT] small households care more about pressure/quality
	* no! then they should invest heavily in pumps etc.
* [REJECT] is hhsize just another proxy for hh SES? and high-SES types are more sensitive to water?
	* NO!  hhsize is not high ses but all big demand shifters have the same effect







areg csy c post post_mhhsize i.year if year!=year_inst , a(conacct) cluster(mru)


areg c     post i.year if mhhsize<=3, a(conacct) 
areg c     post i.year if mhhsize>=7, a(conacct) 


areg ln_c     post i.year if mhhsize<=3, a(conacct) 
areg ln_c     post i.year if mhhsize>=7, a(conacct) 
areg csy   post i.year if mhhsize<=3 & year!=year_inst , a(conacct)
areg csy   post i.year if mhhsize>=7 & year!=year_inst , a(conacct)
areg csy c post i.year if mhhsize<=3 & year!=year_inst , a(conacct)
areg csy c post i.year if mhhsize>=7 & year!=year_inst , a(conacct)

areg csy c post i.year if mhhsize<=3 & year!=year_inst & csy<=, a(conacct)
areg csy c post i.year if mhhsize>=7 & year!=year_inst & c<=200 , a(conacct)


areg csy   post i.year if  year!=year_inst , a(conacct)
areg csy c post i.year if  year!=year_inst , a(conacct)


areg ln_c B_no_pre_post B_pre_post  i.year  , a(conacct) 



areg c B_pre i.year if post==0  , a(mru) cluster(mru)
areg csy B_pre i.year if post==0 & year!=year_inst , a(mru) cluster(mru)
areg csy c B_pre i.year if post==0 & year!=year_inst , a(mru) cluster(mru)


areg c B_pre post i.year  , a(mru) cluster(mru)
areg csy B_pre post i.year if year!=year_inst , a(mru) cluster(mru)
areg csy c B_pre post i.year if year!=year_inst , a(mru) cluster(mru)


areg c B_pre i.year if post==0  , a(mru) cluster(mru)
areg csy B_pre i.year if post==0 & year!=year_inst , a(mru) cluster(mru)
areg csy c B_pre i.year if post==0 & year!=year_inst , a(mru) cluster(mru)



**** DO BOOSTERS AND STORAGE HELP WITH CONSUMPTION VARIANACE?!
areg c mB post i.year  , a(mru) cluster(conacct)
areg csy mB post  i.year if year!=year_inst , a(mru) cluster(conacct)
areg csy c mB post  i.year if year!=year_inst , a(mru) cluster(conacct)

areg c mDR post i.year  , a(mru) cluster(conacct)
areg csy mDR post i.year if year!=year_inst , a(mru) cluster(conacct)
areg csy c mDR post i.year if year!=year_inst , a(mru) cluster(conacct)



areg c B post i.year if  year!=year_inst & yes_flow_M>.46 &  yes_flow_M<., a(mru)
areg c B post i.year if  year!=year_inst & yes_flow_M<=.46 , a(mru)


areg csy c B post i.year if  year!=year_inst & yes_flow_M>.46 &  yes_flow_M<., a(mru)
areg csy c B post i.year if  year!=year_inst & yes_flow_M<=.46 , a(mru)


areg c     post i.year  , a(conacct)




areg c     B_no_pre_post B_pre_post  i.year  , a(conacct) cluster(mru)
areg csy   B_no_pre_post B_pre_post  i.year if year!=year_inst , a(conacct) cluster(mru)
areg csy c B_no_pre_post B_pre_post  i.year if year!=year_inst , a(conacct) cluster(mru)

areg c     B_no_pre_post B_pre_post  i.year  , a(mru) cluster(mru)
areg csy   B_no_pre_post B_pre_post  i.year if year!=year_inst , a(mru) cluster(mru)
areg csy c B_no_pre_post B_pre_post  i.year if year!=year_inst , a(mru) cluster(mru)



areg csy c post B_pre_post  i.year if year!=year_inst , a(conacct) cluster(mru)



areg csy   post  i.year if year!=year_inst , a(conacct) cluster(mru)
areg csy c post  i.year if year!=year_inst , a(conacct) cluster(mru)



*** nothing with individual FE
areg c      post B   i.year  , a(conacct) cluster(conacct)
areg csy    post B   i.year if year!=year_inst  , a(conacct) cluster(conacct)
*** SOMETHING without individual FE, but hard to interpret...
areg c      post B   i.year  , a(mru) cluster(mru)
areg csy    post B   i.year if year!=year_inst  , a(mru) cluster(mru)
areg csy c  post B   i.year if year!=year_inst  , a(mru) cluster(mru)





areg c post i.year, a(conacct)

areg smell post i.year, a(conacct) cluster(conacct)
areg color post i.year, a(conacct) cluster(conacct)
areg taste post i.year, a(conacct) cluster(conacct)
areg stuff post i.year, a(conacct) cluster(conacct)

areg smell post i.year, a(mru) cluster(mru)
areg color post i.year, a(mru) cluster(mru)
areg taste post i.year, a(mru) cluster(mru)
areg stuff post i.year, a(mru) cluster(mru)

areg smell postf i.year, a(mru) cluster(mru)
areg color postf i.year, a(mru) cluster(mru)
areg taste postf i.year, a(mru) cluster(mru)
areg stuff postf i.year, a(mru) cluster(mru)


areg drink postf i.year, a(mru) cluster(mru)
areg filter postf i.year, a(mru) cluster(mru)

areg boil postf i.year, a(mru) cluster(mru)

areg drink post i.year, a(mru) cluster(mru)
areg boil post i.year, a(mru) cluster(mru)


* areg boil post i.year, a(mru) cluster(mru)

 reg B  FP QP



areg cy i.pTl i.year if tc==1 & minpost==0, a(conacct)
	coefplot, vertical keep(*pT*)


areg cy post i.year if tc==1 & mB==1, a(conacct)
areg cy post i.year if tc==1 & mB==0, a(conacct)

areg ln_cy post i.year if tc==1 & mB==1, a(conacct)
areg ln_cy post i.year if tc==1 & mB==0, a(conacct)


areg cy post i.year if tc==1 & minpost==0 & mB==1, a(conacct)
areg cy post i.year if tc==1 & minpost==0 & mB==0, a(conacct)

areg ln_cy post i.year if tc==1 & minpost==0 & mB==1, a(conacct)
areg ln_cy post i.year if tc==1 & minpost==0 & mB==0, a(conacct)

* areg ln_cy post i.year if tc==1 & minpost==0 & mD==1, a(conacct)
* areg ln_cy post i.year if tc==1 & minpost==0 & mD==0, a(conacct)


xi: areg ln_cy i.post*i.FP i.post*i.QP i.year if tc==1 , a(conacct)



areg csy i.pTl if tc==1 & minpost==0, a(conacct)
	coefplot, vertical keep(*pT*)



areg csy drum B c i.pTl i.date, a(mru) cluster(mru)

areg csy drum B i.pTl i.date, a(mru) cluster(mru)

* areg c drum B i.pTl i.date, a(mru) cluster(mru)







sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
gegen date_sr=min(date_sr_id), by(conacct)

g post_rs = date>date_rs & date<.
g post = year>=year_inst & year_inst<.
g post_rs_post = post*post_rs
g sem = class==2

g post_sem = post*sem

g semc = class==2 & class_min!=class_max
g post_semc = post*semc

g amc = amount if amount>=0 & amount<=10000

g Trs = date-date_rs
replace Trs=1000 if Trs>48 | Trs<-48
replace Trs=Trs+100
replace Trs=1 if Trs==1100

g Tsr = date-date_sr
replace Tsr=1000 if Tsr>48 | Tsr<-48
replace Tsr=Tsr+100
replace Tsr=1 if Tsr==1100

cap drop TrsR
cap drop TsrR
g TrsR = round(Trs,6)
g TsrR = round(Tsr,6)
replace TrsR = 0 if TrsR<100-24 | TrsR>100+24
replace TsrR = 0 if TsrR<100-24 | TsrR>100+24

g TrsR_pre = TrsR
replace TrsR_pre = 0 if post==1
g TrsR_post = TrsR
replace TrsR_post = 0 if post==0

g rs_pre=date_rs<date & date_rs<. & post==0
g rs_post=date_rs<date & date_rs<. & post==1

g sr_pre=date_sr<date & date_sr<. & post==0
g sr_post=date_sr<date & date_sr<. & post==1

g sem_pre = sem
replace sem_pre = 0 if post==1
g sem_post = sem
replace sem_post = 0 if post==0





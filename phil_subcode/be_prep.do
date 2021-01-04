* be_prep.do



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


foreach v in B  filter drum SHO hho hhsize sub single hhemp good_job  barangay_id {
	g `v'_3_id = `v' if wave==3
	g `v'_4_id = `v' if wave==4
	g `v'_5_id = `v' if wave==5
	
	gegen `v'_3 = max(`v'_3_id), by(conacct)
	gegen `v'_4 = max(`v'_4_id), by(conacct)
	gegen `v'_5 = max(`v'_5_id), by(conacct)
	drop  `v'_3_id `v'_4_id `v'_5_id

	replace `v' = `v'_3 if w3==1 & w4==0 & w5==0
	replace `v' = `v'_4 if w3==0 & w4==1 & w5==0
	replace `v' = `v'_5 if w3==0 & w4==0 & w5==1

	replace `v' = `v'_4 if year<2010  & w3==0 & w4==1 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==0 & w4==1 & w5==1

	replace `v' = `v'_3 if year<2010  & w3==1 & w4==0 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==1 & w4==0 & w5==1

	replace `v' = `v'_3 if year<2009  & w3==1 & w4==1 & w5==0
	replace `v' = `v'_4 if year>=2009 & w3==1 & w4==1 & w5==0

	replace `v' = `v'_3 if year==2008 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_4 if year==2009 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==1 & w4==1 & w5==1

	drop `v'_3 `v'_4 `v'_5
}

g tot_hh =  hho+hhsize
g c_shr  = hhsize/tot_hh


g cv = c/SHO

	drop if date==653
	g post_treated=post*treated

fmerge m:1 barangay_id using "${temp}cbms_inc.dta", keep(1 3) nogen

g inc = inc_2008 if year<=2010
replace inc = inc_2011 if year>=2011
drop inc_2008 inc_2011

// drops 2% of observations, likely measurement error!
drop if c==.
keep if c<200

replace treated=0 if shr<.8
replace post_treated=0 if shr<.8

keep if cv!=.
g paws=smell!=.


replace amount = . if amount<0 | amount>60*200

replace inc = inc/10000


*** SET UP HETEROGENEITY *** 
foreach var of varlist hhsize hhemp good_job sub single {
	g post_treated_`var' = `var'*post_treated
	g treated_`var' = `var'*treated
}
g inc__post_treated = inc*post_treated


*** SET UP RATE CHANGE ***

gegen ctag=tag(conacct)
gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_max!=class_min
g resm = classm==1 & class_max!=class_min
g clmax = class_max==2

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g Trs = date-date_rs

g Trs_pre = Trs if Trs<0
replace Trs_pre = 0 if Trs_pre==. 
g Trs_post = Trs if Trs>0
replace Trs_post = 0 if Trs_post==. 
g rs_post = Trs>0 & Trs<.

g Trs_pre2=Trs_pre^2
g Trs_post2=Trs_post^2
g Trs_pre3=Trs_pre^3
g Trs_post3=Trs_post^3

g AS=amount/SHO


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


save "${temp}final_analysis.dta", replace





use "${temp}final_analysis.dta", clear

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

tab zm

duplicates drop mru, force

save "${temp}id_set.dta", replace




*** PRE MRU DMA

use "${temp}final_analysis.dta", clear
sum SHO
global SHOm=`=r(mean)'


use "${temp}mru_dma_link.dta", clear
		merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen
		* 1.4 is mean SHO

		gegen acct_dma=sum(accts), by(dma)
		g dma_pop=acct_dma*$SHOm

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

save "${temp}final_nrw.dta", replace




******* COMM ACCOUNTS *******

use "${temp}final_analysis.dta", clear
* keep if cv!=.
	* merge m:1 mru using "${temp}accts_per_mru.dta", keep(3) nogen

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

gegen ctag=tag(conacct)
gegen ctot=sum(ctag), by(mru)
g cshr = ctot/hh_per
drop ctot ctag

gegen cshr_zone = mean(cshr), by(zone_code)

keep conacct zone_code zm mru c post_treated date cshr cshr_zone amount

save "${temp}final_comm.dta", replace



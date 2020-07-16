* pressure.do



*** SHARING INCREASES WITH PIPE FIXES! (but only by a tiny amount..)

**  new accounts are still a mystery........... ( and come into play with uncertainty over pipe fixes... )



* use "${temp}bill_paws_full.dta", clear
* 	tsset conacct date
* 	tsfill, full
* 		fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
* 		drop if date<datec
* 	keep c conacct date class read
* save "${temp}bill_paws_full_ts.dta", replace



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
		replace hhsize=. if hhsize>12

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
			replace hhsize = . if hhsize>12
			replace hho = . if hho<0 | hho>14		

		g B = booster=="Oo"
		g S = storage!=""
		destring hhemp, replace force
		replace hhemp=. if hhemp>12

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


			keep if SHO !=.
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




foreach v in B SHO hhsize sub single hhemp good_job drum {
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


g cv = c/SHO

g p = amt/c

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

g ys = year-2008


* reg SHO post i.year, cluster(mru)



g p1 = p
sum p1, detail
replace p1 = . if p1>`=r(p99)'
g pmiss=p1==.
sort pmiss year c class
by   pmiss year c class: g cn=_n
g p_res_set = p1 if cn==1 & c<=80 & class==1
g p_sem_set = p1 if cn==1 & c<=80 & class==2
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


** ** ** HOW ABOUT FE!? ** ** ** 

* gegen Bmax=max(B), by(conacct)
* gegen Bmin=min(B), by(conacct)
* gegen ctag=tag(conacct)
* tab Bmax Bmin if ctag==1
* areg cv B post i.year, a(mru) cluster(conacct)
* areg cv B post i.year, a(conacct) cluster(conacct)

g B_drum = B*drum


reg cv pi pr drum B B_drum post class_max class_min hhsize ys, cluster(mru)


reg cv pm drum B B_drum post class_max class_min hhsize ys, cluster(mru)
reg cv pm post class_max class_min hhsize ys, cluster(mru)
reg cv pm post class_max class_min hhsize ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max class_min hhsize good_job sub ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max class_min hhsize good_job sub ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max class_min hhsize hhemp good_job sub single SHO  ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max class_min hhsize hhemp good_job  SHO  ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max hhsize hhemp good_job  SHO  ys if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)
reg cv pm post class_max class_min hhsize  if (rdch<=1000 & cch==1) | (rdch<=10000 & cch==0), cluster(mru)


*** TREATED! ***
g treated=minpost==0



preserve
	keep if (rdch<=1000 & cch==1) | (rdch<=10000 & cch==0)
	foreach var of varlist  cv B post pm ys  class_max class_min hhsize {
		drop if `var'==.
	}
	keep if cv<150
	keep cv B post pm ys  class_max class_min hhsize hhemp good_job sub
   order cv B post pm ys  class_max class_min hhsize hhemp good_job sub
   export delimited "${temp}booster_sample1_1.csv", delimiter(",") replace
restore



preserve
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	foreach var of varlist  cv B post pm ys  class_max class_min hhsize hhemp good_job  SHO {
		drop if `var'==.
	}
	keep if cv<150
	keep cv B post pm ys  class_max class_min hhsize hhemp good_job  SHO
   order cv B post pm ys  class_max class_min hhsize hhemp good_job  SHO
   export delimited "${temp}booster_sample1_2.csv", delimiter(",") replace
restore





preserve
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	foreach var of varlist  cv pi pr B post pm ys  class_max class_min hhsize hhemp good_job  SHO {
		drop if `var'==.
	}
	keep if cv<150
	keep cv B post pi pr ys  class_max class_min hhsize hhemp good_job  SHO treated
   order cv B post pi pr ys  class_max class_min hhsize hhemp good_job  SHO treated
   export delimited "${temp}booster_sample1_2nl.csv", delimiter(",") replace
restore




reg cv pm post class_max class_min hhsize ys if (rdch<=10000 & cch==0), cluster(mru)



reg cv pm  if (rdch<=10000 & cch==0) & cv<150, cluster(mru)


reg cv ys hhsize if (rdch<=10000 & cch==0) & cv<150


preserve
	keep if (rdch<=10000 & cch==0)
	foreach var of varlist  cv B post pm ys  class_max class_min hhsize {
		drop if `var'==.
	}
	keep if cv<150
	keep cv B post pm ys  class_max class_min hhsize 
   order cv B post pm ys  class_max class_min hhsize
   export delimited "${temp}booster_sample1_1ch.csv", delimiter(",") replace
restore




areg cv pm post class_max class_min i.year, cluster(mru) a(mru)




reg cv pm post class_max class_min i.year, cluster(mru)


reg cv sem post hhsize class_max class_min i.year, cluster(mru)



reg cv sem post hhsize class_max class_min ys, cluster(mru)



areg cv sem post class_max class_min i.year, a(conacct) cluster(mru)





*** INTERPOLATION! ***
* g paws=B!=.
* gegen paws_per = sum(paws), by(conacct)

* g paws_id = date if B!=.
* gegen paws_first = min(paws_id), by(conacct)
* gegen paws_last = max(paws_id), by(conacct)
* g paws_mid_id = paws_id if paws_first!=paws_id & paws_last!=paws_id & paws_id!=.
* gegen paws_mid = max(paws_mid_id), by(conacct)

* * g post_date_id = date if year_inst==year
* * gegen post_date = max(date), by(conacct)

* drop paws_id paws_mid_id post_date_id


* foreach v in SHO {
* 	g `v'_first_id = `v' if date==paws_first
* 	gegen `v'_first = max(`v'_first_id), by(conacct)
* 	g `v'_mid_id = `v' if date==paws_mid
* 	gegen `v'_mid = max(`v'_mid_id), by(conacct)
* 	g `v'_last_id = `v' if date==paws_last
* 	drop `v'_first_id

* 	replace `v'=`v'_first if date<=paws_first

* }


******* R TO S ANALYSIS ! ********
* sort conacct date
* by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
* g date_rs_id = date if r_to_s_id==1
* replace date_rs_id=. if date_rs_id==577
* gegen date_rs = min(date_rs_id), by(conacct)

* by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
* gegen date_sr=min(date_sr_id), by(conacct)

* g post_rs = date>date_rs & date<.
* g post_rs_post = post*post_rs



* g post_sem = post*sem
* g semc = class==2 & class_min!=class_max
* g post_semc = post*semc


* g Trs = date-date_rs
* replace Trs=1000 if Trs>48 | Trs<-48
* replace Trs=Trs+100
* replace Trs=1 if Trs==1100

* g Tsr = date-date_sr
* replace Tsr=1000 if Tsr>48 | Tsr<-48
* replace Tsr=Tsr+100
* replace Tsr=1 if Tsr==1100

* cap drop TrsR
* cap drop TsrR
* g TrsR = round(Trs,6)
* g TsrR = round(Tsr,6)
* replace TrsR = 0 if TrsR<100-24 | TrsR>100+24
* replace TsrR = 0 if TsrR<100-24 | TsrR>100+24

* g TrsR_pre = TrsR
* replace TrsR_pre = 0 if post==1
* g TrsR_post = TrsR
* replace TrsR_post = 0 if post==0

* g rs_pre=date_rs<date & date_rs<. & post==0
* g rs_post=date_rs<date & date_rs<. & post==1

* g sr_pre=date_sr<date & date_sr<. & post==0
* g sr_post=date_sr<date & date_sr<. & post==1

* g sem_pre = sem
* replace sem_pre = 0 if post==1
* g sem_post = sem
* replace sem_post = 0 if post==0


* g pT = year-year_inst
* replace pT=1000 if pT>3 | pT<-3
* replace pT=pT+10
* replace pT=1 if pT==1010

* g pT1 = pT
* replace pT1=1 if year_inst<=2008


* g pTl = year-year_inst
* replace pTl=1000 if pTl>6 | pTl<-6
* replace pTl=pTl+10
* replace pTl=1 if pTl==1010

* g pTl1 = pTl
* replace pTl1 = 1 if year_inst<=2008

g ln_c = log(c)
gegen minpost=min(post), by(mru)

gegen cy=mean(c), by(year conacct)

gegen csy=sd(c), by(year conacct)

gegen tc=tag(year conacct)

gegen year_ba=group(year ba)



areg cy i.pTl if tc==1 & minpost==0, a(conacct)
	coefplot, vertical keep(*pT*)

areg csy i.pTl if tc==1 & minpost==0, a(conacct)
	coefplot, vertical keep(*pT*)









areg c i.TsrR i.date if post==0, a(conacct)
coefplot, keep(*Tsr*) vertical

areg c i.TsrR i.date if post==1 & minpost==0, a(conacct)
coefplot, keep(*Tsr*) vertical


areg c i.TrsR_pre i.TrsR_post post i.date, a(conacct)
coefplot, keep(*Trs*) vertical


areg c rs_pre rs_post sr_pre sr_post post i.date  if class_max!=class_min, a(conacct)

areg c sem_pre sem_post post i.date  if class_max!=class_min, a(conacct)



areg c i.TrsR i.date if post==1 & minpost==0, a(conacct)
coefplot, keep(*Trs*) vertical


areg c i.TrsR i.date, a(conacct)
coefplot, keep(*Trs*) vertical



areg c i.Trs i.date if post==1 & minpost==0, a(conacct)
coefplot, keep(*Trs*) vertical



areg c post sem post_sem i.date if class_max!=class_min, a(conacct)

areg ln_c post sem post_sem i.date if class_max!=class_min, a(conacct)




reg c post_rs post post_rs_post class_min class_max i.date


reg c post semc post_semc class_min class_max i.date


areg c post_rs post post_rs_post i.date, a(conacct)



areg c post semc post_semc i.date, a(conacct) cluster(conacct) r


areg c post semc post_semc i.date, a(conacct) cluster(mru) r


**** THAT'S COOL! ****


g behind = ar>30 & ar<.

g DC= dc!=.
replace DC=. if (year==2008 | year==2009)

g cm=c==.
replace cm=. if date==592 | date==593 | date==595 | date==653
g amiss=amount==.
replace amiss=. if date==592 | date==593 | date==595 | date==653

gegen cms=sum(cm), by(conacct)

egen year_ba = group(year ba)


areg c i.pT1 i.date  if datec<545, a(conacct)
coefplot, keep(*pT*) vertical



cap drop pn_pre
cap drop pnm
cap drop ptt
g pn_pre = pn if datec<=550
gegen pnm=mean(pn_pre), by(pT1)
gegen ptt=tag(pT1)
twoway scatter pnm pT1 if ptt==1

cap drop a_pre
cap drop anm
cap drop aptt
g a_pre = amiss if datec<=550
gegen anm=mean(a_pre), by(pT1)
gegen aptt=tag(pT1)
twoway scatter anm pT1 if aptt==1


*** date controls reverses the effect


**** C! ****

areg c i.pT if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg c i.pT i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg c i.pT i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical


areg c i.pT1 if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg c i.pT1 i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg c i.pT1 i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical



forvalues year=2008/2015 {
	** BROADLY INCREASING TREND! **
	sum pn if year==`year'
	sum pn_pre if year==`year'
}


**** PN! ****

areg pn i.pT if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical


areg pn i.pT1 if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT1 i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT1 i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical



**** AMISS! ****  THERE MIGHT EVEN BE AN INCREASE!!!

areg amiss i.pT if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pT i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pT i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical


areg amiss i.pT1 if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pT1 i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pT1 i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical





areg amiss i.pTl if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pTl i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pTl i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical


areg amiss i.pTl1 if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pTl1 i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pTl1 i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical



areg pn i.pTl1 i.date if datec<550, a(conacct)
coefplot, keep(*pT*) vertical



areg ar i.pTl1 i.date i.year_ba if datec<550, a(conacct)
coefplot, keep(*pT*) vertical





use "${temp}bill_paws_full.dta", clear
tsset conacct date
tsfill, full
	merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		keep c conacct date class mru datec
		drop if date<datec
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen
g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>12 | pT<-6
gegen min_pT=min(pT), by(mru)
replace pT=pT+10
replace pT=1 if pT==1010


g cm=c==.
gegen cmy=mean(cm), by(conacct year)
gegen cy = mean(c), by(conacct year)
gegen yt = tag(conacct year)

g treat=min_pT<0


areg cmy i.pT i.year if yt==1 , a(conacct) r 
	coefplot, keep(*pT*) vertical
areg cy i.pT i.year if yt==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical

xi: areg cy i.pT i.year*i.treat i.year*i.ba if yt==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 , a(conacct) cluster(conacct) r 
	coefplot, keep(*pT*) vertical















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






* pressure.do






use "${temp}paws_aib.dta", clear

replace year=2008 if year<2008

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen 
		drop zone_code dc-bus
	* merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen
	merge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

g post = 0 if  year<year_inst  & year_inst!=.
replace post = 1 if  year>=year_inst & year_inst!=.

replace age = 99 if age>99
replace me =. if me>5000
replace wrs=. if wrs>500
g well = wrs_type==2
replace well=. if wave==5
g rs = wrs_type==1

g low_skill= job==0 | job==1

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

foreach var of varlist yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp S hho {
	gegen `var'_y=mean(`var'), by(mru year)
}

foreach var of varlist yes_flow no_flow flow_hrs color smell taste stuff B drum gallon me hhsize hhemp S hho {
	gegen `var'_M=mean(`var'), by(pT)
}



twoway scatter yes_flow_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter no_flow_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter B_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter hho_M pT if ptt==1 & pT>=6 & pT<=16
twoway scatter hhemp_M pT if ptt==1 & pT>=6 & pT<=16

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

*** ROBUST TO INDIVIDUAL FIXED EFFECTS
* xi: areg yes_flow i.pT i.year*i.ba, a(conacct) r
* 	coefplot, vertical keep(*pT*)
* xi: areg no_flow i.pT i.year*i.ba, a(conacct) r
* 	coefplot, vertical keep(*pT*)


	* xi: areg yes_flow_y i.pT i.year if shr<.8, a(mru) cluster(mru) r
	* coefplot, vertical keep(*pT*)
	* xi: areg yes_flow_y i.pT i.year if shr>.8 & shr<=1, a(mru) cluster(mru) r
	* coefplot, vertical keep(*pT*)
	* xi: areg no_flow_y i.pT i.year if shr<.8, a(mru) cluster(mru) r
	* coefplot, vertical keep(*pT*)
	* xi: areg no_flow_y i.pT i.year if shr>.8 & shr<=1, a(mru) cluster(mru) r
	* coefplot, vertical keep(*pT*)


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




areg me B post i.year ,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)

areg me B post  hhsize hhemp low_skill sub single i.year ,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)

areg me     post  i.year ,  a(mru) cluster(mru) r 
areg me B   post  i.year ,  a(mru) cluster(mru) r 


* areg me B drum post  i.year ,  a(mru) cluster(mru) r 


areg me B  i.year if post==0,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)
areg me B  i.year if post==1,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)

areg me B  hhsize hhemp low_skill sub single i.year if post==0,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)
areg me B  hhsize hhemp low_skill sub single i.year if post==1,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)



areg B post hhsize hhemp low_skill sub single i.year,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)

areg me  B post hhsize hhemp low_skill sub single i.year ,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)





areg me  drum post hhsize hhemp low_skill sub single i.year ,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)




areg me  B  hhsize hhemp low_skill sub single i.year if post==0,  a(conacct) cluster(conacct)  // 42  (but predicted to be only 16)


areg me post hhsize hhemp low_skill sub single i.year,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)
areg me post B hhsize hhemp low_skill sub single i.year,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)



areg me B post i.year,  a(mru) cluster(mru)  // 42  (but predicted to be only 16)


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






use "${temp}year_billm.dta", clear

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g pT1 = pT
replace pT1=1 if year_inst<=2008


areg mc i.pT1 i.year if datec<545, a(conacct)
coefplot, keep(*pT*) vertical

areg mcm i.pT1 i.year if datec<545, a(conacct)
coefplot, keep(*pT*) vertical



use "${temp}year_amountm.dta", clear

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g pT1 = pT
replace pT1=1 if year_inst<=2008

egen year_ba = group(year ba)

areg ma i.pT1 i.year if datec<545, a(conacct)
coefplot, keep(*pT*) vertical

areg mam i.pT1 i.year_ba if datec<550, a(conacct)
coefplot, keep(*pT*) vertical








use "${temp}bill_paws_full.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2
gegen class_min=min(class), by(conacct)

tsset conacct date
tsfill, full

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
drop if date<datec
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge 1:1 conacct date using "${temp}ar_paws_full.dta", keep(1 3) nogen
	fmerge 1:1 conacct date using "${temp}pay_paws_full.dta", keep(1 3) nogen
	fmerge 1:1 conacct date using "${temp}dc_paws_full.dta", keep(1 3) nogen
	fmerge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen


replace ar = ar+30
replace ar = 0 if ar==.
replace ar = . if date<600

g pn = pay!=.

g dated=dofm(date)
g year=year(dated)

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g post_rs = date>date_rs & date<.
g post = year>=year_inst & year_inst<.
g post_rs_post = post*post_rs
g sem = class==2

g post_sem = post*sem

g semc = class==2 & class_min!=class_max
g post_semc = post*semc

g amc = amount if amount>=0 & amount<=10000



****
* g TM = T==1100
* g T1 = T
* replace T1 = 0 if T==1100
* g T2 = T1
* replace T2 = 0 if T2>100
* g price_post_post=price_post*post
* reg c price_post i.class_max i.class_min T1 TM, cluster(mru) r
* reg c post price_post  i.class_max i.class_min T1 TM, cluster(mru) r
****


reg c post_rs post post_rs_post class_min class_max i.date


reg c post semc post_semc class_min class_max i.date


areg c post_rs post post_rs_post i.date, a(conacct)


areg c post sem post_sem i.date if class_max!=class_min, a(conacct)


areg c post semc post_semc i.date, a(conacct) cluster(conacct) r


areg c post semc post_semc i.date, a(conacct) cluster(mru) r


**** THAT'S COOL! ****

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g pT1 = pT
replace pT1=1 if year_inst<=2008


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

areg pn i.pT1 i.date i.year_ba  if datec<550, a(conacct)
coefplot, keep(*pT*) vertical


areg amiss i.pT1 i.date  i.year_ba  if date!=600 & date!=601 & datec<550, a(conacct)
coefplot, keep(*pT*) vertical





areg c i.pT1 i.date i.year_ba if datec<545, a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT1 i.date  i.year_ba if datec<545, a(conacct)
coefplot, keep(*pT*) vertical






areg pn i.pT1 i.date  i.year_ba if datec<545, a(conacct)
coefplot, keep(*pT*) vertical

areg amiss i.pT1 i.date  i.year_ba  if date!=600 & date!=601 & datec<545, a(conacct)
coefplot, keep(*pT*) vertical







areg DC  i.pT i.date i.year_ba  , a(conacct)
coefplot, keep(*pT*) vertical


areg amc i.pT i.date  , a(conacct)
coefplot, keep(*pT*) vertical

areg c i.pT i.date  , a(conacct)
coefplot, keep(*pT*) vertical





areg pn i.pT i.date, a(conacct)
coefplot, keep(*pT*) vertical



areg ar i.pT i.date  if year>2011 , a(conacct)
coefplot, keep(*pT*) vertical

areg DC i.pT i.date  if year>2011 , a(conacct)
coefplot, keep(*pT*) vertical

areg pn i.pT i.date  if year>2011, a(conacct)
coefplot, keep(*pT*) vertical



areg cm i.pT i.date  if pT!=10 & cms<=30, a(conacct)
coefplot, keep(*pT*) vertical



areg c i.pT i.date, a(conacct)
coefplot, keep(*pT*) vertical



* areg ar i.pT i.date i.year_ba if  cms<=30, a(conacct)
* coefplot, keep(*pT*) vertical












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






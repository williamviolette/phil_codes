* pressure.do



* SELECTION INTO RS AND SR !
use "${temp}bill_rc.dta", clear

	fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen 
	keep conacct date c class read class_max class_min mru datec ba

drop if class_max==4 | class_max==5
keep if datec<=580

sort conacct date
by conacct: g date_rs_id = class[_n-1]==1 & class[_n]==2
by conacct: g date_sr_id = class[_n-1]==2 & class[_n]==1

gegen drs = sum(date_rs_id), by(mru date)
gegen dsr = sum(date_sr_id), by(mru date)

g c_avg_id = c if date<=580
gegen c_avg = mean(c), by(conacct)

g crs_id = c_avg if date_rs_id == 1
g csr_id = c_avg if date_sr_id == 1

gegen crs=mean(crs_id), by(mru date)
gegen csr=mean(csr_id), by(mru date)

keep mru date drs dsr crs csr
duplicates drop mru date, force

tsset mru date
tsfill, full
replace drs=0 if drs==.
replace dsr=0 if dsr==.

g dated=dofm(date)
g year=year(dated)

	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g post = year>year_inst & year<.
gegen minpost=min(post), by(mru)


areg drs i.pT i.date , a(mru)
	coefplot, vertical keep(*pT*)

areg dsr i.pT i.date , a(mru)
	coefplot, vertical keep(*pT*)


reg drs i.pT i.date
	coefplot, vertical keep(*pT*)

reg dsr i.pT i.date
	coefplot, vertical keep(*pT*)


reg crs i.pT i.date
	coefplot, vertical keep(*pT*)

reg csr i.pT i.date
	coefplot, vertical keep(*pT*)



use "${temp}bill_rc.dta", clear

	fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen 
	keep conacct date c class read class_max class_min mru datec ba

drop if class_max==4 | class_max==5
keep if datec<=580

	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

egen year_ba=group(year ba)

* CLEAR EVENT STUDY UNDERSTANDING


sort conacct date
by conacct: g date_rs_id = date if class[_n]==1 & class[_n+1]==2
replace date_rs_id=. if date_rs_id==576
gegen date_rs=min(date_rs_id), by(conacct)


by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
gegen date_sr=min(date_sr_id), by(conacct)

by conacct: g date_sr1_id = date if class[_n]==2 & class[_n+1]==1 & date>=date_rs
gegen date_sr1=min(date_sr1_id), by(conacct)

g dur = date_sr1-date_rs


g Trs = date-date_rs
replace Trs=1000 if Trs>48 | Trs<-48
replace Trs=Trs+100
replace Trs=1 if Trs==1100

g Tsr = date-date_sr
replace Tsr=1000 if Tsr>48 | Tsr<-48
replace Tsr=Tsr+100
replace Tsr=1 if Tsr==1100


g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g pT1 = pT
replace pT1=1 if year_inst<=2008

g post = year>=year_inst

gegen minpost=min(post), by(mru)

tab class, g(c_)

foreach var of varlist c_* {
	g post_`var'=post*`var'
}

g ln_c = log(c)


g Trs_pre = Trs
replace Trs_pre=1 if post==1

g Trs_post = Trs
replace Trs_post=1 if post==0

replace Trs_pre=1 if Trs_pre<100-24 | Trs_pre>100+24
replace Trs_post=1 if Trs_post<100-24 | Trs_post>100+24

g trs = Trs>100 & Trs<.

g trs_pre = trs
replace trs_pre = 0 if post==1
g trs_post = trs
replace trs_post = 0 if post==0


* g c_pre = c if date<date_rs-24 & date_rs<.
* g c_pre_nm=c_pre!=.
* gegen c_pre_nms=sum(c_pre_nm), by(conacct)


areg c i.Trs i.date, a(conacct)
	coefplot, vertical keep(*Trs*)

areg c i.Tsr i.date, a(conacct)
	coefplot, vertical keep(*Tsr*)




areg c i.Trs i.date if dur>12 & dur<., a(conacct)
	coefplot, vertical keep(*Trs*)


areg c post trs_pre trs_post i.date if minpost==0 & Trs>=100-12 & Trs<=100+12, a(conacct)




areg c trs post i.date if minpost==0 & Trs>=100-24 & Trs_pre<=100+24, a(conacct)
	coefplot, vertical keep(*Trs*)



areg c i.Trs i.date if post==0, a(conacct)
	coefplot, vertical keep(*Trs*)

areg c i.Trs i.date if post==1, a(conacct)
	coefplot, vertical keep(*Trs*)


areg c i.Trs i.date if minpost==0 & post==0, a(conacct)
	coefplot, vertical keep(*Trs*)


areg c i.Trs i.date if minpost==0 & post==1, a(conacct)
	coefplot, vertical keep(*Trs*)



areg c i.Tsr i.date , a(conacct)
	coefplot, vertical keep(*Tsr*)


areg c i.Trs i.date if c<100, a(conacct)
	coefplot, vertical keep(*Trs*)

areg c i.Tsr i.date if c<200, a(conacct)
	coefplot, vertical keep(*Tsr*)










use "${temp}bill_paws_full.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2
gegen class_min=min(class), by(conacct)

tsset conacct date
tsfill, full

drop class_max class_min

gegen class_max=max(class), by(conacct)
gegen class_min=min(class), by(conacct)


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






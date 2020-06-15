* pressure.do



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





areg ln_c post post_c_2 post_c_3 i.year , a(conacct)



areg ln_c c_2 post post_c_2 i.year if class_max==2 & class_min==1, a(conacct) cluster(conacct)


areg ln_c c_2 post post_c_2 i.year if class_max==2 & class_min==1 & minpost==0, a(conacct) cluster(conacct)


areg ln_c c_2 c_3 post post_c_2 post_c_3 i.year, a(conacct) cluster(conacct)


areg c c_2 post post_c_2 i.year if class_max==2 & class_min==1 & minpost==0, a(conacct) cluster(conacct)



areg ln_c c_2  i.year if class_max==2 & post==0, a(conacct) cluster(conacct)

areg ln_c c_2  i.year if class_max==2 & post==1, a(conacct) cluster(conacct)




areg mcm i.pT1 i.year if datec<545, a(conacct)
coefplot, keep(*pT*) vertical





use "${temp}cd.dta", clear
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

forvalues r=1/25 {
g c`r'_id = cden if c==`r'
gegen c`r' = max(c`r'_id), by(mru year)
g c_c_`r'=c`r'
drop c`r'_id
}
forvalues r=1/25 {
g c`r'_id = cdennr if c==`r'
gegen cnr`r' = max(c`r'_id), by(mru year)
g c_nrc_`r'=cnr`r'
drop c`r'_id
}

* egen rt = rowtotal(c5-c15)
* g c10_9=(c10-c9)/c15
* g c10r = c10/rt
* g c12r = c12/rt
* g c9r = c8/rt
* gegen ctot=sum(cden), by(mru year)


g post = year>=year_inst

gegen minpost=min(post), by(mru)


g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010


gegen mt=tag(mru year)

g ln_c10=log(c10)
g ln_c13=log(c13)

g c10_11d = c10-c11
g c10_9d = c10-c9


areg c10_11d i.pT i.year if mt==1 , a(mru)
		coefplot, vertical keep(*pT*)

areg c10_9d i.pT i.year if mt==1, a(mru)
		coefplot, vertical keep(*pT*)


ren c_c_7 c_cd_7
	areg c7 c_c_* i.pT i.year if mt==1 , a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_7 c_c_7

ren c_c_8 c_cd_8
	areg c8 c_c_* i.pT i.year if mt==1 , a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_8 c_c_8

ren c_c_9 c_cd_9
	areg c9 c_c_* i.pT i.year if mt==1 , a(mru) cluster(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_9 c_c_9


ren c_c_10 c_cd_10
	areg c10 c_c_* i.pT i.year if mt==1 , a(mru) cluster(mru)
		coefplot, vertical keep(*pT*)
	* areg c10 c_c_* post i.year if mt==1 , a(mru) cluster(mru)
ren c_cd_10 c_c_10

ren c_nrc_10 c_nrcd_10
	areg cnr10 c_nrc_* i.pT i.year if mt==1 , a(mru) cluster(mru)
		coefplot, vertical keep(*pT*)
ren c_nrcd_10 c_nrc_10


ren c_c_10 c_cd_10
	areg c10 c_c_* i.pT i.year if mt==1 , a(mru) cluster(mru)
		coefplot, vertical keep(*pT*)
	areg c10 c_c_* post i.year if mt==1 , a(mru) cluster(mru)
ren c_cd_10 c_c_10


	* areg c10  i.pT i.year if mt==1 , a(mru)
		* coefplot, vertical keep(*pT*)

ren c_c_20 c_cd_20
	areg c20 c_c_* i.pT i.year if mt==1 , a(mru) cluster(mru)
		coefplot, vertical keep(*pT*)
	areg c20 c_c_* post i.year if mt==1 , a(mru) cluster(mru)
ren c_cd_20 c_c_20



ren c_c_12 c_cd_12
	areg c12 c_c_* i.pT i.year if mt==1, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_12 c_c_12

ren c_c_13 c_cd_13
	areg c13 c_c_* i.pT i.year if mt==1, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_13 c_c_13




ren c_c_10 c_cd_10
	areg c10 c_c_* i.pT i.year if mt==1 & minpost==0, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_10 c_c_10


ren c_c_13 c_cd_13
	areg c13 c_c_* i.pT i.year if mt==1 & minpost==0, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_13 c_c_13

ren c_c_8 c_cd_8
	areg c8 c_c_* i.pT i.year if mt==1 & minpost==0, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_8 c_c_8

ren c_c_6 c_cd_6
	areg c6 c_c_* i.pT i.year if mt==1 & minpost==0, a(mru)
		coefplot, vertical keep(*pT*)
ren c_cd_6 c_c_6


	areg c21 i.pT i.year if mt==1 & minpost==0, a(mru)
		coefplot, vertical keep(*pT*)


areg c12 i.pT i.year if mt==1, a(mru)
	coefplot, vertical keep(*pT*)

areg c9 i.pT i.year if mt==1, a(mru)
	coefplot, vertical keep(*pT*)



gegen ht = sum(cden), by(c pT minpost)

gegen tt=tag(c pT minpost)

twoway scatter ht c if tt==1 & pT>1 & c<=15 & c>=5 & minpost==0, by(pT, rescale)


gegen ht1= sum(cden), by(c pT)
gegen tt1=tag(c pT)

twoway scatter ht1 c if tt1==1 & pT>1 & c<=15 & c>=5, by(pT, rescale)


gegen htr1= sum(cdennr), by(c pT)
gegen ttr1=tag(c pT)

twoway scatter htr1 c if ttr1==1 & pT>1 & c<=15 & c>=5, by(pT, rescale)



use "${temp}bill_neg_paws_full.dta", clear

	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)

g post= year>=year_inst
gegen minpost=min(post), by(mru)

g c= pres-prev
g calt=prev-pres
replace c=. if c<0
replace c= calt if year==2008
replace c=. if c<0
replace c=. if pres==0 | prev==0
replace c=. if read==0

sort conacct date
by conacct: replace c=. if read[_n+1]==0 | read[_n-1]==0 | read[_n+2]==0 | read[_n-2]==0

g co = pres-prev
replace co=abs(co)
replace co=. if co<0 | co>500

g o=1
gegen os1=sum(o), by(c read)
gegen ot1=tag(c read)

gegen oso1=sum(o), by(co read)
gegen oto1=tag(co read)

scatter oso1 co if oto1==1  & co<60 & read==1 || ///
scatter os1 c if ot1==1  & c<60 & read==1, xline(10 20 30 40 50) 


scatter oso1 co if oto1==1  & co<40 & co>20 & read==1 || ///
scatter os1 c if ot1==1  & c<40 & c>20 &  read==1
scatter os1 c if ot1==1  & c<60 & read==1

sum oso1 if co==29 & oto1==1 & read==1
global r1 = `=r(mean)'
sum oso1 if co==30 & oto1==1 & read==1
global r2 = `=r(mean)'
sum oso1 if co==31 & oto1==1 & read==1
global r3 = `=r(mean)'

disp $r2/($r1+$r3)

sum os1 if c==29 & ot1==1 & read==1
global r1 = `=r(mean)'
sum os1 if c==30 & ot1==1 & read==1
global r2 = `=r(mean)'
sum os1 if c==31 & ot1==1 & read==1
global r3 = `=r(mean)'

disp $r2/($r1+$r3)




use "${temp}bill_paws_full.dta", clear

* keep if read==1
	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
keep if datec<580

g dated=dofm(date)
g year=year(dated)

g post= year>=year_inst
gegen minpost=min(post), by(mru)

* g post= year>2011
* drop if year==year_inst

* gegen minpost = min(post), by(mru)

g o=1
gegen os=sum(o), by(c post minpost year)
gegen ot = tag(c post minpost year)

gegen os1=sum(o), by(c post read)
gegen ot1 = tag(c post read)


gegen osy=sum(o), by(c post year)
gegen oty = tag(c post year)


twoway scatter os1 c if ot1==1 & post==0  & c<60 & read==0 || ///
scatter os1 c if ot1==1 & post==0  & c<60 & read==1, xline(10 20 30 40 50) yaxis(2)


twoway scatter os1 c if ot1==1 & post==1  & c<60  , xline(10 20 30 40 50)



twoway scatter osy c if oty==1 & post==0  & c<60 & year==2010 || ///
 	   scatter osy c if oty==1 & post==1  & c<60 & year==2010 , yaxis(2) xline(10 20 30 40 50)


twoway scatter osy c if oty==1 & post==0  & c<60 & year==2011 || ///
 	   scatter osy c if oty==1 & post==1  & c<60 & year==2011 , yaxis(2) xline(10 20 30 40 50)


twoway scatter os1 c if ot1==1 & post==0  & c<60  || ///
	scatter os1 c if ot1==1 & post==1 & c<60 , yaxis(2)  xline(10) xline(20)


twoway scatter os c if ot==1 & post==0 & minpost==0 & c<60 & year==2010 || ///
	scatter os c if ot==1 & post==1 & minpost==0 & c<60 & year==2010, yaxis(2)  xline(10) xline(20)


twoway scatter os c if ot==1 & post==0 & minpost==0 & c<60 & year==2009 || ///
	scatter os c if ot==1 & post==1 & minpost==0 & c<60 & year==2009, yaxis(2)  xline(10)


twoway scatter os c if ot==1 & post==0 & minpost==0 & c<60 & year==2011 || ///
	scatter os c if ot==1 & post==1 & minpost==0 & c<60 & year==2011, yaxis(2) xline(10)



g c9=c==9
g c10=c==10
g c11=c==11

gegen ms=sum(o), by(mru year)
gegen c9s=sum(c9), by(mru year)
gegen c10s=sum(c10), by(mru year)
gegen c11s=sum(c11), by(mru year)

g s9=c9s/ms
g s10=c10s/ms
g s11=c11s/ms

gegen mt = tag(mru year)

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10
replace pT=1 if pT==1010

g ss10=s10-s11

g cso=c10s-c9s

areg cso i.pT i.year if mt==1 & minpost==0, a(mru)
coefplot, vertical keep(*pT*)



sort conacct date
by conacct: g date_rs_id = date if class[_n]==1 & class[_n+1]==2
replace date_rs_id=. if date_rs_id==576
gegen date_rs=min(date_rs_id), by(conacct)

by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
gegen date_sr=min(date_sr_id), by(conacct)


g Trs = date-date_rs
replace Trs=1000 if Trs>48 | Trs<-48
replace Trs=Trs+100
replace Trs=1 if Trs==1100

g Trs_t = Trs
replace Trs_t = 1 if Trs<100-24 | Trs>100+24

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


tab class, g(c_)

foreach var of varlist c_* {
	g post_`var'=post*`var'
}

g ln_c = log(c)


areg c i.Trs_t i.date, a(conacct)
	coefplot, vertical keep(*Trs*)



g Trs_pre = Trs
replace Trs_pre=1 if post==1

g Trs_post = Trs
replace Trs_post=1 if post==0

replace Trs_pre=1 if Trs_pre<100-12 | Trs_pre>100+12
replace Trs_post=1 if Trs_post<100-12 | Trs_post>100+12

g trs = Trs>100 & Trs<.

g trs_pre = trs
replace trs_pre = 0 if post==1
g trs_post = trs
replace trs_post = 0 if post==0

areg c post i.Trs_pre i.Trs_post i.date , a(conacct)
	coefplot, vertical keep(*Trs*)


areg c post trs_pre trs_post i.date, a(conacct)


areg c i.Trs_t i.date if minpost==0 & post==1, a(conacct)
	coefplot, vertical keep(*Trs*)





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

g Tsr = date-date_sr
replace Tsr=1000 if Tsr>48 | Tsr<-48
replace Tsr=Tsr+100
replace Tsr=1 if Tsr==1100

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


areg c i.Tsr i.date, a(conacct)
coefplot, keep(*Tsr*) vertical



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


g pTl = year-year_inst
replace pTl=1000 if pTl>6 | pTl<-6
replace pTl=pTl+10
replace pTl=1 if pTl==1010

g pTl1 = pTl
replace pTl1 = 1 if year_inst<=2008


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






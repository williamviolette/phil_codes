


*** LOOK FOR THEFT! ***

cd "${phil_folder}"



import delimited using ais/input/ais_data/AITF_CRMS_DATA_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)
	replace nt_illegal=lower(nt_illegal)

	bys nt_illegal: g NN=_N
	tab nt_illegal if NN>50

	keep if regexm(nt_illegal,"outright")==1

	g outright = regexm(nt_illegal,"outright")==1




import delimited using ais/input/ais_data/AITF_BT_NTARIFF.csv, delimiter(",") clear rowrange(2:) varnames(2)




import delimited using ais/input/ais_data/AITF_BT_NTARIFF.csv, delimiter(",") clear rowrange(2:) varnames(2)
import delimited using ais/input/ais_data/AITF_STREET.csv, delimiter(",") clear rowrange(2:) varnames(2)
import delimited using ais/input/ais_data/AITF_DISTRICT.csv, delimiter(",") clear rowrange(2:) varnames(2)

* import delimited using ais/input/ais_data/AITF_BT_AREACAT.csv, delimiter(",") clear rowrange(2:) varnames(2)
* import delimited using ais/input/ais_data/AITF_INV_ORDER_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)

* ILLEILLIL003CRM054158026351


* PIPESTATID	PIPESTATNM
* 111	NEED UPGRADING
* 222	DOES NOT NEED UPGRADING
* 333	LEAKING

* NAT_WATMAINID	NAT_WATMAIN_DESC
* 1111	EXPOSED
* 2222	NOT EXPOSED

* ILLTYPECD	ILLTYPENM
* 10000	NO ILLEGALITY

* 10001	UNREGISTERED WATER SERVICE CONNECTION
* 10002	NO METER/ STOLEN METER
* 10003	TAMPERING/REVERSION/ILLEGAL DISMOUNTING OF METER
* 10004	DRAWING WATER FROM SERVICE COCK
* 10005	ELECTRICAL PUMP/BOOSTER PUMP
* 10006	TCD/PCD FOUND ACTIVE
* 10007	DOUBLE TAPPING
* 10008	BY PASS CONNECTION
* 10009	UNREGISTERED ADDITIONAL CONNECTION
* 10010	USING ABANDONED WATER SERVICE
* 10011	USING OLD LINE
* 10012	ADVANCED TAPPING
* 10013	UNAUTHORIZED SEPARATION OF TAPPING 
* 10014	UNAUTHORIZED CHANGE OF SERVICE PIPE
* 10015	ILLEGALLY REOPENED WATER SERVICE CONNECTION
* 10016	TAMPERED METER
* 10017	REVERSELY CONNECTED METER
* 10018	ILLEGAL DISMOUNTING OF METER
* 10019	UNREGISTERED WSC - Unknown User
* 10020	USING ABANDONED WSC - Unknown User
* 10021	ILLEGAL SELLING OF WATER
* 10022	"UNAUTHORIZED TRANSFER OF LOCATION TAPPING"
* 10023	TAMPERING OF GV/SERVICECOCK/METER SEAL/PROTECTOR

* WATPRESSID	WATPRESSNM
* LOW	LOW<2
* POOR	2 < POOR <=3
* NORMAL	3 < NORMAL <= 4
* GOOD	4 < GOOD <= 5
* HIGH	HIGH > 5 PSI


import delimited using ais/input/ais_data/AITF_INV_ORDER_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)
		destring cont_accnt, replace force
		ren naccnt_no conacct_t
			destring conacct_t, replace force
			replace conacct_t=. if conacct_t==0
		ren cont_accnt conacct_t2
			destring conacct_t2, replace force
			replace conacct_t2=. if conacct_t2==0
		ren crms_refnum ref_no
			g year=substr(dt_install,-16,4)
			g month=substr(dt_install,1,2)
			replace month=subinstr(month,"/","",.)
			destring year month, replace
			g date_install=ym(year,month)
			destring no_users, replace force
		keep ref_no finding nat_ill conacct_t conacct_t2 date_install st_cd city_cd district_cd no_users wat_press phystatspipe nat_watermain
		duplicates drop ref_no, force
save "${temp}ai_inv.dta", replace



import delimited using ais/input/ais_data/AITF_CRMS_DATA_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)
		g year=substr(crcvdt,-16,4)
		g month=substr(crcvdt,1,2)
		replace month=subinstr(month,"/","",.)
		destring year month, replace
		g date=ym(year,month)
		* keep if date>=580
		ren cacctnb conacct_c
		destring conacct_c, replace force
		duplicates drop ref_no, force
		destring branch, replace force
		keep conacct_c date ref_no branch nt_illegal finding

		replace nt_illegal=lower(nt_illegal)
		g nti=""
		replace nti="tcd" if regexm(nt_illegal,"tcd")==1 | regexm(nt_illegal,"open")==1
		* replace nti="bypass" if regexm(nt_illegal,"pass")==1
		replace nti="outright" if regexm(nt_illegal,"with illegal")==1 | regexm(nt_illegal,"outright")==1
		replace nti="others" if nti==""
		drop nt_illegal
save "${temp}ai_crms.dta", replace



use "${temp}ai_inv.dta", clear

	keep if nat_ill>10000

	g or = nat_ill==10001

	g need_fix 		 = 0 if phystatspipe!=.
	replace need_fix = 1 if phystatspipe==111 | phystatspipe==333

	tab wat_press if or==0
	tab wat_press if or==1

	tab phystatspipe if or==0
	tab phystatspipe if or==1

	tab no_users if or==0 & no_users>=1 & no_users<=10
	tab no_users if or==1 & no_users>=1 & no_users<=10

	tab nat_watermain if or==0
	tab nat_watermain if or==1





use "${temp}ai_crms.dta", clear

	merge 1:1 ref_no using "${temp}ai_inv.dta", keep(1 3) nogen
		g double conacct = conacct_c
		replace conacct= conacct_t if conacct==. & conacct_t!=.
		replace conacct= conacct_t2 if conacct==. & conacct_t2!=.

	keep if conacct!=.

	keep if nat_ill>10000 & nat_ill<.
	keep conacct nat_ill date
	gegen md=min(date), by(conacct)
	keep if md==date
	drop md
	ren date date_ai
	duplicates drop conacct, force

save "${temp}ai_conacct.dta", replace





use "${temp}ai_crms.dta", clear

	merge 1:1 ref_no using "${temp}ai_inv.dta", keep(1 3) nogen
		g double conacct = conacct_c
		replace conacct= conacct_t if conacct==. & conacct_t!=.
		replace conacct= conacct_t2 if conacct==. & conacct_t2!=.

	keep if conacct!=.

	* ren conacct_c conacct
	duplicates drop conacct date, force

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		drop ba zone_code dc-datec

replace nt=lower(nt)
gegen tot=sum(finding), by(mru date)
g nf = finding==0
gegen ntot=sum(nf), by(mru date)
* g tcd_id = regexm(nti,"tcd")==1
g tcd_id = nat_ill==10015 | nat_ill==10006
gegen tcd=sum(tcd_id), by(mru date)
* g outright_id = regexm(nti,"outright")
g outright_id = nat_ill!=10000 & tcd_id!=1
gegen outright = sum(outright_id), by(mru date)

keep mru date tot ntot tcd outright
duplicates drop mru date, force
tsset mru date
tsfill, full

replace tot=0 		if tot==.
replace ntot=0 if ntot==.
replace tcd=0 		if tcd==.
replace outright=0  if outright==.

	merge m:1 mru using "${temp}pipe_year_old.dta", keep(3) nogen
	merge m:1 mru using "${temp}mru_set.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

tab pT
g post = year>=year_inst & year<.

gegen toty=mean(tot), by(mru year)
gegen tcdy=mean(tcd), by(mru year)
gegen outrighty=mean(outright), by(mru year)
g ntc=tot-tcd
gegen ntcy=mean(ntc), by(mru year)
gegen yt=tag(mru year)


areg toty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg outrighty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg tcdy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg ntcy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

* areg outrighty ntcy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
* 	coefplot, keep(*pT*) vertical
* areg tcdy ntcy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
* 	coefplot, keep(*pT*) vertical





use "${temp}ai_crms.dta", clear

	merge 1:1 ref_no using "${temp}ai_inv.dta", keep(1 3) nogen
		g double conacct = conacct_c
		replace conacct= conacct_t if conacct==. & conacct_t!=.
		replace conacct= conacct_t2 if conacct==. & conacct_t2!=.

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
		drop ba zone_code dc-datec
		g o=1
		gegen dmt=sum(o), by(district_cd mru)
		replace dmt=. if district_cd=="" | mru==.
		gegen dtt=max(dmt), by(district_cd)

		g mru_m=mru if dtt==dmt
		gegen mru_id =max(mru_m), by(district_cd)
		bys mru_id: g mN=_N
		drop if mN>10000

g o = 1
gegen tot=sum(o), by(mru date)
g tcd_id = nat_ill==10015
gegen tcd=sum(tcd_id), by(mru date)
g outright_id = nat_ill==10001
gegen outright = sum(outright_id), by(mru date)
g nothing_id = nat_ill==10000
gegen nothing = sum(nothing_id), by(mru date)

keep mru date tot tcd outright nothing
duplicates drop mru date, force
tsset mru date
tsfill, full

replace tot=0 		if tot==.
replace tcd=0 		if tcd==.
replace outright=0  if outright==.
replace nothing=0   if nothing==.

	merge m:1 mru using "${temp}pipe_year_old.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10

tab pT
g post = year>=year_inst & year<.


g something = tot-nothing
gegen toty=mean(something), by(mru year)
gegen tcdy=mean(tcd), by(mru year)
gegen outrighty=mean(outright), by(mru year)
gegen nothingy=mean(nothing), by(mru year)
gegen yt=tag(mru year)




areg outrighty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg tcdy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg toty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical

areg nothingy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical








import delimited using ais/input/ais_data/AITF_CRMS_DATA_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)

	merge m:1 ref_no using "${temp}ai_inv.dta", keep(1 3) nogen

	g year=substr(crcvdt,-16,4)
	g month=substr(crcvdt,1,2)
	replace month=subinstr(month,"/","",.)
	destring year month, replace
g date=ym(year,month)
keep if date>=580

	ren cacctnb conacct
	destring conacct, replace force

	keep conacct date nt_illegal
	keep if conacct!=.

	duplicates drop conacct date, force

	merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		drop ba zone_code dc-datec

replace nt=lower(nt)
g o = 1
gegen tot=sum(o), by(mru date)
g tcd_id = regexm(nt,"tcd")==1
gegen tcd=sum(tcd_id), by(mru date)
g outright_id = regexm(nt,"outright")
gegen outright = sum(outright_id), by(mru date)

keep mru date tot tcd outright
duplicates drop mru date, force
tsset mru date
tsfill, full

replace tot=0 		if tot==.
replace tcd=0 		if tcd==.
replace outright=0  if outright==.

	merge m:1 mru using "${temp}pipe_year_old.dta", keep(3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>3 | pT<-3
replace pT=pT+10

tab pT
g post = year>=year_inst & year<.

gegen toty=mean(tot), by(mru year)
gegen tcdy=mean(tcd), by(mru year)
gegen outrighty=mean(outright), by(mru year)
g ntc=tot-tcd
gegen ntcy=mean(ntc), by(mru year)
gegen yt=tag(mru year)

areg outrighty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical
areg toty i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical
areg tcdy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical
areg ntcy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical






import delimited using ais/input/ais_data/AITF_CRMS_DATA_EDIT.csv, delimiter(",") clear rowrange(2:) varnames(2)

* keep if cacctnb==""
g year=substr(crcvdt,-16,4)
destring year, replace force
destring branch, replace force

bys year branch: g at=_N
keep if cacctnb==""
bys year branch: g ao=_N

duplicates drop year branch, force

keep at ao year branch

save "${temp}at_year.dta", replace



use "${temp}at_year.dta", clear

merge m:1 branch using "${temp}pipe_year_branch.dta", keep(3) nogen

g pT = year-year_inst
* replace pT = . if shr<.1
	replace pT=1000 if pT>3 | pT<-4
	replace pT=pT+10

g aj = at-ao

areg ao i.pT i.year if ao<1500, a(branch) cluster(branch) r
areg ao i.pT i.year , a(branch) cluster(branch) r

coefplot, vertical keep(*pT*)


areg aj i.pT i.year if aj<1500, a(branch) cluster(branch) r

coefplot, vertical keep(*pT*)


g post = year>=year_inst & year<. 

areg ao post i.year, a(branch)  r
areg aj post i.year, a(branch)  r

areg ao post i.year if ao<1500, a(branch)  r
areg aj post i.year if aj<3000, a(branch)  r



areg ao post i.year if pT<14 | pT>100, a(branch) cluster(branch) r


areg ao post i.year if ao<1000 & branch<1700, a(branch) cluster(branch) r

areg aj post i.year if aj<1500 & branch<1700, a(branch) cluster(branch) r



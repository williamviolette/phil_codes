* new_tnpl.do


		clear all
		set more off
		cd /Users/williamviolette/Documents/Philippines/
	 
	 

* use allocation/temp/ais_case.dta, clear
* set more off
* clear all
* cd /Users/williamviolette/Documents/Philippines/

* program define import_aitf
* 	clear
* 	import delimited using ais/input/ais_data/AITF_`1'.csv, rowrange(2:) varnames(2) delimiters(",")
* end
* import_aitf CRMS_DATA

* keep cacctnb
* ren cacctnb conacct
* destring conacct, replace force
* duplicates drop conacct, force

* save "${temp}ais_conacct.dta", replace


*              Col5 |      0200       0300       0400       0500       0600       0700       0800 |     Total
* ----------------------+-----------------------------------------------------------------------------+----------
*   Business  Area Name |         0          0          0          0          0          0          0 |        12 
*                Cavite |         0          0          0          0          0          0    120,467 |   120,467 
* Fairview-Commonwealth |         0          0          0          0          0          0          0 |   164,169 
*       Malabon-Navotas |         0          0          0          0          0          0          0 |    88,352 
*  Muntinlupa-Las Pinas |         0          0          0          0          0          0          0 |   174,179 
*        North Caloocan |         0          0          0          0          0          0          0 |   143,172 
* Novaliches-Valenzuela |         0    137,708          0          0          0          0          0 |   137,708 
*             Paranaque |         0          0          0          0          0          0          0 |   117,519 
*     Quirino-Roosevelt |         0          0    132,730          0          0          0          0 |   132,730 
*              Sampaloc |         0          0          0     86,285          0          0          0 |    86,285 
*        South Caloocan |    91,220          0          0          0          0          0          0 |    91,220 
* South Manila-Pasay/.. |         0          0          0          0          0    105,935          0 |   105,935 
*                 Tondo |         0          0          0          0     98,554          0          0 |    98,554 
* ----------------------+-----------------------------------------------------------------------------+----------
*                 Total |    91,220    137,708    132,730     86,285     98,554    105,935    120,467 | 1,460,302 


*                  Col5 |      0900       1000       1100       1200       1700  Busines.. |     Total
* ----------------------+------------------------------------------------------------------+----------
*   Business  Area Name |         0          0          0          0          0         12 |        12 
*                Cavite |         0          0          0          0          0          0 |   120,467 
* Fairview-Commonwealth |   164,169          0          0          0          0          0 |   164,169 
*       Malabon-Navotas |         0     88,352          0          0          0          0 |    88,352 
*  Muntinlupa-Las Pinas |         0          0          0          0    174,179          0 |   174,179 
*        North Caloocan |         0          0          0    143,172          0          0 |   143,172 
* Novaliches-Valenzuela |         0          0          0          0          0          0 |   137,708 
*             Paranaque |         0          0    117,519          0          0          0 |   117,519 
*     Quirino-Roosevelt |         0          0          0          0          0          0 |   132,730 
*              Sampaloc |         0          0          0          0          0          0 |    86,285 
*        South Caloocan |         0          0          0          0          0          0 |    91,220 
* South Manila-Pasay/.. |         0          0          0          0          0          0 |   105,935 
*                 Tondo |         0          0          0          0          0          0 |    98,554 
* ----------------------+------------------------------------------------------------------+----------
*                 Total |   164,169     88,352    117,519    143,172    174,179         12 | 1,460,302





use "${temp}conacct_rate.dta", clear

		merge 1:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge

		merge m:1 mru using "${temp}mru_area.dta"
		drop if _merge==2
		drop _merge

gegen mrudc=min(datec), by(mru)

g oid = datec>=mrudc & datec<=mrudc+6

gegen ods=sum(oid), by(mru mrudc)
replace ods=. if ods<5
replace ods = ods/area

duplicates drop mru mrudc, force

gegen mmdc=mean(ods), by(mrudc ba)
gegen mmtt=tag(mrudc ba)


twoway scatter mmdc mrudc if mmtt==1 & ///
(ba==300 | ba==1100 | ba==800 | ba==1200 | ba==1700) & datec>545 & datec<=640, ///
 by(ba) xline(612)


gegen mmdc1=mean(ods), by(mrudc)
gegen mmtt1=tag(mrudc)

twoway scatter mmdc1 mrudc if mmtt1==1 & datec>545 & datec<=640



*** JUST USE NEW ONES!  ***



use "${temp}conacct_rate.dta", clear

		merge 1:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge


g pp_id = inst<3000 & inst>1000
g np_id = pp==0
g tp_id = 1


gegen pp=sum(pp_id), by(mru datec)
gegen np=sum(np_id), by(mru datec)
gegen tp=sum(tp_id), by(mru datec)

gegen mt=tag(mru datec)
keep if mt==1

keep pp np tp mru datec ba

tsset mru datec
tsfill, full

gegen ba_id=max(ba), by(mru)
drop ba
ren ba_id ba

replace pp = 0 if pp==.
replace np = 0 if np==.

g pp_id12 = pp>1 & pp<. & datec>=612
gegen mpp = sum(pp_id12), by(mru)
g mp = mpp>0 & mpp<.

g pp_ds_id =date if pp>0 & pp<.
g np_ds_id =date if np>0 & np<.

gegen pp_ds= min(pp_ds_id), by(mru)
gegen np_ds= min(np_ds_id), by(mru)

g date_tp_id = datec if tp>0 & tp<.
gegen mrudc=min(date_tp_id), by(mru)

keep if datec>=580


* tab pp_ds ba 
g Tpp = datec-pp_ds
g preexist=np_ds<=pp_ds-12
 * & np_ds>550 & pp_ds>550
g mun = ba == 1700 | ba == 800 | ba == 1100

tab mrudc ba if mrudc>=590 & mrudc<=624


cap drop ot
cap drop ott
	gegen ot=mean(pp), by(datec )
	gegen ott=tag(Tpp )
twoway scatter  ot  datec if ott==1



cap drop ot
cap drop ott
	gegen ot=mean(pp), by(datec ba)
	gegen ott=tag(Tpp ba )
twoway scatter  ot  datec if ott==1 & datec<=630, by(ba, rescale)



* cap drop ot
* cap drop ott
* 	gegen ot=mean(tp), by(datec mun)
* 	gegen ott=tag(Tpp mun )
* twoway scatter  ot  datec if ott==1, by(mun, rescale)



**** MUN PP ****
**** MUN PP ****

cap drop ot
cap drop ott
cap drop op
	gegen op=mean(tp), by(datec mun)
	gegen ot=mean(pp), by(datec mun)
	gegen ott=tag(Tpp mun )

twoway scatter ot datec if ott==1 || ///
	   scatter op datec if ott==1 , by(mun, rescale)


cap drop ot
cap drop ott
cap drop op
	gegen op=mean(tp), by(datec mun mp)
	gegen ot=mean(pp), by(datec mun mp)
	gegen ott=tag(Tpp mun mp )

twoway scatter ot datec if ott==1 & mun==0 || ///
	   scatter op datec if ott==1 & mun==0 , by(mp, rescale) xline(612)




cap drop ot
cap drop ott
cap drop op
cap drop mpp1
cap drop mpps
	gegen mpps=sum(pp), by(mru)
	g mpp1 = mpps>5 & mpps<.
	gegen op=mean(tp), by(datec mun mpp1)
	gegen ot=mean(pp), by(datec mun mpp1)
	gegen ott=tag(Tpp mun mpp1 )

twoway scatter  ot  datec if ott==1 & mun==0 || ///
	   scatter op  datec if ott==1  & mun==0 , by(mpp1, rescale) xline(612)



	cap drop ot
	cap drop ott
	cap drop op
	cap drop mpp1
	cap drop mpps
	cap drop post
	g post = mrudc>570
		gegen mpps=sum(pp), by(mru)
		g mpp1 = mpps>5 & mpps<.
		gegen op=mean(tp), by(datec mun mpp1 post)
		gegen ot=mean(pp), by(datec mun mpp1 post)
		gegen ott=tag(Tpp mun mpp1 post)

	twoway scatter  ot  datec if ott==1 & mun==0 || ///
		   scatter op  datec if ott==1  & mun==0 , by( post mpp1, rescale) xline(612)



**** MUN NP ****
**** MUN NP ****

cap drop ot
cap drop ott
	gegen ot=mean(np), by(datec mun)
	gegen ott=tag(Tpp mun )
twoway scatter  ot  datec if ott==1, by(mun, rescale)




cap drop ot
cap drop ott
	gegen ot=mean(pp), by(Tpp )
	gegen ott=tag(Tpp )
twoway scatter  ot  Tpp if ott==1


cap drop ot
cap drop ott
	gegen ot=mean(pp), by(Tpp ba )
	gegen ott=tag(Tpp ba )
twoway scatter  ot  Tpp if ott==1, by(ba, rescale)


cap drop ot
cap drop ott
	gegen ot=mean(pp), by(Tpp ba preexist )
	gegen ott=tag(Tpp ba preexist )
twoway scatter  ot  Tpp if ott==1 & preexist==0, by(ba, rescale)



cap drop ot
cap drop ott
	gegen ot=sum(o), by(TA pp)
	gegen ott=tag(TA pp)
twoway scatter  ot  TA if ott==1, by(pp)



cap drop ot
cap drop ott
	gegen ot=sum(o), by(Talt pp)
	gegen ott=tag(Talt pp)
twoway scatter  ot  Talt if ott==1, by(pp)



cap drop ot
  cap drop ott
	gegen ot=sum(o), by(Talt pp ba)
	gegen ott=tag(Talt pp ba)
twoway scatter  ot  T  if ott==1 & pp==1, by(ba, rescale)


cap drop ot
  cap drop ott
	gegen ot=sum(o), by(Talt pp ba preexist)
	gegen ott=tag(Talt pp ba preexist)
twoway scatter  ot  T  if ott==1 & pp==1, by(ba preexist, rescale)











odbc load, exec("SELECT * FROM paws_date")  dsn("phil") clear  

merge m:1 conacct using "${temp}conacct_rate.dta"
drop if _merge==2
drop _merge
g mr=string(mru,"%12.0g")
g mrg=substr(mr,1,4)
g muntin=mrg=="1700"

keep if datec>590
tab muntin
tab SHH muntin

*** NO PAWS COVERAGE! ***



use "${temp}conacct_rate.dta", clear
g mr=string(mru,"%12.0g")
g mrg=substr(mr,1,4)
g muntin=mrg=="1700"

merge 1:1 conacct using "${temp}ais_conacct.dta"
	g ais=_merge==3
	drop if _merge==2
	drop _merge
g o=1
gegen os=sum(o), by(datec muntin)
gegen tt=tag(datec muntin)

g datec1=datec
format datec1 %tm
twoway scatter os datec1 if tt==1 & datec>550, by(muntin)

		merge 1:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge

tab mrg if inst<3000 & datec<610 & datec>590

g d=inst<3000

gegen os1=sum(o), by(datec d muntin)
gegen tt1=tag(datec d muntin)
twoway scatter os1 datec1 if tt1==1 & datec>550, by(d muntin)


gegen os1=sum(o), by(datec d muntin)
gegen tt1=tag(datec d muntin)
twoway scatter os1 datec1 if tt1==1 & datec>580 & datec<630, by(d muntin)





	local 1 muntin

	local 1 qc_04
		use descriptives/output/`1'_mcf_2009_2015.dta, clear
	
		keep conacct year month BLK_UTIL

		fmerge m:1 conacct using "${temp}conacct_rate.dta"
			keep if _merge==3
			drop _merge
		keep if datec>580 & datec<630

		destring year month, replace force
		g date= ym(year,month)	
		drop year month
		destring BLK_UTIL, replace force

				fmerge m:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge

		g DC=BLK_UTIL!=.

		g lc=inst<=3000


		cap drop DC_6
		cap drop dcs6
		cap drop tt

		g DC_6 = 0 if date==datec+12
		replace DC_6 = 1 if  DC==1 & DC_6==0

		gegen dcs6=mean(DC_6), by(datec)
		gegen tt=tag(datec)

		twoway scatter dcs6 datec if tt==1

 		sum dcs6 if datec>610 & tt==1
 			* 5% disconnect within 6 months... never takers....


		cap drop dcs6a
		cap drop tta
		gegen dcs6a=mean(DC_6), by(datec lc)
		gegen tta=tag(datec lc)

		twoway scatter dcs6a datec if tta==1, by(lc)










		* use descriptives/output/`1'_billing_2008_2015.dta, clear


		keep if billclass=="0001"
			ren CONTRACT_A conacct
			keep conacct PREV PRES year month
			destring PREV PRES  year month, replace force
			g date=ym(year,month)
			drop year month

			g c=PRES-PREV
			replace c=. if c<0 | c>200
			
			keep conacct date c




			merge m:1 conacct using "${temp}neighbor_datec.dta"
			drop if _merge==2
			drop _merge
			keep if datec<580

			ren conacct conacct_true
			ren conacctn conacct
				merge m:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge
			ren conacct conacctn
			ren conacct_true conacct

		keep if datecn>590


		g icat= 1 if inst<=2800
		replace icat=2 if inst>2800 & inst<5500
		replace icat=3 if inst>=5500 & inst<.

		g T = date-datecn

		gegen cT = mean(c), by(T)
		gegen tt = tag(T)

		twoway scatter cT T if tt==1 & T>=-12 & T<=12



			gegen cTi = mean(c), by(T icat)
			gegen tti = tag(T icat)
		twoway scatter cTi T if tti==1 & T>=-12 & T<=12, by(icat, rescale)


			gegen cTin = mean(c), by(T napc)
			gegen ttin = tag(T napc)
		twoway scatter cTin T if ttin==1 & T>=-12 & T<=12, by(napc, rescale)



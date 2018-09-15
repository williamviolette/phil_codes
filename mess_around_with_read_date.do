




use "${billingdata}pasay_mcf_2009_2015.dta", clear
keep conacct month year BLK_UTIL
*keep if BLK_UTIL== "TCD" | BLK_UTIL=="6" | BLK_UTIL=="06" | BLK_UTIL== "PCD"| BLK_UTIL=="7" | BLK_UTIL=="07"
		destring month year, replace force
		g date = ym(year,month)

g TCD = BLK_UTIL== "TCD" | BLK_UTIL=="6" | BLK_UTIL=="06"
g PCD = BLK_UTIL== "PCD" | BLK_UTIL=="7" | BLK_UTIL=="07"
duplicates drop conacct month year, force
drop BLK_UTIL year month
save "${temp}pasay_mcf_test.dta", replace





use "${billingdata}pasay_coll_2008_2015.dta", clear
	
drop if year=="2008"
ren totalpymnt pay 
keep conacct pay year month
destring year month, replace
g date = ym(year, month)
drop year month
drop if abs(pay)<10
egen ps = sum(pay), by(date conacct)
drop pay
duplicates drop date conacct, force

save "${temp}pasay_coll_series_test.dta", replace



use "${temp}pasay_mcf_test.dta", clear

merge 1:1 date conacct using "${temp}pasay_coll_series_test.dta"
drop if _merge==2
drop _merge

replace ps=0 if ps==.

sort conacct date
by conacct: g ts_id = TCD[_n-1]==0 & TCD[_n]==1
g date_ts_id = date if ts_id==1
egen tsd = min(date_ts_id), by(conacct)

g T = date-tsd


by conacct: g ps_id = PCD[_n-1]==0 & PCD[_n]==1
g date_ps_id = date if ps_id==1
egen psd = min(date_ps_id), by(conacct)

g TP = date-psd


keep if ps>=0 & ps<50000


set seed 1
g r=runiform()
sort conacct date
by conacct: g r1=r if _n==1
egen R=max(r1), by(conacct)



preserve
	keep if T!=.
	keep if R<.1

	keep if T>=-12 & T<=12
	tab T, g(TT_)
	drop TT_1

	areg ps TT_* i.date, a(conacct) cl(conacct)

	coefplot, vertical keep(TT_*)

restore




preserve
	keep if TP!=.
	*keep if R<.4

	keep if TP>=-12 & TP<=12
	tab TP, g(TP_)
	drop TP_1

	areg ps TP_* i.date, a(conacct) cl(conacct)

	coefplot, vertical keep(TP_*)

restore




***** TESTING JUST ARBITRAGE *****




use "${billingdata}pasay_coll_2008_2015.dta", clear

ren totalpymnt pay 
keep conacct pay

egen TP = sum(pay), by(conacct)
keep conacct TP
duplicates drop conacct, force

save "${temp}pasay_coll_test.dta", replace




/*

* DATA_PREP *
odbc load, exec("SELECT * FROM date_c;") dsn("phil") clear
save "${temp}date_c_test.dta", replace


use "${billingdata}pasay_billing_2008_2015.dta", clear 
		ren CONTRACT_A conacct
		drop if conacct == .
		keep if billclass=="0001"
		drop billclass
		merge m:1 conacct using "${temp}date_c_test.dta"
			keep if _merge==3
			drop _merge
		keep if date_c>590 & date_c<.


		*replace readtag=upper(readtag)
		*keep if readtag=="ACT"
		*ren billclass class
		keep PREV PRES month year conacct date_c 		/* KEEP STATEMENT */
		
		destring PREV PRES, replace force
		g c= PRES-PREV
		replace c=abs(c)
		drop if c<0 | c>300
		drop PRES PREV
		destring month year, replace force
		g date = ym(year,month)

		keep conacct date c date_c 						/* KEEP STATEMENT */

		duplicates drop conacct date, force

		tsset conacct date
		tsfill, full
	
		egen date_c_m=max(date_c), by(conacct)
		replace date_c=date_c_m
		drop date_c_m

		drop if date<date_c

save "${temp}starters.dta", replace

*/





use  "${temp}starters.dta", clear

merge m:1 conacct using "${temp}pasay_coll_test.dta"
	drop if _merge==2
	drop _merge


sort conacct date

local kc " c[_n]==. "
local rmax "12"
forvalues r = 1/`=`rmax'' {
	local kc "`kc' & c[_n+`r']==. "
}
by conacct: g dc = `kc'

replace dc = 0 if date>=664-`=`rmax''


g date_dc_id = date if dc==1
egen d_dc = min(date_dc_id), by(conacct)

bys conacct: g c_n=_n

g t = d_dc - date_c


hist t if c_n==1 & t>3, discrete

tab t if c_n==1 & t>3

browse if c_n==1 & date_c<664-12 -2


g TP1 = TP if TP<100000 & TP>0

egen c_s = sum(c), by(conacct)

g pr = TP1/c_s
replace pr = . if pr<3 | pr>60

egen mc = mean(c), by(conacct)



sum mc if c_n==1 & d_dc==.
sum mc if t>24 & t<. & c_n==1


preserve
	keep if mc<100
		qui sum pr if c_n==1 & d_dc==.

		disp "Connected: `=round(r(mean),.1)'"

		qui sum pr if c_n==1 & d_dc!=.

		disp "DC : `=round(r(mean),.1)'"

		qui sum pr if t>3 & t<=18 & c_n==1

		disp "DC early: `=round(r(mean),.1)'"

		qui sum pr if t>24 & t<. & c_n==1

		disp "DC later: `=round(r(mean),.1)'"

restore




preserve 
	keep if mc<100

		qui sum pr if c_n==1 & date_c<620 & d_dc==.
		disp "Pre non-cheaters: `=round(r(mean),.1)'"

		qui sum pr if c_n==1 & date_c>=620 & d_dc==.
		disp "Post non-cheaters: `=round(r(mean),.1)'"

		qui sum pr if c_n==1 & date_c<620 & t>6 & t<12
		disp "Pre cheaters: `=round(r(mean),.1)'"

		qui sum pr if c_n==1 & date_c>=620 & t>6 & t<12
		disp "Post cheaters: `=round(r(mean),.1)'"

restore 





sum TP if c_n==1 & t>3 & t<. & TP<






by conacct: g cmiss = c == . & _n==_N


forvalues r = 1/10 {
	by conacct: replace cmiss = 1 if c==. & _n==_N-`r'
	*by conacct: replace cmiss = 1 if c[_N-`r'+1]==. & c[_N-`r']==.
}	


egen cmiss_s = sum(cmiss), by(conacct)











/*

**** NOT MUCH WITH EXTRA READ PERIOD

use "${billingdata}pasay_billing_2008_2015.dta", clear 
		ren CONTRACT_A conacct
		drop if conacct == .
		keep if billclass=="0001"
		replace readtag=upper(readtag)
		keep if readtag=="ACT"
		ren billclass class
		*keep PREV PRES month year conacct readtag class
		destring PREV PRES, replace force
		g c= PRES-PREV
		replace c=abs(c)
		drop if c<0 | c>100
		drop PRES PREV
		destring month year, replace force
		g date = ym(year,month)


		duplicates drop conacct date, force
		

		ren NO_OF_DAYS days

		destring days, replace force
		keep if days>=25 & days<=35

		g cp = c/days


		reg days i.month

		coefplot, vertical

		reg cp days i.month

		sort conacct date
		by conacct: g days_lag = days[_n-1]
		by conacct: g days_lead = days[_n+1]

		by conacct: g days_lag2 = days[_n-2]
		by conacct: g days_lead2 = days[_n+2]


		areg cp days days_lag* days_lead* i.month i.year, a(conacct) cl(conacct)	
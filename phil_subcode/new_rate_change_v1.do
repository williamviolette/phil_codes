
* new_rate_change.do

global gen_rate = 0
global gen_rate_neighbor = 0
global gen_neighbor_bill_query = 0

clear all
set more off
cd /Users/williamviolette/Documents/Philippines/





cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end


if $gen_rate == 1 {

	use database/clean/mcf/2015/full_2015.dta, clear
			drop if Col3=="Row Count"
	ren Col4  ba
	ren Col12 conacct
	ren Col6  zone_code
	ren Col10 mru
	ren Col53 bus
	ren Col52 bus_id
	ren Col46 rateclass_key
	ren Col39 dc
	g year=substr(Col19,1,4)
	g month=substr(Col19,6,2)
	destring year month, replace force
	g datec = ym(year,month)
	drop year month
		drop C*
			destring ba conacct zone_code mru bus_id dc, replace force
			drop if conacct==.
			duplicates drop conacct, force
	save "${temp}conacct_rate.dta", replace
		* ren Col13 installation	* duplicates drop conacct installation, force	* g o = 1	* gegen os = sum(o), by(conacct)

prog define data_prep
		use descriptives/output/`1'_billing_2008_2015.dta, clear
		
			ren CONTRACT_A conacct
			keep conacct PREV PRES billclass year month
			destring PREV PRES billclass year month, replace force
			g date=ym(year,month)
			drop year month

			g c=PRES-PREV
			replace c=. if c<0 | c>200
			
			keep conacct date c billclass

			gegen bc_max=max(billclass), by(conacct)
			gegen bc_min=min(billclass), by(conacct)
			keep if bc_max!=bc_min
		
		save "${temp}`1'_rate_change.dta", replace
end
	
foreach v in bacoor muntin tondo pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para {
	data_prep `v'
}
	
use  "${temp}tondo_rate_change.dta", clear
	foreach v in bacoor muntin pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para  {	
	append using "${temp}`v'_rate_change.dta"
	}

	preserve
		gegen ctag=tag(conacct)
		keep if ctag==1
		keep conacct
		gentable conacct_rch
	restore
save "${temp}rate_change_total.dta", replace

}



if $gen_rate_neighbor == 1 {


odbc load, exec("SELECT * FROM neighbor_rs_20")  dsn("phil") clear  
save "${temp}neigbor_rs_20.dta", replace

odbc load, exec("SELECT * FROM paws")  dsn("phil") clear  
gegen wm=max(wave), by(conacct)
keep if wave==wm
keep conacct SHH
save "${temp}n_shh.dta", replace



*** find date of change for each r-to-s account
use "${temp}rate_change_total.dta", clear
	
	merge m:1 conacct using "${temp}conacct_rate.dta"
		drop if _merge==2
		drop _merge
    * keep if bus_id == 1001 // *** Keep only residential houses ***
	* drop bus_id bus // *** Keep only residential houses ***
	* drop if bus_id>2001 & bus_id<. // ** keep houses, sari-sari's, and bayan tubig's


	keep if bc_max==2
	gegen tt = tag(conacct date)
		keep if tt==1
		drop tt
	sort conacct date
		by conacct: g billclass_l1 = billclass[_n-1]
		keep if billclass_l1 == 1  &  billclass == 2
	gegen md=min(date), by(conacct)
	keep if date==md
	keep conacct date
save "${temp}r_to_s_date.dta", replace


*** identify neighbors of r-to-s accounts
use "${temp}neigbor_rs_20.dta", clear
	* conacctp is the one with rate changes
	global rnum = 5
	keep if rank<=$rnum
	keep if distance<=5
	ren conacct conacctn
	ren conacctp conacct
		merge m:1 conacct using "${temp}r_to_s_date.dta"
		keep if _merge==3
		drop _merge

		merge m:1 conacct using "${temp}n_shh.dta"
		drop if _merge==2
		drop _merge
forvalues r=1/$rnum {
	g r_`r'_id = 1 if rank==`r'
	gegen r_`r' = sum(r_`r'_id), by(conacctn date)
	drop r_`r'_id
	g di_`r'_id = distance if rank==`r'
	gegen di_`r' = sum(di_`r'_id), by(conacctn date)
	drop di_`r'_id
		g s_`r'_id = SHH if rank==`r'
	gegen s_`r' = min(s_`r'_id), by(conacctn)
	drop s_`r'_id
}

keep conacctn date r_* di_* s_*
	gegen tt = tag(conacctn date)
		keep if tt==1
		drop tt
	ren conacctn conacct
preserve
	keep conacct
	duplicates drop conacct,  force
	gentable r_to_s_conacct_n
restore
save "${temp}r_to_s_date_neighbor.dta", replace


if $gen_neighbor_bill_query == 1 {
	local bill_query ""
	forvalues r = 1/12 {
		local bill_query " `bill_query'  SELECT A.* FROM billing_`r' AS A JOIN r_to_s_conacct_n AS B ON A.conacct = B.conacct "
		if `r'!=12{
			local bill_query "`bill_query' UNION ALL"
		}
	}

	odbc load, exec("`bill_query'")  dsn("phil") clear  

	save "${temp}r_to_s_bill.dta", replace
}





use "${temp}r_to_s_bill.dta", clear
	gegen tt=tag(conacct date)
	keep if tt==1
	drop tt

	merge m:1 conacct date using "${temp}r_to_s_date_neighbor.dta"
	drop if _merge==2 // lose 6000 here!
	drop _merge

	merge m:1 conacct using "${temp}conacct_rate.dta"
	drop if _merge==2
	drop _merge

	merge m:1 mru using "${temp}mru_cf.dta"
	drop if _merge==2
	drop _merge

g cm=c>0 & c<.
gegen cms=sum(cm), by(conacct)
keep if cms>60

sort conacct date

g r_1a = r_1 if di_1<=1 & s_1>=3 & s_1<=3
g r_2a = r_2 if di_2<=1 & s_2>=3 & s_2<=3
g r_3a = r_3 if di_3<=1 & s_3>=3 & s_3<=3
g r_4a = r_4 if di_4<=1 & s_4>=3 & s_4<=3
g r_5a = r_5 if di_5<=1 & s_5>=3 & s_5<=3

* g r_1a = r_1 if di_1<=1 & s_1>=2 & s_1<=3
* g r_2a = r_2 if di_2<=1 & s_2>=2 & s_2<=3
* g r_3a = r_3 if di_3<=1 & s_3>=2 & s_3<=3
* g r_2a = r_2 if s_2!=.
* g r_1a = r_1 if mrub>=.7 & mrub<=1 
* g r_2a = r_2 if mrub>=.7 & mrub<=1 

egen rs=rowtotal( r_*a  )

g date_rs_id = date if rs>0 & rs<.
gegen date_rs = min(date_rs_id), by(conacct)
g T_rs=date-date_rs
gegen c_rs=mean(c), by( T_rs )
gegen t_rs=tag( T_rs )

twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-24 & T_rs<=36

g T_rs1=T_rs+100

areg c i.T_rs1 i.date if T_rs>=-36 & T_rs<=36, a(conacct) 

coefplot, vertical keep(*T_rs1*)


replace T_rs1 = 1000 if T_rs<-24 | T_rs>24

areg c i.T_rs1 i.date, a(conacct) 

coefplot, vertical keep(*T_rs1*)




cap drop date_rs1_id
cap drop date_rs1
cap drop T_rs1
cap drop Trs1
cap drop Trs1a

cap drop date_rs2_id
cap drop date_rs2
cap drop T_rs2
cap drop Trs2
cap drop Trs2a


g date_rs1_id = date if r_1>0 & r_1<.
gegen date_rs1 = min(date_rs1_id), by(conacct)
g Trs1=date-date_rs1

g date_rs2_id = date if r_2>0 & r_2<.
gegen date_rs2 = min(date_rs2_id), by(conacct)
g Trs2=date-date_rs2

g Trs1a=Trs1+100
replace Trs1a = 1000 if Trs1<-36 | Trs1>36

g Trs2a=Trs2+100
replace Trs2a = 1000 if Trs2<-36 | Trs2>36

areg c i.Trs1a i.Trs2a i.date , a(conacct) 

coefplot, vertical keep(*Trs1a* *Trs2a*)








use "${temp}neigbor_rs_20.dta", clear
	* conacctp is the one with rate changes
	global rnum = 5
	keep if rank<=$rnum
	keep if distance<=5
	
	ren conacct conacctn

	ren conacctp conacct
		merge m:1 conacct using "${temp}r_to_s_date.dta"
		keep if _merge==3
		drop _merge

		merge m:1 conacct using "${temp}n_shh.dta"
		drop if _merge==2
		drop _merge
		
forvalues r=1/$rnum {
	g r_`r'_id = 1 if rank==`r'
	gegen r_`r' = sum(r_`r'_id), by(conacctn)
	g d_`r'_id = date if rank==`r'
	gegen d_`r' = min(d_`r'_id), by(conacctn)
	g s_`r'_id = SHH if rank==`r'
	gegen s_`r' = min(s_`r'_id), by(conacctn)
	drop r_`r'_id d_`r'_id s_`r'_id
}

keep conacctn r_* d_* s_*

	gegen tt = tag(conacctn)
		keep if tt==1
		drop tt
ren conacctn conacct

save "${temp}r_to_s_d1_neighbor.dta", replace







********* look for new connection formation!

use "${temp}r_to_s_bill.dta", clear
	gegen tt=tag(conacct date)
	keep if tt==1
	drop tt

	merge m:1 conacct using "${temp}r_to_s_d1_neighbor.dta"
	drop if _merge==2 // lose 6000 here!
	drop _merge


	merge m:1 conacct using "${temp}n_shh.dta"
	drop if _merge==2
	drop _merge
		
* keep if SHH!=.

egen dm=rowmin(d_*)
* egen sm=rowmin(s_*)
* keep if sm==1   * keep if s_1>1 & s_1<.   * keep if s_1==1

g T_rs=date-dm

gegen c_rs=mean(c), by( T_rs )
gegen t_rs=tag( T_rs )

twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-24 & T_rs<=24

g T_rs1=T_rs+100

areg c i.T_rs1 i.date if T_rs>=-12 & T_rs<=24, a(conacct)  cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)

*** is something compositional happening?!
reg c i.T_rs1 i.date if T_rs>=-12 & T_rs<=24,  r
	coefplot, vertical keep(*T_rs1*)




****** TEST WHETHER PEOPLE ARE SWITCHING TO NEW CONNECTIONS??? ******
****** TEST WHETHER PEOPLE ARE SWITCHING TO NEW CONNECTIONS??? ******
****** TEST WHETHER PEOPLE ARE SWITCHING TO NEW CONNECTIONS??? ******

use "${temp}neigbor_rs_20.dta", clear
	* conacctp is the one with rate changes
	global rnum = 5
	keep if rank<=$rnum
	keep if distance<=5
	ren conacct conacctn
	ren conacctp conacct
		merge m:1 conacct using "${temp}r_to_s_date.dta"
			keep if _merge==3
			drop _merge
		merge m:1 conacct using "${temp}n_shh.dta"
			drop if _merge==2
			drop _merge
	ren conacct conacct_true
	ren conacctn conacct		
		merge m:1 conacct using "${temp}conacct_rate.dta"
			keep if _merge==3
			drop _merge
		ren conacct conacctn
		ren conacct_true conacct

forvalues r=1/$rnum {
	g r_`r'_id = 1 if rank==`r'
	gegen r_`r' = sum(r_`r'_id), by(conacctn)
	g d_`r'_id = datec if rank==`r'
	gegen d_`r' = min(d_`r'_id), by(conacctn)
	drop r_`r'_id d_`r'_id
}

g rst = 1
keep conacct date rst d_* 
duplicates drop conacct date, force
tsset conacct date
tsfill, full

g daters_id = date if rst==1

foreach var of varlist d_* {
	gegen m`var' = max(`var'), by(conacct)
	g md`var'=m`var'==date
	drop m`var' `var'
}

gegen daters = max(daters_id), by(conacct)
egen smd = rowtotal(mdd*)
g T_rs=date-daters
g T_rs1=T_rs+100

gegen smd_rs=mean(smd), by( T_rs )
gegen t_rs=tag( T_rs )

twoway scatter smd_rs T_rs if t_rs==1 & T_rs>=-24 & T_rs<=24

areg mdd_1 i.T_rs1 i.date if T_rs>=-12 & T_rs<=12, a(conacct)  cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)

areg smd i.T_rs1 i.date if T_rs>=-12 & T_rs<=12, a(conacct)  cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)

************* **************** ************* ******************* ***********
************* **************** ************* ******************* ***********
************* **************** ************* ******************* ***********





local bill_query ""
forvalues r = 1/12 {
	local bill_query " `bill_query'  SELECT A.*,  B.conacctp, B.rank, `r' AS ba FROM mcf_`r' AS A JOIN (SELECT * FROM neighborp_50) AS B 	ON A.conacct = B.conacct "
	if `r'!=12{
		local bill_query "`bill_query' UNION ALL"
	}
}

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}mcf_temp_neighbor_big.dta", replace



use "${temp}mcf_temp_neighbor_big.dta", clear

sort conacctp conacct date 
by conacctp conacct: g id = date[_n-1]+1==date[_n]
drop if id==1
drop id


forvalues r=1/20 {
	g r_`r'_id = 1 if rank==`r'
	gegen r_`r' = sum(r_`r'_id), by(conacctp date)
	drop r_`r'_id
}

keep conacctp date r_*
duplicates drop conacctp date, force
ren conacctp conacct

save "${temp}neighbor_dc_full.dta", replace 






use "${temp}rate_change_total.dta", clear

merge m:1 conacct using "${temp}conacct_rate.dta"
	drop if _merge==2
	drop _merge

keep if bc_max<=2

sort conacct date
by conacct: g billclass_l1 = billclass[_n-1]

g r_to_s = billclass_l1==1 & billclass==2
replace r_to_s = . if date==596

g date_rs_id = date if r_to_s==1
gegen date_rs = min(date_rs_id), by(conacct)

g T_rs=date-date_rs
g T_rs1 = T_rs+100

gegen mc=mean(c), by(T_rs)
gegen Tt=tag(T_rs)

twoway scatter mc T_rs if Tt==1  & T_rs>-24 & T_rs<24

areg c i.T_rs1 i.date if T_rs>=-24 & T_rs<=24 , a(conacct)
	coefplot, vertical keep(*T_rs1*)


g cnm=c>0 & c<.
gegen cns=sum(cnm), by(conacct)





/*

*** GENERATE MORE NEIGHBOR MEASURES

use  "${temp}mcf_temp_neighbor.dta", clear
	keep if dc==1
	gegen min_date = min(date), by(conacct)
	keep if date==min_date
	drop min_date
	keep date conacct
	duplicates drop conacct, force
	drop if date<600

save "${temp}mcf_temp_neighbor_date.dta", replace



prog define data_prep_neighbor
		use descriptives/output/`1'_billing_2008_2015.dta, clear
		
			ren CONTRACT_A conacct
			keep conacct PREV PRES billclass year month
			destring PREV PRES billclass year month, replace force
			g date=ym(year,month)
			drop year month

			g c=PRES-PREV
			replace c=. if c<0 | c>200
			
			keep conacct date c billclass

			merge 1:1 
		
		save "${temp}`1'_rate_change_neighbor.dta", replace
end
	
foreach v in bacoor muntin tondo pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para {
	data_prep_neighbor `v'
}
	
use  "${temp}tondo_rate_change_neighbor.dta", clear
	foreach v in bacoor muntin pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para  {	
	append using "${temp}`v'_rate_change_neighbor.dta"
	}


}




/*



***** EXAMINE WITH ZEROS! *****


use "${temp}rate_change_total.dta", clear

merge m:1 conacct using "${temp}conacct_rate.dta"
	drop if _merge==2
	drop _merge

keep if bc_max<=2

sort conacct date
by conacct: g billclass_l1 = billclass[_n-1]

g res = bus_id==1001 | bus_id==1002 | bus_id==2001
* keep if bus_id==1001

cap drop rcat
g rcat= bus_id if bus_id<=2001
replace rcat=0 if rcat==.

* hist date if r_to_s==1
* hist date, by(r_to_s)
* foreach var of varlist r_to_s date_rs_id date_rs T_rs c_rs t_rs {
* cap drop `var'
* }

g r_to_s = billclass_l1==1 & billclass==2
replace r_to_s = . if date==596

g date_rs_id = date if r_to_s==1
gegen date_rs = min(date_rs_id), by(conacct)

g T_rs=date-date_rs

gegen c_rs=mean(c), by(T_rs  rcat)
gegen t_rs=tag(T_rs rcat)

g T_rs1 = T_rs+100


g cnm=c>0 & c<.
gegen cns=sum(cnm), by(conacct)


* datec matters    a lot!
* missing matters  a lot!
* 

areg c i.T_rs1 i.date if T_rs>=-24 & T_rs<=24 , a(conacct)
	coefplot, vertical keep(*T_rs1*)



areg c i.T_rs1 i.date if T_rs>=-36 & T_rs<=48  & datec<=550, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)


areg c i.T_rs1 i.date if T_rs>=-36 & T_rs<=48 & cns>60 & datec<=550, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)


* areg c i.T_rs1 i.date if T_rs>=-36 & T_rs<=48 & rcat==1001 & cns>60 & datec<=550, a(conacct) cluster(conacct) r
* 	coefplot, vertical keep(*T_rs1*)


areg c i.T_rs1 i.date if T_rs>=-36 & T_rs<=48 & rcat==1001, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)

g cmt = c if c>0
areg cmt i.T_rs1 i.date if T_rs>=-36 & T_rs<=48 & rcat==1001, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)

g cm0 = c
	replace cm0 = 0 if c==.
areg cm0 i.T_rs1 i.date if T_rs>=-36 & T_rs<=48 & rcat==1001, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)







*******************************************
**** WHAT HAPPENS TO DISCONNECTIONS?! *****   STRONGGG TRENDS!!!
*******************************************


use "${temp}rate_change_total.dta", clear

merge m:1 conacct using "${temp}conacct_rate.dta"
	drop if _merge==2
	drop _merge
	keep if bus_id==1001

duplicates drop conacct date, force
tsset conacct date
tsfill, full

* ren billclass billclass_id
ren bc_max bc_max_id
ren bc_min bc_min_id
gegen bc_max=max(bc_max_id), by(conacct)
gegen bc_min=max(bc_min_id), by(conacct)
* gegen billclass=max(billclass_id), by(conacct)
	drop bc_max_id
	drop bc_min_id
	* drop billclass_id

keep if bc_max<=2

sort conacct date
by conacct: g billclass_l1 = billclass[_n-1]

g r_to_s = billclass_l1==1 & billclass==2
replace r_to_s = . if date==596

g date_rs_id = date if r_to_s==1
gegen date_rs = min(date_rs_id), by(conacct)

g T_rs=date-date_rs

g DC = c == . | c == 0
g DCm = c==.

g T_rs1 = T_rs+100

areg DC i.T_rs1 i.date if T_rs>=-48 & T_rs<=48, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)


areg DCm i.T_rs1 i.date if T_rs>=-48 & T_rs<=48, a(conacct) cluster(conacct) r
	coefplot, vertical keep(*T_rs1*)







/*

twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-24 & T_rs<=24, by(rcat)




twoway scatter c_rs T_rs if t_rs==1 & rcat==2001 & T_rs>=-36 & T_rs<=36


twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-48 & T_rs<=48 & rcat==1001

* twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-36 & T_rs<=36 & rcat==2001


twoway scatter c_rs T_rs if t_rs==1 & T_rs>=-36 & T_rs<=36, by(rcat)




foreach v in s_to_r date_sr_id date_sr T_sr c_sr t_sr {
cap drop `v'
}

g s_to_r = billclass_l1==2 & billclass==1

g date_sr_id = date if s_to_r==1
gegen date_sr = min(date_sr_id), by(conacct)

g T_sr=date-date_sr

gegen c_sr=mean(c), by(T_sr  rcat)
gegen t_sr=tag(T_sr rcat)

twoway scatter c_sr T_sr if t_sr==1 & rcat==2001 & T_sr>=-48  & T_sr<=48





/*

global R_TO_S_DATA_PREP_ = 1

if $R_TO_S_DATA_PREP_ == 1 {
local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"

#delimit;
local bill_query "";

forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT  A.c, A.class, A.read,
	C.p_L, C.p_H1, C.p_H2, C.p_H3, B.*
	FROM billing_`r' AS A 
	JOIN paws_date AS B 
		ON A.conacct = B.conacct AND A.date = B.date
	JOIN price AS C
		ON A.date = C.date AND A.class = C.class
	WHERE A.class==1 OR A.class==2
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

duplicates   drop   conacct   date,  force

* sort conacct date
* by conacct: g R_to_S=class[_n-1]==1 & class[_n-2]==1 & class[_n-3]==1 & class[_n]==2 & class[_n+1]==2 & class[_n+2]==2
* egen R_to_S_max = max(R_to_S), by(conacct)

save "${temp}r_to_s_date.dta", replace

}

*** THIS TEST DOES NOT WORK! ***
use "${temp}r_to_s_date.dta", clear


sort conacct date
by conacct: g class_lag=class[_n-1]

tab class class_lag

areg c i.class i.date if c<200, a(conacct) cluster(conacct)
areg SHH i.class i.date if c<200, a(conacct) cluster(conacct)





***** CHECK METER *****
***** CHECK METER *****
***** CHECK METER *****
***** CHECK METER *****


odbc load, exec("SELECT CS.conacct FROM meter AS M JOIN conacctseri AS CS ON CS.OGC_FID=M.OGC_FID")  dsn("phil") clear  
duplicates drop conacct, force
save "${temp}conacct_meter.dta", replace

use "${temp}conacct_rate.dta", clear

merge 1:1 conacct using "${temp}conacct_meter.dta"
g meter=_merge==3
drop if _merge==2
drop _merge

tab meter rate

keep if bus_id==1001
keep if regexm(rateclass_key,"Residential")==1 | regexm(rateclass_key,"Semi")==1
keep if dc==.
keep if datec<=620

* tab datec meter
* gegen mm=mean(meter), by(datec)
* gegen dtc=tag(datec)
* twoway scatter mm datec if dtc==1


gegen mrm=mean(meter), by(mru)
gegen mt=tag(mru)

hist mrm if mt==1
sum mrm if mt==1, detail

sum mrm if mt==1 & mrm>0, detail







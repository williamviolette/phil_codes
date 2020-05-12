* pressure.do




*** NOW! measure externalities .. HOW MANY?!?  enough....

* 1. narrow to low-flow MRUs  (high meter merge: eh; this happens naturally..)
* 
* 


global load_data=0

if $load_data == 1 {


	use  /Users/williamviolette/Documents/Philippines/non_payment_exploration/temp/pipe_mru, clear
		keep if pipe_class=="TERTIARY"
		destring year_inst mru, replace force
		egen ly=sum(length), by(mru year_inst)
		egen max_l=max(ly), by(mru)
		egen total_mru=sum(length), by(mru)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		keep length year_inst mru shr
		duplicates drop mru, force
		ren mru mru
	save "${temp}pipe_year_old.dta", replace
	




use "${temp}capex_raw.dta", clear

keep var8 var3
keep if var8!=""
replace var8=regexs(1) if regexm(var8,"^(.+)/")
replace var8=regexs(1) if regexm(var8,"^(.+)/")
replace var8=regexs(1) if regexm(var8,"^(.+) ")
replace var8=strtrim(var8)
replace var8=regexs(1) if regexm(var8,"^(.+) ")
replace var8=strtrim(var8)

* keep var8 var39
* g yr = "20"+substr(var39,1,2) ** MONTH FINISHED! 
* destring yr, replace force
* g mn = substr(var39,4,3)

** USE MONTH DECLARED **
g yr = "20"+substr(var3,1,2)
destring yr, replace force
g mn = substr(var3,4,3)

g month = 1 if mn=="Jan"
replace month = 2 if mn=="Feb"
replace month = 3 if mn=="Mar"
replace month = 4 if mn=="Apr"
replace month = 5 if mn=="May"
replace month = 6 if mn=="Jun"
replace month = 7 if mn=="Jul"
replace month = 8 if mn=="Aug"
replace month = 9 if mn=="Sep"
replace month = 10 if mn=="Oct"
replace month = 11 if mn=="Nov"
replace month = 12 if mn=="Dec"

g date = ym(yr,month)
ren var8 contract_n
keep date contract_n
keep if date!=.
duplicates drop contract_n date, force
replace contract_n=subinstr(contract_n," to","",.)
duplicates drop contract_n, force
ren date date_capex
save "${temp}capex_date.dta", replace


*** HERE IS THE PAWS EXERCISE! * IT WORKS!!! ***
* odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, I.contract_n FROM pipe_primary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.org_fid")  dsn("phil") clear  




odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, I.contract_n FROM pipe_primary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.org_fid")  dsn("phil") clear  
destring year_inst, replace force
merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
	drop contract_n
save "${temp}dist_primary_points_conacct.dta", replace

odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, I.contract_n FROM pipe_secondary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.fid")  dsn("phil") clear  
destring year_inst, replace force
merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
	drop contract_n
save "${temp}dist_secondary_points_conacct.dta", replace

odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, I.contract_n FROM pipe_tertiary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.fid")  dsn("phil") clear  
destring year_inst, replace force
merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
	drop contract_n
save "${temp}dist_tertiary_points_conacct.dta", replace




odbc load, exec("SELECT * FROM pipe_primary_dist")  dsn("phil") clear  
drop rank OGC_FID
save "${temp}dist_primary_conacct.dta", replace

odbc load, exec("SELECT * FROM pipe_secondary_dist")  dsn("phil") clear  
drop rank OGC_FID
save "${temp}dist_secondary_conacct.dta", replace

odbc load, exec("SELECT P.conacct, P.distance, I.year_inst FROM pipe_tertiary_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
destring year_inst, replace force
save "${temp}dist_tertiary_conacct.dta", replace

odbc load, exec("SELECT * FROM valves_dist")  dsn("phil") clear  
drop rank OGC_FID
save "${temp}dist_valves_conacct.dta", replace




use  "${temp}ml_leak_raw.dta", clear

global zc=636

forvalues r=2(1)30 {
ren var`r' mll$zc
global zc = $zc + 1
}

ren var1 dma

	reshape long mll, i(dma) j(date)
	drop if dma==""
	drop if mll==.

save "${temp}ml_leak.dta", replace


use  "${temp}sl_leak_raw.dta", clear

global zc=636

forvalues r=2(1)30 {
ren var`r' sll$zc
global zc = $zc + 1
}

ren var1 dma

	reshape long sll, i(dma) j(date)
	drop if dma==""
	drop if sll==.

save "${temp}sl_leak.dta", replace



use "${temp}nrw_raw.dta", clear


global zc = 587

forvalues r=4(6)466 {
ren var`r' supp$zc
ren var`=`r'+1' bill$zc
global zc = $zc + 1
}

ren var2 dma
keep dma supp* bill*

preserve
	keep dma supp*
	reshape long supp, i(dma) j(date)
	drop if dma==""
	drop if supp==.
	save "${temp}nrw_supp.dta", replace
restore		

	keep dma bill*
	reshape long bill, i(dma) j(date)
	drop if dma==""
	drop if bill==.
	merge 1:1 dma date using  "${temp}nrw_supp.dta"
	keep if _merge==3
	drop _merge

save "${temp}nrw.dta", replace



odbc load, exec("SELECT * FROM meter_dma_int")  dsn("phil") clear  
	g str10 dma = dma_id
		drop dma_id
	keep dma conacct
	duplicates drop conacct, force
save "${temp}conacct_dma_link.dta", replace


}



cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end

cap program drop gentablenp
program define gentablenp
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind1 ON `1' (conacct_1);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind2 ON `1' (conacct_2);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind3 ON `1' (conacct_3);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind4 ON `1' (conacct_4);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind5 ON `1' (conacct_5);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind6 ON `1' (conacct_6);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind7 ON `1' (conacct_7);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind8 ON `1' (conacct_8);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind9 ON `1' (conacct_9);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind10 ON `1' (conacct_10);"), dsn("phil")
end




* odbc load, exec(" SELECT N.* FROM neighbor AS N JOIN (SELECT conacct FROM paws GROUP BY conacct) AS P ON N.conacct = P.conacct JOIN meter_dma_int AS D ON N.conacct = D.conacct") dsn("phil") clear
* local bill_query ""
* 	forvalues r = 1/12 {
* 		local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN (SELECT DISTINCT N.conacctn AS conacct FROM neighbor AS N JOIN (SELECT conacct FROM paws GROUP BY conacct) AS P ON N.conacct = P.conacct) AS B ON A.conacct=B.conacct"
* 		if `r'!=12{
* 			local bill_query "`bill_query' UNION ALL"
* 		}
* 	}
* 	odbc load, exec("`bill_query'")  dsn("phil") clear  
* 	duplicates drop conacct date, force
* save "${temp}npaws_bill_full_neighbors.dta", replace


odbc load, exec(" SELECT N.* FROM neighborp_50 AS N WHERE rank<=10 ") dsn("phil") clear
ren conacct conacctn
ren conacctp conacct

forvalues r=1/10 {
	g long conacct_`r'_id  = conacctn if rank==`r'
	g distance_`r'_id = distance if rank==`r'
	g rank_`r'_id = rank if rank==`r'
	gegen conacct_`r' 	= max(conacct_`r'_id), by(conacct)
	gegen distance_`r'  = max(distance_`r'_id), by(conacct)
	gegen rank_`r' 		= max(rank_`r'_id), by(conacct)
	drop conacct_`r'_id distance_`r'_id rank_`r'_id 
}
drop rank conacctn
gegen ctag=tag(conacct)
keep if ctag==1
drop ctag
drop distance

gentablenp npaws_10

save "${temp}npaws_10.dta", replace



local bill_query ""
forvalues r = 1/12 {
	local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM npaws_10) AS B ON A.conacct=B.conacct"
	if `r'!=12{
		local bill_query "`bill_query' UNION ALL"
	}
}
odbc load, exec("`bill_query'")  dsn("phil") clear  
duplicates drop conacct date, force
save "${temp}npaws_bill.dta", replace



*** THERE IS A MUCH FASTER WAY TO DO THIS! ***

local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM neighborp_50 WHERE rank<=10) AS B ON A.conacct=B.conacct"
		if `r'!=12{
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  
	duplicates drop conacct date, force
save "${temp}npaws_bill_full_neighbors.dta", replace




use  "${temp}npaws_bill.dta", clear
	merge m:1 conacct using "${temp}npaws_10.dta", keep(3) nogen 
	merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
		ren distance p1d_original
		ren year_inst p1yr_original
		ren pipe_id p1id_original
		ren date_capex d1cap_original
	merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
		ren distance p2d_original
		ren year_inst p2yr_original
		ren pipe_id p2id_original
		ren date_capex d2cap_original
	merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
		ren distance p3d_original
		ren year_inst p3yr_original
		ren pipe_id p3id_original
		ren date_capex d3cap_original
	ren conacct conacct_original
	ren c c_original
	ren class class_original

		forvalues r=1/10 {
			ren conacct_`r' conacct
				merge m:1 conacct date using "${temp}npaws_bill_full_neighbors.dta", keep(1 3) nogen 
					merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
						ren distance p1d_`r'
						ren year_inst p1yr_`r'
						ren pipe_id p1id_`r'
						ren date_capex d1cap_`r'
					merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
						ren distance p2d_`r'
						ren year_inst p2yr_`r'
						ren pipe_id p2id_`r'
						ren date_capex d2cap_`r'
					merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
						ren distance p3d_`r'
						ren year_inst p3yr_`r'
						ren pipe_id p3id_`r'
						ren date_capex d3cap_`r'
			ren conacct conacct_`r'
			ren c c_`r'
			ren class class_`r'
		}

save "${temp}npaws_bill_full.dta", replace





*** GO ALL IN ON PAWS!!!! ***


use "${data}paws/clean/full_sample_b_1.dta", clear

destring may_exp_extra, replace force
ren may_exp_extra me

g yes_flow = flow_noon_6=="Malakas"
g no_flow=flow_noon_6=="Wala"
destring flow_hrs, replace force
replace flow_hrs = . if flow_hrs==0

g yr=substr(interview_completion_date,1,4)
g mn=substr(interview_completion_date,6,2)
destring yr mn, replace force
g date=ym(yr,mn)
drop yr mn

destring hhsize, replace force
replace hhsize=. if hhsize>12

g B = booster=="Oo"
g S = storage!=""
keep date conacct hhsize no_flow yes_flow flow_hrs barangay B S wave

duplicates drop conacct date, force

save "${temp}paws_aib.dta", replace




use "${temp}npaws_bill_full.dta", clear
ren *_original *

foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
	merge m:1 conacct using "${temp}conacct_dma_link.dta", keep(1 3) nogen
	merge m:1 dma date using "${temp}nrw.dta", keep(1 3) nogen

g nrw = 1 - bill/supp
replace nrw=0 if nrw<0



*** UP VS DOWN RANK
forvalues r=1/10 {
g up`r' = p1d_`r'<p1d
g down`r' = p1d_`r'>p1d
}

local js 1
* local js 4
g c_up = c_`js' if up`js'==1
g c_down = c_`js' if down`js'==1
forvalues r=`=`js'+1'/10 {
replace c_up=c_`r' if up`r'==1 & c_up==. & c_`r'!=.
replace c_down=c_`r' if down`r'==1 & c_down==. & c_`r'!=.
}

gegen BM=max(B), by(conacct)
gegen NF=max(no_flow), by(conacct)
gegen NF1 = mean(no_flow), by(barangay date)

sort conacct date
foreach var of varlist no_flow yes_flow B S flow_hrs barangay wave {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/3 {
		by conacct: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by conacct: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
	replace `var'1=. if date>625
}

g nrw_B1=nrw*B1
g nrw_BM=nrw*BM


areg c nrw 			 i.date, a(conacct) cluster(conacct) r
areg c nrw nrw_BM BM i.date, a(conacct) cluster(conacct) r


g c_d= c_down-c_up
g B1_no_flow1 = B1*no_flow1
g B1_flow_hrs1 = B1*flow_hrs1

gegen yes_flow1m=mean(yes_flow1), by(barangay_id1 wave1)

areg c_d B1 i.date , a(conacct) cluster(conacct) r

areg c_d B1 yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_d B1 yes_flow1 i.date , a(conacct) cluster(conacct) r
areg c_d B1 no_flow1 i.date , a(conacct) cluster(conacct) r
areg c_d B1 yes_flow1 no_flow1 i.date , a(conacct) cluster(conacct) r











odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
	destring mru, replace force
	gegen marea=max(area), by(mru)
	keep if marea==area
	duplicates drop mru, force
	g str10 dma = dma_id
		drop dma_id
	keep dma mru
save "${temp}mru_dma_link.dta", replace







* do proper event study...


use "${temp}conacct_rate.dta", clear

keep datec mru

g o=1
gegen new=sum(o), by(mru datec)
keep if datec>550
drop o
duplicates drop mru datec, force
tsset mru datec
tsfill, full
replace new=0 if new==.
replace new=. if new>10

merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=mean(new), by(mru year)
gegen yt=tag(mru year)

areg cy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical





use "${data}paws/clean/full_sample_b_1.dta", clear

destring may_exp_extra, replace force
ren may_exp_extra me
replace me=. if me>5000

g no_flow=flow_noon_6=="Wala"
g yes_flow = flow_noon_6=="Malakas"
destring flow_hrs, replace force
replace flow_hrs = . if flow_hrs==0

g nf1 = flow_6_noon=="Wala"
g nf2 = flow_noon_6=="Wala"
g nf3 = flow_6_mid=="Wala"
g nf4 = flow_mid_6=="Wala"

egen nft=rowtotal(nf1-nf4)

g yr=substr(interview_completion_date,1,4)
g mn=substr(interview_completion_date,6,2)
destring yr mn, replace force
g date=ym(yr,mn)
* drop yr mn

g SHH = shr_num_extra
destring SHH, replace force
destring hhsize, replace force

g hho= SHH - hhsize
replace hhsize = . if hhsize>12
replace hho = . if hho<0 | hho>14
g hs = hho>0 & hho<.

g sub=regexm(house,"Subdivided")==1
g single=regexm(house,"Single house")==1

gegen mf = mean(no_flow), by(barangay_id wave)
gegen mff = mean(nft), by(barangay_id wave)

destring wrs_exp_extra, replace force
drop wrs_exp
ren wrs_exp_extra wrs

gegen BM=max(B), by(conacct)

g well = regexm(alt_src,"Pribado")

g balde= storage=="Balde"
g drum= storage=="Drum"
g gallon= storage=="Galon"

g S = storage!=""
g B = booster=="Oo"


sum B if no_flow==1
sum B if no_flow==0

foreach var of varlist S balde drum gallon {
	sum `var' if no_flow==1
	sum `var' if no_flow==0
}

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g post = yr>year_inst


g B_post=B*post
g BM_post=BM*post


areg hhsize post i.wave, a(mru) cluster(mru) r

areg hs post i.wave, a(mru) cluster(mru) r
*** ARE THESE NEW PEOPLE CONNECTED OR REARRANGED CONNECTIONS?! LOOK AT TOTAL


areg me post i.wave, a(mru) cluster(mru) r
areg me post i.wave, a(conacct) cluster(mru) r


areg B post i.wave, a(mru) cluster(mru) r
areg me post BM_post BM i.wave, a(mru) cluster(mru) r

gegen YF = mean(yes_flow), by(wave barangay)
g B_YF= B*YF

* areg flow_hrs B if wave==3, a(mru) cluster(mru) r

areg me B YF i.wave, a(barangay_id) cluster(barangay_id) r


areg me B YF i.wave, a(conacct) cluster(conacct) r
areg me B yes_flow i.wave, a(conacct) cluster(conacct) r

areg me B i.wave, a(barangay) cluster(barangay) r


areg me YF i.wave, a(barangay_id) cluster(barangay_id) r

areg me YF B B_YF i.wave, a(barangay_id) cluster(barangay_id) r



 
* areg no_flow nrw i.date,  a(conacct) cluster(conacct) r
* areg yes_flow nrw i.date,  a(conacct) cluster(conacct) r
* areg flow_hrs nrw i.date,  a(conacct) cluster(conacct) r


areg B no_flow  i.wave, a(barangay_id) cluster(barangay_id)

areg drum no_flow  i.wave, a(barangay_id) cluster(barangay_id)




areg hho no_flow  i.wave, a(barangay_id) cluster(barangay_id)

areg hho mf  i.wave, a(barangay_id) cluster(barangay_id)


areg no_flow hho hhsize sub single i.wave, a(barangay_id) cluster(barangay_id)




areg B hho hhsize sub single, a(barangay_id) cluster(barangay_id)



areg B mf i.wave, a(barangay_id) cluster(barangay_id)
areg hho mf i.wave, a(barangay_id) cluster(barangay_id)


areg me mf i.wave, a(barangay_id) cluster(barangay_id)

areg me mff i.wave, a(barangay_id) cluster(barangay_id)

areg balde   mf i.wave, a(barangay_id) cluster(barangay_id)
areg drum    mf i.wave, a(barangay_id) cluster(barangay_id)
areg gallon  mf i.wave, a(barangay_id) cluster(barangay_id)

areg balde   mff i.wave, a(barangay_id) cluster(barangay_id)
areg drum    mff i.wave, a(barangay_id) cluster(barangay_id)
areg gallon  mff i.wave, a(barangay_id) cluster(barangay_id)



areg hho balde drum gallon i.wave if ,  a(barangay_id) cluster(barangay_id)



areg hho mf i.wave, a(barangay_id) cluster(barangay_id)



areg hho mff i.wave, a(barangay_id) cluster(barangay_id)

areg wrs mf i.wave, a(barangay_id) cluster(barangay_id)



areg hho mf sub single i.wave, a(barangay_id) cluster(barangay_id)

areg hhsize mf sub single i.wave, a(barangay_id) cluster(barangay_id)

areg hho mf sub single  i.wave, a(barangay_id) cluster(barangay_id)



merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop ba zone_code dc-datec
merge m:1 mru using "${temp}mru_dma_link",  keep(1 3) nogen
merge m:1 dma date using "${temp}nrw.dta", keep(1 3) nogen 

g nrw= 1 - (bill/supp)
replace nrw=0 if nrw<0
g high_nrw=0 if nrw!=.
replace high_nrw=1 if nrw>.5 & nrw<=1

areg no_flow  nrw i.date,  a(dma) cluster(dma) r
areg yes_flow nrw i.date,  a(dma) cluster(dma) r
areg flow_hrs nrw i.date,  a(dma) cluster(dma) r

areg B nrw i.date,  a(dma) cluster(dma) r
areg S nrw i.date,  a(dma) cluster(dma) r

areg no_flow  high_nrw i.date, a(dma) cluster(dma) r
areg yes_flow high_nrw i.date, a(dma) cluster(dma) r
areg flow_hrs high_nrw i.date, a(dma) cluster(dma) r

areg B high_nrw i.date,  a(dma) cluster(dma) r
areg S high_nrw i.date,  a(dma) cluster(dma) r







use "${temp}npaws_bill_full.dta", clear
ren *_original *
drop *_*

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

areg cy i.pT i.year if yt==1 , a(conacct) cluster(mru) r
	coefplot, keep(*pT*) vertical




local bill_query ""
forvalues r = 1/12 {
	local bill_query "`bill_query' 	SELECT A.c, A.conacct, A.date FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
	if `r'!=12 {
		local bill_query "`bill_query' UNION ALL"
	}
}
odbc load, exec("`bill_query'")  dsn("phil") clear  

duplicates drop conacct date, force
save "${temp}bill_paws_full.dta", replace




use "${temp}bill_paws_full.dta", clear

replace c=. if c>100

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)


cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

areg cy i.pT i.year if yt==1, a(conacct) 
	coefplot, keep(*pT*) vertical







* ***** TRIPLE CHECK PIPES ***** (pipes don't work, idk why, could be sample size; focus on pasay/tondo? Doesn't work either..)
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*
* replace c=. if c>100
* merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
* merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
* 	drop zone_code-datec

* g dated=dofm(date)
* g year=year(dated)

* forvalues r=1/3 {
* g pT`r' = year-p`r'yr
* replace pT`r'=1000 if pT`r'>6 | pT`r'<-6
* replace pT`r'=pT`r'+10
* }
* forvalues r=1/3 {
* g  T`r' = date-d`r'cap
* replace T`r'=1000 if T`r'<-24 | T`r'>24
* replace T`r'=T`r'+100
* }

* *** NOTHING HERE TOO! ***
* areg no_flow i.pT3 i.year , a(barangay) 
* 	coefplot, keep(*pT3*) vertical
* areg no_flow i.pT2 i.year , a(barangay) 
* 	coefplot, keep(*pT2*) vertical
* areg no_flow i.pT1 i.year , a(barangay) 
* 	coefplot, keep(*pT1*) vertical

* gegen cy=mean(c), by(conacct year)
* gegen yt=tag(conacct year)

* areg cy i.pT3 i.year if yt==1 & ba>=500 & ba<=700, a(conacct) 
* 	coefplot, keep(*pT3*) vertical
* areg cy i.pT2 i.year if yt==1 & p2d<100  & ba>=500 & ba<=700, a(conacct) 
* 	coefplot, keep(*pT2*) vertical
* areg cy i.pT1 i.year if yt==1 & p1d<200  & ba>=500 & ba<=700, a(conacct) 
* 	coefplot, keep(*pT1*) vertical

* areg cy i.pT3 i.year if yt==1, a(conacct) 
* 	coefplot, keep(*pT3*) vertical
* areg cy i.pT2 i.year if yt==1 & p2d<100, a(conacct) 
* 	coefplot, keep(*pT2*) vertical
* areg cy i.pT1 i.year if yt==1 & p1d<200, a(conacct) 
* 	coefplot, keep(*pT1*) vertical
* *** WORKS BUT ITS ALL TOO LATE! ***
* areg c i.T3 i.date, a(conacct)
* 	coefplot, vertical keep(*T3*)
* areg c i.T2 i.date, a(conacct)
* 	coefplot, vertical keep(*T2*)
* areg c i.T1 i.date, a(conacct)
* 	coefplot, vertical keep(*T1*)




* *** TRIPLE CHECK NRW ***
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*
* replace c=. if c>100
* 	merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
* 	merge m:1 conacct using "${temp}conacct_dma_link.dta", keep(1 3) nogen
* 	merge m:1 dma date using "${temp}nrw.dta", keep(1 3) nogen

* g nrw = 1 - bill/supp
* replace nrw=0 if nrw<0

* tab no_flow
* tab no_flow if bill!=.
* *** only 2% covered with no flow...
* tab yes_flow
* tab yes_flow if bill!=.
* sum flow_hrs
* sum flow_hrs if bill!=.

* areg yes_flow nrw i.date, a(dma) cluster(dma)
* areg B nrw i.date, a(dma) cluster(dma)




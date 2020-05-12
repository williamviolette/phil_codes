* pressure.do




*** NOW! measure externalities .. HOW MANY?!?  enough....

* 1. narrow to low-flow MRUs  (high meter merge: eh; this happens naturally..)
* 
* 


global load_data=0

if $load_data == 1 {



use "${temp}capex_raw.dta", clear

keep var8 var39
keep if var8!=""
replace var8=regexs(1) if regexm(var8,"^(.+)/")
replace var8=regexs(1) if regexm(var8,"^(.+)/")
replace var8=strtrim(var8)
g yr = "20"+substr(var39,1,2)
destring yr, replace force
g mn = substr(var39,4,3)

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
duplicates drop contract_n, force
ren date date_capex
save "${temp}capex_date.dta", replace


*** HERE IS THE PAWS EXERCISE! * IT WORKS!!! ***
odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, I.contract_n FROM pipe_primary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.org_fid")  dsn("phil") clear  




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



* sort conacct date
* by conacct: g c_ch = c - c[_n-1]
* by conacct: g ps_ch  = ps - ps[_n-1]
* by conacct: g pm_ch = pmean - pmean[_n-1]



*** PMP DOESNT WORK! ***
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*
* merge m:1 conacct using  "${temp}pmp_distance_link.dta", keep(1 3) nogen
* merge m:1 pmp date using "${temp}pmp_total.dta", keep(1 3) nogen
* ren distance dpmp
* keep if c<100
* egen psg=cut(ps), at(0(1)24)
* tab psg
* reg c ps pmean if dpmp<800
* reg c ps i.date if dpmp<800
* areg c ps i.date  if dpmp<200, absorb(conacct)
* areg c ps i.date idf, absorb(conacct)
* reg c ps pmean



*** PIPES ARE NOT GREAT EITHER UNFORTUNATELY ***
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*

* g dated=dofm(date)
* g year=year(dated)

* g post3 = year>=p3yr & year<.
* g post2 = year>=p2yr & year<.
* g post1 = year>=p1yr & year<.

* forvalues r=1/3 {
* g pT`r' = year-p`r'yr
* replace pT`r'=. if pT`r'>6 | pT`r'<-6
* replace pT`r'=pT`r'+10
* }

* g month = 1
* g date_3 = ym(p3yr,month)
* * g T3 = date-date_3
* cap drop T3
* g T3 = date-d2cap
* replace T3=1000 if T3<-36 | T3>36
* * replace T3=. if  T3<-36 | T3>36
* replace T3 = T3+100
* areg c i.T3 i.date, a(conacct)
* 	coefplot, vertical keep(*T3*)
* areg c i.pT3 i.date, a(conacct)
* coefplot, vertical drop(_cons)
* areg c post1 post2 post3 i.date, a(conacct)
* replace c = . if c>100
* gegen p2d_mean1=mean(p2d), by(p3id)
* g p2dev=p2d-p2d_mean1
* replace p2dev=. if p2dev<-200 | p2dev>200
* g p2dev_post = p2dev*post
* areg c post i.date, a(conacct)
* areg c p2dev post p2dev_post i.date, a(p3id)




*** GO ALL IN ON PAWS!!!! ***


use "${data}paws/clean/full_sample_with_edu_1.dta", clear

destring may_exp_extra, replace force
ren may_exp_extra me

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

keep date conacct hhsize no_flow flow_hrs barangay
duplicates drop conacct date, force

save "${temp}paws_ai.dta", replace




use "${temp}npaws_bill_full.dta", clear
ren *_original *

	merge 1:1 conacct date using  "${temp}paws_ai.dta", keep(1 3) nogen


reg flow_hrs p2d
reg no_flow p2d


areg flow_hrs p2d i.date if p2d<=400, a(barangay_id)
areg no_flow p2d i.date if p2d<=400, a(barangay_id)


areg flow_hrs p1d i.date , a(barangay_id)
areg no_flow p1d i.date , a(barangay_id)

     
* sort conacct date
* foreach var of varlist hhsize no_flow flow_hrs {
* 	by conacct: replace `var' = `var'[_n+1] if `var'==. & `var'[_n+1]
* 	by conacct: replace `var' = `var'[_n-1] if `var'==. & `var'[_n-1]
* }








use "${temp}npaws_bill_full.dta", clear
ren *_original *

	merge 1:1 conacct date using  "${temp}paws_ai.dta", keep(3) nogen

replace c= . if c>100
replace c_1=. if c_1>100
replace c_2=. if c_2>100
replace c_3=. if c_3>100


sort conacct date
by conacct: g hh_ch=hhsize[_n]-hhsize[_n-1]
by conacct: g c_ch=c[_n]-c[_n-1]
by conacct: g c_1_ch=c_1[_n]-c_1[_n-1]
by conacct: g c_2_ch=c_2[_n]-c_2[_n-1]
by conacct: g c_3_ch=c_3[_n]-c_3[_n-1]


g up_2   = p1id==p1id_2 & p2d>p2d_2
g down_2 = p1id==p1id_2 & p2d<p2d_2

g up_3   = p1id==p1id_3 & p2d>p2d_3
g down_3 = p1id==p1id_3 & p2d<p2d_3

reg c_ch hh_ch, cluster(conacct)

reg c_2_ch hh_ch if up_2==1 & flow_hrs<=18, cluster(conacct)

reg c_2_ch hh_ch if down_2==1 & flow_hrs<=18, cluster(conacct)

reg c_3_ch hh_ch if up_3==1 & flow_hrs<=18, cluster(conacct)

reg c_3_ch hh_ch if down_3==1  & flow_hrs<=18, cluster(conacct)





use "${temp}npaws_bill_full.dta", clear
ren *_original *

drop *_*

	merge m:1 conacct using "${temp}conacct_dma_link.dta"
		drop if _merge==2
		drop _merge
	merge m:1 dma date using "${temp}nrw.dta"
		drop if _merge==2
		drop _merge

g nrw = 1 - (bill/supp)
replace nrw = 0 if nrw<0

g dated=dofm(date)
g year=year(dated)
g month=month(dated)

keep if c<=100
* reg nrw i.month  some monthly variation

g high_loss = nrw>.75 & nrw<=1



reg c nrw

reg c high_loss

* robust to date
reg c high_loss i.date 

*** within DMA variation reduces the correlation substantially (by a factor of 4...)
*** small users are in places with lots of NRW (which makes sense...)
areg c high_loss i.date, a(dma) cluster(dma) r


** correlation with pipe
reg c p2d
* drops by half
areg c p2d, a(dma)
* still robust to same nearest pipe
areg c p2d, a(p1id)
* unaffected by date
areg c p2d i.date, a(p1id)


* key 
g high_loss_p2d= high_loss*p2d

*** yes, this is the correlation of interest: gradient is amplified by high NRW
areg c  high_loss p2d high_loss_p2d i.date, a(conacct) cluster(conacct)

areg c  high_loss p2d high_loss_p2d i.date, a(dma) cluster(conacct)



* key 
g nrw_p2d=nrw*p2d

*** yes, this is the correlation of interest: gradient is amplified by high NRW
areg c nrw p2d nrw_p2d i.date, a(conacct) cluster(conacct)

areg c nrw p2d nrw_p2d i.date, a(dma) cluster(conacct)





use "${temp}npaws_bill_full.dta", clear
ren *_original *

	merge m:1 conacct using "${temp}conacct_dma_link.dta"
		drop if _merge==2
		drop _merge
	merge m:1 dma date using "${temp}nrw.dta"
		drop if _merge==2
		drop _merge

foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

g nrw = 1 - (bill/supp)
replace nrw = 0 if nrw<0

g dated=dofm(date)
g year=year(dated)
g month=month(dated)

g high_loss = nrw>.5 & nrw<=1
g high_dist = p2d>100 & p2d<=1

g c_1_high_loss = c_1*high_loss
g c_1_high_dist = c_1*high_dist

g c_2_high_loss = c_2*high_loss
g c_2_high_dist = c_2*high_dist

g c_3_high_loss = c_3*high_loss
g c_3_high_dist = c_3*high_dist


forvalues r=1/10 {
	g c_up_`r' = c_`r' if p2d_`r'<p2d & p1id==p1id_`r'
	replace c_up_`r' = 0 if c_up_`r'==.
	g c_dn_`r' = c_`r' if p2d_`r'>p2d  & p1id==p1id_`r'
	replace c_dn_`r' = 0 if c_dn_`r'==.
}

egen c_ups = rowtotal(c_up*)
egen c_dns = rowtotal(c_dn*)

g c_ups_high_loss = c_ups*high_loss
g c_dns_high_loss = c_dns*high_loss

sum c_ups
sum c_dns


areg c c_ups c_dns c_ups_high_loss c_dns_high_loss high_loss i.date, a(conacct) r cluster(conacct)


areg c high_loss c_1 c_1_high_loss c_2 c_2_high_loss c_3 c_3_high_loss i.date, a(conacct) r


areg c high_loss c_1 c_1_high_loss c_2 c_2_high_loss c_3 c_3_high_loss i.date, a(conacct) r cluster(conacct)





use "${temp}npaws_bill_full.dta", clear
ren *_original *

drop *_*

	merge m:1 conacct using "${temp}conacct_dma_link.dta"
		drop if _merge==2
		drop _merge
	merge m:1 dma date using "${temp}nrw.dta"
		drop if _merge==2
		drop _merge
	* merge m:1 conacct using "${temp}dist_tertiary_conacct.dta"
	* 	keep if _merge==3
	* 	drop _merge
	* merge m:1 conacct using "${temp}conacct_rate.dta"
	* 	keep if _merge==3
	* 	drop _merge
	* drop dc rateclass_key bus_id bus zone_code

replace c = . if c>100

g dated=dofm(date)
g year=year(dated)
g post = year>=year_inst & year<.

g pd1= pd if pd<=1000
g pd1_post = pd1*post

egen fg= cut(pd), at(0(50)600)

g far = pd>=200 & pd<.
g far_post = far*post

g nrw = 1 - (bill/supp)
replace nrw = 0 if nrw<0

egen ng=cut(nrw), at(0(.1)1)
replace ng=ng*10

g n20 = 0 if nrw<.2
replace n20 = 1 if nrw>=.2 & nrw<.


areg c post far_post far i.date, r a(dma)



areg c post far_post i.date, a(conacct) r






reg c i.fg 
coefplot, vertical drop(_cons)

areg c i.fg if nrw<.25, a(mru)
coefplot, vertical drop(_cons)

areg c i.fg if nrw>.25 & nrw<., a(mru)
coefplot, vertical drop(_cons)



reg c i.fg if post==1
coefplot, vertical drop(_cons)

reg c i.fg if nrw<.3 
coefplot, vertical drop(_cons)



areg c post far_post i.date, a(conacct) r



g ln_c = log(c) 
areg ln_c post far_post i.date, a(conacct) r





g d_n20 = n20*pd

g n20_far = n20*far


* reg c pd

areg c n20 d_n20 i.date, a(conacct) cluster(dma) r


areg c n20 n20_far i.date, a(conacct) cluster(dma) r



areg c i.ng i.date, a(conacct) cluster(dma) r





use "${data}paws/clean/full_sample_with_edu_1.dta", clear

destring may_exp_extra, replace force
ren may_exp_extra me

g no_flow=flow_noon_6=="Wala"
destring flow_hrs, replace force
replace flow_hrs = . if flow_hrs==0

g yr=substr(interview_completion_date,1,4)
g mn=substr(interview_completion_date,6,2)
destring yr mn, replace force
g date=ym(yr,mn)
drop yr mn

merge m:1 conacct using "${temp}conacct_dma_link.dta"
	drop if _merge==2
	drop _merge

merge m:1 dma date using "${temp}nrw.dta"
	drop if _merge==2
	drop _merge

merge m:1 conacct using "${temp}dist_primary_points_conacct.dta"
	keep if _merge==3
	drop _merge
	ren distance d1p

merge m:1 conacct using "${temp}dist_primary_conacct.dta"
	keep if _merge==3
	drop _merge
	ren distance d1

merge m:1 conacct using "${temp}dist_secondary_conacct.dta"
	keep if _merge==3
	drop _merge
	ren distance d2

merge m:1 conacct using "${temp}dist_tertiary_conacct.dta"
	keep if _merge==3
	drop _merge
	ren distance d3

merge m:1 conacct using "${temp}dist_valves_conacct.dta"
	keep if _merge==3
	drop _merge
	ren distance dv


g nrw = 1 - bill/supp



reg flow_hrs nrw i.date, r cluster(dma)
reg no_flow nrw i.date, r cluster(dma)

areg flow_hrs nrw i.date, a(barangay) cluster(barangay) r
areg no_flow nrw i.date, a(barangay) cluster(barangay) r



replace d1p=. if d1p>1000
replace d1=. if d1>1000
replace d2=. if d2>500
replace d3=. if d3>500
replace dv=. if dv>500

destring shr_num_extra, replace force
ren shr_num_extra SHH
destring hhsize, replace

replace SHH=SHH-hhsize

reg me d1 d2 d3 dv

reg flow_hrs d1 d2 d3 dv
reg no_flow d1 d2 d3 dv

g sub=regexm(house,"Subdivided")==1
g single=regexm(house,"Single house")==1

xi: areg d1p sub single i.class i.wave , a(barangay) robust



areg SHH d1p i.wave if SHH<=12, a(barangay) robust
areg hhsize d1p i.wave if hhsize<=12, a(barangay) robust


areg me d1p i.wave, a(barangay) robust
areg flow_hrs d1p i.wave, a(barangay) robust
areg no_flow d1p i.wave, a(barangay) robust

areg me d1p sub single i.wave, a(barangay) robust
areg flow_hrs d1p  sub single i.wave, a(barangay) robust
areg no_flow d1p sub single i.wave, a(barangay) robust





areg flow_hrs d1p i.wave, a(barangay) robust cluster(barangay)
areg no_flow  d1p i.wave, a(barangay) robust cluster(barangay)



areg flow_hrs d1 i.wave if mfh<=22, a(barangay) robust

areg no_flow dv i.wave if mfh<=22, a(barangay) robust


areg me d2 d3 dv i.wave if mfh<=22, a(barangay) robust






* use "${data}paws/clean/full_sample_2.dta", clear


use "${data}paws/clean/full_sample_b_1.dta", clear



destring may_exp_extra, replace force
ren may_exp_extra me

g no_flow=flow_noon_6=="Wala"
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
drop yr mn


g SHH = shr_num_extra
destring SHH, replace force
destring hhsize, replace force

g hho= SHH - hhsize
replace hhsize = . if hhsize>12
replace hho = . if hho<0 | hho>14

g sub=regexm(house,"Subdivided")==1
g single=regexm(house,"Single house")==1

gegen mf = mean(no_flow), by(barangay_id wave)
gegen mff = mean(nft), by(barangay_id wave)

destring wrs_exp_extra, replace force
drop wrs_exp
ren wrs_exp_extra wrs


g well = regexm(alt_src,"Pribado")

reg wrs well


g balde= storage=="Balde"
g drum= storage=="Drum"
g gallon= storage=="Galon"

g B = booster=="Oo"


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








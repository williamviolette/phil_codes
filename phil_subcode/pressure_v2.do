* pressure.do




*** NOW! measure externalities .. HOW MANY?!?  enough....

* 1. narrow to low-flow MRUs  (high meter merge: eh; this happens naturally..)
* 
* 


global load_data=0

if $load_data == 1 {

		use ${database}clean/mcf/2015/full_2015.dta, clear
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

		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
		ren Col12 conacct
		g bg=regexs(1) if regexm(Col11,".+BG([0-9]+)$")
		destring bg, replace force

		gegen fn = group(Col16)
		gegen ln = group(Col17)
				duplicates drop conacct, force
				keep fn ln conacct
		save "${temp}name_g.dta", replace



	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.c, A.conacct, A.date, A.class FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}bill_paws_full.dta", replace



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
		

	odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
		destring mru, replace force
		gegen marea=max(area), by(mru)
		keep if marea==area
		duplicates drop mru, force
		g str10 dma = dma_id
			drop dma_id
		keep dma mru
	save "${temp}mru_dma_link.dta", replace


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
		tsset conacct date
		tsfill, full
		gegen class1=max(class), by(conacct)
		drop class
		ren class1 class
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

		g balde= storage=="Balde"
		g drum= storage=="Drum"
		g gallon= storage=="Galon"

		destring hhsize, replace force
		replace hhsize=. if hhsize>12

		g B = booster=="Oo"
		g S = storage!=""
		keep date conacct hhsize no_flow yes_flow flow_hrs barangay B S wave balde drum gallon

		duplicates drop conacct date, force

		save "${temp}paws_aib.dta", replace


}





*** DO THOSE WITH BOOSTER PUMPS REPORT BETTER FLOW?
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*
* sort conacct date
* merge m:1 conacct date using "${temp}paws_aib.dta", keep(3) nogen
* areg B no_flow, a(p3id) cluster(p3id) r
* areg B flow_hrs, a(p3id) cluster(p3id) r




use "${temp}npaws_bill_full.dta", clear

ren *_original *

sort conacct date
by conacct: g tcd=c[_n-3]!=. & c[_n-2]!=. & c[_n-1]!=. & c==. & c[_n+1]==. & c[_n+2]==. & c[_n+3]==.
replace tcd = . if date==592 | date==653 | date==664


foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen


forvalues r=1/10 {
g up`r' = p1d_`r'<p1d
g down`r' = p1d_`r'>p1d
}



local d1set "5 10 15"
local js 1
g c_up = c_`js' if up`js'==1
g c_down = c_`js' if down`js'==1
foreach d1 in `d1set' {
g c_upd`d1' = c_`js' if up`js'==1 & distance_`js'>`d1'
g c_downd`d1' = c_`js' if down`js'==1 & distance_`js'>`d1'
}
forvalues r=`=`js'+1'/10 {
replace c_up=c_`r' if up`r'==1 & c_up==. & c_`r'!=.
replace c_down=c_`r' if down`r'==1 & c_down==. & c_`r'!=.
foreach d1 in `d1set' {
replace c_upd`d1'   = c_`r' if up`r'==1   & c_upd`d1'==. & c_`r'!=. &  distance_`r'>`d1'
replace c_downd`d1' = c_`r' if down`r'==1 & c_downd`d1'==. & c_`r'!=. & distance_`r'>`d1'
}
}



gegen BM=max(B), by(conacct)
gegen BMI=min(B), by(conacct)
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

g c_d= c_down-c_up

gegen yes_flow1m=mean(yes_flow1), by(barangay_id1 wave1)
gegen no_flow1m=mean(no_flow1), by(barangay_id1 wave1)

g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)
gegen cdy=mean(c_d), by(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

g far = p1d>200
g post = year>year_inst
g post_far = post*far
g post_BM = post*BM


g up_tot = 0
g down_tot = 0
forvalues r=1/10 {
	replace up_tot=up_tot+up`r'*c_`r' if c_`r'!=.
	replace down_tot=down_tot+down`r'*c_`r' if c_`r'!=.
}


g bw1_id=B if wave==3
gegen bw1=max(bw1_id), by(conacct)

g bw1_post = post*bw1


gegen p1d_rd = mean(p1d), by(p3id)
g rd=p1d-p1d_rd
g rdf=rd>0 & rd<.

g post_rd = post*rd

g post_rdf=post*rdf

areg c post post_rdf i.date , a(conacct) cluster(conacct) r



areg c post bw1_post i.date if p1d>200, a(conacct) cluster(conacct) r



g B1_post = B1*post

g B1_yes_flow1m = B1*yes_flow1m


g p1d_post=p1d*post


areg B p1d i.wave if post==0, a(barangay_id) cluster(barangay_id) r

g ln_c = log(c)

reg  c post p1d_post p1d i.date

areg c post p1d_post  i.date, a(conacct) 


areg ln_c post p1d_post  i.date, a(conacct) 

areg B post p1d_post  i.date, a(conacct) 


g B1_post = B1*post
g B1_p1d_post = B1*p1d_post

areg c B1 post p1d_post  i.date, a(conacct) 

areg c B1 post B1_post p1d_post B1_p1d_post  i.date, a(conacct) 


areg c_down B1  i.date , a(conacct) cluster(conacct) r
areg c_up B1    i.date , a(conacct) cluster(conacct) r


areg c_down B1 post B1_post i.date , a(conacct) cluster(conacct) r
areg c_up B1 post B1_post   i.date , a(conacct) cluster(conacct) r


areg c_down B1 c_up i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down i.date , a(conacct) cluster(conacct) r


areg c_downd5  B1 i.date , a(conacct) cluster(conacct) r
areg c_downd10 B1 i.date , a(conacct) cluster(conacct) r
areg c_downd15 B1 i.date , a(conacct) cluster(conacct) r

areg c_upd5  B1 i.date , a(conacct) cluster(conacct) r
areg c_upd10 B1 i.date , a(conacct) cluster(conacct) r
areg c_upd15 B1 i.date , a(conacct) cluster(conacct) r



areg c_down B1 c_up c i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c i.date , a(conacct) cluster(conacct) r

areg c_down B1 c_up c i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c i.date , a(conacct) cluster(conacct) r

areg c_downd5  B1 c_up c  i.date , a(conacct) cluster(conacct) r
areg c_downd10 B1 c_up c  i.date , a(conacct) cluster(conacct) r
areg c_downd15 B1 c_up c  i.date , a(conacct) cluster(conacct) r


areg c_downd5  B1 c_down c_up c  i.date , a(conacct) cluster(conacct) r
areg c_downd10 B1 c_down c_downd5 c_up c  i.date , a(conacct) cluster(conacct) r
areg c_downd15 B1 c_down c_downd5 c_downd10 c_up c  i.date , a(conacct) cluster(conacct) r


areg c_downd5 B1 c_upd5 c  i.date , a(conacct) cluster(conacct) r
areg c_upd5 B1 c_downd5 c  i.date , a(conacct) cluster(conacct) r

areg c_downd10 B1 c_upd10 c  i.date , a(conacct) cluster(conacct) r
areg c_upd10 B1 c_downd10 c  i.date , a(conacct) cluster(conacct) r

areg c_downd15 B1 c_upd15 c  i.date , a(conacct) cluster(conacct) r
areg c_upd15 B1 c_downd15 c  i.date , a(conacct) cluster(conacct) r


areg c_down B1 c_up c no_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c no_flow1m i.date , a(conacct) cluster(conacct) r




areg c_down B1 B1_post post c_up c  i.date , a(conacct) cluster(conacct) r
areg c_up B1 B1_post post c_down c  i.date , a(conacct) cluster(conacct) r

 
* areg c_down B1 B1_yes_flow1m yes_flow1m c_up c  i.date , a(conacct) cluster(conacct) r
* areg c_up B1  B1_yes_flow1m yes_flow1m  c_down c  i.date , a(conacct) cluster(conacct) r

 


areg cy post post_far i.year if yt==1, a(conacct) cluster(mru) r
areg cdy post i.year if yt==1, a(conacct) cluster(mru) r
areg cdy post post_BM i.year if yt==1 , a(conacct) cluster(mru) r

areg c_d B1 yes_flow1m i.pT i.date , a(conacct) cluster(conacct) r


areg c_down B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_downd5 B1 c_upd5 c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_upd5 B1 c_downd5 c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_downd10 B1 c_upd10 c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_upd10 B1 c_downd10 c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_downd15 B1 c_upd15 c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_upd15 B1 c_downd15 c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg down_tot B1 up_tot c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg up_tot B1 down_tot c yes_flow1m i.date , a(conacct) cluster(conacct) r

*** HOW FAR TO EXTERNALITIES EXTEND?! ** what if neighbors are ALSO getting rid of pumps at the same time?!


	areg c_down B1  yes_flow1m i.date , a(conacct) cluster(conacct) r
	areg c_up B1     yes_flow1m i.date , a(conacct) cluster(conacct) r





*** GET RID OF 


cap drop tcd_date_id
cap drop tcd_date
cap drop Tc
cap drop TcBM
cap drop TcNBM
g tcd_date_id = date if tcd==1
gegen tcd_date= min(tcd_date_id), by(conacct)
g Tc = date-tcd_date
replace Tc=1000 if Tc>6 | Tc<-6
replace Tc=Tc+10
g TcBM=Tc if BMI==1
replace TcBM=1000+10 if TcBM==.
g TcNBM=Tc if BMI==0
replace TcNBM=1000+10 if TcNBM==.


areg c_d i.TcBM i.TcNBM i.date , a(conacct) cluster(conacct) r
coefplot, vertical keep(*Tc*)

* areg c_up c_down i.TcBM i.TcNBM i.date , a(conacct) cluster(conacct) r
* coefplot, vertical keep(*Tc*)


*** not a majorly clear gradient... possibly because of investments in booster pumps?
* areg c p1d p2d, a(mru) cluster(mru) r *** (1st pipe) is more correlated!! 








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
destring hhemp, replace force

g sub_post = sub*post

areg B sub  sub_post single no_flow flow_hrs i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r

areg me sub  sub_post single no_flow flow_hrs i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r



areg B sub i.wave, a(barangay) cluster(barangay) r


reg  B post, r
reg  B post i.wave, r
areg B post i.wave, r a(mru)

areg B post i.wave, r a(conacct)


reg B post single sub i.hhsize i.hhemp i.hho i.wave, r


reg me post i.yr if yr>=2008, r
areg me post i.yr if yr>=2008, r a(mru) cluster(mru)

reg me post single sub i.hhsize i.hhemp i.hho i.yr if yr>=2008, r
areg me post single sub i.hhsize i.hhemp i.hho i.yr if yr>=2008, r a(mru) cluster(mru)


reg B post i.yr if yr>=2008, r
areg B post i.yr if yr>=2008, r a(mru)




g B_post=B*post
* g BM_post=BM*post

gegen no_flowm = mean(no_flow), by(barangay wave)
g no_flowm_B = B*no_flowm

areg me no_flow B i.wave, a(barangay) cluster(barangay) r


areg me no_flow B i.wave, a(barangay) cluster(barangay) r

areg me no_flow B sub single i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r


areg me no_flowm B no_flowm_B i.wave, a(barangay) cluster(barangay) r

areg me no_flowm B no_flowm_B sub single i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r


**** TEST DEMAND FOR PRESSURE ****

g no_flow_hhsize=no_flow*hhsize
g yes_flow_hhsize=yes_flow*hhsize

reg me no_flow hhsize no_flow_hhsize B i.wave, r cluster(conacct) 



areg hhsize post i.wave, a(mru) cluster(mru) r

areg hs post i.wave, a(mru) cluster(mru) r


areg drum post i.wave, a(mru) cluster(mru) r
areg B post i.wave, a(mru) cluster(mru) r


areg me B post B_post  i.wave, a(mru) cluster(mru) r

areg me B post B_post  i.wave, a(mru) cluster(mru) r


areg me B post B_post  i.wave, a(conacct) cluster(conacct) r


areg me B post B_post  sub single i.hhsize i.hhemp i.hho  i.wave, a(mru) cluster(mru) r

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
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

areg cy i.pT i.year if yt==1 , a(conacct) cluster(mru) r
	coefplot, keep(*pT*) vertical




use "${temp}bill_paws_full.dta", clear

replace c=. if c>100

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen

gegen BM=max(B), by(conacct)
gegen DM=max(drum), by(conacct)

g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

g post = year>year_inst
g post_BM=BM*post
g post_DM=DM*post


sort conacct date
foreach var of varlist B {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/6 {
		by conacct: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by conacct: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
	replace `var'1=. if date>625
}


gegen class_max=max(class), by(conacct)
gegen class_min=min(class), by(conacct)

drop if class_max>=3

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g price_post = date>date_rs & date<.

g price_post_wind = 

cap drop T
g T = date-date_rs
replace T = 1000 if T<-36 | T>36
replace T = T+100

reg c i.T
coefplot, vertical keep(*T*)

areg c i.T i.date, a(conacct)
coefplot, vertical keep(*T*)



reg c price_post if T>=-24+100 & T<=24+100


g TM = T==1100
g T1 = T
replace T1 = 0 if T==1100

g price_post_post=price_post*post


reg c post price_post i.class_max i.class_min T1 TM, cluster(mru) r

reg c post price_post price_post_post i.class_max i.class_min T1 TM, cluster(mru) r

reg c post price_post price_post_post i.class_max i.class_min T1 TM,  r cluster(conacct)


reg B1 post price_post i.class_max i.class_min T1 TM, cluster(mru) r




g post_B1=post*B1


reg c post i.year if B1!=., cluster(mru) r

reg B1 post i.year if B1!=., cluster(mru) r





areg c post i.date if B1!=., a(conacct) cluster(mru) r




reg c post i.date if B!=., cluster(mru) r



areg cy B1 post post_B1 i.year if yt==1, a(conacct) cluster(mru) r


areg cy post i.year if yt==1, a(conacct) cluster(mru) r

areg cy post post_BM i.year if yt==1, a(conacct) cluster(mru) r


areg cy post post_BM post_DM i.year if yt==1, a(conacct) cluster(mru) r


areg cy post i.year if yt==1 & BM==0, a(conacct) cluster(mru) r
areg cy post i.year if yt==1 & BM==1, a(conacct) cluster(mru) r

areg cy i.pT i.year if yt==1, a(conacct) 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 & BM==0, a(conacct) 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 & BM==1, a(conacct) 
	coefplot, keep(*pT*) vertical






*** THIS DOES NEIGHBOR BOOSTER INTERACTION (BUT SAMPLE IS WAYYYY TOO SMALL!!!!)

use "${temp}paws_aib.dta", clear
	gegen BID = min(B), by(conacct)
	keep BID conacct
	duplicates drop conacct, force
save "${temp}BID.dta", replace


use "${temp}npaws_bill_full.dta", clear
forvalues r=1/10 {
	ren conacct_`r' conacct
	merge m:1 conacct using "${temp}BID.dta", keep(1 3) nogen
	ren conacct conacct_`r'
	ren BID BID_`r'
}

ren *_original *

foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

forvalues r=1/10 {
g up`r' = p1d_`r'<p1d
g down`r' = p1d_`r'>p1d
}

local js 1
g c_up = c_`js' if up`js'==1
g c_down = c_`js' if down`js'==1
g c_upB = c_`js' if up`js'==1 & BID_1==1
g c_downB = c_`js' if down`js'==1 & BID_1==1
g c_upN = c_`js' if up`js'==1 & BID_1==0
g c_downN = c_`js' if down`js'==1 & BID_1==0
forvalues r=`=`js'+1'/10 {
replace c_up=c_`r' if up`r'==1 & c_up==. & c_`r'!=.
replace c_down=c_`r' if down`r'==1 & c_down==. & c_`r'!=.
replace c_upB=c_`r' if up`r'==1 & c_up==. & c_`r'!=. & BID_`r'==1
replace c_downB=c_`r' if down`r'==1 & c_down==. & c_`r'!=. & BID_`r'==1
replace c_upN=c_`r' if up`r'==1 & c_up==. & c_`r'!=. & BID_`r'==0
replace c_downN=c_`r' if down`r'==1 & c_down==. & c_`r'!=. & BID_`r'==0
}

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

***** SEE IF WE CAN GET USEFUL (PROPORTIONAL) CORRELATIONS FROM MRU! *****


gegen p1d_min_mru=min(p1d), by(mru)
g p1id_mru_id = mru if p1d==p1d_min_mru
gegen p1id_mru=min(p1id_mru_id), by(mru)

gegen p1m=mean(p1d), by(mru)

reg c p1m 


******

g c_d= c_down-c_up
g c_dB = c_downB-c_upB
g c_dN = c_downN-c_upN

gegen yes_flow1m=mean(yes_flow1), by(barangay_id1 wave1)
gegen no_flow1m=mean(no_flow1), by(barangay_id1 wave1)

g B_up = 0 if c_upN!=.
replace B_up = 1 if c_upB!=.

g B_down = 0 if c_downN!=.
replace B_down = 1 if c_downB!=.


g B_up1   = B_up==1
g B_down1 = B_down==1


reg c B_up1 B_down1 p1d


areg c B B_up1 B_down1 p1d i.date, cluster(conacct) a(barangay_id1)



areg c_down B1 c_up c yes_flow1m i.date , a(barangay_id1) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(barangay_id1) cluster(conacct) r


reg c_down B1 c_up c yes_flow1m  , r
reg c_up B1 c_down c yes_flow1m  , r


areg c_down B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_down B1  c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1    c yes_flow1m i.date , a(conacct) cluster(conacct) r


areg c_down B1  yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1    yes_flow1m i.date , a(conacct) cluster(conacct) r



areg c_down B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(conacct) cluster(conacct) r




areg c_downB B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_downN B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r



g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)
gegen cdy=mean(c_d), by(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

g far = p1d>200
g post = year>year_inst
g post_far = post*far
g post_BM = post*BM


* areg c_d B1 i.date, a(mru)
* areg c_down B1 i.date, a(mru)
* areg c_up B1 i.date, a(mru)



areg cy post post_far post_f2ar i.year if yt==1, a(conacct) cluster(mru) r

areg cdy post i.year if yt==1, a(conacct) cluster(mru) r

areg cdy post post_BM i.year if yt==1 , a(conacct) cluster(mru) r

areg c_d B1 yes_flow1m i.pT i.date , a(conacct) cluster(conacct) r
* areg c_d2 B1 yes_flow1m i.pT i.date , a(conacct) cluster(conacct) r






**** TRY BARANGAY EXTERNALITY?! ****
**** ACTUALLY KIND OF WORKS! ****

use "${temp}npaws_bill_full.dta", clear
	ren *_original *
	drop *_*

	merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
	
gegen b1 = max(barangay_id), by(conacct)
gegen b_max=max(p1d), by(b1)
gegen b_min=min(p1d), by(b1)

g b_d= (p1d-b_min)/(b_max - b_min)

egen pg=cut(p1d), at(0(50)2500)

egen b_dg=cut(b_d), at(0(.1)1)
replace b_dg=b_dg*10

gegen nf_bdg=mean(no_flow), by(b_dg)

reg B b_d p1d  i.wave, cluster(conacct) r
reg B b_d nf_bdg  i.wave, cluster(conacct) r

reg B b_d no_flow p1d  i.wave, cluster(conacct) r
reg c b_d no_flow p1d  i.wave, cluster(conacct) r

reg B b_d p1d  i.wave, cluster(conacct) r
reg c b_d p1d  i.wave, cluster(conacct) r


reg no_flow b_d p1d  i.wave, cluster(conacct) r

reg B b_d i.pg i.wave, cluster(conacct) r
reg B i.b_dg i.pg i.wave, cluster(barangay) r
areg B p1d i.wave, a(barangay_id) cluster(conacct) r



****  FAMILY MATCH! ****


use "${temp}paws_aib.dta", clear
	keep barangay_id conacct
	duplicates drop conacct, force
save "${temp}paws_bar.dta", replace




use "${temp}npaws_bill_full.dta", clear
drop c_* class_*
drop date
	gegen dt=tag(conacct_original)
	keep if dt==1
	drop dt

ren conacct_original conacct
merge m:1 conacct using "${temp}name_g.dta", keep(1 3) nogen
ren ln ln_original
ren fn fn_original
ren conacct conacct_original

forvalues r=1/10 {
	ren conacct_`r' conacct
	merge m:1 conacct using "${temp}name_g.dta", keep(1 3) nogen
	merge m:1 conacct using "${temp}paws_bar.dta", keep(1 3) nogen
	ren barangay_id barangay_id_`r'
	ren conacct conacct_`r'
	ren ln ln_`r'
	ren fn fn_`r'
}

	ren *_original *

merge 1:m conacct using "${temp}paws_aib", keep(1 3) nogen	



cap drop fam_up
cap drop fam_down
cap drop tot_up
cap drop tot_down
cap drop fam_upr
cap drop fam_downr 

cap drop bar_up
cap drop bar_down
cap drop bart_up
cap drop bart_down
cap drop bar_upr
cap drop bar_downr 

g fam_up = 0
g tot_up = 0
g fam_down = 0
g tot_down = 0

g bar_up = 0
g bar_down=0
g bart_up=0
g bart_down=0


forvalues r=1/10 {
	replace fam_up = fam_up + 1 if ln==ln_`r' & p1d>p1d_`r' & fn==fn_`r'
	replace tot_up = tot_up + 1 if p1d>p1d_`r'
	replace fam_down = fam_down + 1 if ln==ln_`r' & p1d<p1d_`r' & fn==fn_`r'
	replace tot_down = tot_down + 1 if p1d<p1d_`r'

	replace bar_up = bar_up + 1 if barangay_id!=barangay_id_`r' & p1d>p1d_`r'
	replace bart_up = bart_up + 1 if barangay_id_`r'!=. & p1d>p1d_`r'
	replace bar_down = bar_down + 1 if barangay_id!=barangay_id_`r' & p1d<p1d_`r'
	replace bart_down = bart_down + 1 if barangay_id_`r'!=. & p1d<p1d_`r'
}

g fam_upr = fam_up/tot_up
g fam_downr = fam_down/tot_down

g bar_upr = bar_up/bart_up
g bar_downr = bar_down/bart_down

g fup_id = fam_up>0 & fam_up<.
g fud_id = fam_down>0 & fam_down<.

egen pg= cut(p1d), at(0(200)2500)


areg B fam_upr fam_downr no_flow p1d i.wave, cluster(barangay_id) a(barangay_id) r



areg B fup_id fud_id i.pg i.date, cluster(barangay_id) a(barangay_id) r



areg B bar_up bar_down p1d i.wave, cluster(barangay_id) a(barangay_id) r








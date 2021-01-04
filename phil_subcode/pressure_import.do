* pressure_import.do



use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear






use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear
	g barangay_id = prov*100000 + mun*1000 + brgy
	keep barangay_id totin
	replace totin = totin/12
	replace totin = . if totin>200000
	* g year = 2011 
	gegen inc_2011=mean(totin), by(barangay_id)
	gegen bt=tag(barangay_id)
	keep if bt==1
	keep barangay_id inc_2011
save "${temp}cbms_inc_2011.dta", replace

use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear
	g barangay_id = prov*100000 + mun*1000 + brgy
	keep barangay_id totin
	replace totin = totin/12
	replace totin = . if totin>200000
	* g year = 2008
	gegen inc_2008=mean(totin), by(barangay_id)
	gegen bt=tag(barangay_id)
	keep if bt==1
	keep barangay_id inc_2008
save "${temp}cbms_inc_2008.dta", replace


use "${temp}cbms_inc_2011.dta", clear
	merge 1:1 barangay_id using  "${temp}cbms_inc_2008.dta", keep(3) nogen
save "${temp}cbms_inc.dta", replace




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
	tsset conacct date
	tsfill, full
		fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
		drop if date<datec
	keep c conacct date class read
save "${temp}bill_paws_full_ts.dta", replace



* use "${temp}bar_health_11.dta", clear
* 	merge 1:1 bar using "${temp}bar_map_list.dta"

	odbc load, exec("SELECT A.* FROM pipes_barangay_int AS JOIN barangay AS B ON A.OGC_FID_bar=B.OGC_FID ")  dsn("phil") clear  
	bar_clean
	ren int_length length

	keep if pipe_class=="TERTIARY"
		egen total_bar=sum(length), by(bar)
		destring year_inst, replace force
	keep if year_inst>2000
		egen ly=sum(length), by(bar year_inst)
		egen max_l=max(ly), by(bar)
		keep if ly==max_l
		g shr=max_l/total_bar
	*	keep if year_inst>=2008
		keep length year_inst bar shr
		duplicates drop bar, force

		format bar %25s
		g str bar1 =bar
		drop bar
		ren bar1 bar
	save "${temp}brgy_pipe_date.dta", replace


	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_primary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	save "${temp}dist_primary_points_conacct.dta", replace

	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_secondary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	save "${temp}dist_secondary_points_conacct.dta", replace

	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_tertiary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	save "${temp}dist_tertiary_points_conacct.dta", replace

	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_tertiary_points_5m_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	save "${temp}dist_tertiary_points_5m_conacct.dta", replace


	odbc load, exec("SELECT * FROM meter_dma_int")  dsn("phil") clear  
		g str10 dma = dma_id
			drop dma_id
		keep dma conacct
		duplicates drop conacct, force
	save "${temp}conacct_dma_link.dta", replace



		* odbc load, exec(" SELECT N.* FROM neighborp_50 AS N ") dsn("phil") clear
		* 	ren conacct conacctn
		* 	ren conacctp conacct
		* 	ren distance distance_p

		* 	merge m:1 conacct using "${temp}dist_tertiary_points_5m_conacct.dta", keep(1 3) nogen 



		*** GO ALL IN ON PAWS!!!! ***


	use "${data}paws/clean/full_sample_prefs_b.dta", clear

		foreach var of varlist stop_big booster booster_need {
			ren `var' `var'_id
			g `var'=0 if `var'_id=="Hindi"
			replace `var'=1 if `var'_id=="Oo"
		}

		foreach var of varlist stop_freq stop_length booster_use {
			drop `var'
			ren `var'_extra `var'
			destring `var', replace force
		}

		foreach var of varlist smell color taste stuff {
			drop `var'
			g `var'=`var'_extra!=""
			drop `var'_extra
		}
		
		keep conacct wave stop_big booster booster_need stop_freq stop_length booster_use smell color taste stuff  pf_cont_day_pr pf_cont_night_pr pf_day_pr_night_pr pf_flow_compl pf_flow_qual pf_qual_flow

	save "${temp}paws_prefs_b.dta", replace



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
		ren yr year
		drop mn

		g balde= storage=="Balde"
		g drum= storage=="Drum"
		g gallon= storage=="Galon"

		destring hhsize, replace force
		replace hhsize=. if hhsize>12

		g B = booster=="Oo"
		g S = storage!=""
		destring hhemp, replace force
		replace hhemp=. if hhemp>12
			g SHH = shr_num_extra
			destring SHH, replace force
			g hho= SHH - hhsize
			replace hhsize = . if hhsize>12
			replace hho = . if hho<0 | hho>14

			drop age
			ren age age
			destring age, replace force
			g sub=regexm(house,"Subdivided")==1
			g single=regexm(house,"Single house")==1

			ren drink drink_id
			g drink = 0 if drink_id=="Hindi"
			replace drink = 1 if drink_id=="Oo"
			ren boil boil_id
			g boil = 0 if boil_id=="Hindi"
			replace boil = 1 if boil_id == "Oo"

			destring wrs_exp_extra alt_src_extra, replace force
			g wrs = alt_src_extra
			replace wrs = wrs_exp_extra if wrs==. & wrs_exp_extra!=.

			g wrs_type = 1 if regexm(alt_src,"refill")==1
			replace wrs_type = 2 if regexm(alt_src,"Deep")==1 | regexm(alt_src,"Pribado")==1  | regexm(alt_src,"Iba pang")==1
			replace wrs_type = 0 if wrs_type==.

			destring job, replace force
			ren class sclass


		keep date year me conacct hhsize drink boil wrs wrs_type no_flow yes_flow flow_hrs barangay B S wave balde drum gallon sub single hhemp hho job age  sclass

		merge 1:1 conacct wave using "${temp}paws_prefs_b.dta", keep(1 3) nogen

		recode booster_need (0 = 1) (1=0)
			duplicates drop conacct date, force
		save "${temp}paws_aib.dta", replace

			duplicates drop conacct year, force
		save "${temp}paws_year_aib.dta", replace




	use  /Users/williamviolette/Documents/Philippines/non_payment_exploration/temp/pipe_mru, clear
		keep if pipe_class=="TERTIARY"
		destring year_inst mru, replace force
		egen ly=sum(length), by(mru year_inst)
		egen max_l=max(ly), by(mru)
		egen total_mru=sum(length), by(mru)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		drop length
		ren ly length
		keep length year_inst mru shr
		duplicates drop mru, force
		ren mru mru
	save "${temp}pipe_year_old.dta", replace
	

	odbc load, exec("SELECT * FROM decom_pipes_mru_int")  dsn("phil") clear  
		egen length_tot=sum(int_length), by(mru year_inst)
		keep if pipe_class=="TERTIARY"
		destring year_inst mru, replace force

		drop if year_inst<5

		ren int_length length
		egen ly=sum(length), by(mru year_inst)
		egen max_l=max(ly), by(mru)
		egen total_mru=sum(length), by(mru)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		drop length
		ren ly length
		keep length length_tot year_inst mru shr
		duplicates drop mru, force
		ren * *_decom
		ren mru mru
	save "${temp}pipe_year_decom_nold.dta", replace



	odbc load, exec("SELECT * FROM pipes_mru_int")  dsn("phil") clear  
		egen length_tot=sum(int_length), by(mru year_inst)
		keep if pipe_class=="TERTIARY"
		destring year_inst mru, replace force
		ren int_length length
		egen ly=sum(length), by(mru year_inst)
		egen max_l=max(ly), by(mru)
		egen total_mru=sum(length), by(mru)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		drop length
		ren ly length
		keep length length_tot year_inst mru shr
		duplicates drop mru, force
		ren mru mru
	save "${temp}pipe_year_nold.dta", replace


*** PIPE LENGTH FIGURE FOR PAPER
	odbc load, exec("SELECT * FROM pipes_dma_int")  dsn("phil") clear  
		gegen total_length=sum(int_length)
		tab total_length
	destring year_inst, replace
	g post = year_inst>=2005 & year_inst<=2015

gegen total_length_post=sum(int_length), by(post)
tab  total_length_post if post==1


	odbc load, exec("SELECT * FROM pipes_dma_int")  dsn("phil") clear  

		keep if pipe_class=="TERTIARY"
		destring year_inst, replace force
		ren int_length length
		* g year_inst1 = year_inst if year_inst>1900 & year_inst<2020
		* asgen year_mean = year_inst1, by(dma_id) w(length)
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



	use  /Users/williamviolette/Documents/Philippines/non_payment_exploration/temp/pipe_mru, clear
		keep if pipe_class=="TERTIARY"
		g branch=substr(mru_no,1,4)
		destring branch, replace force
		destring year_inst branch, replace force

		g length_latest=length if year_inst>2000
		egen ly=sum(length_latest), by(branch year_inst)
		egen max_l=max(ly), by(branch)

		egen total_branch=sum(length), by(branch)
		keep if ly==max_l

		g shr=max_l/total_branch
		keep length year_inst branch shr
		duplicates drop branch, force
	save "${temp}pipe_year_branch.dta", replace
	


	
	use  /Users/williamviolette/Documents/Philippines/non_payment_exploration/temp/pipe_mru, clear
		keep if pipe_class=="TERTIARY"
		destring year_inst mru, replace force
		drop if year_inst<2007
		egen ly=sum(length), by(mru year_inst)
		egen max_l=max(ly), by(mru)
		egen total_mru=sum(length), by(mru)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
	ren year_inst year_inst_new
		keep year_inst_new mru
		duplicates drop mru, force
		ren mru mru
	save "${temp}pipe_year_old_latest.dta", replace

	


		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
		ren Col4 ba
		ren Col5 ba_name
		destring ba, replace force
		duplicates drop ba, force
		keep if ba!=.
		keep ba ba_name
		save "${temp}ba_name.dta", replace


		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
		ren Col12 conacct
		ren Col10 mru
		ren Col4 ba
		ren Col5 ba_name
		g year=substr(Col19,1,4)
		g month=substr(Col19,6,2)
		destring year month mru ba , replace force
		g datec = ym(year,month)
		keep conacct datec mru ba ba_name
		drop if conacct==.
		duplicates drop conacct, force

		g after = datec<=545
		gegen asum=sum(after), by(mru)
		duplicates drop mru, force

		g kg = asum>10 & asum<.

		tab ba_name kg 

		keep mru
		destring mru, replace force
		save "${temp}old_mru.dta", replace


		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
				keep if Col39==""
			ren Col12 conacct
			ren Col10 mru
			drop if conacct==.
			duplicates drop conacct, force
			g o=1
			gegen accts=sum(o), by(mru)
			gegen mtag=tag(mru)
			keep if mtag==1
			drop mtag o
			keep mru accts
			destring mru, replace force
		save "${temp}accts_per_mru.dta", replace


		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
		ren Col12 conacct
		ren Col10 mru
		ren Col4 ba
		ren Col5 ba_name
		g year=substr(Col19,1,4)
		g month=substr(Col19,6,2)
		destring year month mru ba , replace force
		g datec = ym(year,month)
		keep conacct datec mru ba ba_name
		drop if conacct==.
		duplicates drop conacct, force

		merge 1:1 conacct using "${temp}conacct_dma_link.dta", keep(3) nogen
		g after = datec<=545
		gegen asum=sum(after), by(dma)
		duplicates drop dma, force

		keep if asum>20 & asum<.

		keep dma
		save "${temp}old_dma.dta", replace
		


		use ${database}clean/mcf/2015/full_2015.dta, clear
				drop if Col3=="Row Count"
		ren Col12 conacct
		g year=substr(Col19,1,4)
		g month=substr(Col19,6,2)
		g day = substr(Col19,9,2)
		destring year month day, replace force
		g dayc = mdy(month,day,year)
		keep conacct dayc
		drop if conacct==.
		duplicates drop conacct, force
		save "${temp}dayc.dta", replace

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
		ren Col27 billclass_key
		duplicates tag Col16 Col17, g(ndup)
		g year=substr(Col19,1,4)
		g month=substr(Col19,6,2)
		destring year month, replace force
		g datec = ym(year,month)
		drop year month
			drop C*
				destring ba conacct zone_code mru bus_id dc billclass_key, replace force
				drop if conacct==.
				duplicates drop conacct, force
		save "${temp}conacct_rate.dta", replace

		use "${temp}conacct_rate.dta", clear
			keep mru zone_code
			duplicates drop mru, force
			drop if mru==. | zone_code==.
		save "${temp}mru_zone_code.dta", replace


	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.c, A.conacct, A.date, A.class, A.read FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}bill_paws_full.dta", replace



	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.amount, A.conacct, A.date  FROM bill_total_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}amount_paws_full.dta", replace


	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.* FROM ar_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}ar_paws_full.dta", replace


	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.* FROM coll_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}pay_paws_full.dta", replace


	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.* FROM mcf_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}dc_paws_full.dta", replace


		
		

	odbc load, exec("SELECT A.*, B.area as area_mru FROM mru_dma_int AS A JOIN mru AS B ON A.mru = B.mru_no")  dsn("phil") clear  
	* odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
		destring mru, replace force
		gegen marea=max(area), by(mru)
		keep if marea==area
		duplicates drop mru, force
		g str10 dma = dma_id
			drop dma_id
		g shr = area/area_mru
		keep if shr>.50
		keep dma mru
	save "${temp}mru_dma_link.dta", replace



	odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
		destring mru, replace force
		merge m:1 mru using "${temp}mru_zone_code.dta", keep(3) nogen

		egen area_dma = sum(area), by(dma_id)
		egen area_zone = sum(area), by(zone_code)
		egen area_int = sum(area), by(dma_id zone_code)
		keep dma_id zone_code area_dma area_zone area_int
		duplicates drop dma_id zone_code, force

		egen m_area_int=max(area_int), by(dma_id)
		g shr=m_area_int/area_dma
		keep if m_area_int == area_int
		keep dma_id zone_code
				g str10 dma = dma_id
			drop dma_id
	save "${temp}zone_dma_link.dta", replace



	use "${temp}capex_raw.dta", clear

	keep var4 var3 var5 var9 var10 var39 
	keep if var3!=""

	ren var5 capex_year
	destring capex_year, replace force

	g yr_d = "20"+substr(var3,1,2)
	destring yr_d, replace force
	replace yr_d=. if yr_d==20
	g mn_d = substr(var3,4,3)

	g month_d = 1 if mn_d=="Jan"
	replace month_d = 2 if mn_d=="Feb"
	replace month_d = 3 if mn_d=="Mar"
	replace month_d = 4 if mn_d=="Apr"
	replace month_d = 5 if mn_d=="May"
	replace month_d = 6 if mn_d=="Jun"
	replace month_d = 7 if mn_d=="Jul"
	replace month_d = 8 if mn_d=="Aug"
	replace month_d = 9 if mn_d=="Sep"
	replace month_d = 10 if mn_d=="Oct"
	replace month_d = 11 if mn_d=="Nov"
	replace month_d = 12 if mn_d=="Dec"

	g date_d = ym(yr_d,month_d)

	g yr_c = "20"+substr(var39,1,2)
	destring yr_c, replace force
	replace yr_c=. if yr_c==20
	g mn_c = substr(var39,4,3)

	g month_c = 1 if mn_d=="Jan"
	replace month_c = 2 if mn_c=="Feb"
	replace month_c = 3 if mn_c=="Mar"
	replace month_c = 4 if mn_c=="Apr"
	replace month_c = 5 if mn_c=="May"
	replace month_c = 6 if mn_c=="Jun"
	replace month_c = 7 if mn_c=="Jul"
	replace month_c = 8 if mn_c=="Aug"
	replace month_c = 9 if mn_c=="Sep"
	replace month_c = 10 if mn_c=="Oct"
	replace month_c = 11 if mn_c=="Nov"
	replace month_c = 12 if mn_c=="Dec"

	g date_c = ym(yr_c,month_c)

	g ongoing = regexm(var39,"on-going")==1

	drop month_* mn_* var39 var3
	ren yr_d year_d
	ren yr_c year_c
	ren var4 dma

	ren var9 cost
	ren var10 pipe_l

	replace cost = regexs(1) if regexm(cost,"(.+)/") 
	replace pipe_l = regexs(1) if regexm(pipe_l,"(.+)/") 
	destring cost pipe_l, replace force

	duplicates drop dma, force
	save "${temp}capex_dma_full.dta", replace



******** CHECK WHATS GOING ON! ********




use "${temp}mru_dma_link.dta", clear

	merge m:1 dma using  "${temp}capex_dma_full.dta", keep(1 3) nogen
	merge 1:m mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
	merge 1:m mru using "${temp}pipe_year_old_latest.dta", keep(1 3) nogen

	drop dma 

save "${temp}pipe_test.dta", replace





****  FULL! FOR AMOUNT! *** ****
		forvalues r = 1/12 {
			* local r 1
		local bill_query " SELECT A.amount, A.conacct, A.date  FROM bill_total_`r' AS A"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
			fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
			keep amount mru date billclass_key
			keep if billclass_key<=4
			* replace billclass_key=3 if billclass_key==4
			gegen asum = sum(amount), by(mru date)
			gegen amean=mean(amount), by(mru date)
			forvalues j=1/4 {
				g am_`j'=amount if billclass_key==`j'
				gegen asum_`j' = sum(am_`j'), by(mru date)
				gegen amean_`j' = mean(am_`j'), by(mru date)
				drop am_`j'
			}
			gegen mt=tag(mru date)
			keep if mt==1
		keep mru date asum* amean*
		save "${temp}full_amountm_`r'.dta", replace
		}


		use   "${temp}full_amountm_1.dta", clear
		erase "${temp}full_amountm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}full_amountm_`r'.dta"
			erase "${temp}full_amountm_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}full_amountm.dta", replace	


****  FULL! FOR BILLING!! *** ****
		forvalues r = 1/12 {
			* local r 1
		local bill_query " SELECT A.c, A.conacct, A.date FROM billing_`r' AS A WHERE A.c>=0"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
			fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
			keep c mru date billclass_key
			keep if billclass_key<=4
			gegen csum = sum(c), by(mru date)
			gegen cmean=mean(c), by(mru date)
			forvalues j=1/4 {
				g cm_`j'=c if billclass_key==`j'
				gegen csum_`j' = sum(cm_`j'), by(mru date)
				gegen cmean_`j' = mean(cm_`j'), by(mru date)
				drop cm_`j'
			}
			gegen mt=tag(mru date)
			keep if mt==1
		keep mru date csum* cmean*
		save "${temp}full_billm_`r'.dta", replace
		}

		use   "${temp}full_billm_1.dta", clear
		erase "${temp}full_billm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}full_billm_`r'.dta"
			erase "${temp}full_billm_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}full_billm.dta", replace	


		forvalues r = 1/12 {
			* local r 1
		local bill_query " SELECT A.c, A.conacct, A.date FROM billing_`r' AS A WHERE A.c>=0"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
			fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
			keep c conacct date billclass_key
			keep if billclass_key==3 | billclass_key==4
		save "${temp}comm_billm_`r'.dta", replace
		}

		use   "${temp}comm_billm_1.dta", clear
		erase "${temp}comm_billm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}comm_billm_`r'.dta"
			erase "${temp}comm_billm_`r'.dta"
		}
		duplicates drop conacct date, force
		save "${temp}comm_billm.dta", replace	



		forvalues r = 1/12 {
			* local r 1
		local bill_query " SELECT A.amount, A.conacct, A.date  FROM bill_total_`r' AS A"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
			fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
			keep amount conacct date billclass_key
			keep if billclass_key==3 | billclass_key==4
		save "${temp}comm_amountm_`r'.dta", replace
		}

		use   "${temp}comm_amountm_1.dta", clear
		erase "${temp}comm_amountm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}comm_amountm_`r'.dta"
			erase "${temp}comm_amountm_`r'.dta"
		}
		duplicates drop conacct date, force
		save "${temp}comm_amountm.dta", replace	






/*



	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, PA.paws FROM pipe_tertiary_points_5m_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID LEFT JOIN (SELECT DISTINCT 1 AS paws, conacct FROM paws) AS PA ON PA.conacct = P.conacct")  dsn("phil") clear  
		destring year_inst, replace force
		destring paws, replace force
			replace paws=0 if paws==.
		gegen mpaws=max(paws), by(pipe_id)
			keep if mpaws==1
			drop mpaws
		gegen spaws=sum(paws), by(pipe_id)
			keep if spaws>3
			drop spaws distance 
			ren pipe_id p3id
			ren year_inst p3yr

			gentable paws_pipes

		merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
			ren distance p1d
			ren year_inst p1yr
			ren pipe_id p1id

		sort p3id p1d
		by p3id: g p1r=_n
		g pd = 0 if paws==1
		g long pconacct = conacct if paws==1
		forvalues r=1/12 {
			by p3id: replace pd=-`r' if paws[_n+`r']==1 & pd==.
			by p3id: replace pd=`r' if paws[_n-`r']==1 & pd==.
			by p3id: replace pconacct=conacct[_n+`r'] if paws[_n+`r']==1 & pconacct==.
			by p3id: replace pconacct=conacct[_n-`r'] if paws[_n-`r']==1 & pconacct==.	
		}
	save "${temp}paws_pipes.dta", replace

		local bill_query ""
		forvalues r = 1/12 {
			local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN paws_pipes AS B ON A.conacct=B.conacct"
			if `r'!=12{
				local bill_query "`bill_query' UNION ALL"
			}
		}
		odbc load, exec("`bill_query'")  dsn("phil") clear  
		duplicates drop conacct date, force
		save "${temp}paws_pipes_bill.dta", replace



	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, PA.paws FROM pipe_tertiary_points_5m_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID LEFT JOIN (SELECT DISTINCT 1 AS paws, conacct FROM paws) AS PA ON PA.conacct = P.conacct")  dsn("phil") clear  
		destring year_inst, replace force
		destring paws, replace force
			replace paws=0 if paws==.
		gegen mpaws=max(paws), by(pipe_id)
			keep if mpaws==1
			drop mpaws
		gegen spaws=sum(paws), by(pipe_id)
			keep if spaws>3
			drop spaws distance 
			ren pipe_id p3id
			ren year_inst p3yr

		merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
			ren distance p1d
			ren year_inst p1yr
			ren pipe_id p1id


		merge m:1 conacct using "${temp}paws_year_B.dta", keep(1 3) nogen
			drop B_*

		sort p3id p1d
		by p3id: g p1r=_n

		forvalues r=1/24 {
			by p3id: g B_up`r' = BM[_n-`r']
			by p3id: g B_down`r' = BM[_n+`r']
		}
	save "${temp}paws_pipes_ranking.dta", replace






	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id, PA.paws FROM pipe_tertiary_points_5m_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID LEFT JOIN (SELECT DISTINCT 1 AS paws, conacct FROM paws) AS PA ON PA.conacct = P.conacct")  dsn("phil") clear  
		destring year_inst, replace force
		destring paws, replace force
			replace paws=0 if paws==.
		gegen mpaws=max(paws), by(pipe_id)
			keep if mpaws==1
			drop mpaws
		* gegen spaws=sum(paws), by(pipe_id)
		* 	keep if spaws>3
		* 	drop spaws 
			drop distance 
			ren pipe_id p3id
			ren year_inst p3yr

		merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
			ren distance p1d
			ren year_inst p1yr
			ren pipe_id p1id


		merge m:1 conacct using "${temp}paws_year_B.dta", keep(1 3) nogen
			* drop B_*

		sort p3id p1d
			by p3id: g p1r=_n
		forvalues r=1/12 {
			by p3id: g B_up`r' = BM[_n-`r']
			by p3id: g B_down`r' = BM[_n+`r']
		}
		forvalues z=2008/2011 {
			forvalues r=1/12 {
				by p3id: g By_`z'_up`r' = B_`z'[_n-`r']
				by p3id: g By_`z'_down`r' = B_`z'[_n+`r']
			}
		}

	save "${temp}paws_pipes_only_ranking_yr.dta", replace

		drop By*
	save "${temp}paws_pipes_only_ranking.dta", replace




**** YEAR PANEL! ****
		* forvalues r = 1/12 {
		* 	local bill_query " SELECT * FROM billing_`r' WHERE c>=0 AND c<500"
		* odbc load, exec("`bill_query'")  dsn("phil") clear  
		* fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		* 	tsset conacct date
		* 	tsfill, full
		* 	drop if date<datec
		* 	g dated=dofm(date)
		* 	g year=year(dated)

		* 	gegen mc = mean(c), by(conacct year)
		* 	g cm=c==.
		* 	replace cm=. if date==592 | date==593 | date==595 | date==653
		* 	gegen mcm = mean(cm), by(conacct year)

		* 	gegen mt=tag(conacct year)
		* 	keep if mt==1
		* keep conacct year mc mcm
		* save "${temp}year_billm_`r'.dta", replace
		* }

		* use   "${temp}year_billm_1.dta", clear
		* erase "${temp}year_billm_1.dta"
		* forvalues r = 2/12 {
		* 	append using "${temp}year_billm_`r'.dta"
		* 	erase "${temp}year_billm_`r'.dta"
		* }
		* duplicates drop conacct year, force
		* save "${temp}year_billm.dta", replace	


**** YEAR PANEL! FOR AMOUNT! *** ****
		* forvalues r = 1/12 {
		* 	* local r 1
		* 	local bill_query " SELECT A.amount, A.conacct, A.date  FROM bill_total_`r' AS A"
		* odbc load, exec("`bill_query'")  dsn("phil") clear  
		* 	tsset conacct date
		* 	tsfill, full
		* 	fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		* 	keep amount conacct date datec
		* 	drop if date<datec
		* 	g dated=dofm(date)
		* 	g year=year(dated)

		* 	gegen ma = mean(amount), by(conacct year)
		* 	g am=amount==.
		* 	replace am=. if date==592 | date==593 | date==595 | date==653
		* 	gegen mam = mean(am), by(conacct year)

		* 	gegen mt=tag(conacct year)
		* 	keep if mt==1
		* keep conacct year ma mam
		* save "${temp}year_amountm_`r'.dta", replace
		* }

		* use   "${temp}year_amountm_1.dta", clear
		* erase "${temp}year_amountm_1.dta"
		* forvalues r = 2/12 {
		* 	append using "${temp}year_amountm_`r'.dta"
		* 	erase "${temp}year_amountm_`r'.dta"
		* }
		* duplicates drop conacct year, force
		* save "${temp}year_amountm.dta", replace	


**** YEAR PANEL! FOR PAYMENTS! *** ****

		* forvalues r = 1/12 {
		* 	local bill_query " SELECT A.* FROM coll_`r' AS A"
		* odbc load, exec("`bill_query'")  dsn("phil") clear  
		* fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
		* 	tsset conacct date
		* 	tsfill, full
		* 	drop if date<datec
		* 	g dated=dofm(date)
		* 	g year=year(dated)

		* 	gegen mp = mean(pay), by(conacct year)
		* 	g pm=pay==.
		* 	gegen mpm = mean(pm), by(conacct year)

		* 	gegen mt=tag(conacct year)
		* 	keep if mt==1
		* keep conacct year mp mpm
		* save "${temp}year_paym_`r'.dta", replace
		* }

		* use   "${temp}year_paym_1.dta", clear
		* erase "${temp}year_paym_1.dta"
		* forvalues r = 2/12 {
		* 	append using "${temp}year_paym_`r'.dta"
		* 	erase "${temp}year_paym_`r'.dta"
		* }
		* duplicates drop conacct year, force
		* save "${temp}year_paym.dta", replace	







* forvalues r = 1/12 {
* 	* local r 1
* 			local bill_query " SELECT * FROM billing_`r' WHERE c>=0 AND c<100"
* 		odbc load, exec("`bill_query'")  dsn("phil") clear  
* 		fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
* 			keep if datec<=580
* 			* g o=1
* 			g dated=dofm(date)
* 			g year=year(dated)
* 			g or = 1 if read==1
* 			gegen cden=sum(or), by(c mru year)
* 			g onr = 1 if read==0
* 			gegen cdennr = sum(onr), by(c mru year)
* 			gegen mt=tag(c mru year)
* 			keep if mt==1
* 		keep year mru cden cdennr c 
* 		save "${temp}cd_`r'.dta", replace
* 		}

* 		use   "${temp}cd_1.dta", clear
* 		erase "${temp}cd_1.dta"
* 		forvalues r = 2/12 {
* 			append using "${temp}cd_`r'.dta"
* 			erase "${temp}cd_`r'.dta"
* 		}
* 		duplicates drop mru c year, force
* 		save "${temp}cd.dta", replace	




* *** PANEL OF AVERAGE CONS AND DISCONNECTIONS! 
* 		forvalues r = 1/12 {
* 			local bill_query " SELECT * FROM billing_`r' WHERE c>=0 AND c<500"
* 		odbc load, exec("`bill_query'")  dsn("phil") clear  
* 		fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
* 			keep if datec<=550
* 			tsset conacct date
* 			tsfill, full
* 			drop if date<datec
* 			gegen mc = mean(c), by(mru date)
* 			g cm=c==.
* 			replace cm=. if date==592 | date==593 | date==595 | date==653
* 			gegen mcm = mean(cm), by(mru date)

* 			gegen mt=tag(mru date)
* 			keep if mt==1
* 		keep date mru mc mcm
* 		save "${temp}panel_billm_`r'.dta", replace
* 		}

* 		use   "${temp}panel_billm_1.dta", clear
* 		erase "${temp}panel_billm_1.dta"
* 		forvalues r = 2/12 {
* 			append using "${temp}panel_billm_`r'.dta"
* 			erase "${temp}panel_billm_`r'.dta"
* 		}
* 		duplicates drop mru date, force
* 		save "${temp}panel_billm.dta", replace	


* 	**** READ ACCOUNTS

* 		forvalues r = 1/12 {
* 			local bill_query " SELECT * FROM billing_`r' WHERE c>=0 AND c<500"
* 		odbc load, exec("`bill_query'")  dsn("phil") clear  
* 		merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
* 			g read_early = read if datec<580
* 			gegen rem=mean(read), by(mru date)
* 			gegen reme=mean(read_early), by(mru date)
* 			gegen mt=tag(mru date)
* 			keep if mt==1
* 		keep date mru rem reme
* 		save "${temp}rem_`r'.dta", replace
* 		}

* 		use   "${temp}rem_1.dta", clear
* 		erase "${temp}rem_1.dta"
* 		forvalues r = 2/12 {
* 			append using "${temp}rem_`r'.dta"
* 			erase "${temp}rem_`r'.dta"
* 		}
* 		duplicates drop mru date, force
* 		save "${temp}rem.dta", replace	




* *** ACTIVE ACCOUNTS BY MRU! 
* 		forvalues r = 1/12 {
* 			local bill_query " SELECT * FROM billing_`r' WHERE c>=0 AND c<500"
* 		odbc load, exec("`bill_query'")  dsn("phil") clear  
* 		merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
* 			g o=1
* 			g clow_id = c if c<100
* 			g cread_id = c if read==1
* 			g ares_id = o if class==1 | class==2

* 			gegen c_count = sum(o), by(conacct)
* 			g cpanel_id = c if (class==1 | class==2) & c_count>60 & read==1 & c<200
* 			gegen cpanel=mean(cpanel_id), by(mru date)
* 			gegen asum=sum(o), by(mru date)
* 			gegen aressum=sum(ares_id), by(mru date)
* 			gegen csum=sum(c), by(mru date)
* 			gegen cmean=mean(c), by(mru date)
* 			gegen clow=mean(clow_id), by(mru date)
* 			gegen csumlow=sum(clow_id), by(mru date)
* 			gegen cread=mean(cread_id), by(mru date)
* 			gegen mt=tag(mru date)
* 			keep if mt==1
* 		keep date mru asum aressum csum csumlow cmean clow cread cpanel
* 		save "${temp}activem_`r'.dta", replace
* 		}

* 		use   "${temp}activem_1.dta", clear
* 		erase "${temp}activem_1.dta"
* 		forvalues r = 2/12 {
* 			append using "${temp}activem_`r'.dta"
* 			erase "${temp}activem_`r'.dta"
* 		}
* 		duplicates drop mru date, force
* 		save "${temp}activem.dta", replace	




/*  

 ** NOT A LOT OF EVIDENCE OF NEIGHBORS WITH ILLEGAL CONNECTIONS ! **

	use "${complaintdata}cc_12_2012_all.dta", clear
	 	g year="2012"
		g month="01"
	foreach r in 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_2012_all.dta", force
		replace month="`r'" if month==""
		replace year="2012" if year==""
	}
	foreach z in 2013  {
	foreach r in 01 02 03 04   10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
			replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2014 {
	foreach r in 01 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2015 {
	foreach r in 01 02 03 04 05 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}	
	ren contract conacct1
	replace conacct=conacct1 if conacct1!=""
		ren classificationcode class
		destring conacct year month, replace force
	*	duplicates drop conacct year month, force
		drop if conacct==.

	replace type=var24 if type=="" & var24!=""
	replace type=lower(type)
	replace title=lower(title)

	keep type class conacct year month resolution issue typecode title
	replace resolution=lower(resolution)
	replace issue=lower(issue)
	format resol %100s

browse if regexm(issue,"illegal connection")==1 | regexm(reso,"illegal connection")==1


browse if (regexm(issue,"illegal")==1 | regexm(reso,"illegal")==1 | regexm(issue,"theft")==1 | regexm(reso,"theft")==1) & ///
	(regexm(issue,"neigh")==1 | regexm(reso,"neigh")==1 )




cap prog drop bar_clean
prog def bar_clean
	replace bar=lower(bar)
	replace bar=subinstr(bar,".","",.)
	replace bar="batasan hills" if regexm(bar,"batasan hills")==1
	replace bar="damar" if regexm(bar,"damar")==1
	replace bar="aurora" if regexm(bar,"aurora")==1
	replace bar="imelda" if regexm(bar,"imelda")==1
	replace bar="josefa" if regexm(bar,"josefa")==1
	replace bar="fairview" if regexm(bar,"greater fairview")==1
	replace bar="greater lagro" if regexm(bar,"greater lagro")==1
	replace bar="amoranto" if regexm(bar,"amoranto")==1
	replace bar="novaliches" if regexm(bar,"novaliches")==1
	replace bar="pasong putik" if regexm(bar,"pasong putik")==1
	replace bar="payatas" if regexm(bar,"payatas a")==1
	replace bar="sto domingo" if regexm(bar,"sto domingo")==1
	* MERGE payatas!!!! FOR NOW JUST PAYATAS A!
	replace bar=strtrim(bar)
end



use "${data}Quezon City Health/raw_health/MMR_14_jan_aug.dta", clear

	g year=2014
g month = substr(var34,1,2)
destring month, replace force
destring var3-var32, replace force
egen Ms=rowtotal(var3-var32)

replace var2=lower(var2)
g diar = regexm(var2,"diarrhea")==1
replace diar=1 if regexm(var2,"acute gastro")==1
replace diar=1 if regexm(var2,"gastro-enteritis")==1
replace diar=1 if regexm(var2,"gastroenteritis")==1
keep if diar==1

ren var1 bgy_code
egen M =sum(Ms), by(year month bgy_code)
duplicates drop year month bgy_code, force
ren bgy_code bar
	keep bar M month year
		replace bar=lower(bar)
		sort bar
	bar_clean
	duplicates drop bar month year, force
	drop if bar==""

save "${temp}MMR_14_jan_jul_clean.dta", replace






import delimited using "${data}Quezon City Health/MMR_13_working.csv", delimiter(",") clear

replace column1=lower(column1)

g diar = regexm(column1,"diarrhea")==1
replace diar=1 if regexm(column1,"acute gastro")==1
replace diar=1 if regexm(column1,"gastro-enteritis")==1
replace diar=1 if regexm(column1,"gastroenteritis")==1
keep if diar==1


destring under1_m-above_f, replace force
egen Ms = rowtotal(under1_m-above_f)
egen M =sum(Ms), by(date bgy_code)
duplicates drop date bgy_code, force
ren bgy_code bar

g year = 2013

g month = substr(date,1,2)
destring month, replace force
	keep bar M month year
		replace bar=lower(bar)
		sort bar
	bar_clean
	duplicates drop bar month year, force
	drop if bar==""

save "${temp}MMR_13_clean.dta", replace


* save "${data}Quezon City Health/raw_health/MMR_12_raw.dta", replace
use "${data}Quezon City Health/raw_health/MMR_12_raw.dta", clear

keep if var8 == "Acute Gastro-Enteritis (Diarrheas)"

destring var9-var30, replace force

egen M=rowtotal(var9-var30)

ren var3 bar
replace bar = var4 if bar=="" & var4!=""
replace bar = var5 if bar=="" & var5!=""
replace bar = var6 if bar=="" & var6!=""
replace bar = var7 if bar=="" & var7!=""

g month=1 if regexm(var2,"JANUARY")
replace month=2 if regexm(var2,"FEBRUARY")
replace month=3 if regexm(var2,"MARCH")
replace month=4 if regexm(var2,"APRIL")
replace month=5 if regexm(var2,"MAY")
replace month=6 if regexm(var2,"JUNE")
replace month=7 if regexm(var2,"JULY")
replace month=8 if regexm(var2,"AUG")
replace month=9 if regexm(var2,"SEPT")
replace month=10 if regexm(var2,"OCT")
replace month=11 if regexm(var2,"NOV")
replace month=12 if regexm(var2,"DEC")

g year = 2012

	keep bar M month year
		replace bar=lower(bar)
		sort bar
	bar_clean
	duplicates drop bar month year, force
	drop if bar==""

save "${temp}MMR_12_clean.dta", replace



foreach r in 09 10 11 {
	use "${data}Quezon City Health/raw_health/MMR_`r'.dta", clear

		replace bar=lower(bar)
		sort bar
	bar_clean
	duplicates drop bar month year, force
	drop if bar==""
		* MERGE payatas!!!! FOR NOW JUST PAYATAS A!
	save "${temp}MMR_`r'_clean.dta", replace
}


use "${temp}MMR_14_jan_jul_clean.dta", clear

foreach r in 09 10 11 12 13 {
	append using "${temp}MMR_`r'_clean.dta"
}

replace year=year+2000 if year<2000

sort bar year month

save "${temp}MMR_total.dta", replace


use "${data}Quezon City Health/raw_health/MMR_11.dta", clear
	keep bar
	duplicates drop bar, force
	replace bar=lower(bar)
	sort bar
	bar_clean
save "${temp}bar_health_11.dta", replace


use "${temp}barangay_map.dta", clear
	keep if regexm(munici,"QUEZON")==1
	ren brgy bar
	keep bar
	duplicates drop bar, force
	replace bar=lower(bar)
	sort bar
	bar_clean
save "${temp}bar_map_list.dta", replace





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
	ren var`=`r'-1' acct$zc
	global zc = $zc + 1
	}

	ren var2 dma
	keep dma supp* bill* acct*

	preserve
		keep dma supp*
		reshape long supp, i(dma) j(date)
		drop if dma==""
		drop if supp==.
		save "${temp}nrw_supp.dta", replace
	restore		

	preserve
		keep dma acct*
		reshape long acct, i(dma) j(date)
		drop if dma==""
		drop if acct==.
		save "${temp}nrw_acct.dta", replace
	restore		

		keep dma bill*
		reshape long bill, i(dma) j(date)
		drop if dma==""
		drop if bill==.
		merge 1:1 dma date using  "${temp}nrw_supp.dta", keep(3) nogen
		merge 1:1 dma date using  "${temp}nrw_acct.dta", keep(3) nogen
	save "${temp}nrw.dta", replace





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

		cap program drop gentablenp2
		program define gentablenp2
			odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
			odbc insert, table("`1'") dsn("phil") create
			odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
			odbc exec("CREATE INDEX `1'_conacct_ind1 ON `1' (conacct_1);"), dsn("phil")
			odbc exec("CREATE INDEX `1'_conacct_ind2 ON `1' (conacct_2);"), dsn("phil")
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




	*** PIPE FIX SHARING !!! ***

	* sample: date create by distance to MRU pipe

	use "${temp}conacct_rate.dta", clear

		drop if ba==1700
		g pre_id= 1 if datec<550
		gegen pres=sum(pre_id), by(mru)
			keep if pres>10
			keep if datec>580
		merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
			g dated_c=dofm(datec)
			g yearc=year(dated_c)
			drop dated_c
		g pTa = yearc-year_inst
		keep if pTa>=-3 & pTa<=3

	keep conacct year_inst yearc datec pTa
	save "${temp}conacct_pipe_shr.dta", replace



		odbc load, exec(" SELECT N.* FROM neighbor AS N WHERE rank<=10 ") dsn("phil") clear
			keep if rank==1 | rank==2 | rank==10
			merge m:1 conacct using "${temp}conacct_pipe_shr.dta", keep(3) nogen
			keep conacct conacctn rank distance
				foreach r in 1 2 10 {
					g long conacct_`r'_id  = conacctn if rank==`r'
					g distance_`r'_id = distance if rank==`r'
					gegen conacct_`r' 	= max(conacct_`r'_id), by(conacct)
					gegen distance_`r'  = max(distance_`r'_id), by(conacct)
					drop conacct_`r'_id distance_`r'_id 
				}
			drop rank conacctn
			gegen ctag=tag(conacct)
			keep if ctag==1
			drop ctag
			drop distance

			preserve 
				keep conacct conacct_1 conacct_2 conacct_10
				ren conacct conacct_0
				g nn=_n 
				reshape long conacct_, i(nn) j(newvar) 
				ren conacct conacct
				keep conacct
				duplicates drop conacct, force
				gentable nshr_2
			restore
		save "${temp}nshr_2.dta", replace



		local bill_query ""
		forvalues r = 1/12 {
			local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN (SELECT conacct FROM nshr_2) AS B ON A.conacct=B.conacct"
			if `r'!=12{
				local bill_query "`bill_query' UNION ALL"
			}
		}
		odbc load, exec("`bill_query'")  dsn("phil") clear  
		duplicates drop conacct date, force
		drop class
		save "${temp}nshr_bill.dta", replace



		use "${temp}nshr_2.dta", clear
			merge 1:m conacct using "${temp}nshr_bill.dta", keep(1 3) nogen
			drop if date==.
		tsset conacct date
		tsfill, full

		foreach v of varlist *_* {
			gegen `v'_m=max(`v'), by(conacct)
			drop `v'
			ren `v'_m `v'
		}


		ren conacct conacct_original
		ren c c_original

		foreach r in 1 2 10 {
			ren conacct_`r' conacct
			merge m:1 conacct date using "${temp}nshr_bill.dta", keep(1 3) nogen
			ren c c_`r'
			ren conacct conacct_`r'
		}

		ren conacct_original  conacct		
		merge m:1 conacct using "${temp}conacct_pipe_shr.dta", keep(3) nogen

		keep conacct date c_1 c_2 c_10 datec year_inst yearc pTa

		save "${temp}nshr_full.dta", replace





		*** DO NORMAL NEIGHBOR GEN! 

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
				* ren date_capex d1cap_original
			merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
				ren distance p2d_original
				ren year_inst p2yr_original
				ren pipe_id p2id_original
				* ren date_capex d2cap_original
			merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
				ren distance p3d_original
				ren year_inst p3yr_original
				ren pipe_id p3id_original
				* ren date_capex d3cap_original
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
								* ren date_capex d1cap_`r'
							merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
								ren distance p2d_`r'
								ren year_inst p2yr_`r'
								ren pipe_id p2id_`r'
								* ren date_capex d2cap_`r'
							merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
								ren distance p3d_`r'
								ren year_inst p3yr_`r'
								ren pipe_id p3id_`r'
								* ren date_capex d3cap_`r'
					ren conacct conacct_`r'
					ren c c_`r'
					ren class class_`r'
				}

		save "${temp}npaws_bill_full.dta", replace





		forvalues r = 1/12 {
			* local bill_query " SELECT A.conacct, AVG(A.c) as mc FROM billing_`r' AS A WHERE A.c<=100 AND A.date>=640 GROUP BY conacct"
			local bill_query " SELECT * FROM billing_`r' "
		odbc load, exec("`bill_query'")  dsn("phil") clear  

		gegen mc = mean(c), by(conacct)
		g clow=c if c<100
		gegen mclow = mean(clow), by(conacct)
		g clate = c if date>=640
		gegen mclate = mean(clate), by(conacct)
		g clowlate=c if date>=640 & c<100
		gegen mclowlate=mean(clowlate), by(conacct)
		g cnm_id =  c!=.
		gegen mcn=sum(cnm_id), by(conacct)
		g cnm_late_id = c!=. & date>=640
		gegen mcnlate=sum(cnm_late_id), by(conacct)

		g cres = c if class==1 
		gegen mcres=mean(cres), by(conacct)
		g cresmed=c if class==1 & c<200
		gegen mcresmed=mean(cresmed), by(conacct)
		g cmed = c if c<200
		gegen mcmed=mean(cmed), by(conacct)

		gegen tc=tag(conacct)
		keep if tc==1

		keep conacct mc mclow mclate mclowlate mcn mcnlate mcres mcresmed mcmed

		save "${temp}b_mc_`r'.dta", replace
		}

		use   "${temp}b_mc_1.dta", clear
		erase "${temp}b_mc_1.dta"
		forvalues r = 2/12 {
			append using "${temp}b_mc_`r'.dta"
			erase "${temp}b_mc_`r'.dta"
		}
		duplicates drop conacct, force
		save "${temp}b_mc.dta", replace		





		forvalues r = 1/12 {
			local bill_query " SELECT A.* FROM coll_`r' AS A"
		odbc load, exec("`bill_query'")  dsn("phil") clear 
		merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
		ren pay pay1
		replace pay1=. if pay1>10000
		gegen pay=mean(pay1), by(mru date)
		gegen pays=sum(pay1), by(mru date)
		g pay_id = pay1!=.
		gegen payc=sum(pay_id), by(mru date)
		gegen mt=tag(mru date)
		keep if mt==1
		drop mt
		keep mru date pay pays payc 
		save "${temp}pay_`r'.dta", replace
		}

		use   "${temp}pay_1.dta", clear
		erase "${temp}pay_1.dta"
		forvalues r = 2/12 {
			append using "${temp}pay_`r'.dta"
			erase "${temp}pay_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}pay.dta", replace		


*** DISCONNECTION BY MRU! 
		forvalues r = 1/12 {
			local bill_query " SELECT * FROM mcf_`r'"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
		merge m:1 conacct using "${temp}conacct_rate.dta"
			g o=1
			gegen dct = sum(o), by(mru date)
			gegen mt=tag(mru date)
			keep if mt==1
		keep date mru dct
		save "${temp}dcm_`r'.dta", replace
		}

		use   "${temp}dcm_1.dta", clear
		erase "${temp}dcm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}dcm_`r'.dta"
			erase "${temp}dcm_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}dcm.dta", replace	



*** DISCONNECTION BY MRU! 
		forvalues r = 1/12 {
			local bill_query " SELECT * FROM billing_`r' WHERE c>0 AND c<200"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
		merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
		keep if datec<=560
			g o=1
			gegen bm=sum(o), by(mru date)
			gegen mt=tag(mru date)
			keep if mt==1
		keep date mru bm
		save "${temp}billm_`r'.dta", replace
		}

		use   "${temp}billm_1.dta", clear
		erase "${temp}billm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}billm_`r'.dta"
			erase "${temp}billm_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}billm.dta", replace	




		forvalues r = 1/12 {
			* local r 1
			local bill_query " SELECT conacct, date FROM billing_`r' WHERE c>=0 AND c<500"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
		fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
			keep if datec<=580
			gegen dmax=max(date), by(conacct)
			keep if date==dmax
			keep if date<664

			g house=regexm(bus,"House")==1
			g bayan=regexm(bus,"Bayan")==1
			g o=1
			gegen ldc=sum(o), by(mru date)
			gegen ldb=sum(bayan), by(mru date)
			gegen ldh=sum(house), by(mru date)
			gegen mt=tag(mru date)
			keep if mt==1
		keep date mru ldc ldb ldh
		save "${temp}ldcm_`r'.dta", replace
		}

		use   "${temp}ldcm_1.dta", clear
		erase "${temp}ldcm_1.dta"
		forvalues r = 2/12 {
			append using "${temp}ldcm_`r'.dta"
			erase "${temp}ldcm_`r'.dta"
		}
		duplicates drop mru date, force
		save "${temp}ldcm.dta", replace	


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

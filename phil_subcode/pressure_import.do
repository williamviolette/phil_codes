* pressure_import.do


	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_primary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	* , I.contract_n 
	 * merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
		* drop contract_n
	save "${temp}dist_primary_points_conacct.dta", replace

	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_secondary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	* , I.contract_n 
	* merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
		* drop contract_n
	save "${temp}dist_secondary_points_conacct.dta", replace

	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_tertiary_points_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	* , I.contract_n
	* merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
		* drop contract_n
	save "${temp}dist_tertiary_points_conacct.dta", replace


	odbc load, exec("SELECT P.conacct, P.distance, I.year_inst, I.OGC_FID as pipe_id FROM pipe_tertiary_points_5m_dist AS P JOIN pipes AS I ON I.OGC_FID = P.OGC_FID")  dsn("phil") clear  
	destring year_inst, replace force
	* , I.contract_n
	* merge m:1 contract_n using "${temp}capex_date.dta", keep(1 3) nogen
		* drop contract_n
	save "${temp}dist_tertiary_points_5m_conacct.dta", replace







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






		**** MEASURE PIPE EXTERNALITIES ! ****

		* use "${temp}dist_tertiary_points_conacct.dta", clear
		* 	bys pipe_id: g PN=_N
		* 	bys pipe_id: g pn=_n
		* 	tab PN if pn==1
		* 	sum PN if 





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

		forvalues r=1/12 {
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










		* odbc load, exec(" SELECT N.* FROM neighborp_50 AS N ") dsn("phil") clear
		* 	ren conacct conacctn
		* 	ren conacctp conacct
		* 	ren distance distance_p

		* 	merge m:1 conacct using "${temp}dist_tertiary_points_5m_conacct.dta", keep(1 3) nogen 








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

			destring job, replace force
			ren class sclass
		keep date year conacct hhsize no_flow yes_flow flow_hrs barangay B S wave balde drum gallon sub single hhemp hho job age  sclass

			duplicates drop conacct date, force
		save "${temp}paws_aib.dta", replace

			duplicates drop conacct year, force
		save "${temp}paws_year_aib.dta", replace

		forvalues r=2008/2011 {
			g B_`r'_id = B==1 & year==`r'
			gegen B_`r'= max(B_`r'_id), by(conacct)
			drop B_`r'_id
		}
		gegen BM=max(B), by(conacct)
		duplicates drop conacct, force
		keep conacct BM B_*
		save "${temp}paws_year_B.dta", replace




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

	keep var4 var3 var5 var39 
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

	duplicates drop dma, force
	save "${temp}capex_dma_full.dta", replace



******** CHECK WHATS GOING ON! ********




use "${temp}mru_dma_link.dta", clear

	merge m:1 dma using  "${temp}capex_dma_full.dta", keep(1 3) nogen
	merge 1:m mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
	merge 1:m mru using "${temp}pipe_year_old_latest.dta", keep(1 3) nogen

	drop dma 

save "${temp}pipe_test.dta", replace





/* WORKS !!!




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


corr year_inst p3yr

cap prog drop et
prog def et
	cap drop pT
	g pT = year-`1'
	replace pT=1000 if pT>6 | pT<-6
	replace pT=pT+10

	areg cy i.pT i.year if yt==1, a(conacct) cluster(p3id) r
		coefplot, keep(*pT*) vertical ylabel(-4(1)4)
		graph export  "${temp}test_`1'.pdf", as(pdf) replace
end

et p3yr
et p2yr
et p1yr


cap prog drop tt
prog def tt
	cap drop post_`1'
	g post_`1' = year>=`1' & year<.
	areg cy post_`1' i.year if yt==1, a(conacct) cluster(p3id) r
end

tt p3yr
tt p2yr
tt p1yr







cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

areg cy i.pT i.year if yt==1 , a(conacct) cluster(mru) r
	coefplot, keep(*pT*) vertical



*** notes: 
* (1) actual date works the best
* (2) very correlated with capex year
* (3) capex year is more precise but smaller effects (consistent)
* (4) year_inst is sensitive to BIG replacements... figure why pipes wont work!?


use "${temp}bill_paws_full.dta", clear

replace c=. if c>100

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_test.dta", keep(1 3) nogen
merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

g year_inst_big = year_inst if shr>.75 & shr<=1

g year_combo = year_inst if year_inst>=2007 & year_inst<.
replace year_combo = capex_year if capex_year>=2007 & capex_year<. & year_combo==.

g year_combo_alt = capex_year if capex_year>=2007 & capex_year<.
replace year_combo_alt = year_inst if year_inst>=2007 & year_inst<. & year_combo_alt==.



cap prog drop et
prog def et
	cap drop pT
	g pT = year-`1'
	replace pT=1000 if pT>6 | pT<-6
	replace pT=pT+10

	areg cy i.pT i.year if yt==1, a(conacct) cluster(mru) r
		coefplot, keep(*pT*) vertical ylabel(-4(1)4)
		graph export  "${temp}test_`1'.pdf", as(pdf) replace
end


et year_combo_alt
et year_combo
et year_inst
et capex_year



cap prog drop tt
prog def tt
	cap drop post_`1'
	g post_`1' = year>=`1' & year<.
	areg cy post_`1' i.year if yt==1, a(conacct) cluster(mru) r
end

tt year_combo_alt
tt year_combo
tt year_inst
tt capex_year



* et year_inst_big

* et year_inst
* et year_inst_new
* et capex_year
* et year_d
* et year_c



cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

areg cy i.pT i.year if yt==1, a(conacct) 
	coefplot, keep(*pT*) vertical



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


cap drop T
g T = date-date_rs
replace T = 1000 if T<-36 | T>36
replace T = T+100

reg c i.T
coefplot, vertical keep(*T*)



areg c i.T i.date, a(conacct)
coefplot, vertical keep(*T*)






* tab  year_inst yr_d if year_inst>2000

* tab  year_inst capex_year if year_inst>2000
* corr year_inst capex_year if year_inst>2006
* corr year_inst yr_d if year_inst>2006








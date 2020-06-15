


*** SHARING TRENDS 










*** MRU TO BAR! 


*** PREP CENSUS 2010
foreach r in 1339 1375 13741 13742 13761 13762 {
* local r 1339
import delimited using census/input/2010/RT01_`r'.CSV, delimiter(",") clear
	g bar = prov*100000 + mun*1000 + bgy
	keep bar
	g o=1
	gegen pop10 = sum(o), by(bar)
	drop o
	duplicates drop bar, force
save "${temp}c10_`r'_pop.dta", replace 
}


use "${temp}c10_1339_pop.dta", clear
foreach r in 1375 13741 13742 13761 13762  {
	append using "${temp}c10_`r'_pop.dta"
}
save "${temp}c10_pop.dta", replace



**** PREP CENSUS 2015
global j = 1
foreach v in "R13_CITY OF LAS PIAS _PRV7601.DAT"  "R13_CALOOCAN CITY _PRV7501.DAT" "R13_CITY OF MAKATI _PRV7602.DAT" "R13_CITY OF MALABON_PRV7502.DAT" "R13_CITY OF MANDALUYONG _PRV7401.DAT" "R13_CITY OF MANILA_PRV39.DAT" "R13_CITY OF MARIKINA_PRV7402.DAT" "R13_CITY OF MUNTINLUPA_PRV7603.DAT" "R13_CITY OF NAVOTAS_PRV7503.DAT" "R13_CITY OF PARAAQUE_PRV7604.DAT" "R13_CITY OF PASIG _PRV7403.DAT" "R13_CITY OF SAN JUAN _PRV7405.DAT" "R13_CITY OF VALENZUELA _PRV7504.DAT" "R13_PASAY CITY _PRV7605.DAT" "R13_PATEROS_PRV7606.DAT" "R13_QUEZON CITY _PRV7404.DAT" "R13_TAGUIG CITY_PRV7607.DAT" {
	* local v "R13_CITY OF MANILA_PRV39.DAT"
	infix str rec 27-28 str b1 3-4 str b2 9-10 str b3 11-13   ///
	str age 36-37   str grade 45-47   str occ 53-54  /// 
	 using "/Users/williamviolette/Downloads/2015/puf/Microdatafile 2 (Provinces of Region 9 to 17)/`v'", clear
	keep if rec=="22"

	g bar = b1+b2+b3
	destring bar, replace force

	g o=1
	gegen pop=sum(o), by(bar)

	destring age grade occ, replace force

	g emp = occ!=9 & occ<99
	g prof_emp = occ>=11 & occ<=61
	g low_emp = occ>61 & occ<99

	g post_grad = grade>=800 & grade<.
	g college_grad = grade>=300 & grade<.
	g hs_grad = grade>=250 & grade<.

	foreach var of varlist post_grad college_grad hs_grad emp prof_emp low_emp   {
		replace `var'=. if age<=25
		ren `var' `var'_1
		gegen `var'=mean(`var'_1), by(bar)
		drop `var'_1
	}
	ren age age_1
	gegen age = mean(age_1), by(bar)
	keep bar pop age  post_grad college_grad hs_grad  emp prof_emp low_emp
	duplicates drop bar, force
	save "${temp}c15_${j}_demo_pers.dta", replace
	global j = $j +1
}

use "${temp}c15_1_demo_pers.dta", clear
forvalues r=2/17 {
	append using "${temp}c15_`r'_demo_pers.dta"
}
save "${temp}c15_demo_pers.dta", replace





	use "${temp}brgy_link.dta", clear
		ren id bar
		ren prikeyc254 prikey
			merge 1:m prikey using "${temp}bar_mru_int.dta", keep(3) nogen
		drop if int_area==0 | int_area==.

		g tiny_overlap = int_area/mru_area
		drop if tiny_overlap<=.01
		drop tiny_overlap

		merge m:1 mru using "${temp}mru_set.dta", keep(1 3)
			g mset=_merge==3
			drop _merge
			g mset_area_id=int_area if mset==1
			gegen mset_area=sum(mset_area_id), by(bar)
			g mset_shr = mset_area/bar_area
			keep if mset_shr>.9 & mset_shr<.
		drop mset mset_area_id mset_area mset_shr

		*** share of barangay area that intersects with mru
			gegen int_per_bar = sum(int_area), by(bar)
		*** share of total barangay intersection attributed to each mru
			g mru_weight      = int_area/int_per_bar
			g mru_weight_sum  = bar_area/int_per_bar
		*** share of mru that contributes to intersection area
			g mru_fraction    = int_area/mru_area

			gegen ba_s =max(ba), by(bar)
			drop ba
			ren ba_s ba

	save "${temp}mru_to_bar.dta", replace


	* year expand
	use "${temp}mru_to_bar.dta", clear
		g year=2008
		forvalues y=2009/2015 {
			append using "${temp}mru_to_bar.dta"
			replace year=`y' if year==.
		}
	save "${temp}mru_to_bar_year.dta", replace




		use "${data}paws/clean/full_sample_b_1.dta", clear
			destring shr_num_extra hhsize, replace force
			g sho = shr_num_extra
			g thh = hhsize
			replace thh= hhsize+sho if sho!=.
			replace thh=. if thh>45
			merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
				keep if thh!=.
				g o=1
				gegen ms=sum(o), by(mru)
				keep if ms>10
			keep mru
			duplicates drop mru, force
		save "${temp}mru_thh.dta", replace


		*** MAKE BRGY LINK WITH MRU! 
	use "${temp}brgy_link.dta", clear
		ren id bar
		ren prikeyc254 prikey
			merge 1:m prikey using "${temp}bar_mru_int.dta", keep(3) nogen
			drop if int_area==0 | int_area==.
			g tiny_overlap = int_area/mru_area
			drop if tiny_overlap<=.01
			drop tiny_overlap
		merge m:1 mru using "${temp}mru_thh.dta", keep(3)
		*** share of barangay area that intersects with mru
			gegen int_per_bar = sum(int_area), by(bar)
		*** share of total barangay intersection attributed to each mru
			g mru_weight      = int_area/int_per_bar
			g mru_weight_sum  = bar_area/int_per_bar
		*** share of mru that contributes to intersection area
			g mru_fraction    = int_area/mru_area
	save "${temp}mru_to_bar_thh.dta", replace


	use "${data}paws/clean/full_sample_b_1.dta", clear
			destring shr_num_extra hhsize, replace force
			g sho = shr_num_extra
			g thh = hhsize
			replace thh= hhsize+sho if sho!=.
			replace thh=. if thh>45
			merge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
				keep if thh!=.
				g o=1
				gegen ms=sum(o), by(mru)
				keep if ms>10

			ren thh thh1
			gegen thh=mean(thh1), by(mru)
			keep thh mru
			duplicates drop mru, force

		merge 1:m mru using "${temp}mru_to_bar_thh.dta", keep(3) nogen

		foreach var of varlist thh {
			ren `var' `var'temp
			g `var'_mru = `var'temp*mru_weight
			gegen `var'=sum(`var'_mru), by(bar)
			drop `var'temp `var'_mru
		}
		keep thh bar
		duplicates drop bar, force
	save "${temp}bar_thh.dta", replace

		

* use  "${temp}mru_house.dta", clear
* 	sum thh_mru, detail

*** COLLAPSE TO MRU/YEAR LEVEL

	use "${temp}activem.dta", clear

		g dated=dofm(date)
		g year=year(dated)
		drop dated date

		* foreach var of varlist  {
		* 	ren `var' `var'temp
		* 	gegen `var'=sum(`var'temp), by(mru year)
		* 	drop `var'temp
		* }

		foreach var of varlist cpanel cmean clow cread asum aressum csum csumlow {
			ren `var' `var'temp
			gegen `var'=mean(`var'temp), by(mru year)
			drop `var'temp
		}
		duplicates drop mru year, force

	save "${temp}activem_year.dta", replace




odbc load, exec("SELECT * FROM barangay")  dsn("phil") clear  
	keep prikey pop_2007
	destring prikey, replace force
save "${temp}pop_2007", replace


* use "${temp}c15_demo_pers.dta", clear
* use "${temp}c10_pop.dta", clear





	use "${temp}mru_to_bar_year.dta", clear

		merge m:1 mru year using "${temp}activem_year.dta", keep(3) nogen
			** WATCH THIS MERGE, THERE ARE ISSUES!!! (like new mrus...)
		foreach var in asum aressum csum csumlow {
			ren `var' `var'temp
			g `var'_mru = `var'temp*mru_fraction
			gegen `var'=sum(`var'_mru), by(bar year)
			replace `var' = `var'*mru_weight_sum
			drop `var'temp `var'_mru
		}

		foreach var of varlist cpanel cmean clow cread {
			ren `var' `var'temp
			g `var'_mru = `var'temp*mru_weight
			gegen `var'=sum(`var'_mru), by(bar year)
			drop `var'temp `var'_mru
		}

	duplicates drop bar year, force

	merge m:1 prikey using  "${temp}pop_2007", keep(3) nogen
	merge m:1 bar using "${temp}c15_demo_pers.dta", keep(3) nogen
	merge m:1 bar using "${temp}c10_pop.dta", keep(3) nogen
	merge m:1 bar using "${temp}bar_thh.dta", keep(1 3) nogen
	replace pop10 = pop10*5

	merge m:1 prikey using "${temp}brgy_pipe_key_date.dta", keep(1 3) nogen

	g pT = year-year_inst
	replace pT=1000 if pT>12 | pT<-6
	gegen min_pT=min(pT), by(mru)
	gegen max_pT=max(pT), by(mru)
	replace pT=pT+10
	replace pT=1 if pT==1010

	g post=pT>=10 & pT<.

	g ln_ares=log(aressum)


corr aressum pop

sum aressum if pop<5000
sum pop if pop<5000

g pop_aressum = pop/aressum

sum aressum if aressum<10000
sum pop if pop<10000


gegen thhm=mean(thh)

g atotm = aressum*thhm
g atotm_pop=atotm/pop

sum atotm_pop, detail

sum aressum, detail

	g atot=aressum*thh



	g atot_pop=atot/pop

	sum atot_pop, detail


	sum atot_pop if pop<5000, detail






	areg ln_ares post i.year, a(bar) cluster(bar) r

	xi: areg ln_ares post i.year*i.ba, a(bar) cluster(bar) r



	areg ln_ares i.pT i.year, a(bar)
		coefplot, vertical keep(*pT*)







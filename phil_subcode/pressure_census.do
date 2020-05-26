* pressure_census.do



cd /Users/williamviolette/Documents/Philippines/

import delimited using census/input/BARANGAY.csv, delimiter(",") clear
	ren brgyc254 name
	ren municipalic254 city
	replace name=lower(name)
	replace name=subinstr(name,".","",.)
*	replace name=subinstr(name,"village","",.)
	replace name=regexs(1) if regexm(name,"([0-9]+)-a")
	replace name=regexs(1) if regexm(name,"([0-9]+)a")

	replace name=subinstr(name,"st ","saint",.)	
	replace name=subinstr(name,"sta","santa",.)
	replace name=subinstr(name,"sto","santo",.)
	replace name=subinstr(name,"ñ","n",.)	
	replace name=subinstr(name,"(pob)","pob",.)
	replace name=subinstr(name,"alabang 1","alabang",.)
	replace name=subinstr(name,"daang hari","daanghari",.)
	replace name=subinstr(name,"north bay blvd, north","north bay",.)
	replace name=subinstr(name,"bf homes","b f homes",.)
	replace name=subinstr(name,"?","n",.)
	replace name=subinstr(name,"greater fairview","fairview",.)
	replace name=subinstr(name,"greater lagro 5","greater lagro",.)

	replace name=subinstr(name," (pasong putik)","",.)

	g calo=regexm(city,"TONDO")==1
	replace name=regexs(1) if regexm(name,"([0-9]+)") & calo==1
	drop calo	
	g calo=regexm(city,"CALO")==1
	replace name=regexs(1) if regexm(name,"([0-9]+)") & calo==1
	drop calo
	replace name=strtrim(name)
	
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY","",.)
	replace city=subinstr(city,"I / II","",.)
	replace city=subinstr(city,", MANILA","",.)
	replace city="SANTA CRUZ" if city=="STA CRUZ"
	replace city="PARA" if regexm(city,"PARA")==1
	replace city="LAS PINAS" if regexm(city,"LAS PI")==1
	replace city=strtrim(city)
	duplicates drop city name, force
save census/temp/barangay_TO_psgc.dta, replace
*

*

use census/input/psgc.dta, clear
	* cleaning
	g city=name if ruralurban==""
	replace city=city[_n-1] if city[_n]=="" & city[_n-1]!=""
	drop if ruralurban==""
	drop if regprovmunbgy>140000000
	replace name=lower(name)	
	replace name=subinstr(name,"barangay ","",.)
	replace name=subinstr(name,".","",.)
	replace name=strtrim(name)
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY","",.)
	replace city=subinstr(city,"I / II","",.)
	replace city=subinstr(city,", MANILA","",.)
	replace city="SANTA CRUZ" if city=="STA CRUZ"
	replace city="PARA" if regexm(city,"PARA")==1
	replace city="LAS PINAS" if regexm(city,"LAS PI")==1
	replace city=strtrim(city)
	replace name=subinstr(name,"kuatro","cuatro",.)
	replace name=subinstr(name,"(pob)","pob",.)
	replace name=subinstr(name,"ñ","n",.)	
	replace name=subinstr(name,"pilar village","pilar",.)	
	
		merge 1:1 city name using census/temp/barangay_TO_psgc.dta
		sort city name
		drop if city=="BACOOR" | city=="CAVITE" | city=="IMUS" | city=="KAWIT"
	*	browse if _merge!=3
		drop if _merge==1
		tab _merge
		keep if _merge==3
		drop _merge
	
		** VERY DECENT MERGE!! **
	g id=string(reg,"%20.0g")
	g reg=substr(id,1,2)
	g prov=substr(id,3,2)
	g mun=substr(id,5,2)
	g bgy=substr(id,7,3)
	destring prov, replace
	destring mun, replace
	destring bgy, replace
		merge 1:1 prov mun bgy using census/output/merged.dta
		keep if _merge==3
		drop _merge	
save census/output/brgy_link.dta, replace

use census/output/brgy_link.dta, clear
	keep id prikeyc254
	replace id = substr(id,3,.)
	destring id, replace force
save "${temp}brgy_link.dta", replace




	odbc load, exec("SELECT A.*, B.prikey FROM pipes_barangay_int AS A JOIN barangay AS B ON A.OGC_FID_bar=B.OGC_FID ")  dsn("phil") clear  

	destring prikey, replace force
	ren int_length length

	keep if pipe_class=="TERTIARY"
		egen total_bar=sum(length), by(prikey)

		destring year_inst, replace force
	keep if year_inst>2000
		egen ly=sum(length), by(prikey year_inst)
		egen max_l=max(ly), by(prikey)
		keep if ly==max_l
		g shr=max_l/total_bar
	*	keep if year_inst>=2008
		keep length year_inst prikey shr
		duplicates drop prikey, force

	save "${temp}brgy_pipe_key_date.dta", replace



*** THIS WORKS PRETTY WELL! *** 





global j = 1
foreach v in "R13_CITY OF LAS PIAS _PRV7601.DAT"  "R13_CALOOCAN CITY _PRV7501.DAT" "R13_CITY OF MAKATI _PRV7602.DAT" "R13_CITY OF MALABON_PRV7502.DAT" "R13_CITY OF MANDALUYONG _PRV7401.DAT" "R13_CITY OF MANILA_PRV39.DAT" "R13_CITY OF MARIKINA_PRV7402.DAT" "R13_CITY OF MUNTINLUPA_PRV7603.DAT" "R13_CITY OF NAVOTAS_PRV7503.DAT" "R13_CITY OF PARAAQUE_PRV7604.DAT" "R13_CITY OF PASIG _PRV7403.DAT" "R13_CITY OF SAN JUAN _PRV7405.DAT" "R13_CITY OF VALENZUELA _PRV7504.DAT" "R13_PASAY CITY _PRV7605.DAT" "R13_PATEROS_PRV7606.DAT" "R13_QUEZON CITY _PRV7404.DAT" "R13_TAGUIG CITY_PRV7607.DAT" {
	infix str rec 27-28 str b1 3-4 str b2 9-10 str b3 11-13 str waterdrink 34-35 str watercook 36-37  using "/Users/williamviolette/Downloads/2015/puf/Microdatafile 2 (Provinces of Region 9 to 17)/`v'", clear
	keep if rec=="23"
	g bar = b1+b2+b3
	destring bar, replace force
	destring waterdrink watercook, replace force
	tab waterdrink, g(wd15_)
	tab watercook, g(wc15_)
	foreach var of varlist wd15_* wc15_* {
		replace `var'=0 if `var'==.
		ren `var' `var'_1
		gegen `var'=sum(`var'_1), by(bar)
		drop `var'_1
	}
	keep bar wd15_* wc15_*
	duplicates drop bar, force
	save "${temp}c15_${j}.dta", replace
	global j = $j +1
}

use "${temp}c15_1.dta", clear
forvalues r=2/17 {
	append using "${temp}c15_`r'.dta"
}
save "${temp}c15.dta", replace



foreach r in 1339 1375 13741 13742 13761 13762 {
* local r 1375
import delimited using census/input/2010/RT02_`r'.CSV, delimiter(",") clear

	g bar = prov*100000 + mun*1000 + bgy
	destring sh3a_drink sh3b_cook sh3c_laundry, replace force
	tab sh3a_drink, g(wd15_)
	tab sh3b_cook, g(wc15_)
	tab sh3c_laundry, g(wl15_)
	foreach var of varlist wd15_* wc15_* wl15_* {
		replace `var'=0 if `var'==.
		ren `var' `var'_1
		gegen `var'=sum(`var'_1), by(bar)
		drop `var'_1
	}
	keep bar wd15_* wc15_* wl15_*
	duplicates drop bar, force
save "${temp}c10_`r'.dta", replace 
}


use "${temp}c10_1339.dta", clear
foreach r in 1375 13741 13742 13761 13762  {
	append using "${temp}c10_`r'.dta"
}
save "${temp}c10.dta", replace



use "${temp}c15.dta", clear
	
	g year=2015
	append using "${temp}c10.dta"
	replace year=2010 if year==.	
	ren *15_* *_*
	ren bar id
	merge m:1 id using "${temp}brgy_link.dta", keep(1 3) nogen
	ren id bar
	ren prikeyc254 prikey
	merge m:1 prikey using "${temp}brgy_pipe_key_date.dta", keep(1 3) nogen

save "${temp}c_analysis.dta", replace




use "${temp}c_analysis.dta", clear

g bst=string(bar,"%12.0g")
g city=substr(bst,1,4)
destring city, replace force

egen dtot=rowtotal(wd_*)
egen ctot=rowtotal(wc_*)
egen ltot=rowtotal(wl_*)
g pd = (wd_1+wd_2)/dtot
g pc = (wc_1+wc_2)/ctot
g pl = (wl_1+wl_2)/ltot
g pd1 = (wd_1)/dtot
g pc1 = (wc_1)/ctot

foreach r in d c  {
	g o`r' = (w`r'_3+w`r'_4+w`r'_5+w`r'_6+w`r'_7+w`r'_8+w`r'_9+w`r'_10+w`r'_12)/`r'tot
	replace o`r'=0 if o`r'==.
}


g pdb = wd_11/dtot
g pcb = wc_11/ctot
replace pdb=0 if pdb==.
replace pcb=0 if pcb==.


g post = year_inst>=2010 & year_inst<2015 & year==2015

gegen mm=max(post), by(bar)

g just_before = year_inst<2010 & year_inst>2000

* areg pc just_before if year==2010, a(city)



* areg pd post , a(bar) cluster(bar)

g pc10_id = pc if year==2010
gegen pc10=max(pc10_id), by(bar)
g oc10_id = oc if year==2010
gegen oc10=max(oc10_id), by(bar)

sum pc if year==2010
sum pc if year==2015

sum pc if year==2010 & mm==1
sum pc if year==2015 & mm==1


sum pc if year==2010 & pc10<1
sum pc if year==2015 & pc10<1

sum pc if year==2010 & mm==1 & pc10<1
sum pc if year==2015 & mm==1 & pc10<1


areg oc post i.year, a(bar) cluster(bar)
areg oc10 post i.year if oc10>0, a(bar) cluster(bar)


areg pc post i.year, a(bar) cluster(bar)
areg pc post i.year if pc10<1,  a(bar) cluster(bar)


areg ctot post i.year, a(bar) cluster(bar)
areg ctot post i.year, a(bar) cluster(bar)
areg ctot post i.year if pc10<.8, a(bar) cluster(bar)
areg ctot post i.year if pc10<.95, a(bar) cluster(bar)

areg ln_ctot post i.year if pc10<.9, a(bar) cluster(bar)




areg oc post i.year, a(bar) cluster(bar)


areg pc post i.year, a(bar) cluster(bar)

areg pd post i.year, a(bar) cluster(bar)
areg pdb post i.year, a(bar) cluster(bar)
areg pdb post i.year if pdb>0, a(bar) cluster(bar)



areg pc post i.year if pc10<.99, a(bar) cluster(bar)
areg pd post i.year if pc10<.99, a(bar) cluster(bar)




areg pc1 post i.year, a(bar) cluster(bar)


areg pc post i.year if pc10<.96, a(bar) cluster(bar)





* 2010
* 01 Own use, faucet community water system
* 02 Shared, faucet community water system
* 03 Own use, tubed/piped deep well (at least 100ft/30m deep)
* 04 Shared, tubed/piped deep well
* 05 Tubed/piped shallow well
* 06 Dug well
* 07 Protected spring
* 08 Unprotected spring
* 09 Lake, river, rain, and others
* 10 Peddler
* 11 Bottled water
* 12 Others, SPECIFY ___

* 2015
* Source of Water Supply for Cooking
* 01 – Own Use Faucet, Community Water System 
* 02 – Shared Faucet, Community Water System
* 03 – Own Use, Tubed/Piped Deep Well
* 04 – Shared, Tubed/Piped Deep Well
* 05 – Tubed/Piped Shallow Well
* 06 – Dug Well
* 07 – Protected Spring
* 08 – Unprotected Spring
* 09 – Lake, River, and Rain
* 10 – Peddler
* 11 – Bottled Water
* 12 – Others
* 99 – Not Reported




/*
* infix str bar 5-13 str hhrel 33-34 str sex 35 house 29 str housemat 30 str waterdrink 34-35 str watercook 36-37 str tenure 38 using "/Users/williamviolette/Downloads/2015/puf/Microdatafile 2 (Provinces of Region 9 to 17)/`v'", clear




infix str rec 27-28 str bar1 5-8 str bar2 11-13 str hhrel 33-34 str sex 35 house 29 str housemat 30 str waterdrink 34-35 str watercook 36-37 str tenure 38 using "/Users/williamviolette/Downloads/2015/puf/Microdatafile 2 (Provinces of Region 9 to 17)/R13_PASAY CITY _PRV7605.DAT", clear
keep if rec=="23"
g bar=bar1+bar2
destring bar, replace force





** input : census data
** output: savings/temp/RT02_merged.dta

foreach r in 1339 1375 13741 13742 13761 13762 {
  * local r "13762"
import delimited using "${censusdata}RT01_`r'.CSV", delimiter(",") clear
	egen age=max(cp5_age), by(region prov mun bgy hsnb)
	bys region prov mun bgy hsnb: g hhsize=_N
		replace s15ap20_occ="-1" if s15ap20_occ=="    "
		g occ=substr(s15ap20_occ,1,1)
		destring occ, replace force
		g emp=occ!=. & occ!=0
		egen hhemp=sum(emp), by(region prov mun bgy hsnb)
		replace hhemp=. if hhemp>12
		egen occupation=max(occ), by(region prov mun bgy hsnb)
	
		g move_id=h05ap14m_5yrsago!="" & h05ap14m_5yrsago!="00"
		egen move_id1=mean(move_id), by(region prov mun bgy hsnb)
		g move=move_id1>.5 & move_id1<.
		
	keep region prov mun bgy hsnb age hhemp occupation move
	duplicates drop region prov mun bgy hsnb, force

save "${temp}RT01_`r'_prep.dta", replace

 * local r "13762"
import delimited using "${censusdata}RT02_`r'.CSV", delimiter(",") clear

	ren hsize hhsize	
	destring hhsize, replace force
	keep region prov mun bgy hsnb hhsize sh3a_drink sh3b_cook sh3c_laundry hb1_bldg
	duplicates drop region prov mun bgy hsnb, force
	
		merge 1:1 region prov mun bgy hsnb using "${temp}RT01_`r'_prep.dta"
		keep if _merge==3
		drop _merge		
	
save "${temp}RT02_`r'_prep.dta", replace 
}

use "${temp}RT02_1339_prep.dta", clear
foreach r in 1375 13741 13742 13761 13762 {
append using "${temp}RT02_`r'_prep.dta"
}

		g barangay_id	=prov*100000+mun*1000+bgy
		g alt			=sh3c_laundry>2 & sh3c_laundry<.
		g house_1		=hb1_bldg==3
		g house_2       =hb1_bldg==1
		g low_skill     = (occupation>=6 & occupation<=8)
		replace age = 100 if age>100
		g conacct=_n
		keep barangay_id alt house_1 house_2 age hhemp hhsize conacct low_skill move sh3c_laundry
		

odbc exec("DROP TABLE IF EXISTS census;"), dsn("phil")
odbc insert, table("census") dsn("phil") create
odbc exec("CREATE INDEX census_conacct_ind ON census (conacct);"), dsn("phil")

*	save savings/temp/census_prep.dta, replace
		
foreach r in 1339 1375 13741 13742 13761 13762 {
erase "${temp}RT01_`r'_prep.dta"
erase "${temp}RT02_`r'_prep.dta"
}
		
		

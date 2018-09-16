
* input :
*  - DTA cbms 05 08 11
*  - TABLE paws
* output :
*  - TABLE paws_inc



** prep CBMS	
	**** 2005

	use "${cbmsdata}2005/pasay_hh_fin.dta", clear
	duplicates drop hcn, force
	merge 1:m hcn using "${cbmsdata}2005/pasay_mem_fin.dta"

	ren age age_yr
	egen age=max(age_yr), by(hcn)
		keep hcn totin hsize htype jobind g_occ age
	g water_price=.
	ren hsize hhsize
	g J=jobind==1
	egen hhemp=sum(J), by(hcn)
	g house="single" if htype==1
		replace house="duplex" if htype==2
		replace house="apartment" if htype==3
		replace house="other" if house==""
	g low_skill=g_occ==9
	replace totin=totin/12
	drop if totin<1000 | totin>60000
	*hist totin
	g wave=3
	keep hcn totin house low_skill hhemp hhsize wave water_price age
		duplicates drop hcn, force
		drop if hhsize>12
		drop if hhemp>8
	save "${temp}cbms_inc_2005.dta", replace

	**** 2008

	use "${cbmsdata}2008/pasay_hhfinal08.dta", clear
	duplicates drop hcn, force
	merge 1:m hcn using "${cbmsdata}2008/pasay_memfinal08.dta"

	egen age=max(age_yr), by(hcn)
		keep hcn totin hsize kind_house jobind g_occ water_price age
	replace water_price=. if water_price==0
	replace water_price=     water_price/100
	* hist water_price if water_price<2000
	ren hsize hhsize
		g J=jobind==1
	egen hhemp=sum(J), by(hcn)
		ren kind_house house_type
	g house="single" if house_type==1
		replace house="duplex" if house_type==2
		replace house="apartment" if house_type==3
		replace house="other" if house==""
	g low_skill=g_occ==9
	replace totin=totin/12
	drop if totin<1000 | totin>60000
	*hist totin
	g wave=4
	keep hcn totin house low_skill hhemp hhsize wave water_price age
		duplicates drop hcn, force
	*	drop hcn
		drop if hhsize>12
		drop if hhemp>8
	save "${temp}cbms_inc_2008.dta", replace
	
	**** 2011

	use "${cbmsdata}2011/pasay_final2011_hh.dta", clear
	duplicates drop hcn, force
	merge 1:m hcn using "${cbmsdata}2011/pasay_final2011_mem.dta"

	ren water water_facility
	egen age=max(age_yr), by(hcn)
		keep hcn totin hsize house_type jobind g_occ source_water water_facility ave_water age
	replace ave_water=. if ave_water>2000 | ave_water<20
	ren ave_water water_price
	ren hsize hhsize
	g house="single" if house_type==1
		replace house="duplex" if house_type==2
		replace house="apartment" if house_type==3
		replace house="other" if house==""
	g J=jobind==1
	egen hhemp=sum(J), by(hcn)
	g low_skill=g_occ==9
	replace totin=totin/12
	drop if totin<1000 | totin>60000
	*hist totin
		g wave=5
		keep hcn totin house low_skill hhemp hhsize wave source_water water_facility water_price age
		duplicates drop hcn, force
		drop if hhsize>12
		drop if hhemp>8
	append using "${temp}cbms_inc_2005.dta"
	append using "${temp}cbms_inc_2008.dta"
			drop if age==.
	g house_1 = house=="apartment"
	g house_2 = house=="single"
	drop house

	save "${temp}cbms_inc.dta", replace
	

** IMPUTATE INCOME
odbc load, table("paws") clear dsn("phil")
		g paws = 1
		append using "${temp}cbms_inc.dta"	
			replace age=100 if age>100
		qui xi: reg totin i.hhsize*i.hhemp i.low_skill*i.house_1 i.low_skill*i.house_2 i.hhsize*i.low_skill i.low_skill*i.hhemp i.hhsize*age i.low_skill*age i.wave
		predict INC, xb
		keep if paws==1
		keep conacct INC
		duplicates drop conacct, force
		drop if conacct==.
save "${temp}paws_inc.dta", replace

odbc exec("DROP TABLE IF EXISTS paws_inc;"), dsn("phil")
odbc insert, table("paws_inc") dsn("phil") create
odbc exec("CREATE INDEX paws_inc_conacct_ind ON paws_inc (conacct);"), dsn("phil")


	rm "${temp}cbms_inc_2008.dta"
	rm "${temp}cbms_inc_2005.dta"
	rm "${temp}cbms_inc.dta"


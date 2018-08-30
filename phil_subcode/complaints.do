
** input: cc data
** output: table cc
	 
	 
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
	
	g ugl_r=regexm(resolution,"ugl")==1
		replace ugl_r=0 if regexm(resolution," no ")==1
	g leak_r=regexm(resolution,"leak")==1
		replace leak_r=0 if regexm(resolution," no ")==1
		replace leak_r=0 if regexm(class,"WAAV")==1
	g ugl_i=regexm(issue,"ugl")==1
		replace ugl_i=0 if regexm(issue,"no ugl")==1
	g leak_i=regexm(issue,"leak")==1
		replace leak_i=0 if regexm(issue,"no leak")==1
		replace leak_i=0 if regexm(class,"WAAV")==1

    g break_i = ( regexm(issue,"break")==1 | regexm(issue,"damage")==1 ) & regexm(issue,"pipe")==1
		replace break_i=0 if regexm(class,"WAAV")==1
    g break_r = ( regexm(resolution,"break")==1 | regexm(resolution,"damage")==1 ) & regexm(resolution,"pipe")==1
		replace break_r=0 if regexm(class,"WAAV")==1
		
	g vertical_r=regexm(resolution,"vertical")==1
	g vertical_i = regexm(issue,"vertical")==1

		g LEAK_OLD=(ugl_r==1 | leak_r==1 | ugl_i==1 | leak_i==1)
		g VERTICAL=(vertical_r==1 | vertical_i==1)
		g BILL=regexm(resolution,"excessive")==1 | regexm(issue,"excessive")==1 | typecode=="B0001" | regexm(type,"excessive")==1 | regexm(title,"excessive")==1  

	g LEAK=(ugl_r==1 | leak_r==1 | ugl_i==1 | leak_i==1 | break_i==1 | break_r==1 | vertical_r==1 | vertical_i==1)
	
		* browse if LEAK==1
		* browse if regexm(resolution,"downgrade")==1
		* browse if regexm(issue,"neighbor")==1
		* browse if regexm(issue,"fetch")==1
		* browse if regexm(resolution,"fetch")==1
		* browse if regexm(resolution,"famil")==1
		
		g neigh=regexm(issue,"neigh")==1
		g nei_reso=regexm(resolution,"neigh")==1 
		
		*tab neigh LEAK
		*browse if nei_reso==1 & LEAK==1
			
	drop resolution issue
	destring year month, force replace

	g date = ym(year,month)

	keep conacct date ugl* leak* break* LEAK LEAK_OLD VERTICAL BILL
	
	*** *** *** *** *** *** *** *** *** *** ***
	***** HERE IS THE KEY KEEP CONDITION! *****
	*** *** *** *** *** *** *** *** *** *** ***

	*keep if LEAK==1 

	*** THIS DEALS WITH EXCESSIVE BILLING COMPLAINTS TOO
	keep if LEAK_OLD==1 | VERTICAL==1 | BILL==1
	
	sort conacct date
	by conacct: g id=_n
	by conacct: g idN=_N
	keep if id==idN
	drop id idN
		** quite a few repeat complaints unfortunately ... 

** PUT INTO A TABLE !!

	odbc exec("DROP TABLE IF EXISTS cc;"), dsn("phil")
	odbc insert, table("cc") dsn("phil") create
	odbc exec("CREATE INDEX cc_conacct_ind ON cc (conacct);"), dsn("phil")


odbc load, exec("SELECT * FROM cc") clear


***  checks out, exactly the same sample  ***

*use "${phil_folder}non_payment_exploration/temp/full_cc.dta", clear
*	keep if LEAK==1 | VERTICAL==1 | BILL==1
*	duplicates drop conacct, force	
* 72,158

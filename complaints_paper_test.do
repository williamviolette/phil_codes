
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
	*	drop if conacct==.

	replace type=var24 if type=="" & var24!=""
	replace type=lower(type)
	replace title=lower(title)


	g mn = regexs(1) if regexm(createdon,"^([0-9]+)")
	destring mn, replace force
	replace mn = . if mn>12

	g d = regexs(1) if regexm(createdon,"^[0-9]+/([0-9]+)")
	destring d, replace force

	g date = ym(year,month)

	g D = mdy(mn,d,year)

	format D %td


preserve
	keep if class=="MMRR"

	bys D: g DDN=_N
	bys D: g ddn=_n

	scatter DDN D if ddn==1 & ((year==2015 & mn<12) | year==2014 & mn>2) & DDN<1000
restore



preserve
	keep if class=="BILL"
	drop if aging>10 | aging<0
	egen am=mean(aging), by(D)
	bys D: g ddn=_n

	scatter am D if ddn==1 & ((year==2015 & mn<12) | year==2014 & mn>2) 
restore




format date %tm


bys date: g dN=_N
bys date: g dn=_n


scatter dN date if dn==1




/*
	keep type class conacct year month resolution issue typecode title
	replace resolution=lower(resolution)
	replace issue=lower(issue)
	format resol %100s
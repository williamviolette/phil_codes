


cap program drop load_data
prog define load_data
	odbc exec("DROP TABLE IF EXISTS bill_neg_`1';"), dsn("phil")
	odbc exec("CREATE TABLE bill_neg_`1' ( conacct INTEGER, date INTEGER, prev INTEGER, pres INTEGER, class INTEGER, days INTEGER, read INTEGER);"), dsn("phil")
	* local 2 "pasay"
	use "${billingdata}`2'_billing_2008_2015.dta", clear 
		ren CONTRACT_A conacct
		drop if conacct == .
		keep PREV PRES month year conacct NO_OF_DAYS readtag billclass
		destring billclass, replace force
		ren billclass class
		ren NO_OF_DAYS days
		destring PREV PRES days, replace force
		ren PREV prev
		ren PRES pres
		destring month year , replace force
		g date = ym(year,month)
		drop year month
		g read = regexm(readtag,"ACT")==1
		keep conacct date prev pres class days read
		order conacct date prev pres class days read
		duplicates drop conacct date, force

	odbc insert, table("bill_neg_`1'") dsn("phil")
	*odbc exec("DELETE FROM billing_`1' WHERE ROWID NOT IN (SELECT min(ROWID) FROM billing_`1' GROUP BY conacct, date);"), dsn("phil")
end

*
load_data 1 tondo 
load_data 2 pasay 
load_data 3 val 
load_data 4 qc_09 
load_data 5 qc_12 
load_data 6 samp 
load_data 7 qc_04 
load_data 8 bacoor 
load_data 9 so_cal 
load_data 10 cal_1000 
load_data 11 muntin 
load_data 12 para
*

cap program drop addindex
prog define addindex
	odbc exec("CREATE INDEX bill_neg_`1'_c_ind ON bill_neg_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX bill_neg_`1'_d_ind ON bill_neg_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex `r'
}




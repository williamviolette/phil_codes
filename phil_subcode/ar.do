




cap program drop load_data_ar
prog define load_data_ar
	odbc exec("DROP TABLE IF EXISTS ar_`1';"), dsn("phil")
	odbc exec("CREATE TABLE ar_`1' ( conacct INTEGER, date INTEGER, ar INTEGER );"), dsn("phil")

	use "${billingdata}`2'_ar_2009_2015.dta", clear 
		keep conacct year month bucket
			drop if conacct == .
			drop if year=="2009"
		g ar =regexs(1) if regexm(bucket,"(^[0-9]+)")
			drop bucket
			drop if ar==""
		destring ar, replace force
		sort conacct year month ar
			by conacct year month: g id1=_n
			by conacct year month: g id2=_N
			keep if id1==id2
			drop id1 id2
		destring ar month year, replace force
		g date = ym(year,month)
			drop year month
		order conacct date ar

	odbc insert, table("ar_`1'") dsn("phil")
end


load_data_ar 1 tondo 
load_data_ar 2 pasay 
load_data_ar 3 val 
load_data_ar 4 qc_09 
load_data_ar 5 qc_12 
load_data_ar 6 samp 
load_data_ar 7 qc_04 
load_data_ar 8 bacoor 
load_data_ar 9 so_cal 
load_data_ar 10 cal_1000 
load_data_ar 11 muntin 
load_data_ar 12 para


cap program drop addindex_gen
prog define addindex_gen
	odbc exec("CREATE INDEX `2'_`1'_conacct_ind ON `2'_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX `2'_`1'_date_ind ON `2'_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex_gen `r' "ar"
}




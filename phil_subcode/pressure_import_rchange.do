* pressure_import.do





		forvalues r = 1/12 {
		 * local r 1
			local bill_query " SELECT A.*  FROM billing_`r' AS A"
		odbc load, exec("`bill_query'")  dsn("phil") clear  
				
			gegen class_max=max(class), by(conacct)
			gegen class_min=min(class), by(conacct)
			keep if class_max!=class_min

		save "${temp}bill_rc_`r'.dta", replace
		}

		use   "${temp}bill_rc_1.dta", clear
		erase "${temp}bill_rc_1.dta"
		forvalues r = 2/12 {
			append using "${temp}bill_rc_`r'.dta"
			erase "${temp}bill_rc_`r'.dta"
		}
		duplicates drop conacct date, force
		save "${temp}bill_rc.dta", replace	




	local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query' 	SELECT A.* FROM bill_neg_`r' AS A JOIN (SELECT DISTINCT conacct FROM paws) AS B ON A.conacct = B.conacct"
		if `r'!=12 {
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  

	duplicates drop conacct date, force
	save "${temp}bill_neg_paws_full.dta", replace






* prog define data_prep

* 	local 1 pasay
* 		use /Users/williamviolette/Documents/Philippines/descriptives/output/`1'_billing_2008_2015.dta, clear
* 		use /Users/williamviolette/Documents/Philippines/descriptives/output/`1'_billing_2008_mrnote.dta, clear
		
* 			ren CONTRACT_A conacct
* 			keep conacct PREV PRES volume billclass year month readtag 
* 			destring PREV PRES billclass year month, replace force
* 			g date=ym(year,month)
* 			drop year month

* 			g c=PRES-PREV
* 			replace c=. if c<0 | c>200
			
* 			keep conacct date c billclass

* 			gegen bc_max=max(billclass), by(conacct)
* 			gegen bc_min=min(billclass), by(conacct)
* 			keep if bc_max!=bc_min
		
* 		save "${temp}`1'_rate_change.dta", replace
* end
	
* foreach v in bacoor muntin tondo pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para {
* 	data_prep `v'
* }
	
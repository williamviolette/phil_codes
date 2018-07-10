* improve_meter_accounts

local run_here "0"
local run_meterseri_prep "0"

if "`run_here'"=="0" {
	do "phil_subcode/setmacros.do"
}
else {
	do "setmacros.do"	
}


cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end


if "`run_meterseri_prep'" == "1" {

	odbc load, exec("SELECT OGC_FID, meter_seri FROM meter") clear  dsn("phil")
	drop if length(meter_seri)<=1

	replace meter_seri = subinstr(meter_seri,"-","",.)
	replace meter_seri = strtrim(meter_seri)
		duplicates tag meter_seri, g(D)
		tab D
		drop if D>0
		drop D
	save "${temp}meterseri.dta", replace


	cap program drop merge_to_mcf
	prog define merge_to_mcf
		use "${billingdata}`1'_mcf_2009_2015.dta", clear
		keep conacct DEVICE_NB
			ren DEVICE_NB meter_seri
		replace meter_seri = subinstr(meter_seri,"-","",.)
		replace meter_seri = strtrim(meter_seri)
		sort conacct meter_seri
			bys conacct meter_seri: g nn=_n==1
			keep if nn==1
			drop nn
		duplicates tag meter_seri, g(D)
			tab D
			drop if D>0
			drop D
		merge 1:1 meter_seri using "${temp}meterseri.dta", keep(2 3) nogen
		duplicates tag conacct, g(D)
			tab D
			drop if D>0	& conacct!=.
			drop D
		save "${temp}meterseri.dta", replace
	end


	foreach v in tondo pasay val qc_09 qc_12 samp qc_04 bacoor so_cal cal_1000 muntin para {
	merge_to_mcf `v'
	}
	drop if conacct==.

	save "${temp}meterseri.dta", replace
}



odbc load, exec("SELECT OGC_FID, meter_seri, account_no AS conacctm FROM meter") clear  dsn("phil")
destring conacctm, replace force

	replace meter_seri = subinstr(meter_seri,"-","",.)
	replace meter_seri = strtrim(meter_seri)
merge m:1 meter_seri using "${temp}meterseri.dta", keep(1 3) nogen

g conacct_total = conacctm
replace conacct_total = conacct if (conacctm==. | conacctm==0) & conacct!=.
	duplicates tag conacct_total, g(D)
	replace conacct_total = 0 if conacctm!=conacct & D>0
	drop D

** 1) some accounts have two meters
** 2) sometimes the meter serial number is not unique to accounts (get rid of these)

sort OGC_FID
keep OGC_FID conacct_total
ren conacct_total conacct
replace conacct=0 if conacct==.

** This part generates the conacctseri table!
gentable conacctseri
odbc exec("CREATE INDEX seri_ogc_ind ON conacctseri (OGC_FID);"), dsn("phil")


*************************************
** this runs for the meter table!! **
	odbc exec("CREATE INDEX meter_ogc_ind ON meter (OGC_FID);"), dsn("phil")
*************************************

if "`run_here'"=="0" {
exit, STATA clear
}


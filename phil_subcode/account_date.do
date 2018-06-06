
* input : database/clean/mcf/..
* output : TABLE date_c

use  "${database}clean/mcf/2015/0200_052015_1.dta", clear	
		foreach r in 0200 0300 0400 0500 0600 0700 0800 0900 1000 1100 1200 1700 {
		append using  "${database}clean/mcf/2015/`r'_052015_1.dta"
		}
	drop if Col3=="Row Count"
	rename Col12 conacct
	rename Col19 acctcreat
	keep conacct acctcreat
	g yr=substr(acctcreat,1,4)
	g mn=substr(acctcreat,6,2)
	destring yr mn, replace force
	g date_c=ym(yr,mn)
	keep date_c conacct
	destring conacct, replace force
	duplicates drop conacct, force
	drop if conacct==.
save "${temp}mcf_2015_date_c.dta", replace

use "${database}clean/mcf/2012/mcf_122012.dta", clear
	g yr=substr(acctcreat,-4,4)
	g mn=substr(acctcreat,1,2)
	destring yr mn, replace force
	g date_c=ym(yr,mn)
	keep date_c conacct
	drop if conacct==.
save "${temp}mcf_2012_date_c.dta", replace
	
use "${temp}mcf_2015_date_c.dta", clear
	keep conacct date_c
	append using "${temp}mcf_2012_date_c.dta"
	duplicates drop conacct, force

odbc exec("DROP TABLE IF EXISTS date_c;"), dsn("phil")
odbc insert, table("date_c") dsn("phil") create

rm "${temp}mcf_2012_date_c.dta"
rm "${temp}mcf_2015_date_c.dta"


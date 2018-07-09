
** outline : 1) identify leak disconnects , 2) get their neighbors , 3) do the analysis


* 1) identify leak disconnects


* odbc sqlfile("leaks_test_sql"),  dsn("phil")


#delimit;

cap program drop leak_data;
program define leak_data;
	odbc load, exec(
	"SELECT A.*, B.date AS date_l, C.date_c	
	FROM billing_`1' AS A JOIN cc AS B ON A.conacct = B.conacct
	LEFT JOIN date_c AS C ON A.conacct = C.conacct
	;"
	)  dsn("phil")	clear;
	tsset conacct date;
	tsfill, full;
		foreach var of varlist date_l class date_c {;
			egen `var'_m = max(`var'), by(conacct);
			replace `var'=`var'_m;
			drop `var'_m;
		};
	save "${temp}L_bill_`1'.dta", replace;

	odbc load, exec(
	"SELECT A.*, B.date AS date_l 
	FROM ar_`1' AS A JOIN cc AS B ON A.conacct = B.conacct;"
	)  dsn("phil")	clear;
	save "${temp}L_ar_`1'.dta", replace;

	use "${temp}L_bill_`1'.dta", clear;
	merge 1:1 conacct date using "${temp}L_ar_`1'.dta";
	ren _merge M;
	save "${temp}L_`1'.dta", replace;
	erase "${temp}L_bill_`1'.dta";
	erase "${temp}L_ar_`1'.dta";
end;

leak_data 1;
leak_data 2;
leak_data 3;

#delimit cr






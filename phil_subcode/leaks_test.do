
** outline : 1) identify leak disconnects , 2) get their neighbors , 3) do the analysis


* 1) identify leak disconnects


* odbc sqlfile("leaks_test_sql"),  dsn("phil")


#delimit;

cap program drop leak_data;
program define leak_data;
	odbc load, exec(
	"SELECT A.*, B.date AS date_l	FROM billing_`1' AS A JOIN cc AS B ON A.conacct = B.conacct;"
	)  dsn("phil")	clear;
	tsset conacct date;
	tsfill, full;
		foreach var of varlist date_l class {;
			egen `var'_m = max(`var'), by(conacct);
			replace `var'=`var'_m;
			drop `var'_m;
		};
	save "${temp}L_bill_`1'.dta", replace;

	odbc load, exec(
	"SELECT A.*, B.date AS date_l FROM ar_`1' AS A JOIN cc AS B ON A.conacct = B.conacct;"
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




/*;

cap program drop leak_data;
program define leak_data;
	odbc load, exec(
	"
	SELECT A.date, A.conacct,  A.date_l, B.ar AS ar, A.c, A.class, A.read
		FROM 
			(
			SELECT J.*, cc.date AS date_l FROM billing_`1' 
				AS J JOIN cc ON J.conacct = cc.conacct 
			) AS A  
		LEFT JOIN 
			(
			SELECT K.ar, K.date, K.conacct FROM ar_`1' 
				AS K JOIN cc ON K.conacct = cc.conacct 
			) AS B
		ON A.conacct = B.conacct AND A.date = B.date 

	UNION

	SELECT B.date, B.conacct,  B.date_l, B.ar AS ar, A.c, A.class, A.read
	  
		FROM 
			(
			SELECT K.ar, K.date, K.conacct, cc.date AS date_l FROM ar_`1' 
				AS K JOIN cc ON K.conacct = cc.conacct 
			) AS B
		LEFT JOIN 
			(
			SELECT J.* FROM billing_`1' 
				AS J JOIN cc ON J.conacct = cc.conacct 
			) AS A
		ON A.conacct = B.conacct AND A.date = B.date 

		;"
	)  dsn("phil")	clear;

	tsset conacct date;
	tsfill, full;

	foreach var of varlist date_l class {;
	egen `var'_m = max(`var'), by(conacct);
	replace `var'=`var'_m;
	drop `var'_m;
	};

	save "${temp}L_`1'.dta", replace;
end;

leak_data 1;
leak_data 2;
leak_data 3;



* odbc load, exec(
"SELECT A.*, B.ar AS ar
	FROM billing_1 AS A  
	LEFT JOIN ar_1 AS B 
	ON A.conacct = B.conacct AND A.date = B.date 

		UNION ALL 

SELECT C.*, D.ar AS ar
	FROM ar_1 AS D 
	LEFT JOIN billing_1 AS C  
	ON C.conacct = D.conacct AND C.date = D.date 
	;"
)  dsn("phil")	clear;


*odbc load, exec(
*"SELECT A.*, B.date AS date_l FROM billing_1 AS A JOIN cc AS B ON A.conacct = B.conacct;"
*)  dsn("phil")	clear;






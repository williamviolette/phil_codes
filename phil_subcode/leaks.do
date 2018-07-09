
set more off

cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end

*** LEAK DATA IMPORT PROGRAM ***
#delimit;
cap program drop leak_data;
program define leak_data;
	odbc load, exec(
	"SELECT A.*, B.date AS date_l, C.date_c	
	FROM billing_`1' AS A JOIN cc AS B ON A.conacct = B.conacct
	LEFT JOIN date_c AS C ON A.conacct = C.conacct;")  dsn("phil")	clear;
	tsset conacct date;
	tsfill, full;
		foreach var of varlist date_l class date_c {;
			egen `var'_m = max(`var'), by(conacct);
			replace `var'=`var'_m;
			drop `var'_m;
		};

	else {;
	save "${temp}L_`1'.dta", replace;
	};
end;

*** get neighbor outcome data (haven't added ar in here yet.. probs don't need it);

cap program drop leak_data_neighbors;
program define leak_data_neighbors;
	odbc load, exec(
	"SELECT A.*, B.date_l, B.distance, B.rank, B.conacct AS conacct_leak, C.date_c	
	FROM billing_`1' AS A JOIN leakneighbors AS B ON A.conacct = B.conacctn
	LEFT JOIN date_c AS C ON A.conacct = C.conacct;")  dsn("phil")	clear;
	tsset conacct date;
	tsfill, full;

		egen long conacct_leak_m = max(conacct_leak), by(conacct);
		replace conacct_leak=conacct_leak_m;
		drop conacct_leak_m;

		foreach var of varlist date_l class date_c conacct_leak rank distance {;
			egen double `var'_m = max(`var'), by(conacct);
			replace `var'=`var'_m;
			drop `var'_m;
		};
	save "${temp}LN_`1'.dta", replace;
end;
#delimit cr;

**** SCRIPT STARTS HERE ****

*leak_data 1
*leak_data 2
*leak_data 3

**** then generate 

use  "${temp}L_1.dta", clear
*	append using  "${temp}L_2.dta"
*	append using  "${temp}L_3.dta"

duplicates drop conacct date, force

sort conacct date
g T = date-date_l

** 1 ** clean data
order conacct date date_l

keep if class==1 | class==2
keep if date>=600
drop if date<date_c // get rid of before connection

** maximum of 15% missing in the pre-period ( which is strange if they )

keep if date_l<=662 // only early leakers
replace c=. if c<0 | c>200 // get rid of crazy volumes

g cmiss = c ==. | c==0

sort conacct date // keep from first usage onwards
by conacct: g tn=_n
	g tn_obs = tn if cmiss==0
	egen tn_id = min(tn_obs), by(conacct)
	drop if tn<tn_id
	drop tn tn_obs tn_id

g ct=c if T<-3 & c>=0 & c<=200 // keep only smallish leakers
egen mct=mean(ct), by(conacct)
keep if mct<80

	*** PRE-CLEANING
g cmiss_pre_id 	= 	cmiss==1 & T<0 & date>600   // keep long time-series pre
g c_pre_id 		= 	T<0 & date>600
		
egen cmiss_pre=sum(cmiss_pre_id), by(conacct)
egen c_pre=sum(c_pre_id), by(conacct)
g ratio_pre=cmiss_pre/c_pre
	keep if ratio_pre <=.85  // keep long early time series

	*** POST-CLEANING
g cmiss_post_id = 	cmiss==1 & T>=2 & T<=13
g c_post_id 	= 	T>=2 & T<=13
		
egen cmiss_post=sum(cmiss_post_id), by(conacct)
egen c_post=sum(c_post_id), by(conacct)
g ratio_post=cmiss_post/c_post
	keep if ratio_post>=.82 & ratio_post<=1 // *hist ar, by(DC) // how can I include ar in the definition? OR just ignore it completely... *g DC = ratio_pre<=.85 & ratio_post>=.82 & ratio_post<=1
	keep conacct date_l
	duplicates drop conacct, force

gentable leakers


#delimit;
odbc load, 
exec("SELECT C.*, A.date_l 
	FROM neighbor AS C JOIN leakers AS A 
		ON C.conacct = A.conacct WHERE C.rank<=5 AND C.distance<=10"
		) clear;
#delimit cr;

	bys conacct: g n1=_n==1
	expand 2 if n1==1, gen(expand)
	replace conacctn=conacct if expand==1
	replace distance=-1 if expand==1
	drop n1 expand
		
	egen double min_dist=min(distance), by(conacctn) // closest distance to deal with duplicates
	keep if distance==min_dist
	drop min_dist

gentable leakneighbors

leak_data_neighbors 1




use  "${temp}LN_1.dta", clear

	keep if class==1 | class==2
	drop if c>200 | c<=0
	drop if date<date_c
	drop date_c




** 2 ** make graphs

/*

local time "50"
forvalues r = 1/`=`time'' {
	g T_`r' = T==`=`r'-25'
}

g cm = c==.

qui areg read T_* i.date, absorb(conacct) cluster(conacct) r 

   parmest, fast

   g time = _n
   keep if time<=`=`time''

   tw (scatter estimate time) || (rcap max95 min95 time)




/*		*** THIS IS JUST THE AR PART *** ;
	if "${ar}"=="yes" {;
	save "${temp}L_bill_`1'.dta", replace;
	odbc load, exec( "SELECT A.*, B.date AS date_l 
	FROM ar_`1' AS A JOIN cc AS B ON A.conacct = B.conacct;"
	)  dsn("phil")	clear;
	save "${temp}L_ar_`1'.dta", replace;

	use "${temp}L_bill_`1'.dta", clear;
	merge 1:1 conacct date using "${temp}L_ar_`1'.dta";
	ren _merge M;
	save "${temp}L_`1'.dta", replace;
	erase "${temp}L_bill_`1'.dta";
	erase "${temp}L_ar_`1'.dta";
	};
*/




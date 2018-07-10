


** control panel **

global run_value=12 // run with full sample (greater than 1)

	global leak_data_prep_1_ = "yes" // get the initial leak sample to determine disconnection
	global leaker_define_2_  = "no"
	global leak_compile_3_   = "no"


* 1. check the distance matrix, did I do it right????
* 2. different criteria for leaks (clean the exact same way?)
*

*** OLD CHECK *
* leaks_clean_v1_add.do

** complaints included: 72,000
** key leakers identified: 3,959 (5.5%)
** able to merge with geo-data: 2,200 


*** NEW CHECK *
** complaints included: 25,253 
** key leakers identified: 1,154 (4.5%) (very similar...)
** able to merge with geo-data: 609 ( which is about right now... )


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
	save "${temp}L_`1'.dta", replace;
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
**** SCRIPT STARTS HERE ****
**** SCRIPT STARTS HERE ****


**** leak_data_prep_1_

if "${leak_data_prep_1_}"=="yes" {
	forvalues r=1/$run_value {
		leak_data `r'
	}
}



**** leaker_define_2_

if "$leaker_define_2_"=="yes" {

	use  "${temp}L_1.dta", clear
	g b=1
	forvalues r=2/$run_value {
		append using "${temp}L_`r'.dta"
		replace b=`r' if b==.
	}


	duplicates drop conacct date, force

	sort conacct date
	g T = date-date_l

	order conacct date date_l
	keep if class==1 | class==2
	*keep if date>=600 // do this?
	*drop if date<date_c // get rid of before connection

	** maximum of 15% missing in the pre-period ( which is strange if they )

	keep if date_l<=662 // only early leakers
	replace c=. if c<=0 | c>200 // get rid of crazy volumes ( KEY whether to set c == 0 to missing... )
	g cmiss = c ==. | c==0

	*sort conacct date // keep from first usage onwards
	*by conacct: g tn=_n
	*	g tn_obs = tn if cmiss==0
	*	egen tn_id = min(tn_obs), by(conacct)
	*	drop if tn<tn_id
	*	drop tn tn_obs tn_id

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
		
		keep conacct date_l b
		duplicates drop conacct, force

	gentable leakers


odbc load, exec("SELECT A.* FROM leakers AS A ") clear
ren conacct inputid
merge 1:m inputid using "${phil_folder}sharing/temp/full_nearest_10_v2.dta"
keep if _merge==3

duplicates drop inputid, force


*** TEST THE NEIGHBORS TABLE CAREFULLY HERE !!!!

odbc load, exec("SELECT A.* FROM leakers AS A ") clear
save "${temp}leakers_test.dta", replace 


** 1 ** TEST MERGE WITH METER FILE
odbc load, exec("SELECT OGC_FID, meter_seri, account_no AS conacctm FROM meter") clear  dsn("phil")
destring conacctm, replace force
ren conacctm inputid 
duplicates drop inputid, force
	merge 1:m inputid using "${phil_folder}sharing/temp/full_nearest_10_v2.dta"
duplicates drop inputid, force
tab _merge
*** merges fine...


** 2 ** TRY
odbc load, exec("SELECT * FROM conacctseri") clear  dsn("phil")
drop if conacct==0
ren conacct inputid 
duplicates drop inputid, force
	merge 1:m inputid using "${phil_folder}sharing/temp/full_nearest_10_v2.dta"
duplicates drop inputid, force
tab _merge


** 3 ** try
odbc load, exec("SELECT OGC_FID, meter_seri, account_no AS conacctm FROM meter") clear  dsn("phil")
destring conacctm, replace force

	replace meter_seri = subinstr(meter_seri,"-","",.)
	replace meter_seri = strtrim(meter_seri)
merge m:1 meter_seri using "${temp}meterseri.dta", keep(1 3) nogen

g long conacct_total = conacctm
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
drop if conacct==0

ren conacct inputid 
duplicates drop inputid, force
	merge 1:m inputid using "${phil_folder}sharing/temp/full_nearest_10_v2.dta"
duplicates drop inputid, force
tab _merge





odbc load, exec("SELECT A.* FROM neighbor AS A ") clear
	duplicates drop conacct, force

	merge 1:m conacct using "${temp}leakers_test.dta"


odbc load, exec("SELECT A.* FROM neighbor AS A ") clear
	duplicates drop conacct, force

	ren conacct inputid
	merge 1:m inputid using "${phil_folder}sharing/temp/full_nearest_10_v2.dta"

	duplicates drop inputid, force
	tab _merge


odbc load, exec("SELECT C.*, A.date_l, A.b FROM neighbor AS C JOIN leakers AS A ON C.conacct = A.conacct") clear


*** this checks out! ***

*use "${phil_folder}sharing/temp/full_nearest_10_v2.dta", clear
*duplicates drop conacct, force
*odbc load, exec("SELECT A.* FROM neighbor AS A GROUP BY A.conacct ") clear



*	odbc load, exec("SELECT A.* FROM leakers AS A ") clear
*	odbc load, exec("SELECT A.* FROM neighbor AS A GROUP BY A.conacct ") clear
*	odbc load, exec("SELECT A.* FROM leakers AS A JOIN neighbor AS B ON A.conacct = B.conacct GROUP BY A.conacct ") clear
*	odbc load, exec("SELECT A.*, AVG(B.distance) AS dist FROM leakers AS A JOIN neighbor AS B ON A.conacct = B.conacct GROUP BY B.conacct ") clear


	**** DISTANCE AND RANK CUT IS HERE ! ****
	odbc load, exec("SELECT C.*, A.date_l, A.b FROM neighbor AS C JOIN leakers AS A ON C.conacct = A.conacct WHERE C.rank<=5 AND C.distance<=10") clear

		bys conacct: g n1=_n==1
		expand 2 if n1==1, gen(expand)
		replace conacctn=conacct if expand==1
		replace distance=-1 if expand==1
		replace rank = 0 if expand==1
		drop n1 expand
			
		egen double min_dist=min(distance), by(conacctn) // closest distance to deal with duplicates
		keep if distance==min_dist
		drop min_dist

	gentable leakneighbors

	*** get leak data for all the neighbors

	forvalues r=1/$run_value {
		leak_data_neighbors `r'
	}
	use "${temp}LN_1.dta", clear
	forvalues r=2/$run_value {
		append using "${temp}LN_`r'.dta"
	}
	save "${temp}LN_total.dta", replace
}




if "$leak_compile_3_"=="yes" {

odbc load, exec("SELECT A.*, B.barea, B.pop, B.density FROM pawsstats AS A  LEFT JOIN barea AS B ON A.conacct = B.conacct JOIN leakneighbors AS C ON A.conacct = C.conacctn") clear

	merge 1:m conacct using "${temp}LN_total.dta", keep(2 3) nogen




	keep if class==1 | class==2
	drop if c>200 | c<=0
	drop if date<date_c
	drop date_c


}


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




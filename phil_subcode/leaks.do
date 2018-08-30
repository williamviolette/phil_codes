
	** global : temp
	** input  : TABLE billing_ALL, date_c, neighbor, cc
	** temp   : TABLE leakneighbors, leakers, LN_total  DTA {temp} L_ALL.dta, LN_ALL.dta, leakers.dta, LN_total.dta


** changed post cleaning to 10!

** control panel **

global leak_data_prep_1_ = "no" // get the initial leak sample to determine disconnection
global leaker_define_2_  = "yes" // USES NEIGHBORS


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
	duplicates drop conacct date, force;
	tsset conacct date;
	tsfill, full;

		egen double conacct_leak_m = max(conacct_leak), by(conacct);
		replace conacct_leak=conacct_leak_m;
		drop conacct_leak_m;

		foreach var of varlist date_l class date_c rank distance {;
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
	forvalues  r=1/12 {
		leak_data `r'
	}
}



**** leaker_define_2_

if "$leaker_define_2_"=="yes" {

	use  "${temp}L_1.dta", clear
	g b=1
	forvalues r=2/12 {
		append using "${temp}L_`r'.dta"
		replace b=`r' if b==.
	}

	keep if date_l<=660 // only early leakers
	keep if class==1 | class==2
	duplicates drop conacct date, force

	sort conacct date
	g T = date-date_l

	order conacct date date_l
	*keep if date>=600 // do this?
	drop if date<date_c // get rid of before connection

	replace c=. if c<0 | c>200 // get rid of crazy volumes ( KEY whether to set c == 0 to missing... )
	g cmiss = c ==. | c==0

	sort conacct date // keep from first usage onwards
	by conacct: g tn=_n
		g tn_obs = tn if cmiss==0
		egen tn_id = min(tn_obs), by(conacct)
		drop if tn<tn_id
		drop tn tn_obs tn_id

	*g ct=c if T<-3 & c>=0 & c<=200 // keep only smallish leakers
	*egen mct=mean(ct), by(conacct)
	*keep if mct<80

		*** PRE-CLEANING
	g cmiss_pre_id 	= 	cmiss==1 & T<0 
	*& date>600   // keep long time-series pre
	g c_pre_id 		= 	T<0 
	*& date>600
			
	egen cmiss_pre=sum(cmiss_pre_id), by(conacct)
	egen c_pre=sum(c_pre_id), by(conacct)
	g ratio_pre=cmiss_pre/c_pre
		keep if ratio_pre <=.9  // keep long early time series
			* previous .85

		*** POST-CLEANING
	g cmiss_post_id = 	cmiss==1 & T>=2 & T<=10
	g c_post_id 	= 	T>=2 & T<=10
			
	egen cmiss_post=sum(cmiss_post_id), by(conacct)
	egen c_post=sum(c_post_id), by(conacct)
	g ratio_post=cmiss_post/c_post
		keep if ratio_post>=.9 & ratio_post<=1 // *hist ar, by(DC) // how can I include ar in the definition? OR just ignore it completely... *g DC = ratio_pre<=.85 & ratio_post>=.82 & ratio_post<=1
			* previous .82

		keep conacct date_l b
		duplicates drop conacct, force

	gentable leakers

save "${temp}leakers.dta", replace


	**** DISTANCE AND RANK CUT IS HERE ! ****
	odbc load, dsn(phil) exec("SELECT C.*, A.date_l, A.b FROM neighbor AS C JOIN leakers AS A ON C.conacct = A.conacct WHERE C.rank<=6 AND C.distance<=5") clear

		bys conacct: g n1=_n==1
		expand 2 if n1==1, gen(expand)
		replace conacctn=conacct if expand==1
		replace distance=-1 if expand==1
		replace rank = 0 if expand==1
		drop n1 expand
			
		egen double min_dist=min(distance), by(conacctn) // closest distance to deal with duplicates
		keep if distance==min_dist
		drop min_dist

	*duplicates tag conacctn, g(D)   // 	** there's an issue here with the matching of neighbors
	*browse if D>0   // 		** ... need to fix in neighbor's data data? So small, I'm gonna drop for now..

		duplicates drop conacctn, force
	gentable leakneighbors

		*** get leak data for all the neighbors
	forvalues r=1/12 {
		leak_data_neighbors `r'
	}
	use "${temp}LN_1.dta", clear
	forvalues r=2/12 {
		append using "${temp}LN_`r'.dta"
	}
	duplicates drop conacct date, force
	save "${temp}LN_total.dta", replace
	gentable LN_total
}






** control panel **

global leak_data_prep_1_ = "yes" // get the initial leak sample to determine disconnection
global leaker_define_2_  = "yes" // USES NEIGHBORS
global leak_compile_3_   = "yes"


* 1. check the distance matrix, did I do it right????
* 2. different criteria for leaks (clean the exact same way?)
*

*** OLD CHECK *
* leaks_clean_v1_add.do

** complaints included: 72,000           // checks out !
** key leakers identified: 3,959 (5.5%)  // get 
** able to merge with geo-data: 2,200 



*** NEW CHECK ***
** complaints included: 25,253 
** key leakers identified: 1,154 (4.5%) (very similar...)
** able to merge with geo-data: 496 ( which is about right now... )

*** TESTING>>> use "${phil_folder}savings/temp/treat_sample_v2_2.dta", clear



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
	g cmiss_post_id = 	cmiss==1 & T>=2 & T<=13
	g c_post_id 	= 	T>=2 & T<=13
			
	egen cmiss_post=sum(cmiss_post_id), by(conacct)
	egen c_post=sum(c_post_id), by(conacct)
	g ratio_post=cmiss_post/c_post
		keep if ratio_post>=.9 & ratio_post<=1 // *hist ar, by(DC) // how can I include ar in the definition? OR just ignore it completely... *g DC = ratio_pre<=.85 & ratio_post>=.82 & ratio_post<=1
			* previous .82

		keep conacct date_l b
		duplicates drop conacct, force

	gentable leakers

save "${temp}leakers.dta", replace

* odbc load, exec("SELECT *  FROM leakers") clear
* use "${phil_folder}savings/temp/key_leakers_2.dta", clear



 
*use "${phil_folder}sharing/temp/full_nearest_10_v2.dta", clear
*	destring inputid targetid, replace force
*	bys inputid: g n1=_n==1
*	expand 2 if n1==1, gen(expand)
*	replace targetid=inputid if expand==1
*	replace distance=-1 if expand==1
*	drop n1
*	
*		ren inputid conacct
*			merge m:1 conacct using "${temp}leakers.dta"
*			keep if _merge==3
*			drop _merge
*			ren date_leak date_c_treat
*			keep conacct targetid distance date_c_treat
*		ren conacct conacct_treat
*		ren targetid conacct
*	
*	keep if distance<=5
*	
*	bys conacct distance: g c_n=_n
*	sort  conacct_treat c_n distance
*	by conacct_treat: g gn=_n
*	g dist_rank=gn if c_n==1
*	drop gn c_n
*	keep if dist_rank<=5
*	
*		egen min_dist=min(distance), by(conacct) // closest distance
*		keep if distance==min_dist
*		drop min_dist
*		
*		duplicates drop conacct, force
*		ren conacct conacctn
*		ren conacct_treat conacct
*		ren dist_rank rank
*		replace rank=0 if distance==-1
*		drop expand
*
*		*drop dist_rank
*	gentable leakneighbors


	**** DISTANCE AND RANK CUT IS HERE ! ****
	odbc load, exec("SELECT C.*, A.date_l, A.b FROM neighbor AS C JOIN leakers AS A ON C.conacct = A.conacct WHERE C.rank<=6 AND C.distance<=5") clear

		bys conacct: g n1=_n==1
		expand 2 if n1==1, gen(expand)
		replace conacctn=conacct if expand==1
		replace distance=-1 if expand==1
		replace rank = 0 if expand==1
		drop n1 expand
			
		egen double min_dist=min(distance), by(conacctn) // closest distance to deal with duplicates
		keep if distance==min_dist
		drop min_dist

	*duplicates tag conacctn, g(D)
	*browse if D>0
		** there's an issue here with the matching of neighbors
		** ... need to fix in neighbor's data data? So small, I'm gonna drop for now..
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

}



**** leak_compile_3_

if "$leak_compile_3_"=="yes" {



*odbc load, exec("SELECT A.*, B.barea, B.pop, B.density FROM pawsstats AS A  LEFT JOIN barea AS B ON A.conacct = B.conacct JOIN leakneighbors AS C ON A.conacct = C.conacctn") clear
*	ren distance distancep


* odbc load, exec("SELECT * FROM bstats") clear



odbc load, exec("SELECT A.conacct, B.* FROM bmatch AS A  LEFT JOIN bstats AS B ON A.OGC_FID = B.OGC_FID JOIN leakneighbors AS C ON A.conacct = C.conacctn") clear

	merge 1:m conacct using "${temp}LN_total.dta", keep(2 3) nogen

*use "${temp}LN_total.dta", clear

	keep if class==1 | class==2
	drop if c>120 | c<0 // this is an important parameter right here...
	drop if date<date_c
	drop date_c

	keep if distance<5
	keep if rank<=5

	g T = date - date_l
	g c_nei = c if distance!=-1
	egen C = sum(c_nei), by(conacct_leak date)


	** smaller effect than in the paper .. is that an issue?!
	*  1. don't worry about neighbors in the conacct near threshold... (close)


*** g2 : heterogeneity by distance and rank 

cap program drop est_total
program define est_total
	local cluster_var "conacct_leak"
	local outcome "C"
	local keep_low "-24"
	local keep_high "12"
	local treat_thresh "2"
	*drop if T==0 | T==1
	preserve
		g treat = T>`treat_thresh' & T<.
		g treat_T = treat*T
		keep if T>=`keep_low' & T<=`keep_high'
		duplicates drop `cluster_var' date, force
		areg `outcome' treat treat_T T, absorb(`cluster_var') cluster(`cluster_var') r 		
		areg `outcome' treat, absorb(`cluster_var') cluster(`cluster_var') r 		
	
	restore
end

est_total


*** g1 : just total neighbor usage

cap program drop graph_neighbor
program define graph_neighbor
	local cluster_var "conacct_leak"
	local outcome "C"
	local time "50"
	duplicates drop `cluster_var' date, force
	preserve
		forvalues r = 1/`=`time'' {
		g T_`r' = T==`=`r'-25'
		}
		qui areg `outcome' T_* date, absorb(`cluster_var') cluster(`cluster_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time - `=`time'/2'
    	tw (scatter estimate time) || (rcap max95 min95 time)
   	restore
end


graph_neighbor






cap program drop graph_ind
program define graph_ind
	local cluster_var "conacct"
	local outcome "c"
	local keep_low "-24"
	local keep_high "12"
	local treat_thresh "2"
	preserve
			*g d=distance if distance>0
			*egen dc=cut(d), group(4)
			*tab dc, g(DC_)
			*local het "DC_1 DC_2 DC_3 DC_4"
			*	g house_avg = (house_1_avg + house_2_avg) / 2
			*	keep if pop>2000
		local het "distance house_avg"
		local int "no"

			*egen max_distancep = max(distancep), by(conacct_leak)
			*sum max_distancep, detail
			*keep if max_distancep<`=r(p25)'
		drop if distance==-1
		g treat = T>`treat_thresh' & T<.
		foreach v in `het' {
		g treat_`v' = treat*`v'	
			if "`int'"=="yes" {
				g treat_`v'_T = T * `v'
				g treat_`v'_T_post = T * treat_`v'
			}
		}
		g T_treat = T*treat
		keep if T>=`keep_low' & T<=`keep_high'
			local int_controls ""
			if "`int'"=="yes" {
				local int_controls "T T_treat date"
			}
		duplicates drop `cluster_var' date, force
			areg `outcome' treat $int_controls, absorb(`cluster_var') cluster(`cluster_var') r
			areg `outcome' treat treat_* $int_controls, absorb(`cluster_var') cluster(`cluster_var') r	
	restore
end

graph_ind



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




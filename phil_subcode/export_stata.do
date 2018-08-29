

*********************
*** CONTROL PANEL ***
*********************

local run_here "0"

if "`run_here'"=="0" {
	do "phil_subcode/setmacros.do"
}
else {
	do "setmacros.do"	
}

global price_go 			  = 0
global account_date_go        = 0
global paws_go  		      = 0
global impute_income_go       = 0
global census_clean_go        = 0
global paws_density_go        = 0
global billing_go   	      = 0
global ar_go 			  	  = 0
global complaints_go      	  = 0
global censusbarangaymerge_go = 0
global alt_sub_go 			  = 0
global mean_dist_go 		  = 0

*** TRUE EXPORT
global bill_sample_go 		  = 0   // [check suboptions]
global leaks_go 			  = 0   // [check suboptions]
global leaks_sample_go 		  = 0



cd "${phil_folder}"

if $price_go == 1 {
	** global: $temp, $data, $billingdata  ** input: $data cpi_psa_clean, $billingdata pasay  ** output: TABLE price
	do "${subcode}price.do"
}

if $account_date_go == 1 {
	** global: $temp, $database  ** input:  database/clean/mcf/..  ** output: TABLE date_c
	do "${subcode}account_date.do" 
}

if $paws_go == 1 {
	** global: $pawsdata, $paws_vars ** input:  DTA $pawsdata/full_sample  ** output: TABLE paws
	do "${subcode}paws.do" 
}

if $impute_income_go == 1 {
	** global: $temp, $cbmsdata  ** input:  DTA $cbmsdata 05 08 11, TABLE paws  ** output: TABLE paws_inc
	do "${subcode}impute_income.do" 
}

if $census_clean_go == 1 {
	** global: $temp, $censusdata  ** input: DTA $censusdata RTO1, RT02  ** output: TABLE census
	do "${subcode}census.do" 
}

if $billing_go == 1 {
	** global: $billingdata input: DTA $billingdata(all regions)_billing_2008_2015.dta, ** output: TABLE billing_1 through 12
	do "${subcode}billing.do" //	* issues : 1.) non-matching between areas; *  2.) actread vs. full-read (create indicator) *  3.) billing type (create indicator)
}

if $ar_go == 1 {
	** global: $billingdata  ** input: DTA $billingdata(all regions)_ar_2009_2015.dta, ** output: TABLE ar_1 through 12
	do "${subcode}ar.do"
}

if $complaints_go == 1 {
	** global: $complaintdata  ** input: DTA $complaintdata(all files)  ** output: TABLE cc
	do "${subcode}complaints.do" // define disconnection using non-payment of bills after complaint!!
}

if $censusbarangaymerge_go == 1 {
	** global: $temp, $censusgeodata ** input: $censusgeodata(psgc.dta, psgc_region_IV.dta), TABLE barangay ** TABLE censusbar * input : TABLE
	do "${subcode}censusbarangaymerge.do"
}

if $alt_sub_go == 1 {
	** input: TABLE census , paws    ** output: TABLE alt_sub
	do "${subcode}alt_sub.do"
}

if $mean_dist_go == 1 {
	** input: TABLE neighbor , bmatch , bstats    ** output: TABLE mean_dist
	do "${subcode}mean_dist.do"
}


***** EXPORT TRUE DATA *****


*** 1 * LEAKS SAMPLE ***

if $leaks_go == 1 {
	** global : temp
	** input  : TABLE billing_ALL, date_c, neighbor, cc
	** temp   : TABLE leakneighbors, leakers, LN_total  DTA {temp} L_ALL.dta, LN_ALL.dta, leakers.dta, LN_total.dta
	do "${subcode}leaks.do"
}


if $leaks_sample_go == 1 {
	** global : generated, subcode
	** input  : TABLE bmatch, bstats, LN_total, pawsstats, price, alt_sub
	** output : CSV {generate} post.csv, post_t.csv, g.csv  TABLE leaks
	do "${subcode}leaks_test.do"
}


*** 2 * STANDARD SAMPLE ***

if $bill_sample_go == 1 {
	** global : generated, temp, subcode
	** input  : TABLE paws, conacctseri, price, leakneighbors, census billing_ALL, DO generate_controls.do
	** temp   : TABLE bill_sample_temp, pop_c, DTA {temp} price_avg.dta
	** output : CSV {generated} standard.csv, standard_t.csv, alt.csv
	do "${subcode}bill_sample.do"
}





if "`run_here'"=="0" {
exit, STATA clear
}



** THEN i just need to do all the billing and we're good!! (should I create indexes for files?)

*if $paws_density_go == 1 {
*	** global: 
*	* two density measures : 1) barangay and census; 2) just paws and local area
*	display "paws density"
*}






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

global account_date_go    = 0
global paws_go  		  = 0
global impute_income_go   = 0
global census_clean_go    = 0
global paws_density_go    = 0
global billing_go   	  = 0
global ar_go 			  = 0
global complaints_go      = 0


cd "${phil_folder}"


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
	* issues : 1.) non-matching between areas; *  2.) actread vs. full-read (create indicator) *  3.) billing type (create indicator)
	do "${subcode}billing.do"
}

if $ar_go == 1 {
	** global: $billingdata  ** input: DTA $billingdata(all regions)_ar_2009_2015.dta, ** output: TABLE ar_1 through 12
	do "${subcode}ar.do"
}

if $complaints_go == 1 {
	** global: $complaintdata  ** input: DTA $complaintdata(all files)  ** output: TABLE cc
	display "complaints"
	do "${subcode}complaints.do"
	* define disconnection using non-payment of bills after complaint!!
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




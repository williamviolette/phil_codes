
clear all
set more off

******************
**** SETTINGS ****
******************

global phil_folder="/Users/williamviolette/Documents/Philippines/"
cd "${phil_folder}"


global subcode="${phil_folder}phil_analysis/phil_code/phil_subcode/"

	** data locations **
global temp          = "${phil_folder}phil_analysis/phil_temp/"
global database      = "${phil_folder}database/"
global pawsdata      = "${phil_folder}data/paws/clean/"
global cbmsdata      = "${phil_folder}data/backup_cbms/"
global censusdata    = "${phil_folder}census/input/2010/"
global billingdata   = "${phil_folder}descriptives/output/"
global complaintdata = "${phil_folder}data/cc/"


*********************
*** CONTROL PANEL ***
*********************

global account_date_go 	  = 0
global paws_go  		  = 0
global impute_income_go   = 0
global census_clean_go    = 0
global paws_density_go    = 0
global billing_go   	  = 0
global complaints_go      = 0

if $account_date_go == 1 {
	** global: $temp, $database  ** input:  database/clean/mcf/..  ** output: TABLE date_c
	do "${subcode}account_date.do" 
}

if $paws_go == 1 {
	** global: $pawsdata  ** input:  DTA $pawsdata/full_sample  ** output: TABLE paws
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
	* issues : 1.) non-matching between areas; 
			*  2.) actread vs. full-read (create indicator) 
			*  3.) billing type (create indicator)
	do "${subcode}billing.do"
}



if $complaints_go == 1 {
	** 
	display "complaints"
	* define disconnection using non-payment of bills after complaint!!

}



** THEN i just need to do all the billing and we're good!! (should I create indexes for files?)

if $paws_density_go == 1 {
	** global: 
	* two density measures : 1) barangay and census; 2) just paws and local area
	display "paws density"
}




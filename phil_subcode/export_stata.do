
clear all
set more off
cd /Users/williamviolette/Documents/Philippines/

******************
**** SETTINGS ****
******************

global subcode="/Users/williamviolette/Documents/Philippines/phil_analysis/phil_code/phil_subcode/"

** data locations
global temp="/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/"
global database="/Users/williamviolette/Documents/Philippines/database/"
global pawsdata="/Users/williamviolette/Documents/Philippines/data/paws/clean/"
global cbmsdata="/Users/williamviolette/Documents/Philippines/data/backup_cbms/"


*********************
*** CONTROL PANEL ***
*********************

global account_date = 0
global paws = 1
global impute_income = 1


if $account_date == 1 {
	** global: $temp, $database
	** input: database/clean/mcf/..
	** output TABLE: date_c
	do "${subcode}account_date.do"
}

if $paws == 1 {
	** global: $pawsdata
	** input: DTA $pawsdata/full_sample
	** output: TABLE paws
	do "${subcode}paws.do"
}

if $impute_income == 1 {
	** global: $temp, $cbmsdata
	** input : DTA $cbmsdata 05 08 11, TABLE paws
	** output : TABLE paws_inc
	do "${subcode}impute_income.do"
}

if 





/*

** paws_clean_prep.do
use data/paws/clean/full_sample.dta, clear
		
		** CLEAN CONACCT
		drop if conacct==.

		** DATE CREATED
			merge m:1 conacct using promissory_note/temp/date_c.dta
			keep if _merge==3
			drop _merge
			g pre=date_c<=541

		** AGE
			drop age
			destring age_extra, replace force ignore(+)
			ren age_extra age
			replace age=19 if age==198
			replace age=23 if age==230
			replace age=56 if age==564
			replace age=age*10 if age<=12
			replace age=100 if age>100 & age<.
			replace age=18 if age<18
				
		** HOUSE
			g house_1=regexm(house,"Apartment :")==1
			g house_2=regexm(house,"Single house")==1
		
		** INCOME
			g low_skill=job=="1"
			destring hhemp, replace force
				replace hhemp=8 if hhemp>8
				
		** HHSIZE AND SHARING MEASURES
			destring shr_hh_extra shr_num_extra hhsize, replace force
			replace hhsize=12 if hhsize>12
			g SHO=shr_num_extra - hhsize
			replace SHO=. if SHO<0
			g SHH=shr_hh_extra

			replace SHH=1 if wave==4 & SHH==.	
			*drop if SHO>15 & SHO<.  // CLEAN SHARING VARIABLES
			*drop if SHH>=4  & SHH<. 
			drop if SHO==.
			replace SHO=0 if SHH==1
			replace SHH=1 if wave==3 & SHO==0
			replace SHH=2 if wave==3 & SHO>0 & SHO<=6
			replace SHH=3 if wave==3 & SHO>6 & SHO<.
			* drop if SHH==2 & SHO<=1
			drop if SHH==3 & SHO<=2
		
		** KEY SHARING CUTOFF HERE
			replace SHO=30 if SHO>30
			replace SHH=3 if SHH>3

		g paws = 1
		append using sharing/temp/cbms_inc.dta		// IMPUTE INCOME
			replace age=100 if age>100
		qui xi: reg totin i.hhsize*i.hhemp     i.low_skill*i.house ///
					  i.hhsize*i.low_skill i.low_skill*i.hhemp i.hhsize*age i.low_skill*age ///
					  if wave==4
			predict INC, xb		  
		qui xi: reg totin i.hhsize*i.hhemp     i.low_skill*i.house  ///
					  i.hhsize*i.low_skill i.low_skill*i.hhemp i.hhsize*age  i.low_skill*age ///
					  if wave==5
			predict INC1, xb			  
		replace INC=INC1 if wave==5
		drop INC1
				drop if conacct<10000 // 		** fix identifiers **
				drop if conacct==.
				drop if hcn!=.
		
		replace INC=. if INC<=100
		
		keep conacct INC barangay_id wave date_c pre house_1 house_2 age hhemp hhsize low_skill SHH SHO shh

		duplicates drop conacct wave, force	
			foreach v in 3 4 5 {
			g wave_`v'_id=wave==`v'
			egen wave_`v'=max(wave_`v'_id), by(conacct)
			}
		expand 3 if (wave_3==1 & wave_4==0 & wave_5==0)
		expand 3 if (wave_3==0 & wave_4==1 & wave_5==0)
		expand 3 if (wave_3==0 & wave_4==0 & wave_5==1)
		
		expand 2 if (wave_3==1 & wave_4==1 & wave_5==0 & wave==4)
		expand 2 if (wave_3==0 & wave_4==1 & wave_5==1 & wave==4)
		expand 2 if (wave_3==1 & wave_4==0 & wave_5==1 & wave==3)
			sort conacct wave
			by conacct: g c_n=_n
			replace wave=3 if c_n==1 
			replace wave=4 if c_n==2 
			replace wave=5 if c_n==3 
			drop wave_* c_n			
		duplicates drop conacct wave, force	
	
	foreach var of varlist * {
	if `var'==. {
	error
	}
	}

odbc exec("DROP TABLE IF EXISTS paws;"), dsn("phil")
odbc insert, table("paws") dsn("phil") create



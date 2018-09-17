
	

import delimited using "${generated}alt_${version}.csv", delimiter(",") clear
    g alt = 1
	save "${temp}alt_${version}_temp.dta", replace	


use "${temp}standard_${version}_temp.dta", clear
	ren * , lower
	g alt=0

	append using "${temp}alt_${version}_temp.dta"
	egen A = sum(alt)

	egen mc=mean(c), by(conacct)

	duplicates drop conacct, force

	g TOTAL_C = _N
	replace TOTAL_C = TOTAL_C-A
	
		g hh2 = shh == 2 
		egen hh2s = sum(hh2)
		g hh3 = shh == 3
		egen hh3s = sum(hh3)

g controls_hh_med = hhsize==4 | hhsize==5

g controls_hh_high = hhsize>5 & hhsize<.


bys controls_barangay_id: g b_n=_n==1
egen BN = sum(b_n)


*foreach var of varlist controls_* dist_mean house_census  {
*replace `var'=`var'*100
*}


global varlist "c hh2 hh3 controls_hh_med controls_hh_high controls_house_1 controls_house_2 controls_low_skill controls_hhemp2 controls_age2 controls_age3 house_census dist_mean "
order $varlist


estpost sum $varlist
	matrix meanf1=e(mean)
	matrix list meanf1
	
	matrix minf1=e(min)
	matrix list e(min)

	matrix maxf1=e(max)
	matrix list e(max)

	matrix sdf1=e(sd)
	matrix list e(sd)
	

	matrix A1 = (meanf1',minf1',maxf1',sdf1')

	
*	lab values SHH shh
*	lab var SHH "Water Source"
			

global varcount = 13
* global varlist "hhsize hhemp low_skill INC house_1 house_2 duplex   mc mb vol_per  hhtot THH HH T"	
	

matrix define FOR=J($varcount,1,2) /* format for decimal places */
/*
matrix FOR[1,1]=1
matrix FOR[2,1]=0
matrix FOR[3,1]=0
matrix FOR[4,1]=0
matrix FOR[5,1]=0
matrix FOR[6,1]=0
matrix FOR[7,1]=0
matrix FOR[8,1]=0
matrix FOR[14,1]=0
matrix FOR[13,1]=0
matrix FOR[15,1]=0
*/

matrix define PER=J($varcount,1,0) /* format for percentages */


g temp=""
replace temp = "Water (m3/mo.)"	 	in 1
replace temp = "Shared 2 HHs"	 	in 2
replace temp = "Shared Over 3 HHs"   	in 3
replace temp = "4 or 5 HH members" in 4
replace temp = "Over 5 HH members" in 5
replace temp = "Apartment" 	in 6
replace temp = "Single House" 	in 7
replace temp = "Low-Skill Emp. (Head of HH)"  	in 8
replace temp = "Two or more Empl. HH members"  	in 9
replace temp = "HoH Age Between 36 and 52 Yrs"  	in 10
replace temp = "HoH Age above 52 Yrs"  	in 11

replace temp = "Apartment or Single House" in 12
replace temp = "Dist. Between Neighbors (meters)" 	in 13




g colnames1 = ""
g colnames2 = ""
replace colnames1 = "" in 1
replace colnames2 = "Mean" in 1

replace colnames1 = "" in 2
replace colnames2 = "Min" in 2

replace colnames1 = "" in 3
replace colnames2 = "Max" in 3

replace colnames1 = "Standard" in 4
replace colnames2 = "Deviation" in 4


matrix DIM = ( 11 \ 2 )


 program drop _all
	
	
program define tables `1' `2' `3' `4' `5' `6' `7' `8'
	file open fi using "${output}`1'.tex", write replace
	
	local COLS `=colsof(`2')'
	disp `COLS'	
	file write fi "\begin{tabular}{l*{1}{"	
	forvalues c=1/`COLS' {
		if `c'>1 {
		file write fi "c"
		}
		if `c'==`COLS' {
		file write fi  "c}}" _n		
		}
	}
*	file write fi "\hline" _n
*	file write fi "\hline " _n
	
	
*	file write fi "  & \multicolumn{3}{c}{ \textbf{PAWS} } & \textbf{Census} \\ \cmidrule(r){2-4} \cmidrule(l){5-5}" _n	 // HERE'S WHERE THE COLUMN NAMES ARE SET	
	*file write fi "\hline" _n
	file write fi " &" 
	forvalues c=1/`COLS' {
		if `c'!=`COLS' {
		file write fi "`=`5'[`c']' &"
		}
		if `c'==`COLS' {
		file write fi "`=`5'[`c']'  \\" _n		
		}
	}
	file write fi " &" 	
	forvalues c=1/`COLS' {
		if `c'!=`COLS' {
		file write fi "`=`6'[`c']' &"
		}
		if `c'==`COLS' {
		file write fi "`=`6'[`c']'  \\" _n		
		}
	}	
	*file write fi "\hline" _n  *** FIRST SECTION HERE 
*	file write fi "\hline \\" _n	
	file write fi "\textbf{Owner Demographics} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	forvalues r=1/`=`7'[1,1]' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
		local PP " "
		if `8'[`r',1]==1 {
		local PP "\%"
		}
		if `c'!=`COLS' {
		file write fi  "`h'`PP' & "
		}
		if `c'==`COLS' {
		file write fi  "`h'`PP'  \\" _n		
		}		
		}
	}
			***  SECOND  SECTION HERE 
	file write fi "\hline \\" _n	
	file write fi "\textbf{Ward-Level Characteristics} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	forvalues r=`=`7'[1,1]+1'/`=`7'[1,1]+`7'[2,1]' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
		local PP " "
		if `8'[`r',1]==1 {
		local PP "\%"
		}
		if `c'!=`COLS' {
		file write fi  "`h'`PP' & "
		}
		if `c'==`COLS' {
		file write fi  "`h'`PP'  \\" _n		
		}		
		}
	}
			***  THIRD  SECTION HERE 
	file write fi "\hline \\" _n	
	file write fi "\textbf{Sample Characteristics} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	
	sum TOTAL_C, detail
	*local SET = string(`=r(mean)',"%13.0gc")
	*disp `SET'

	file write fi " Total Connections &\multicolumn{`=`COLS'-1'}{c}{`=string(`=r(mean)',"%13.0gc")' }\\" _n	
	sum A, detail
	file write fi " Unconnected HHs &\multicolumn{`=`COLS'-1'}{c}{`=string(`=r(mean)',"%13.0gc")' }\\" _n	
	sum BN, detail
	file write fi " Number of Villages &\multicolumn{`=`COLS'-1'}{c}{`=string(`=r(mean)',"%13.0gc")' }\\" _n	

	file write fi "\hline" _n
	file write fi "\hline" _n
	file write fi "\end{tabular}"
	file close fi
end			
		 
	tables new_descriptives_est_sample A1 FOR temp colnames1 colnames2 DIM PER
	
	
	
	
	
	
	
	
	
	
	
		
		
		

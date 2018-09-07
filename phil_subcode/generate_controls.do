****************** OLD CONTROLS CODE!

foreach var of varlist house_1 house_2 low_skill {
replace `var'=0 if `var'<.5
replace `var'=1 if `var'>=.5
}

*g hhemp1 = hhemp<=1
*g hhemp2 = hhemp<=1

g hhemp2 = hhemp>=2
g hhemp3 = hhemp>3 & hhemp<.

*g age1 = age<=35
g age2 = age>35 & age<=52
g age3 = age>52


*foreach var of varlist house_1 house_2 low_skill hhemp2 hhemp3 age2 age3 INC  {
*g CONTROLS_`var'=`var'
*drop `var'
*}

foreach var of varlist house_1 house_2 low_skill hhemp2 age3 age2 hhemp3  INC  {
g CONTROLS_`var'=`var'
drop `var'
}
		
capture confirm variable barangay_id
if !_rc {
	g CONTROLS_barangay_id=barangay_id
	drop barangay_id
}

**********************


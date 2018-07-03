


#delimit cr



use  "${temp}L_1.dta", clear
*	append using  "${temp}L_2.dta"
*	append using  "${temp}L_3.dta"

duplicates drop conacct date, force

preserve
	keep conacct
	duplicates drop conacct, force
	display _N
restore

	sort conacct date
g T = date-date_l

local time "50"
forvalues r = 1/`=`time'' {
	g T_`r' = T==`=`r'-25'
}

g cm = c==.

qui areg ar T_* i.date, absorb(conacct) cluster(conacct) r 

   parmest, fast

   g time = _n
   keep if time<=`=`time''

   tw (scatter estimate time) ///
    || (rcap max95 min95 time)








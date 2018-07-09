*** COMPUTE STATA

local run_here "1"

if "`run_here'"=="0" {
	do "phil_subcode/setmacros.do"
}
else {
	do "setmacros.do"	
}




if "`run_here'"=="0" {
exit, STATA clear
}


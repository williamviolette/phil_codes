*** COMPUTE STATA

local run_here "1"

if "`run_here'"=="0" {
	do "phil_subcode/setmacros.do"
}
else {
	do "setmacros.do"	
}

*** CONTROL PANEL ***

global pawsstats_go  = 1
global leaks_go      = 0



if $pawsstats_go == 1 {
	** global: $paws_vars, $temp  ** input: TABLE paws, pneighbor  ** output: TABLE pawsstats
	do "${subcode}pawsstats.do"
}

if $leaks_go == 1 {
	** global: $temp  ** input: TABLE billing_1 - 12, date_c, neighbor, pawsstats, barea  ** output: TABLE leakers, leakneighbors TEMP L_1 - 12.dta, LN_1 - 12.dta
	do "${subcode}leaks.do"
}




if "`run_here'"=="0" {
exit, STATA clear
}


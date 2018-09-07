* test_pull_graphs.do

local version "high_ph"

*local version "normal"

import delimited "/Users/williamviolette/Documents/Philippines/phil_analysis/phil_generated/tables/`version'_1_groups.csv", delimiter(",") clear


line v2 v1

foreach var of varlist v9-v11 {
	*egen m`var'=min(`var')
	g m`var' = `var'[1]
	replace `var'=`var'-m`var'
}

tw (line v9  v1) ||  (line v10  v1) ||  (line v11  v1) 


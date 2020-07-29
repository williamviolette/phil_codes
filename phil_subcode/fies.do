

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


global fies_load = 0

if $fies_load == 1 {


* import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - INCOME AND OTHER RECEIPTS - raw data.csv", delimiter(",") clear

* keep if w_regn=="Region XIII - NCR"


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - NONFOOD EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

destring twatersupply, replace force
destring todisbcashloan, replace force
destring todisbdeposits, replace force
keep if  todisbcashloan!=. | todisbdeposits!=.

replace todisbcashloan = todisbcashloan/6
replace todisbdeposits = todisbdeposits/6

keep w_id w_shsn w_hcn todisbcashloan todisbdeposits twatersupply rfact

save "${fies}hh_loans.dta", replace


import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - HOUSEHOLD DETAILS AND HOUSING CHARACTERISTICS - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

* house_1 house_2 age hhemp hhsize
* house_1 = 

save "${fies}hh_char.dta", replace


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - TOTALS OF INCOME AND EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

merge 1:1 w_id w_shsn w_hcn using "${fies}hh_char.dta"
	keep if _merge==3
	drop _merge

merge 1:1 w_id w_shsn w_hcn using "${fies}hh_loans.dta"
	drop if _merge==2
	drop _merge

save "${fies}fies_merged.dta", replace

}


use "${fies}fies_merged.dta", clear

g inc = toinc/12


sum inc, detail

write "${output}median_inc.tex" `=r(p50)' 1 "%12.0fc"



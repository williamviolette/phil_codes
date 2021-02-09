* pressure.do

* WHEN TO REPLACE PIPES?  
* 		DO NRW IDEA
* counterfactuals:
*  straight monopoly, monopoly with fixed price, quality standards (ie. target NRW?) ?

* low-powered incentive: costs are covered and the utility believes that
* high-powered incentive: imagine that the utility expects a change in regulation 
* 		where the regulator doesn't commit to covering costs

* dynamics too?!




* GO ALL DMA BY MATCHING MRU TO DMA~!



grstyle init
grstyle set imesh, horizontal


* census stat:
* use "${temp}c15_demo_hh.dta", clear
*** Do cost savings by percentage and starting point??


do "${subcode}be_prog.do"


global F = 486



use "${temp}final_analysis.dta", clear


label_set 





**** DYNAMIC EFFECTS  ****
spec_time
time_post
time_export

main_export_time



***** MAIN ESTIMATION RESULTS *****
spec_cv
	est save "${temp}cv1", replace
spec_B
	est save "${temp}cv2", replace
main_post
main_export

***** BOOTSTRAPPED MAIN RESULTS *****
est_boot


**** ROBUSTNESS TO TIME TRENDS *****
spec_cv_robust
	est save "${temp}cv1_robust", replace
spec_B_robust
	est save "${temp}cv2_robust", replace
main_export_robust



***** FIRST STAGE AND REDUCED FORM RESULTS *****
spec_cv_1st_stage
	est save "${temp}e1", replace
spec_cv_red_form
	est save "${temp}e2", replace
spec_B_1st_stage
	est save "${temp}e3", replace
spec_B_red_form
	est save "${temp}e4", replace
tab rs_post if e(sample)==1  // observe only 208 connections after the price change

stage_export


***** HETEROGENEOUS EFFECTS *****

g ln_cv = log(cv+1)
	ivreghdfe cv post_treated post_treated_* hhsize hhemp good_job sub single Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		est save "${temp}cv1h", replace
	ivreghdfe cv post_treated inc__post_treated inc Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		est save "${temp}cv2h", replace
	ivreghdfe ln_cv post_treated post_treated_* hhsize hhemp good_job sub single Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		est save "${temp}cv3h", replace
	ivreghdfe ln_cv post_treated inc__post_treated inc Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO], absorb(conacct date)  cluster(mru) 
		est save "${temp}cv4h", replace
	ivreghdfe B post_treated post_treated_* hhsize hhemp good_job sub single Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
		est save "${temp}cv5h", replace
	ivreghdfe B post_treated inc__post_treated inc Trs_pre Trs_post (pa_adj = rs_post ) [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
		est save "${temp}cv6h", replace

	het_post
	het_export
drop ln_cv

**** ADDITIONAL RESULTS 
main_nrw
main_comm

**** DESCRIPTIVE TABLES ****
dtable 
dtable_rs

**** FIGURES ****
graph_cv
graph_rs


cons_histogram
price_time_series


use "${temp}final_analysis.dta", clear
		

* sum pa_adj, detail
* 21 PhP
* PER MRU : 152,000 PhP
* SURPLUS : 250 accounts * avg HHs (1.4) * HH surplus (1.8*(22/.15) use + .2*480 boost  ) 
* = ( 264 use + 96 boost )* 350 
* = 92,400 use + 33,600 boost
* PROFITS : 250 accounts * 3.7 c per account * (21 price - 5 mc) = 14,680 PhP per MRU (12 months, paid for!)
*** World Bank reports on NRW
*** Water and sanitation benefits!?


















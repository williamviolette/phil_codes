


		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!	
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		** THIS APPROACH IS THE NUTS!		** THIS APPROACH IS THE NUTS!
		
		
	
***** CAN'T REPRODUCE THIS SAMPLE UNFORTUNATELY!!! 

	use ${phil_folder}savings/temp/savings_sample.dta, clear
	
		g SHH2=SHH==2
		sum SHH2, detail
		scalar define s2=r(mean)
		
		g SHH3=SHH==3
		sum SHH3, detail
		scalar define s3=r(mean)
		
	scalar list s2 s3
	
	
		
	use ${phil_folder}diff_in_diff_595/input/mcf_2015.dta, clear
	
	
		merge 1:1 conacct using ${phil_folder}diff_in_diff_595/input/cf.dta
		drop if _merge==2
		g MERGE=_merge==3
		drop _merge
		
	g MB=INST_SUM>500 & INST_SUM<2800
	replace MB=2 if INST_SUM>=2800 & INST_SUM<4500
	replace MB=3 if INST_SUM>=4500 & INST_SUM<.
	replace MB=2 if INST_SUM>=2800 & INST_SUM<5500 & date_c>605
	
		bys mru: g MR_n=_n
	
		g 			MBI=MB==1
		egen 		MBS=sum(MBI), by(mru)
		g 			NO_BANK = MBS<=0
		
		g 		 BANK_POST=1 if MB==1 & date_c>=610 & date_c<=630
		replace  BANK_POST=0 if MB!=1 & date_c>=610 & date_c<=630
		egen 	 FULL_BANK = mean(BANK_POST), by(mru)
		
	egen min_date=min(date_c), by(mru)
	g early=date_c<=550
	egen ed=sum(early), by(mru)
		keep if ed>5
		keep if min_date<560
		
		
		**** ! DOUBLE-CHECK ALL OF THE CLASSIFICATIONS ! ****
			* hist FULL_BANK if MR_n==1, discrete
			 g IR=round(INST_SUM,100) 
			 g dd=dofm(date_c)
			 g year=year(dd)
			 bys IR: g IRN=_N
			 
		   * tab IR year if IRN>500
	
	preserve
		keep if date_c>610
		drop if conacct==.
		keep conacct MB
		export delimited using "${phil_folder}data/gis/constructed_files/cfee.csv", delimiter(",") replace
	restore
	
	g pre=date_c<595
	egen MRU_TOT=sum(pre), by(mru)
	bys mru: g mru_n=_n
	sum MRU_TOT if mru_n==1, detail
	scalar define MRUN=r(mean)
	*sum MRU_TOT if mru_n==1 & MRU_TOT<1000, detail
	
		** ARE THERE MRU's WITH FULL COVERAGE BEFORE 580!?
	g       M_pre=1  if MERGE==1 & date_c<570
	replace M_pre=0  if MERGE==0 & date_c<570
	egen MRU_pre=mean(M_pre), by(mru)
		

		
	* 	hist MRU_pre if MR_n==1, discrete
	*	sum MRU_pre if MR_n==1, detail
	*** THIS OPTION KEEPS ONLY MRU's WITH HIGH COVERAGE BEFORE THE CHANGE
	*	keep if MRU_pre>.75
	
	*** DO THE FIRST STAGE HERE ACTUALLY ***
	
	g MBM=MBI
	replace MBM=. if MERGE==0
	
	egen mean_t=mean(MBM), by(date_c NO_BANK)
	egen mean_t1=mean(MBI), by(date_c NO_BANK)
	bys date_c NO_BANK: g d_n=_n
	
	egen mean_all=mean(MERGE), by(date_c NO_BANK)
	
	g bb=NO_BANK==0
	
	lab var bb "Treatment"
	lab define treat 0 "Untreated" 1 "Treated"
	lab values bb treat
	lab var mean_t "Mean Discounts"
	lab var date_c "Month"
	format date_c %tm
	
			g POST1=date_c>595
			g POST_bb=POST1*bb
			reg MBM bb POST_bb POST1, robust
			mat def mbm_res=e(b)
			scalar define mbm_dind=round(mbm_res[1,2],.001)
	
	
	
	
		line mean_t date_c if d_n==1 & date_c>545 & bb==1, caption("Event Study Estimate: `=100*mbm_dind'%") title("First Stage")
			graph export "${output}diff_595_first_stage.pdf", as(pdf) replace
	
		
		file open newfile using "${output}first_stage.tex", write replace
		file write newfile "`=100*mbm_dind'"
		file close newfile
		
	
		keep if date_c>550
		ren date_c date	
	bys mru date: g T=_N
	
	g MB1_T=MB==1
	egen T_1=sum(MB1_T), by(mru date)
	g MB2_T=MB==2
	egen T_2=sum(MB2_T), by(mru date)
	g MB3_T=MB==3
	egen T_3=sum(MB3_T), by(mru date)
	
	bys mru date: g T_n=_n
	keep if T_n==1
	
	keep mru date T NO_BANK T_1 T_2 T_3
	tsset mru date
		tsfill
		replace T=0 if T==.
		replace T_1=0 if T_1==.
		replace T_2=0 if T_2==.
		replace T_3=0 if T_3==.
		
		
		egen NO_BANKM=max(NO_BANK), by(mru)
		drop NO_BANK
		ren NO_BANKM NO_BANK
		
		scalar define upper_bound=50
		
		g T1=T
		replace T1=`=upper_bound' if T1>`=upper_bound'
		ren T1 New_Connections

		g T1_1=T_1
			replace T1_1=`=upper_bound' if T1_1>`=upper_bound'
		g T1_2=T_2
			replace T1_2=`=upper_bound' if T1_2>`=upper_bound'
		g T1_3=T_3
			replace T1_3=`=upper_bound' if T1_3>`=upper_bound'
	
		g T1_23=T_2+T_3
			replace T1_23=`=upper_bound' if T1_23>`=upper_bound'
		
	g BANK=NO_BANK==0
		
	g date1=round(date,2)
	
			qui tab date1, g(D_)
			
			foreach var of varlist D_* {
			lab var `var' " "
			g NB_`var'=`var'
			lab var NB_`var' " "
			}
			
			foreach var of varlist D_* {
			lab var `var' " "
			g BA_`var'=`var'*BANK
			lab var BA_`var' " "
			}
			
			lab var NB_D_17 "-12"
			lab var NB_D_23 "0"
			lab var NB_D_29 "12"
			lab var BA_D_17 "-12"
			lab var BA_D_23 "0"
			lab var BA_D_29 "12"
		
		sum New_Connections
		scalar define NC=r(mean)
		
		drop NB_D_1-NB_D_2
		drop BA_D_1-BA_D_2
		
		*drop NB_D_1-NB_D_3
		*drop BA_D_1-BA_D_3
		
		* drop NB_D_110-NB_D_114
		drop NB_D_56-NB_D_57
		drop BA_D_56-BA_D_57
		xi: areg New_Connections NB_* BA_*, absorb(mru) robust cluster(mru)
		
		


		preserve
		
			parmest, fast
				   	g BA_id = regexm(parm,"BA")==1
				   	keep if BA_id==1
				   	g time = _n - 22
				   	lab var time "Time (Months to Leak)"

			    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
			    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
			    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
			    	 graphregion(color(gs16)) plotregion(color(gs16))  ///
			    	 ytitle("New Accounts Per Month") ///
			    	 title("Additional New Connections per Month for" "Treated Areas Relative to Untreated Areas", ///
					size(medsmall) color(black))  ylabel(-.5(.5).75)  ///
					xtitle("Months to Discount Policy") note("Avg. New Connections Per Month : `=round(NC,.01)'       Mean Connections per Area: `=round(MRUN,1)' ")

				graph export  "${output}diff_595.pdf", as(pdf) replace
			   
		restore



		*** DISCOUNT SIZE
			
		
		
		g POST=date>595 & date<.
		g POST_BANK=POST*BANK
		
		lab var BANK "Treated"
		lab var POST "Post"
		lab var POST_BANK "Post X Treated"
		lab var New_Connections "New Connections per month/area"
		
		sum New_Connections, detail
		scalar define NC_mean=round(r(mean),.01)
		
		areg New_Connections POST_BANK POST , absorb(mru) cluster(mru) robust
		est sto est1
			matrix def res   = e(b)
			scalar def slope = res[1,1]
			
			
		file open newfile using "${output}red_form_est.tex", write replace
		file write newfile "`=round(res[1,1],.01)'"
		file close newfile
	
			
		file open newfile using "${output}red_form_base.tex", write replace
		file write newfile "`=round(res[1,3],.01)'"
		file close newfile
			
		outreg2 using "${output}diff_595_reg_primary.tex", tex(frag) ///
		replace addtext("Avg. New Conn.","`=NC_mean'","Area FE","Yes") addnote("Clustered at the MRU Level: 3,757 MRUs") label ///
		ctitle("Diff-in-Diff Estimate") 
		
	
		
	*	areg T1_1  POST_BANK POST , absorb(mru) cluster(mru) robust
	
		label var T1_23 "New Full Price Connections"
		sum T1_23, detail
		scalar define NP_mean=round(r(mean),.01)
		
		reg T1_23 POST_BANK POST BANK , cluster(mru) robust
		
		outreg2 using "${output}diff_595_reg_secondary.tex", tex(frag) ///
		replace addtext("Avg. New Conn.","`=NP_mean'")addnote("Clustered at the MRU Level: 3,757 MRUs") label ///
		ctitle("Diff-in-Diff Estimate") 
		
		
		
		matrix def XX=e(b)
		scalar define would_have_added = round((XX[1,2]+XX[1,3]+XX[1,4]),.01)
		scalar list would_have_added
		
file open newfile using "${output}would_have_added.tex", write replace
file write newfile "`=would_have_added'"
file close newfile
		
		scalar define actually_added = round((XX[1,1]+XX[1,2]+XX[1,3]+XX[1,4]),.01)

file open newfile using "${output}actually_added.tex", write replace
file write newfile "`=actually_added'"
file close newfile
				
		scalar define substitution =  100*round(1 - (actually_added/would_have_added),.01)
		
			scalar list substitution
			

file open newfile using "${output}substitution.tex", write replace
file write newfile "`=substitution'"
file close newfile
							
		
		scalar define treated_months = 664-595
		
		file open newfile using "${output}treated_months.tex", write replace
		file write newfile "`=treated_months'"
		file close newfile
		
		scalar define total_effect = round(slope*treated_months,.02)
		
			scalar list total_effect
			
		file open newfile using "${output}total_effect.tex", write replace
		file write newfile "`=total_effect'"
		file close newfile
		
		scalar define mru_size= `=round(MRUN,1)'
		
			scalar list mru_size
			
		file open newfile using "${output}mru_size.tex", write replace
		file write newfile "`=mru_size'"
		file close newfile
		
		

			scalar list s2 s3	

		file open newfile using "${output}share_2_hhs.tex", write replace
		file write newfile "`=round(100*s2)'"
		file close newfile
		
		file open newfile using "${output}share_3_hhs.tex", write replace
		file write newfile "`=round(100*s3)'"
		file close newfile			

		
			disp mru_size*(1+s2+2*s3)*(1+.05)
		
		scalar define population_served=mru_size*(1+s2+2*s3)*(1+.05)
		
		file open newfile using "${output}population_served.tex", write replace
		file write newfile "`=round(population_served)'"
		file close newfile			
		
		file open newfile using "${output}increase_in_individual_connections.tex", write replace
		file write newfile "`=round(100*total_effect/population_served,.1)'"
		file close newfile			
		
		
		
		
			scalar define percent_increase = round(total_effect/population_served,.001)
		
		file open newfile using "${output}percent_increase_discount.tex", write replace
		file write newfile "`=100*percent_increase'"
		file close newfile
		
			scalar list percent_increase
	


	
	
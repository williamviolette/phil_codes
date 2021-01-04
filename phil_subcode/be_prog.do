

***** MAIN SPECIFICATIONS *****
cap prog drop spec_cv
prog def spec_cv
		ivreghdfe cv post_treated  Trs_pre Trs_post (pa_adj = rs_post )  [pweight = SHO], absorb(conacct date)  cluster(mru) 
end


cap prog drop spec_B
prog def spec_B
		ivreghdfe B post_treated  Trs_pre Trs_post (pa_adj = rs_post )  [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
end

**** ROBUSTNESS TO TIME CONTORLS ****

cap prog drop spec_cv_robust
prog def spec_cv_robust
		ivreghdfe cv post_treated  Trs_pre Trs_post Trs_pre2 Trs_post2 (pa_adj = rs_post )  [pweight = SHO], absorb(conacct date)  cluster(mru) 
end

cap prog drop spec_B_robust
prog def spec_B_robust
		ivreghdfe B post_treated  Trs_pre Trs_post Trs_pre2 Trs_post2 (pa_adj = rs_post )  [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
end

**** FIRST STAGE AND REDUCED FORM ****
cap prog drop spec_cv_1st_stage
prog def spec_cv_1st_stage
	reghdfe pa_adj  post_treated  rs_post Trs_pre Trs_post [pweight = SHO], absorb(conacct date)  cluster(mru) 
end
cap prog drop spec_cv_red_form
prog def spec_cv_red_form
	reghdfe cv  post_treated  rs_post Trs_pre Trs_post [pweight = SHO], absorb(conacct date)  cluster(mru) 
end

cap prog drop spec_B_1st_stage
prog def spec_B_1st_stage
	reghdfe pa_adj  post_treated  rs_post Trs_pre Trs_post [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
end
cap prog drop spec_B_red_form
prog def spec_B_red_form
	reghdfe cv  post_treated  rs_post Trs_pre Trs_post [pweight = SHO] if paws==1, absorb(mru date)  cluster(mru) 
end




cap prog drop main_post
prog def main_post

	qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv1"
		mat ee=e(b)
		estadd scalar varmean = `=j[1,1]'
		global cm = `=j[1,1]'
			global cm_st = string(`=j[1,1]',"%12.1fc")
		    file open newfile using "${output}cm.tex", write replace
    		file write newfile " $cm_st  "
    		file close newfile 
    	global dqdrm = `=ee[1,2]'
			global dqdr_st = string(`=ee[1,1]',"%12.2fc")
		    file open newfile using "${output}dqdrm.tex", write replace
    		file write newfile " $dqdr_st  "
    		file close newfile 
    	global alpham = `=ee[1,1]'
			global alpha_st = string(`=ee[1,2]',"%12.2fc")
		    file open newfile using "${output}alpham.tex", write replace
    		file write newfile " $alpha_st  "
    		file close newfile 
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv1s", replace

	qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv2"
		mat ee=e(b)
			global bm = `=j[1,1]'
			global bm_st = string(`=j[1,1]',"%12.1fc")
		    file open newfile using "${output}bm.tex", write replace
    		file write newfile " $bm_st "
    		file close newfile 

    		global dbdrm = `=ee[1,2]'
			global dbdr_st = string(`=ee[1,2]',"%12.2fc")
		    file open newfile using "${output}dbdrm.tex", write replace
    		file write newfile " $dbdr_st  "
    		file close newfile 
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv2s", replace

    local value1=string(`=$dqdrm*($cm/-$alpham)',"%12.1fc")
    local value2=string(`=-$dbdrm*$F',"%12.1fc")
    local value3=string(`=($dqdrm*($cm/-$alpham)) -$dbdrm*$F',"%12.1fc")

	file open newfile using "${output}est_welfare.tex", write replace
    file write newfile " `value1' & `value2' & `value3'"
    file close newfile   

end


cap prog drop main_export
prog def main_export
		forvalues r=1/2 {
			est use "${temp}cv`r's"
			est sto cv`r's
		}

	estout cv1s cv2s using "${output}reg.tex", replace  style(tex) ///
		 keep(  post_treated pa_adj  ) ///
		order(  post_treated pa_adj  ) ///
			  label noomitted ///
			  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean  r2 N dataset , ///
			  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


	estout cv1s cv2s using "${output}reg_full.tex", replace  style(tex) ///
		 keep(  post_treated pa_adj Trs_pre Trs_post ) ///
		order(  post_treated pa_adj Trs_pre Trs_post ) ///
			  label noomitted ///
			  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean  r2 N dataset , ///
			  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


	estout cv1s cv2s using "${output}reg_stars.tex", replace  style(tex) ///
		 keep(  post_treated pa_adj  ) ///
		order(  post_treated pa_adj  ) ///
			  label noomitted ///
			  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean  r2 N dataset , ///
			  labels( "Mean" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12.3fc %12.0fc %12s  )   ) 
end



cap prog drop main_export_robust
prog def main_export_robust
		forvalues r=1/2 {
			est use "${temp}cv`r'_robust"
			est sto cv`r's_robust
		}

	estout cv1s_robust cv2s_robust using "${output}reg_robust.tex", replace  style(tex) ///
		 keep( post_treated pa_adj Trs_pre Trs_post Trs_pre2 Trs_post2 ) ///
		order( post_treated pa_adj Trs_pre Trs_post Trs_pre2 Trs_post2 ) ///
			  label noomitted ///
			  varlabels(, el( post_treated "[0.5em]" pa_adj "[0.5em]" )) ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats(  r2 N dataset , ///
			  labels(  "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt(  %12.3fc %12.0fc %12s  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

end



cap prog drop stage_export
prog def stage_export

		forvalues r=1/4 {
			est use "${temp}e`r'"
			est sto e`r'
		}

	estout e1 e2 e3 e4 using "${output}reg_stages.tex", replace  style(tex) ///
		 keep(  post_treated rs_post Trs_pre Trs_post ) ///
		order(  post_treated rs_post Trs_pre Trs_post  ) ///
			  label noomitted ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats(  r2 N dataset , ///
			  labels(  "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt(  %12s %12s %12.3fc %12.0fc %12s  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 
end




cap prog drop het_post
prog def het_post

		qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv1h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv1hs", replace

		qui mean cv [pweight = SHO ] 
    	mat j=e(b)
	est use "${temp}cv2h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"
		estadd local dataset "Billing Panel"
	est save "${temp}cv2hs", replace

		qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv3h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv3hs", replace

		qui mean B [pweight = SHO ]  if paws==1
    	mat j=e(b)
	est use "${temp}cv4h"
		estadd scalar varmean = `=j[1,1]'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""
		estadd local  dataset "Household Survey"
	est save "${temp}cv4hs", replace
end



cap prog drop het_export
prog def het_export

		forvalues r=1/4 {
			est use "${temp}cv`r'hs"
			est sto cv`r'hs
		}

	lab var post_treated "Post"

	estout cv1hs cv2hs cv3hs cv4hs using "${output}reghet.tex", replace  style(tex) ///
		 keep(  post_treated pa_adj  ///
		 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
		 		hhsize hhemp good_job sub single inc  ) ///
		order(  post_treated pa_adj ///
				post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
		 		hhsize hhemp good_job sub single inc ) ///
			  label noomitted ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
			  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

	estout cv1hs cv2hs cv3hs cv4hs using "${output}reghet_stars.tex", replace  style(tex) ///
		 keep(  post_treated   ///
		 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
		 		hhsize hhemp good_job sub single inc  ) ///
		order(  post_treated  ///
				post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single inc__post_treated  ///
		 		hhsize hhemp good_job sub single inc ) ///
			  label noomitted ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
			  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) 

	estout cv1hs cv3hs using "${output}reghet_stars_int.tex", replace  style(tex) ///
		 keep(  post_treated   ///
		 		post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single  ) ///
		order(  post_treated  ///
				post_treated_hhsize post_treated_hhemp post_treated_good_job post_treated_sub post_treated_single   ) ///
			  label noomitted ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean ctrl_ind ctrl_place r2 N dataset , ///
			  labels( "Mean" "Household FE" "Small Area FE" "$\text{R}^{2}$"  "N" "Dataset" )  ///
			    fmt( %12.2fc  %12s %12s %12.3fc %12.0fc %12s  )   ) 

	*** RELABEL THE VARIABLE! ***
	lab var post_treated "After Pipe Replacement"

end





cap prog drop est_boot
prog def est_boot

	set seed 15

	global bno=10
	mat def ef = J($bno,3,0)

	forvalues r = 1/$bno {
		global tag = "_`r'"
		preserve
			keep mru
			gegen mtag=tag(mru)
			keep if mtag==1
			drop mtag
			bsample
			duplicates tag mru, g(D)
			duplicates drop mru, force
			replace D = D+1 
			save "${temp}boot_temp.dta", replace
		restore

		preserve
			merge m:1 mru using "${temp}boot_temp.dta", keep(3) nogen

			sort mru conacct date
			expand D
			sort mru conacct date
			by mru conacct date: g dn=_n

			gegen conacct1=group(conacct dn)
				drop conacct
				ren conacct1 conacct
			gegen mru1 = group(mru dn)
				drop mru
				ren mru1 mru

			spec_cv
			est save "${temp}cv_b`r'", replace

			qui mean cv [pweight = SHO ] 
			est save "${temp}mm_b`r'", replace

			spec_B
			est save "${temp}bb_b`r'", replace

		restore
	}


	global F = 486

	forvalues r=1/$bno {
	est use "${temp}cv_b`r'"
		mat def bb=e(b)
		global dqdr = bb[1,2]
		global alpha = bb[1,1]

	est use "${temp}bb_b`r'"
		mat def bb=e(b)
		global dbdr = bb[1,2]
	est use "${temp}mm_b`r'"
		mat def bb=e(b)
		global wstar = bb[1,1]

	mat ef[`r',1] =  $dqdr*($wstar/-$alpha)
	mat ef[`r',2] = -$dbdr*$F
	mat ef[`r',3] =  $dqdr*($wstar/-$alpha) -$dbdr*$F
	}


	preserve
		clear
		svmat ef 
	    sum ef1
	    local value1=string(`=r(sd)',"%12.1fc")
	    sum ef2
	    local value2=string(`=r(sd)',"%12.1fc")
	    sum ef3
	    local value3=string(`=r(sd)',"%12.1fc")

	    file open newfile using "${output}sd_welfare.tex", write replace
	    file write newfile "(`value1') & (`value2') & (`value3')"
	    file close newfile    
	restore
end


cap prog drop label_set
prog define label_set
	lab var post_treated "After Pipe Replacement"
	lab var B "Use Booster Pump"
	lab var cv "Usage per Household (m3)"

	lab var pa_adj "Avg. Price (PhP)"
	lab var clmax "Ever High Price"
	lab var semm "Change High to Low Price"
	lab var resm "Change Low to High Price"
	lab var hhsize "Household Size"
	lab var hhemp "Employed Household Members"
	lab var good_job "High Skilled Employment"
	lab var sub "Subdivided House/Duplex"
	lab var single "Freestanding House"

	lab var post_treated_hhsize "Post $\times$ Household Size"
	lab var post_treated_hhemp "Post $\times$ Employed Household Members"
	lab var post_treated_good_job "Post $\times$ High Skilled Employment"
	lab var post_treated_sub "Post $\times$ Subdivided House/Duplex"
	lab var post_treated_single "Post $\times$ Freestanding House"

	lab var inc "Monthly Income (10,000 PhPs)"
	lab var inc__post_treated "Post $\times$ Monthly Income (10,000 PhPs)"

	lab var rs_post "Post Price Increase"

	lab var Trs_pre "Months Pre"
	lab var Trs_post "Months Post"

	lab var Trs_pre2 "Months sq. Pre"
	lab var Trs_post2 "Months sq. Post"

	lab var Trs_pre3 "Months cu. Pre"
	lab var Trs_post3 "Months cu. Post"

end



**** DESCRIPTIVE TABLES ****


cap prog drop dtable
prog def dtable
	preserve 
		g no_flow_6mid = fl_6_mid==1
		g yes_flow_6mid = fl_6_mid==4
		g taste_smell= taste==1 | smell==1
		replace booster_use = . if booster_use>=24
		g deepwell = wrs_type==2
		g station = wrs_type==1

		keep if paws==1
		g SHO1=SHO-1

		print_mean2 flow_hrs flow_hrs  "%10.2fc" 1
		print_mean2 stop_freq stop_freq  "%10.2fc" 1
		print_mean2 yes_flow_6mid  yes_flow_6mid  "%10.2fc" 1
		print_mean2 no_flow_6mid  no_flow_6mid    "%10.2fc" 1
		print_mean2 foreign_bodies  stuff    "%10.2fc" 1
		print_mean2 discolored  color        "%10.2fc" 1
		print_mean2 taste_smell taste_smell  "%10.2fc" 1

		print_mean2 booster  B "%10.2fc" 1
		print_mean2 booster_use  booster_use "%10.2fc" 1
		print_mean2 drum  drum "%10.2fc" 1
		print_mean2 filter  filter "%10.2fc" 1

		print_mean2 station   station   "%10.2fc" 1
		print_mean2 deepwell  deepwell  "%10.2fc" 1
		print_mean2 wrs_exp   wrs       "%10.2fc" 1
		print_mean2 drink  drink  "%10.2fc" 1
		print_mean2 boil   boil   "%10.2fc" 1

		print_mean2 hhsize  hhsize   "%10.2fc" 1
		print_mean2 hhemp  hhemp   "%10.2fc" 1
		print_mean2 good_job  good_job   "%10.2fc" 1
		print_mean2 sub  sub   "%10.2fc" 1
		print_mean2 single single  "%10.2fc" 1
		print_mean2 SHO   SHO1   "%10.2fc" 1

		print_mean2n pawsn B "%10.0fc" 1
	restore
end


cap prog drop dtable_rs
prog def dtable_rs
	preserve 
		g class_ch=class_max!=class_min
		gegen rs_id = max(rs_post), by(conacct)
		g cch = 1 if class==1 & rs_id==0
		replace cch=2 if class==2 & rs_id==0 
		replace cch=3 if rs_id==1
		g SHO1=SHO
		replace SHO1=SHO1-1

		print_mean2s cv_rs  cv   "%10.2fc" 1
		print_mean2s hhsize_rs  hhsize   "%10.2fc" 1
		print_mean2s hhemp_rs  hhemp   "%10.2fc" 1
		print_mean2s good_job_rs  good_job   "%10.2fc" 1
		print_mean2s sub_rs  sub   "%10.2fc" 1
		print_mean2s single_rs single  "%10.2fc" 1
		print_mean2s SHO_rs   SHO1   "%10.2fc" 1
		print_mean2Ns N_rs  hhsize   "%10.0fc" 1
	restore
end


*** FIGURES ***

cap prog drop graph_cv
prog def graph_cv

	grstyle init
	grstyle set imesh, horizontal

	preserve 
		g pT = year-year_inst
		replace pT=. if pT>6 | pT<-6
		replace pT=. if minpost!=0
		gegen ptag=tag(pT)
		* gegen mcv = mean(cv), by(pT)

		asgen mcv = cv , w(SHO) by(pT)

		label var mcv "Water Use per Household (m3)"
		label var pT  "Years to Pipe Replacement"

		    mean cv [pweight = SHO ] if pT>=-4 & pT<0
		    mat j=e(b)
		    global c_pre = j[1,1]
		    local value=string($c_pre ,"%12.1fc")
		    file open newfile using "${output}c_pre.tex", write replace
		    file write newfile "`value'"
		    file close newfile   

		    mean cv [pweight = SHO ] if pT>=0 & pT<=6
		    mat j=e(b)
		    global c_post = j[1,1]
		    local value=string($c_post,"%12.1fc")
		    file open newfile using "${output}c_post.tex", write replace
		    file write newfile "`value'"
		    file close newfile   

		    local value=string($c_post - $c_pre ,"%12.1fc")
		    file open newfile using "${output}c_diff.tex", write replace
		    file write newfile "`value'"
		    file close newfile   

			local value=string(100*($c_post - $c_pre)/$c_pre ,"%12.0fc")
		    file open newfile using "${output}c_diff_per.tex", write replace
		    file write newfile "`value'"
		    file close newfile   


		twoway scatter mcv pT if ptag==1 & pT>=-4 & pT<=6, ylabel(18(1)22) ///
			note("Avg. Pre:  `=string($c_pre ,"%12.1fc")'    Avg. Post:  `=string($c_post ,"%12.1fc")' ")
		graph export "${output}pipe_cons.pdf", as(pdf) replace 
	restore
end



cap prog drop graph_rs
prog def graph_rs

	grstyle init
	grstyle set imesh, horizontal

	preserve 
		asgen cv_rs =cv, by(Trs) w(SHO)
		gegen rstag=tag(Trs)

	lab var cv_rs "Usage (m3) per Household-Month"
	lab var Trs "Months to Price Change"
	sum pa_adj if sem==1
	sum pa_adj if sem==0
		gegen pa_adjm=mean(pa_adj), by(Trs)
		lab var pa_adjm "PhP per m3"

		twoway scatter cv_rs Trs if rstag==1 & Trs>=-24 & Trs<=24 || ///
			 scatter pa_adjm Trs if rstag==1 & Trs>=-24 & Trs<=24 , yaxis(2) ms(diamond)  ///
			legend(order(1 "Usage" 2 "Price") symx(6) col(1) ///
		    ring(0) position(3) bm(medium) rowgap(small)  ///
		    colgap(small) size(*.95) region(lwidth(none)))

		graph export "${output}r_to_s_only_graph.pdf", as(pdf) replace
	restore 
end


cap prog drop cons_histogram
prog def cons_histogram
	preserve 
		keep if c<=60
		g o=1
		gegen cN=sum(o), by(c read)
		gegen cT=tag(c read)
		gegen NN=sum(o), by(read)
		replace cN=cN/NN
		lab var cN " "
		lab var c "Monthly Usage per Connection (m3)"
		twoway scatter cN c if cT==1 & read==1
		graph export "${output}cons_histogram.pdf", replace
	restore
end

cap prog drop price_time_series
prog def price_time_series
	preserve 

	cap drop avgp
	cap drop avgc
	cap drop dtag
	gegen avgp=mean(pa_adj), by(date)
	gegen avgc=mean(cv), by(date )
	gegen dtag=tag(date)

	format date %tm
	lab var date "Date"
	lab var avgp "Average Price (PhP/m3)"
	lab var avgc "Average Usage per Household (m3)"

	twoway scatter avgc  date if dtag==1 || ///
			scatter avgp  date if dtag==1, yaxis(2) ms(diamond) ///
			legend(order(1 "Usage per Household (m3)" 2 "Price (PhP/m3)") symx(6) col(1) ///
		    ring(0) position(5) bm(medium) rowgap(small)  ///
		    colgap(small) size(*.95) region(lwidth(none)))

		graph export "${output}price_time_series.pdf", replace
	restore
end


*** NRW RESULTS ***

cap prog drop main_nrw
prog def main_nrw
	preserve
		use "${temp}final_nrw.dta", clear

	reghdfe supp5 post_treated, a(dma date) cluster(dma)
		est sto nrw1
		sum supp5
		estadd scalar varmean = `=r(mean)'

	reghdfe supp post_treated, a(dma date) cluster(dma)
		est sto nrw2
		sum supp
		estadd scalar varmean = `=r(mean)'

	reghdfe bill post_treated, a(dma date) cluster(dma)
		est sto nrw3
		sum bill
		estadd scalar varmean = `=r(mean)'

	reghdfe nrw post_treated, a(dma date) cluster(dma)
		est sto nrw4
		sum nrw
		estadd scalar varmean = `=r(mean)'

	lab var post_treated "After Pipe Replacement"

	estout nrw1 nrw2 nrw3 nrw4  using "${output}nrw.tex", replace  style(tex) ///
	 keep(  post_treated  ) ///
	order(  post_treated  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean  r2 N  , ///
		  labels( "Mean"  "$\text{R}^{2}$"  "N"  )  ///
		    fmt( %12.2fc   %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 
	restore
end


*** COMM RESULTS ***

cap prog drop main_comm
prog def main_comm

	preserve
		use "${temp}final_comm.dta", clear

		reghdfe c post_treated , a(conacct date) cluster(mru)
		est sto comm1
		sum c
		estadd scalar varmean = `=r(mean)'
		est save "${temp}comm_c", replace

		reghdfe amount post_treated , a(conacct date) cluster(mru)
		est sto comm2
		sum amount
		estadd scalar varmean = `=r(mean)'
		est save "${temp}comm_a", replace
		
	restore

		reghdfe cv post_treated , a(conacct date) cluster(mru)
		est sto comm1
		sum c
		estadd scalar varmean = `=r(mean)'
		est save "${temp}res_c", replace


		reghdfe AS post_treated , a(conacct date) cluster(mru)		
		est sto comm2
		sum AS
		estadd scalar varmean = `=r(mean)'
		est save "${temp}res_a", replace


		foreach v in comm_c comm_a res_c res_a {
			est use "${temp}`v'"
			est sto `v'
		}

		lab var post_treated "After Pipe Replacement"

		estout comm_c comm_a res_c res_a  using "${output}comm.tex", replace  style(tex) ///
		 keep(  post_treated  ) ///
		order(  post_treated  ) ///
			  label noomitted ///
			  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
			  stats( varmean  r2 N  , ///
			  labels( "Mean"  "$\text{R}^{2}$"  "N"  )  ///
			    fmt( %12.2fc   %12.3fc %12.0fc  )   ) ///
			  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

end




*** GEO


cap prog drop main_geo

prog def main_geo

	use "${temp}final_analysis.dta", clear


		g o =1
		gegen Wtemp = sum(o), by(zm)
		drop o
		replace Wtemp=Wtemp/_N

		g CPe = .
		g W = .
		levelsof zm
		foreach v in `=r(levels)' {
			sum cper if zm==`v'
			replace CPe=`=r(mean)' in `v'
			sum Wtemp if zm==`v'
			replace W = `=r(mean)' in `v'
		}

		levelsof zm
		foreach v in `=r(levels)' {
			g ZM_`v'_post_treated=post_treated==1 & zm==`v'
			lab var ZM_`v'_post_treated " `v' "
		}

		reghdfe B  ZM_*_post_treated [pweight=SHO] if paws==1, a(mru date) cluster(mru)
		est save "${temp}co_B", replace
		mat def be = e(b)

		reghdfe cv ZM_*_post_treated [pweight=SHO], a(conacct date) cluster(mru)
		est save "${temp}co_cv", replace	
		mat def ce = e(b)

		reghdfe AS ZM_*_post_treated [pweight=SHO], a(conacct date) cluster(mru)
		est save "${temp}co_as", replace	
		mat def ae = e(b)

		reghdfe no_flow ZM_*_post_treated [pweight=SHO] if paws==1, a(mru date) cluster(mru)
		est save "${temp}co_nf", replace
		mat def ne = e(b)


		g Be = .
		g Ce = .
		g Ae = .
		g NFe = .
		levelsof zm
		foreach r in `=r(levels)' {
			replace Be = be[1,`r'] in `r'
			replace Ce = ce[1,`r'] in `r'
			replace Ae = ae[1,`r'] in `r'
			replace NFe = ne[1,`r'] in `r'
		}


		g CVe = .
		g NFm  = .
		levelsof zm
		foreach r in `=r(levels)' {
		qui mean cv [pweight = SHO ] if zm==`r'
		matrix ee=e(b)
		replace CVe=ee[1,1] in `r'
		qui mean no_flow [pweight = SHO ] if zm==`r' & post_treated==1
		matrix ee=e(b)
		replace NFm=ee[1,1] in `r'
		}


		browse CVe Ce Be Ae CPe

		g CSe = CVe*Ce/.6
		g BSe = -Be*486


		preserve	
			keep  CSe BSe Ae CPe NFm NFe W
			order CSe BSe Ae CPe NFm NFe W
			keep if CSe!=.
			export delimited using "${temp}mat_counter.csv", delimiter(",") replace
			g id=_n
			save "${temp}geo.dta", replace
		restore



	use "${temp}final_comm.dta", clear

	levelsof zm
	foreach v in `=r(levels)' {
		g ZM_`v'_post_treated=post_treated==1 & zm==`v'
		lab var ZM_`v'_post_treated " `v' "
	}

	levelsof zm
	foreach v in `=r(levels)' {
		sum cshr if zm==`v'
	}

	reghdfe amount ZM_*_post_treated , a(conacct date) cluster(mru)
	mat def mca = e(b)
	est save "${temp}co_asc", replace

	g CSHR = .
	g CAMT = .

	levelsof zm
	foreach v in `=r(levels)' {
		sum cshr if zm==`v'
		replace CSHR=`=r(mean)' in `v'
		replace CAMT=mca[1,`v'] in `v'
	}

	preserve	
		keep  CSHR CAMT
		order CSHR CAMT
		keep if CSHR!=.
		export delimited using "${temp}mat_counter_comm.csv", delimiter(",") replace
		g id=_n
		save "${temp}geo_comm.dta", replace
	restore
end


cap prog drop export_geo
prog def export_geo


	foreach v in co_B co_cv co_as co_asc co_nf  {
		est use "${temp}`v'"
		est sto `v'
	}

	estout co_B co_cv co_as co_asc co_nf  using "${output}reg_geo.tex", replace  style(tex) ///
	 keep(  ZM_*_post_treated  ) ///
	order(  ZM_*_post_treated  ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats(   r2 N  , ///
		  labels( "$\text{R}^{2}$"  "N"  )  ///
		    fmt(   %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

	preserve
		use "${temp}geo.dta", clear
		merge 1:1 id using "${temp}geo_comm.dta", keep(3) nogen
		g CS = CSe + BSe
		g PS = Ae + CSHR*CAMT
		g E  = 116
		g Lbar = CPe

		file open newfile using "${output}geo_inputs.tex", write replace
			forvalues r=1/`=_N' {
				local valuew=string(W[`r'],"%12.2fc")
				local value1=string(CS[`r'],"%12.0fc")
				local value2=string(PS[`r'],"%12.0fc")
				local value3=string(E[`r'],"%12.0fc")
				local value4=string(Lbar[`r'],"%12.0fc")
				file write newfile " `r' & `valuew' & `value1' & `value2' & `value3' \\" _n
			}
		file close newfile
	restore

end




*** PRINT PROGRAMS ***

cap prog drop print_mean2s
program print_mean2s
    qui mean `2' [pweight = SHO ] if cch==1 & paws==1
    mat j=e(b)
    local value1=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if cch==2  & paws==1
    mat j=e(b)
    local value2=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if cch==3  & paws==1
    mat j=e(b)
    local value3=string(`=j[1,1]*`4'',"`3'")
    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


cap prog drop print_mean2Ns
program print_mean2Ns
    qui sum `2' if cch==1 & paws==1, detail 
    local value1=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==2 &  paws==1, detail 
    local value2=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==3 &  paws==1, detail 
    local value3=string(`=r(N)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end

cap prog drop print_mean2
program print_mean2
    qui mean `2' [pweight = SHO ] if treated==1 & post==0 & paws==1
    mat j=e(b)
    local value1=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if treated==1 & post==1 & paws==1
    mat j=e(b)
    local value2=string(`=j[1,1]*`4'',"`3'")
    qui mean `2' [pweight = SHO ] if paws==1
    mat j=e(b)
    local value3=string(`=j[1,1]*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


cap prog drop print_mean2n
program print_mean2n
    qui sum `2' if minpost==0 & post==0, detail 
    local value1=string(`=r(N)*`4'',"`3'")
    qui sum `2' if minpost==0 & post==1, detail 
    local value2=string(`=r(N)*`4'',"`3'")
    qui sum `2', detail 
    local value3=string(`=r(N)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


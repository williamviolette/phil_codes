* pressure.do



*** SHARING INCREASES WITH PIPE FIXES! (but only by a tiny amount..)

**  new accounts are still a mystery........... ( and come into play with uncertainty over pipe fixes... )



* use "${temp}bill_paws_full.dta", clear
* 	tsset conacct date
* 	tsfill, full
* 		fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
* 		drop if date<datec
* 	keep c conacct date class read
* save "${temp}bill_paws_full_ts.dta", replace



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



		use "${data}paws/clean/full_sample_b_1.dta", clear

		destring may_exp_extra, replace force
		ren may_exp_extra me

		foreach v in 6_noon noon_6 6_mid mid_6 {
			g fl_`v' = 1 if flow_`v'=="Wala"
			replace fl_`v'=2 if flow_`v'=="Mahina"
			replace fl_`v'=3 if flow_`v'=="Katamtaman"
			replace fl_`v'=4 if flow_`v'=="Malakas"
		}

		replace drink_freq="3" if drink_freq=="Palagi"
		replace drink_freq="2" if drink_freq=="Madalas"
		replace drink_freq="1" if drink_freq=="Minsan"

		replace filter="1" if filter=="Oo"
		replace filter="0" if filter=="Hindi"

		destring drink_freq filter, replace force
		g yes_flow = flow_noon_6=="Malakas"
		g no_flow=flow_noon_6=="Wala"
		destring flow_hrs, replace force
		replace flow_hrs = . if flow_hrs==0

		g yr=substr(interview_completion_date,1,4)
		g mn=substr(interview_completion_date,6,2)
		destring yr mn, replace force
		g date=ym(yr,mn)
		ren yr year
		drop mn

		g balde= storage=="Balde"
		g drum= storage=="Drum"
		g gallon= storage=="Galon"

		destring hhsize, replace force
		g hhsize1 = hhsize
		replace hhsize1=. if hhsize>12

		destring shr_hh_extra, replace force
		ren shr_hh_extra SHO
		replace SHO=1 if SHO==. & wave==4
		replace SHO=4 if SHO>4 & SHO<.
 			g SHH = shr_num_extra
			destring SHH, replace force
			g hho= SHH - hhsize1
			replace hho=0 if hho<0
		replace SHO = 2 if hho>0 & hho<=5 & wave==3
		replace SHO = 3 if hho>5 & hho<=11 & wave==3
		replace SHO = 4 if hho>11 & hho<. & wave==3
		replace SHO = 1 if hho==0 & wave==3

		g B = booster=="Oo"
		g S = storage!=""
		destring hhemp, replace force

			drop age
			ren age age
			destring age, replace force
		
		**** KEY DROP SECTION ****
		drop if hhemp>12
		drop if hhsize>16
		drop if SHO==.
		* drop if age>100 | age<12
		

			g sub=regexm(house,"Subdivided")==1
			g single=regexm(house,"Single house")==1

			ren drink drink_id
			g drink = 0 if drink_id=="Hindi"
			replace drink = 1 if drink_id=="Oo"
			ren boil boil_id
			g boil = 0 if boil_id=="Hindi"
			replace boil = 1 if boil_id == "Oo"

			destring wrs_exp_extra alt_src_extra, replace force
			g wrs = alt_src_extra
			replace wrs = wrs_exp_extra if wrs==. & wrs_exp_extra!=.

			g wrs_type = 1 if regexm(alt_src,"refill")==1
			replace wrs_type = 2 if regexm(alt_src,"Deep")==1 | regexm(alt_src,"Pribado")==1  | regexm(alt_src,"Iba pang")==1
			replace wrs_type = 0 if wrs_type==.

			destring job, replace force
			ren class sclass

		keep date year me conacct  SHO drink_freq filter fl_* hhsize drink boil wrs wrs_type no_flow yes_flow flow_hrs barangay B S wave balde drum gallon sub single hhemp hho job age  sclass

		merge 1:1 conacct wave using "${temp}paws_prefs_b.dta", keep(1 3) nogen

		ren pf_qual_flow pf_qual_compl
		recode booster_need (0 = 1) (1=0)
			duplicates drop conacct date, force
		save "${temp}paws_aib1.dta", replace





use "${temp}bill_paws_full_ts.dta", clear

gegen class_max=max(class), by(conacct)
keep if class_max<=2
gegen class_min=min(class), by(conacct)

	fmerge m:1 conacct date using "${temp}paws_aib1.dta", keep(1 3) nogen
	drop year
	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen
	drop if date<datec
	drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
	fmerge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen

	g amt = amount if amount>0 & amount<10000

g dated=dofm(date)
g year=year(dated)

g post = year>=year_inst & year_inst<.
g sem = class==2

gegen minpost=min(post), by(mru)
g treated=minpost==0

g month = month(dated)


g w3_id = wave==3
g w4_id = wave==4
g w5_id = wave==5
gegen w3=max(w3_id), by(conacct)
gegen w4=max(w4_id), by(conacct)
gegen w5=max(w5_id), by(conacct)
drop w3_id w4_id w5_id

g good_job =  job>=3 & job<.

g booster_use1= booster_use
replace booster_use1=. if booster_use==24
sum booster_use1, detail


sum B if post==0 & minpost==0
global rpre=`=r(mean)'
sum B if post==1 & minpost==0
global rpost=`=r(mean)'
disp $rpost-$rpre

* sum c, detail 
g mc = 28 // plug in AVERAGE consumption

g p1 = amt/c
replace p1 = . if p1<5 | p1>100
replace p1= . if c!=mc

gegen pa = mean(p1), by(date class)

g pa_adj = pa
replace pa_adj = 15.6 if (date==584 | date==585)  &  class==1
replace pa_adj = 21 if (date==584 | date==585 | date==587 | date==588 | date==590 | date==591)  &  class==2

* gegen dct=tag(class date)
* twoway scatter pa_adj date if dct==1


foreach v in B  filter drum SHO hho hhsize sub single hhemp good_job {
	g `v'_3_id = `v' if wave==3
	g `v'_4_id = `v' if wave==4
	g `v'_5_id = `v' if wave==5
	
	gegen `v'_3 = max(`v'_3_id), by(conacct)
	gegen `v'_4 = max(`v'_4_id), by(conacct)
	gegen `v'_5 = max(`v'_5_id), by(conacct)
	drop  `v'_3_id `v'_4_id `v'_5_id

	replace `v' = `v'_3 if year<=2010 & w3==1 & w4==0 & w5==0
	replace `v' = `v'_4 if year<=2010 & w3==0 & w4==1 & w5==0
	replace `v' = `v'_5 if year>=2010 & w3==0 & w4==0 & w5==1

	replace `v' = `v'_4 if year<2010  & w3==0 & w4==1 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==0 & w4==1 & w5==1

	replace `v' = `v'_3 if year<2010  & w3==1 & w4==0 & w5==1
	replace `v' = `v'_5 if year>=2010 & w3==1 & w4==0 & w5==1

	replace `v' = `v'_3 if year<2009  & w3==1 & w4==1 & w5==0
	replace `v' = `v'_4 if year>=2009 & w3==1 & w4==1 & w5==0

	replace `v' = `v'_3 if year==2008 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_4 if year==2009 & w3==1 & w4==1 & w5==1
	replace `v' = `v'_5 if year==2010 & w3==1 & w4==1 & w5==1

	drop `v'_3 `v'_4 `v'_5
}

* g class_change = class_max!=class_min
	* reg c  post B pa_adj i.class_max class_change treated i.date 
	* reg c  post B pa_adj i.class_max class_change treated  hhsize hhemp good_job  i.date
	* areg c post pa_adj  i.class_max class_change i.date,  a(mru)
	* areg c post pa_adj i.date,  a(conacct)

g tot_hh =  hho+hhsize
g c_shr  = hhsize/tot_hh

g cv = c*c_shr

cap drop rng_id 
cap drop md
cap drop cn
cap drop rd

set seed 3
g rng_id = runiform()
gegen md=min(date), by(conacct)
replace md = 0 if md==date
sort md rng_id conacct
g cn=_n
gegen rd = min(cn), by(conacct)

g cch = class_max==class_min
sort cch md rng_id conacct
by cch: g cnch=_n
gegen rdch=min(cnch), by(conacct)

	foreach var of varlist  cv B post pa_adj year month  class_max class_min hhsize hhemp good_job  SHO {
		drop if `var'==.
	}

save "${temp}final_analysis.dta", replace








use "${temp}final_analysis.dta", clear

	keep if cv<150
	drop if date==653
	g clmax=class_max==2
	g clmin=class_min==2
 	g class_change = class_max!=class_min
gegen dateg=group(date)
	g post_treated=post*treated

g paws=smell!=.

**** HOUSEHOLD SAMPLE! ****
* keep conacct SHO date 

gegen ctag=tag(conacct)

forvalues r=1/4 {
	count if SHO==`r' & ctag==1
	global N_S`r' = (1/(5-`r'))*`=r(N)'
}

set seed 3
g ri = runiform()
replace ri=. if ctag!=1
gegen rn = max(ri), by(conacct)
g rs = rn
replace rn = 0 if class_change==1

gegen md1 = min(date), by(conacct)
g SHO1id=SHO if md1==date
gegen SHO1 = max(SHO1id), by(conacct)
replace md1 = 0 if md1==date
sort SHO1 md1 rn conacct
by SHO1: g cn1=_n
gegen rd1 = min(cn1), by(conacct)

g 		es = rd1<=$N_S1  if  SHO1==1
replace es = rd1<=$N_S2  if  SHO1==2
replace es = rd1<=$N_S3  if  SHO1==3
replace es = rd1<=$N_S4  if  SHO1==4

sort rs

* sum pa_adj if class==1
* g pa_adj1 = `=r(mean)'  if class==1
* sum pa_adj if class==2
* replace pa_adj1 = `=r(mean)' if class==2

* foreach var of varlist B {
* 	gegen `var'_ma = max(B), by(year conacct)
* }
* foreach var of varlist cv post_treated pa_adj dateg clmax class_change hhsize hhemp good_job treated SHO {
* 	gegen `var'_m = mean(`var'), by(year conacct)
* }
* gegen year_tag = tag(year conacct)

* gegen pa_adj_min = min(pa_adj), by(year conacct)

gegen datem=min(date), by(conacct)
g classm_id=class if datem==date
gegen classm=min(classm_id), by(conacct)
g semm = classm==2 & class_change==1
g resm = classm==1 & class_change==1

g post_treated_B=B*post_treated

* g post_treated_drum=drum*post_treated
* g post_treated_filter = filter*post_treated
* 	areg cv pa_adj post_treated B post_treated_B clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)
* 	areg cv pa_adj post_treated B post_treated_B clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)
* 	areg cv pa_adj post_treated drum post_treated_drum clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)
* 	areg cv pa_adj post_treated B post_treated_B  filter post_treated_filter clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru)
* 	areg filter  post_treated clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)
* 	areg B       post_treated clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)
* 	areg drum      post_treated clmax semm resm treated hhsize hhemp good_job  i.date if es==1, a(mru) cluster(mru)


	reg cv pa_adj post_treated B post_treated_B clmax semm resm treated  i.date [pweight = SHO]

	reg cv pa_adj post_treated B post_treated_B clmax semm resm treated hhsize hhemp good_job  i.date [pweight = SHO]

	areg cv pa_adj post_treated B post_treated_B clmax semm resm treated hhsize hhemp good_job  i.date [pweight = SHO], a(mru) cluster(mru)

	areg cv pa_adj post_treated post_treated_B i.date [pweight = SHO], a(conacct) 


mat def EB = e(b)

g alpha1 = -EB[1,1]
g theta1 = EB[1,2]
g theta2 = EB[1,3]
g theta3 = EB[1,4]

predict fv, xb
g alpha0 = fv - (  - alpha1*pa_adj + theta1*post_treated + theta2*B + theta3*post_treated_B)

preserve
	keep if es==1
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	keep B alpha0 alpha1 theta1 theta2 theta3 post_treated pa_adj
   order B alpha0 alpha1 theta1 theta2 theta3 post_treated pa_adj
   export delimited "${temp}booster_sample_2s.csv", delimiter(",") replace
restore




preserve
	keep if es==1 & year_tag==1
	* keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	keep cv_m B_ma post_treated_m pa_adj_m year clmax_m class_change_m hhsize_m hhemp_m good_job_m treated_m SHO_m
   order cv_m B_ma post_treated_m pa_adj_m year clmax_m class_change_m hhsize_m hhemp_m good_job_m treated_m SHO_m
   export delimited "${temp}booster_sample_year.csv", delimiter(",") replace
restore


preserve
	keep if es==1
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	keep cv B post_treated pa_adj dateg clmax class_change hhsize hhemp good_job treated SHO
   order cv B post_treated pa_adj dateg clmax class_change hhsize hhemp good_job treated SHO
   export delimited "${temp}booster_sample_date.csv", delimiter(",") replace
restore

preserve
	keep if es==1
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	keep cv B post_treated pa_adj1 dateg clmax class_change hhsize hhemp good_job treated SHO
   order cv B post_treated pa_adj1 dateg clmax class_change hhsize hhemp good_job treated SHO
   export delimited "${temp}booster_sample_date_pa1.csv", delimiter(",") replace
restore


preserve 



* reg cv i.date
* predict cv_adj, resid
* sum cv
* replace cv_adj=cv_adj+`=r(mean)'

	reg cv  post_treated pa_adj1  B clmax class_change treated if es==1

	reg cv  post_treated pa_adj  B clmax class_change treated i.date,
	reg cv  post_treated pa_adj B clmax class_change  treated  hhsize hhemp good_job  i.date if es==1
	reg cv  post_treated pa_adj1 B clmax class_change  treated  hhsize hhemp good_job i.date if es==1

	reg cv  post_treated pa_adj1 B clmax class_change  treated  hhsize hhemp good_job i.year if es==1

	reg cv  post_treated pa_adj B clmax class_change  treated  hhsize hhemp good_job i.date if es==1

	reg cv  post_treated pa_adj1 B clmax class_change  treated  hhsize hhemp good_job i.year i.month if es==1




* browse date conacct SHO ctag ri rn md1 cn1 rd1 es
* g es = rn<=.25 if SHO==1
* replace es = rn<=.5 if SHO==2
* replace es = rn<=.75 if SHO==3
* replace es = rn<=1 if SHO==4

	lab var post_treated "After Pipe Replacement"
	lab var B "Use Booster Pump"
	lab var cv "Usage per Household (m3)"

	lab var pa_adj "Avg. Price (PhP)"
	lab var clmax "Ever High Price"
	lab var class_change "Ever Change Price"
	lab var treated "Pipe Replacement Area"
	lab var hhsize "Household Size"
	lab var hhemp "Employed Household Members"
	lab var good_job "High Skilled Employment"



preserve
	keep if es==1

	reg cv  post_treated pa_adj  B clmax class_change treated i.date,  cluster(mru)
		eststo cv1
		sum cv if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		* estadd local  ctrl_time2 ""
		estadd local  ctrl_place ""
		estadd local  ctrl_ind ""

	reg cv  post_treated pa_adj B clmax class_change  treated  hhsize hhemp good_job  i.date,  cluster(mru)
		eststo cv2
		sum cv if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		* estadd local  ctrl_time2 ""
		estadd local  ctrl_place ""
		estadd local  ctrl_ind ""

	areg cv  post_treated pa_adj B clmax class_change hhsize hhemp good_job  i.date,  a(mru) cluster(mru)
		eststo cv3
		sum cv if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		* estadd local  ctrl_time2 ""
		estadd local  ctrl_place "\checkmark"
		estadd local  ctrl_ind ""

	areg cv  post_treated pa_adj  i.date,  a(conacct)  cluster(mru)
		eststo cv4
		sum cv if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		* estadd local  ctrl_time2 "\checkmark"
		estadd local  ctrl_place ""
		estadd local  ctrl_ind "\checkmark"

restore



* ctrl_time2 

estout cv1 cv2 cv3 cv4 using "${output}cv_reg.tex", replace  style(tex) ///
	 keep(  post_treated pa_adj B  treated  clmax class_change hhsize hhemp good_job ) ///
	order(  post_treated  pa_adj B  treated clmax class_change  hhsize hhemp good_job ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean ctrl_time1 ctrl_place ctrl_ind r2 N , ///
		  labels( "Mean" "Calendar Month FE"  "Small-Area FE" "Household FE" "$\text{R}^{2}$" "N"  )  ///
		    fmt( %12.2fc  %12s   %12s %12s  %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 



preserve
	keep if es==1
	reg B  post_treated treated i.date, cluster(mru) r
			eststo B1
		sum B if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""

	reg B  post_treated pa_adj clmax class_change treated  hhsize hhemp good_job i.date, cluster(mru)
			eststo B2
		sum B if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place ""

	areg B post_treated pa_adj clmax class_change treated  hhsize hhemp good_job i.date, a(mru) cluster(mru)
			eststo B3
		sum B if e(sample)==1, detail
		estadd scalar varmean = `r(mean)'
		estadd local  ctrl_time1 "\checkmark"
		estadd local  ctrl_place "\checkmark"
restore

estout B1 B2 B3 using "${output}B_reg.tex", replace  style(tex) ///
	keep(   post_treated treated pa_adj clmax class_change  hhsize hhemp good_job ) ///
	order(  post_treated treated pa_adj clmax class_change   hhsize hhemp good_job ) ///
		  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(3) star ) se(par fmt(3)) ) ///
		  stats( varmean ctrl_time1 ctrl_place r2 N , ///
		  labels( "Mean" "Calendar Month FE"  "Small-Area FE" "$\text{R}^{2}$" "N"  )  ///
		    fmt( %12.2fc  %12s   %12s %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 






sum pa_adj if class==1
global p_r = `=r(mean)'
    local value=string($p_r ,"%12.1fc")
    file open newfile using "${output}p_r.tex", write replace
    file write newfile "`value'"
    file close newfile

sum pa_adj if class==2
global p_s = `=r(mean)'
    local value=string( $p_s ,"%12.1fc")
    file open newfile using "${output}p_s.tex", write replace
    file write newfile "`value'"
    file close newfile

* reg  cv p_H1  post B class_min class_max hhsize hhemp good_job  treated i.year i.month
* 	areg cv p_H1  post  i.year i.month, a(conacct) 





reg  cv pa_adj  post B class_min class_max hhsize hhemp good_job  treated i.year i.month
	areg cv pa_adj  post  i.year i.month, a(conacct)




preserve
	keep if (rdch<=10000 & cch==1) | (rdch<=10000 & cch==0)
	keep cv B post pa_adj year month class_max class_min hhsize hhemp good_job  SHO treated
   order cv B post pa_adj year month class_max class_min hhsize hhemp good_job  SHO treated
   export delimited "${temp}booster_sample1_2.csv", delimiter(",") replace
restore




preserve
	keep if (rdch<=1000 & cch==1) | (rdch<=10000 & cch==0)
	foreach var of varlist  cv B post pa_adj year month  class_max class_min hhsize hhemp good_job  SHO {
		drop if `var'==.
	}
	keep if cv<150
	keep cv B post pa_adj year month class_max class_min hhsize hhemp good_job  SHO treated
   order cv B post pa_adj year month class_max class_min hhsize hhemp good_job  SHO treated
   export delimited "${temp}booster_sample1_1.csv", delimiter(",") replace
restore





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





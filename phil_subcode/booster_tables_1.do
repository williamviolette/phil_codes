



grstyle init
grstyle set imesh, horizontal


cap prog drop print_blank
program print_blank
    forvalues r=1/$cat_num {
    file write newfile  " & "
    }    
    file write newfile " \\ " _n
end


cap prog drop in_stat_cg
program in_stat_cg
    preserve 
        `6' 
        qui sum `2', detail 
        local value=string(`=r(`3')',"`4'")
        if `5'==0 {
            file write `1' " & `value' "
        }
        if `5'==1 {
            file write  `1' " & [`value'] "
        }        
    restore 
end

cap prog drop print_1_cg
program print_1_cg
    file write newfile " `1' "
    foreach r in $cat_group {
        in_stat_cg newfile `2' `r' `3' "0" 
        }      
    file write newfile " \\ " _n
end

cap prog drop print_obs
program print_obs
    file write newfile " `1' "
        in_stat_cg newfile `2' mean `3' "0" 
    forvalues r=2/$cat_num {
      file write newfile " & "
    }    
    file write newfile " \\ " _n
end



cap prog drop print_mean
program print_mean
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${tables}`1'.tex", write replace
    file write newfile "`value'"
    file close newfile    
end


cap prog drop print_mean2
program print_mean2
    qui sum `2' if minpost==0 & post==0, detail 
    local value1=string(`=r(mean)*`4'',"`3'")
    qui sum `2' if minpost==0 & post==1, detail 
    local value2=string(`=r(mean)*`4'',"`3'")
    qui sum `2', detail 
    local value3=string(`=r(mean)*`4'',"`3'")

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




cap prog drop print_mean_sd
program print_mean_sd
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${tables}`1'_mean.tex", write replace
    file write newfile "`value'"
    file close newfile    

    local value=string(`=r(sd)*`4'',"`3'")
    file open newfile using "${tables}`1'_sd.tex", write replace
    file write newfile "`value'"
    file close newfile    
end

cap prog drop print_mean_csv
program print_mean_csv
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${moments}`1'.csv", write replace
    file write newfile "`value'"
    file close newfile    
end





use "${temp}paws_aib1.dta", clear

	
drop year
	fmerge m:1 conacct using  "${temp}conacct_rate.dta", keep(3) nogen

g class=1 if rateclass_key=="Residential"
replace class=2 if rateclass_key=="Semi-Business"
gegen class_max=max(class), by(conacct)
keep if class_max<=2
keep if datec<=580

drop zone_code dc bus_id rateclass_key bus
	fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(3) nogen
g dated=dofm(date)
g year=year(dated)
g month=month(dated)
g post = year>=year_inst & year_inst<.
gegen minpost=min(post), by(mru)

g no_flow_6mid = fl_6_mid==1
g yes_flow_6mid = fl_6_mid==4

g taste_smell= taste==1 | smell==1

replace booster_use = . if booster_use>=24

g deepwell = wrs_type==2
g station = wrs_type==1
g good_job = job>=3 & job<.

replace SHO=SHO-1


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
print_mean2 SHO   SHO   "%10.2fc" 1

print_mean2n pawsn B "%10.0fc" 1






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
g month=month(dated)

g post = year>=year_inst & year_inst<.
g sem = class==2

gegen minpost=min(post), by(mru)

g w3_id = wave==3
g w4_id = wave==4
g w5_id = wave==5
gegen w3=max(w3_id), by(conacct)
gegen w4=max(w4_id), by(conacct)
gegen w5=max(w5_id), by(conacct)
drop w3_id w4_id w5_id

g good_job = 0 if job!=.
replace good_job=1 if job>=3 & job<.

g booster_use1= booster_use
replace booster_use1=. if booster_use==24
sum booster_use1, detail


foreach v in B SHO hhsize sub single hhemp good_job drum {
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


g cv = c/SHO


merge m:1 date using "${temp}prices_5r_nocpi.dta", nogen keep(1 3)
ren p_* rp_*
merge m:1 date using "${temp}prices_5s_nocpi.dta", nogen keep(1 3)
ren p_* sp_*
merge m:1 date using "${temp}prices_5r.dta", nogen keep(1 3)
ren p_* rcp_*


g p = amt/c
sum p, detail
replace p=. if p>`=r(p99)'

sum c, detail
global c_25p=`=r(p25)'
global c_50p=`=r(p50)'
global c_75p=`=r(p75)'

	sum p if c<$c_25p & class==1, detail
		global p_q1=`=r(mean)'
	sum p if c>=$c_25p & c<$c_50p & class==1, detail
		global p_q2=`=r(mean)'
	sum p if c>=$c_50p & c<$c_75p & class==1, detail
		global p_q3=`=r(mean)'
	sum p if c>=$c_75p & class==1, detail
		global p_q4=`=r(mean)'

g p_r = ($p_q1 + $p_q2 + $p_q3 + $p_q4)/4

	sum p if c<$c_25p & class==2, detail
		global p2_q1=`=r(mean)'
	sum p if c>=$c_25p & c<$c_50p & class==2, detail
		global p2_q2=`=r(mean)'
	sum p if c>=$c_50p & c<$c_75p & class==2, detail
		global p2_q3=`=r(mean)'
	sum p if c>=$c_75p & class==2, detail
		global p2_q4=`=r(mean)'

g p_s = ($p2_q1 + $p2_q2 + $p2_q3 + $p2_q4)/4


sum p_r
global p_r = `=r(mean)'
    local value=string($p_r ,"%12.1fc")
    file open newfile using "${output}p_r.tex", write replace
    file write newfile "`value'"
    file close newfile

sum p_s
global p_s = `=r(mean)'
    local value=string( $p_s ,"%12.1fc")
    file open newfile using "${output}p_s.tex", write replace
    file write newfile "`value'"
    file close newfile





g cv1=cv
replace cv1=. if cv1>200 | datec<560
gegen cvm= mean(cv1), by(date)

gegen dt=tag(date)
g date1=date
format date1 %tm

sort date dt

lab var cvm "Avg. Usage (m3)"
lab var date1 "Date"
lab var rp_H1 "Price 10-20 (m3)"
lab var rp_H2 "Price 20-40 (m3)"
lab var rp_H3 "Price 40-60 (m3)"

line rp_H1 date1 if dt==1 || ///
line rp_H2 date1 if dt==1 || ///
line rp_H3 date1 if dt==1 || ///
line cvm date1 if dt==1 , yaxis(2) lpattern(dash)  ///
legend(order(1 "Price 10-20 (m3)" 2 "Price 20-40 (m3)"  ///
3 "Price 40-60 (m3)" 4 "Avg. Usage (m3)"  ) symx(6) col(1) ///
    ring(0) position(11) region(lwidth(none))) ytitle("Price (PhP per m3)", axis(1))
graph export "${output}price_series.pdf", as(pdf) replace




g pT = year-year_inst
replace pT=. if pT>6 | pT<-6
replace pT=. if minpost!=0
gegen ptag=tag(pT)
gegen mcv = mean(cv), by(pT)

label var mcv "Usage per Household (m3)"
label var pT  "Years to Pipe Replacement"

sum mcv if ptag==1 & pT>=-4 & pT<0
global c_pre = `=r(mean)'
    local value=string($c_pre ,"%12.1fc")
    file open newfile using "${output}c_pre.tex", write replace
    file write newfile "`value'"
    file close newfile   

sum mcv if ptag==1 & pT>0 & pT<=6
global c_post = `=r(mean)'
    local value=string($c_post ,"%12.1fc")
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



twoway scatter mcv pT if ptag==1 & pT>=-4, ylabel(20(2)26) ///
	note("Avg. Pre:  `=string($c_pre ,"%12.1fc")'    Avg. Post:  `=string($c_post ,"%12.1fc")' ")
graph export "${output}pipe_cons.pdf", as(pdf) replace 






****** R TO S ANALYSIS ! ********
sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g year_rs_id = year if r_to_s_id==1
* replace year_rs_id=. if year_rs_id==577
gegen year_rs = min(year_rs_id), by(conacct)

by conacct: g date_sr_id = date if class[_n]==2 & class[_n+1]==1
gegen date_sr=min(date_sr_id), by(conacct)

by conacct: g year_sr_id = year if class[_n]==2 & class[_n+1]==1
gegen year_sr=min(year_sr_id), by(conacct)


cap drop Trs
cap drop Tsr
cap drop cv_rs
cap drop cv_sr
cap drop rstag
cap drop srtag

g Trs = year-year_rs
replace Trs=. if Trs>6 | Trs<-6
g Tsr = year-year_sr
replace Tsr=. if Tsr>6 | Tsr<-6

* g Trs = date-date_rs
* replace Trs=. if Trs>48 | Trs<-48
* replace Trs=round(Trs,12)
* g Tsr = date-date_sr
* replace Tsr=. if Tsr>48 | Tsr<-48
* replace Tsr=round(Tsr,12)

gegen cv_rs = mean(cv), by(Trs)
gegen cv_sr = mean(cv), by(Tsr)

gegen rstag=tag(Trs)
gegen srtag=tag(Tsr)

lab var cv_rs "Regular Price to High Price"
lab var cv_sr "High Price to Regular Price"

lab var Trs "Years to Price Change"
lab var Tsr "Years to Price Change"

twoway 	scatter cv_sr Tsr if srtag==1 & Tsr>=-4 & Tsr<=4, ylabel(22(4)30) msymbol(triangle) msize(medium)  || ///
		scatter cv_rs Trs if rstag==1 & Trs>=-4 & Trs<=4, ylabel(22(4)30)  ///
		legend(order(2 "Regular Price to High Price" 1 "High Price to Regular Price") symx(6) col(1) ///
    ring(0) position(2) bm(medium) rowgap(small)  ///
    colgap(small) size(*.95) region(lwidth(none)))

graph export "${output}r_to_s_graph.pdf", as(pdf) replace


foreach v in rs sr {
	 * local v "rs"
	sum cv_`v' if `v'tag==1 & T`v'>=-4 & T`v'<0
	global c_pre_`v' = `=r(mean)'
	    local value=string(${c_pre_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_pre_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   
	sum cv_`v' if `v'tag==1 & T`v'>=0 & T`v'<=4
	global c_post_`v' = `=r(mean)'
	    local value=string(${c_post_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_post_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   

	    local value=string(${c_post_`v'} - ${c_pre_`v'} ,"%12.1fc")
	    file open newfile using "${output}c_diff_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   

		local value=string(100*(${c_post_`v'} - ${c_pre_`v'} )/${c_pre_`v'} ,"%12.0fc")
	    file open newfile using "${output}c_diff_per_`v'.tex", write replace
	    file write newfile "`value'"
	    file close newfile   
}


g class_ch=class_max!=class_min
g cch = class
replace cch=3 if class_ch==1

cap prog drop print_mean2s
program print_mean2s
    qui sum `2' if cch==1 & fl_6_mid!=., detail 
    local value1=string(`=r(mean)*`4'',"`3'")
    qui sum `2' if cch==2 & fl_6_mid!=., detail 
    local value2=string(`=r(mean)*`4'',"`3'")
    qui sum `2' if cch==3 & fl_6_mid!=., detail 
    local value3=string(`=r(mean)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end

cap prog drop print_mean2Ns
program print_mean2Ns
    qui sum `2' if cch==1 & fl_6_mid!=., detail 
    local value1=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==2 & fl_6_mid!=., detail 
    local value2=string(`=r(N)*`4'',"`3'")
    qui sum `2' if cch==3 & fl_6_mid!=., detail 
    local value3=string(`=r(N)*`4'',"`3'")

    file open newfile using "${output}`1'.tex", write replace
    file write newfile "`value1' & `value2' & `value3'"
    file close newfile    
end


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




**** MAKE PRICE GRAPH! ****




g np = amount/c
replace np=. if np<10 | np>100

g namount=amount
sum namount, detail
replace namount  = . if namount<10 | namount>5000
gegen mamount = mean(namount), by(c class)

gegen ctag=tag(c class)

sort ctag class c
by ctag class: g mch=mamount[_n]-mamount[_n-1]

* browse c class mch if ctag==1

g bracket = 1 if c>10 & c<=20 
replace bracket = 2 if c>20 & c<=40
replace bracket = 3 if c>40 & c<=60

gegen mp = mean(mch), by(ctag class bracket)
replace mp=0 if c<=10


preserve
	keep if ctag==1
	keep class c mp 

	expand 100
	sort class c
	by class c: g cn=_n/100
	replace c= c+cn

	lab var mp "Price per m3"
	lab var c "Monthly Consumption (m3)"
	twoway line mp c if class==1 & c<=60, lw(thick) color(green) ||  ///
		   line mp c if class==2 & c<=60,  lp(dash) lw(thick)  color(orange) ///
		   legend(order(2 "High Price" 1 "Low Price") symx(6) col(1) ///
	    ring(0) position(5) bm(medium) rowgap(small)  ///
	    colgap(small) size(*.95) region(lwidth(none)))
	graph export "${output}rs_prices.pdf", as(pdf) replace
restore



g o=1
cap drop c_read
cap drop NN
cap drop NNs
cap drop nr
cap drop crtag

g c_read = c if read==1 & c<=60
gegen NN=sum(o), by(c_read)
gegen crtag= tag(c_read)
replace NN=. if crtag!=1
gegen NNs=sum(NN)
g nr = NN/NNs


lab var nr " "
lab var c_read "Monthly Consumption (m3)"
twoway scatter nr c_read if crtag==1
graph export "${output}consumption_histogram.pdf", replace as(pdf)



 g pan=namount/c if c>20 & c<=30
gegen panm=mean(pan), by(year class)


areg cv post panm year if class==1, a(conacct)


areg cv post panm year, a(conacct)



areg cv post panm year if class==1 & date>600, a(conacct)





cap drop pa
cap drop pam
cap drop ytag
cap drop cnm
cap drop cnms
cap drop cva
cap drop cy

g pa = namount/c if c==25
replace pa=. if pa<12 | pa>30

gegen pam=mean(pa), by(year)
gegen ytag=tag(year)

g cnm=c!=.
gegen cnms=sum(cnm), by(conacct)
g cva=cv if cnms>80 & cnms<.

gegen cy=mean(cva), by(year)

scatter pam year if ytag==1 || ///
scatter cy year if ytag==1, yaxis(2)



cap drop mamount1
cap drop ctag1
cap drop mch1


gegen mamount1 = mean(namount), by(c class date)
gegen ctag1=tag(class date c)
sort ctag1 class date c 
by ctag1 class date: g mch1=mamount1[_n]-mamount1[_n-1]


gegen cy1 = mean(cva), by(date class)
gegen dtag1 = tag(date class)





scatter cy1 date if class==1 & dtag==1 || ///
scatter mch1 date if c==25 & ctag1==1 & class==1, yaxis(2)


browse class date c mch1 if ctag1==1

browse class date c mch1 if ctag1==1 & c==25




gegen mamount1 = mean(namount), by(c class year)
gegen ctag1=tag(class year c)
sort ctag1 class year c 
by ctag1 class year: g mch1=mamount1[_n]-mamount1[_n-1]

browse class year c mch1 if ctag1==1

browse class year c mch1 if ctag1==1 & c==25



* replace Trs=1000 if Trs>48 | Trs<-48
* replace Trs=Trs+100
* replace Trs=1 if Trs==1100

* replace Tsr=1000 if Tsr>48 | Tsr<-48
* replace Tsr=Tsr+100
* replace Tsr=1 if Tsr==1100

*** increase in spending, avg increase in water cons



* gegen std = sd(cv), by(pT)
* gegen sdw= sd(cv), by(conacct year)
* g cv_no10=cv if pT!=10
* gegen stdp=sd(cv_no10), by(post minpost)
* gegen sdwp=sd(cv_no10), by(conacct post minpost)
* gegen std1 = mean(sdw), by(pT)
* gegen ptag=tag(pT)
* twoway scatter mcv pT if ptag==1 & pT>=6 & pT<=16
* sum sdw if post==0 & minpost==0
* sum sdw if post==1 & minpost==0 & pT!=10
* sum sdwp if post==0 & minpost==0 & pT!=10
* sum sdwp if post==1 & minpost==0 & pT!=10
* sum stdp if post==0 & minpost==0
* sum stdp if post==1 & minpost==0 & pT!=10
* sum std if post==0 & minpost==0
* sum std if post==1 & minpost==0 & pT!=10
* twoway scatter std1 pT if ptag==1 & pT>=6 & pT<=16 & pT!=10
* scatter std pT if ptag==1 & pT>=6 & pT<=16 & pT!=10, yaxis(2)
* * twoway scatter std pT if ptag==1 & pT>=6 & pT<=16 & pT!=10
* g coefv=mcv/std
* twoway scatter coefv pT if ptag==1 & pT>=6 & pT<=16 & pT!=10
* g post_other  =  post==1 & minpost==1
* g post_alt    =  post==1 & minpost==0
* g treated=minpost==0
* reg  cv post treated i.year 
* areg cv post i.year , a(conacct)
* reg  cv post_alt post_other i.year 
* gegen msd=sd(c), by(mru year)
* gegen myt=tag(mru year)
* areg msd post i.year if myt==1 & pT!=10 & minpost==0, a(mru)
* areg std post i.year if pT!=10  & minpost==0, a(mru)



*** 
* cap drop cvm
* cap drop mtag
* gegen cvm=mean(cv), by(post month minpost)
* gegen mtag=tag(month post minpost)
* twoway scatter cvm month if mtag==1 & post==0  & minpost==0 || ///
* 	   scatter cvm month if mtag==1 & post==1  & minpost==0 
* sort mtag minpost month post
* by mtag minpost month: g cdiff = cvm[_n]-cvm[_n-1]
* twoway  scatter cdiff month if mtag==1 & post==1  & minpost==0 








* g no_flow_6mid = fl_6_mid==1
* g yes_flow_6mid = fl_6_mid==4
* g taste_smell= taste==1 | smell==1
* foreach var of varlist no_flow_6mid yes_flow_6mid taste_smell {
* 	replace `var'=. if fl_6_mid==.
* }
* reg c flow_hrs i.year if minpost==0
* ivregress 2sls c i.year (flow_hrs=post i.year) if minpost==0
* reg no_flow_6mid good_job SHO sub single hhsize hhemp i.year if minpost==0 & fl_6_mid!=., cluster(mru)
* areg stuff        post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg taste_smell  post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg no_flow_6mid post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg stuff        post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg taste_smell  post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg no_flow_6mid post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg no_flow_6mid post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg no_flow_6mid post B good_job SHO sub single hhsize hhemp i.year, a(mru) cluster(mru)
* areg no_flow_6mid post good_job SHO sub single hhsize hhemp i.year if B==0, a(mru) cluster(mru)





/*

*** FIND MONTHS WITH LOW DEMAND! ***

use "${temp}nrw.dta", clear

merge m:1 dma using "${temp}pipe_year_old_dma.dta", keep(1 3) nogen

g ba_id=substr(dma,4,3)
replace ba_id = lower(ba_id)
gegen ba=group(ba_id)

		g dated=dofm(date)
		g year=year(dated)
		g month=month(dated)
		drop dated

	g pT = year-year_inst
	replace pT=1000 if pT>6 | pT<-4
	replace pT=pT+10
	replace pT=1 if pT==1010

	gegen mpT=min(pT), by(dma)
	* replace pT=1010 if mpT>=10	
	* replace pT=1010 if shr<.7
	gegen dg = group(dma)

	g nrw = 1 - (bill/supp)
	replace nrw=0 if nrw<0

	gegen yt=tag(dg year)

gegen nrwm=mean(nrw), by(dg year)
gegen billm=mean(bill), by(dg year)
gegen suppm=mean(supp), by(dg year)

g ln_billm=log(billm)
g ln_suppm=log(suppm)

xi: areg nrwm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg billm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg suppm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg ln_billm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical

xi: areg ln_suppm i.pT i.year*i.ba if yt==1 , a(dg) cluster(dg) r 
	coefplot, keep(*pT*) vertical


g post= year>=year_inst
gegen minpost=min(post), by(dg)


drop if pT==10

cap drop nrw_m
cap drop mtag

gegen nrw_m = mean(nrw), by(month minpost post)
gegen mtag=tag(month minpost post)

twoway scatter nrw_m month if mtag==1 & minpost==0 & post==0 || ///
	   scatter nrw_m month if mtag==1 & minpost==0 & post==1



**** USE PMP FOR IT TOO!

use "${temp}pmp_mean_total.dta", clear

		g dated=dofm(date)
		g year=year(dated)
		g month=month(dated)
gegen p_m = mean(pmean), by(month)
gegen mtag=tag(month)

twoway scatter p_m month if mtag==1




use "${temp}pmp_under_total.dta", clear
		g dated=dofm(date)
		g year=year(dated)
		g month=month(dated)
gegen p_m = mean(ps), by(month)
gegen mtag=tag(month)

twoway scatter p_m month if mtag==1



	

* reg hhemp post if minpost==0, cluster(mru) r
* reg hhemp post i.year if minpost==0, cluster(mru) r
* areg hhemp post i.year if minpost==0, a(mru) cluster(mru) r
* areg sub post i.year if minpost==0, a(mru) cluster(mru) r
* areg single post i.year if minpost==0, a(mru) cluster(mru) r
* areg good_job post i.year if minpost==0, a(mru) cluster(mru) r


* gegen npress = mean(no_flow_6mid), by(post month minpost)
* gegen ypress = mean(yes_flow_6mid), by(post month minpost)
* gegen fhpress = mean(flow_hrs), by(post month minpost)
* gegen fbpress = mean(stuff), by(post month minpost)
* gegen fbpress = mean(color), by(post month minpost)
* gegen ttag=tag(post month minpost)
* gegen mpress=mean(no_flow_6mid), by(month year)
* gegen mtag=tag(month year)
* bys month year: g MN=_N
* twoway scatter mpress month if mtag==1 & year==2008  & MN>1000 || ///
* 		scatter mpress month if mtag==1 & year==2009   & MN>1000 || ///
* 		scatter mpress month if mtag==1 & year==2011   & MN>1000 
* twoway scatter fhpress month if ttag==1 & post==0 & minpost==0 || ///
* 	   scatter fhpress month if ttag==1 & post==1 & minpost==0 
* twoway scatter ypress month if ttag==1 & post==0  & minpost==0 || ///
* 	   scatter ypress month if ttag==1 & post==1 & minpost==0 
* twoway scatter npress month if ttag==1 & post==0 || ///
* 	   scatter npress month if ttag==1 & post==1
* twoway scatter fbpress month if ttag==1 & post==0 || ///
* 	   scatter fbpress month if ttag==1 & post==1
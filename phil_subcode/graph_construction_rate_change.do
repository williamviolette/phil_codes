


global R_TO_S_DATA_PREP_ = 1

if $R_TO_S_DATA_PREP_ == 1 {
local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"

#delimit;
local bill_query "";

forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT  A.date, A.c, A.class, A.read,
	C.p_L, C.p_H1, C.p_H2, C.p_H3, B.*
	FROM billing_`r' AS A 
	JOIN `paws_data_selection' AS B 
		ON A.conacct = B.conacct
	JOIN price AS C
		ON A.date = C.date AND A.class = C.class
	WHERE A.class==1 OR A.class==2
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

duplicates   drop   conacct   date,  force

sort conacct date
by conacct: g R_to_S=class[_n-1]==1 & class[_n-2]==1 & class[_n-3]==1 & class[_n]==2 & class[_n+1]==2 & class[_n+2]==2
egen R_to_S_max = max(R_to_S), by(conacct)

save "${temp}r_to_s.dta", replace
}



use "${temp}r_to_s.dta", clear
		
		* keep if R_to_S_max == 1

*** START NEW TEST  ***
		ren SHH S1
		replace c = c/S1
		g SHH=S1>1
		g rsd_id=date if R_to_S==1 & date!=596
		gegen rsd=min(rsd_id), by(conacct)

		g T = date-rsd


		gegen mc=mean(c), by(T)
		gegen tt = tag(T)

		gegen ttshr=tag(T SHH)
		* twoway scatter mc T if tt==1 & T>=-36 & T<=36

		gegen mcshr=mean(c), by(T SHH)

		twoway scatter mc T if tt==1 & T>=-24 & T<=24


		twoway  scatter mcshr T if ttshr==1 & T>=-12 & T<=12 & SHH==0 || ///
				scatter mcshr T if ttshr==1 & T>=-12 & T<=12 & SHH==1 


		* twoway  scatter mcshr T if ttshr==1 & T>=-24 & T<=24 & SHH==1 || ///
		* 		scatter mcshr T if ttshr==1 & T>=-24 & T<=24 & SHH==2 || ///
		* 		scatter mcshr T if ttshr==1 & T>=-24 & T<=24 & SHH==3


		sort conacct date
		by conacct: g S_to_R =class[_n-1]==2 & class[_n]==2 & class[_n+1]==1 & class[_n+2]==1

		g srd_id=date if S_to_R==1
		gegen srd=min(srd_id), by(conacct)

		g Ts = date-srd

		gegen mcs=mean(c), by(Ts)
		gegen tts = tag(Ts)

		gegen mc_shr=mean(c), by(Ts SHH)
		gegen tts_shr = tag(Ts SHH)


		twoway scatter mcs Ts if tts==1 & Ts>=-24 & Ts<=24


		twoway  scatter mc_shr Ts if tts_shr==1 & Ts>=-24 & Ts<=24 & SHH==0 || ///
				scatter mc_shr Ts if tts_shr==1 & Ts>=-24 & Ts<=24 & SHH==1 

		* twoway  scatter mc_shr Ts if tts_shr==1 & Ts>=-24 & Ts<=24 & SHH==1 || ///
		* 		scatter mc_shr Ts if tts_shr==1 & Ts>=-24 & Ts<=24 & SHH==2 || ///
		* 		scatter mc_shr Ts if tts_shr==1 & Ts>=-24 & Ts<=24 & SHH==3

*** END NEW TEST  ***



		bys conacct: g c_n=_n==1
		egen S=sum(c_n)
		
		sum S, detail
	
		file open myfile using "${output}semi_sample_size.tex", write replace
			file write myfile "`=round(r(mean),1)'"
			file close myfile
			
	
		*	egen mp=max(p_H1), by(conacct)
		*	keep if mp<32
	*	drop if c>120
	*	g SEM=p_H1>25
	
		g SEM=class==2
	
		sort conacct date
		by conacct: g ch=SEM[_n]==1 & SEM[_n-1]==0
		
		 g ts=date if ch==1
		 egen tsd=max(ts), by(conacct)
		 g T=date-tsd
		 
		 g rid=uniform()
		 bys conacct: g RID=rid if _n==1
		 egen Rmax=max(RID), by(conacct)
		 
		 
		 keep if T!=. | Rmax<.1
		 
		 
		 g P = p_L if c<=10
		 replace P = p_H1 if c>10 & c<=20
		 replace P = p_H2 if c>20 & c<=40
		 replace P = p_H3 if c>40
		 
		 
		 preserve
		 
			scalar define TKEY1=13
			
			replace T=100 if T<-`=TKEY1' | T>`=TKEY1'
			
			tab T, g(TT_)
			
			foreach var of varlist TT_* {
			lab var `var' " "
			}
			lab var TT_`=TKEY1-12' "-12"
			lab var TT_`=TKEY1' "0"
			lab var TT_`=TKEY1+12' "12"
			
			 g TREAT=T>1 & T<100
			 g T_TREAT=T*TREAT 
			 
			 g ln_c=ln(c)
			 
			 xi: areg ln_c TREAT if T!=100 , absorb(conacct) cluster(conacct) robust
			 
			 matrix define G=e(b)
			 scalar define E=round(G[1,1],.1)
			 
			 g ln_p=ln(P)
			 
			 xi: areg ln_p TREAT if T!=100 , absorb(conacct) cluster(conacct) robust
			 
			 matrix define PCH=e(b)
			 scalar define P_ch=round(PCH[1,1],.1)
			 
			 scalar define ELASTICITY = E/P_ch
			 
		file open myfile using "${output}sempriceincrease.tex", write replace
		file write myfile "`=round(P_ch*100,1)'"
		file close myfile
		
		file open myfile using "${output}semelasticity.tex", write replace
		file write myfile "`=round(ELASTICITY*100,1)'"
		file close myfile
		
		
			 
			 xi: areg c TT_* i.date, absorb(conacct) cluster(conacct) robust
			 
				coefplot , keep(TT_*) ///
			 scheme(vg_outc) recast(line) lcolor("0 0 204") ciopts(lwidth(medium) ///
			lpattern(dash) lcolor("51 153 255") recast(rline)) msize(medlarge) vert ytitle("Cubic Meters per Month" , size(medsmall)) ///
			levels(95) xlabel(, labsize(medsmall)  angle(horizontal)) ylabel(-2(2)8, labsize(medsmall)) label ///
			title("Consumption After Upgradede to Semi-Business Rate", ///
			size(medsmall) color(black)) xtitle("Months to Upgrade to Semi-Business Rate") note(" Diff-in-Diff Elasticity Estimate: -0`=abs(ELASTICITY)' ")
		
		graph export "${output}sem_event.pdf", as(pdf) replace
		
		
		* TIME SERIES VARIATION IN PRICES		
		
		*** COMPARE MEANS BETWEEN SEMI AND NON-SEMI~!
		
		

use "${temp}r_to_s.dta", clear
	
	egen mc=mean(c), by(conacct)
	
	egen bill_max=max(class), by(conacct)

	
	g categories=0 if bill_max==1
	replace categories=1 if bill_max==2
	replace categories=2 if R_to_S_max==1
	
		
	duplicates drop conacct, force
	
			bys categories: g N=_N
	
	lab var mc "Cons. (avg.)"
**	lab var LEAK_SIZE "Leak Size"
	lab var age "Age HoH"
	lab var hhsize "HH Size"
	lab var hhemp  "HH Size Empl."
	lab var drink  "Drink"
**	lab var storage  "Water Storage"
	lab var flow 	"Water Flow"
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
	lab var low_skill "Low Skill Emp."
**	lab var SEM "Semi-Business"
	lab var N "Obs."
*	lab var NM "Family Nearby"
	
	** take out sem
	
	g sem_to_reg=1 if categories==1
	replace sem_to_reg=0 if categories==0
	
	g sem_to_change=1 if categories==2
	replace sem_to_change=0 if categories==0
	
	
	sort categories
	
	estpost sum mc  age hhsize hhemp low_skill    house_1 house_2  N if categories==0
	matrix meanf0=e(mean)
	matrix list meanf0

	estpost sum mc  age hhsize hhemp low_skill    house_1 house_2  N if categories==1
	matrix meanf1=e(mean)
	matrix list meanf1
	
	estpost sum mc  age hhsize hhemp low_skill   house_1 house_2  N if categories==2
	matrix meanf2=e(mean)
	matrix list meanf2
	
	
	estpost ttest mc age hhsize hhemp low_skill    house_1 house_2  N , by(sem_to_reg)
	matrix ttest_sem_to_reg=e(b)
	matrix ttest_sem_to_reg_se=e(se)
	
	
	estpost ttest mc age hhsize hhemp low_skill    house_1 house_2  N , by(sem_to_change)
	matrix ttest_sem_to_change=e(b)
	matrix ttest_sem_to_change_se=e(se)
	
	
	estadd matrix meanf0
	estadd matrix meanf1
	estadd matrix meanf2
	estadd matrix ttest_sem_to_reg
	estadd matrix ttest_sem_to_change
	estadd matrix ttest_sem_to_reg_se
	estadd matrix ttest_sem_to_change_se

	esttab using "${output}sem_compare_means.tex", ///
	noobs cells("meanf0(fmt(2)) meanf1(fmt(2)) meanf2(fmt(2)) ttest_sem_to_reg(star fmt(2))   ttest_sem_to_change(star fmt(2))  ") ///
	star(* 0.1 ** .05 *** 0.01) ///
collabels("Residential" "Semi-Business" "Upgraded to Semi-Business" "T-Test: Semi to Res"  "T-Test: Semi to Semi-Upgrade" ) tex replace label


* rm "${temp}r_to_s.dta"
		

	
	* INPUT : CSV "${generated}standard_${version}.csv", "${generated}alt_${version}.csv"
	* TEMP  : DTA "${temp}paws_temp_stats.dta", "${temp}alt.dta"

	
	** load

global LOAD_STATS_DATA = 0


if $LOAD_STATS_DATA == 1 {

	local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"

	local bill_query ""

	#delimit;
	forvalues r = 1/12 {;
		local bill_query "`bill_query' 
		SELECT AVG(A.c) AS mc, COUNT(*) AS T, B.*, p_L_avg, p_H1_avg, p_H2_avg, p_H3_avg, I.inc AS INC
		
		FROM (SELECT * FROM billing_`r' WHERE c<=100 AND date>600  AND date<664)  AS A 
		JOIN `paws_data_selection' AS B 
			ON A.conacct = B.conacct
		JOIN paws_inc AS I ON A.conacct = I.conacct
		JOIN (SELECT class, AVG(C.p_L) AS p_L_avg, AVG(C.p_H1) AS p_H1_avg, AVG(C.p_H2) AS p_H2_avg, AVG(C.p_H3) AS p_H3_avg 
				FROM price AS C GROUP BY class) AS C
			ON A.class = C.class
		WHERE A.class==1 OR A.class==2 GROUP BY A.conacct
		";
		if `r'!=12{;
			local bill_query "`bill_query' UNION ALL";
		};
	};
	#delimit cr;

	clear
	odbc load, exec("`bill_query'")  dsn("phil") clear  

		g bill = 150 if mc<=10 
		replace bill = 150 + (mc-10)*p_H1 if mc>10 & mc<=20
		replace bill = 150 + 10*p_H1 + (mc-20)*p_H2 if mc>20 & mc<=40
		replace bill = 150 + 10*p_H1 + 20*p_H2 + (mc-40)*p_H3 if mc>40

	save "${temp}paws_temp_stats.dta", replace

	odbc load, exec("SELECT A.* FROM census AS A ") dsn("phil") clear
	save "${temp}alt.dta", replace
}



use "${temp}paws_temp_stats.dta", clear
		append using "${temp}alt.dta"

	replace T = . if T>62


	** STAT 1: shr_use_from_neighbor.tex
		egen THH = sum(SHH) // total hhs
		sum alt
		replace THH = THH*(1+`=r(mean)')


		g hh2 = SHH == 2 
		egen hh2s = sum(hh2)
		g hh3 = SHH == 3
		egen hh3s = sum(hh3)

		g shr_use_from_neighbor = (hh2s + 2*hh3s)/THH
		sum shr_use_from_neighbor

	file open myfile using "${output}shr_use_from_neighbor.tex", write replace
	file write myfile "`=round((`=r(mean)')*100,1)'"
	file close myfile


	** STAT 2: shr_1or2hh.tex
		g shr_1or2hh = (2*hh2s + 3*hh3s)/THH
		sum shr_1or2hh

	file open myfile using "${output}shr_1or2hh.tex", write replace
	file write myfile "`=round((`=r(mean)')*100,1)'"
	file close myfile	


	** STAT 3: shr_individual.tex (share of connected that are individual)

	egen CHH = sum(SHH), by(SHH)

	egen THH_c = sum(SHH)

	egen shh_c = sum(SHH), by(SHH)
	g HH = shh_c / THH_c

	sum HH if SHH==1
	file open myfile using "${output}shr_individual.tex", write replace
	file write myfile "`=round(r(mean)*100,1)'"
	file close myfile
		
	sum HH if SHH==2
	scalar define hh2=r(mean)
	file open myfile using "${output}shr_1hh.tex", write replace
	file write myfile "`=round(r(mean)*100,1)'"
	file close myfile
		
	sum HH if SHH==3
	scalar define hh3=r(mean)
	file open myfile using "${output}shr_2hh.tex", write replace
	file write myfile "`=round(r(mean)*100,1)'"
	file close myfile

	** IMPUTE INCOME FOR ALT !!
		
		qui xi: reg INC i.hhsize*hhemp     i.low_skill*i.house_1 ///
						 i.low_skill*hhemp i.low_skill*age
					predict INC_alt, xb	
					
				replace INC=INC_alt if INC==.
				egen INC_alt1=mean(INC_alt), by(alt)
				replace INC=INC_alt1 if INC==.
				drop _* INC_alt*


	sum INC if SHH!=. & INC>0
	local inc_shr_temp "`=r(mean)'"

	sum INC if alt==1 & INC>0
	local inc_alt_temp "`=r(mean)'"
	
	sum alt
	local alt_mean_temp "`=r(mean)'"

	local mean_inc "`=`=`inc_shr_temp''*(1-`=`alt_mean_temp'') +`=`inc_alt_temp''*(`=`alt_mean_temp'')  '"
	disp `mean_inc'
			
	file open myfile using "${generated}tables/mean_inc_descriptive.csv", write replace
	file write myfile "`=round(`=`mean_inc'',1)'"
	file close myfile



	** CLEAN FOR TABLE

		g SHARE_2 = SHH==2
		g SHARE_3 = SHH==3
		
		replace SHH=4 if alt==1
		bys SHH: g N=_N
	
		g hhtot=SHO+hhsize
		g duplex=house_1==0 & house_2==0
		replace N=. if alt==1
		
		g vol_per=mc/hhtot
	
	** CONVERT TO DOLLARS !!!!
		
		replace INC = INC/50
		ren bill mb
		replace mb  = mb/50
		
			sum mc if SHH==1, detail
			file open myfile using "${output}cons_ind.csv", write replace
			file write myfile "`=round(r(mean),1)'"
			file close myfile
			
			sum mc if SHH==2, detail
			file open myfile using "${output}cons_shr1.csv", write replace
			file write myfile "`=round(r(mean),1)'"
			file close myfile
			
			sum mc if SHH==3, detail
			file open myfile using "${output}cons_shr2.csv", write replace
			file write myfile "`=round(r(mean),1)'"
			file close myfile
		
		g incshr = mb/INC
		
		sum incshr, detail
		file open myfile using "${output}incshr.tex", write replace
		file write myfile "`=round(r(mean)*100,1)'"
		file close myfile
		
		sum alt
		file open myfile using "${output}shr_alt.tex", write replace
		file write myfile "`=round(r(mean)*100,1)'"
		file close myfile


foreach var of varlist house_1 house_2 duplex low_skill HH {
replace `var'=`var'*100
}


*global varlist "hhtot mc vol_per hhsize house_1 house_2 duplex low_skill INC THH HH"

global varlist "age hhsize hhemp low_skill INC house_1 house_2 duplex   mc mb hhtot  vol_per   CHH HH T"


order $varlist

estpost sum $varlist if SHH==1
	matrix meanf1=e(mean)
	matrix list meanf1
	
estpost sum $varlist if SHH==2
	matrix meanf2=e(mean)
	matrix list meanf2

estpost sum $varlist if SHH==3
	matrix meanf3=e(mean)
	matrix list meanf3

*estpost sum $varlist if SHH==4
*	matrix meanf4=e(mean)
*	matrix list meanf4
	

	matrix A1 = (meanf1',meanf2',meanf3')

	
	lab values SHH shh
	lab var SHH "Water Source"
			
	lab var mc "Water (m3/mo.)"
	lab var hhtot "Total People Served"
	lab var vol_per "Water per Person"
	lab var hhsize "HH Size"	
	lab var hhemp "Employed HH Members"
	lab var age "Age HoH"	
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
	lab var duplex "Duplex"
	lab var low_skill "Low Skill Emp."
	lab var INC "Inc. USD/Mo. (Imputed)"
	
	lab var T "Months per Connection"
	lab var N "Total Accounts"
	lab var HH "Share of Total HHs"
		lab var CHH "Total HHs"
		
		lab var mb "Water Bill (USD/Mo)"
		

* global varlist "hhsize hhemp low_skill INC house_1 house_2 duplex   mc mb vol_per  hhtot THH HH T"	
	
matrix define FOR=J(15,1,2)
matrix FOR[1,1]=1

matrix FOR[13,1]=0
matrix FOR[15,1]=0
matrix FOR[4,1]=0
matrix FOR[5,1]=0
matrix FOR[6,1]=0
matrix FOR[7,1]=0
matrix FOR[8,1]=0
matrix FOR[14,1]=0


matrix define PER=J(15,1,0)
matrix PER[4,1]=1
matrix PER[6,1]=1
matrix PER[7,1]=1
matrix PER[8,1]=1
matrix PER[14,1]=1


g temp=""

replace temp = "Age (Head of HH)"	 	in 1
replace temp = "HH Size"	 	in 2
replace temp = "Total Empl."   	in 3
replace temp = "Low-Skill Emp. (Head of HH)"  	in 4
replace temp = "Inc. (USD/Mo. Imputed)" in 5
replace temp = "Apartment" 	in 6
replace temp = "Single House" 	in 7
replace temp = "Duplex" 		in 8
replace temp = "Water (m3/mo.)" in 9
replace temp = "Water Bill (USD/Mo)" in 10
replace temp = "Total People Served" in 11
replace temp = "Water per Person" in 12

replace temp = "Connected HHs" in 13
replace temp = "Share of Connected HHs" in 14
replace temp = "Months per Connection" in 15


g colnames1 = ""
g colnames2 = ""
replace colnames1 = "Serving One" in 1
replace colnames2 = "Household" in 1

replace colnames1 = "Serving Two" in 2
replace colnames2 = "Households" in 2

replace colnames1 = "Serving Three" in 3
replace colnames2 = "or More Households" in 3

replace colnames1 = "Served by" in 4
replace colnames2 = "Vendor" in 4


matrix DIM = ( 8 \ 4 \ 3 )


 program drop _all
	
	
program define tables `1' `2' `3' `4' `5' `6' `7' `8'
	file open fi using "${output}`1'.tex", write replace
	
	local COLS `=colsof(`2')'
	disp `COLS'	
	file write fi "\begin{tabular}{l*{1}{"	
	forvalues c=1/`COLS' {
		if `c'>1 {
		file write fi "c"
		}
		if `c'==`COLS' {
		file write fi  "c}}" _n		
		}
	}
	file write fi "\hline" _n
	file write fi "\hline " _n
	
	
*	file write fi "  & \multicolumn{3}{c}{ \textbf{PAWS} } & \textbf{Census} \\ \cmidrule(r){2-4} \cmidrule(l){5-5}" _n	 // HERE'S WHERE THE COLUMN NAMES ARE SET	
	*file write fi "\hline" _n
	file write fi " &" 
	forvalues c=1/`COLS' {
		if `c'!=`COLS' {
		file write fi "`=`5'[`c']' &"
		}
		if `c'==`COLS' {
		file write fi "`=`5'[`c']'  \\" _n		
		}
	}
	file write fi " &" 	
	forvalues c=1/`COLS' {
		if `c'!=`COLS' {
		file write fi "`=`6'[`c']' &"
		}
		if `c'==`COLS' {
		file write fi "`=`6'[`c']'  \\" _n		
		}
	}	
	*file write fi "\hline" _n  *** FIRST SECTION HERE 
	file write fi "\hline \\" _n	
	file write fi "\textbf{Owner Demographics} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	forvalues r=1/`=`7'[1,1]' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
		local PP " "
		if `8'[`r',1]==1 {
		local PP "\%"
		}
		if `c'!=`COLS' {
		file write fi  "`h'`PP' & "
		}
		if `c'==`COLS' {
		file write fi  "`h'`PP'  \\" _n		
		}		
		}
	}
			***  SECOND  SECTION HERE 
	file write fi "\hline \\" _n	
	file write fi "\textbf{Connection-Level Attributes} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	forvalues r=`=`7'[1,1]+1'/`=`7'[1,1]+`7'[2,1]' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
		local PP " "
		if `8'[`r',1]==1 {
		local PP "\%"
		}
		if `c'!=`COLS' {
		file write fi  "`h'`PP' & "
		}
		if `c'==`COLS' {
		file write fi  "`h'`PP'  \\" _n		
		}		
		}
	}
			***  THIRD  SECTION HERE 
	file write fi "\hline \\" _n	
	file write fi "\textbf{Sample Characteristics} &\multicolumn{`=`COLS''}{c}{ }\\" _n	
	file write fi "\hline" _n	
	forvalues r=`=`7'[1,1]+`7'[2,1]+1'/`=`7'[1,1]+`7'[2,1]+`7'[3,1]' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
		local PP " "
		if `8'[`r',1]==1 {
		local PP "\%"
		}
		if `c'!=`COLS' {
		file write fi  "`h'`PP' & "
		}
		if `c'==`COLS' {
		file write fi  "`h'`PP'  \\" _n		
		}		
		}
	}
	
	file write fi "\hline" _n
	file write fi "\hline" _n
	file write fi "\end{tabular}"
	file close fi
end			
		 
	tables new_descriptives A1 FOR temp colnames1 colnames2 DIM PER
	
	
	
	
	
	
	
	
	
	
	
		
		
		

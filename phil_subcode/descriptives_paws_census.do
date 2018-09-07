

	
	
use "${temp}paws_temp_stats.dta", clear
		append using "${temp}alt.dta"
			
		*bys barangay_id: g b_n=_n==1
		*browse if b_n==1
		*drop b_n

					g census=alt!=.	
						egen cs=sum(census), by(barangay_id)
						drop if cs<20
						
					g c1=alt==.
						egen c1s1=sum(c1), by(barangay_id) // total connected households
						drop if c1s1<=10 // get rid of areas that are not covered by PAWS
						drop    c1s1
			
		*bys barangay_id: g b_n=_n==1
		*browse if b_n==1
		*drop b_n


	g duplex  =  house_1==0 & house_2==0
			
	lab var hhsize "HH Size"	
	lab var hhemp "Total Empl."
	lab var age "Age HoH"	
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
	lab var duplex "Duplex"
	lab var low_skill "Low Skill Emp."
						
			qui xi: reg INC i.hhsize*hhemp     i.low_skill*i.house_1 ///
					 i.low_skill*hhemp i.low_skill*age
				predict INC_alt, xb	
				
			replace INC=INC_alt if INC==.
			egen INC_alt1=mean(INC_alt), by(alt)
			replace INC=INC_alt1 if INC==.
			drop _* INC_alt*


	replace INC = INC/50

g well=0 if sh3>2 & sh3<.
replace well=1 if sh3>=3 & sh3<=6

g peddler=0 if sh3>2 & sh3<.
replace peddler=1 if sh3==10


sum well
file open myfile using "${output}vendor_well.tex", write replace
file write myfile "`=round(r(mean)*100,1)'"
file close myfile
		
sum peddler
file open myfile using "${output}vendor_peddler.tex", write replace
file write myfile "`=round(r(mean)*100,1)'"
file close myfile
	
sum alt 
file open myfile using "${output}vendor_total.tex", write replace
file write myfile "`=round(r(mean)*100,1)'"
file close myfile		
	

g shr = 0 if alt!=.
replace shr = 1 if sh3 == 2

bys alt shr census: g N=_N
bys census: g NS=_N

g PERCENTAGE = N/NS
replace PERCENTAGE = . if census==0

lab var N "Households"


foreach var of varlist house_1 house_2 duplex low_skill PERCENTAGE {
replace `var'=`var'*100
}


global varlist " age hhsize hhemp low_skill  INC house_1 house_2 duplex N PERCENTAGE"


order $varlist

estpost sum $varlist if census==0
	matrix meanf1=e(mean)
	matrix list meanf1
	
estpost sum $varlist if census==1 & shr==0 & alt==0
	matrix meanf2=e(mean)
	matrix list meanf2

estpost sum $varlist if census==1 & shr==1 & alt==0
	matrix meanf3=e(mean)
	matrix list meanf3

estpost sum $varlist if census==1 & shr==0 & alt==1
	matrix meanf4=e(mean)
	matrix list meanf4
	

g temp=""
replace temp = "Age (Head of HH)" 	 	in 1
replace temp = "HH Size"	 	in 2
replace temp = "Employed HH Members"   	in 3
replace temp = "Low Skill Emp. (Head of HH)"  	in 4
replace temp = "Inc. (USD/Mo. Imputed)" in 5
replace temp = "Apartment" 	in 6
replace temp = "Single House" 	in 7
replace temp = "Duplex" 		in 8
replace temp = "Households" in 9
replace temp = "Share of Pop." in 10



g colnames = ""
replace colnames = "" in 1
replace colnames = "Own Use" in 2
replace colnames = "Shared Use" in 3
replace colnames = "Vendor" in 4


matrix define PER=J(10,1,0)
matrix PER[4,1]=1
matrix PER[6,1]=1
matrix PER[7,1]=1
matrix PER[8,1]=1
matrix PER[10,1]=1


matrix define FOR=J(10,1,2)
matrix FOR[1,1]=1
matrix FOR[4,1]=0
matrix FOR[5,1]=0
matrix FOR[6,1]=0
matrix FOR[7,1]=0
matrix FOR[8,1]=0
matrix FOR[9,1]=0
matrix FOR[10,1]=0




matrix A1 = (meanf1',meanf2',meanf3',meanf4')

 program drop _all
	
program define tables `1' `2' `3' `4' `5' `6'
	file open fi using "${output}`1'.tex", write replace
	local ROWS `=rowsof(`2')'
	local COLS `=colsof(`2')'
	disp `ROWS'
	disp `COLS'	
	file write fi "\begin{tabular}{l"	
	forvalues c=1/`COLS' {
		if `c'>1 {
		file write fi "c"
		}
		if `c'==`COLS' {
		file write fi  "c}" _n		
		}
	}
	file write fi "\hline" _n
	file write fi "\hline" _n		
	file write fi " & \textbf{PAWS} & \multicolumn{3}{c}{ \textbf{Census} } \\ \cmidrule(r){2-2} \cmidrule(l){3-5}" _n	 // HERE'S WHERE THE COLUMN NAMES ARE SET	
	*file write fi "\hline" _n
	file write fi " &" // NOT ENOUGH COLUMNS!
	forvalues c=1/`COLS' {
		if `c'!=`COLS' {
		file write fi "`=`5'[`c']' &"
		}
		if `c'==`COLS' {
		file write fi "`=`5'[`c']'  \\" _n		
		}
	}
	file write fi "\hline" _n
	file write fi "\hline" _n	
	forvalues r=1/`ROWS' {
	file write fi  "`=`4'[`r']' & "
	forvalues c=1/`COLS' {
		local PP " "
		if `6'[`r',1]==1 & `2'[`r',`c']!=. {
		local PP "\%"
		}
		local h ""
		if `2'[`r',`c']!=. {
		local h : di %10.`=`3'[`r',1]'fc `2'[`r',`c']
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
		 
	tables descriptives_census_to_paws A1 FOR temp colnames PER
	
	
	
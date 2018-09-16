

** prep tables for descriptives
global gen_paws_mc_table    = 0
global gen_leaks_table_data = 0

** actually generate tables
global gen_mean_diff_leak   = 0
global gen_mean_diff_DC 	= 0
global gen_leak_graphs 		= 1
global gen_selection_graphs = 0


if $gen_paws_mc_table == 1 {

cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end

local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"
* replaces bill_sample_temp

local bill_query ""

forvalues r = 1/12 {
	local bill_query "`bill_query' SELECT B.*, AVG(A.c) AS mc FROM (SELECT conacct, c FROM billing_`r' WHERE c>=0 & c<100 AND (class==1 OR class==2)) AS A JOIN `paws_data_selection' AS B ON A.conacct = B.conacct GROUP BY A.conacct "
	if `r'!=12{
		local bill_query "`bill_query' UNION ALL"
	}
}
clear

odbc load, exec("`bill_query'")  dsn("phil") clear  

gentable paws_mc

}


if $gen_leaks_table_data == 1 {

	use  "${temp}L_1.dta", clear
	g b=1
	forvalues r=2/12 {
		append using "${temp}L_`r'.dta"
		replace b=`r' if b==.
	}

	keep if date_l<=660 // only early leakers
	keep if class==1 | class==2
	duplicates drop conacct date, force

	sort conacct date
	g T = date-date_l

	order conacct date date_l
	drop if date<date_c // get rid of before connection

	g T=date-date_c_treat
	g cnc=c
	replace cnc=. if cnc<0 | cnc>500
	replace c=. if c<=0 | c>200 // get rid of crazy volumes
			
	g DC=0 // DC sample!

	g LEAK_SIZE_id=cnc if T>=-2 & T<=2
	egen LEAK_SIZE=mean(LEAK_SIZE_id), by(conacct)

	replace c=. if c<0 | c>200 // get rid of crazy volumes ( KEY whether to set c == 0 to missing... )
	g cmiss = c ==. | c==0

	sort conacct date // keep from first usage onwards
	by conacct: g tn=_n
		g tn_obs = tn if cmiss==0
		egen tn_id = min(tn_obs), by(conacct)
		drop if tn<tn_id
		drop tn tn_obs tn_id

		*** PRE-CLEANING
	g cmiss_pre_id 	= 	cmiss==1 & T<0 
	*& date>600   // keep long time-series pre
	g c_pre_id 		= 	T<0 
	*& date>600
			
	egen cmiss_pre=sum(cmiss_pre_id), by(conacct)
	egen c_pre=sum(c_pre_id), by(conacct)
	g ratio_pre=cmiss_pre/c_pre
		*keep if ratio_pre <=.9  // keep long early time series
			* previous .85

		*** POST-CLEANING
	g cmiss_post_id = 	cmiss==1 & T>=2 & T<=10
	g c_post_id 	= 	T>=2 & T<=10
			
	egen cmiss_post=sum(cmiss_post_id), by(conacct)
	egen c_post=sum(c_post_id), by(conacct)
	g ratio_post=cmiss_post/c_post
	*	keep if ratio_post>=.9 & ratio_post<=1 // *hist ar, by(DC) // how can I include ar in the definition? OR just ignore it completely... *g DC = ratio_pre<=.85 & ratio_post>=.82 & ratio_post<=1
			* previous .82

	replace DC=1 if ratio_post>=.9 & ratio_post<=1 & ratio_pre <= .9

	g c1=c if T<-3
	egen mc=mean(c1), by(conacct)
		
		duplicates drop conacct, force

		keep conacct DC mc class LEAK_SIZE

	gentable leaks_table_data

}



if $gen_mean_diff_DC == 1 {

odbc load, exec("SELECT A.conacct AS conacct_original, A.DC, A.mc, A.class, A.LEAK_SIZE, C.*  FROM leaks_table_data AS A JOIN pneighbor AS B ON A.conacct = B.conacct JOIN (SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID) AS C ON C.conacct = B.conacctp  ") clear

	bys DC: g N=_N
	
	g SEM = class==2

	lab var mc "Cons. (avg.)"
	lab var LEAK_SIZE "Leak Size"
	lab var age "Age HoH"
	lab var hhsize "HH Size"
	lab var hhemp  "HH Size Empl."
	*lab var drink  "Drink"
	*lab var storage  "Water Storage"
	*lab var flow 	"Water Flow"
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
	lab var low_skill "Low Skill Emp."
	lab var SEM "Semi-Business"
	lab var N "Obs."
	*lab var NM "Family Nearby"
	
	
	estpost sum mc LEAK_SIZE age hhsize hhemp low_skill  house_1 house_2   N if DC==1
	matrix meanf1=e(mean)
	matrix list meanf1

	estpost sum mc LEAK_SIZE age hhsize hhemp low_skill   house_1 house_2   N if DC==0
	matrix meanf0=e(mean)
	matrix list meanf0
	
	estpost ttest mc LEAK_SIZE age hhsize hhemp low_skill  house_1 house_2   N , by(DC)

	estadd matrix meanf1
	estadd matrix meanf0


	esttab using "${output}mean_diff_DC.tex", noobs cells("meanf0(fmt(3)) meanf1(fmt(3)) b(star fmt(3)) se(fmt(3))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Mean No DC" "Mean DC" "Diff." "Std. Error" "Obs.") tex  replace label

}






******** HERE'S THE NEW SEGMENT RIGHT HERE !!! **********


















********* HERE IS THE TABLE GENERATION !!! **********



if $gen_mean_diff_leak == 1 {
odbc load, exec("SELECT A.*, CC.source FROM paws_mc AS A LEFT JOIN (SELECT conacct, 1 AS source FROM cc) AS CC ON CC.conacct = A.conacct ") clear

g LEAK = source=="1"

	tabstat mc age hhsize hhemp  house_1 house_2 low_skill, by(LEAK)
	

	
	bys LEAK: g N=_N
		
	
	lab var mc "Cons. (avg.)"
**	lab var LEAK_SIZE "Leak Size"
	lab var age "Age HoH"
	lab var hhsize "HH Size"
	lab var hhemp  "HH Size Empl."
*	lab var drink  "Drink"
*	lab var storage  "Water Storage"
*	lab var flow 	"Water Flow"
	lab var house_1 "Apartment"
	lab var house_2 "Single House"
	lab var low_skill "Low Skill Emp."
**	lab var SEM "Semi-Business"
	lab var N "Obs."
*	lab var NM "Family Nearby"
	
	** take out sem
	
	estpost sum mc  age hhsize hhemp low_skill  house_1 house_2 N if LEAK==1
	matrix meanf1=e(mean)
	matrix list meanf1

	estpost sum mc  age hhsize hhemp low_skill    house_1 house_2 N if LEAK==0
	matrix meanf0=e(mean)
	matrix list meanf0
	
	estpost ttest mc age hhsize hhemp low_skill   house_1 house_2 N , by(LEAK)

	*drink storage flow 

	estadd matrix meanf1
	estadd matrix meanf0


	esttab using "${output}mean_diff_leak.tex", noobs cells("meanf0(fmt(2)) meanf1(fmt(2)) b(star fmt(2)) se(fmt(2))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Mean No Leak" "Mean Leak" "Diff." "Std. Error" "Obs.") tex replace label

}







if $gen_leak_graphs == 1 {


odbc load, dsn(phil) exec("SELECT A.* FROM leaks AS A") clear


** GRAPH OUTCOMES 



** leak pretrend

cap program drop leak_pretrend
program define leak_pretrend
	preserve
			sum c if distance==-1 & T<0
			scalar define mc=round(r(mean),.01)
			keep if distance==-1
			drop if c>100

	local cluster_var "conacct"
	local outcome "c"
	local T_high "-1"
	local T_low "-25"

		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		drop T_1
		*`=`T_high'-`T_low'-1'
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		 areg `outcome' T_* , absorb(`cluster_var') cluster(`cluster_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min'-1'
	   	lab var time "Time (Months to Leak)"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low'+1'(2)`=`T_high'') ///
    	 ytitle("Total Neighbor Usage (m3)") ///
		xtitle("Months to Leak") note("Avg. Q Leakers: `=mc' m3  ")
   	restore
	graph export  "${output}leakers_pre_2.pdf", as(pdf) replace
		
end

leak_pretrend





*** g2 : heterogeneity by distance and rank 

cap program drop est_total
program define est_total
	local cluster_var "conacct_leak"
	local outcome "C"
	local keep_low "-12"
	local keep_high "10"
	local treat_thresh "2"
	*drop if T==0 | T==1
	preserve
		g c_nei = c if distance!=-1
		egen C = sum(c_nei), by(conacct_leak date)
		g treat = T>`treat_thresh' & T<.
		g treat_T = treat*T
		keep if T>=`keep_low' & T<=`keep_high'
		duplicates drop `cluster_var' date, force
		areg `outcome' treat treat_T T date, absorb(`cluster_var') cluster(`cluster_var') r 		
		*areg `outcome' treat i.date, absorb(`cluster_var') cluster(`cluster_var') r 		
		areg `outcome' treat, absorb(`cluster_var') cluster(`cluster_var') r 		
			mat define est=	e(b)
			scalar define est1=round(est[1,1],.1)
	restore
end

est_total


*** g1 : just total neighbor usage


cap program drop graph_neighbor
program define graph_neighbor
	local cluster_var "conacct_leak"
	local outcome "C"
	local T_high "12"
	local T_low "-12"
	preserve
		sum c if distance==-1 & T<0
		scalar define mc=round(r(mean),.01)

		keep if T>=`=`T_low'' & T<=`=`T_high''
		g c_nei = c if distance!=-1
		egen C = sum(c_nei), by(conacct_leak date)
	duplicates drop `cluster_var' date, force
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		qui areg `outcome' T_* , absorb(`cluster_var') cluster(`cluster_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min''
	   	lab var time "Time (Months to Leak)"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("Total Neighbor Usage (m3)") ///
    	 note("Avg. Q Leakers: `=round(mc,.1)' m3       Diff-in-Diff Estimate: `=round(est1,.1)' m3 ")
   	restore
   	graph export  "${output}leakers_full_2.pdf", as(pdf) replace
end

graph_neighbor

}









	 
	 **** OK SO THAT CHECKS OUT!! 
	 
	 
	 ******* NOW CHECK OUT SELECTION BY HOUSEHOLDS!!!
	 
if $gen_selection_graphs == 1 {	

odbc load, dsn(phil) exec("SELECT C.*, U.alt_sub, G.p_L, G.p_H1, G.p_H2, G.p_H3, B.house_avg AS house_census, P.barangay_id, P.SHH, P.SHO, P.house_1, P.house_2, P.age, P.hhemp, P.hhsize, P.low_skill FROM bmatch AS A LEFT JOIN bstats AS B ON A.OGC_FID = B.OGC_FID  JOIN LN_total AS C ON A.conacct = C.conacct  JOIN pawsstats AS P ON A.conacct = P.conacct  JOIN price AS G ON C.date = G.date AND C.class = G.class  JOIN alt_sub AS U ON P.barangay_id = U.barangay_id") clear 


	keep if class==1 | class==2
	drop if date<date_c
	drop date_c

	drop if c<=0 | c>100

	* keep if distance<5
	* keep if rank<=4

	g T = date - date_l
	g TREAT = conacct==conacct_leak

	g g_id = conacct_leak
	
	ren conacct_leak conacct_treat
	ren rank dist_rank

	bys conacct: g cc=_n==1
	egen CC=sum(cc), by(conacct_treat)
	tab CC		
		drop if CC<=2
	* browse if cc==1
		drop cc CC
	 
	 
	 g ct=c if distance==-1
	 egen MC=mean(ct), by(conacct_treat)
	 
	 
	 **** TEST IF FOLKS ARE MATCHING WITH SMALLER NEARBY USERS!

	*	sum c if rank==1
	
	gen ui = floor((8)*runiform() + 1)
	bys conacct: g cc=_n==1
	replace ui = . if cc!=1
	egen TR=max(ui), by(conacct)
	drop cc
		
		
	*************************************	
	***** SHOW DISTANCE SELECTION ! *****
	*************************************	
		
		
	preserve		
		
		keep if dist_rank<=5
	
	*replace dist_rank=dist_rank-1
	replace dist_rank=5 if dist_rank>5
	
			sum c if distance==-1 & T<0
			scalar define mc=round(r(mean),.01)
			keep if distance<5
			
			drop if distance==-1
			drop if c>120
			g treat=T>1 & T<.
	
	*** GEN RANK ***
		 g cpre=c if T<-1
		egen cc=mean(cpre), by(conacct)
		replace cc=. if distance==-1
		
		sort conacct date
		by conacct: g cnn=_n
		
		sort conacct_treat cnn  cc 
		by conacct_treat cnn: g rank=_n
		egen mr=min(rank), by(conacct)
		replace rank = mr
	*** *** *** ***
			
			lab var c "Q (m3)"
			
			scalar define TKEY1=14
			
			replace T=100 if T<-`=TKEY1' | T>`=TKEY1'
			drop if T==100
			
			sum dist_rank, detail
			forvalues j = 1/`=r(max)' {
			g DR`j' = dist_rank==`j'
			g TR`j'= DR`j'*treat
			lab var TR`j' "Distance Rank `j'"
			g T_TR`j'=T*DR`j'
			g T_treat_TR`j'=T*treat*DR`j'
			}
			drop TR
			lab var TR`=r(max)' "Distance Rank `=r(max)'-5"
			xi: areg c treat , robust cluster(conacct) absorb(conacct)
			xi: areg c TR* T_*, robust cluster(conacct) absorb(conacct)
			
			est sto True
			matrix define C1 = e(b)
			 
			outreg2 using ///
			"${output}neighbor_distance.tex", ///
			tex(frag) ///
			label replace keep(TR*) addtext("Pre Post Trends by Rank","Yes") 		
	restore
		

		
		
		
		
		
		
		
****************************	
**** NEIGHBOR SELECTION ****
**** NEIGHBOR SELECTION ****
**** NEIGHBOR SELECTION ****
**** NEIGHBOR SELECTION ****
****************************

		
	 preserve		
	*	replace T =. if T>0
	*	replace T = T+TR
	* keep if L==3
	
	keep if dist_rank<=5
	
			sum c if distance==-1 & T<0
			scalar define mc=round(r(mean),.01)
			*keep if distance<3
			
			drop if distance==-1
			drop if c>120
			g treat=T>1 & T<.
	
	*** GEN RANK ***
		 g cpre=c if T<-1
		egen cc=mean(cpre), by(conacct)
		replace cc=. if distance==-1
		
		sort conacct date
		by conacct: g cnn=_n
		
		sort conacct_treat cnn  cc 
		by conacct_treat cnn: g rank=_n
		egen mr=min(rank), by(conacct)
		replace rank = mr
	*** *** *** ***
			
			lab var c "Q (m3)"
			
			scalar define TKEY1=14
			
			replace T=100 if T<-`=TKEY1' | T>`=TKEY1'
			drop if T==100
			
			sum rank, detail
			forvalues j = 1/`=r(max)' {
			g TR`j' = rank==`j'
			replace TR`j'= TR`j'*treat
			lab var TR`j' "Demand Rank `j'"
			}

			xi: areg c treat , robust cluster(conacct) absorb(conacct)
			xi: areg c TR* , robust cluster(conacct) absorb(conacct)
			est sto True
			matrix define C1 = e(b)
			 
			outreg2 using ///
			"${output}neighbor_selection.tex", ///
			tex(frag) ///
			label replace keep(TR1 TR2 TR3 TR4 TR5) addtext("Connection FE","Yes","Simulated Leak","No") 		
	restore
	


	 
	 
	 preserve		
	 	keep if dist_rank<=5
		* keep if L==3

		replace T =. if T>0
		replace T = T+TR
		
			sum c if distance==-1 & T<0
			scalar define mc=round(r(mean),.01)
			keep if distance<5
			
			drop if distance==-1
			drop if c>100
			g treat=T>1 & T<.
	
	*** GEN RANK ***
		 g cpre=c if T<-1
		egen cc=mean(cpre), by(conacct)
		replace cc=. if distance==-1
		
		sort conacct date
		by conacct: g cnn=_n
		
		sort conacct_treat cnn  cc 
		by conacct_treat cnn: g rank=_n
		egen mr=min(rank), by(conacct)
		replace rank = mr
	*** *** *** ***
			
			scalar define TKEY1=14
			
			replace T=100 if T<-`=TKEY1' | T>`=TKEY1'
			drop if T==100
			
			lab var c "Q (m3)"
			
			sum rank, detail
			forvalues j = 1/`=r(max)' {
			g TR`j' = rank==`j'
			replace TR`j'= TR`j'*treat
			lab var TR`j' "Demand Rank `j'"
			}

			xi: areg c treat        , robust cluster(conacct) absorb(conacct)
			xi: areg c TR* , robust cluster(conacct) absorb(conacct)
			matrix define C2 = e(b)
			est sto Reversion
			
		outreg2 using ///
		"${output}neighbor_selection.tex", ///
		tex(frag) ///
		label append keep(TR1 TR2 TR3 TR4 TR5) addtext("Connection FE","Yes","Simulated Leak","Yes")
		
	 matrix list C1
	 matrix list C2
	 
	 matrix define MD=C1-C2
	 matrix list MD
	 
	 est sto MD
	 
	 svmat MD

	 replace MD2=MD3[1]
	 replace MD3=MD4[1]
	 replace MD4=MD5[1]
	 replace MD5=MD6[1]
	 replace MD6=MD7[1]
	 	 

	 g MD=MD2       if   TR1==1
	 replace MD=MD3 if   TR2==1
	 replace MD=MD4 if   TR3==1
	 replace MD=MD5 if   TR4==1
	 replace MD=MD6 if   TR5==1

	 lab var MD "Difference"
	 reg MD  TR1 TR2 TR3 TR4 TR5 , nocons
	 
		outreg2 using ///
		"${output}neighbor_selection.tex", ///
		tex(frag) ///
		label append keep(TR1 TR2 TR3 TR4 TR5)   nose  noobs nor2
			 
	restore
	


	
	
	******* *******		 	NOW CHECK OUT 			******* ******* 
	******* ******* SELECTION BY TYPE OF HOUSEHOLDS ******* ******* 
	
	
	
	
		
		
	preserve		
		*	replace T =. if T>0
		*	replace T = T+TR
		drop TR*

		keep if dist_rank<=5
		
		g CK = c if distance==-1 & T<0
		egen MCK = mean(CK), by(conacct_treat)
		sum MCK, detail
		egen MD  = cut(MCK), group(5)
		replace MD = MD+1
		
		matrix define R = J(1,5,0)
		tab MD		
		sum MD, detail
		forvalues j = 1/`=r(max)' {
		sum MCK if MD==`j'
		matrix R[1,`j']=`=r(mean)'
		}
		
		
				sum c if distance==-1 & T<0
				scalar define mc=round(r(mean),.01)
				keep if distance<3
				
				drop if distance==-1
				drop if c>120
				g treat=T>1 & T<.
		
		*** GEN RANK ***
			 g cpre=c if T<-1
			egen cc=mean(cpre), by(conacct)
			replace cc=. if distance==-1
			
			sort conacct date
			by conacct: g cnn=_n
			
			sort conacct_treat cnn  cc 
			by conacct_treat cnn: g rank=_n
			egen mr=min(rank), by(conacct)
			replace rank = mr
		*** *** *** ***
			
				egen cs=sum(c), by(conacct_treat date)
				drop c
				ren cs c
				duplicates drop conacct_treat date, force
				
				
				lab var c "Q (m3)"
				
				scalar define TKEY1=14
				
				replace T=100 if T<-`=TKEY1' | T>`=TKEY1'
				drop if T==100
				
				sum MD, detail
				forvalues j = 1/`=r(max)' {
				g TR`j' = MD==`j'
				replace TR`j'= TR`j'*treat
				lab var TR`j' "Quintile `j'"
				}
				*drop TR
				
				xi: areg c treat , robust cluster(conacct_treat) absorb(conacct_treat)
				xi: areg c TR* , robust cluster(conacct_treat) absorb(conacct_treat)
				est sto True
				matrix define C1 = e(b)
				 
				outreg2 using ///
				"${output}leaker_selection.tex", ///
				tex(frag) ///
				label replace keep(TR1 TR2 TR3 TR4 TR5) addtext("Neighborhood FE","Yes") 		
	
	
	
	
	 svmat R

	 replace R1=R1[1]
	 replace R2=R2[1]
	 replace R3=R3[1]
	 replace R4=R4[1]
	 replace R5=R5[1]
	 
	 g 	     MEAN=R1  if  TR1==1
	 replace MEAN=R2  if  TR2==1
	 replace MEAN=R3  if  TR3==1
	 replace MEAN=R4  if  TR4==1
	 replace MEAN=R5  if  TR5==1

	 lab var MEAN "Avg. Q (m3)"
	 reg MEAN TR1 TR2 TR3 TR4 TR5   , nocons
	 
		outreg2 using ///
		"${output}leaker_selection.tex", ///
		tex(frag) ///
		label append keep(TR1 TR2 TR3 TR4 TR5)   nose  noobs nor2
		

	
	matrix CA = C1[1,1..5]
	svmat CA
	
	 replace CA1=CA1[1]
	 replace CA2=CA2[1]
	 replace CA3=CA3[1]
	 replace CA4=CA4[1]
	 replace CA5=CA5[1]	
	
	 replace MEAN=CA1/MEAN  if  TR1==1
	 replace MEAN=CA2/MEAN  if  TR2==1
	 replace MEAN=CA3/MEAN  if  TR3==1
	 replace MEAN=CA4/MEAN  if  TR4==1
	 replace MEAN=CA5/MEAN  if  TR5==1	
	
	 lab var MEAN "Share Offset"
	 reg MEAN TR1 TR2 TR3 TR4 TR5   , nocons
	 
		outreg2 using ///
		"${output}leaker_selection.tex", ///
		tex(frag) ///
		label append keep(TR1 TR2 TR3 TR4 TR5)   nose  noobs nor2
		
	
	
	restore
	
	 
	 

}






/*


cap program drop graph_ind
program define graph_ind
	local cluster_var "conacct"
	local outcome "c"
	local keep_low "-24"
	local keep_high "12"
	local treat_thresh "2"
	preserve
			*g d=distance if distance>0
			*egen dc=cut(d), group(4)
			*tab dc, g(DC_)
			*local het "DC_1 DC_2 DC_3 DC_4"
			*	g house_avg = (house_1_avg + house_2_avg) / 2
			*	keep if pop>2000
		local het "distance house_census"
		local int "no"

			*egen max_distancep = max(distancep), by(conacct_leak)
			*sum max_distancep, detail
			*keep if max_distancep<`=r(p25)'
		drop if distance==-1
		g treat = T>`treat_thresh' & T<.
		foreach v in `het' {
		g treat_`v' = treat*`v'	
			if "`int'"=="yes" {
				g treat_`v'_T = T * `v'
				g treat_`v'_T_post = T * treat_`v'
			}
		}
		g T_treat = T*treat
		keep if T>=`keep_low' & T<=`keep_high'
			local int_controls ""
			if "`int'"=="yes" {
				local int_controls "T T_treat date"
			}
		duplicates drop `cluster_var' date, force
			areg `outcome' treat $int_controls, absorb(`cluster_var') cluster(`cluster_var') r
			areg `outcome' treat treat_* $int_controls, absorb(`cluster_var') cluster(`cluster_var') r	
	restore
end

graph_ind




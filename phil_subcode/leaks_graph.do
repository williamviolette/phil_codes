

odbc load, dsn(phil) exec("SELECT A.* FROM leaks AS A") clear

** GRAPH OUTCOMES 

	g c_nei = c if distance!=-1
	egen C = sum(c_nei), by(conacct_leak date)

*** g2 : heterogeneity by distance and rank 

cap program drop est_total
program define est_total
	local cluster_var "conacct_leak"
	local outcome "C"
	local keep_low "-24"
	local keep_high "16"
	local treat_thresh "2"
	*drop if T==0 | T==1
	preserve
		g treat = T>`treat_thresh' & T<.
		g treat_T = treat*T
		keep if T>=`keep_low' & T<=`keep_high'
		duplicates drop `cluster_var' date, force
		areg `outcome' treat treat_T T, absorb(`cluster_var') cluster(`cluster_var') r 		
		areg `outcome' treat, absorb(`cluster_var') cluster(`cluster_var') r 		
	
	restore
end

est_total


*** g1 : just total neighbor usage


cap program drop graph_neighbor
program define graph_neighbor
	local cluster_var "conacct_leak"
	local outcome "C"
	local time "50"
	duplicates drop `cluster_var' date, force
	preserve
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		qui areg `outcome' T_* , absorb(`cluster_var') cluster(`cluster_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min''
    	tw (scatter estimate time) || (rcap max95 min95 time)
   	restore
end

graph_neighbor






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




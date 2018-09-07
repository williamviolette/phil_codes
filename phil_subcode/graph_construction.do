

		
		
		import delimited using "${generated}tables/tariff_graph/tpt_graph_full.csv", ///
		delimiter(",") clear
		
		g p_lead=v2[_n+1]
		g p_lead2=v2[_n+2]
		g p_lag = v2[_n-1]
		g p_avg= ( v2+p_lag+p_lead+p_lead2 ) / 4
		replace p_avg=v2 if p_avg==.
		
		g f_lead= v3[_n+1]
		g f_lead2= v3[_n+2]
		g f_lag = v3[_n-1]
		g f_avg = (v3 + f_lead + f_lag + f_lead2)/4
		replace f_avg=v3 if f_avg==.
		
		drop if v1>30
		
		lab var v1 "Hassle Cost (PhP/m3)"
		lab var p_avg "Marginal Price (PhP/m3)"
		lab var f_avg "Fixed Fee (PhP/mo)"
		
		
		line p_avg v1, yaxis(1) lwidth("thick") ylabel(,nogrid)  ytitle("Marginal Price (PhP/m3)", axis(1)) || ///
		line f_avg v1, yaxis(2) lwidth("thick") lpattern("longdash")  ytitle("Fixed Fee (PhP/mo)", axis(2)) xline(15.14,lpattern(dash) lcolor(gs6)) ///
		title("Optimal Marginal Price and Fixed Fee") graphregion(style(none) color(gs16)) 
		
			graph export "${output}tpt_full_graph_prices.pdf", as(pdf) replace		
						
		
			
		g vendor = 1-v4-v5	
		
		
		lab var v4 "Owning a Connection"
		lab var v5 "Using from Neighbors"
		lab var vendor "Using from a Vendor"
		
		line v4 v1, yaxis(1) lwidth("thick") ylabel(,nogrid)  lcolor("green") ytitle("Share of Households", axis(1)) || ///
		line v5 v1, yaxis(1) lwidth("thick") ylabel(,nogrid) lpattern("dash")  lcolor("orange")  || ///
		line vendor v1, yaxis(1) lwidth("thick") lcolor("purple") lpattern("longdash")  xline(15.14,lpattern(dash) lcolor(gs6)) graphregion(style(none) color(gs16)) ///
		title("Water Source Choices") 
		
			graph export "${output}tpt_full_graph_shares.pdf", as(pdf) replace		
						
		
			
		
		
		
		
		
		use "${data}prices_5B_no_inflation.dta", clear
			keep if date==620
			expand 5000
			g c=_n/100
			g P=0 if c<=10
			replace P=p_H1 if c>10 & c<=20
			replace P=p_H2 if c>20 & c<=40
			replace P=p_H3 if c>40
		*scatter P c
		keep P c
	
		save "${temp}price_graph2.dta", replace
		
		
		
		
		
		
		
		******** FULL TARIFF STRUCTURE GRAPHS **********
		
		
		use "{temp}price_graph2.dta", clear
		
		*replace P=P/50
		
			lab var P "Marginal Price (PhP/m3)"
			lab var c "Water (m3/month)"
			replace c= c+1
			
		line P c,  lwidth("thick") ytitle(,size("large")) xtitle(,size("large")) graphregion(style(none) color(gs16))
			
			graph export "${output}tariff_structure.pdf", as(pdf) replace		
						
		
		
		
			****** COUNTERFACTUAL TARIFF GRAPHS ******
		
		**** TPT
		
		import delimited using "${generated}tables/normal_optimal_prices_groups.csv", clear
			scalar define tpt_p_normal_avg=v4[1]	
			scalar define tpt_p_normal_poor=v5[1]	

		import delimited using "${generated}tables/high_ph_optimal_prices_groups.csv", clear
			scalar define tpt_p_noshr_avg=v4[1]	
			scalar define tpt_p_noshr_poor=v5[1]	
			
		**** TP3 
	
		import delimited using "${generated}tables/normal_avg_optimal_prices_tpt3_groups.csv", clear
			scalar define tp3_p1_normal_avg=v2[1]	
			scalar define tp3_p2_normal_avg=v3[1]	
			
		import delimited using "${generated}tables/normal_low_optimal_prices_tpt3_groups.csv", clear
			scalar define tp3_p1_normal_poor=v2[1]	
			scalar define tp3_p2_normal_poor=v3[1]	
			
	
		import delimited using "${generated}tables/high_ph_avg_optimal_prices_tpt3_groups.csv", clear
			scalar define tp3_p1_noshr_avg=v2[1]	
			scalar define tp3_p2_noshr_avg=v3[1]	
			
		import delimited using "${generated}tables/high_ph_low_optimal_prices_tpt3_groups.csv", clear
			scalar define tp3_p1_noshr_poor=v2[1]	
			scalar define tp3_p2_noshr_poor=v3[1]	
			

		
		***** NOSHR 	
				
		use "${temp}price_graph2.dta", clear
		
		*replace P=P/50
		
			lab var P "Current"
			lab var c "Water (m3/month)"
			
			
			g P_tpt_avg = `=tpt_p_noshr_avg'
			lab var P_tpt_avg "Opt. 2-Part"			
			
			g P_tpt_poor =  `=tpt_p_noshr_poor'
			lab var P_tpt_poor "Social 2-Part"	
			
			g P_tp3_avg = `=tp3_p1_noshr_avg'
			replace P_tp3_avg = `=tp3_p2_noshr_avg' if c>20
			lab var P_tp3_avg "Opt. 3-Part"
			
			g P_tp3_poor = `=tp3_p1_noshr_poor'
			replace P_tp3_poor = `=tp3_p2_noshr_poor' if c>20
			lab var P_tp3_poor "Social 3-Part"
			
		replace c = c+1
		
		g MC = 5
		lab var MC "Marginal Cost"
		
		
	*	drop if P>20
		
		line P c, lwidth(medthick)  ///
			|| line MC c, lwidth(medthick) ///
			|| line P_tpt_avg c, lpattern("dash") lcolor("green") lwidth(medthick) ///
			|| line P_tpt_poor c, lpattern("dash") lcolor("orange") lwidth(medthick) ///
			|| line P_tp3_avg c, lpattern("longdash_dot") lcolor("forest_green") lwidth(medthick) ///
			|| line P_tp3_poor c, lpattern("longdash_dot") lcolor("sienna")  lwidth(medthick) ytitle("Tariff (PhP/m3)") ///
			 graphregion(style(none) color(gs16))
		*title("Optimal Tariffs Without Sharing")
		
			graph export "${output}no_shr_tariff_groups.pdf", as(pdf) replace		
						
						
			
			
			
			
		***** NORMAL 	
				
		use "${temp}price_graph2.dta", clear
		
		*replace P=P/50
		
			lab var P "Current"
			lab var c "Water (m3/month)"
			
		*	replace P=20.1 if c>20 & c<20.02
		*	replace P=. if c>=20.02
			
			
			g P_tpt_avg = `=tpt_p_normal_avg'
			lab var P_tpt_avg "Opt. 2-Part"			
			
			g P_tpt_poor =  `=tpt_p_normal_poor'
			lab var P_tpt_poor "Social 2-Part"	
			
			g P_tp3_avg = `=tp3_p1_normal_avg'
			replace P_tp3_avg = `=tp3_p2_normal_avg' if c>20
			lab var P_tp3_avg "Opt. 3-Part"
			
			g P_tp3_poor = `=tp3_p1_normal_poor'
			replace P_tp3_poor = `=tp3_p2_normal_poor' if c>20
			lab var P_tp3_poor "Social 3-Part"
			
			
			
		g MC = 5
		lab var MC "Marginal Cost"
		
		*replace P=20 if c==20
		*replace P=. if c>20
		replace c = c+1
		
		
		line P c, lwidth(medthick)   ///
		|| line MC c, lwidth(medthick) ///
		|| line P_tpt_avg c, lpattern("dash") lcolor("green") lwidth(medthick) ///
		|| line P_tpt_poor c, lpattern("dash") lcolor("orange") lwidth(medthick) ///
		|| line P_tp3_avg c, lpattern("longdash_dot") lcolor("forest_green") lwidth(medthick) ///
		|| line P_tp3_poor c, lpattern("longdash_dot") lcolor("sienna")  lwidth(medthick) ytitle("Tariff (PhP/m3)") ///
		 graphregion(style(none) color(gs16))
		
		*title("Optimal Tariffs With Sharing")
		
			graph export "${output}shr_tariff_groups.pdf", as(pdf) replace		
						
		
			
		
		
		** FIXED FEE EXP
		
		import delimited using "${generated}tables/price_increase_for_fixed_cost_group.csv", clear
			scalar define price_increase=v1[1]	
				
		use "${temp}price_graph2.dta", clear
		
		*replace P=P/50
		
			lab var P "Pre"
			lab var c "Water (m3/month)"
			g P1 = P
			replace P1 = P+`=price_increase' 
			* if c<=20   NOTE : NOW WE APPLY EVERYWHERE
			lab var P1 "Post"
					g MC = 5
		lab var MC "Marginal Cost"
		
		line P c, lwidth("thick")  ///
		|| line MC c,  lwidth("thick") ///
		|| line P1 c, lpattern("longdash") lwidth("thick") ///
		   ytitle(,size("large")) xtitle(,size("large")) ytitle("Tariff (PhP/m3)")  graphregion(style(none) color(gs16))
			*title("Discount Policy Tariff")
			graph export "${output}discount_tariff_groups.pdf", as(pdf) replace		
						
				
		
		*** MAKE GRAPHS AND DESCRIPTIVES		
		*** CONSUMPTION HISTOGRAM ****
		
odbc load, exec("SELECT A.date, A.c FROM billing_7 AS A WHERE (A.class==1 OR A.class==2) AND A.c<=100 AND A.read==1")  dsn("phil") clear  
		
		lab var c "Consumption (Cubic Meters per Month)"
		
		bys c: g c_N=_N
		bys c: g c_n=_n
		
		replace c_N=c_N/_N

		lab var c_N "Frequency"
		
			scatter c_N c if c<=60 & c_n==1, title("Histogram of Monthly Consumption") ///
			ylabel(0(.01).035) xlabel(0(10)60) ///
			xline(11,lstyle(refline) lpattern(dash)) ///
			xline(21,lstyle(refline) lpattern(dash)) ///
			xline(41,lstyle(refline) lpattern(dash)) 	
			
		graph export "${output}consumption_histogram.pdf", as(pdf) replace
		



		
		
		
		
	*	use jmp/r_t_s_full.dta, clear
		
		
		
		
		* BUNCHING 
		
		use "${data}prices_5B_no_inflation.dta", clear
			lab var p_L "Tariff Segment 1"
			lab var p_H1 "Tariff Segment 2"
			lab var p_H2 "Tariff Segment 3"
			lab var p_H3 "Tariff Segment 4"
			
			format date %tm
			lab var date "Date"
			
			line p_L date if date>600, lwidth("thick") || line p_H1 date if date>600, lwidth("thick") ///
			|| line p_H2 date if date>600, lwidth("thick") || line p_H3 date if date>600, lwidth("thick") title("Regulated Tariff Changes") ytitle("Tariff (PhP/m3)") 
			graph export "${output}tariff_time_series.pdf", as(pdf) replace		
		




		use "${data}prices_5B_no_inflation.dta", clear
			keep if date==620
			expand 5000
			g c=_n/100
			g P=0 if c<=10
			replace P=p_H1 if c>10 & c<=20
			replace P=p_H2 if c>20 & c<=40
			replace P=p_H3 if c>40
		
		*scatter P c
		keep P c

		save "${temp}price_graph2.dta", replace
		
		use "${data}prices_semi_5B_no_inflation.dta", clear
			keep if date==620
			expand 5000
			g c=_n/100
			g P_semi=0 if c<=10
			replace P_semi=p_H1 if c>10 & c<=20
			replace P_semi=p_H2 if c>20 & c<=40
			replace P_semi=p_H3 if c>40
		
			merge 1:1 c using "${temp}price_graph2.dta"
		
	*	replace P = P/50
	*	replace P_semi = P_semi/50
		
		lab var P "Residential Tariff (PhP)"
		lab var P_semi "Semi-Business Tariff (PhP)"
		lab var c "Cubic Meters per Month"

		replace c = c+1		
			
		line P c, lwidth("thick") || line P_semi c, lpattern("dash") title("Residential and Semi-Business Tariffs") lwidth("thick")
	
			graph export "${output}res_semi_tariff.pdf", as(pdf) replace
		
		
		
		
		
		
		
		
		
		
		
		
		

		
		/*
				
				
				
			*** WEIGHT ON LOW-INCOME
		g P2 = 54.5 if c<=20
		replace P2 = -2.81 if c>20
		
		lab var P2 "Small-User Tariff"
			
		line P c, lwidth("thick") || line P1 c, lpattern("dash") lwidth("medthick") ///
		|| line P2 c, lwidth("medthick") lpatter("longdash") title("Tariff",size("large")) 
			graph export "jmp/tariff_structure_2.pdf", as(pdf) replace		
		
		*/

* price.do

	** input: pasay_billing, cpi_psa_clean
	** output: TABLE price

	use "${billingdata}pasay_billing_2008_2015.dta", clear
		* append using "${billingdata}samp_billing_2008_2015.dta"
		* append using "${billingdata}qc_04_billing_2008_2015.dta"
		keep if billclass=="0001"
		* keep if regexm(readtag,"ACT")==1
		ren CON conacct
		
		keep conacct year month PREV PRES amount
		
		destring year month PREV PRES, replace force
		
		g c=PRES-PREV
		replace c = abs(c)
		replace c=. if c<0 | c>100
		drop if c==.
		
		g date=ym(year,month)
		
		g p_L=0
		
		bys amount date c: g A_N=_N
		gegen mAN=max(A_N), by(date c)
		keep if A_N==mAN
		
		g basic_charge_id=amount if c==5 & amount<115 & amount>50
		gegen basic_charge=mean(basic_charge_id), by(date)


gegen dt=tag(date)
scatter basic_charge date if dt==1

		
			g amount_id_1_l=amount-basic_charge if c==15 & amount<1000
			g amount_id_1_h=amount-basic_charge if c==16 & amount<1000
			g amount_id_2_l=amount-basic_charge if c==25 & amount<1500
			g amount_id_2_h=amount-basic_charge if c==26 & amount<1500
			g amount_id_3_l=amount-basic_charge if c==45 & amount<6500	& amount>500
			g amount_id_3_h=amount-basic_charge if c==46 & amount<6500	& amount>500		
			g amount_id_4_l=amount-basic_charge if c==65 & amount<6500	& amount>500
			g amount_id_4_h=amount-basic_charge if c==66 & amount<6500	& amount>500		
			
			gegen amount_1_l=mean(amount_id_1_l), by(date)
			gegen amount_1_h=mean(amount_id_1_h), by(date)
			gegen amount_2_l=mean(amount_id_2_l), by(date)
			gegen amount_2_h=mean(amount_id_2_h), by(date)
			gegen amount_3_l=mean(amount_id_3_l), by(date)
			gegen amount_3_h=mean(amount_id_3_h), by(date)
			gegen amount_4_l=mean(amount_id_4_l), by(date)
			gegen amount_4_h=mean(amount_id_4_h), by(date)
			
			g p_H1=amount_1_h-amount_1_l
			g p_H2=amount_2_h-amount_2_l
			g p_H3=amount_3_h-amount_3_l
			g p_H4=amount_4_h-amount_4_l
			
			bys date: g d_n=_n
			
	
	*	scatter p_H4 date if d_n==1 	
	*	scatter p_H1 date if d_n==1 || scatter p_H2 date if d_n==1 
		
		keep date p_H1 p_H2 p_H3 p_H4
		
		duplicates drop date, force
		

		
	*	browse date p_H4
		
		replace p_H4=34 if date== 584 | date==585 | date==582
		replace p_H4=43.03 if date==598
		replace p_H4=50.41 if date==624
		replace p_H4=57.83 if date==636
		replace p_H4=57.58 if date==639
		replace p_H4=58.12 if date==649
		replace p_H4=58.12 if date==660
		
		replace p_H3=29 if date== 584 | date==585 | date==582 | date==579
		replace p_H3=37.03 if date==598
	*	replace p_H3=30.60 if date==600
		replace p_H3=49.69 if date==636
		replace p_H3=49.46 if date==639
		replace p_H3=49.94 if date==649
	


	*	scatter p_H4 date
		
		replace p_H1=12.29 if date==584 | date==585
		replace p_H1=15.57 if date==600
		replace p_H1=20.09 if date==636
		replace p_H1=20.95 if date==660
		replace p_H1=18.05 if date==614

		replace p_H2=22.36 if date==584 | date==585
		replace p_H2=33.26 if date==614


		tsset date
		tsfill, full

			forvalues r=1/16 {
			replace p_H1=p_H1[_n+`r'] if p_H1==.
			}
			forvalues r=1/16 {
			replace p_H2=p_H2[_n+`r'] if p_H2==.
			}
			forvalues r=1/16 {
			replace p_H3=p_H3[_n+`r'] if p_H3==.
			}
			forvalues r=1/16 {
			replace p_H4=p_H4[_n+`r'] if p_H4==.
			}
		duplicates drop date, force

	
	g p_L=0
	keep date p_H1 p_H2 p_H3 p_H4 p_L
	g class = 1

save "${temp}prices_5r_nocpi.dta", replace

			merge 1:1 date using "${data}cpi_psa_clean.dta"
			keep if _merge==3
			drop _merge	
*	scatter p_H1 date || scatter p_H2 date
*	scatter p_H1d date || scatter p_H2d date
		
	replace p_H1=p_H1*100/cpi
	replace p_H2=p_H2*100/cpi
	replace p_H3=p_H3*100/cpi
	replace p_H4=p_H4*100/cpi
	
*	scatter p_H1 date || scatter p_H2 date || scatter p_H3 date || scatter p_H4 date
	drop if p_H1==. | p_H2==. | p_H3==. | p_H4==.
	
	keep date p_L p_H1 p_H2 p_H3  p_H4 class
	order date p_L p_H1 p_H2 p_H3  p_H4 class



save "${temp}prices_5r.dta", replace

	
	
	
	use "${billingdata}pasay_billing_2008_2015.dta", clear
		append using "${billingdata}samp_billing_2008_2015.dta"
		append using "${billingdata}tondo_billing_2008_2015.dta"
		keep if billclass=="0002"
		* keep if regexm(readtag,"ACT")==1
		ren CON conacct
		
		keep conacct year month PREV PRES amount
		
		destring year month PREV PRES, replace force
		
		g c=PRES-PREV
		replace c=abs(c)
		replace c=. if c<0 | c>100
		drop if c==.
		
		g date=ym(year,month)
		
		g p_L=0
		
		bys amount date c: g A_N=_N
		gegen mAN=max(A_N), by(date c)
		keep if A_N==mAN
		
		g basic_charge_id=amount if c<=10 & amount<200
		gegen basic_charge=mean(basic_charge_id), by(date)
		
			g amount_id_1_l=amount-basic_charge if c==15 & amount<1000
			g amount_id_1_h=amount-basic_charge if c==16 & amount<1000
			g amount_id_2_l=amount-basic_charge if c==25 & amount<1500
			g amount_id_2_h=amount-basic_charge if c==26 & amount<1500
			g amount_id_3_l=amount-basic_charge if c==45 & amount<5500	& amount>500
			g amount_id_3_h=amount-basic_charge if c==46 & amount<5500	& amount>500		
			g amount_id_4_l=amount-basic_charge if c==65 & amount<6500	& amount>700
			g amount_id_4_h=amount-basic_charge if c==66 & amount<6500	& amount>700		
			
			gegen amount_1_l=mean(amount_id_1_l), by(date)
			gegen amount_1_h=mean(amount_id_1_h), by(date)
			gegen amount_2_l=mean(amount_id_2_l), by(date)
			gegen amount_2_h=mean(amount_id_2_h), by(date)
			gegen amount_3_l=mean(amount_id_3_l), by(date)
			gegen amount_3_h=mean(amount_id_3_h), by(date)
			gegen amount_4_l=mean(amount_id_4_l), by(date)
			gegen amount_4_h=mean(amount_id_4_h), by(date)
			
			g p_H1=amount_1_h-amount_1_l
			g p_H2=amount_2_h-amount_2_l
			g p_H3=amount_3_h-amount_3_l
			g p_H4=amount_4_h-amount_4_l
			
			bys date: g d_n=_n
			
	*	scatter p_H1 date if d_n==1 	
	*	scatter p_H1 date if d_n==1 || scatter p_H2 date if d_n==1 
		
		keep date p_H1 p_H2 p_H3 p_H4
		
		duplicates drop date, force
		
		tsset date
		tsfill, full
		
			forvalues r=1/16 {
			replace p_H1=p_H1[_n+`r'] if p_H1==.
			}
			forvalues r=1/16 {
			replace p_H2=p_H2[_n+`r'] if p_H2==.
			}
			forvalues r=1/16 {
			replace p_H3=p_H3[_n+`r'] if p_H3==.
			}
			forvalues r=1/16 {
			replace p_H4=p_H4[_n+`r'] if p_H4==.
			}
			

		replace p_H1=19.85 if date==576
		replace p_H1=19.85 if date==579
		replace p_H1=19.85 if date==582
		replace p_H1=19.85 if date==584
		replace p_H1=20.1 if date==589
		replace p_H1=20.1 if date==585

		replace p_H1=25.31 if date==600
		replace p_H1=29.49 if date==614
		replace p_H1=29.49 if date==624
		replace p_H1=32.96 if date==631
		replace p_H1=33.64 if date==642
		replace p_H1=30.20 if date==649
		replace p_H1=33.96 if date==660


		replace p_H2 = 24.02 if date==579
		replace p_H2 = 24.02 if date==582 | date==585 | date==584
		replace p_H2 = 24.2 if date==576
		replace p_H2 = 42.02 if date==660

		replace p_H2=30.87 if date==598	
		replace p_H2=30.87 if date==600
		*replace p_H2=29.49 if date==614
		replace p_H2=39.52 if date==624
		replace p_H2=39.52 if date==631
		replace p_H2=41.37 if date==636
		replace p_H2=41.17 if date==642
		replace p_H2=36.94 if date==649
		replace p_H2=41.37 if date==639
		
		replace p_H3 = 30.4 if date==576 | date==579 | date==582 | date==584 | date==585
		replace p_H3 = 30.79 if date==589
		replace p_H3 = 34.4 if date==591
		replace p_H3 = 52.12 if date==639

		replace p_H3=30.79 if date==587
		replace p_H3=38.83 if date==598
		replace p_H3=41.80 if date==600
		replace p_H3=41.80 if date==605
		replace p_H3=41.80 if date==606
		
		replace p_H3=50.03 if date==631
		replace p_H3=45.43 if date==624
		replace p_H3=50.70 if date==636
		replace p_H3=46.50 if date==642
		replace p_H3=46.51 if date==649
		replace p_H3=52.96 if date==660		
		
	
		replace p_H4=35.15 if date==579
		replace p_H4=34.88 if date==582
		replace p_H4=35.2 if date==584 | date==585
		replace p_H4=35.61 if date==589 | date==590
		replace p_H4=35.51 if date==591
		replace p_H4=44.98 if date==598
		replace p_H4=44.98 if date==600
		replace p_H4=48.41 if date==605
		replace p_H4=48.41 if date==606
		replace p_H4=48.4  if date==609
		replace p_H4=52.64 if date==624
		replace p_H4=58.15 if date==631
		replace p_H4=58.77 if date==636
		replace p_H4 = 58.9 if date==633
		replace p_H4 = 60.43 if date==638
		replace p_H4 = 60.43 if date==639
		replace p_H4=60.14 if date==642
		replace p_H4=53.9  if date==649

		* scatter p_H1 date
		* scatter p_H2 date
		* scatter p_H3 date
		* scatter p_H4 date

		
	g p_L=0
	keep date p_H1 p_H2 p_H3 p_H4 p_L
	g class = 2

save "${temp}prices_5s_nocpi.dta", replace

			merge 1:1 date using "${data}cpi_psa_clean.dta"
			keep if _merge==3
			drop _merge	
*	scatter p_H1 date || scatter p_H2 date
*	scatter p_H1d date || scatter p_H2d date
		
	replace p_H1=p_H1*100/cpi
	replace p_H2=p_H2*100/cpi
	replace p_H3=p_H3*100/cpi
	replace p_H4=p_H4*100/cpi
	
*	scatter p_H1 date || scatter p_H2 date || scatter p_H3 date || scatter p_H4 date
	drop if p_H1==. | p_H2==. | p_H3==. | p_H4==.
	
	keep date p_L p_H1 p_H2 p_H3 p_H4 class
	order date p_L p_H1 p_H2 p_H3  p_H4 class



save "${temp}prices_5s.dta", replace


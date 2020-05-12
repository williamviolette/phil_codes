

cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end

cap program drop gentablenp
program define gentablenp
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind1 ON `1' (conacct_1);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind2 ON `1' (conacct_2);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind3 ON `1' (conacct_3);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind4 ON `1' (conacct_4);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind5 ON `1' (conacct_5);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind6 ON `1' (conacct_6);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind7 ON `1' (conacct_7);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind8 ON `1' (conacct_8);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind9 ON `1' (conacct_9);"), dsn("phil")
	odbc exec("CREATE INDEX `1'_conacct_ind10 ON `1' (conacct_10);"), dsn("phil")
end





	use "${complaintdata}cc_12_2012_all.dta", clear
	 	g year="2012"
		g month="01"
	foreach r in 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_2012_all.dta", force
		replace month="`r'" if month==""
		replace year="2012" if year==""
	}
	foreach z in 2013  {
	foreach r in 01 02 03 04   10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
			replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2014 {
	foreach r in 01 02 03 04 05 06 07 08 09 10 11 12 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}
	foreach z in  2015 {
	foreach r in 01 02 03 04 05 {
	append using "${complaintdata}cc_`r'_`z'_all.dta", force
				replace month="`r'" if month==""
		replace year="`z'" if year==""
	}
	}	
	ren contract conacct1
	replace conacct=conacct1 if conacct1!=""
		ren classificationcode class
		destring conacct year month, replace force
	*	duplicates drop conacct year month, force
		drop if conacct==.

	replace type=var24 if type=="" & var24!=""
	replace type=lower(type)
	replace title=lower(title)

	keep type class conacct year month resolution issue typecode title
	replace resolution=lower(resolution)
	replace issue=lower(issue)
	format resol %100s


	g am = regexm(resolution,"after")==1 & regexm(resolution,"meter")==1


    g break_i = ( regexm(issue,"break")==1 | regexm(issue,"damage")==1 ) & regexm(issue,"pipe")==1
		replace break_i=0 if regexm(class,"WAAV")==1
    g break_r = ( regexm(resolution,"break")==1 | regexm(resolution,"damage")==1 ) & regexm(resolution,"pipe")==1
		replace break_r=0 if regexm(class,"WAAV")==1
		
	g vertical_r=regexm(resolution,"vertical")==1
	g vertical_i = regexm(issue,"vertical")==1

	
	g ugl_r=regexm(resolution,"ugl")==1
		replace ugl_r=0 if regexm(resolution," no ")==1
	g leak_r=regexm(resolution,"leak")==1
		replace leak_r=0 if regexm(resolution," no ")==1

	replace ugl_r = 0  if regexm(class,"WAAV")==1
	replace leak_r= 0 if regexm(class,"WAAV")==1

keep if ugl_r==1 | leak_r==1
g date= ym(year,month)
keep conacct date ugl_r am
duplicates drop conacct date, force

save "${temp}demand_leak.dta", replace


use "${temp}demand_leak.dta", clear

keep conacct 
duplicates drop conacct, force

gentable ln 





odbc load, exec(" SELECT N.* FROM ln_dist AS N JOIN (SELECT 1 AS j, conacct FROM ln) AS LL ON LL.conacct=N.conacct WHERE LL.j==1 ") dsn("phil") clear

ren conacctl conacctn

preserve
	keep conacctn
	ren conacctn conacct
	duplicates drop conacct, force
	gentable ln_10n
restore


forvalues r=1/10 {
	g long conacct_`r'_id  = conacctn if rank==`r'
	g distance_`r'_id = distance if rank==`r'
	g rank_`r'_id = rank if rank==`r'
	gegen conacct_`r' 	= max(conacct_`r'_id), by(conacct)
	gegen distance_`r'  = max(distance_`r'_id), by(conacct)
	gegen rank_`r' 		= max(rank_`r'_id), by(conacct)
	drop conacct_`r'_id distance_`r'_id rank_`r'_id 
}
drop rank conacctn
gegen ctag=tag(conacct)
keep if ctag==1
drop ctag
drop distance

gentablenp ln_10

save "${temp}ln_10.dta", replace




local bill_query ""
forvalues r = 1/12 {
	local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN (SELECT DISTINCT conacct FROM ln_10) AS B ON A.conacct=B.conacct"
	if `r'!=12{
		local bill_query "`bill_query' UNION ALL"
	}
}
odbc load, exec("`bill_query'")  dsn("phil") clear  
duplicates drop conacct date, force
save "${temp}ln_bill.dta", replace



*** THERE IS A MUCH FASTER WAY TO DO THIS! ***

local bill_query ""
	forvalues r = 1/12 {
		local bill_query "`bill_query'  SELECT A.conacct, A.date, A.c, A.class FROM billing_`r' AS A JOIN ln_10n AS B ON A.conacct=B.conacct"
		if `r'!=12{
			local bill_query "`bill_query' UNION ALL"
		}
	}
	odbc load, exec("`bill_query'")  dsn("phil") clear  
	duplicates drop conacct date, force
save "${temp}ln_bill_full_neighbors.dta", replace



use  "${temp}ln_bill.dta", clear
	merge m:1 conacct using "${temp}ln_10.dta", keep(3) nogen 
	merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
		ren distance p1d_original
		ren year_inst p1yr_original
		ren pipe_id p1id_original
		ren date_capex d1cap_original
	merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
		ren distance p2d_original
		ren year_inst p2yr_original
		ren pipe_id p2id_original
		ren date_capex d2cap_original
	merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
		ren distance p3d_original
		ren year_inst p3yr_original
		ren pipe_id p3id_original
		ren date_capex d3cap_original
	ren conacct conacct_original
	ren c c_original
	ren class class_original

		forvalues r=1/10 {
			ren conacct_`r' conacct
				merge m:1 conacct date using "${temp}ln_bill_full_neighbors.dta", keep(1 3) nogen 
				merge m:1 conacct using "${temp}dist_primary_points_conacct.dta", keep(1 3) nogen 
						ren distance p1d_`r'
						ren year_inst p1yr_`r'
						ren pipe_id p1id_`r'
						ren date_capex d1cap_`r'
					merge m:1 conacct using "${temp}dist_secondary_points_conacct.dta", keep(1 3) nogen
						ren distance p2d_`r'
						ren year_inst p2yr_`r'
						ren pipe_id p2id_`r'
						ren date_capex d2cap_`r'
					merge m:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(1 3) nogen 
						ren distance p3d_`r'
						ren year_inst p3yr_`r'
						ren pipe_id p3id_`r'
						ren date_capex d3cap_`r'
			ren conacct conacct_`r'
			ren c c_`r'
			ren class class_`r'
		}

save "${temp}ln_bill_full.dta", replace















use "${temp}ln_bill_full.dta", clear
ren *_original *

merge 1:1 conacct date using "${temp}demand_leak.dta"
	g LD = _merge==3
	drop if _merge==2
	drop _merge


	merge m:1 conacct using "${temp}conacct_dma_link.dta"
		drop if _merge==2
		drop _merge
	merge m:1 dma date using "${temp}nrw.dta"
		drop if _merge==2
		drop _merge

	merge m:1 conacct date using "${temp}demand_leak.dta", keep(1 3) nogen

gegen ugl_id = max(ugl_r), by(conacct)
gegen am_id = max(am), by(conacct)

g nrw = 1 - (bill/supp)
replace nrw = 0 if nrw<0
g high_loss= nrw>.25 & nrw<=1

g datel_id=date if LD==1
gegen datel = min(datel_id), by(conacct)

g Tl=date-datel
replace Tl=1000 if Tl<-24 | Tl>24
replace Tl=Tl+100

sum p2d, detail
g far = p2d>400

* keep if am_id==1

areg c i.Tl i.date, a(conacct)
coefplot, vertical keep(*Tl*)


* g up_5   = p1id==p1id_5 & p2d>p2d_5
* g down_5 = p1id==p1id_5 & p2d<p2d_5
* g up_10   = p1id==p1id_10 & p2d>p2d_10
* g down_10 = p1id==p1id_10 & p2d<p2d_10
* g up_1   = p1id==p1id_1 & p2d>p2d_1
* g down_1 = p1id==p1id_1 & p2d<p2d_1
* g up_3   = p1id==p1id_3 & p2d>p2d_3
* g down_3 = p1id==p1id_3 & p2d<p2d_3
* g up_2   = p1id==p1id_2 & p2d>p2d_2
* g down_2 = p1id==p1id_2 & p2d<p2d_2


g up_5   = p1id==p1id_5 & p1d>p1d_5
g down_5 = p1id==p1id_5 & p1d<p1d_5

g up_10   = p1id==p1id_10 & p1d>p1d_10
g down_10 = p1id==p1id_10 & p1d<p1d_10

g up_1   = p1id==p1id_1 & p1d>p1d_1
g down_1 = p1id==p1id_1 & p1d<p1d_1

g up_3   = p1id==p1id_3 & p1d>p1d_3
g down_3 = p1id==p1id_3 & p1d<p1d_3

g up_2   = p1id==p1id_2 & p1d>p1d_2
g down_2 = p1id==p1id_2 & p1d<p1d_2





areg c_10 i.Tl i.date if up_10==1 & c_10<100, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_10 i.Tl i.date if down_10==1 & c_10<100, a(conacct)
coefplot, vertical keep(*Tl*)


* areg c_10 i.Tl i.date if up_10==1 & c_10<100 & high_loss==1, a(conacct)
* coefplot, vertical keep(*Tl*)

* areg c_10 i.Tl i.date if down_10==1 & c_10<100 & high_loss==1, a(conacct)
* coefplot, vertical keep(*Tl*)




areg c_5 i.Tl i.date if up_5==1 , a(conacct)
coefplot, vertical keep(*Tl*)

areg c_5 i.Tl i.date if down_5==1, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_5 i.Tl i.date if up_5==1 & c_5<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_5 i.Tl i.date if down_5==1 & c_5<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)


areg c_3 i.Tl i.date if up_3==1 , a(conacct)
coefplot, vertical keep(*Tl*)

areg c_3 i.Tl i.date if down_3==1, a(conacct)
coefplot, vertical keep(*Tl*)


areg c_3 i.Tl i.date if up_3==1 & c_3<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_3 i.Tl i.date if down_3==1 & c_3<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)



areg c_2 i.Tl i.date if up_2==1 & c_2<100, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_2 i.Tl i.date if down_2==1 & c_2<100, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_2 i.Tl i.date if up_2==1 & c_2<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_2 i.Tl i.date if down_2==1 & c_2<100 & high_loss==1, a(conacct)
coefplot, vertical keep(*Tl*)


areg c_1 i.Tl i.date if up_1==1 & c_1<400 , a(conacct)
coefplot, vertical keep(*Tl*)

areg c_1 i.Tl i.date if down_1==1 & c_1<400 , a(conacct)
coefplot, vertical keep(*Tl*)



areg c_1 i.Tl i.date if up_1==1 & c_1<100 & p2d>200, a(conacct)
coefplot, vertical keep(*Tl*)

areg c_1 i.Tl i.date if down_1==1 & c_1<100 & p2d>200, a(conacct)
coefplot, vertical keep(*Tl*)




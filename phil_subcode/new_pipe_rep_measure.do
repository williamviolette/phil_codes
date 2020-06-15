
* 1)   LINK to specific projects! (TPR) VS (PPR)




use "${temp}capex_raw.dta", clear

	keep if var3!=""

	ren var4 dma
	ren var5 capex_year
	ren var6 activity
	ren var8 contract_no
	ren var9 cost
	ren var10 pipe_l

	ren var14 wsc_b
	ren var15 cmd_b
	ren var16 bv_b
	ren var17 supp_b
	ren var19 nrw_b

	ren var23 wsc_p
	ren var24 cmd_p
	ren var25 bv_p
	ren var26 supp_p
	ren var28 nrw_p

	ren var32 wsc_a
	ren var33 cmd_a
	ren var34 bv_a
	ren var35 supp_a
	ren var37 nrw_a
	ren var38 rec_a

foreach var of varlist *_b *_p *_a {
	destring `var', ignore(%) replace force
}
	
	destring capex_year, replace force

	g yr_d = "20"+substr(var3,1,2)
	destring yr_d, replace force
	replace yr_d=. if yr_d==20
	g mn_d = substr(var3,4,3)

	g month_d = 1 if mn_d=="Jan"
	replace month_d = 2 if mn_d=="Feb"
	replace month_d = 3 if mn_d=="Mar"
	replace month_d = 4 if mn_d=="Apr"
	replace month_d = 5 if mn_d=="May"
	replace month_d = 6 if mn_d=="Jun"
	replace month_d = 7 if mn_d=="Jul"
	replace month_d = 8 if mn_d=="Aug"
	replace month_d = 9 if mn_d=="Sep"
	replace month_d = 10 if mn_d=="Oct"
	replace month_d = 11 if mn_d=="Nov"
	replace month_d = 12 if mn_d=="Dec"

	g date_d = ym(yr_d,month_d)

	g yr_c = "20"+substr(var39,1,2)
	destring yr_c, replace force
	replace yr_c=. if yr_c==20
	g mn_c = substr(var39,4,3)

	g month_c = 1 if mn_d=="Jan"
	replace month_c = 2 if mn_c=="Feb"
	replace month_c = 3 if mn_c=="Mar"
	replace month_c = 4 if mn_c=="Apr"
	replace month_c = 5 if mn_c=="May"
	replace month_c = 6 if mn_c=="Jun"
	replace month_c = 7 if mn_c=="Jul"
	replace month_c = 8 if mn_c=="Aug"
	replace month_c = 9 if mn_c=="Sep"
	replace month_c = 10 if mn_c=="Oct"
	replace month_c = 11 if mn_c=="Nov"
	replace month_c = 12 if mn_c=="Dec"

	g date_c = ym(yr_c,month_c)

	g ongoing = regexm(var39,"on-going")==1
	g def = regexm(var39,"deferred")==1 | regexm(var39,"camcelled")==1
	drop month_* mn_* var*

	replace cost = regexs(1) if regexm(cost,"(.+)/") 
	replace pipe_l = regexs(1) if regexm(pipe_l,"(.+)/") 
	destring cost pipe_l, replace force

	duplicates drop dma, force
save "${temp}capex_clean.dta", replace


*** MERGE THE PIPES AGAIN!!! ***


	odbc load, exec("SELECT contract_n, year_inst, OGC_FID FROM pipes")  dsn("phil") clear  
	keep if contract_n!=""
	save "${temp}pipe_cn_test.dta", replace


use "${temp}capex_clean.dta", clear
	keep if contract_n!=""
	keep contract_n dma cost pipe_l
	replace contract_n=regexs(1) if regexm(contract_n,"^(.+) /")
	replace contract_n=regexs(1) if regexm(contract_n,"^(.+)/")
	replace contract_n=strtrim(contract_n)	
	replace contract_n=regexs(1) if regexm(contract_n,"^(.+) ")
	replace contract_n=regexs(1) if regexm(contract_n,"^(.+) ")
	drop if dma=="2008"

	duplicates drop contract_n,  force
	ren contract_n contract_n

		merge 1:m contract_n using "${temp}pipe_cn_test.dta", keep(3) nogen

	keep OGC_FID cost pipe_l

save "${temp}pipe_contract.dta", replace



use "${temp}conacct_rate.dta", clear

	keep conacct datec
	merge 1:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen
	ren pipe_id OGC_FID
	merge m:1 OGC_FID using "${temp}pipe_contract.dta", keep(1 3) nogen


g pre_pipe_id = datec<=550
gegen pres=sum(pre_pipe_id), by(OGC_FID)
keep if pres>10


g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>12 | pT<-6
replace pT=pT+10
replace pT=1 if pT==1010


tab pT 
tab pT if cost!=.

hist pT if cost!=. & year_inst>=2010
hist pT if cost==. & year_inst>=2010

tab pT if cost!=. & year_inst>=2010 & pT>7
tab pT if cost==. & year_inst>=2010 & pT>7





use "${temp}conacct_rate.dta", clear

	keep conacct datec
	merge 1:1 conacct using "${temp}dist_tertiary_points_conacct.dta", keep(3) nogen
	ren pipe_id OGC_FID
	merge m:1 OGC_FID using "${temp}pipe_contract.dta", keep(1 3) nogen

g pre_pipe_id = datec<=550
gegen pres=sum(pre_pipe_id), by(OGC_FID)
keep if pres>10
ren datec date

g o=1
gegen new=sum(o), by(OGC_FID date)

duplicates drop OGC_FID date, force

tsset OGC_FID date
tsfill, full
replace new=0 if new==.

gegen year_instm=max(year_inst), by(OGC_FID)
drop year_inst
ren year_instm year_inst

g cn=cost!=.
gegen cnm=max(cn), by(OGC_FID)



g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>12 | pT<-6
replace pT=pT+10
replace pT=1 if pT==1010


gegen yt = tag(OGC_FID year)
gegen nm = sum(new), by(OGC_FID year)


areg nm i.pT i.year if yt==1 & nm<20, a(OGC_FID) cluster(OGC_FID) r

coefplot, keep(*pT*) vertical


areg nm i.pT i.year if yt==1 & nm<20 & cnm==1, a(OGC_FID) cluster(OGC_FID) r

coefplot, keep(*pT*) vertical



* NR-15-SDS-PQ-01
* NR-15-GIP-TO-03
* NR-13-ACP-NV02-ST-01
* browse if regexm(contract_n,"NR")==1 & regexm(contract_n,"PQ")==1
* browse if regexm(contract_n,"ACP")==1 & regexm(contract_n,"NV")==1


	odbc load, exec("SELECT * FROM pipes_dma_int")  dsn("phil") clear  

		keep if pipe_class=="TERTIARY"
		destring year_inst, replace force
		ren int_length length
		egen ly=sum(length), by(dma_id year_inst)
		egen max_l=max(ly), by(dma_id)
		egen total_mru=sum(length), by(dma_id)
		keep if ly==max_l
		g shr=max_l/total_mru
	*	keep if year_inst>=2008
		keep length year_inst dma_id shr
		duplicates drop dma_id, force
		g str25 dma = dma_id
		drop dma_id
	save "${temp}pipe_year_old_dma.dta", replace



use "${temp}pipe_year_old_dma.dta", clear

	merge 1:1 dma using "${temp}capex_clean.dta"

	corr yr_d year_inst if year_inst>2010




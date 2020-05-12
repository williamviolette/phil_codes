


*** BRING IN DMA 


use "${temp}nrw_raw.dta", clear


global zc = 587

forvalues r=4(6)466 {
ren var`r' supp$zc
ren var`=`r'+1' bill$zc
global zc = $zc + 1
}

ren var2 dma
keep dma supp* bill*

preserve
	keep dma supp*
	reshape long supp, i(dma) j(date)
	drop if dma==""
	drop if supp==.
	save "${temp}nrw_supp.dta", replace
restore		

	keep dma bill*
	reshape long bill, i(dma) j(date)
	drop if dma==""
	drop if bill==.
	merge 1:1 dma date using  "${temp}nrw_supp.dta"
	keep if _merge==3
	drop _merge

save "${temp}nrw.dta", replace



odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
	destring mru, replace force
	gegen marea=max(area), by(mru)
	keep if marea==area
	duplicates drop mru, force

	g str10 dma = dma_id
		drop dma_id

	keep dma mru
save "${temp}mru_dma_link.dta", replace







use "${temp}conacct_rate.dta", clear
	bys datec mru: g mnew=_N
	keep mnew datec mru
	duplicates drop datec mru, force
	ren datec date
		merge m:1 mru using "${temp}mru_dma_link.dta"
		keep if _merge==3
		drop _merge
		merge m:1 mru using "${temp}mru_area.dta"
		drop if _merge==2
		drop _merge
	egen darea=sum(area), by(date dma)
	egen dnew=sum(mnew), by(date dma)
	keep dnew darea date dma
	duplicates drop date dma, force
save "${temp}dnew.dta", replace






odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
	destring mru, replace force
		merge m:1 mru using "${temp}mru_cf.dta"
		drop if _merge==2
		drop _merge
	g str10 dma = dma_id
		drop dma_id
		egen mrub_mean= mean(mrub), by(dma)
		egen mrub_max = max(mrub), by(dma)
		egen mrub_min = min(mrub), by(dma)

	keep mrub_* dma
	duplicates drop dma, force

	merge 1:m dma using "${temp}nrw.dta"
	keep if _merge==3
	drop _merge

	bys dma: g DN=_N
	g DNF=DN==78

g nrw = 1 - bill/supp
	cap drop mn
	cap drop tt
	cap drop treat
	cap drop mb
	cap drop ms

	  * g treat = mrub_min>=.8 & mrub_min<.
	* g treat= 0 if mrub_min<.8
	* replace treat=1 if mrub_mean>=.5 & mrub_mean<.
	 g treat = 0 if mrub_mean<.5
	 replace treat = 1 if mrub_mean>=.5

	gegen mn=mean(nrw), by(date treat DNF)
	gegen tt=tag(date treat DNF)

	gegen mb=mean(bill), by(date treat DNF)
	gegen ms=mean(supp), by(date treat DNF)

	twoway scatter mb date if tt==1 & treat==0 & date<650 & DNF==1 || ///
		   scatter mb date if tt==1 & treat==1 & date<650 & DNF==1 || ///
		   scatter ms date if tt==1 & treat==0 & date<650 & DNF==1 || ///
		   scatter ms date if tt==1 & treat==1 & date<650 & DNF==1, ///
		   legend(order(1 "Untreat bill" 2 "Treat bill" 3 "Untreat supp" 4 "Treat supp"))



	twoway scatter mn date if tt==1 & treat==0 & date<650 & DNF==0 || ///
		   scatter mn date if tt==1 & treat==1 & date<650 & DNF==0





odbc load, exec("SELECT * FROM mru_dma_int")  dsn("phil") clear  
	destring mru, replace force
		merge m:1 mru using "${temp}mru_cf.dta"
		drop if _merge==2
		drop _merge
	g str10 dma = dma_id
		drop dma_id

	egen mrub_mean= mean(mrub), by(dma)
	egen mrub_max = max(mrub), by(dma)
	egen mrub_min = min(mrub), by(dma)


	keep mrub_* dma
	duplicates drop dma, force

	merge 1:m dma using "${temp}nrw.dta"
	keep if _merge==3
	drop _merge

	merge 1:1 dma date using "${temp}dnew.dta"
		drop if _merge==2
		drop _merge

	g dnew1 = dnew if dnew<=100

	g bill1=bill if bill<=2
	g supp1=supp if supp<=2

	sort dma date
	by dma: g dl1 = dnew1[_n-1]
	by dma: g dl2 = dnew1[_n-2]


gegen dnews=sum(dnew1), by(dma)

g lnew_id = dnew if date>600
gegen lnew=sum(lnew_id), by(dma)


reg bill1 dnews

	areg supp1 dnew1 i.date , a(dma) // NOTHING EACH INDIVIDUAL IS TOO SMALL
	areg bill1 dnew1 i.date , a(dma) // NOTHING EACH INDIVIDUAL IS TOO SMALL

	g nrw = 1 - bill/supp


g lnew_a=lnew/darea
g mid=mrub_min>=.8

reg nrw lnew_a if date>660, cluster(dma) r
reg lnew_a mid if date>660, cluster(dma) r
reg nrw mid if date>660 , cluster(dma) r





	bys dma: g DN=_N
	g DNF=DN==78


	cap drop mn
	cap drop tt
	cap drop treat
	  * g treat = mrub_min>=.8 & mrub_min<.
	* g treat= 0 if mrub_min<.8
	* replace treat=1 if mrub_mean>=.5 & mrub_mean<.
	 g treat = 0 if mrub_max==0
	 replace treat = 1 if mrub_min>=.8 & mrub_min<.


	gegen mn=mean(nrw), by(date treat DNF)
	gegen tt=tag(date treat DNF)


	twoway scatter mn date if tt==1 & treat==0 & date<650 & DNF==1 || ///
		   scatter mn date if tt==1 & treat==1 & date<650 & DNF==1

	twoway scatter mn date if tt==1 & treat==0 & date<650 & DNF==0 || ///
		   scatter mn date if tt==1 & treat==1 & date<650 & DNF==0






odbc load, exec("SELECT A.msa_type, A.street_nam, C.conacct FROM meter AS A JOIN conacctseri AS C ON A.OGC_FID = C.OGC_FID")  dsn("phil") clear  
	drop if conacct==0
	duplicates drop conacct, force
	ren street_nam street
	replace street=subinstr(street,".","",.)
	replace street=subinstr(street,"RD","",.)
	replace street=subinstr(street,"ST","",.)
	replace street=subinstr(street,"ROAD","",.)
	replace street=subinstr(street,"STREET","",.)
	replace street=subinstr(street,"AVE","",.)
	replace street=strtrim(street)
	drop if street==""
	gegen stg = group(street)
	g mtype = 0 
	replace mtype = 1 if regexm(msa,"CLUSTERED")==1
	replace mtype = 2 if regexm(ms,"B")==1
	keep conacct mtype stg
save "${temp}mtype.dta", replace



odbc load, exec("SELECT A.* FROM neighbor AS A WHERE A.rank==1")  dsn("phil") clear  
			merge m:1 conacct using "${temp}conacct_rate.dta"
			keep if _merge==3
			drop _merge
	keep conacct conacctn datec
	ren conacct conaccto
	ren datec dateco
	ren conacctn conacct
			merge m:1 conacct using "${temp}conacct_rate.dta"
			keep if _merge==3
			drop _merge
	ren conacct conacctn
	ren datec datecn
	keep conacct* date*
	ren conaccto conacct
	ren dateco datec
save "${temp}neighbor_datec.dta", replace




use "/Users/williamviolette/Documents/Philippines/data/cf.dta", clear

		ren v5 conacct
		ren v17 ba2

	gegen inst = sum(v14), by(conacct)

	g year = substr(v16,1,4)
	g month = substr(v16,6,2)
	destring year month, replace force

	g datecf=ym(year,month)

	g adl=regexm(v26,"ADD")==1
	g napc=regexm(v26,"NAPC")==1
	g bnk= regexm(v26,"BNK")==1   |  ///
		   regexm(v26,"MTR B")==1 | ///
		   regexm(v26,"BK")==1 

	g clu= regexm(v26,"CL")==1   

	* browse if regexm(v26,"REOPEN")==1 | regexm(v26,"RESTO")

	foreach var of varlist adl napc bnk clu {
		gegen `var'_id = max(`var'), by(conacct)
		drop `var'
		ren `var'_id `var'
	}

	keep conacct datecf inst adl napc bnk clu 

	gegen min_date=min(datecf), by(conacct)
		keep if datecf==min_date
		drop min_date

	gegen ctag=tag(conacct)
		keep if ctag==1
		drop ctag

	keep if inst<10000
	keep if datecf>=541
save "${temp}cf_inst.dta", replace   // * around 90% of new accounts after 613!!



* use "${temp}cf_inst.dta", clear
* tab datecf napc
* * hist inst
* g icat= 1 if inst<=2800
* replace icat=2 if inst>2800 & inst<5500
* replace icat=3 if inst>=5500 & inst<.
* tab datecf icat
* g o=1
* gegen ot=sum(o), by(datecf icat)
* gegen otag=tag(datecf icat)
* twoway scatter ot datecf if otag==1 & datecf>570, by(icat, rescale) 
* g instadl=inst if adl==1
* gegen am=mean(instadl), by(datecf)
* twoway scatter am datecf if otag==1



*** MRU pros:  full data          cons: noisy eligibility measure, not full gps
*** STR pros: gps, clean measure  cons: gps subset, streets big enough?










use ${phil_folder}diff_in_diff_595/input/mcf_2015.dta, clear
	
		merge 1:1 conacct using "${temp}cf_inst.dta"
		drop if _merge==2
		g minst=_merge==3
		drop _merge


g icat= 1 if inst<=2800
replace icat=2 if inst>2800 & inst<5500
replace icat=3 if inst>=5500 & inst<.

	** SET GROUP HERE! ****
	* merge 1:1 conacct using "${temp}mtype.dta"
	* 	g mm=_merge==3
	* 	drop if _merge==2
	* 	drop _merge
	*  *   * gegen mmt = mean(mm), by(date_c) ; gegen dtt = tag(date_c) ; twoway scatter mmt date_c if dtt==1
	* g id_meter =  0 if date_c>=550 & date_c<=640
	* replace id_meter = 1 if id_meter==0 & mm==1
	* gegen mid_m = mean(id_meter), by(mru)
	* gegen mru_t = tag(mru)
	* keep if mid_m>=.75
	* ** hist mid_m if mru_t==1 // TEST METER COVERAGE! 
	* ** sum mid_m, detail
	* ** g mid1=0 if mid_m>=0 & mid_m<.8
	* ** replace mid1=1 if mid_m>=.8 & mid_m<=1
	* keep if mm==1
	* gegen msg = group(stg mru)
	**********************
	* drop if ba==1700

	**** MRU ****
	g msg=mru

	gegen napcm=max(napc), by(msg)
	g dpre=date_c<=590
	gegen dpres=sum(dpre), by(msg)
	g dpost=date_c>630
	gegen dposts=sum(dpost), by(msg)

	keep if dpres>5 & dpres<. 
	keep if dposts>5 & dposts<.
	keep if date_c>=550

 	g       bps = 0 if date_c>=620 & icat==3 
 	replace bps = 1 if date_c>=620 & icat==1

 	gegen mrub=mean(bps), by(msg)

		preserve 
			keep if mrub!=.
			keep mru mrub
			duplicates drop mru, force
			save "${temp}mru_cf.dta", replace
		restore

 	g o =1 
 	gegen tn = sum(o), by(msg date_c)
 	g oadd=icat==2
 	gegen tnadd=sum(oadd), by(msg date_c)

 	duplicates drop msg date_c, force

 	keep tn tnadd date_c mrub msg inst
 	tsset msg date_c
 	tsfill, full

 	replace tn=0 if tn==.
 	replace tnadd=0 if tnadd==.
 	gegen mrub_id=max(mrub), by(msg)
 	drop mrub
 	ren mrub_id mrub

g tnl=tn if tn<=50
g tnladd=tnadd if tnadd<=50

cap drop tr
cap drop tnm
cap drop tt
cap drop isl
cap drop mp

g tr = 0 if mrub==0
replace tr=1 if mrub>.8 & mrub<=1

gegen tnm = mean(tnl), by(date_c tr)
gegen tnmadd = mean(tnladd), by(date_c tr)
gegen tt = tag(date_c tr)
sort date_c tr tt

sort date_c tr tt
twoway  line tnm date_c if tt==1 & tr==0 || ///
	 	line tnm date_c if tt==1 & tr==1 , ///
	 	legend(order( 1 "0" 2 "1" )) xline(595)


gegen instm=mean(inst), by(date_c tr)

twoway  line instm date_c if tt==1 & tr==0 || ///
	 	line instm date_c if tt==1 & tr==1 , ///
	 	legend(order( 1 "0" 2 "1" )) xline(595)



sort date_c tr tt
twoway  line tnmadd date_c if tt==1 & tr==0 || ///
	 	line tnmadd date_c if tt==1 & tr==1 , ///
	 	legend(order( 1 "0" 2 "1" ))






cap prog drop data_prep_mru_c
prog  define  data_prep_mru_c
	
	  * local 1 qc_04
		use descriptives/output/`1'_billing_2008_2015.dta, clear
		
		keep if billclass=="0001"
			ren CONTRACT_A conacct
			keep conacct PREV PRES year month
			destring PREV PRES  year month, replace force
			g date=ym(year,month)
			drop year month

			g c=PRES-PREV
			replace c=. if c<0 | c>200
			
			keep conacct date c

			g cnm=c>0 & c<=200
			gegen cnms=sum(cnm), by(conacct)
			g cn_id = c if cnms>=70

			merge m:1 conacct using "${temp}conacct_rate.dta"
			keep if _merge==3
			drop _merge

			keep if datec<580

			merge m:1 conacct using "${temp}neighbor_datec.dta"
			drop if _merge==2
			drop _merge

			* cap drop dt
			* cap drop dt_id
			* cap drop T
			* cap drop cT
			* cap drop tt
			* g dt_id=date if date==datecn
			* gegen dt=max(dt_id), by(conacct)
			* g T = date-dt
			* gegen cT=mean(c), by(T)
			* gegen tt=tag(T)
				* twoway scatter cT T if tt==1 & T>=-24 & T<=24

			sort conacct date
			by conacct: g cn_ch_id = c[_n+2] - c[_n-2] if date==datecn

			g cshr_id = c if datecn>580 & datecn<.
			g cnshr_id = c if datecn<=580

			keep mru c cn_id cshr_id cnshr_id date cn_ch_id
			gegen cm = mean(c), by(mru date)
			gegen cn = mean(cn_id), by(mru date)
			gegen cshr = mean(cshr_id), by(mru date)
			gegen cnshr = mean(cnshr_id), by(mru date)
			gegen cnch = mean(cn_ch_id), by(mru date)
			drop cn_id cshr_id cnshr_id
			gegen mtag=tag(mru date)
			keep if mtag==1
			keep cm cn cshr cnshr cnch mru date 
			ren cm c
		
		save "${temp}`1'_mru_c.dta", replace
end
	
foreach v in bacoor muntin tondo pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para {
	data_prep_mru_c `v'
}
	

use  "${temp}tondo_mru_c.dta", clear
	foreach v in bacoor muntin pasay val samp qc_04 qc_12 qc_09 so_cal cal_1000 para  {	
	append using "${temp}`v'_mru_c.dta"
	}
	duplicates drop mru date, force
save "${temp}mru_c.dta", replace




use "${temp}mru_c.dta", clear

	merge m:1 mru using "${temp}mru_cf.dta"
		keep if _merge==3
		drop _merge

keep if date>588

* g tr1 = 0 if mrub==0
* replace tr1=1 if mrub>.8 & mrub<=1

* gegen cmshr = mean(cshr), by(date tr)
* gegen cmnshr=mean(cnshr), by(date tr)
* gegen tt1 = tag(date tr1)

* sort tt1 date tr1
* twoway line cmshr date if tt1==1 & tr1==0 & date<=620 || ///
* 	line cmnshr date if tt1==1 & tr1==0 & date<=620 || ///
* 	line cmshr date if tt1==1 & tr1==1 & date<=620 || ///
* 	line cmnshr date if tt1==1 & tr1==1 & date<=620, 	legend(order(1 "0" 2 "1" 3 "2" 4 "3" ))

* g cdiff=cmshr-cmnshr

* twoway line cdiff date if tt1==1 & tr1==0 & date<=620 || ///
* 	line cdiff date if tt1==1 & tr1==1 & date<=620 

g tr = 0 if mrub==0
replace tr=1 if mrub>0 & mrub<.25
replace tr=2 if mrub>=.25 & mrub<.5
replace tr=3 if mrub>=.5 & mrub<.75
replace tr=4 if mrub>=.75 & mrub<=1



* drop c
* ren cn c

drop c
ren cnch c


gegen cm = mean(c), by(date tr)
gegen tt = tag(date tr)

sort tt date tr
by tt date: g cm_ch1 = cm-cm[_n-1]
by tt date: g cm_ch2 = cm-cm[_n-2]
by tt date: g cm_ch3 = cm-cm[_n-3]
by tt date: g cm_ch4 = cm-cm[_n-4]


* keep if date>=590

sort date tr tt
twoway  line cm date if tt==1 & tr==0 || ///
	 	line cm date if tt==1 & tr==1 || ///
	 	line cm date if tt==1 & tr==2 || ///
	 	line cm date if tt==1 & tr==3 || ///
	 	line cm date if tt==1 & tr==4, ///
	 	legend(order(1 "0" 2 "1" 3 "2" 4 "3" 5 "4"))


twoway  line cm date if tt==1 & tr==0 & date<=620 || ///
	 	line cm date if tt==1 & tr==1 & date<=620 || ///
	 	line cm date if tt==1 & tr==2 & date<=620 || ///
	 	line cm date if tt==1 & tr==3 & date<=620 || ///
	 	line cm date if tt==1 & tr==4 & date<=620, ///
	 	legend(order(1 "0" 2 "1" 3 "2" 4 "3" 5 "4"))





twoway line cm_ch1 date if tt==1 & tr==1 || ///
	 	line cm_ch2 date if tt==1 & tr==2 || ///
	 	line cm_ch3 date if tt==1 & tr==3 || ///
	 	line cm_ch4 date if tt==1 & tr==4 || ///
	 	, legend(order(1 "0" 2 "1" 3 "2" 4 "3" ))


twoway	 line cm_ch1 date if tt==1 & tr==2 || ///
	 	line cm_ch2 date if tt==1 & tr==3 || ///
	 	line cm_ch3 date if tt==1 & tr==4 || ///
	 	, legend(order(1 "0" 2 "1" 3 "2"  ))


twoway	 line cm_ch1 date if tt==1 & tr==2 || ///
	 	line cm_ch2 date if tt==1 & tr==4


twoway  line cm_ch1 date if tt==1 & tr==1 & date<620

twoway  line cm_ch2 date if tt==1 & tr==2 & date<620

twoway  line cm_ch3 date if tt==1 & tr==3 & date<620

twoway  line cm_ch3 date if tt==1 & tr==4 & date<620


twoway  line cm_ch4 date if tt==1 & tr==4 & date<650


twoway  line cm date if tt==1 & tr==0 & date<630 || ///
	 	line cm date if tt==1 & tr==4 & date<630


	



***** ARE THE EFFECTS REALLY FOR ADDITIONAL METERS?!

	local 1 qc_04
		use descriptives/output/`1'_billing_2008_2015.dta, clear
		
		keep if billclass=="0001"
			ren CONTRACT_A conacct
			keep conacct PREV PRES year month
			destring PREV PRES  year month, replace force
			g date=ym(year,month)
			drop year month

			g c=PRES-PREV
			replace c=. if c<0 | c>200
			
			keep conacct date c

			keep if datec<580

			merge m:1 conacct using "${temp}neighbor_datec.dta"
			drop if _merge==2
			drop _merge

			ren conacct conacct_true
			ren conacctn conacct
				merge m:1 conacct using "${temp}cf_inst.dta"
				drop if _merge==2
				drop _merge
			ren conacct conacctn
			ren conacct_true conacct

		keep if datecn>590


		g icat= 1 if inst<=2800
		replace icat=2 if inst>2800 & inst<5500
		replace icat=3 if inst>=5500 & inst<.

		g T = date-datecn

		gegen cT = mean(c), by(T)
		gegen tt = tag(T)

		twoway scatter cT T if tt==1 & T>=-12 & T<=12



			gegen cTi = mean(c), by(T icat)
			gegen tti = tag(T icat)
		twoway scatter cTi T if tti==1 & T>=-12 & T<=12, by(icat, rescale)


			gegen cTin = mean(c), by(T napc)
			gegen ttin = tag(T napc)
		twoway scatter cTin T if ttin==1 & T>=-12 & T<=12, by(napc, rescale)



			* merge m:1 conacct using "${temp}conacct_rate.dta"
			* keep if _merge==3
			* drop _merge




	use ${phil_folder}diff_in_diff_595/input/mcf_2015.dta, clear
	
	
		merge 1:1 conacct using ${phil_folder}diff_in_diff_595/input/cf.dta
		drop if _merge==2
		g MERGE=_merge==3
		drop _merge

	keep if date_c>550


	* hist INST_SUM if INST_SUM<15000

	g b = INST_SUM>=500 & INST_SUM<2800

	gegen bm=mean(b), by(date_c)
	gegen dct=tag(date_c)
	twoway scatter bm date_c if dct==1

 	g bp = 0 if date_c>=610
 	replace bp = 1 if b==1 & date_c>=610

 	g bps = 0 if date_c>=610 & MERGE==1
 	replace bps = 1 if b==1 & date_c>=610 & MERGE==1
 	
 	gegen mrut=tag(mru)
 	gegen mrub=mean(bp), by(mru)
 	gegen mrubs=mean(bps), by(mru)

* sum mrub if mrut==1, detail
* hist mrub if mrut==1 & mrub>0
* hist mrubs  if mrut==1 
* hist mrubs  if mrut==1  & mrubs>0

preserve
	keep mru mrub 
	duplicates drop mru, force
	save "${temp}mru_cf.dta", replace
restore

g o=1

cap drop tr
cap drop tn
cap drop tt
cap drop isl
cap drop mp

g tr = 0 if mrub==0
replace tr=1 if mrub>0 & mrub<.25
replace tr=2 if mrub>.25 & mrub<.75
replace tr=3 if mrub>=.75 & mrub<=1

gegen tn = sum(o), by(date_c tr)
gegen tt = tag(date_c tr)
sort date_c tr tt

twoway  line tn date_c if tt==1 & tr==0 || ///
	 	line tn date_c if tt==1 & tr==1 || ///
	 	line tn date_c if tt==1 & tr==2 || ///
	 	line tn date_c if tt==1 & tr==3 

twoway  line tn date_c if tt==1 & tr==0 || ///
	 	line tn date_c if tt==1 & tr==2 , xline(613)



g isl = INST_SUM if INST_SUM<10000
gegen mp = mean(isl),  by(date_c tr)

twoway  line mp date_c if tt==1 & tr==0 || ///
	 	line mp date_c if tt==1 & tr==1 || ///
	 	line mp date_c if tt==1 & tr==2 



cap drop tr
cap drop tn
cap drop tt
cap drop isl
cap drop mp

g tr = 0 if mrub==0
replace tr=1 if mrub>0 & mrub<.8
replace tr=2 if mrub>=.8 & mrub<=1

gegen tn = sum(o), by(date_c tr)
gegen tt = tag(date_c tr)
sort date_c tr tt

twoway  line tn date_c if tt==1 & tr==0 || ///
	 	line tn date_c if tt==1 & tr==1 || ///
	 	line tn date_c if tt==1 & tr==2 




g o =1
gegen os=sum(o), by(mru date_c)
gegen mtag=tag(mru date_c)
g post  	 = date_c>=610 
g treat 	 = mrub>=.8 & mrub<=1
g post_treat = post*treat


reg os treat post post_treat if date_c<635 & mtag==1






odbc load, exec("SELECT * FROM paws_date")  dsn("phil") clear  

merge m:1 conacct using "${temp}conacct_rate.dta"
	keep if _merge==3
	drop _merge

merge m:1 mru using "${temp}mru_cf.dta"
	keep if _merge==3
	drop _merge

g treat = 0 if mrub==0
replace treat =10 if mrub>0 & mrub<.8
replace treat =1 if mrub>=.8 & mrub<=1
drop if treat ==10
* g treat=mrub>.5 & mrub<.

g post = wave==5
g treat_post = post*tr

g SHR=SHH>1 & SHH<.

reg SHR treat_post treat post , cluster(mru)  r
areg SHR treat_post treat i.wave, cluster(mru)  r a(mru)
areg SHR treat_post treat i.wave, cluster(conacct)  r a(conacct)

xi: areg SHR i.treat*i.wave, cluster(mru) r a(mru)

xi: areg SHH i.treat*i.wave, cluster(conacct) r a(conacct)

xi: areg SHO i.treat*i.wave, cluster(conacct) r a(conacct)


reg SHO treat_post treat post , cluster(mru)  r
areg SHO treat_post treat i.wave, cluster(mru)  r a(mru)
areg SHO treat_post treat i.wave, cluster(conacct)  r a(conacct)



	* cheap 


/*





		
	g MB=INST_SUM>500 & INST_SUM<2800
	replace MB=2 if INST_SUM>=2800 & INST_SUM<4500
	replace MB=3 if INST_SUM>=4500 & INST_SUM<.
	replace MB=2 if INST_SUM>=2800 & INST_SUM<5500 & date_c>605
	
		bys mru: g MR_n=_n
	
		g 			MBI=MB==1
		egen 		MBS=sum(MBI), by(mru)
		g 			NO_BANK = MBS<=0
		
		g 		 BANK_POST=1 if MB==1 & date_c>=610 & date_c<=630
		replace  BANK_POST=0 if MB!=1 & date_c>=610 & date_c<=630
		egen 	 FULL_BANK = mean(BANK_POST), by(mru)
		
	egen min_date=min(date_c), by(mru)
	g early=date_c<=550
	egen ed=sum(early), by(mru)
		keep if ed>5
		keep if min_date<560
		
		
		**** ! DOUBLE-CHECK ALL OF THE CLASSIFICATIONS ! ****
			* hist FULL_BANK if MR_n==1, discrete
			 g IR=round(INST_SUM,100) 
			 g dd=dofm(date_c)
			 g year=year(dd)
			 bys IR: g IRN=_N
			 
		   * tab IR year if IRN>500
	
	* preserve
	* 	* keep if date_c>610
	* 	* drop if conacct==.
	* 	* keep conacct MB
	* 	* export delimited using "${phil_folder}data/gis/constructed_files/cfee.csv", delimiter(",") replace
	* restore
	
	g pre=date_c<595
	egen MRU_TOT=sum(pre), by(mru)
	bys mru: g mru_n=_n
	sum MRU_TOT if mru_n==1, detail
	scalar define MRUN=r(mean)
	*sum MRU_TOT if mru_n==1 & MRU_TOT<1000, detail
	
		** ARE THERE MRU's WITH FULL COVERAGE BEFORE 580!?
	g       M_pre=1  if MERGE==1 & date_c<570
	replace M_pre=0  if MERGE==0 & date_c<570
	egen MRU_pre=mean(M_pre), by(mru)
		

		
	* 	hist MRU_pre if MR_n==1, discrete
	*	sum MRU_pre if MR_n==1, detail
	*** THIS OPTION KEEPS ONLY MRU's WITH HIGH COVERAGE BEFORE THE CHANGE
	*	keep if MRU_pre>.75
	
	*** DO THE FIRST STAGE HERE ACTUALLY ***
	
	g MBM=MBI
	replace MBM=. if MERGE==0
	
	egen mean_t=mean(MBM), by(date_c NO_BANK)
	egen mean_t1=mean(MBI), by(date_c NO_BANK)
	bys date_c NO_BANK: g d_n=_n
	
	egen mean_all=mean(MERGE), by(date_c NO_BANK)
	
	g bb=NO_BANK==0
	
	lab var bb "Treatment"
	lab define treat 0 "Untreated" 1 "Treated"
	lab values bb treat
	lab var mean_t "Mean Discounts"
	lab var date_c "Month"
	format date_c %tm
	
			g POST1=date_c>595
			g POST_bb=POST1*bb
			reg MBM bb POST_bb POST1, robust
			mat def mbm_res=e(b)
			scalar define mbm_dind=round(mbm_res[1,2],.001)
	
	
	
	
		line mean_t date_c if d_n==1 & date_c>545 & bb==1, caption("Event Study Estimate: `=100*mbm_dind'%") title("First Stage")
		* 	graph export "${output}diff_595_first_stage.pdf", as(pdf) replace
	
		
		file open newfile using "${output}first_stage.tex", write replace
		file write newfile "`=100*mbm_dind'"
		file close newfile
		
	
		keep if date_c>550
		ren date_c date	
	bys mru date: g T=_N
	
	g MB1_T=MB==1
	egen T_1=sum(MB1_T), by(mru date)
	g MB2_T=MB==2
	egen T_2=sum(MB2_T), by(mru date)
	g MB3_T=MB==3
	egen T_3=sum(MB3_T), by(mru date)
	
	bys mru date: g T_n=_n
	keep if T_n==1
	
	keep mru date T NO_BANK T_1 T_2 T_3
	tsset mru date
		tsfill
		replace T=0 if T==.
		replace T_1=0 if T_1==.
		replace T_2=0 if T_2==.
		replace T_3=0 if T_3==.
		
		
		egen NO_BANKM=max(NO_BANK), by(mru)
		drop NO_BANK
		ren NO_BANKM NO_BANK
		
		scalar define upper_bound=50
		
		g T1=T
		replace T1=`=upper_bound' if T1>`=upper_bound'
		ren T1 New_Connections

		g T1_1=T_1
			replace T1_1=`=upper_bound' if T1_1>`=upper_bound'
		g T1_2=T_2
			replace T1_2=`=upper_bound' if T1_2>`=upper_bound'
		g T1_3=T_3
			replace T1_3=`=upper_bound' if T1_3>`=upper_bound'
	
		g T1_23=T_2+T_3
			replace T1_23=`=upper_bound' if T1_23>`=upper_bound'
		
	g BANK=NO_BANK==0
		
	g date1=round(date,2)
	
			qui tab date1, g(D_)
			
			foreach var of varlist D_* {
			lab var `var' " "
			g NB_`var'=`var'
			lab var NB_`var' " "
			}
			
			foreach var of varlist D_* {
			lab var `var' " "
			g BA_`var'=`var'*BANK
			lab var BA_`var' " "
			}
			
			lab var NB_D_17 "-12"
			lab var NB_D_23 "0"
			lab var NB_D_29 "12"
			lab var BA_D_17 "-12"
			lab var BA_D_23 "0"
			lab var BA_D_29 "12"
		
		sum New_Connections
		scalar define NC=r(mean)
		
		drop NB_D_1-NB_D_2
		drop BA_D_1-BA_D_2
		
		*drop NB_D_1-NB_D_3
		*drop BA_D_1-BA_D_3
		
		* drop NB_D_110-NB_D_114
		drop NB_D_56-NB_D_57
		drop BA_D_56-BA_D_57
		xi: areg New_Connections NB_* BA_*, absorb(mru) robust cluster(mru)
		
		


		preserve
		
			parmest, fast
				   	g BA_id = regexm(parm,"BA")==1
				   	keep if BA_id==1
				   	g time = _n - 22
				   	lab var time "Time (Months to Leak)"

			    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
			    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
			    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
			    	 graphregion(color(gs16)) plotregion(color(gs16))  ///
			    	 ytitle("New Accounts Per Month") ///
			    	 title("Additional New Connections per Month for" "Treated Areas Relative to Untreated Areas", ///
					size(medsmall) color(black))  ylabel(-.5(.5).75)  ///
					xtitle("Months to Discount Policy") note("Avg. New Connections Per Month : `=round(NC,.01)'       Mean Connections per Area: `=round(MRUN,1)' ")

				graph export  "${output}diff_595.pdf", as(pdf) replace
			   
		restore



		*** DISCOUNT SIZE
			
		
		
		g POST=date>595 & date<.
		g POST_BANK=POST*BANK
		
		lab var BANK "Treated"
		lab var POST "Post"
		lab var POST_BANK "Post X Treated"
		lab var New_Connections "New Connections per month/area"
		
		sum New_Connections, detail
		scalar define NC_mean=round(r(mean),.01)
		
		areg New_Connections POST_BANK POST , absorb(mru) cluster(mru) robust
		est sto est1
			matrix def res   = e(b)
			scalar def slope = res[1,1]
			
			
		file open newfile using "${output}red_form_est.tex", write replace
		file write newfile "`=round(res[1,1],.01)'"
		file close newfile
	
			
		file open newfile using "${output}red_form_base.tex", write replace
		file write newfile "`=round(res[1,3],.01)'"
		file close newfile
			
		outreg2 using "${output}diff_595_reg_primary.tex", tex(frag) ///
		replace addtext("Avg. New Conn.","`=NC_mean'","Area FE","Yes") addnote("Clustered at the MRU Level: 3,757 MRUs") label ///
		ctitle("Diff-in-Diff Estimate") 
		
	
		
	*	areg T1_1  POST_BANK POST , absorb(mru) cluster(mru) robust
	
		label var T1_23 "New Full Price Connections"
		sum T1_23, detail
		scalar define NP_mean=round(r(mean),.01)
		
		reg T1_23 POST_BANK POST BANK , cluster(mru) robust
		
		outreg2 using "${output}diff_595_reg_secondary.tex", tex(frag) ///
		replace addtext("Avg. New Conn.","`=NP_mean'")addnote("Clustered at the MRU Level: 3,757 MRUs") label ///
		ctitle("Diff-in-Diff Estimate") 
		
		
		
		matrix def XX=e(b)
		scalar define would_have_added = round((XX[1,2]+XX[1,3]+XX[1,4]),.01)
		scalar list would_have_added
		
file open newfile using "${output}would_have_added.tex", write replace
file write newfile "`=would_have_added'"
file close newfile
		
		scalar define actually_added = round((XX[1,1]+XX[1,2]+XX[1,3]+XX[1,4]),.01)

file open newfile using "${output}actually_added.tex", write replace
file write newfile "`=actually_added'"
file close newfile
				
		scalar define substitution =  100*round(1 - (actually_added/would_have_added),.01)
		
			scalar list substitution
			

file open newfile using "${output}substitution.tex", write replace
file write newfile "`=substitution'"
file close newfile
							
		
		scalar define treated_months = 664-595
		
		file open newfile using "${output}treated_months.tex", write replace
		file write newfile "`=treated_months'"
		file close newfile
		
		scalar define total_effect = round(slope*treated_months,.02)
		
			scalar list total_effect
			
		file open newfile using "${output}total_effect.tex", write replace
		file write newfile "`=total_effect'"
		file close newfile
		
		scalar define mru_size= `=round(MRUN,1)'
		
			scalar list mru_size
			
		file open newfile using "${output}mru_size.tex", write replace
		file write newfile "`=mru_size'"
		file close newfile
		
		

			scalar list s2 s3	

		file open newfile using "${output}share_2_hhs.tex", write replace
		file write newfile "`=round(100*s2)'"
		file close newfile
		
		file open newfile using "${output}share_3_hhs.tex", write replace
		file write newfile "`=round(100*s3)'"
		file close newfile			

		
			disp mru_size*(1+s2+2*s3)*(1+.05)
		
		scalar define population_served=mru_size*(1+s2+2*s3)*(1+.05)
		
		file open newfile using "${output}population_served.tex", write replace
		file write newfile "`=round(population_served)'"
		file close newfile			
		
		file open newfile using "${output}increase_in_individual_connections.tex", write replace
		file write newfile "`=round(100*total_effect/population_served,.1)'"
		file close newfile			
		
		
		
		
			scalar define percent_increase = round(total_effect/population_served,.001)
		
		file open newfile using "${output}percent_increase_discount.tex", write replace
		file write newfile "`=100*percent_increase'"
		file close newfile
		
			scalar list percent_increase
	


	
	
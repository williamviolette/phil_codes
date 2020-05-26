* pressure.do




*** NOW! measure externalities .. HOW MANY?!?  enough....

* 1. narrow to low-flow MRUs  (high meter merge: eh; this happens naturally..)
* 
* 



*** DO THOSE WITH BOOSTER PUMPS REPORT BETTER FLOW?
* use "${temp}npaws_bill_full.dta", clear
* ren *_original *
* drop *_*
* sort conacct date
* merge m:1 conacct date using "${temp}paws_aib.dta", keep(3) nogen
* areg B no_flow, a(p3id) cluster(p3id) r
* areg B flow_hrs, a(p3id) cluster(p3id) r


use "${temp}paws_pipes_bill.dta", clear
drop class
	g dated=dofm(date)
	g year=year(dated)
		drop dated

	merge m:1 conacct year using "${temp}paws_year_aib.dta", keep(3) nogen

	merge m:1 conacct using "${temp}paws_pipes.dta", keep(1 3) nogen 


	g post =year>p3yr & year<.





use "${temp}paws_pipes_bill.dta", clear
drop class
	g dated=dofm(date)
	g year=year(dated)
		drop dated
	keep if year<=2011
	merge m:1 conacct using "${temp}paws_pipes_ranking.dta", keep(3) nogen 
	global nn = 12
	forvalues r=1/$nn {
		global z = $nn + 1 - `r'
		g BB_up${z}_b=B_up${z}==1
		g BB_up${z}_n=B_up${z}!=.
	}
	forvalues r=1/$nn {
		g BB_down`r'_b=B_down`r'==1
		g BB_down`r'_n=B_down`r'!=.
	}
replace c = . if c>100
egen up_sum 	= rowtotal(BB_up*b)
egen down_sum 	= rowtotal(BB_down*b)
areg c BM up_sum down_sum p1d p1r i.year if year<=2011,  cluster(p3id) a(p3id)
areg c BB_up*b BB_down*b p1d i.year if year<=2011, a(p3id) cluster(p3id)
	coefplot, keep(*BB*b*) vertical




*** THIS WORKS DECENTLY WELL! 

use "${temp}bill_paws_full.dta", clear
drop class
	g dated=dofm(date)
	g year=year(dated)
		drop dated
	* keep if year<=2013
	merge m:1 conacct using "${temp}paws_pipes_ranking.dta", keep(3) nogen 
	g BM_b = BM==1
	g BM_n = BM==0

	global nn = 24
	forvalues r=1/$nn {
		global z = $nn + 1 - `r'
		g BB_up${z}_b=B_up${z}==1
		g BB_up${z}_n=B_up${z}!=.
		g BMB_up${z}_b=BB_up${z}_b*BM
		g BMB_up${z}_n=BB_up${z}_n*BM
	}

	forvalues r=1/$nn {
		g BB_down`r'_b=B_down`r'==1
		g BB_down`r'_n=B_down`r'!=.
		g BMB_down`r'_b=BB_down`r'_b*BM
		g BMB_down`r'_n=BB_down`r'_n*BM
	}

replace c = . if c>100

egen up_sum 	= rowtotal(BB_up*b)
egen down_sum 	= rowtotal(BB_down*b)
g up_sum_BM = up_sum*BM
g down_sum_BM = down_sum*BM

areg c BM up_sum down_sum p1d p1r i.year if year<=2011,  cluster(p3id) a(p3id)
areg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year  if year<=2011,  cluster(p3id) a(p3id)

areg c BB_up*b BB_down*b p1d i.year if year<=2011 & BM==0, a(p3id) cluster(p3id)
	coefplot, keep(*BB*b*) vertical

* areg c BM BB_up*b BB_down*b p1d i.date,  cluster(p3id) a(p3id)
* 	coefplot, keep(*BB*b*) vertical
* reg c BM up_sum down_sum p1d p1r i.year,  cluster(p3id)
* reg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year,  cluster(p3id)

* egen nup_sum 	= rowtotal(BB_up*n)  robust to this!
* egen ndown_sum 	= rowtotal(BB_down*n)





use "${temp}bill_paws_full.dta", clear
drop class
	g dated=dofm(date)
	g year=year(dated)
		drop dated
	*keep if year<=2013
	merge m:1 conacct using "${temp}paws_pipes_ranking.dta", keep(3) nogen 
		g BM_b = BM==1
		g BM_n = BM==0

	forvalues r=1/6 {
		global z = 7 - `r'
		g BB_up${z}_b=B_up${z}==1
		g BB_up${z}_n=B_up${z}!=.
		g BMB_up${z}_b=BB_up${z}_b*BM
		g BMB_up${z}_n=BB_up${z}_n*BM
	}

	forvalues r=1/6 {
		g BB_down`r'_b=B_down`r'==1
		g BB_down`r'_n=B_down`r'!=.
		g BMB_down`r'_b=BB_down`r'_b*BM
		g BMB_down`r'_n=BB_down`r'_n*BM
	}

replace c = . if c>100

egen up_sum 	= rowtotal(BB_up*b)
egen down_sum 	= rowtotal(BB_down*b)

g up_sum_BM = up_sum*BM
g down_sum_BM = down_sum*BM

* egen nup_sum 	= rowtotal(BB_up*n)  robust to this!
* egen ndown_sum 	= rowtotal(BB_down*n)


areg c BM up_sum down_sum p1d p1r i.year,  cluster(p3id) a(p3id)
areg c BM up_sum down_sum p1d p1r i.year if year<=2011,  cluster(p3id) a(p3id)

areg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year,  cluster(p3id) a(p3id)
areg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year if year<=2011,  cluster(p3id) a(p3id)


areg c BM BB_up*b BB_down*b p1d i.date,  cluster(p3id) a(p3id)
	coefplot, keep(*BB*b*) vertical

* reg c BM up_sum down_sum p1d p1r i.year,  cluster(p3id)
* reg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year,  cluster(p3id)
* reg c BB_up*b BB_down*b p1d i.date,  cluster(p3id)
	* coefplot, keep(*BB*b*) vertical














use "${temp}paws_pipes_bill.dta", clear
drop class

	merge m:1 conacct using "${temp}paws_pipes.dta", keep(1 3) nogen 
	g dated=dofm(date)
	g year=year(dated)
		drop dated
	g post =year>p3yr & year<.

	merge m:1 conacct year using "${temp}paws_year_aib.dta", keep(1 3) nogen

keep if pconacct!=.
* keep if pd>=-5 & pd<=5

replace c = . if c>100 
gegen BM=max(B), by(pconacct)
gegen BMd=max(B), by(pconacct date)

forvalues r=1/8 {
g up`r'   = pd==-`r'
g down`r' = pd==`r'
* g up`r'_BM=BM*up`r'
* g down`r'_BM=BM*down`r'
g up`r'_BMd=BMd*up`r'
g down`r'_BMd=BMd*down`r'
}


areg c up* down* p1d i.date, a(p3id) cluster(p3id)


coefplot, keep(*BMd*) vertical







use "${temp}npaws_bill_full.dta", clear

ren *_original *

sort conacct date
by conacct: g tcd=c[_n-3]!=. & c[_n-2]!=. & c[_n-1]!=. & c==. & c[_n+1]==. & c[_n+2]==. & c[_n+3]==.
replace tcd = . if date==592 | date==653 | date==664


foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen



* 1 2
foreach  j in 1 {
	local d1set "5 10 15"
	local js 1
	g c`j'_up = c_`js' if p`j'd_`js'<p`j'd
	g c`j'_down = c_`js' if p`j'd_`js'>p`j'd
	foreach d1 in `d1set' {
		g c`j'_upd`d1' = c_`js' if p`j'd_`js'<p`j'd & distance_`js'>`d1'
		g c`j'_downd`d1' = c_`js' if p`j'd_`js'>p`j'd & distance_`js'>`d1'
	}
	forvalues r=`=`js'+1'/10 {
		replace c`j'_up=c_`r' if p`j'd_`r'<p`j'd & c`j'_up==. & c_`r'!=.
		replace c`j'_down=c_`r' if p`j'd_`r'>p`j'd & c`j'_down==. & c_`r'!=.
		foreach d1 in `d1set' {
			replace c`j'_upd`d1'   = c_`r' if p`j'd_`r'<p`j'd & c`j'_upd`d1'==. & c_`r'!=. &  distance_`r'>`d1'
			replace c`j'_downd`d1' = c_`r' if p`j'd_`r'>p`j'd & c`j'_downd`d1'==. & c_`r'!=. & distance_`r'>`d1'
		}
	}
}



gegen BM=max(B), by(conacct)
gegen BMI=min(B), by(conacct)
gegen NF=max(no_flow), by(conacct)
gegen NF1 = mean(no_flow), by(barangay date)


replace age=. if age>100
destring job,  replace force
g up_class=sclass=="AB" | sclass=="C"


sort conacct date
foreach var of varlist no_flow yes_flow B S flow_hrs barangay_id wave hhsize hhemp hho sub single age job up_class {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/8 {
		by conacct: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by conacct: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
	replace `var'1=. if date>645
}

g dated=dofm(date)
g year=year(dated)
g post =year>p3yr & year<.
g treat_id = post==0

gegen treat=max(treat_id), by(conacct)

g treat_post = treat*post
g treat_p1d = treat*p1d
g treat_post_p1d = treat*post*p1d

gegen yes_flow_pipe = mean(yes_flow), by(year p3id)
g B1_p1d=B1*p1d
g B1_post = B1*post
g B1_treat = B1*treat
g B1_yes_flow_pipe = B1*yes_flow_pipe

tab year, g(yy_)
foreach var of varlist yy_* {
	g `var'_p1d=`var'*p1d
	g `var'_treat_p1d = `var'*p1d*treat
}



reg  yes_flow p1d treat treat_post treat_p1d treat_post_p1d i.year, cluster(p3id) r
reg  yes_flow p1d treat treat_post treat_p1d treat_post_p1d i.year if B==0, cluster(p3id) r //	* actually less mitigation for the B==0 group!


reg  c p1d treat treat_post treat_p1d treat_post_p1d i.year if year<=2011, cluster(p3id) r

reg  B p1d treat treat_post treat_p1d treat_post_p1d i.year if year<=2011, cluster(p3id) r

reg  S p1d treat treat_post treat_p1d treat_post_p1d i.year if year<=2011, cluster(p3id) r




areg  c  yes_flow yes_flow_pipe B1 p1d i.year, cluster(p3id) r a(p3id)
areg  c  yes_flow yes_flow_pipe B1 B1_post B1_treat p1d treat post i.year, cluster(p3id) r a(p3id)


reg   c  B1 B1_yes_flow_pipe yes_flow_pipe treat p1d hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.year, cluster(p3id) r

areg  c  B1 B1_yes_flow_pipe yes_flow_pipe p1d hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.year, cluster(p3id) r a(p3id)


areg  c  B1 B1_p1d p1d hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.year, cluster(p3id) r a(p3id)
areg  c  yes_flow1 yes_flow_pipe B1 B1_p1d p1d hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.year, cluster(p3id) r a(p3id)




reg  c B1 p1d treat treat_post i.year, cluster(p3id) r

reg  c B1 hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1, cluster(p3id) r



reg  c B1 yes_flow, cluster(p3id) r

reg  c B1 yes_flow hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1, cluster(p3id) r



reg  yes_flow p1d treat treat_post treat_p1d treat_post_p1d yy_* , cluster(p3id)
reg  c  treat treat_p1d treat_post treat_post_p1d yy_* , cluster(p3id)


gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)


g B1_post = B1*post
g p1d_post = p1d*post
g BM_post = BM*post
g B1_p1d = B1*p1d
g B1_post_p1d = B1*post*p1d
g S1_post = S1*post

replace job = 0 if job==. & hhsize!=.
replace job1 = 0 if job1==. & hhsize1!=.



** THINK GRADIENT! **



reg yes_flow p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1, cluster(p3id) r
reg yes_flow p1d p1d_post post i.wave1 if e(sample)==1 , cluster(p3id) r

reg yes_flow p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 if B==0, cluster(p3id)
reg yes_flow p1d p1d_post post i.wave1 if e(sample)==1 &  B==0 , cluster(p3id)

reg c p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1, cluster(p3id) r
reg c p1d p1d_post post i.wave1 if e(sample)==1 , cluster(p3id) r

reg B p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1, cluster(p3id) r
reg B p1d p1d_post post i.wave1 if e(sample)==1 , cluster(p3id) r




areg yes_flow p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1, cluster(p3id) r a(ba)
areg yes_flow p1d p1d_post post i.wave1 if e(sample)==1 , cluster(p3id) r a(ba)




*** p3id is too small...

reg p1d hhsize hhemp hho sub single age i.job  up_class i.wave if p1d<800
areg p1d hhsize hhemp hho sub single age i.job up_class i.wave  if p1d<800, a(barangay_id)
* areg p1d hhsize hhemp hho sub single age i.job i.wave up_class if p1d<800, a(p3id)


reg p1d hhsize hhemp hho sub single age  up_class i.wave, cluster(p3id) r
areg p1d hhsize hhemp hho sub single age i.job up_class i.wave , cluster(p3id) a(barangay_id)
* areg p1d hhsize hhemp hho sub single age i.job i.wave up_class , a(p3id)






reg c p1d
* correlation is totally robust to controls
reg c p1d hhsize1 hhemp1 hho1 sub1 single1 age1 i.job1 up_class1 i.wave1 if p1d<800

areg c p1d i.wave1 if p1d<800, a(barangay_id1)
areg c p1d hhsize1 hhemp1 hho1 sub1 single1 age1 i.job1 up_class1 i.wave1 if p1d<800, a(barangay_id1)



areg yes_flow1 p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 , a(barangay_id1) cluster(conacct)
areg yes_flow1 p1d p1d_post post i.wave1 if e(sample)==1 , a(barangay_id1) cluster(conacct)

areg yes_flow1 p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 if B1==0 , a(barangay_id1) cluster(conacct)
areg yes_flow1 p1d p1d_post post i.wave1 if e(sample)==1  & B1==0 , a(barangay_id1) cluster(conacct)


areg flow_hrs p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 , a(barangay_id1) cluster(conacct)
areg flow_hrs p1d p1d_post post i.wave1 if e(sample)==1 , a(barangay_id1) cluster(conacct)

areg flow_hrs p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1  if B1==0, a(barangay_id1) cluster(conacct)
areg flow_hrs p1d p1d_post post i.wave1 if e(sample)==1  & B1==0, a(barangay_id1) cluster(conacct)


areg c p1d hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 , a(barangay_id1) cluster(conacct)
areg c p1d i.wave1 if e(sample)==1 , a(barangay_id1) cluster(conacct)

areg c p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 , a(barangay_id1) cluster(conacct)
areg c p1d p1d_post post i.wave1 if e(sample)==1 , a(barangay_id1) cluster(conacct)

areg B p1d p1d_post post hhsize1 hhemp1 hho1 sub1 single1 age1 up_class1 i.wave1 , a(barangay_id1) cluster(conacct)
areg B p1d p1d_post post i.wave1 if e(sample)==1 , a(barangay_id1) cluster(conacct)


reg p1d B S single i.wave
areg p1d B S single i.wave, a(barangay_id)
* areg p1d B S single i.wave, a(p3id)

reg p1d yes_flow flow_hrs single i.wave
areg p1d yes_flow flow_hrs single i.wave, a(barangay_id)



	areg c B yes_flow i.date , a(conacct) cluster(conacct) r

areg c B1 yes_flow1 i.date , a(conacct) cluster(conacct) r


areg c1_down B1 i.date , a(conacct) cluster(conacct) r
areg c1_up B1 i.date , a(conacct) cluster(conacct) r



areg c B1 i.date , a(conacct) cluster(conacct) r

areg c1_down B1  B1_post post i.date , a(conacct) cluster(conacct) r
areg c1_up B1  B1_post post i.date , a(conacct) cluster(conacct) r


areg c1_down B1  B1_post post i.date , a(conacct) cluster(conacct) r

areg c1_downd5  B1 i.date , a(conacct) cluster(conacct) r
areg c1_downd10 B1 i.date , a(conacct) cluster(conacct) r
areg c1_downd15 B1 i.date , a(conacct) cluster(conacct) r

areg c1_upd5  B1 i.date , a(conacct) cluster(conacct) r
areg c1_upd10 B1 i.date , a(conacct) cluster(conacct) r
areg c1_upd15 B1 i.date , a(conacct) cluster(conacct) r


areg cy post i.year if yt==1, a(conacct) cluster(p3id) r
areg c  post i.date,	      a(conacct) cluster(p3id) r

areg c B S, cluster(p3id) a(p3id)
areg c B1 S1 B1_post S1_post post i.date, a(conacct) cluster(conacct) r


g cup_gap=c-c1_up
g cdown_gap=c-c1_down


areg cup_gap B1 B1_post post i.date, a(p3id) cluster(p3id)

areg cdown_gap B1 B1_post post i.date, a(p3id) cluster(p3id)



areg B post i.wave, a(conacct) cluster(p3id) r
areg B post i.wave, a(barangay_id) cluster(barangay_id) r


g B_post = B*post

areg c B i.wave, a(barangay_id)
areg c B i.hhsize i.wave, a(barangay_id)

**** BIASED BY NEIGHBORS ON THE? PIPE!
areg c B post B_post i.wave, a(barangay_id)
areg c B post B_post i.hhsize i.wave, a(barangay_id)


areg c B1 post B1_post i.date, a(conacct)




areg B post p1d_post p1d i.wave, a(p3id) cluster(p3id) r

areg B post p1d_post p1d i.wave, a(conacct) cluster(conacct) r


areg c post p1d_post p1d i.year, a(p3id) cluster(p3id) r

areg c post p1d B1 B1_p1d p1d_post B1_post  B1_post_p1d i.year, a(p3id) cluster(p3id) r


areg B post p1d_post p1d i.wave, a(barangay_id) cluster(barangay_id) r


areg cy post p1d_post i.year if yt==1, a(conacct) cluster(p3id) r


areg c post BM_post i.date , a(conacct) cluster(p3id) r




* gegen Bmax=max(B), by(conacct)
* gegen Bmin=min(B), by(conacct)
* gegen ctag=tag(conacct)




* do proper event study...


use "${temp}conacct_rate.dta", clear

keep datec mru

g o=1
gegen new=sum(o), by(mru datec)
keep if datec>550
drop o
duplicates drop mru datec, force
tsset mru datec
tsfill, full
replace new=0 if new==.
replace new=. if new>10

merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

gegen cy=mean(new), by(mru year)
gegen yt=tag(mru year)

areg cy i.pT i.year if yt==1 , a(mru) cluster(mru) r 
	coefplot, keep(*pT*) vertical





use "${data}paws/clean/full_sample_b_1.dta", clear

destring may_exp_extra, replace force
ren may_exp_extra me
replace me=. if me>5000

g no_flow=flow_noon_6=="Wala"
g yes_flow = flow_noon_6=="Malakas"
destring flow_hrs, replace force
replace flow_hrs = . if flow_hrs==0

g nf1 = flow_6_noon=="Wala"
g nf2 = flow_noon_6=="Wala"
g nf3 = flow_6_mid=="Wala"
g nf4 = flow_mid_6=="Wala"

egen nft=rowtotal(nf1-nf4)

g yr=substr(interview_completion_date,1,4)
g mn=substr(interview_completion_date,6,2)
destring yr mn, replace force
g date=ym(yr,mn)
* drop yr mn

g SHH = shr_num_extra
destring SHH, replace force
destring hhsize, replace force

g hho= SHH - hhsize
replace hhsize = . if hhsize>12
replace hho = . if hho<0 | hho>14
g hs = hho>0 & hho<.

g sub=regexm(house,"Subdivided")==1
g single=regexm(house,"Single house")==1

gegen mf = mean(no_flow), by(barangay_id wave)
gegen mff = mean(nft), by(barangay_id wave)

destring wrs_exp_extra, replace force
drop wrs_exp
ren wrs_exp_extra wrs

gegen BM=max(B), by(conacct)

g well = regexm(alt_src,"Pribado")

g balde= storage=="Balde"
g drum= storage=="Drum"
g gallon= storage=="Galon"

g S = storage!=""
g B = booster=="Oo"


sum B if no_flow==1
sum B if no_flow==0

foreach var of varlist S balde drum gallon {
	sum `var' if no_flow==1
	sum `var' if no_flow==0
}

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g post = yr>year_inst
destring hhemp, replace force

g sub_post = sub*post

areg B sub  sub_post single no_flow flow_hrs i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r

areg me sub  sub_post single no_flow flow_hrs i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r



areg B sub i.wave, a(barangay) cluster(barangay) r


reg  B post, r
reg  B post i.wave, r
areg B post i.wave, r a(mru)

areg B post i.wave, r a(conacct)


reg B post single sub i.hhsize i.hhemp i.hho i.wave, r


reg me post i.yr if yr>=2008, r
areg me post i.yr if yr>=2008, r a(mru) cluster(mru)

reg me post single sub i.hhsize i.hhemp i.hho i.yr if yr>=2008, r
areg me post single sub i.hhsize i.hhemp i.hho i.yr if yr>=2008, r a(mru) cluster(mru)


reg B post i.yr if yr>=2008, r
areg B post i.yr if yr>=2008, r a(mru)






g B_post=B*post
* g BM_post=BM*post

gegen no_flowm = mean(no_flow), by(barangay wave)
g no_flowm_B = B*no_flowm

areg me no_flow B i.wave, a(barangay) cluster(barangay) r


areg me no_flow B i.wave, a(barangay) cluster(barangay) r

areg me no_flow B sub single i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r


areg me no_flowm B no_flowm_B i.wave, a(barangay) cluster(barangay) r

areg me no_flowm B no_flowm_B sub single i.hhsize i.hhemp i.hho i.wave, a(barangay) cluster(barangay) r


**** TEST DEMAND FOR PRESSURE ****

g no_flow_hhsize=no_flow*hhsize
g yes_flow_hhsize=yes_flow*hhsize

reg me no_flow hhsize no_flow_hhsize B i.wave, r cluster(conacct) 



areg hhsize post i.wave, a(mru) cluster(mru) r

areg hs post i.wave, a(mru) cluster(mru) r


areg drum post i.wave, a(mru) cluster(mru) r
areg B post i.wave, a(mru) cluster(mru) r


areg me B post B_post  i.wave, a(mru) cluster(mru) r

areg me B post B_post  i.wave, a(mru) cluster(mru) r


areg me B post B_post  i.wave, a(conacct) cluster(conacct) r


areg me B post B_post  sub single i.hhsize i.hhemp i.hho  i.wave, a(mru) cluster(mru) r

*** ARE THESE NEW PEOPLE CONNECTED OR REARRANGED CONNECTIONS?! LOOK AT TOTAL


areg me post i.wave, a(mru) cluster(mru) r
areg me post i.wave, a(conacct) cluster(mru) r


areg B post i.wave, a(mru) cluster(mru) r
areg me post BM_post BM i.wave, a(mru) cluster(mru) r

gegen YF = mean(yes_flow), by(wave barangay)
g B_YF= B*YF

* areg flow_hrs B if wave==3, a(mru) cluster(mru) r

areg me B YF i.wave, a(barangay_id) cluster(barangay_id) r


areg me B YF i.wave, a(conacct) cluster(conacct) r
areg me B yes_flow i.wave, a(conacct) cluster(conacct) r

areg me B i.wave, a(barangay) cluster(barangay) r


areg me YF i.wave, a(barangay_id) cluster(barangay_id) r

areg me YF B B_YF i.wave, a(barangay_id) cluster(barangay_id) r


* areg no_flow nrw i.date,  a(conacct) cluster(conacct) r
* areg yes_flow nrw i.date,  a(conacct) cluster(conacct) r
* areg flow_hrs nrw i.date,  a(conacct) cluster(conacct) r


areg B no_flow  i.wave, a(barangay_id) cluster(barangay_id)
areg drum no_flow  i.wave, a(barangay_id) cluster(barangay_id)

areg hho no_flow  i.wave, a(barangay_id) cluster(barangay_id)
areg hho mf  i.wave, a(barangay_id) cluster(barangay_id)
areg no_flow hho hhsize sub single i.wave, a(barangay_id) cluster(barangay_id)
areg B hho hhsize sub single, a(barangay_id) cluster(barangay_id)

areg B mf i.wave, a(barangay_id) cluster(barangay_id)
areg hho mf i.wave, a(barangay_id) cluster(barangay_id)


areg me mf i.wave, a(barangay_id) cluster(barangay_id)

areg me mff i.wave, a(barangay_id) cluster(barangay_id)



merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop ba zone_code dc-datec
merge m:1 mru using "${temp}mru_dma_link",  keep(1 3) nogen
merge m:1 dma date using "${temp}nrw.dta", keep(1 3) nogen 

g nrw= 1 - (bill/supp)
replace nrw=0 if nrw<0
g high_nrw=0 if nrw!=.
replace high_nrw=1 if nrw>.5 & nrw<=1

areg no_flow  nrw i.date,  a(dma) cluster(dma) r
areg yes_flow nrw i.date,  a(dma) cluster(dma) r
areg flow_hrs nrw i.date,  a(dma) cluster(dma) r

areg B nrw i.date,  a(dma) cluster(dma) r
areg S nrw i.date,  a(dma) cluster(dma) r

areg no_flow  high_nrw i.date, a(dma) cluster(dma) r
areg yes_flow high_nrw i.date, a(dma) cluster(dma) r
areg flow_hrs high_nrw i.date, a(dma) cluster(dma) r

areg B high_nrw i.date,  a(dma) cluster(dma) r
areg S high_nrw i.date,  a(dma) cluster(dma) r







use "${temp}npaws_bill_full.dta", clear
ren *_original *
drop *_*

merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

areg cy i.pT i.year if yt==1 , a(conacct) cluster(mru) r
	coefplot, keep(*pT*) vertical






use "${temp}bill_paws_full.dta", clear

replace c=. if c>100
	

merge 1:1 conacct date using "${temp}amount_paws_full.dta", keep(1 3) nogen
merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen
merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
	drop year

gegen BM=max(B), by(conacct)
gegen DM=max(drum), by(conacct)

g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

g post = year>year_inst
g post_BM=BM*post
g post_DM=DM*post


sort conacct date
foreach var of varlist B {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/6 {
		by conacct: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by conacct: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
	replace `var'1=. if date>625
}


gegen class_max=max(class), by(conacct)
gegen class_min=min(class), by(conacct)

drop if class_max>=3

sort conacct date
by conacct: g r_to_s_id = class[_n-1]==1 & class[_n]==2
g date_rs_id = date if r_to_s_id==1
replace date_rs_id=. if date_rs_id==577
gegen date_rs = min(date_rs_id), by(conacct)

g price_post = date>date_rs & date<.

g price = amount/c
replace price=. if price<5 | price>50

cap drop T
g T = date-date_rs
replace T = 1000 if T<-36 | T>36
replace T = T+100


* reg c i.T
* coefplot, vertical keep(*T*)

areg c i.T i.date, a(conacct)
coefplot, vertical keep(*T*)


reg price price_post if T>=-24+100 & T<=24+100

reg c price_post if T>=-24+100 & T<=24+100


reg c price_post if T>=-6+100 & T<=24+100


g TM = T==1100
g T1 = T
replace T1 = 0 if T==1100

g T2 = T1
replace T2 = 0 if T2>100

g price_post_post=price_post*post


reg c price_post i.class_max i.class_min T1 TM, cluster(mru) r


reg c post price_post  i.class_max i.class_min T1 TM, cluster(mru) r


reg c post price_post price_post_post i.class_max i.class_min T1 TM, cluster(mru) r

reg c post price_post price_post_post i.class_max i.class_min T1 TM,  r cluster(conacct)


reg B1 post price_post i.class_max i.class_min T1 TM, cluster(mru) r




g post_B1=post*B1


reg c post i.year if B1!=., cluster(mru) r

reg B1 post i.year if B1!=., cluster(mru) r





areg c post i.date if B1!=., a(conacct) cluster(mru) r




reg c post i.date if B!=., cluster(mru) r



areg cy B1 post post_B1 i.year if yt==1, a(conacct) cluster(mru) r


areg cy post i.year if yt==1, a(conacct) cluster(mru) r

areg cy post post_BM i.year if yt==1, a(conacct) cluster(mru) r


areg cy post post_BM post_DM i.year if yt==1, a(conacct) cluster(mru) r


areg cy post i.year if yt==1 & BM==0, a(conacct) cluster(mru) r
areg cy post i.year if yt==1 & BM==1, a(conacct) cluster(mru) r

areg cy i.pT i.year if yt==1, a(conacct) 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 & BM==0, a(conacct) 
	coefplot, keep(*pT*) vertical

areg cy i.pT i.year if yt==1 & BM==1, a(conacct) 
	coefplot, keep(*pT*) vertical






*** THIS DOES NEIGHBOR BOOSTER INTERACTION (BUT SAMPLE IS WAYYYY TOO SMALL!!!!)

use "${temp}paws_aib.dta", clear
	gegen BID = min(B), by(conacct)
	keep BID conacct
	duplicates drop conacct, force
save "${temp}BID.dta", replace


use "${temp}npaws_bill_full.dta", clear
forvalues r=1/10 {
	ren conacct_`r' conacct
	merge m:1 conacct using "${temp}BID.dta", keep(1 3) nogen
	ren conacct conacct_`r'
	ren BID BID_`r'
}

ren *_original *

foreach var of varlist  c c_* {
	replace `var'=. if `var'>100
}

merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
merge m:1 conacct using "${temp}conacct_rate.dta", keep(1 3) nogen
	drop dc-datec
merge m:1 mru using "${temp}pipe_year_old.dta", keep(1 3) nogen

forvalues r=1/10 {
g up`r' = p1d_`r'<p1d
g down`r' = p1d_`r'>p1d
}

local js 1
g c_up = c_`js' if up`js'==1
g c_down = c_`js' if down`js'==1
g c_upB = c_`js' if up`js'==1 & BID_1==1
g c_downB = c_`js' if down`js'==1 & BID_1==1
g c_upN = c_`js' if up`js'==1 & BID_1==0
g c_downN = c_`js' if down`js'==1 & BID_1==0
forvalues r=`=`js'+1'/10 {
replace c_up=c_`r' if up`r'==1 & c_up==. & c_`r'!=.
replace c_down=c_`r' if down`r'==1 & c_down==. & c_`r'!=.
replace c_upB=c_`r' if up`r'==1 & c_up==. & c_`r'!=. & BID_`r'==1
replace c_downB=c_`r' if down`r'==1 & c_down==. & c_`r'!=. & BID_`r'==1
replace c_upN=c_`r' if up`r'==1 & c_up==. & c_`r'!=. & BID_`r'==0
replace c_downN=c_`r' if down`r'==1 & c_down==. & c_`r'!=. & BID_`r'==0
}

sort conacct date
foreach var of varlist no_flow yes_flow B S flow_hrs barangay wave {
	cap drop `var'1
	g `var'1=`var'
	forvalues z=1/3 {
		by conacct: replace `var'1 = `var'[_n+`z'] if `var'1==. & `var'[_n+`z']!=.
		by conacct: replace `var'1 = `var'[_n-`z'] if `var'1==. & `var'[_n-`z']!=.
	}
	replace `var'1=. if date>625
}

***** SEE IF WE CAN GET USEFUL (PROPORTIONAL) CORRELATIONS FROM MRU! *****


gegen p1d_min_mru=min(p1d), by(mru)
g p1id_mru_id = mru if p1d==p1d_min_mru
gegen p1id_mru=min(p1id_mru_id), by(mru)

gegen p1m=mean(p1d), by(mru)

reg c p1m 

******

g c_d= c_down-c_up
g c_dB = c_downB-c_upB
g c_dN = c_downN-c_upN

gegen yes_flow1m=mean(yes_flow1), by(barangay_id1 wave1)
gegen no_flow1m=mean(no_flow1), by(barangay_id1 wave1)

g B_up = 0 if c_upN!=.
replace B_up = 1 if c_upB!=.

g B_down = 0 if c_downN!=.
replace B_down = 1 if c_downB!=.


g B_up1   = B_up==1
g B_down1 = B_down==1


reg c B_up1 B_down1 p1d


areg c B B_up1 B_down1 p1d i.date, cluster(conacct) a(barangay_id1)



areg c_down B1 c_up c yes_flow1m i.date , a(barangay_id1) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(barangay_id1) cluster(conacct) r


reg c_down B1 c_up c yes_flow1m  , r
reg c_up B1 c_down c yes_flow1m  , r


areg c_down B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(conacct) cluster(conacct) r

areg c_down B1  c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1    c yes_flow1m i.date , a(conacct) cluster(conacct) r


areg c_down B1  yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1    yes_flow1m i.date , a(conacct) cluster(conacct) r



areg c_down B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_up B1 c_down c yes_flow1m i.date , a(conacct) cluster(conacct) r




areg c_downB B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r
areg c_downN B1 c_up c yes_flow1m i.date , a(conacct) cluster(conacct) r



g dated=dofm(date)
g year=year(dated)
gegen cy=mean(c), by(conacct year)
gegen yt=tag(conacct year)
gegen cdy=mean(c_d), by(conacct year)

cap drop pT
g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10

g far = p1d>200
g post = year>year_inst
g post_far = post*far
g post_BM = post*BM


* areg c_d B1 i.date, a(mru)
* areg c_down B1 i.date, a(mru)
* areg c_up B1 i.date, a(mru)



areg cy post post_far post_f2ar i.year if yt==1, a(conacct) cluster(mru) r

areg cdy post i.year if yt==1, a(conacct) cluster(mru) r

areg cdy post post_BM i.year if yt==1 , a(conacct) cluster(mru) r

areg c_d B1 yes_flow1m i.pT i.date , a(conacct) cluster(conacct) r
* areg c_d2 B1 yes_flow1m i.pT i.date , a(conacct) cluster(conacct) r






**** TRY BARANGAY EXTERNALITY?! ****
**** ACTUALLY KIND OF WORKS! ****

use "${temp}npaws_bill_full.dta", clear
	ren *_original *
	drop *_*

	merge m:1 conacct date using "${temp}paws_aib.dta", keep(1 3) nogen
	
gegen b1 = max(barangay_id), by(conacct)
gegen b_max=max(p1d), by(b1)
gegen b_min=min(p1d), by(b1)

g b_d= (p1d-b_min)/(b_max - b_min)

egen pg=cut(p1d), at(0(50)2500)

egen b_dg=cut(b_d), at(0(.1)1)
replace b_dg=b_dg*10

gegen nf_bdg=mean(no_flow), by(b_dg)

reg B b_d p1d  i.wave, cluster(conacct) r
reg B b_d nf_bdg  i.wave, cluster(conacct) r

reg B b_d no_flow p1d  i.wave, cluster(conacct) r
reg c b_d no_flow p1d  i.wave, cluster(conacct) r

reg B b_d p1d  i.wave, cluster(conacct) r
reg c b_d p1d  i.wave, cluster(conacct) r


reg no_flow b_d p1d  i.wave, cluster(conacct) r

reg B b_d i.pg i.wave, cluster(conacct) r
reg B i.b_dg i.pg i.wave, cluster(barangay) r
areg B p1d i.wave, a(barangay_id) cluster(conacct) r



****  FAMILY MATCH! ****


use "${temp}paws_aib.dta", clear
	keep barangay_id conacct
	duplicates drop conacct, force
save "${temp}paws_bar.dta", replace






use "${temp}npaws_bill_full.dta", clear
drop c_* class_*
drop date
	gegen dt=tag(conacct_original)
	keep if dt==1
	drop dt

ren conacct_original conacct
merge m:1 conacct using "${temp}name_g.dta", keep(1 3) nogen
ren ln ln_original
ren fn fn_original
ren conacct conacct_original

forvalues r=1/10 {
	ren conacct_`r' conacct
	merge m:1 conacct using "${temp}name_g.dta", keep(1 3) nogen
	merge m:1 conacct using "${temp}paws_bar.dta", keep(1 3) nogen
	ren barangay_id barangay_id_`r'
	ren conacct conacct_`r'
	ren ln ln_`r'
	ren fn fn_`r'
}

	ren *_original *

merge 1:m conacct using "${temp}paws_aib", keep(1 3) nogen	



cap drop fam_up
cap drop fam_down
cap drop tot_up
cap drop tot_down
cap drop fam_upr
cap drop fam_downr 

g fam_up = 0
g tot_up = 0
g fam_down = 0
g tot_down = 0

forvalues r=1/10 {
	replace fam_up = fam_up + 1 if ln==ln_`r' & p1d>p1d_`r' 
	replace tot_up = tot_up + 1 if p1d>p1d_`r'
	replace fam_down = fam_down + 1 if ln==ln_`r' & p1d<p1d_`r' 
	replace tot_down = tot_down + 1 if p1d<p1d_`r'

}

g fam_upr = fam_up/tot_up
g fam_downr = fam_down/tot_down

g fup_id = fam_up>0 & fam_up<.
g fud_id = fam_down>0 & fam_down<.

egen pg= cut(p1d), at(0(200)2500)


areg B fam_upr fam_downr i.wave, cluster(barangay_id) a(barangay_id) r



areg B fup_id fud_id i.pg i.date, cluster(barangay_id) a(barangay_id) r









**** THE YEAR APPROACH IS KINDA WEIRD ****
use "${temp}bill_paws_full.dta", clear
drop class
	g dated=dofm(date)
	g year=year(dated)
		drop dated

	keep if year<=2011

	merge m:1 conacct using "${temp}paws_pipes_only_ranking_yr.dta", keep(3) nogen 

	g BM_b = BM==1
	g BM_n = BM==0

	forvalues z=2008/2011 {
		forvalues r=1/12 {
			replace B_up`r' = By_`z'_up`r' if year==`z'
			replace B_down`r' = By_`z'_down`r' if year==`z'
		}
	}


	forvalues r=1/6 {
		global z = 7 - `r'
		g BB_up${z}_b=B_up${z}==1
		g BB_up${z}_n=B_up${z}!=.
		g BMB_up${z}_b=BB_up${z}_b*BM
		g BMB_up${z}_n=BB_up${z}_n*BM
	}

	forvalues r=1/6 {
		g BB_down`r'_b=B_down`r'==1
		g BB_down`r'_n=B_down`r'!=.
		g BMB_down`r'_b=BB_down`r'_b*BM
		g BMB_down`r'_n=BB_down`r'_n*BM
	}

replace c = . if c>100



egen up_sum 	= rowtotal(BB_up*b)
egen down_sum 	= rowtotal(BB_down*b)

g up_sum_BM = up_sum*BM
g down_sum_BM = down_sum*BM

egen nup_sum 	= rowtotal(BB_up*n)  
egen ndown_sum 	= rowtotal(BB_down*n)

g nup_sum_BM = nup_sum*BM
g ndown_sum_BM = ndown_sum*BM


reg c BB_up*b BB_down*b p1d i.date,  cluster(p3id)
	coefplot, keep(*BB*b*) vertical

areg c BM BB_up*b BB_down*b p1d i.date,  cluster(p3id) a(p3id)
	coefplot, keep(*BB*b*) vertical



reg c BM up_sum down_sum nup_sum ndown_sum p1d p1r i.year,  cluster(p3id)

reg c BM up_sum up_sum_BM down_sum down_sum_BM p1d p1r i.year,  cluster(p3id)

areg c BM up_sum down_sum nup_sum ndown_sum p1d p1r i.year,  cluster(p3id) a(p3id)

areg c BM up_sum up_sum_BM down_sum down_sum_BM nup_sum nup_sum_BM ndown_sum ndown_sum_BM p1d p1r i.year,  cluster(p3id) a(p3id)





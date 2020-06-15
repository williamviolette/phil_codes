* pressure_pasay_case_study.do


use "/Users/williamviolette/Documents/Philippines/descriptives/output/pasay_billing_2008_2015.dta", clear


keep CONTRACT_A volume month year
destring *, replace
ren CON conacct

g date=ym(year,month)
drop year month
duplicates drop conacct date, force
tsset conacct date
tsfill, full

fmerge m:1 conacct using "${temp}conacct_rate.dta", keep(3) nogen
drop if date<datec

fmerge m:1 mru using "${temp}mru_set.dta", keep(3) nogen

fmerge m:1 mru using "${temp}pipe_year_nold.dta", keep(1 3) nogen



g dated=dofm(date)
g year=year(dated)

g pT = year-year_inst
replace pT=1000 if pT>6 | pT<-6
replace pT=pT+10
replace pT=1 if pT==1010

gegen yt =tag(mru year)

cap drop cm
cap drop cmm

g cm=volume==.  if datec<560

gegen cmm=mean(cm), by(mru year)


areg cmm i.pT i.year if yt==1, a(mru)
coefplot, vertical keep(*pT*)









	* save pollfish/w2.dta, replace	
	* save pollfish/w3.dta, replace
	* save pollfish/w4.dta, replace
	* save pollfish/w5.dta, replace
	* save pollfish/w6.dta, replace	
	* save pollfish/w7.dta, replace
	
	
	use "${data}pollfish/w2.dta", clear
	
	ren whatwasthetotalbillforthewaterco pay 
	ren  howmuchwaterdidyourhouseholdusef use
	

	ren ifawaterconnectionfrommaynilador alt
	ren whatisthepriceperliterfromthiswa alt_price
	
	ren doesyourhouseholdownthewaterconn own 
	
	
	ren whichbestdescribeshowyourhouseho conn1
	
	g conn=1 if regexm(conn1,"1")==1
	replace conn=2 if regexm(conn1,"2")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1
	ren var16 fee2
	ren var17 bill2
	
	replace fee1 = fee2 if fee1=="-"
	
	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	replace bill1= bill2 if bill1=="-"
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	
		** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren howmanytotalpeopleusethewatercon shrtot
	
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
		
	g idn=_n
	g wave=2
	destring pay use, replace force
	order idn wave conn TYPE fee bill own alt alt_price pay use    shrtot gender yearofbirth hhsize inc
	keep idn wave conn TYPE fee bill own alt alt_price pay use    shrtot gender yearofbirth hhsize inc
	
	save "${data}pollfish/w2_e.dta", replace
	
	
	
	use "${data}pollfish/w3.dta", clear
	
	ren howmuchdidyourhouseholdpayforwat pay 
	ren  howmuchwaterdidyourhouseholdusef use
	
	ren withoutawaterconnectionfrommayni alt
	ren whatisthepriceforfillingacontain alt_price
	
	
	ren doesyourhouseholdownthewaterconn own 
	
	ren whichbestdescribeshowyourhouseho conn1
	
		g conn=1 if regexm(conn1,"1")==1
		replace conn=2 if regexm(conn1,"2")==1
		replace conn=0 if regexm(conn1,"alone")==1
		
		ren howdosharinghouseholdsaccessthec access1
		
		g access="single tap" if regexm(access1,"provides a single")==1
		replace access="connect pipes" if regexm(access1,"pipes/plumbing")==1
		replace access="fetch"  if regexm(access1,"fetch")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1

	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	ren whatarethemainreasonsthewaterbil reason
	
	
		** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren whattypeofdwellingdoesyourhouseh dwelling
	ren howmanyotherpeopledoesyourhouseh shroth
		
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
		
	g idn=_n
	g wave=3
	destring pay use, replace force
	order idn wave conn TYPE fee bill access reason own alt alt_price pay use    shroth gender yearofbirth hhsize inc dwelling
	keep idn wave conn TYPE fee bill access reason own alt alt_price pay use    shroth gender yearofbirth hhsize inc dwelling
	
	save "${data}pollfish/w3_e.dta", replace
	
	
	
	
	
	
	use "${data}pollfish/w4.dta", clear
	
	ren howmuchdoesyourhouseho pay 
	
	
*	tab howmuchdoesyourhouseholdspendeac  wheredoyouaccesswaterfromprimari
	
	ren withoutawaterconnectionfrommayni alt
	ren var24 alt_price
	
	
	
	ren whatarethemainissueswithwateracc issue
	
	ren whichbestdescribeshowyourhouseho conn1
	
		g conn=1 if regexm(conn1,"1")==1
		replace conn=2 if regexm(conn1,"2")==1
		replace conn=0 if regexm(conn1,"alone")==1
		
		ren howdosharinghouseholdsaccessthec access1
		
		g access="single tap" if regexm(access1,"provides a single")==1
		replace access="connect pipes" if regexm(access1,"pipes/plumbing")==1
		replace access="fetch"  if regexm(access1,"fetch")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1

	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	ren whatarethemainreasonsthewaterbil reason
	
	ren doesyourhouseholdownthewaterconn own
	
	
		** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren whattypeofdwellingdoesyourhouseh dwelling
	ren howmanyotherpeopledoesyourhouseh shroth
		
	
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
	
	ren wheredoyouaccesswater alt_access
		
	g idn=_n
	g wave=4
	destring pay , replace force
	order idn wave conn alt_access TYPE fee bill access reason own issue alt alt_price pay    shroth gender yearofbirth hhsize inc dwelling
	keep idn wave conn  alt_access TYPE fee bill access reason own issue alt alt_price pay    shroth gender yearofbirth hhsize inc dwelling
	
	save "${data}pollfish/w4_e.dta", replace
	
	
	
	
	
	use "${data}pollfish/w5.dta", clear
		
	ren howmuchdoesyourhouseholdspendeac pay 
	
	*tab howmuchdoesyourhouseholdspendeac  wheredoyouaccesswaterfromprimari
	*ren withoutawaterconnectionfrommayni alt
	*ren var24 alt_price
	
	
	
	ren whatarethemainissueswithwateracc issue
	
	ren whichbestdescribeshowyourhouseho conn1
	
		g conn=1 if regexm(conn1,"1")==1
		replace conn=2 if regexm(conn1,"2")==1
		replace conn=0 if regexm(conn1,"alone")==1
		
		ren howdosharinghouseholdsaccessthec access1
		
		g access="single tap" if regexm(access1,"provides a single")==1
		replace access="connect pipes" if regexm(access1,"pipes/plumbing")==1
		replace access="fetch"  if regexm(access1,"fetch")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1

	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	*ren whatarethemainreasonsthewaterbil reason
	
	ren doesyourhouseholdownthewaterconn own
	
	g neighbor= regexm(ifyourwaterpip,"neighbor")==1
		
	ren ifyourwaterpipewasbrokenfor3mont leak_switch
	
				** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren whattypeofdwellingdoesyourhouseh dwelling
	ren howmanyotherpeopledoesyourhouseh shroth
		
	
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
		
	ren wheredoyouaccesswate alt_access
		
	g idn=_n
	g wave=5
	destring pay, replace force
	order idn wave conn TYPE fee bill access alt_access own issue leak_switch neighbor pay    shroth gender yearofbirth hhsize inc dwelling
	keep idn wave conn TYPE fee bill access alt_access  own issue leak_switch neighbor pay    shroth gender yearofbirth hhsize inc dwelling
	
	save "${data}pollfish/w5_e.dta", replace
	
	
	
	
	
	
	
	
	
	use "${data}pollfish/w6.dta", clear
	
	
	g neighbor= regexm(ifyourwaterpip,"neighbor")==1
		
	ren howmuchdoesyourhouseholdspendeac pay 
	
	*tab howmuchdoesyourhouseholdspendeac  wheredoyouaccesswaterfromprimari
	*ren withoutawaterconnectionfrommayni alt
	*ren var24 alt_price
	
	ren whatisthemainissuewithwateracces issue
	
	ren whichbestdescribeshowyourhouseho conn1
	
		g conn=1 if regexm(conn1,"1")==1
		replace conn=2 if regexm(conn1,"2")==1
		replace conn=0 if regexm(conn1,"alone")==1
		
		ren howdosharinghouseholdsaccessthec access1
		
		g access="single tap" if regexm(access1,"provides a single")==1
		replace access="connect pipes" if regexm(access1,"pipes/plumbing")==1
		replace access="fetch"  if regexm(access1,"fetch")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1

	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	*ren whatarethemainreasonsthewaterbil reason
	
	ren doesyourhouseholdownthewaterconn own
	
					** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren whattypeofdwellingdoesyourhouseh dwelling
	ren howmanyotherpeopledoesyourhouseh shroth
			
	
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
	
	ren wheredoyouaccesswate alt_access
	
	
	ren ifyourwaterpip subs
	
	g idn=_n
	g wave=6
	destring pay, replace force
	order idn wave conn TYPE subs fee bill access alt_access  own issue pay neighbor    shroth gender yearofbirth hhsize inc dwelling
	keep idn wave conn TYPE subs fee bill access alt_access own issue pay neighbor    shroth gender yearofbirth hhsize inc dwelling
	
	save "${data}pollfish/w6_e.dta", replace
	
	
	
	
	use "${data}pollfish/w7.dta", clear
	
	g neighbor= regexm(ifyourwaterpip,"neighbor")==1
		
	ren howmuchdoesyourhouseholdspendeac pay 
	
	*tab howmuchdoesyourhouseholdspendeac  wheredoyouaccesswaterfromprimari
	*ren withoutawaterconnectionfrommayni alt
	*ren var24 alt_price
	
	ren whatisthemainissuewithwateracces issue
	
	ren whichbestdescribeshowyourhouseho conn1
	
	
		g conn=1 if regexm(conn1,"1")==1
		replace conn=2 if regexm(conn1,"2")==1
		replace conn=0 if regexm(conn1,"alone")==1
	
	
	g TYPE = conn
	replace TYPE = -1 if regexm(conn1,"does not")==1
		
		ren howdosharinghouseholdsaccessthec access1
		
		g access="single tap" if regexm(access1,"provides a single")==1
		replace access="connect pipes" if regexm(access1,"pipes/plumbing")==1
		replace access="fetch"  if regexm(access1,"fetch")==1
	
	ren whichbestdescribeshowtheinitialc fee1
	ren whichbestdescribeshowthewaterbil bill1

	g fee="all" if regexm(fee1,"all of the fee")==1
	replace fee="even" if regexm(fee1,"even")==1
	replace fee="some" if regexm(fee1,"some")==1
	
	g bill="usage" if regexm(bill1,"usage")==1
	replace bill="fixed" if regexm(bill1,"fixed")==1
	replace bill="split" if regexm(bill1,"split")==1
	
	*ren whatarethemainreasonsthewaterbil reason
	
	ren doesyourhouseholdownthewaterconn own
	
	ren wheredoyouaccesswaterfromprimari alt_access
		** ** ** DEMOGRAPHICS ** ** **
		drop income
	ren howmanypeopleliveinyourhousehold hhsize
	ren whatisyourtotalhouseholdincomeea inc
	ren whattypeofdwellingdoesyourhouseh dwelling
	ren howmanyotherpeopledoesyourhouseh shroth
	
	ren ifyourwaterpip subs
		
	g idn=_n
	g wave=7
	destring pay, replace force
	order idn wave conn TYPE subs fee bill access alt_access  own issue pay neighbor    shroth gender yearofbirth hhsize inc dwelling
	keep idn wave conn TYPE subs fee bill access   alt_access own issue pay neighbor    shroth gender yearofbirth hhsize inc dwelling
	
	save "${data}pollfish/w7_e.dta", replace
	
	
	
	***************************************************************************
	***************************************************************************
	***************************************************************************
	***************************************************************************
	
	
	
	use "${data}pollfish/w2_e.dta", clear
		append using "${data}pollfish/w3_e.dta"
		append using "${data}pollfish/w4_e.dta"
		append using "${data}pollfish/w5_e.dta"
		append using "${data}pollfish/w6_e.dta"
		append using "${data}pollfish/w7_e.dta"
		
	replace pay=. if pay<=1 | pay==99
	
	sum pay if conn==1 & own=="Yes"
	sum pay if conn==1 & own=="No"
	
	tab hhsize own  if conn==1
	
	tab inc own  if conn==1
	
	g II=substr(inc,1,2)
	replace II="50" if regexm(II,"O")==1
	replace II=subinstr(II,",","",.)
	destring II, replace force
	
	tab II if conn==1 & own=="Yes"
	tab II if conn==1 & own=="No"
	
	g HH = substr(hhsize,1,2)
	replace HH=subinstr(HH,"-","",.)	
	destring HH, replace force
	
	tab HH if conn==1 & own=="Yes"
	tab HH if conn==1 & own=="No"
	
	
	tab II if (conn==1 | conn==2) & own=="Yes"
	tab II if (conn==1 | conn==2) & own=="No"
	tab HH if (conn==1 | conn==2) & own=="Yes"
	tab HH if (conn==1 | conn==2) & own=="No"
	
	
	tab alt_access if regexm(alt_access,"District")!=1 & regexm(alt_access,"-")!=1
	
	tab alt_access if regexm(alt_access,"Well")==1 | regexm(alt_access,"Tanker")==1  | regexm(alt_access,"Water Refilling")==1
	
	
	
	
	
	

	
	use "${data}pollfish/w2_e.dta", clear
		append using "${data}pollfish/w3_e.dta"
		append using "${data}pollfish/w4_e.dta"
		append using "${data}pollfish/w5_e.dta"
		append using "${data}pollfish/w6_e.dta"
		append using "${data}pollfish/w7_e.dta"
	
	
	
	
		ren hhsize hhsize1
		
		g hh1_2 = regexm(hhsize1,"2" )==1
		g hh3_5 = regexm(hhsize1,"3" )==1
		g hh6_10 = regexm(hhsize1,"6" )==1
		g hh11 = regexm(hhsize1,"11")==1
		
		lab var hh1_2 "HHsize: 1-2"
		lab var hh3_5 "HHsize: 3-5"
		lab var hh6_10 "HHsize: 6-10"
		lab var hh11 "HHsize: $>$10"
		
		
		g age = 2017 - yearofbirth
		drop if age<18
		lab var age "Age"

		g fem = gender=="female"
		lab var gender "Female"
		
		g apartment = regexm(dwelling,"Apartment")==1
		g duplex    = regexm(dwelling,"Duplex")==1
		g house     = regexm(dwelling,"Single")==1
		
		lab var apartment "Apartment"
		lab var duplex "Duplex"
		lab var house "Single House"
		
			replace apartment = . if apartment==0 & duplex==0 & house==0
			replace duplex	  = . if apartment==. 
			replace house 	  = . if apartment==.
		
		replace shroth="" if TYPE<=0
			tab shroth
		
		g shh1_6 = regexm(shroth,"2")==1
			replace  shh1_6=. if shroth==""
		g shh7_10 = regexm(shroth,"7")==1
			replace  shh7_10 =. if shroth==""
		g shh11_15 = regexm(shroth,"11")==1
			replace  shh11_15=. if shroth==""
		g shh16 =  regexm(shroth,"16")==1
			replace  shh16=. if shroth==""
	
	
		lab var shh1_6 "Other Users: 1-6"
		lab var shh7_10 "Other Users: 7-10"
		lab var shh11_15 "Other Users: 11-15"
		lab var shh16 "Other Users: $>$15"

	g SHH=1 if TYPE==0
	replace SHH=2 if TYPE==1
	replace SHH=3 if TYPE==2
	
	lab var SHH "Water Source"
	lab define share_label 1 "Single User" 2 "Share with 1 HH" 3 "Share with 2 or more HHs"
	lab values SHH share_label
	
	g SHH1 = SHH==1
		lab var SHH1 "Single User"
	g SHH2 = SHH==2
		lab var SHH2 "Share with 1 HH"
	g SHH3 = SHH==3
		lab var SHH3 "Share with 2 or more HHs"
	
		
		
		keep wave hh1_2 hh3_5 hh6_10 hh11 age gender ///
				apartment duplex house ///
				shh1_6 shh7_10 shh11_15 shh16 SHH SHH1 SHH2 SHH3 TYPE
	g data="pollfish"				
	save "${temp}pollfish_stats_prep.dta", replace			
	
	
	
	
	
	****** PAWS CLEANING ********
	
	
	
	use "${data}paws/clean/full_sample.dta", clear
	
		*** PAWS CLEANING ***
		drop age
		destring age_extra, replace force ignore(+)
		ren age_extra age
		replace age=19 if age==198
		replace age=23 if age==230
		replace age=56 if age==564
		replace age=age*10 if age<=12
		replace age=100 if age>100 & age<.
		replace age=18 if age<18
	
			lab var age "Age"	
			** HOUSE
			ren house house1
		g house="single" if regexm(house1,"Single house")==1
			replace house="apartment" if regexm(house1,"Apartment :")==1
			replace house="duplex" if regexm(house1,"Duplex")==1
			replace house="other" if house==""
			
			ren house house2
		g apartment=house2=="apartment"
		g house=house2=="single"
		g duplex=apartment==0 & house==0
				lab var apartment "Apartment"
			lab var duplex "Duplex"
			lab var house "Single House"
		
			** HHSIZE
		destring shr_hh_extra shr_num_extra hhsize, replace force
		
			g SHO=shr_num_extra - hhsize
			replace SHO=. if SHO<0
			g SHH=shr_hh_extra
				destring may_exp_extra, replace force
				replace SHH=1 if wave==4 & SHH==.	

		
	* drop if wave==3
	
				drop if SHO==.
				replace SHO=0 if SHH==1
				replace SHH=1 if wave==3 & SHO==0
				replace SHH=2 if wave==3 & SHO>0 & SHO<=6
				replace SHH=3 if wave==3 & SHO>6 & SHO<.

				drop if SHH==3 & SHO<=2
				
				replace SHO=30 if SHO>30
				replace SHH=3 if SHH>3
	
	
	
		g shh1_6 = SHO>=1 & SHO<=6
			replace shh1_6=. if SHO==0
		g shh7_10 = SHO>=7 & SHO<=10
			replace shh7_10=. if SHO==0
		g shh11_15 = SHO>=11 & SHO<=15
			replace shh11_15=. if SHO==0
		g shh16 = SHO>=16 & SHO<.
			replace shh16=. if SHO==0
		
		lab var shh1_6 "Other Users: 1-6"
		lab var shh7_10 "Other Users: 7-10"
		lab var shh11_15 "Other Users: 11-15"
		lab var shh16 "Other Users: $>$15"
	
	
		lab var age "Age"
	
	
		g hh1_2 = hhsize>=1 & hhsize<=2
		g hh3_5 = hhsize>=3 & hhsize<=5
		g hh6_10 = hhsize>=6 & hhsize<=10
		g hh11 =  hhsize>=11
		
		lab var hh1_2 "HHsize: 1-2"
		lab var hh3_5 "HHsize: 3-5"
		lab var hh6_10 "HHsize: 6-10"
		lab var hh11 "HHsize: $>$10"
		
	lab var SHH "Water Source"
	lab define share_label 1 "Single User" 2 "Share with 1 HH" 3 "Share with 2 or more HHs"
	lab values SHH share_label
	
	g SHH1 = SHH==1
		lab var SHH1 "Single User"
	g SHH2 = SHH==2
		lab var SHH2 "Share with 1 HH"
	g SHH3 = SHH==3
		lab var SHH3 "Share with 2 or more HHs"
	

		keep wave hh1_2 hh3_5 hh6_10 hh11 age  ///
				apartment duplex house ///
				shh1_6 shh7_10 shh11_15 shh16 SHH SHH1 SHH2 SHH3
	g data="paws"				
	save "${temp}paws_pollfish.dta", replace				
			
			
			
	
	
	
		use "${temp}pollfish_stats_prep.dta", clear
			
			append using "${temp}paws_pollfish.dta"
		
		
		g apt_or_duplex=house==0
		replace apt_or_duplex=. if house==.
		lab var apt_or_duplex "Apartment/Duplex"
		
			bys SHH data: g N=_N
			label var N "Obs."
			
global varlist "age apt_or_duplex house hh1_2 hh3_5 hh6_10 hh11 shh1_6 shh7_10 shh11_15 shh16 N"


order $varlist

qui estpost sum $varlist if SHH==1 & data=="pollfish"
qui 	matrix meanf1_pollfish=e(mean)
qui 	matrix list meanf1_pollfish
	
qui estpost sum $varlist if SHH==1 & data=="paws"
qui 	matrix meanf1_paws=e(mean)
qui 	matrix list meanf1_paws
	
	
qui estpost sum $varlist if SHH==2 & data=="pollfish"
qui 	matrix meanf2_pollfish=e(mean)
qui 	matrix list meanf2_pollfish
	
	
qui estpost sum $varlist if SHH==2 & data=="paws"
qui 	matrix meanf2_paws=e(mean)
qui 	matrix list meanf2_paws
	
qui estpost sum $varlist if SHH==3 & data=="pollfish"
qui 	matrix meanf3_pollfish=e(mean)
qui 	matrix list meanf3_pollfish
	
qui estpost sum $varlist if SHH==3 & data=="paws"
qui 	matrix meanf3_paws=e(mean)
qui 	matrix list meanf3_paws	
	
qui 	estadd matrix meanf1_pollfish
qui 	estadd matrix meanf1_paws
qui 	estadd matrix meanf2_pollfish
qui 	estadd matrix meanf2_paws
qui 	estadd matrix meanf3_pollfish
qui 	estadd matrix meanf3_paws

	
	
	
file open myfile using "${output}pollfish_paws_diff.tex", write replace
file write myfile "\begin{tabular}{lcccccc}" _n
file write myfile "&\multicolumn{2}{c}{Single User} & \multicolumn{2}{c}{Share: 1 HH} & \multicolumn{2}{c}{Share: 2 or more HHs} \\" _n
file write myfile "\hline" _n
file write myfile "\hline" _n
file close myfile	
	
	esttab using "${output}pollfish_paws_diff.tex", noobs ///
	cells("meanf1_pollfish(fmt(%010.2fc)) meanf1_paws(fmt(%010.2fc)) meanf2_pollfish(fmt(%010.2fc)) meanf2_paws(fmt(%010.2fc)) meanf3_pollfish(fmt(%010.2fc)) meanf3_paws(fmt(%010.2fc)) ") ///
	collabels("Mobile"  "PAWS"  ///
	"Mobile"  "PAWS" ///
	"Mobile"  "PAWS" ) tex append label frag  mgroups(none) mlabels(none) eqlabels(none) nomtitles

	
file open myfile using "${output}pollfish_paws_diff.tex", write append
file write myfile "\end{tabular}" _n
file close myfile		
	



	
	
	

	
use "${temp}pollfish_stats_prep.dta", clear
	
	append using "${temp}paws_pollfish.dta"
		
		g apt_or_duplex=house==0
		replace apt_or_duplex=. if house==.
		lab var apt_or_duplex "Apartment/Duplex"
		
			bys data: g N=_N
			label var N "Obs."
		
		
		drop if wave==2 & data=="pollfish"

		
	g SHH1_paws=SHH1 if data=="paws"
	g SHH2_paws=SHH2 if data=="paws"
	g SHH3_paws=SHH3 if data=="paws"
	
	egen SHH1_sum=sum(SHH1_paws)	
	egen SHH2_sum=sum(SHH2_paws)
	replace SHH2_sum=SHH2_sum*2
	egen SHH3_sum=sum(SHH3_paws)
	replace SHH3_sum=SHH3_sum*3
	
	g total=SHH1_sum+SHH2_sum+SHH3_sum
	
	replace SHH1 = SHH1_sum/total if data=="paws"
	replace SHH2 = SHH2_sum/total if data=="paws"
	replace SHH3 = SHH3_sum/total if data=="paws"
	
global varlist "SHH1 SHH2 SHH3 N"


replace SHH1 = . if SHH1==0 & SHH2==0 & SHH3==0 & data=="pollfish"
replace SHH2 = . if SHH1==0 & SHH2==0 & SHH3==0 & data=="pollfish" 
replace SHH3 = . if SHH1==0 & SHH2==0 & SHH3==0 & data=="pollfish" 


order $varlist

	qui estpost sum $varlist if data=="pollfish"
		qui 	matrix meanf1_pollfish=e(mean)
		
	qui estpost sum $varlist if data=="paws"
		qui 	matrix meanf1_paws=e(mean)

	
qui 	estadd matrix meanf1_pollfish
qui 	estadd matrix meanf1_paws
	
file open myfile using "${output}pollfish_paws_means.tex", write replace
file write myfile "\begin{tabular}{lcc}" _n
file close myfile	
	
	esttab using "${output}pollfish_paws_means.tex", noobs ///
	cells("meanf1_pollfish(fmt(%010.2fc)) meanf1_paws(fmt(%010.2fc))") ///
	collabels("Mobile"  "PAWS"  ///
	 ) tex append label frag  mgroups(none) mlabels(none) eqlabels(none) nomtitles

	
file open myfile using "${output}pollfish_paws_means.tex", write append
file write myfile "\end{tabular}" _n
file close myfile		
	


	
		
	use "${data}pollfish/w2_e.dta", clear
		append using "${data}pollfish/w3_e.dta"
		append using "${data}pollfish/w4_e.dta"
		append using "${data}pollfish/w5_e.dta"
		append using "${data}pollfish/w6_e.dta"
		append using "${data}pollfish/w7_e.dta"

	
	g no_info=pay==. | pay==1 | pay==-1 | pay==99
	
	sum no_info, detail
		file open myfile using "${output}no_info.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
	
	g no_use=0 if use!=.
	replace no_use=1 if use==-1 | use==1 | use==99
	sum no_use, detail
		file open myfile using "${output}no_use.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile	
	
	
	
	
	tab bill if own=="Yes" & (conn==1 | conn==2) ///
		& own=="Yes" & (conn==1 | conn==2)
	
	g fixed = bill!="" & ///
		& own=="Yes" & (conn==1 | conn==2)
	replace fixed = 1 if bill=="fixed"
	
		sum fixed, detail
		file open myfile using "${output}bill_fixed.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
	
	
	g split = bill!="" & ///
		& own=="Yes" & (conn==1 | conn==2)
	replace split = 1 if bill=="split"
	
		sum split, detail
	
		file open myfile using "${output}bill_split.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
			
	g usage = bill!="" & ///
		& own=="Yes" & (conn==1 | conn==2)
	replace usage = 1 if bill=="usage"
	
	
		sum usage, detail
	
		file open myfile using "${output}bill_usage.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
	
	
	
	
	
	
	tab fee if own=="Yes" & (conn==1 | conn==2)
	
	g fee_even_some=1 if (fee=="even" | fee=="some") ///
		& own=="Yes" & (conn==1 | conn==2)
	replace fee_even_some=0 if fee=="all" ///
		& own=="Yes" & (conn==1 | conn==2)
	
	sum fee_even_some, detail
	
		file open myfile using "${output}fee_even_some.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
		
	
	tab access if  ///
		own=="Yes" & (conn==1 | conn==2)
	
	g connect_pipes = 1 if access=="connect pipes" & ///
		own=="Yes" & (conn==1 | conn==2)
	replace connect_pipes = 0 if (access=="fetch" | access=="single tap") & ///
		own=="Yes" & (conn==1 | conn==2)
	
	sum connect_pipes, detail
	file open myfile using "${output}access_pipes.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
	
		
	g fetch = 1 if access=="fetch" & ///
		own=="Yes" & (conn==1 | conn==2)
	replace fetch = 0 if (access=="connect pipes" | access=="single tap") & ///
		own=="Yes" & (conn==1 | conn==2)
			
	sum fetch, detail
		file open myfile using "${output}access_fetch.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
			
	
	g single_tap = 1 if access=="single tap" & ///
		own=="Yes" & (conn==1 | conn==2)
	replace single_tap = 0 if (access=="connect pipes" | access=="fetch") & ///
		own=="Yes" & (conn==1 | conn==2)
			
	sum single_tap, detail
		file open myfile using "${output}access_single_tap.tex", write replace
			file write myfile "`=round(r(mean)*100,1)'"
			file close myfile
			
					
		
		*/
		
		
		
		
		
		
		
		
		/*
		
		
	
	tab bill if own=="Yes" & (conn==1 | conn==2) ///
		& own=="Yes" & (conn==1 | conn==2)
	
	
	
	g bill_split=1 if bill=="fixed" | bill=="split"
	replace bill_split=0 if bill=="usage"
	
	sum bill_split if own=="Yes" & (conn==1 | conn==2)
	
	tab fee if own=="Yes"
	
	
	
	g ALT="Deep Well" if regexm(alt,"Deep Well")==1
	replace ALT="Tanker Truck" if regexm(alt,"Tanker Truck")==1
	replace ALT="WRS" if regexm(alt,"Water Refilling")==1
	
	**** ! CHECK OUT ALT ! ****
	
	replace alt_price=. if wave==2 & alt_price<=1
	replace alt_price=. if (wave==3 | wave==4) & alt_price==99
	
	replace alt_price=. if alt_price>100
	
	hist alt_price, discrete
	
	sum alt_price if ALT=="Deep Well" & wave>2
	sum alt_price if ALT=="Tanker Truck" & wave>2
	sum alt_price if ALT=="WRS" & wave>2
	
	hist alt_price if wave>2, discrete by(ALT)
	
	
	
	g conng=conn
	
	lab define conn_type 0 "1 HH" 1 "2 HHs" 2 "3 or more HHs"
	lab variable conng "Connection Type"
	lab values conng conn_type
		
		catplot conng if wave>2, vertical  title("Sharing Relationships")
			graph export "/Users/williamviolette/Google Drive/jmp/conn.png", as(png) replace
		
	
	
	g F = 1 if fee=="all"
	replace F = 2 if fee=="some"	
	replace F = 3 if fee=="even"

	lab define fee_type 1 "Owner pays all" 2 "Owner pays some" 3 "Split evenly"
	lab variable F "Connection Fee"
	lab values F fee_type
		
		catplot F, vertical  title("Splitting Connection Fee")
			graph export "/Users/williamviolette/Google Drive/jmp/fee.png", as(png) replace
		

	
	g B = 1 if bill=="usage"
	replace B = 2 if bill=="fixed"
	replace B = 3 if bill=="split"

	lab define bill_type 1 "Usage" 2 "Fixed Payment"  3 "Split Evenly"
	lab variable B "Bill"
	lab values B bill_type
			
		catplot B, vertical  title("Splitting Bill")
			graph export "/Users/williamviolette/Google Drive/jmp/bill.png", as(png) replace
		
	
	
	g A = 1 if access=="connect pipes"
	replace A = 2 if access=="single tap"
	replace A = 3 if access=="fetch"

	lab define access_type 1 "Connect Pipes" 2 "Single Tap"  3 "Fetch"
	lab variable A "Access"
	lab values A access_type
			
		catplot A, vertical  title("Method of Access")
			graph export "/Users/williamviolette/Google Drive/jmp/access.png", as(png) replace
		
	
	
	g R = 1 if regexm(reason,"measure")==1
	replace R = 2 if regexm(reason,"tariff")==1
	replace R = 3 if regexm(reason,"conserve")==1
	replace R = 4 if regexm(reason,"fairly")==1
	
	lab define reason_type 1 "Measure Consumption" 4 "Fairness" 2 "Follow Tariff" 3 "Conserve Water"
	lab variable R "Reason for dividing bill"
	lab values R reason_type
	
		catplot R, vertical  title("Reason for Dividing Bill")
			graph export "/Users/williamviolette/Google Drive/jmp/reason.png", as(png) replace
		
	
	
	g I = 1 if regexm(issue,"time")==1
	replace I = 2 if regexm(issue,"pressure")==1
	replace I = 3 if regexm(issue,"Negotia")==1
	replace I = 4 if regexm(issue,"maintenance")==1
	replace I = 5 if regexm(issue,"None")==1
	
	
	lab define issue_type 1 "Time Fetching" 2 "Low Pressure" 3 "Negotiating the Bill" 4 "Pipes Break" 5 "No Issue"
	lab variable I "Issues with Water"
	lab values I issue_type
	
	
		g S = conng
		replace S = 1 if S>1 & S<.
		lab define SHR_lab 0 "Single HH" 1 "Sharing HHs"
		lab values S SHR_lab
		
		catplot I, percent vertical by(S) title("Issues")  var1opts(label(angle(45))) 
			graph export "/Users/williamviolette/Google Drive/jmp/issues.png", as(png) replace
		
	
	*/
	
	
		
		
/*	
	use savings/temp/data_temp.dta, clear
		drop if alt==1
		duplicates drop conacct, force
	save savings/temp/data_temp_weight.dta, replace		
*/



*	use savings/temp/group_data_v1_5b.dta , clear
*		keep if g_id==conacct
*		duplicates drop conacct, force
		/*
	use  savings/temp/data_temp_weight.dta, clear
		*** keep track of weighting!! BY SHH!
		ren house_1 ho_1
		ren house_2 ho_2
		
		g SHH1=SHH==1
		g SHH2=SHH==2
		g SHH3=SHH==3
		
		g hhs1_2=hhsize>=1 & hhsize<=2
		g hhs3_5=hhsize>=3 & hhsize<=5
		g hhs6_10=hhsize>=6 & hhsize<=10
		g hhs11=hhsize>=11
		
		g hho1_6=SHO>=0 & SHO<=6
		g hho7_10=SHO>=7 & SHO<=10
		g hho11 = SHO>=11
		
		*egen minc=mean(INC)
		*replace INC=minc if INC==.
		
	*	g inc0_5=INC>=0 & INC<=5000
		
		///
		*	hhs1_2 hhs3_5 hhs6_10 hhs11 ///
		*	hho1_6 hho7_10 hho11 
			
		*	egen SHHS=sum(SHH)
			
		file open myfile using "test_w.txt", write replace
		
		foreach var of varlist SHH1 SHH2 SHH3 ho_1 ho_2 hhs3_5 hho7_10 {
		replace `var'=`var'*SHH
		egen `var'_s=sum(`var')
	*	replace `var'_s=`var'_s/SHHS
		qui sum `var'_s, detail
		file write myfile "`var'" _tab(1) "`=r(mean)'" _n
		}
	
		file close myfile
		*/
		
		
		
		
		
		
		/*
		
		************ HERE IS THE CRUCIAL NEIGHBOR VARIABLE!!! **********
		
		************ HERE IS THE CRUCIAL NEIGHBOR VARIABLE!!! **********
		
		************ HERE IS THE CRUCIAL NEIGHBOR VARIABLE!!! **********
		
		************ HERE IS THE CRUCIAL NEIGHBOR VARIABLE!!! **********
		
		************ HERE IS THE CRUCIAL NEIGHBOR VARIABLE!!! **********
		
	
	import delimited "/Users/williamviolette/Google Drive/jmp/sim_build/tables/leak_avg_consumption.tex", clear
		scalar define avg_cons=v1[1]
		
		
		
		
	use pollfish/w5.dta, clear
	ren whichbestdescribeshowyourhouseho conn
	g SHH = 1 if regexm(conn,"alone")==1
	replace SHH = 2 if regexm(conn,"1")==1
	replace SHH = 3 if regexm(conn,"2")==1	
	
	drop if SHH==.
	
	g SHH1=SHH==1
	g SHH2=SHH==2
	g SHH3=SHH==3
	
	g neighbor= regexm(ifyourwaterpip,"neighbor")==1
		
		sum neighbor, detail
		scalar define nshr=r(mean)
			file open myfile using "/Users/williamviolette/Google Drive/jmp/sim_build/tables/neighbor.tex", write replace
				file write myfile "`=round(r(mean)*100,1)'"
				file close myfile
				
		
		scalar define exp_offset=round(nshr*avg_cons,.01)			
			file open myfile using "/Users/williamviolette/Google Drive/jmp/sim_build/tables/neighbor_cons_offset.tex", write replace
				file write myfile "`=round(exp_offset,.01)'"
				file close myfile
				
	
	
	
	g ho_1 = regexm(whattypeofdwelling,"Apartment")==1
	g ho_2 = regexm(whattypeofdwelling,"Single")==1

	g hhs1_2=regexm(howmanypeople,"1")==1
	g hhs3_5=regexm(howmanypeople,"3")==1
	g hhs6_10=regexm(howmanypeople,"6")==1
	g hhs11 = regexm(howmanypeople,"11")==1
	
	g hho1_6 = regexm(howmanyother,"6")==1
	g hho7_10 = regexm(howmanyother,"7")==1
	g hho11 = regexm(howmanyother,"11")==1 | regexm(howmanyother,"16")==1
	
	g inc0_5 = regexm(whatisyourtotal,"5,000")==1
	g inc5_15 =  regexm(whatisyourtotal,"15,000")==1
	g inc15_30 =  regexm(whatisyourtotal,"30,000")==1
	g inc30_50 =  regexm(whatisyourtotal,"50,000")==1
	g inc50 =  regexm(whatisyourtotal,"50,001")==1
	
	order neighbor SHH1 SHH2 SHH3 ho_1 ho_2 ///
			hhs1_2 hhs3_5 hhs6_10 hhs11 ///
			hho1_6 hho7_10 hho11 
			
			*inc0_5 inc5_15 inc15_30 inc50
			
	keep neighbor SHH1 SHH2 SHH3 ho_1 ho_2 ///
			hhs1_2 hhs3_5 hhs6_10 hhs11 ///
			hho1_6 hho7_10 hho11 
			
			*inc0_5 inc5_15 inc15_30 inc50
	
	reweight2 using "test_w.txt", newweight(W)
	
	sum W, detail
	
	replace W=W/`=r(mean)'
	
	g neighborm=neighbor*W
	sum neighborm, detail
	
	*/
	
	
	
	
	
	
	

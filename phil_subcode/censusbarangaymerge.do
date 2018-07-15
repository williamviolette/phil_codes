
* censusbarangaymerge

* input : TABLE barangay, "${censusgeodata}psgc.dta", "${censusgeodata}psgc_region_IV.dta"
* output : TABLE censusbar


odbc load, exec("SELECT OGC_FID, prikey, brgy, municipali FROM barangay") clear

	ren brgy name
	ren municipali city
	
	sort prikey
	replace city=city[_n-1] if city==""
	
	replace name=lower(name)
	replace name=subinstr(name,".","",.)
*	replace name=subinstr(name,"village","",.)
	replace name=regexs(1) if regexm(name,"([0-9]+)-a")
	replace name=regexs(1) if regexm(name,"([0-9]+)a")

	replace name=subinstr(name,"st ","saint",.)	
	replace name=subinstr(name,"sta","santa",.)
	replace name=subinstr(name,"sto","santo",.)
	replace name=subinstr(name,"ñ","n",.)	
	replace name=subinstr(name,"(pob)","pob",.)
	replace name=subinstr(name,"alabang 1","alabang",.)
	replace name=subinstr(name,"daang hari","daanghari",.)
	replace name=subinstr(name,"north bay blvd, north","north bay",.)
	replace name=subinstr(name,"bf homes","b f homes",.)
	replace name=subinstr(name,"?","n",.)
	replace name=subinstr(name,"greater fairview","fairview",.)
	replace name=subinstr(name,"greater lagro 5","greater lagro",.)

	replace name=subinstr(name," (pasong putik)","",.)

	g calo=regexm(city,"TONDO")==1
	replace name=regexs(1) if regexm(name,"([0-9]+)") & calo==1
	drop calo	
	g calo=regexm(city,"CALO")==1
	replace name=regexs(1) if regexm(name,"([0-9]+)") & calo==1
	drop calo
	
	replace name=regexr(name," i$"," 1")
	replace name=regexr(name," ii$"," 2")
	replace name=regexr(name," iii$"," 3")
	replace name=regexr(name," iv$"," 4")
	replace name=regexr(name," v$"," 5")
	replace name=regexr(name," vi$"," 6")
	replace name=regexr(name," vii$"," 7")
	replace name=regexr(name," viii$"," 8")
	replace name=regexr(name," v$"," 5")
	replace name="saint peter" if regexm(name,"peter")==1
	
	replace name="san rafael 2" if regexm(name,"san rafel")==1
	replace name="taclong" if regexm(name,"clong")==1
	replace name=strtrim(name)
	
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY","",.)
	replace city=subinstr(city,"I / II","",.)
	replace city=subinstr(city,", MANILA","",.)
	replace city="SANTA CRUZ" if city=="STA CRUZ"
	replace city="PARA" if regexm(city,"PARA")==1
	replace city="LAS PINAS" if regexm(city,"LAS PI")==1
	replace city=strtrim(city)
	replace name=subinstr(name," ("," ",.) if city=="CAVITE"
	replace name=subinstr(name,"("," ",.) if city=="CAVITE"
	replace name=subinstr(name,")","",.) if city=="CAVITE"
	duplicates drop city name, force

save "${temp}barangay_TO_psgc_1.dta", replace



use "${censusgeodata}psgc.dta", clear
	append using "${censusgeodata}psgc_region_IV.dta"
	* cleaning
	drop city
	g city=name if ruralurban==""
	replace city=city[_n-1] if city[_n]=="" & city[_n-1]!=""
	
	g r=substr(id_st,1,4)
	g r1=substr(r,1,3)
	keep if r=="1339" | r=="1375" | r=="1374" | r=="1376" | r1=="421"

	drop if ruralurban==""
*	drop if regprovmunbgy>140000000
	replace name=lower(name)	
	replace name=subinstr(name,"barangay ","",.)
	replace name=subinstr(name,".","",.)
	replace name=strtrim(name)
	
	
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY OF","",.)
	replace city=subinstr(city,"CITY","",.)
	replace city=subinstr(city,"I / II","",.)
	replace city=subinstr(city,", MANILA","",.)
	replace city="SANTA CRUZ" if city=="STA CRUZ"
	replace city="PARA" if regexm(city,"PARA")==1
	replace city="LAS PINAS" if regexm(city,"LAS PI")==1
	replace city=strtrim(city)
	replace city="MALABON" if regexm(name,"navotas east")==1
	replace city="PASAY" if regexm(name,"729")==1
	replace city="PARA" if regexm(name,"fajardo")==1
	replace city="NAVOTAS" if regexm(name,"niugan")==1
	
	replace name="664" if regexm(name,"664-a")==1
	replace name="cupang 1" if regexm(name,"cupang")==1
	replace name="alabang 3" if regexm(name,"new alabang")==1
	replace name="alabang 2" if regexm(name,"alabang")==1
	
	replace name="pilar village" if regexm(name,"pilar")==1 & regexm(city,"PINAS")==1
	replace name="bf international village" if regexm(name,"international village")==1
	replace name="north bay" if regexm(name,"north bay blvd, north")==1
	replace name="marcelo green" if regexm(name,"marcelo green")==1
	replace name="veterans" if regexm(name,"veterans")==1
	replace name="pasong putik proper" if regexm(name,"pasong putik proper")==1
	replace name="ns amoranto" if regexm(name,"ns amoranto")==1
	replace name="santo domingo" if regexm(name,"santo domingo")==1
	replace name="dona aurora" if regexm(name,"aurora")==1
	replace name="novaliches" if regexm(name,"novaliches")==1
	replace name="a samson" if regexm(name,"samson")==1
	
	replace name=subinstr(name,"kuatro","cuatro",.)
	replace name=subinstr(name,"(pob)","pob",.)
	replace name=subinstr(name,"ñ","n",.)	
	replace name=subinstr(name,"pilar village","pilar",.)	
	
	replace name=regexr(name," i$"," 1")
	replace name=regexr(name," ii$"," 2")
	replace name=regexr(name," iii$"," 3")
	replace name=regexr(name," iv$"," 4")
	replace name=regexr(name," v$"," 5")
	replace name=regexr(name," vi$"," 6")
	replace name=regexr(name," vii$"," 7")
	replace name=regexr(name," viii$"," 8")
	replace name=regexr(name," ix$"," 9")

	replace name=regexr(name," pob$","") if city=="IMUS"
	
	replace name="taclong" if regexm(name,"clong")==1
	replace name="anabu g" if regexm(name,"anabu i-g")==1
	
	
	replace name=regexr(name,"^[0-9]* ","") if city=="CAVITE"
	replace name=regexr(name,"^[0-9]*-[a-z] ","") if city=="CAVITE"
	replace name=subinstr(name,"(","",.) if city=="CAVITE"
	replace name=subinstr(name,")","",.) if city=="CAVITE"
	
	duplicates drop city name, force
	
		merge 1:1 city name using "${temp}barangay_TO_psgc_1.dta", keep(3) nogen
		sort city name // merge looks good (just a few weird ones don't merge)
	
		** VERY DECENT MERGE!! **
		
	g id=string(reg,"%20.0g")
	replace id="0"+id if length(id)==8

	g barangay_id = substr(id,-7,.)	
	destring barangay_id, replace force
	
	keep OGC_FID barangay_id
	duplicates drop OGC_FID, force // 0 drops :)
	duplicates drop barangay_id, force // 0 drops :)


	odbc exec("DROP TABLE IF EXISTS censusbar;"), dsn("phil")
	odbc insert, table("censusbar") dsn("phil") create
	odbc exec("CREATE INDEX censusbar_barangay_id ON censusbar (barangay_id);"), dsn("phil")
	odbc exec("CREATE INDEX censusbar_OGC_FID_id ON censusbar (OGC_FID);"), dsn("phil")





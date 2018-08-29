
	** global : generated, subcode
	** input  : TABLE bmatch, bstats, LN_total, pawsstats, price, alt_sub
	** output : CSV {generate} post.csv, post_t.csv, g.csv  TABLE leaks


local version "v1"
* local version "v2"


global min_dist = "yes"  // use min dist for all group members (instead of actual distance for main member)

global c_min_leak = "0"
global c_max_leak = "100"

if "`version'"=="v2" {
	global c_max_leak = "120"
}


cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end


#delimit;
odbc load, dsn(phil) 
exec("SELECT C.*, U.alt_sub, 
G.p_L, G.p_H1, G.p_H2, G.p_H3, 
B.house_avg AS house_census, 
P.barangay_id, P.SHH, P.SHO, P.house_1, P.house_2, P.age, P.hhemp, P.hhsize, P.low_skill 
	FROM bmatch AS A 
		LEFT JOIN bstats AS B ON A.OGC_FID = B.OGC_FID 
			 JOIN LN_total AS C ON A.conacct = C.conacct 
			 JOIN pawsstats AS P ON A.conacct = P.conacct 	
			 JOIN price AS G ON C.date = G.date AND C.class = G.class 
			 JOIN alt_sub AS U ON P.barangay_id = U.barangay_id") clear ;
#delimit cr;


	keep if class==1 | class==2
	drop if date<date_c
	drop date_c

	drop if c>${c_max_leak} | c<${c_min_leak} // this is an important parameter right here...
	
	keep if distance<5
	keep if rank<=4

	g T = date - date_l
	g TREAT = conacct==conacct_leak

	g g_id = conacct_leak

******** OLD CRITERIA

			drop if T>0 & TREAT==1
			
			keep if ( T>=-24 & T<=16 & TREAT==0 ) | ( T>=-24 & T<0 & TREAT==1 )   // KEEP WIDER GROUP!

			drop if c==.
			
			g TP=T<0          //   KEEP ONLY TREATED WITH PREPERIODS
				egen mt=sum(TP), by(conacct) // total pre
				g mt_g=mt if distance==-1 
				egen mt_G=min(mt_g), by(g_id) // smallest preperiod by group
				drop if mt_G<=1 // gets rid of groups without pre-periods 
				drop if mt<2 // gets rid of neighbors with no pre-periods
				drop mt mt_G mt_g TP	

			g TA=T>=1 & T<.   //   KEEP ONLY THOSE WITH POST PERIODS!
				egen ma=sum(TA), by(conacct)
				egen MAM=mean(ma), by(g_id)
				sum MAM, detail
				drop if MAM<=`=r(p1)'
				drop if ma<2 & distance!=-1 
				*  drop anybody with less than 2 post periods
				drop ma TA 					
			egen mean_c=mean(c), by(conacct)
			replace mean_c=. if distance!=-1
			egen mgc=max(mean_c), by(g_id)
			sum mgc, detail
		*	keep if mgc<=`=r(p95)' & mgc>=`=r(p5)' // * sum mgc, detail // drop percentiles instead?
			drop mean_c mgc 
				sort conacct date // KEEP ONLY LARGE GROUPS
				by conacct: g cc_n=_n
				g cc_n_id=cc_n==1
				egen g1=sum(cc_n_id), by(g_id)								
					drop if g1<2  							
					drop cc_n_id cc_n g1
			
		***** SORT AND GEN
			sort conacct date
			by conacct: g cc_n=_n==1
			sort g_id TREAT conacct date // make sure the order is right!
		***** GENERATE G SIZE
			egen g=sum(cc_n), by(g_id)
		***** GAMMA **********************
			g gamma=1/(g-1) // create gamma
		***** FIX SID
				g SID=T>1
		***** DOUBLE-CHECK TREATMENT
			egen TM=max(TREAT), by(g_id) // MAKE SURE THERE IS A TREATMENT IN THE GROUP!!
			drop if TM==0
			drop TM

*** GEN CONTROLS 
	
	do "${subcode}size_SHH_INC_function.do"
	do "${subcode}generate_controls.do" 

sort g_id conacct date

if "$min_dist" == "yes" {
	g DIST = distance if distance>0 & distance<.
	egen min_dist = min(DIST), by(g_id)   // use minimum distance instead
	drop distance DIST
	ren min_dist distance
}

*** PRE DATA ***
preserve
	** PRE : FULL DATA
		keep if T<1
		order c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS*	
		keep  c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS*	
		export delimited "${generated}pre_`version'.csv", delimiter(",") replace
restore

preserve
	** PRE : TIME
		keep if T<1
		keep conacct
		g o = 1
		egen t = sum(o), by(conacct)
		duplicates drop conacct, force
		keep t
		*tab t
		export delimited "${generated}pre_t_`version'.csv", delimiter(",") replace	
restore


*** POST DATA ***
preserve
	** POST : FULL DATA
		keep if T>=1
		order c p_L p_H1 p_H2 p_H3 gamma alt_sub size SHH_G CONTROLS* house_census distance
		keep  c p_L p_H1 p_H2 p_H3 gamma alt_sub size SHH_G CONTROLS* house_census distance
		export delimited "${generated}post_`version'.csv", delimiter(",") replace	
restore

preserve
	** POST : TIME 
		keep if T>=1
		keep conacct
		g o = 1
		egen t = sum(o), by(conacct)
		duplicates drop conacct, force
		keep t
		*tab t
		export delimited "${generated}post_t_`version'.csv", delimiter(",") replace			
restore

*** G ***
preserve
		duplicates drop g_id, force
		keep g
		tab g
		export delimited "${generated}g_`version'.csv", delimiter(",") replace
restore

*** export graph table ***
preserve 
	keep conacct date c class distance rank conacct_leak house_census T
	gentable leaks
restore







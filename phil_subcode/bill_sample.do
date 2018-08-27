

** pull full sample for billing

	** global : generated, temp, subcode
	** input  : TABLE paws, conacctseri, price, leakneighbors, census billing_ALL, DO generate_controls.do
	** temp   : TABLE bill_sample_temp, pop_c, DTA {temp} price_avg.dta
	** output : CSV {generated} standard.csv, standard_t.csv, alt.csv


global bill_sample_upper = "6000"
global bill_sample_total = "5000"
global b_mult = "5"
global sample_per_upper = "`=$bill_sample_upper / $b_mult'"

global c_low     = "0"
global c_high    = "120"
global date_low  = "600"
global date_high = "664"
global t_min     = "10"

global sample_by_barangay_1_ = "no"
global compile_full_sample_2_ = "yes"
global compile_alt_3_ = "yes"

*********************************
****** PREPARING DATA HERE ******
*********************************


if "$sample_by_barangay_1_" == "yes" {

cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end


local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"

#delimit;
odbc load, exec("
SELECT A.* 
	FROM `paws_data_selection' AS A
	JOIN conacctseri AS B 
		 ON A.conacct = B.conacct
	LEFT JOIN leakneighbors AS C 
		ON A.conacct = C.conacct 
WHERE B.conacct>0 AND C.conacct IS NULL  ")  dsn("phil") 	clear;
#delimit cr;


	set seed 10
	g B = runiform()
	sort B
	g B_id = _n<=$sample_per_upper          // creates some excess sample
	egen B_sum = sum(B_id), by(barangay_id)
	keep if B_sum>0 						// keep only if first sample goes through
	replace B_sum = B_sum * $b_mult 		// scale to at least 5

	g R = runiform()
	sort barangay_id R
	by barangay_id: drop if _N < B_sum 		// drops only a very few
	by barangay_id: keep if _n<= B_sum

	drop R B B_id B_sum

gentable bill_sample_temp


}


*****************************************
****** EXPORTING BILLING DATA HERE ******
*****************************************

if "$compile_full_sample_2_" == "yes" { 

local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"
* replaces bill_sample_temp

#delimit;
local bill_query "";

forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.date, A.c, A.class, A.read, B.*, 
	C.p_L, C.p_H1, C.p_H2, C.p_H3
	FROM billing_`r' AS A 
	JOIN bill_sample_temp AS B 
		ON A.conacct = B.conacct
	JOIN price AS C
		ON A.date = C.date AND A.class = C.class
	WHERE A.class==1 OR A.class==2
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear
	duplicates drop conacct date, force

*** trim sample 
	keep if c>=$c_low & c<=$c_high   
	keep if date>=$date_low & date<=$date_high  
	bys conacct: g T=_N   	
	drop if T<=${t_min}        

*** minimum number of accounts per barangay ...  could be improved
	set seed 10
	sort conacct date
	bys conacct: g cn=_n
	g c1=cn==1
	egen BN=sum(c1), by(barangay_id)
	drop if BN<$b_mult  				// drop barangays with too few obs

	g Ri = runiform()
	g R_id = Ri if cn==1
	egen R = max(R_id), by(conacct) 	// R : account-level, random identifier

	sort barangay_id cn R
	by barangay_id: g nn=_n
	g nn_id = nn<=$b_mult & cn==1
	egen NN = max(nn_id), by(conacct)
	replace R = 0 if NN==1 				// make sure to keep a minimum of number per barangay

	sort cn R
	g G_id = _n if _n<=$bill_sample_total
	egen G = max(G_id), by(conacct)

	keep if G<=$bill_sample_total 		// ensure we meet the sample threshold

	drop G G_id R NN nn_id R_id Ri BN c1

*** last fixing here 
	g size = (hhsize+SHO)/SHH 
	g SHH_G=1 if SHH<1.5 
		replace SHH_G=2 if SHH>=1.5 & SHH<2.5 
		replace SHH_G=3 if SHH>=2.5 & SHH<. 
	g INC = 10000

	do "${subcode}generate_controls.do" 

** FULL DATA EXPORT
	preserve 
		keep  c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS* hhsize SHO 
		order c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS* hhsize SHO 
		export delimited "${generated}standard_v2.csv", delimiter(",") replace 
	restore 

** TIME EXPORT
	preserve 
		duplicates drop conacct , force 
		keep T 
		export delimited "${generated}standard_t_v2.csv", delimiter(",") replace 
	restore 

** EXPORT HHs PER BARANGAY  (to sample alt)
	preserve 
		duplicates drop conacct, force 
		ren CONTROLS_barangay_id barangay_id 
		egen pop_c = sum(SHH), by(barangay_id) 
		duplicates drop barangay_id, force 
		keep pop_c barangay_id 
		odbc exec("DROP TABLE IF EXISTS pop_c;"), dsn("phil") 
		odbc insert, table("pop_c") dsn("phil") create 
		odbc exec("CREATE INDEX pop_c_barangay ON pop_c (barangay_id);"), dsn("phil") 
	restore 

}


*****************************************
****** EXPORTING BILLING DATA HERE ******
*****************************************

if "$compile_alt_3_" == "yes" {

*** get average prices temporarily
	odbc load, exec("SELECT AVG(p_L) AS p_L, AVG(p_H1) AS p_H1, AVG(p_H2) AS p_H2, AVG(p_H3) AS p_H3 FROM price WHERE class==1") dsn("phil") clear
	save "${temp}price_avg.dta", replace

*** load data
	odbc load, exec("SELECT A.*, B.pop_c FROM census AS A JOIN pop_c AS B ON A.barangay_id = B.barangay_id") dsn("phil") clear

*** sampling procedure
	egen alt_shr = mean(alt), by(barangay_id)

	g TOT = (pop_c*alt_shr)/(1-alt_shr) 	// total alt given pop_c and share using alt
	g TOT_st = string(TOT,"%10.0f")
	destring TOT_st, force replace
	set seed 10
	g R = runiform()
	g extra = R<=(TOT-TOT_st) 				// random draw of remaining alternative (sampling procedure)
	g alt_tot = TOT_st + extra 				// integer amount of alt sampled from each barangay

	keep if alt==1
	g RI = runiform()
	sort barangay_id RI
	by barangay_id: g RI_n=_n

	keep if RI_n <=alt_tot

*** add in average prices
	append using "${temp}price_avg.dta"
	foreach v in p_L p_H1 p_H2 p_H3 {
		replace `v' = `v'[_N]
	}
	drop if barangay_id==.

*** generate controls
 	g SHO = 0
 	g SHH = 1

	g size = (hhsize+SHO)/SHH 
		
	g SHH_G=1 if SHH<1.5 
	replace SHH_G=2 if SHH>=1.5 & SHH<2.5 
	replace SHH_G=3 if SHH>=2.5 & SHH<. 
	g INC = 10000

	do "${subcode}generate_controls.do"

preserve
	keep  c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS* 
	order c p_L p_H1 p_H2 p_H3 size SHH_G CONTROLS*
	export delimited "${generated}alt_v2.csv", delimiter(",") replace
restore

}







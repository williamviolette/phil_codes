


local paws_data_selection "(SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID)"
local census_data_selection "(SELECT barangay_id, AVG(alt) AS alt_shr FROM census GROUP BY barangay_id)"


odbc load, exec("SELECT A.*, B.alt_shr FROM `paws_data_selection' AS A JOIN `census_data_selection' AS B ON A.barangay_id = B.barangay_id") dsn("phil") clear

ren alt_shr alt_shr1
	egen alt_shr=mean(alt_shr1), by(barangay_id)
	
	g o=SHH
	egen os=sum(SHH), by(barangay_id)
	
	g AA = ( alt_shr/(1-alt_shr) )*(os)	
	g share_tot_id=SHH-1
	egen share_tot=sum(share_tot_id), by(barangay_id)
	 		g shr_shr= share_tot/(AA+os)
			g alt_sub=shr_shr/(shr_shr+alt_shr) 		// NOTE: THERE ARE A FAIR AMOUNT OF ALT_SUB MISSING!
														// HOW TO DEAL?! need to expand the areas...
			
duplicates drop barangay_id, force
keep barangay_id alt_sub

odbc exec("DROP TABLE IF EXISTS alt_sub;"), dsn("phil")
odbc insert, table("alt_sub") dsn("phil") create
odbc exec("CREATE INDEX alt_sub_barangay ON alt_sub (barangay_id);"), dsn("phil")

clear

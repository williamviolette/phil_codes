

* generate paws statistics for all of the conaccts

* programs

cap program drop gentable
program define gentable
	odbc exec("DROP TABLE IF EXISTS `1';"), dsn("phil")
	odbc insert, table("`1'") dsn("phil") create
	odbc exec("CREATE INDEX `1'_conacct_ind ON `1' (conacct);"), dsn("phil")
end

* 1) get barangay means

local pvs "$paws_vars"
local pv : list sizeof pvs

global vtempavg=""
scalar define vs=0

foreach v in $paws_vars {
	scalar define vs=vs+1
	if `=vs'<`=`pv''{
		global vtempavg = "$vtempavg AVG(`v') AS `v'_avg,"
	}
	else {
		global vtempavg = "$vtempavg AVG(`v') AS `v'_avg"
	}
}

global vtemp=""
scalar define vs=0

foreach v in $paws_vars {
	scalar define vs=vs+1
	if `=vs'<`=`pv''{
		global vtemp = "$vtemp B.`v',"
	}
	else {
		global vtemp = "$vtemp B.`v'"
	}
}


odbc load, exec("SELECT barangay_id, $vtempavg FROM paws AS P GROUP BY P.barangay_id") clear
save "${temp}paws_barangay.dta", replace



odbc load, exec("SELECT A.conacct, A.conacctp, A.distance, B.barangay_id, $vtemp FROM pneighbor AS A JOIN (SELECT * FROM paws GROUP BY conacct HAVING MIN(ROWID) ORDER BY ROWID) AS B ON A.conacctp = B.conacct") clear
merge m:1 barangay_id using "${temp}paws_barangay.dta", nogen keep(3)





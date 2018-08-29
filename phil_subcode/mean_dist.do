
	** input: TABLE neighbor , bmatch , bstats    ** output: TABLE mean_dist

odbc load, dsn(phil) exec("SELECT AVG(N.distance) AS mean_dist, C.barangay_id FROM (SELECT A.* FROM neighbor AS A WHERE A.rank==1) AS N JOIN bmatch AS B ON N.conacct = B.conacct JOIN bstats AS C ON B.OGC_FID = C.OGC_FID GROUP BY C.barangay_id") clear

replace mean_dist = 50 if mean_dist>50

odbc exec("DROP TABLE IF EXISTS mean_dist;"), dsn("phil")
odbc insert, table("mean_dist") dsn("phil") create
odbc exec("CREATE INDEX mean_dist_barangay_ind ON mean_dist (barangay_id);"), dsn("phil")




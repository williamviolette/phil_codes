



from sklearn.neighbors import NearestNeighbors
from pysqlite2 import dbapi2 as sql
import os, subprocess, shutil, multiprocessing, re, glob
from functools import partial
from itertools import product
import numpy  as np
import pandas as pd
#from phil_subcode.spatial2sql import add_meter


# action plan :
# - billing
# - complaints 
# 	- find better metrics? 
# 	- leave the same? 
# 	- think more carefully? 
# - heterogeneity in hassle costs



#################
# ENV SETTINGS  # 
#################

analysis = os.getcwd()[:os.getcwd().rfind('phil_code')]
code = analysis + 'phil_code/'

phil_folder = '/Users/williamviolette/Documents/Philippines/'
database = phil_folder + 'database/'
data = phil_folder + 'data/'

gis_folder = data + 'gis/'
generated = analysis + 'phil_generated/'
db = generated+'phil.db'




_1_ab_IMPORT_NEW 		= 0
_1_b_NEIGHBORS     		= 0
_1_c_EXPORT_STATA  		= 0
_1_d_PAWNEAR   	   		= 0   ## NEED TO IMPORT PAWS FIRST BEFORE RUNNING PAWNEAR
_1_e_NEARPAW   	   		= 0
_1_f_NEARRATECHANGE     = 0


_2_a_AREASTATS		    = 0   ## NEEDS FULL EXPORT STATA




_1_a_IMPORT 	   		= 0

## JUST A FUNCTION THAT WE USE A LOT ##

def runsubcode(dofile):
	dofile = code+"phil_subcode/"+dofile
	cmd = ['stata-mp','do',dofile]
	subprocess.call(cmd)
	return 0


###### STEP 1 : SET UP DATABASE ######



if _1_a_IMPORT == 1:  # import GIS DATA
	
	print '\n', " Import GIS data into database ! ", '\n'
	def osremove():
		if os.path.exists(db):
			os.remove(db)
		return 0

	def add_meter(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -dsco SPATIALITE=YES','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'METER.shp','-nlt POINT','-nln meter', '-overwrite']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_barangay(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'BARANGAY.shp','-nln barangay', '-overwrite']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def improve_meter_accounts():
		runsubcode('improve_meter_accounts.do')
		return 0

	osremove()
	add_meter(gis_folder,db)
	add_barangay(gis_folder,db)
	improve_meter_accounts()

	print '\n', " Done ! ", '\n'


if _1_ab_IMPORT_NEW == 1:

	print 'start'
	# def add_mru(gis_folder,db):
	# 	cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
	# 	db, gis_folder+'MRU.shp','-nln mru', '-overwrite -skipfailures']
	# 	subprocess.call(' '.join(cmd),shell=True)
	# 	return 0

	# def add_dma(gis_folder,db):
	# 	cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
	# 	db, gis_folder+'DMA_BOUNDARY.shp','-nln dma', '-overwrite -skipfailures']
	# 	subprocess.call(' '.join(cmd),shell=True)
	# 	return 0

	# add_mru(gis_folder,db)
	# add_dma(gis_folder,db)


	def int_mru_dma(db):

		print 'start this'
		name = 'mru_dma_int'

	    # connect to DB
		con = sql.connect(db)
		con.enable_load_extension(True)
		con.execute("SELECT load_extension('mod_spatialite');")
		cur = con.cursor()

	    # chec_qry = '''
	    #            SELECT type,name from SQLite_Master
	    #            WHERE type="table" AND name ="{}";
	    #            '''.format(name)

	    # drop_qry = '''
	    #            SELECT DisableSpatialIndex('{}','GEOMETRY');
	    #            SELECT DiscardGeometryColumn('{}','GEOMETRY');
	    #            DROP TABLE IF EXISTS idx_{}_GEOMETRY;
	    #            DROP TABLE IF EXISTS {};
	    #            '''.format(name,name,name,name)

	    # cur.execute(chec_qry)
	    # result = cur.fetchall()
	    # if result:
	    #     cur.executescript(drop_qry)
		cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

		print 'running ... '

		make_qry = '''
	                   CREATE TABLE {} AS 
                		SELECT A.OGC_FID as ogc_fid_mru,
                		A.mru_no as mru,
                		G.OGC_FID as ogc_fid_dma,
                		G.dma_id, 
                        st_area(st_intersection(ST_MAKEVALID(A.GEOMETRY),ST_MAKEVALID(G.GEOMETRY))) AS area
                FROM mru as A, dma as G
                WHERE A.ROWID IN (SELECT ROWID FROM SpatialIndex 
                WHERE f_table_name='mru' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
                AND st_intersects(ST_MAKEVALID(A.GEOMETRY),ST_MAKEVALID(G.GEOMETRY))
	                    ;
			              '''.format(name)
		cur.execute(make_qry)
	    
	    # cur.execute("SELECT RecoverGeometryColumn('{}','GEOMETRY',2046,'MULTIPOLYGON','XY');".format(name))
	    # cur.execute("SELECT CreateSpatialIndex('{}','GEOMETRY');".format(name))

		return

	# int_mru_dma(db)




###### STEP 1 b : COMPUTE TABLE OF NEAREST NEIGHBORS ######

if _1_b_NEIGHBORS == 1:

	print '\n', " Compute Nearest Neighbors Table ! ", '\n'

	num_neighbors = 11 # set the number of neighbors

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	qry = '''
   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat = np.array(cur.fetchall())

	def dist_calc(in_mat,targ_mat):

	    nbrs = NearestNeighbors(n_neighbors=num_neighbors, algorithm='auto').fit(targ_mat)
	    dist, ind = nbrs.kneighbors(in_mat)

	    return [dist,ind]

	res=dist_calc(mat[:,:2], mat[:,:2])

	cur.execute('DROP TABLE IF EXISTS neighbor;')
	cur.execute(''' CREATE TABLE neighbor (
	                conacct     INTEGER,
	                conacctn    INTEGER, 
	                rank    	INTEGER, 
	                distance    numeric(10,10) );''')

	rowsqry = '''INSERT INTO neighbor VALUES (?,?,?,?);'''

	for i in range(0,len(mat)):
		for j in range(1,num_neighbors):
			cur.execute(rowsqry, [mat[i][2],mat[res[1][i][j]][2],j,res[0][i][j]])		

	cur.execute('''CREATE INDEX neighbor_conacct_ind ON neighbor (conacct);''')
	cur.execute('''CREATE INDEX neighbor_conacctn_ind ON neighbor (conacctn);''')

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'



###### STEP 1 c : EXPORT FULL STATA RAW DATA TO DB!

if _1_c_EXPORT_STATA == 1:
	
	print '\n', " Started up the old export (takes a while) ", '\n'

	runsubcode('export_stata.do')

	print '\n', " we made it! :) ", '\n'


###### STEP 1 d : COMPUTE TABLE OF NEAREST PAWS NEIGHBORS FOR MERGING TO LEAK DATA ###### NEED TO IMPORT PAWS FIRST!! 

if _1_d_PAWNEAR == 1:

	print '\n', " Compute Nearest PAWS Table ! ", '\n'

	tablename = 'pneighbor'

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	qry = '''
   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat = np.array(cur.fetchall())
	
	qry = '''
        SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            JOIN (SELECT conacct FROM paws GROUP BY conacct) AS p ON B.conacct = p.conacct
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat_paws = np.array(cur.fetchall())

	def dist_calc(in_mat,targ_mat):

	    nbrs = NearestNeighbors(n_neighbors=1, algorithm='auto').fit(targ_mat)
	    dist, ind = nbrs.kneighbors(in_mat)

	    return [dist,ind]

	res=dist_calc(mat[:,:2], mat_paws[:,:2])

	cur.execute('DROP TABLE IF EXISTS {};'.format(tablename))
	cur.execute(''' CREATE TABLE {} (
	                conacct     INTEGER,
	                conacctp    INTEGER, 
	                distance    numeric(10,10) );'''.format(tablename))

	rowsqry = '''INSERT INTO {} VALUES (?,?,?);'''.format(tablename)

	for i in range(0,len(mat)):
		cur.execute(rowsqry, [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]])		
		#print [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]]

	cur.execute('''CREATE INDEX {}_conacct_ind ON {} (conacct);'''.format(tablename,tablename))
	cur.execute('''CREATE INDEX {}_conacctp_ind ON {} (conacctp);'''.format(tablename,tablename))

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'

#### FOR EACH PAWS OBS COMPUTE THE NEAREST 10 METERS

if _1_e_NEARPAW == 1:

	print '\n', " Compute Nearest PAWS TO CONACCT Table ! ", '\n'

	tablename = 'neighborp_50'

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	qry = '''
   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat = np.array(cur.fetchall())
	
	qry = '''
        SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            JOIN (SELECT conacct FROM paws GROUP BY conacct) AS p ON B.conacct = p.conacct
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat_paws = np.array(cur.fetchall())

	def dist_calc(in_mat,targ_mat):

	    nbrs = NearestNeighbors(n_neighbors=51, algorithm='auto').fit(targ_mat)
	    dist, ind = nbrs.kneighbors(in_mat)

	    return [dist,ind]

	res=dist_calc(mat_paws[:,:2], mat[:,:2])

	cur.execute('DROP TABLE IF EXISTS {};'.format(tablename))
	cur.execute(''' CREATE TABLE {} (
	                conacctp    INTEGER,
	                conacct     INTEGER, 
	                rank    	INTEGER, 
	                distance    numeric(10,10) );'''.format(tablename))

	rowsqry = '''INSERT INTO {} VALUES (?,?,?,?);'''.format(tablename)

	for i in range(0,len(mat_paws)):
		for j in range(1,51):
			cur.execute(rowsqry, [mat_paws[i][2],mat[res[1][i][j]][2],j,res[0][i][j]])	
		# cur.execute(rowsqry, [mat_paws[i][2],mat[res[1][i][0]][2],res[0][i][0]])		
		#print [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]]

	cur.execute('''CREATE INDEX {}_cp_ind ON {} (conacctp);'''.format(tablename,tablename))
	cur.execute('''CREATE INDEX {}_c_ind ON {} (conacct);'''.format(tablename,tablename))

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'





if _1_f_NEARRATECHANGE == 1:

	print '\n', " Compute Nearest RATE CHANGE TO CONACCT Table ! ", '\n'

	tablename = 'neighbor_rs_20'
	nc = 20 + 1

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	qry = '''
   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat = np.array(cur.fetchall())
	
	qry = '''
        SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  B.conacct AS conacct
            FROM meter AS e 
            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
            JOIN (SELECT conacct FROM conacct_rch) AS p ON B.conacct = p.conacct
            WHERE B.conacct>0
    	'''
	cur.execute(qry)
	mat_paws = np.array(cur.fetchall())

	def dist_calc(in_mat,targ_mat):

	    nbrs = NearestNeighbors(n_neighbors=nc, algorithm='auto').fit(targ_mat)
	    dist, ind = nbrs.kneighbors(in_mat)

	    return [dist,ind]

	res=dist_calc(mat_paws[:,:2], mat[:,:2])

	cur.execute('DROP TABLE IF EXISTS {};'.format(tablename))
	cur.execute(''' CREATE TABLE {} (
	                conacctp    INTEGER,
	                conacct     INTEGER, 
	                rank    	INTEGER, 
	                distance    numeric(10,10) );'''.format(tablename))

	rowsqry = '''INSERT INTO {} VALUES (?,?,?,?);'''.format(tablename)

	for i in range(0,len(mat_paws)):
		for j in range(1,nc):
			cur.execute(rowsqry, [mat_paws[i][2],mat[res[1][i][j]][2],j,res[0][i][j]])	
		# cur.execute(rowsqry, [mat_paws[i][2],mat[res[1][i][0]][2],res[0][i][0]])		
		#print [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]]

	cur.execute('''CREATE INDEX {}_cp_ind ON {} (conacctp);'''.format(tablename,tablename))
	cur.execute('''CREATE INDEX {}_c_ind ON {} (conacct);'''.format(tablename,tablename))

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'





##################################################
###### STEP 2 a : COMPUTE Barangay areas for enclosed points ######
##################################################

if _2_a_AREASTATS == 1:
	
	####################
	###### BOVERLAP
	####################

	def boverlap():
		print '\n', " Determine overlapping conaccts (with matched barangays) ", '\n'
		con = sql.connect(db)
		con.enable_load_extension(True)
		con.execute("SELECT load_extension('mod_spatialite');")
		cur=con.cursor()

		name = 'bmatch'

		cur.execute('DROP TABLE IF EXISTS {};'.format(name))
		qry = 	'''
				CREATE TABLE {} AS
	   			SELECT B.conacct, f.OGC_FID
	            FROM barangay AS f JOIN censusbar as g 
	            	ON f.OGC_FID = g.OGC_FID, 
	            meter AS e JOIN conacctseri AS B 
	            	ON e.OGC_FID = B.OGC_FID
	            WHERE e.ROWID IN (SELECT ROWID FROM SpatialIndex 
	               WHERE f_table_name='meter' AND search_frame=f.GEOMETRY)
	               AND st_within(e.GEOMETRY,f.GEOMETRY)
	               AND B.conacct>0
	               GROUP BY B.conacct;
				'''.format(name)
		cur.execute(qry)
		cur.execute('''CREATE INDEX {}_ind ON {} (conacct);'''.format(name,name))
		cur.execute('''CREATE INDEX {}_ogc_fid_ind ON {} (OGC_FID);'''.format(name,name))


		con.commit()
		con.close()

		print '\n', " Done :) ... ", '\n'	


	####################
	###### BNEAR
	####################

	def bnear():
		print '\n', " Find nearest centroids for the other conaccts", '\n'

		tablename = 'bmatch_dist'
		tablename2 = 'bmatch'

		con = sql.connect(db)
		con.enable_load_extension(True)
		con.execute("SELECT load_extension('mod_spatialite');")
		cur=con.cursor()

		qry = '''
	   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
	                  B.conacct AS conacct
	            FROM meter AS e 
	            JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID
	            LEFT JOIN boverlap AS G ON B.conacct = G.conacct
	            WHERE B.conacct>0 AND G.OGC_FID IS NULL
	    	'''
		cur.execute(qry)
		mat = np.array(cur.fetchall())
		
		qry = '''
	        SELECT DISTINCT st_x(st_centroid(e.GEOMETRY)) AS x, 
	        		  st_y(st_centroid(e.GEOMETRY)) AS y,
	                  e.OGC_FID AS OGC_FID
	            FROM barangay AS e 
	            JOIN censusbar AS G ON e.OGC_FID = G.OGC_FID
	    	'''
		cur.execute(qry)
		mat_paws = np.array(cur.fetchall())

		def dist_calc(in_mat,targ_mat):

		    nbrs = NearestNeighbors(n_neighbors=1, algorithm='auto').fit(targ_mat)
		    dist, ind = nbrs.kneighbors(in_mat)

		    return [dist,ind]

		res=dist_calc(mat[:,:2], mat_paws[:,:2])

		cur.execute('DROP TABLE IF EXISTS {};'.format(tablename))
		cur.execute(''' CREATE TABLE {} (
		                conacct     INTEGER,
		                OGC_FID    INTEGER, 
		                distance    numeric(10,10) );'''.format(tablename))

		rowsqry = '''INSERT INTO {} VALUES (?,?,?);'''.format(tablename)
		rowsqry_2 = '''INSERT INTO {} VALUES (?,?);'''.format(tablename2)

		for i in range(0,len(mat)):
			cur.execute(rowsqry, [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]])		
			cur.execute(rowsqry_2, [mat[i][2],mat_paws[res[1][i][0]][2]])		


		cur.execute('''CREATE INDEX {}_conacct_ind ON {} (conacct);'''.format(tablename,tablename))
		cur.execute('''CREATE INDEX {}_OGC_FID_ind ON {} (OGC_FID);'''.format(tablename,tablename))

		con.commit()
		con.close()

		print '\n', " Done :) ... ", '\n'	


	####################
	###### BNEAR
	####################

	def bstats():
		
		print '\n', " Compute Barangay Area ! ( only for accounts within barangay outline ... ) ", '\n'

		con = sql.connect(db)
		con.enable_load_extension(True)
		con.execute("SELECT load_extension('mod_spatialite');")
		cur=con.cursor()

		cur.execute('DROP TABLE IF EXISTS bstats;')
		qry = 	'''
				CREATE TABLE bstats AS
	   			SELECT f.OGC_FID, ST_AREA(f.GEOMETRY) as area,
	   						f.pop_2007 as pop,
	   						f.pop_2007/ST_AREA(f.GEOMETRY) as density,
	   					AVG(house_1) AS house_1,
	   					AVG(house_2) AS house_2,
	   					AVG(house_1 + house_2) AS house_avg,
	   					AVG(low_skill) AS low_skill,
	   					AVG(hhsize) AS hhsize,
	   					COUNT(*) AS obs,
	   					MAX(G.barangay_id) AS barangay_id
	            FROM barangay AS f 
	            JOIN censusbar AS G 
	            	ON f.OGC_FID = G.OGC_FID 
	            JOIN census AS H
	            	ON G.barangay_id = H.barangay_id
	            GROUP BY f.OGC_FID ;
				'''
		cur.execute(qry)
		cur.execute('''CREATE INDEX bstats_ind ON bstats (OGC_FID);''')

		con.commit()
		con.close()

		print '\n', " Done :) ... ", '\n'	


	#### RUN THE SUB PROGRAMS  ####

	boverlap()
	bnear()
	bstats()






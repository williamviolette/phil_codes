



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


_1_a_IMPORT 	= 0
_1_b_NEIGHBORS  = 0
_1_c_BAREA   	= 0

_2_a_HASSLE = 0

######################################
###### STEP 1 : SET UP DATABASE ######
######################################


if _1_a_IMPORT == 1:  # import GIS DATA
	
	print '\n', " Import GIS data into database ! ", '\n'

	if os.path.exists(db):
		os.remove(db)

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

	add_meter(gis_folder,db)
	add_barangay(gis_folder,db)

	print '\n', " Done ! ", '\n'


##################################################
###### STEP 1 b : COMPUTE TABLE OF NEAREST NEIGHBORS ######
##################################################

if _1_b_NEIGHBORS == 1:

	print '\n', " Compute Nearest Neighbors Table ! ", '\n'

	num_neighbors = 11 # set the number of neighbors

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	qry = '''
   		SELECT DISTINCT st_x(e.GEOMETRY) AS x, st_y(e.GEOMETRY) AS y,
                  CAST(e.account_no AS INTEGER) AS conacct
            FROM meter AS e WHERE CAST(e.account_no AS INTEGER) > 0
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


##################################################
###### STEP 1 c : COMPUTE Barangay areas for enclosed points ######
##################################################

if _1_c_BAREA == 1:

	print '\n', " Compute Barangay Area ! ", '\n'

	con = sql.connect(db)
	con.enable_load_extension(True)
	con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	cur.execute('DROP TABLE IF EXISTS barea;')
	qry = 	'''
			CREATE TABLE barea AS
   			SELECT CAST(e.account_no AS INTEGER) AS conacct, 
   						ST_AREA(f.GEOMETRY) as barea
            FROM meter AS e, barangay AS f
            WHERE e.ROWID IN (SELECT ROWID FROM SpatialIndex 
               WHERE f_table_name='meter' AND search_frame=f.GEOMETRY)
               AND st_within(e.GEOMETRY,f.GEOMETRY)
               AND CAST(e.account_no AS INTEGER) > 0
               GROUP BY CAST(e.account_no AS INTEGER);
			'''
	cur.execute(qry)
	cur.execute('''CREATE INDEX barea_ind ON barea (conacct);''')

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'	





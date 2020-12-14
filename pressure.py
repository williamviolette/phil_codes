
from sklearn.neighbors import NearestNeighbors
from pysqlite2 import dbapi2 as sql
import os, subprocess, shutil, multiprocessing, re, glob
from functools import partial
from itertools import product
import numpy  as np
# import pandas as pd
#from phil_subcode.spatial2sql import add_meter



analysis = os.getcwd()[:os.getcwd().rfind('phil_code')]
code = analysis + 'phil_code/'

phil_folder = '/Users/williamviolette/Documents/Philippines/'
database = phil_folder + 'database/'
data = phil_folder + 'data/'

gis_folder = data + 'gis/'
generated = analysis + 'phil_generated/'
db = generated+'phil.db'


_1_IMPORT       = 0
_2_DIST			= 1


print range(0,1)


if _1_IMPORT == 1:

	print 'start'
	def add_pipes(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'PIPES.shp','-nln pipes', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0
	
	def add_decom_pipes(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'DECOM_PIPES.shp','-nln decom_pipes', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_valves(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'VALVES.shp','-nln valves', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_pipe_primary(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'junk/pipe_primary_points.shp','-nln pipe_primary_points', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_pipe_secondary(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'junk/pipe_secondary_points.shp','-nln pipe_secondary_points', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_pipe_tertiary(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'junk/pipe_tertiary_points.shp','-nln pipe_tertiary_points', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_pmp(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'PMP.shp','-nln pmp', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	def add_chain_pipes(gis_folder,db):
		cmd = ['ogr2ogr -f "SQLite" -update','-a_srs http://spatialreference.org/ref/epsg/25393/',
		db, gis_folder+'junk/chain_pipes.shp','-nln chain_pipes', '-overwrite -skipfailures']
		subprocess.call(' '.join(cmd),shell=True)
		return 0

	# add_pipes(gis_folder,db)
	# add_valves(gis_folder,db)
	# add_pipe_primary(gis_folder,db)
	# add_pipe_secondary(gis_folder,db)
	# add_pipe_tertiary(gis_folder,db)
	# add_pmp(gis_folder,db)
	# add_chain_pipes(gis_folder,db)
	add_decom_pipes(gis_folder,db)




if _2_DIST == 1:

	print '\n', " Compute Nearest RATE CHANGE TO CONACCT Table ! ", '\n'

	def nearby(tablename,targetid,targettable,targetcond,centroid,totn):
		nc = totn + 1

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
		mat_meter = np.array(cur.fetchall())
		
		if centroid==1:
			geoselect = 'st_x(st_centroid(B.GEOMETRY)) AS x, st_y(st_centroid(B.GEOMETRY)) AS y,'
		else:
			geoselect = 'st_x(B.GEOMETRY) AS x, st_y(B.GEOMETRY) AS y,'

		qry = '''
	        SELECT DISTINCT {}
	                  B.{} 
	            FROM {} AS B {}
	    	'''.format(geoselect,targetid,targettable,targetcond)
		cur.execute(qry)
		mat = np.array(cur.fetchall())

		def dist_calc(in_mat,targ_mat):

		    nbrs = NearestNeighbors(n_neighbors=nc, algorithm='auto').fit(targ_mat)
		    dist, ind = nbrs.kneighbors(in_mat)

		    return [dist,ind]

		res=dist_calc(mat_meter[:,:2], mat[:,:2])

		cur.execute('DROP TABLE IF EXISTS {};'.format(tablename))
		cur.execute(''' CREATE TABLE {} (
		                conacct    INTEGER,
		                {}     		INTEGER, 
		                rank    	INTEGER, 
		                distance    numeric(10,10) );'''.format(tablename,targetid))

		rowsqry = '''INSERT INTO {} VALUES (?,?,?,?);'''.format(tablename)

		for i in range(0,len(mat_meter)):
			for j in range(1,nc):
				cur.execute(rowsqry, [mat_meter[i][2],mat[res[1][i][j]][2],j,res[0][i][j]])	
			# cur.execute(rowsqry, [mat_paws[i][2],mat[res[1][i][0]][2],res[0][i][0]])		
			#print [mat[i][2],mat_paws[res[1][i][0]][2],res[0][i][0]]

		cur.execute('''CREATE INDEX {}_cp_ind ON {} (conacct);'''.format(tablename,tablename))
		cur.execute('''CREATE INDEX {}_c_ind ON {} ({});'''.format(tablename,tablename,targetid))

		con.commit()
		con.close()

		print '\n', " Done :) ... ", '\n'

	targetcond = ' WHERE B.pipe_class == "TERTIARY" '
	tablename = 'pipe_tertiary_dist'
	targettable = 'pipes'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,1,1)

	targetcond = ' WHERE B.pipe_class == "SECONDARY" '
	tablename = 'pipe_secondary_dist'
	# nearby(tablename,targetid,targettable,targetcond,1,1)

	targetcond = ' WHERE B.pipe_class == "PRIMARY" '
	tablename = 'pipe_primary_dist'
	# nearby(tablename,targetid,targettable,targetcond,1,1)

	targetcond = '  '
	tablename = 'pipe_primary_points_dist'
	targettable = '(SELECT e.GEOMETRY, B.OGC_FID FROM chain_pipes AS e JOIN pipes AS B ON e.fid = B.OGC_FID WHERE B.pipe_class=="PRIMARY")'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)

	targetcond = '  '
	tablename = 'pipe_secondary_points_dist'
	targettable =  '(SELECT e.GEOMETRY, B.OGC_FID FROM chain_pipes AS e JOIN pipes AS B ON e.fid = B.OGC_FID WHERE B.pipe_class=="SECONDARY")'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)

	targetcond = '  '
	tablename =  'pipe_tertiary_points_dist' 
	targettable = '(SELECT e.GEOMETRY, B.OGC_FID FROM chain_pipes AS e JOIN pipes AS B ON e.fid = B.OGC_FID WHERE B.pipe_class=="TERTIARY")'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)

	targetcond = '  '
	tablename =  'pipe_tertiary_points_5m_dist' 
	targettable = '( SELECT e.GEOMETRY, B.OGC_FID FROM chain_pipes AS e JOIN pipes AS B ON e.fid = B.OGC_FID WHERE B.pipe_class=="TERTIARY" AND ST_LENGTH(B.GEOMETRY)>5 )'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)


	targetcond = ' JOIN pmp_link AS PL ON PL.OGC_FID = B.OGC_FID '
	tablename = 'pmp_dist'
	targettable = 'pmp'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)


	targetcond = '  '
	tablename = 'valves_dist'
	targettable = 'valves'
	targetid = 'OGC_FID'
	# nearby(tablename,targetid,targettable,targetcond,0,1)


	targetcond = '  '
	tablename = 'ln_dist'
	targettable = '(SELECT e.GEOMETRY, B.conacct AS conacctl FROM meter AS e JOIN conacctseri AS B ON e.OGC_FID = B.OGC_FID JOIN (SELECT 1 AS j, conacct FROM LN) AS L ON L.conacct=B.conacct  WHERE B.conacct>0 AND L.j==1)'
	targetid = 'conacctl'
	# nearby(tablename,targetid,targettable,targetcond,0,10)



	def int_meter_barangay(db):

			print 'start this barangay'
			name = 'meter_barangay_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT B.conacct,
	                		G.OGC_FID as ogc_fid_barangay,
	                		G.prikey
	                FROM barangay as G, meter as A JOIN conacctseri AS B ON A.OGC_FID = B.OGC_FID
	                WHERE B.conacct>0 AND A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='meter' AND search_frame=G.GEOMETRY)
	                AND st_intersects(A.GEOMETRY,G.GEOMETRY)
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			cur.execute('''CREATE INDEX {}_cp_ind ON {} (conacct);'''.format(name,name))
			cur.execute('''CREATE INDEX {}_c_ind ON {} (prikey);'''.format(name,name))

			return

	# int_meter_barangay(db)

	def int_meter_dma(db):

			print 'start this'
			name = 'meter_dma_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT B.conacct,
	                		G.OGC_FID as ogc_fid_dma,
	                		G.dma_id
	                FROM dma as G, meter as A JOIN conacctseri AS B ON A.OGC_FID = B.OGC_FID
	                WHERE B.conacct>0 AND A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='meter' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			cur.execute('''CREATE INDEX {}_cp_ind ON {} (conacct);'''.format(name,name))
			cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return

	# int_meter_dma(db)


	def int_pipes_barangay(db):

			print 'start this'
			name = 'pipes_barangay_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT G.OGC_FID AS OGC_FID_bar,
	                		G.brgy AS bar,
	                		G.municipali AS mun,
	                		A.OGC_FID AS OGC_FID_pipes,
	                		A.pipe_class,
	                		A.year_inst,
	                		ST_LENGTH(ST_INTERSECTION(A.GEOMETRY,G.GEOMETRY)) AS int_length
	                FROM barangay as G, pipes as A
	                WHERE  A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='pipes' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			# cur.execute('''CREATE INDEX {}_cp_ind ON {} (bar);'''.format(name,name))
			# cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return

	# int_pipes_barangay(db)


	def int_pipes_dma(db):

			print 'start this'
			name = 'pipes_dma_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT G.OGC_FID AS OGC_FID_dma,
	                		G.dma_id AS dma_id,
	                		A.OGC_FID AS OGC_FID_pipes,
	                		A.pipe_class,
	                		A.year_inst,
	                		ST_LENGTH(ST_INTERSECTION(A.GEOMETRY,G.GEOMETRY)) AS int_length
	                FROM dma as G, pipes as A
	                WHERE  A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='pipes' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			# cur.execute('''CREATE INDEX {}_cp_ind ON {} (bar);'''.format(name,name))
			# cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return

	# int_pipes_dma(db)


	def int_pipes_mru(db):

			print 'start this'
			name = 'pipes_mru_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT G.OGC_FID AS OGC_FID_mru,
	                		G.mru_no AS mru,
	                		A.OGC_FID AS OGC_FID_pipes,
	                		A.pipe_class,
	                		A.year_inst,
	                		ST_LENGTH(ST_INTERSECTION(A.GEOMETRY,G.GEOMETRY)) AS int_length
	                FROM mru as G, pipes as A
	                WHERE  A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='pipes' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			# cur.execute('''CREATE INDEX {}_cp_ind ON {} (bar);'''.format(name,name))
			# cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return
	
	# int_pipes_mru(db)


	def int_decom_pipes_mru(db):

			print 'start this'
			name = 'decom_pipes_mru_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                	CREATE TABLE {} AS 
	                		SELECT G.OGC_FID AS OGC_FID_mru,
	                		G.mru_no AS mru,
	                		A.OGC_FID AS OGC_FID_pipes,
	                		A.pipe_class,
	                		A.year_inst,
	                		A.year_decom,
	                		A.status,
	                		A.material,
	                		ST_LENGTH(ST_INTERSECTION(A.GEOMETRY,G.GEOMETRY)) AS int_length
	                FROM mru as G, decom_pipes as A
	                WHERE  A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='decom_pipes' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			# cur.execute('''CREATE INDEX {}_cp_ind ON {} (bar);'''.format(name,name))
			# cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return
	
	int_decom_pipes_mru(db)

	def int_barangay_mru(db):

			print 'start this'
			name = 'barangay_mru_int'

		    # connect to DB
			con = sql.connect(db)
			con.enable_load_extension(True)
			con.execute("SELECT load_extension('mod_spatialite');")
			cur = con.cursor()

			cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

			print 'running ... '

			make_qry = '''
		                   CREATE TABLE {} AS 
	                		SELECT G.OGC_FID AS OGC_FID_bar,
	                		G.brgy AS bar,
	                		G.municipali AS mun,
	                		A.OGC_FID AS OGC_FID_mru,
	                		A.mru_no AS mru,
	                		ST_AREA(G.GEOMETRY) AS bar_area,
	                		ST_AREA(A.GEOMETRY) AS mru_area,
	                		ST_AREA(ST_INTERSECTION(A.GEOMETRY,G.GEOMETRY)) AS int_area
	                FROM barangay as G, mru as A
	                WHERE  A.ROWID IN (SELECT ROWID FROM SpatialIndex 
	                WHERE f_table_name='mru' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
	                AND st_intersects(A.GEOMETRY,ST_MAKEVALID(G.GEOMETRY))
		                    ;
				              '''.format(name)
			cur.execute(make_qry)
			
			# cur.execute('''CREATE INDEX {}_cp_ind ON {} (bar);'''.format(name,name))
			# cur.execute('''CREATE INDEX {}_c_ind ON {} (dma_id);'''.format(name,name))

			return
	
	# int_barangay_mru(db)


	# def int_mru_dma(db):

	# 	print 'start this'
	# 	name = 'mru_dma_int'

	#     # connect to DB
	# 	con = sql.connect(db)
	# 	con.enable_load_extension(True)
	# 	con.execute("SELECT load_extension('mod_spatialite');")
	# 	cur = con.cursor()

	#     # chec_qry = '''
	#     #            SELECT type,name from SQLite_Master
	#     #            WHERE type="table" AND name ="{}";
	#     #            '''.format(name)

	#     # drop_qry = '''
	#     #            SELECT DisableSpatialIndex('{}','GEOMETRY');
	#     #            SELECT DiscardGeometryColumn('{}','GEOMETRY');
	#     #            DROP TABLE IF EXISTS idx_{}_GEOMETRY;
	#     #            DROP TABLE IF EXISTS {};
	#     #            '''.format(name,name,name,name)

	#     # cur.execute(chec_qry)
	#     # result = cur.fetchall()
	#     # if result:
	#     #     cur.executescript(drop_qry)
	# 	cur.execute('DROP TABLE IF EXISTS {};'.format(name))   

	# 	print 'running ... '

	# 	make_qry = '''
	#                    CREATE TABLE {} AS 
 #                		SELECT A.OGC_FID as ogc_fid_mru,
 #                		A.mru_no as mru,
 #                		G.OGC_FID as ogc_fid_dma,
 #                		G.dma_id, 
 #                        st_area(st_intersection(ST_MAKEVALID(A.GEOMETRY),ST_MAKEVALID(G.GEOMETRY))) AS area
 #                FROM mru as A, dma as G
 #                WHERE A.ROWID IN (SELECT ROWID FROM SpatialIndex 
 #                WHERE f_table_name='mru' AND search_frame=ST_MAKEVALID(G.GEOMETRY))
 #                AND st_intersects(ST_MAKEVALID(A.GEOMETRY),ST_MAKEVALID(G.GEOMETRY))
	#                     ;
	# 		              '''.format(name)
	# 	cur.execute(make_qry)
	    
	#     # cur.execute("SELECT RecoverGeometryColumn('{}','GEOMETRY',2046,'MULTIPOLYGON','XY');".format(name))
	#     # cur.execute("SELECT CreateSpatialIndex('{}','GEOMETRY');".format(name))

	# 	return

	# # int_mru_dma(db)
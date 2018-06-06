

from pysqlite2 import dbapi2 as sql
import os, subprocess, shutil, multiprocessing, re, glob
from functools import partial
from itertools import product
import numpy  as np
import pandas as pd
#from phil_subcode.spatial2sql import add_meter



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

print phil_folder
print database
print data
print gis_folder
print code

_1_a_IMPORT = 0
_2_a_HASSLE_TEST = 1



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
###### STEP 2 : COMPUT HASSLE COST INTEREST ######
##################################################

if _2_a_HASSLE_TEST == 1:

	print '\n', " Compute Areas for subset of data ! ", '\n'

	dofile = "phil_subcode/export_stata.do"
	cmd = ['stata-mp', 'do', dofile]
	subprocess.call(cmd)





from sklearn.neighbors import NearestNeighbors
from pysqlite2 import dbapi2 as sql
import os, subprocess, shutil, multiprocessing, re, glob
from functools import partial
from itertools import product
import numpy  as np
import pandas as pd


analysis = os.getcwd()[:os.getcwd().rfind('phil_code')]
code = analysis + 'phil_code/'

phil_folder = '/Users/williamviolette/Documents/Philippines/'
database = phil_folder + 'database/'
data = phil_folder + 'data/'

gis_folder = data + 'gis/'
generated = analysis + 'phil_generated/'
db = generated+'phil.db'


leaks_table  = 1

if leaks_table == 1:

	print '\n', " Create Leak Merge Table ! ", '\n'

	con = sql.connect(db)
	#con.enable_load_extension(True)
	#con.execute("SELECT load_extension('mod_spatialite');")
	cur=con.cursor()

	cur.execute('DROP TABLE IF EXISTS leaks;')
	qry = 	'''
		CREATE TABLE leaks AS
		SELECT A.*, C.ar
		FROM billing_1 AS A 
		JOIN ar_1 AS C 
			ON A.conacct = C.conacct AND A.date = C.date;
			'''
	cur.execute(qry)
	cur.execute('''CREATE INDEX conacct_leak_test ON leaks (conacct);''')

	con.commit()
	con.close()

	print '\n', " Done :) ... ", '\n'	



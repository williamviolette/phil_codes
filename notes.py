


# CREATE TABLE query right here !!
#	qry = '''
#    	CREATE TABLE paw_density AS
#    	SELECT 
#                    FROM bblu_{} as A, rdp_conhulls AS G
#                    WHERE A.ROWID IN (SELECT ROWID FROM SpatialIndex 
#                        WHERE f_table_name='bblu_{}' AND search_frame=G.GEOMETRY)
#                        AND st_intersects(A.GEOMETRY,G.GEOMETRY)
#                    GROUP BY A.conacct;
#    	'''



# ADD python path for QGIS
# open bash in text editor through terminal with:
#   touch ~/.bash_profile; open ~/.bash_profile


# on OSX: export PYTHONPATH=/Applications/QGIS.app/Contents/Resources/python
#         export PATH="/Applications/QGIS.app/Contents/MacOS/bin:$PATH"

## RUN QGIS REMOTELY

#from qgis.core import *

#	QgsApplication.setPrefixPath("/Applications/QGIS.app/Contents/MacOS/", True)
#	qgs = QgsApplication([], True)
#	qgs.initQgis()

#	uri = QgsDataSourceURI()
#	uri.setDatabase(db)
#	schema = ''
#	table = 'meter'
#	geom_column = 'GEOMETRY'
#	uri.setDataSource(schema, table, geom_column)

#	display_name = 'METER'
#	vlayer = QgsVectorLayer(uri.uri(), display_name, 'spatialite')

#	QgsMapLayerRegistry.instance().addMapLayer(vlayer)
#	qgs.exitQgis()



## TEST ENTRY OF NEIGHBORS TABLE

#	for i in range(0,3):
#		for j in range(1,5):
#			print 'line'
#			print i
#			print j
#			print mat[i][2]
#			print mat[res[1][i][j]][2]
#			print res[0][i][j]





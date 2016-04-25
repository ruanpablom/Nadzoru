COEF_FILE  = io.open('COEF_FILE', 'w')
LOG_FILE   = io.open('LOG_FILE',  'w')
GEOM_FILE  = io.open('GEOM_FILE', 'w')
GEOM_FILE:write( "equations = {\n" )
System = {}
require 'System'
require 'FBViewer'
print('\n\n\n\n-------------------FBE - Function Block Environment-----------------------')
print('---UDESC - Universidade do Estado de Santa Catarina')
print('---GASR  - Grupo de Automacao de Sistemas e Robotica\n---Version 1.0 ')
print('---gtk version = ' , gtk.version() )

F = FBViewer.new()
F:run()
GEOM_FILE:write( "}\n" )
GEOM_FILE:close()




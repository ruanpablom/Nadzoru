COEF_FILE  = io.open('COEF_FILE', 'w')
LOG_FILE   = io.open('LOG_FILE',  'w')
GEOM_FILE  = io.open('GEOM_FILE',  'w')
GEOM_FILE:write( "equations = {\n" )
System = {}
require 'System'
--require 'DrawNetwork'
--require 'FBViewer'

--~ local S = FB.importXML('/home/gabriel/Dropbox/Projeto_LAPAS/Biblioteca FB (oficial)/', 'STARTER.xml', 'S')
local S = System.importXML ('Biblioteca FB (oficial)\\', 'System.xml', 'S')
S['RTE_Lua']['STEP-NC_DATA1']['START_WORK']:exe(1)
--GEOM_FILE:write( "}\n" )


--GEOM_FILE:close()
COEF_FILE:close()
LOG_FILE:close()





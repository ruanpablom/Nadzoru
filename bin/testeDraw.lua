require 'System'
require 'Device'
require 'DrawNetwork'
--require 'DrawBlock'
--require 'FBViewer'
--require 'BlockView'


local lma = FB.importXML ('XML/linear_move_adjusted.xml', 'lma')
DrawNetwork (lma)

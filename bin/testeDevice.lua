require 'Device'

Device = Device.importXML ('XML/Device1.xml', 'Device')
Device.r1.Subl_r1.RD_1 = {0, 0, 0 }
Device.r1:exe ('ind', 'Subl')

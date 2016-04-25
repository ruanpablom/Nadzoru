Sub_0 = {}

Sub_0.__index = SIFB_Subl    

function Sub_0:exe(event)
    print( '***Subl: '..self.label..' started with event: '..event )
    System[System.Device][self.resource]:exe( event, 'Subl' )
end

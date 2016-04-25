SIFB_Publ = {}

SIFB_Publ.__index = SIFB_Publ

SIFB_Publ.new = function ( label, resource )
    local t = {}
    setmetatable ( t, SIFB_Publ )
    t.label = label
    _, _,t.id    = label:find('.+%_+(.+)')   --Coloca o nome do resource	 destino
    t.resource   = resource
    return t
end

--~ function SIFB_Publ:service ( event )
    --~ --print(self.label..' procura: '..self.ServiceSequence[ event ][ 1 ]..'_'..self.ID[2])
    --~ return self.ServiceSequence[ event ][ 2 ], self.ServiceSequence[ event ][ 1 ]..'_'..self.ID[2]
    --~
--~ end

function SIFB_Publ:exe(event)

    LOG_FILE:write('SIFB_Publ--- '..self.label..' started with event: '..event..'\n')
    --~ local label
    --~ event, label = self:service (event)
    LOG_FILE:write('SIFB_Publ--- Service -> Data transfer from local publisher to local subscriber\n')
    local _, _, quantas_in_vars = self.FBType:find('.+%_+(%d+)')
    quantas_in_vars = tonumber(quantas_in_vars)
--    print(self.ID[1], self.label)
    for i = 1, quantas_in_vars do
--        print(self.ID[1], self.ID[2], self._Resource, self._Resource._Device.label, self._Resource._Device[ self.ID[1] ])
        self._Resource._Device[ self.ID[1] ][ self.ID[2] ][ 'RD_'..tostring(i) ] = self[ 'SD_'..tostring(i) ]

        --~ --%%%%%APAGAR ISSO%%%%%%%%%%%%%
            --~ if type(self['SD_'..tostring(i)]) == 'table' then
            --~ print('VALORES DO SUBL---> RD_'..tostring(i)..' = ' , self[ 'SD_'..tostring(i) ][1], self[ 'SD_'..tostring(i) ][2], self[ 'SD_'..tostring(i) ][3]) end
        --~ --%%%%%APAGAR ISSO%%%%%%%%%%%%%


    end

    --LOG_FILE:write('SIFB_Subl--- '.. label.. ' returned event: '.. event..'\n' )
    if self._Resource and self._Resource._Device and self._Resource._Device[ self.ID[1] ] and
    self._Resource._Device[ self.ID[1] ][ self.ID[2] ] and self._Resource._Device[ self.ID[1] ][ self.ID[2] ].exe then
        self._Resource._Device[ self.ID[1] ][ self.ID[2] ]:exe( 'IND' )
    else
        LOG_FILE:write('SIFB_Publ--- Couldn\'t find subscriber\n')
    end
    return nil, 'Execution_OK'

end

SIFB_Class.SIFB_Publ = SIFB_Publ

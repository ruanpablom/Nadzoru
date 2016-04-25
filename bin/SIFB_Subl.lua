SIFB_Subl = {  	--SIFB_Subl = Service Interface Function Block, Sublisher Local
    --[[
    label = "",
    id    = "",
    type  = "Subscriber local" ,
    --Eventos de Entrada
    init  = false,
    rsp   = false,
    --Eventos de Saída
    inito = false,
    ind   = false,
    --Parâmetros de Entrada:
    QI    = false,
    RD_1  = {0, 0, 0},
    RD_2  = {0, 0, 0}, --o numero de parametros e o tipo de cada um varia de acordo com cada caso

    flag = {
        init  = "InputEvent" ,
        inito = "OutputEvent",
        ind   = "OutputEvent",
        QI    =  false,
        RD_1  = "Parameter",
        RD_2  = "Parameter",
    },
    with ={
        
        init = {"QI"},
        ind  = {"RD_1","RD_2"},
    },
    ServiceSequence = {
            rsp   = {"Publ", "cnf"},
            init  = {"Subl", "inito"},
    },]]
}

SIFB_Subl.__index = SIFB_Subl

SIFB_Subl.new = function ( label, resource )
    local t = {}
    setmetatable ( t, SIFB_Subl )
    t.label = label
    _, _,t.id    = label:find('.+%_+(.+)')   --Coloca o nome do resource
    t.resource   = resource
    return t
end
    

function SIFB_Subl:exe(event)
    LOG_FILE:write( 'SIFB_Subl--- '..self.label..' started with event: '..event..'\n' )
    self._Resource:exe( event, self.label )
end

SIFB_Class.SIFB_Subl = SIFB_Subl

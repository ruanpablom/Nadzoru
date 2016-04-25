--separar o parametro file_name do importXML em root + fbtype

require 'BasicFB'
require 'CompFB'
require 'SIFB_Publ'
require 'SIFB_Subl'
require 'Starter'
require 'File_Writer'

--funcoes auxiliares
local split = function ( str )
    local _,_,str1,str2 = str:find('(.+)%.(.+)')
    return str1, str2
end

local function string_to_value (str, ArraySize, tipo)
    --print('Inicio da função String to value\n' ,str, ArraySize, tipo)
    local valor 
    if not ArraySize then
        if tipo == 'BOOL' then
            if str =='false' or str == 'FALSE' or str == 'False' then return false
            elseif str =='true' or str == 'True' or str == 'TRUE' then return true
            end
        elseif tipo =='REAL' then
            return tonumber(str)
        elseif tipo == 'STRING'  then
            return str
        else return '@INVALID'
        end
    else
        if tipo == 'REAL' then
            valor = {}
            if ArraySize == '1' then
                 _,_,valor[1] =  str:find("%[(%d+)%]")
            elseif ArraySize == '2' then
                 _,_,valor[1], valor[2] =  str:find("%[(%d+)%,(%d+)%]")
            elseif ArraySize == '3' then
                 _,_,valor[1], valor[2], valor[3] =  str:find("%[(%d+)%,(%d+)%,(%d+)%]")
            elseif ArraySize == '4' then
                 _,_,valor[1], valor[2], valor[3], valor[4] =  str:find("%[(%d+)%,(%d+)%,(%d+)%,(%d+)%]")
            end
            for i=1, ArraySize do
                valor[i] = tonumber(valor[i])
            end
        elseif tipo == 'STRING' then
            valor = {}
            if ArraySize == '1' then
                 _,_,valor[1] =  str:find("%[(.+)%]")
            elseif ArraySize == '2' then
                 _,_,valor[1], valor[2] =  str:find("%[(.+)%,(.+)%]")
            elseif ArraySize == '3' then
                 _,_,valor[1], valor[2], valor[3] =  str:find("%[(.+)%,(.+)%,(.+)%]")
            elseif ArraySize == '4' then
                 _,_,valor[1], valor[2], valor[3], valor[4] =  str:find("%[(.+)%,(.+)%,(.+)%,(.+)%]")
            end
        end
    return valor    
    end
end



local clone = function ( t , deep )  --créditos Y.K.
    if (type(t) ~='table') then
        r = t
    else
        local r = {}
        for k, v in pairs( t ) do
            if deep and type( v ) == 'table'
                then r[ k ] = table.clone( v, true )
                else r[ k ] = v
                end
        end
    end
    return r
end

FB = {}
FB.importXML = function(file_name, label)
    local model = {}
    model.invarlist        = {}
    model.ineventlist      = {}
    model.outvarlist       = {}
    model.outeventlist     = {}
    model.FBNetwork        = {}
    model.Type             = {}
    model.ArraySize        = {}
    model.ArraySize2       = {}
    local state            = {}
    local funcoes          = {}
    model.label            = label
    model.with             = {}             --estruturas utilizadas para armazenar os dados
    model.flag             = {}
    local Basics           = {}
    local BasicsPos        = {}
    model.flag             = {}
    model.stlist           = {}
    model.INPUTS           = {}
    local InPrim           = " "
    local acState          = 0
    local acEvent          = 0
    local acAlg            = 0
    local class            = " "
    local st_ev            = " "
    local service          = " "
    model.EventConnections = {}
    model.DataConnections  = {}
    model.STdx             = {}                   --posiçao de estado no desenho do ECC
    model.STdy             = {}
    model.buffer = {
        eventPos = 1,
        event = {
        },
        var = {
            --Buffer: ["instance.var"] = value  
        },
    }


    -- tratamento de estados
    --ADICIONAR OS CABEÇALHOS

    funcoes[ 'FBType' ] = function( name, atb )
        model.FBType = atb.Name
        class = atb.Class
        model.Class = atb.Class
    end
    --------
    funcoes['Identification'] = function( name, atb )
    local Identification = atb.Standard
    end  
    ---------
    funcoes[ 'InterfaceList' ] = function ( name, atb )
    end
    ---------
    funcoes[ 'EventInputs' ]  = function ( name, atb )
    end
    ---------
    funcoes[ 'EventOutputs' ]  = function ( name, atb )
    end
    ---------
    funcoes[ 'Event' ] = function ( name, atb )
        if state[#state-1] == 'EventInputs' then      
            model[atb.Name] = false    --inicializou o evento
            model.flag[atb.Name] = "InputEvent"
            model.ineventlist [#model.ineventlist+1] = atb.Name
            acEvent = atb.Name
            --if atb.Name ==  'req' then service = 'publisher' end -- GAMBI_1
        else
            model[atb.Name] = false    --inicializou o evento
            model.flag[atb.Name] = "OutputEvent"
            model.outeventlist [#model.outeventlist+1] = atb.Name
            acEvent = atb.Name
            st_ev = atb.Name
            if model.Class == 'File_Writer' then
                model.CONFIRMATION = atb.Name
            end
            --if atb.Name ==  'ind' then service = 'subscriber' end -- GAMBI_2
        end
    end
    ---------
    funcoes[ 'With' ] = function ( name, atb )
        if type(model.with[acEvent]) ~= "table" then
            model.with[acEvent] ={}
        end
        local tam = #model.with[acEvent]  +1
        model.with[acEvent][tam] = atb.Var
    end
    ---------
    funcoes [ 'InputVars' ]= function ( name, atb )
    end
    ---------
    funcoes [ 'OutputVars' ]= function ( name, atb )
    end
    ---------
    funcoes [ 'VarDeclaration' ] = function ( name, atb) 
        
        if atb.ArraySize ~= nil and tonumber(atb.ArraySize) > 1 then
            model[atb.Name] = {}
            for i = 1, atb.ArraySize do
                model[atb.Name][#model[atb.Name]+1] = 0 --inicializa vetor
                end
            else
            model[atb.Name] = 0  -- nao eh array
        end
        
        
        model.INPUTS[#model.INPUTS+1]  = atb.Name
        model.Type[atb.Name]           = atb.Type
        model.ArraySize[atb.Name]      = atb.ArraySize or 1 --usado para inicializar as variaveis
        model.ArraySize2[atb.Name]     = atb.ArraySize --usado para os parametros
        
        if atb.InitialValue then
            model[atb.Name] = string_to_value (atb.InitialValue, atb.ArraySize, atb.Type)
        end
        
        if state[#state-1] == 'InputVars' then 
            model.flag[atb.Name] = 'InputVar'
            model.invarlist [#model.invarlist+1] = atb.Name
        else
            model.flag[atb.Name] = 'OutputVar'
            model.outvarlist [#model.outvarlist+1] = atb.Name
        end
    end
    ---------
    funcoes[ 'FBNetwork' ] = function ( name, atb)
    --class = "Composite"
    end
    ---------
    funcoes [ 'FB' ] = function ( name, atb )
        Basics[#Basics +1]       = {atb.Name, atb.Type}   --vai instanciar os blocos ao final
        BasicsPos[#BasicsPos +1] = {atb.dx  , atb.dy}
    end
    ---------
    funcoes[ 'EventConnections' ] = function ( name, atb)
    end
    ---------
    funcoes[ 'DataConnections' ]  = function ( name, atb)
    end
    ---------
    
    funcoes[ 'Connection' ]  = function ( name, atb)
        local sourceInst, sourceEvent, destInst, destEvent
        if state[#state -1] == 'EventConnections' then 
            sourceInst, sourceEvent = split (atb.Source)
            if sourceInst ==nil or sourceEvent ==nil then    --separa a string antes e depois do ponto
                sourceInst = 'self' 
                sourceEvent = atb.Source   
            end
            destInst, destEvent = split (atb.Destination)
            if destInst ==nil or destEvent ==nil then    --separa a string antes e depois do ponto
                destInst = 'self'
                destEvent = atb.Destination
            end
            if type (model.EventConnections[sourceInst]) ~= 'table' then
                model.EventConnections[sourceInst] = {}
            end
            model.EventConnections[sourceInst][sourceEvent] = { destInst , destEvent }
        
        elseif state[#state -1] == 'DataConnections' then
            local sourceInst, sourceData, destInst, destData
            sourceInst, sourceData = split (atb.Source)
            if sourceInst ==nil or sourceData ==nil then    --separa a string antes e depois do ponto
                sourceInst = 'self'
                sourceData = atb.Source
            end
            
            destInst, destData = split (atb.Destination)
            if destInst ==nil or destData ==nil then    --separa a string antes e depois do ponto
                destInst = 'self'
                destData = atb.Destination
            end
            
            if type(model.DataConnections[destInst]) ~= 'table' then
                model.DataConnections[destInst] = {}
            end
            model.DataConnections[destInst][destData] = {sourceInst, sourceData}

        end
    end
    -----
    
    funcoes[ 'BasicFB' ] = function ( name, atb)
        --class = "Basic"
    end
    -----
    
    funcoes [ 'ECC' ] = function ( name, atb)
    end
    -----
    
    funcoes [ 'ECState' ] = function ( name, atb)
        model.stlist[atb.Name] = {}
        model.stlist[atb.Name].transition = {}
        model.stlist[atb.Name].action     = {}
        model.STdx[atb.Name]              = tonumber(atb.dx)
        model.STdy[atb.Name]              = tonumber(atb.dy)
        acState = atb.Name
    end
    -----
    
    funcoes [ 'ECAction' ] = function ( name, atb )
        local tam = #model.stlist[acState].action
        model.stlist[acState].action[tam+1] = {}
        model.stlist[acState].action[tam+1].alg = atb.Algorithm
        model.stlist[acState].action[tam+1].out = atb.Output
    end
    -----
    
    funcoes [ 'ECTransition' ] = function ( name, atb )
        local translate = {
            ['&']  = ' and ',
            ['||'] = ' or ',
            ['!']  = ' not ',
            ['!='] = '~=',
        }
        local tam = #model.stlist[atb.Source].transition 
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition+1] = {}
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition].Condition = atb.Condition
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition].Destination = atb.Destination
    end
    -----
    
    funcoes ['Algorithm'] = function ( name, atb )
        --print('abriu algorithm')
            acAlg = atb.Name
    end
    ----
    
    funcoes ['Lua'] = function ( name, atb )   --armazena o conteúdo do algoritmo
            model[acAlg] = atb.Text
    -----
    end
    ----- dados de publisher e subscriber, a seguir:
    
    funcoes ['Service'] = function ( name, atb)
        --class = 'ServiceInterface'
        model.ServiceSequence = {}
        --print('L: '..atb.RightInterface..' R: '.. atb.LeftInterface)
    end
    
    -----
    
    funcoes ['ServiceSequence'] = function ( name, atb )
        --print('ServiceSequence: '..atb.Name)
    end
    
    ----
    
    funcoes ['ServiceTransaction'] = function ( name, atb )
        --print('Abriu ServiceTransaction')
    end
    
    ----
    
    funcoes ['InputPrimitive'] = function ( name, atb)
        InPrim = atb.Event
    end
    
    ----
    
    funcoes ['OutputPrimitive'] = function ( name, atb)
        model.ServiceSequence[InPrim] = {atb.Interface, atb.Event}
    end
    
    
    ------------------------Inicio do  parser---------------------
    local callbacks = {
        
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then 
                funcoes[ state[#state] ]( name, atb )
            else --print('funcao ', name, ' nao encontrada')
            end
        end,
        
        EndElement = function ( parser, name )
        --  io.write(string.rep(" ", count),"- ",  name, "\n")
            state[#state] =nil 
        end
    }

    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
    local file = io.open( file_name, 'r')
    for l in file:lines() do  -- iterate lines
        p:parse(l)            -- parses the line
        p:parse("\n")         -- parses the end of line

    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    
    --Instanciação dos blocos internos
    -----------------------------------------------------------------------
    
    for i, v in ipairs(Basics) do
        model[v[1]] = FB.importXML ('XML/'..v[2]..".xml", v[1])
        model[v[1]].Upper = model
        model[v[1]].dx = tonumber(BasicsPos[i][1])
        model[v[1]].dy = tonumber(BasicsPos[i][2])
        model.FBNetwork[#model.FBNetwork+1] = {v[1],tonumber(BasicsPos[i][1]),  tonumber(BasicsPos[i][2])}
    end
    
    if class == 'Comp' then
        setmetatable(model, CompFB)
        model.Class = 'Comp'
    
    elseif model.Class == 'Starter' then
        model.event = st_ev
        setmetatable(model, Starter)
    elseif model.Class =='Basic' then
        setmetatable(model, BasicFB)
        model.state = 'START'
    elseif model.Class == 'Publ' then
        _, _, model.quantas_in_vars = model.FBType:find('.+%_+(.+)')
        model.quantas_in_vars = tonumber(model.quantas_in_vars)
        setmetatable (model, SIFB_Publ)
    elseif model.Class == 'Subl' then
        setmetatable (model, SIFB_Subl)
    elseif model.Class == 'File_Writer' then
        setmetatable (model, File_Writer)
    end
    
    return model
end

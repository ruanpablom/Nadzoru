require ('Resource')
Device = {}

local split = function ( str )
	local _,_,str1,str2 = str:find('(.+)%.(.+)')	
	return str1, str2
end



Device.importXML = function (root, DeviceType, label)
    local state     = {}
    local model     = {}
    local funcoes   = {}
    local resources = {}
    local Rname     = {}
    local dx        = {}
    local dy        = {} 
    model.label     = label
    
    funcoes [ 'Device' ]  = function ( name, atb)
        model.DeviceType = atb.Name
        model.Class      = 'Device'
    end
    
    funcoes[ 'Resource' ] = function ( name, atb )
        resources[#resources +1] = atb.Type 
        Rname    [#Rname + 1]    = atb.Name
        dx       [#dx+1]         = atb.dx
        dy       [#dy+1]         = atb.dy
        actResource              = atb.Name
        model[atb.Name]         = Resource.importXML (root, atb.Type .. '.xml' , atb.Name)
        model[atb.Name]._Device = model
    end
    
    funcoes[ 'Parameter' ] = function ( name, atb )
        local block, var = split(atb.Name)
        if type(model[actResource].Parameters) ~= 'table' then
            model[actResource].Parameters = {}
        end
        model[actResource].Parameters[#model[actResource].Parameters+1]= {block, var, atb.Value}
        model[actResource][block][var] = string_to_value (atb.Value, model[actResource][block].other.ArraySize2[var], model[actResource][block].other.Type[var])
        LOG_FILE:write('DEVICE---Parameters set on:  '..actResource..'.'..block..'.'..var..' = '.. atb.Value..'\n' )
    end
    --------------------------------------Inicio do parser--------------------------------------------------
    local callbacks = {
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then 
                funcoes[ state[#state] ]( name, atb )
            else 
            end
        end,
        EndElement = function ( parser, name )
        --  io.write(string.rep(" ", count),"- ",  name, "\n")
            state[#state] =nil 
        end
    }

    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
    local file = io.open( root..DeviceType, 'r')
    for l in file:lines() do  -- iterate lines
        p:parse(l)            -- parses the line
        p:parse("\n")         -- parses the end of line

    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    
    model.ResourceList = {}
    for i, v in ipairs (resources) do
        model.ResourceList[#model.ResourceList + 1] = {model[Rname[i]], dx[i], dy[i]}
    end
    return model
end

function Device:exe()
    --Device.r1:exe ('ind', 'Subl')

end


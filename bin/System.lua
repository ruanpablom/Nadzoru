require ('Device')
require ('Resource')
System = {}

local split = function ( str )
    local _,_,str1,str2 = str:find('(.+)%.(.+)')
    return str1, str2
end

function string_to_value (str, ArraySize, tipo)
    local valor 
    if not tonumber(ArraySize) then
        if tipo == 'BOOL' then
            if str =='false' or str == 'FALSE' or str == 'False' or str == '.F. 'then return false
            elseif str =='true' or str == 'True' or str == 'TRUE' or str == '.T.' then return true
            end
        elseif tipo =='REAL' or tipo =='INT' then
            return tonumber(str)
        elseif tipo == 'STRING' then
            return str
        else return '@INVALID'
        end
    else
        if tipo == 'REAL' or tipo == 'INT' then
            valor = {}
            if ArraySize == '1' then
                 _,_,valor[1] =  str:find("%[%s*(.+)%s*%]")
            elseif ArraySize == '2' then
                 _,_,valor[1], valor[2] =  str:find("%[%s*(.+)%s*%,%s*(.+)%s*%]")
            elseif ArraySize == '3' then
                 _,_,valor[1], valor[2], valor[3] =  str:find("%[%s*(.+)%s*%,%s*(.+)%s*%,%s*(.+)%s*%]")
            elseif ArraySize == '4' then
                 _,_,valor[1], valor[2], valor[3], valor[4] =  str:find("%[%s*(.+)%s*%,%s*(.+)%s*%,%s*(.+)%s*%,%s*(.+)%s*%]")
            end
            for i=1, ArraySize do
                valor[i] = tonumber(valor[i])
            end
        elseif tipo == 'STRING'  then
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
    --if type(valor) == 'table' then print(str,valor[1], valor[2], valor[3]) end
    return valor    
    end
end


System.importXML = function (root, SystemType, label)
    local actResource  = " "
    local state        = {}
    local model        = {}
    local funcoes      = {}
    local actDevice    = {}
    local model        = {}
    model.label        = label
    model.DeviceList   = {}
    model._VersionInfo = {}
    model._Parameters  = {}
    
    funcoes['System'] = function (name, atb)
        model.SystemType 		= atb.Name
        model.FBType			= atb.Name
        model.SystemTypeComment = atb.Comment
    end
    ------------------------------------------
    funcoes['Identification'] = function (name, atb)
        model._Standard 		= atb.Standard
    end
    -------------------------------------------
    funcoes['VersionInfo'] = function (name, atb)
        model._VersionInfo 		= {
			Date		 = atb.Date,
			Organization = atb.Organization,
			Author       = atb.Author,
			Version      = atb.Version
        }
    end
    -------------------------------------------
    funcoes['Device'] = function ( name, atb )
        model[atb.Name]          = {
            DeviceType   = atb.Type,
            label        = atb.Name,
            ResourceList = {}
        }
        actDevice                               = atb.Name
        model[actDevice]._System                = model
        model[actDevice]._SystemName            = model.label
        model.DeviceList[#model.DeviceList + 1] = {model[atb.Name], atb.dx or atb.x, atb.dy or atb.y,
			Name    = atb.Name,
			Type    = atb.Type,
			x       = atb.x or atb.dx,
			y       = atb.y or atb.dy,
			Comment = atb.Comment
        }
    end
    -------------------------------------------
    funcoes[ 'Resource' ] = function ( name, atb )
        model[actDevice][atb.Name]             = Resource.importXML (root, atb.Type..'.xml', atb.Name)
        model[actDevice][atb.Name]._Device     = model[actDevice]
        model[actDevice][atb.Name]._DeviceName = actDevice
        actResource 						   = atb.Name
        model[actDevice].ResourceList[#model[actDevice].ResourceList+1] = {model[actDevice][atb.Name], atb.x or atb.dx, atb.y or atb.dy,
			Name    = atb.Name,
			Type    = atb.Type,
			x       = atb.x or atb.dx,
			y       = atb.y or atb.dy,
			Comment = atb.Comment
        }
        
    end
    
    funcoes[ 'Parameter' ] = function ( name, atb )
        local block, var = split(atb.Name)
        if not model._Parameters[actDevice] then
			model._Parameters[actDevice] = {}
		end
		if not model._Parameters[actDevice][actResource] then
			model._Parameters[actDevice][actResource] = {}
		end
        if type(model[actDevice][actResource].Parameters) ~= 'table' then
            model[actDevice][actResource].Parameters = {}
        end
        model._Parameters[actDevice][actResource][#model._Parameters[actDevice][actResource]+1] = {
			Name    = atb.Name,
			Value   = atb.Value,
			Comment = atb.Comment
        }
        
        model[actDevice][actResource].Parameters[#model[actDevice][actResource].Parameters+1]= {block, var, atb.Value}
        --print(actDevice, actResource, block, var)
        model[actDevice][actResource][block][var] = string_to_value (atb.Value, model[actDevice][actResource][block].other.ArraySize2[var], model[actDevice][actResource][block].other.Type[var])
        LOG_FILE:write('SYSTEM---Parameters set on:  '..actResource..'.'..block..'.'..var..' = '.. atb.Value..'\n' )
    end
    local callbacks = {
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then 
                funcoes[ state[#state] ]( name, atb )
            else --LOG_FILE:write('funcao ', name, ' nao encontrada')
            end
        end,
        EndElement = function ( parser, name )
        --  io.write(string.rep(" ", count),"- ",  name, "\n")
            state[#state] =nil 
        end
    }

    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
    local file = io.open( root..SystemType, 'r')
    for l in file:lines() do  -- iterate lines
        p:parse(l)            -- parses the line
        p:parse("\n")         -- parses the end of line

    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    file:close()
    return model
end


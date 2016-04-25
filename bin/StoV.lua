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


local s = string_to_value ('true', false, 'BOOL')
if s then print(type(s)) end


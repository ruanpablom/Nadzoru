require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')



function DrawNetwork (Comp --[[FBlist, inst, origem]])
    local N = 0.8
    local draw_type = 'network'
    --Extrai do CompFB, FBlist, inst e origem
    local FBlist, inst, Origem = {}, {}, {}
    
    if Comp.FBNetwork then
        for i, v in ipairs(Comp.FBNetwork) do
                FBlist[#FBlist + 1 ] = Comp[v[1]]
                inst[#inst + 1 ]     = v[1]
                Origem[#Origem+1]    = {v[2], v[3]}
        end
    end    
    
    function draw_network(widget, cr)
        
        local origem = {}
        local slot   = {}
        local xtreme = {} --xtreme.inito = { posicao[1], posicao[2], slot  } do extremo do fiozinho do evento ou variavel, e o nº do slot em q esta posicionado
        
        -------------------------------------------
        --Conta quantidade de eventos e variáveis
        for j, FB in ipairs(FBlist) do
            
            for i, v in ipairs (Origem) do
                origem[i] = {}
                origem[i][1], origem[i][2] = N*Origem[i][1], N*Origem[i][2]
            end
            local emax, vmax, ein, eout, vin, vout = 0, 0, 0, 0, 0, 0
            xtreme[inst[j]] = {}
        
            for i, v in pairs (FB.flag) do
                if v == 'InputVar' then
                    vin = vin +1
                elseif v == 'OutputVar' then
                    vout = vout + 1
                elseif v == 'InputEvent' then
                    ein = ein +1
                elseif v == 'OutputEvent' then
                    eout = eout +1
                end
            end
            
            FB.VIN  = vin
            FB.EIN  = ein
            FB.EOUT = eout
            FB.VOUT = vout
            
            if vin > vout then
                vmax = vin
            else vmax = vout
            end
            
            if vmax == 0 then vmax = 1 end
            
                FB.VMAX = vmax
            
            if ein > eout then
                emax = ein
            else emax = eout
            end
                
            if emax == 0 then emax = 1 end
                
                FB.EMAX = emax
            --------------------------------------------------------------
                local iactev, iactvar , oactev, oactvar = {}, {}, {}, {} --guarda a posicao para o proximo dado/evento
                
                function add_input_event (label)
                    local pos = {iactev[1], iactev[2] + 20*N}
                    
                    slot.iev = slot.iev + 1
                    xtreme[inst[j]][label] = {pos[1] - 16*N, pos[2], slot.iev}
                    cr:move_to (pos[1] - 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
                    cr:set_source_rgb (0, 0.7, 0)
                    cr:rel_line_to (-15*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                    
                    cr:move_to (pos[1] - 1*N, pos[2])
                    cr:rel_move_to (10*N,5*N)
                    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
                    cr:set_font_size(14*N)
                    cr:show_text(label)
                    
                    iactev[2] = iactev[2] + 40*N
                end
                
                function add_input_var (label)
                    local pos = {iactvar[1], iactvar[2] + 20*N}
                    
                    slot.ivar = slot.ivar + 1
                    xtreme[inst[j]][label] = {pos[1] - 16*N, pos[2], slot.ivar}
                    cr:move_to (pos[1] - 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
                    cr:set_source_rgb (0, 0, 0.7)
                    cr:rel_line_to (-15*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                    
                    cr:move_to (pos[1] - 1*N, pos[2])
                    cr:rel_move_to (10*N,5*N)
                    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
                    cr:set_font_size(14*N)
                    cr:show_text(label)
                    
                    iactvar[2] = iactvar[2] + 40*N
                end
                
                function add_output_event (label)
                    local pos = {oactev[1], oactev[2] + 20*N}
                    
                    slot.oev = slot.oev + 1
                    xtreme[inst[j]][label] = {pos[1] + 16*N, pos[2], slot.oev}
                    cr:move_to (pos[1] + 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
                    cr:set_source_rgb (0, 0.7, 0)
                    cr:rel_line_to (15*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                    
                    cr:move_to (pos[1] + 1*N, pos[2])
                    cr:rel_move_to (-50*N,5*N)
                    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
                    cr:set_font_size(14*N)
                    cr:show_text(label)
                    
                    oactev[2] = oactev[2] + 40*N
                end
                
                function add_output_var (label)
                    local pos = {oactvar[1], oactvar[2] + 20*N}
                    
                    slot.ovar = slot.ovar + 1
                    xtreme[inst[j]][label] = {pos[1] + 16*N, pos[2], slot.ovar} --guarda posicao e posicao do slot
                    cr:move_to (pos[1] + 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
                    cr:set_source_rgb (0, 0, 0.7)
                    cr:rel_line_to (15*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                    
                    cr:move_to (pos[1] + 1*N, pos[2])
                    cr:rel_move_to (-50*N,5*N)
                    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
                    cr:set_font_size(14*N)
                    cr:show_text(label)
                    
                    oactvar[2] = oactvar[2] + 40*N
                end
                
                function add_connection (tipo, si, sd, di, dd)  --source inst, source data, dest inst, dest data
                    local delta = 0
                    if tipo == 'event' then
                        cr:set_source_rgb (0, 0.7, 0)
                        delta = (Comp[si].EOUT + 1 - xtreme[si][sd][3])/Comp[si].EOUT
                    elseif tipo == 'data' then
                    cr:set_source_rgb (0, 0, 0.7)
                        delta = (Comp[si].VOUT + 1 - xtreme[si][sd][3])/Comp[si].VOUT
                    end
                    
                    --1º Caso = Bloco destino à direita e abaixo:
                    if xtreme[di][dd][1] > xtreme[si][sd][1] and xtreme[di][dd][2] >= xtreme[si][sd][2] then
                        cr:move_to(xtreme[si][sd][1], xtreme[si][sd][2])
                        cr:rel_line_to((xtreme[di][dd][1]- xtreme[si][sd][1] )*0.7*delta*N, 0)
                        cr:line_to(xtreme[si][sd][1] + (xtreme[di][dd][1]- xtreme[si][sd][1] )*0.7*delta*N, xtreme[di][dd][2])
                        cr:line_to(xtreme[di][dd][1], xtreme[di][dd][2])
                
                    --2º Caso = Bloco destino à direita e acima:
                    elseif xtreme[di][dd][1] > xtreme[si][sd][1] and xtreme[di][dd][2] < xtreme[si][sd][2] then
                        delta = 1 + (1/Comp[si].EOUT) - delta
                        cr:move_to(xtreme[si][sd][1], xtreme[si][sd][2])
                        cr:rel_line_to((xtreme[di][dd][1]- xtreme[si][sd][1] )*0.7*delta*N, 0)
                        cr:line_to(xtreme[si][sd][1] + (xtreme[di][dd][1]- xtreme[si][sd][1] )*0.7*delta*N, xtreme[di][dd][2])
                        cr:line_to(xtreme[di][dd][1], xtreme[di][dd][2])
                    
                    --3º Caso = Bloco destino à esquerda e abaixo:
                    elseif xtreme[di][dd][1] < xtreme[si][sd][1] and xtreme[di][dd][2] >= xtreme[si][sd][2] then
                        cr:move_to(xtreme[si][sd][1], xtreme[si][sd][2])
                        
                        if tipo == 'event' then
                            delta = (Comp[si].EOUT + Comp[si].VOUT + 1 - xtreme[si][sd][3])/(Comp[si].EOUT + Comp[si].VOUT)
                        else
                            delta = (Comp[si].VOUT + 1 - xtreme[si][sd][3])/(Comp[si].EOUT + Comp[si].VOUT)
                        end
                        
                        local dist_meio = Comp[di].ORIGEM[2] - Comp[si].ORIGEM[2] - 40*Comp[si].EMAX*N - 100/3*N - 40*Comp[si].VMAX*N
                        
                        if tipo == 'event' then 
                            cr:rel_line_to(70*delta*N, 0)
                            cr:rel_line_to(0,( 20 + 40*(Comp[si].EMAX -xtreme[si][sd][3])+100/3)*N)
                            cr:rel_line_to(0, 40*(Comp[si].VMAX)*N)
                            cr:rel_line_to(0, (Comp[di].ORIGEM[2] - Comp[si].ORIGEM[2] - 40*Comp[si].EMAX*N - 100/3*N - 40*Comp[si].VMAX*N)*0.7*delta)
                        else
                            cr:rel_line_to(70*delta*N, 0)
                            cr:rel_line_to(0, (20 + 40*(Comp[si].VMAX -xtreme[si][sd][3]))*N)
                            cr:rel_line_to(0, dist_meio*0.7*delta)
                        end
                            cr:rel_line_to((-140*delta*N - xtreme[si][sd][1] + xtreme [di][dd][1]) ,0)
                            cr:rel_line_to(0 ,((1 -0.7*delta)*dist_meio + 20*N))
                        
                        if tipo == 'event' then
                            cr:rel_line_to(0 , (xtreme[di][dd][3]-1)*40*N) 
                        else
                            cr:rel_line_to(0 , (40 + (Comp[si].EMAX + xtreme[di][dd][3]-2)*40 +100/3)*N) 
                        end
                        --cr:line_to(xtreme[si][sd][1] + (xtreme[di][dd][1]- xtreme[si][sd][1] )*0.7*delta, xtreme[di][dd][2])
                        cr:line_to(xtreme[di][dd][1], xtreme[di][dd][2])
                    end
                    
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                    --print('Conexao '..si..'.'..sd..' to '..di..'.'..dd)                
                end
                
                function comp_connect_in (inst, data)
                    cr:move_to(xtreme[inst][data][1], xtreme[inst][data][2] )
                    cr:set_source_rgb (0.8, 0, 0)
                    cr:rel_line_to (-10*N, -10*N)
                    cr:rel_line_to (0, 10*N)
                    cr:rel_line_to (10*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                end
                
                function comp_connect_out (inst, data)
                    cr:move_to(xtreme[inst][data][1], xtreme[inst][data][2] )
                    cr:set_source_rgb (0.8, 0, 0)
                    cr:rel_line_to (10*N, -10*N)
                    cr:rel_line_to (0, 10*N)
                    cr:rel_line_to (-10*N, 0)
                    cr:stroke()
                    cr:set_source_rgb (0, 0, 0)
                end
                
                
                
                local width, height = widget:get_allocated_size()
                cr = cairo.Context.wrap(cr)
                -- Configuracao da linha (cor, tipo de extremidade, largura)
                cr:set_source_rgb(0 , 0 , 0 )
                cr:set_line_cap(cairo.LINE_CAP_BUTT)
                cr:set_line_width( 2*N )

                -- Inicio do Desenho
                
                FB.ORIGEM = {origem[j][1], origem[j][2]}
                local p1 = {origem[j][1], origem[j][2]}   --ponto onde inicia a cabeça
                local p2 = {origem[j][1], origem[j][2] + 40*emax*N + 30*N} --ponto onde inicia o corpo
                local p3 = {(135 + 7*#FB.FBType)*N + origem[j][1], origem[j][2]}
                local p4 = {(135 + 7*#FB.FBType)*N + origem[j][1], origem[j][2] + 40*emax*N + 30*N}
                
                iactev[1],  iactev[2]  = p1[1], p1[2]
                iactvar[1], iactvar[2] = p2[1], p2[2]
                oactev[1],  oactev[2]  = p3[1], p3[2]
                oactvar[1], oactvar[2] = p4[1], p4[2]
                slot.iev, slot.oev, slot.ivar, slot.ovar = 0, 0, 0, 0
                --iactev, iactvar, oactev, oactvar = p1, p2, p3, p4
                --1) Desenha linha esquerda/vertical da Cabeça
                cr:move_to(origem[j][1] , origem[j][2])
                
                cr:rel_line_to(0, 40*emax*N)
                
                --2) Desenha a Divisao Cabeça/Corpo, esquerda
                cr:rel_line_to(600/18*N, 0)
                cr:rel_line_to(0, 600/18*N)
                cr:rel_line_to(-600/18*N, 0)
                
                --3) Desenha linha esquerda/vertical do Corpo
                cr:rel_line_to(0, 40*vmax*N)
                
                --4) Desenha linha horizontal inferior, baseado no tamanho da string FBType
                cr:rel_line_to((135 + 7*#FB.FBType)*N, 0)
                
                --5) Desenha linha direita/vertical do Corpo
                cr:rel_line_to(0, -40*vmax*N)
                
                --6) Desenha a Divisao Cabeça/Corpo, direita
                cr:rel_line_to(-600/18*N, 0)
                cr:rel_line_to(0, -600/18*N)
                cr:rel_line_to(600/18*N, 0)
                
                --7) Desenha linha direita/vertical da Cabeça
                cr:rel_line_to(0, -40*emax*N)
                
                --8) Desenha linha horizontal superior, baseado no tamanho da string FBType
                cr:rel_line_to(-(135 + 7*#FB.FBType)*N, 0)
                
                --Desenha o bloco
                cr:stroke()
                
                --9) Inserir os Eventos e Variáveis
                for i, v in ipairs(FB.ineventlist) do
                    add_input_event (v)
                end
                
                for i, v in ipairs(FB.outeventlist) do
                    add_output_event (v)
                end
                
                for i, v in ipairs(FB.invarlist) do
                    add_input_var (v)
                end
                
                for i, v in ipairs(FB.outvarlist) do
                    add_output_var (v)
                end
                --[[for i, v in pairs ( FB.flag ) do
                    if v == 'InputEvent' then 
                        add_input_event (i) 
                    elseif v == 'InputVar' then
                        add_input_var (i)
                    elseif v == 'OutputEvent' then
                        add_output_event (i)
                    elseif v == 'OutputVar' then
                        add_output_var (i)
                    end
                end]]
                
                --10) Inserir o tipo do bloco
                cr:move_to (origem[j][1] + ((135 + 7*#FB.FBType)/2 -4.53*#FB.FBType)*N  , origem[j][2] +(50/3 + 40*emax)*N )
                cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                cr:set_font_size(14*N)
                cr:show_text (FB.FBType)
                cr:stroke()
               
                --11) Inserir o nome da Instância do Bloco
                ---------------------------------------------
                cr:move_to (origem[j][1] + ((135 + 7*#FB.FBType)/2 - 4.53*#inst[j])*N  , origem[j][2] -3*N )
                cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                cr:set_font_size(14*N)
                cr:show_text (inst[j])
                cr:stroke()
                
                --12) Inserir "With"
                for i, v in pairs(FB.with) do
                    local delta = 0
                    cr:move_to (xtreme[FB.label][i][1], xtreme[FB.label][i][2] )
                    if FB.flag[i] == 'InputEvent' then
                        delta = 2.2*(FB.EIN + 1 - xtreme[FB.label][i][3])/FB.EIN
                        cr:set_line_width ( 1*N )
                        cr:rel_move_to ( (1+ 4*(2 - delta))*N , -2.5*N )
                        cr:rel_line_to ( 0 , 5*N )
                        cr:rel_line_to ( 5*N , 0 )
                        cr:rel_line_to ( 0 , -5*N )
                        cr:rel_line_to ( -5*N , 0 )
                        cr:stroke()
                        cr:set_line_width ( 2*N )
                    else
                        delta = 2.2*(FB.EOUT + 1 - xtreme[FB.label][i][3])/FB.EOUT
                        cr:set_line_width ( 1*N )
                        cr:rel_move_to ((-1 -4*(2 -delta))*N , -2.5*N )
                        cr:rel_line_to ( 0 , 5*N )
                        cr:rel_line_to ( -5*N , 0 )
                        cr:rel_line_to ( 0 , -5*N )
                        cr:rel_line_to ( 5*N , 0 )
                        cr:stroke()
                        cr:set_line_width ( 2*N )
                    end
                    for j, k in ipairs( v ) do
                        cr:move_to (xtreme[FB.label][k][1], xtreme[FB.label][k][2] )
                        if FB.flag[k] == 'InputVar' then
                            cr:set_line_width ( 1*N )
                            cr:rel_move_to ((1+ 4*(2-delta))*N , -2.5*N )
                            cr:rel_line_to ( 0 , 5*N )
                            cr:rel_line_to ( 5*N , 0 )
                            cr:rel_line_to ( 0 , -5*N )
                            cr:rel_line_to ( -5*N , 0 )
                            cr:move_to (xtreme[FB.label][i][1] + (3.5 + 4*(2-delta))*N , xtreme[FB.label][i][2] +2.5*N )
                            cr:line_to (xtreme[FB.label][k][1] + 3.5*N + 4*(2-delta)*N , xtreme[FB.label][k][2] -2.5*N )
                            cr:stroke()
                            cr:set_line_width ( 2*N )
                            
                        else
                            cr:set_line_width ( 1*N )
                            cr:rel_move_to ((-1 -4*(2-delta))*N , -2.5*N )
                            cr:rel_line_to ( 0 , 5*N )
                            cr:rel_line_to ( -5*N , 0 )
                            cr:rel_line_to ( 0 , -5*N )
                            cr:rel_line_to ( 5*N , 0 )
                            cr:move_to (xtreme[FB.label][i][1] - (3.5 + 4*(2-delta))*N , xtreme[FB.label][i][2] +2.5*N )
                            cr:line_to (xtreme[FB.label][k][1] - 3.5*N - 4*(2-delta)*N , xtreme[FB.label][k][2] -2.5*N )
                            cr:stroke()
                            cr:set_line_width ( 2*N )
                        end
                    end
                end
            end
            
            --13) Inserir Parâmetros
            if Comp.Parameters and nil then
                for i, v in ipairs(Comp.Parameters) do
                    cr:move_to (xtreme[v[1]][v[2]][1], xtreme[v[1]][v[2]][2])
                    if Comp[v[1]].flag[v[2]] == 'InputVar' then
                        cr:rel_move_to (-4.5*#v[3])
                    end
                    cr:set_font_size (12*N)
                    cr:show_text(v[3])
                end
            end
            --14) Inserir Conexões de Evento
            for i, v in pairs (Comp.EventConnections) do
                for j, k in pairs (Comp.EventConnections[i]) do
                    ----print('inst '..i..' event '..j..' destinst '..k[1]..' destevent '..k[2])
                    if i ~= 'self' and k[1] ~='self' then
                        add_connection('event', i, j, k[1], k[2])
                    elseif i == 'self' then
                        comp_connect_in (k[1], k[2])
                    elseif k[1] == 'self' then
                        comp_connect_out (i, j)
                    end
                end
            end
        
            --15) Inserir Conexões de Dados
            for i, v in pairs (Comp.DataConnections) do
                for j, k in pairs (Comp.DataConnections[i]) do
                    ----print('inst '..i..' event '..j..' destinst '..k[1]..' destevent '..k[2])
                    if i ~= 'self' and k[1] ~='self' then
                        add_connection('data', k[1], k[2], i, j)
                    elseif i == 'self' then
                        comp_connect_out (k[1], k[2])
                    elseif k[1] == 'self' then
                        comp_connect_in (i, j)
                    end
                end
            end
        
        return false
    end
    
    function draw_block(widget, cr)
        --conta quantos eventos e variaveis
        
        local slot   = {}
        slot.iev, slot.oev, slot.ivar, slot.ovar = 0, 0, 0, 0
        local xtreme = {}
        local iactev, iactvar, oactev, oactvar = {}, {}, {}, {}
        local vin, vout, ein, eout, vmax, emax = 0, 0, 0, 0, 0, 0
        if Comp.flag ~= nil then 
            for i, v in pairs (Comp.flag) do
                    if v == 'InputVar' then
                        vin = vin +1
                    elseif v == 'OutputVar' then
                        vout = vout + 1
                    elseif v == 'InputEvent' then
                        ein = ein +1
                    elseif v == 'OutputEvent' then
                        eout = eout +1
                    end
            end
        end
        if vin > vout then
            vmax = vin
        else vmax = vout
        end
        
        if vmax == 0 then vmax = 1 end
        
        if ein > eout then
            emax = ein
        else emax = eout
        end
            
        if emax == 0 then emax = 1 
        end
        
        local iactev, iactvar , oactev, oactvar = {}, {}, {}, {} --guarda a posicao para o proximo dado/evento
            
        function add_input_event (label)
            local pos = {iactev[1], iactev[2] + 20*N}
            slot.iev = slot.iev + 1
            xtreme[label] = {pos[1] - 16*N, pos[2], slot.iev}
            cr:move_to (pos[1] - 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0.7, 0)
            cr:rel_line_to (-15*N, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] - 1*N, pos[2])
            cr:rel_move_to (10*N,5*N)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*N)
            cr:show_text(label)
            
            iactev[2] = iactev[2] + 40*N
        end
        
        function add_input_var (label)
            local pos = {iactvar[1], iactvar[2] + 20*N}
            slot.ivar = slot.ivar + 1
            xtreme[label] = {pos[1] - 16*N, pos[2], slot.ivar}
            cr:move_to (pos[1] - 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0, 0.7)
            cr:rel_line_to (-15*N, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] - 1*N, pos[2])
            cr:rel_move_to (10*N,5*N)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*N)
            cr:show_text(label)
            
            iactvar[2] = iactvar[2] + 40*N
        end
        
        function add_output_event (label)
            local pos = {oactev[1], oactev[2] + 20*N}
            slot.oev = slot.oev + 1
            xtreme[label] = {pos[1] + 16*N, pos[2], slot.oev}
            cr:move_to (pos[1] + 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0.7, 0)
            cr:rel_line_to (15*N, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
                
            cr:move_to (pos[1] + 1*N, pos[2])
            cr:rel_move_to (-50*N,5*N)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*N)
            cr:show_text(label)
            
            oactev[2] = oactev[2] + 40*N
        end
            
        function add_output_var (label)
            local pos = {oactvar[1], oactvar[2] + 20*N}
            slot.ovar = slot.ovar + 1
            xtreme[label] = {pos[1] + 16*N, pos[2], slot.ovar}
            cr:move_to (pos[1] + 1*N, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0, 0.7)
            cr:rel_line_to (15*N, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] + 1*N, pos[2])
            cr:rel_move_to (-50*N,5*N)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*N)
            cr:show_text(label)
            
            oactvar[2] = oactvar[2] + 40*N
        end
        
        cr = cairo.Context.wrap(cr)
        -- Configuracao da linha (cor, tipo de extremidade, largura)
        cr:set_source_rgb(0 , 0 , 0 )
        cr:set_line_cap(cairo.LINE_CAP_BUTT)
        cr:set_line_width( 2*N )

        -- Inicio do Desenho
        local origem = {450, 150}
        local p1 = {origem[1], origem[2]}   --ponto onde inicia a cabeça
        local p2 = {origem[1], origem[2] + 40*emax*N + 30*N} --ponto onde inicia o corpo
        local p3 = {(135 + 7*#Comp.FBType)*N + origem[1], origem[2]}
        local p4 = {(135 + 7*#Comp.FBType)*N + origem[1], origem[2] + 40*emax*N + 30*N}
        
        iactev[1],  iactev[2]  = p1[1], p1[2]
        iactvar[1], iactvar[2] = p2[1], p2[2]
        oactev[1],  oactev[2]  = p3[1], p3[2]
        oactvar[1], oactvar[2] = p4[1], p4[2]
    
        --iactev, iactvar, oactev, oactvar = p1, p2, p3, p4
        --1) Desenha linha esquerda/vertical da Cabeça
        
        cr:move_to(origem[1], origem[2])
        cr:rel_line_to(0, 40*emax*N)
        
        --2) Desenha a Divisao Cabeça/Corpo, esquerda
        cr:rel_line_to(600/18*N, 0)
        cr:rel_line_to(0, 600/18*N)
        cr:rel_line_to(-600/18*N, 0)
        
        --3) Desenha linha esquerda/vertical do Corpo
        cr:rel_line_to(0, 40*vmax*N)
        
        --4) Desenha linha horizontal inferior, baseado no tamanho da string FBType
        cr:rel_line_to((135 + 7*#Comp.FBType)*N, 0)
        
        --5) Desenha linha direita/vertical do Corpo
        cr:rel_line_to(0, -40*vmax*N)
        
        --6) Desenha a Divisao Cabeça/Corpo, direita
        cr:rel_line_to(-600/18*N, 0)
        cr:rel_line_to(0, -600/18*N)
        cr:rel_line_to(600/18*N, 0)
        
        --7) Desenha linha direita/vertical da Cabeça
        cr:rel_line_to(0, -40*emax*N)
        
        --8) Desenha linha horizontal superior, baseado no tamanho da string FBType
        cr:rel_line_to(-(135 + 7*#Comp.FBType)*N, 0)
        
        --Desenha o bloco
        cr:stroke()
        
        --9) Inserir os Eventos e Variáveis
        if Comp.ineventlist then    
            for i, v in ipairs(Comp.ineventlist) do
                add_input_event (v)
            end
        end    
        if Comp.outeventlist then    
            for i, v in ipairs(Comp.outeventlist) do
                add_output_event (v)
            end
        end
        if Comp.invarlist then    
            for i, v in ipairs(Comp.invarlist) do
                add_input_var (v)
            end
        end
        if Comp.outvarlist then       
            for i, v in ipairs(Comp.outvarlist) do
                add_output_var (v)
            end
        end
        --10) Inserir o tipo do bloco
        cr:move_to (origem[1] + ((135 + 7*#Comp.FBType)/2 -4.53*#Comp.FBType)*N  , origem[2] +(50/3 + 40*emax)*N )
        cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        cr:set_font_size(14*N)
        cr:show_text (Comp.FBType)
        cr:stroke()
        
        --11) Inserir o nome da Instância do Bloco
        ---------------------------------------------
        cr:move_to (origem[1] + ((135 + 7*#Comp.FBType)/2 - 4.53*#Comp.label)*N  , origem[2] -3*N )
        cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        cr:set_font_size(14*N)
        cr:show_text (Comp.label)
        cr:stroke()
        
        --12) Inserir "With"
        for i, v in pairs(Comp.with) do
            local delta = 0
            cr:move_to (xtreme[i][1], xtreme[i][2] )
            if Comp.flag[i] == 'InputEvent' then
                delta = 2.2*(ein + 1 - xtreme[i][3])/ein
                cr:set_line_width ( 1*N )
                cr:rel_move_to ( (1+ 4*(2 - delta))*N , -2.5*N )
                cr:rel_line_to ( 0 , 5*N )
                cr:rel_line_to ( 5*N , 0 )
                cr:rel_line_to ( 0 , -5*N )
                cr:rel_line_to ( -5*N , 0 )
                cr:stroke()
                cr:set_line_width ( 2*N )
            else
                delta = 2.2*(eout + 1 - xtreme[i][3])/eout
                cr:set_line_width ( 1*N )
                cr:rel_move_to ((-1 -4*(2 -delta))*N , -2.5*N )
                cr:rel_line_to ( 0 , 5*N )
                cr:rel_line_to ( -5*N , 0 )
                cr:rel_line_to ( 0 , -5*N )
                cr:rel_line_to ( 5*N , 0 )
                cr:stroke()
                cr:set_line_width ( 2*N )
            end
            for j, k in ipairs( v ) do
                cr:move_to (xtreme[k][1], xtreme[k][2]) 
                if Comp.flag[k] == 'InputVar' then
                    cr:set_line_width ( 1*N )
                    cr:rel_move_to ((1+ 4*(2-delta))*N , -2.5*N )
                    cr:rel_line_to ( 0 , 5*N )
                    cr:rel_line_to ( 5*N , 0 )
                    cr:rel_line_to ( 0 , -5*N )
                    cr:rel_line_to ( -5*N , 0 )
                    cr:move_to (xtreme[i][1] + (3.5 + 4*(2-delta))*N , xtreme[i][2] +2.5*N )
                    cr:line_to (xtreme[k][1] + 3.5*N + 4*(2-delta)*N , xtreme[k][2] -2.5*N )
                    cr:stroke()
                    cr:set_line_width ( 2*N )
                    
                else
                    cr:set_line_width ( 1*N )
                    cr:rel_move_to ((-1 -4*(2-delta))*N , -2.5*N )
                    cr:rel_line_to ( 0 , 5*N )
                    cr:rel_line_to ( -5*N , 0 )
                    cr:rel_line_to ( 0 , -5*N )
                    cr:rel_line_to ( 5*N , 0 )
                    cr:move_to (xtreme[i][1] - (3.5 + 4*(2-delta))*N , xtreme[i][2] +2.5*N )
                    cr:line_to (xtreme[k][1] - 3.5*N - 4*(2-delta)*N , xtreme[k][2] -2.5*N )
                    cr:stroke()
                    cr:set_line_width ( 2*N )
                end
            end
        end
    end
    
    function draw(widget, cr)
        if draw_type == 'network' then
            draw_network(widget, cr)
        elseif draw_type == 'block' then
            draw_block(widget, cr)
        end
    end
    
    
    
    --Containers
    local window   = gtk.Window.new()
    local main_box = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5)
    local area     = gtk.DrawingArea.new()
    local hbox1    = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    local hbox2    = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    local hbox11   = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    local hbox12   = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    
    local x, y = 0 , 0  --para salvar a configuração inicial
    local ZoomIn = function()
        N = N + 0.05
        for i, v in ipairs(Origem) do
            v[1] = v[1] - 5
        end
        x = x - 5
        area:queue_draw()
    end
    local ZoomOut = function()
        N = N - 0.05
        for i, v in ipairs(Origem) do
            v[1] = v[1] + 5
        end
        x = x + 5
        area:queue_draw()
    end
    local GoBack = function()
        for i, v in ipairs(Origem) do
            v[1] = v[1] - 10
        end
        x = x - 10
        area:queue_draw()
    end
    local GoForward = function()
        for i, v in ipairs(Origem) do
            v[1] = v[1] + 10
        end
        x = x + 10
        area:queue_draw()
    end
    local GoUp = function()
        for i, v in ipairs(Origem) do
            v[2] = v[2] -10
        end
        y = y - 10
        area:queue_draw()
    end
    local GoDown = function()
        for i, v in ipairs(Origem) do
            v[2] = v[2] + 10
        end
        y = y + 10
        area:queue_draw()
    end
    
    local Reset = function()
        for i, v in ipairs(Origem) do
            v[1] = v[1] - x
            v[2] = v[2] - y
        end
        x = 0
        y = 0
        N = 0.8
        area:queue_draw()
    end
    --toolbar:
    local toolbar  = gtk.Toolbar.new()
    toolbar:set("toolbar-style", gtk.TOOLBAR_ICONS)
    toolbar:set('height-request', 40)
    --toolbar itens => toolbuttons
    local toolbutton1 = gtk.ToolButton.new() --zoom in
    toolbutton1:set('stock-id', 'gtk-zoom-in')
    toolbutton1:connect ('clicked', ZoomIn)
    local toolbutton2 = gtk.ToolButton.new() --zoom out
    toolbutton2:set('stock-id', 'gtk-zoom-out')
    toolbutton2:connect ('clicked', ZoomOut)
    local toolbutton3 = gtk.ToolButton.new() --deslocar à direita
    toolbutton3:set('stock-id', 'gtk-go-back')
    toolbutton3:connect ('clicked', GoBack)
    local toolbutton4 = gtk.ToolButton.new() --deslocar à direita
    toolbutton4:set('stock-id', 'gtk-go-forward')
    toolbutton4:connect ('clicked', GoForward)
    local toolbutton5 = gtk.ToolButton.new() --deslocar à direita
    toolbutton5:set('stock-id', 'gtk-go-up')
    toolbutton5:connect ('clicked', GoUp)
    local toolbutton6 = gtk.ToolButton.new() --deslocar à direita
    toolbutton6:set('stock-id', 'gtk-go-down')
    toolbutton6:connect ('clicked', GoDown)
    local toolbutton7 = gtk.ToolButton.new() --reset
    toolbutton7:set('stock-id', 'gtk-refresh')
    toolbutton7:connect ('clicked', Reset)
    
    --Toolbar itens => separators
    local sep1 = gtk.SeparatorToolItem.new()
    local sep2 = gtk.SeparatorToolItem.new()
    local sep3 = gtk.SeparatorToolItem.new()
    
    ---radio buttons
    local radio1 =  gtk.RadioToolButton.new_from_stock(false, 'gtk-preferences')
    radio1:set('label', 'Network')
    local radio2 =  gtk.RadioToolButton.new_with_stock_from_widget(radio1, 'gtk-orientation-landscape')
    function RADIO()
        if radio1:get_active() then
            draw_type = 'network'
        elseif radio2:get_active() then
            draw_type = 'block'
        end
        area:queue_draw()
    end
    radio1:connect('toggled', RADIO)
    radio2:connect('toggled', RADIO)
   
    --packing
    toolbar:add(toolbutton1, toolbutton2, sep1, toolbutton3, toolbutton4, toolbutton5, toolbutton6, sep2, radio1, radio2, sep3, toolbutton7)
    hbox1:pack_start(toolbar, true, true, 0)
    hbox2:pack_start(area, true, true , 0)
    main_box:pack_start(hbox1, false, false, 0)
    main_box:pack_end(hbox2, true, true, 0)
    window:set('default-width', 1000, 'default-height', 650)
    --window:add(toolbar)
    window:add(main_box)
    window:set('title', "FB Viewer", 'window-position', gtk.WIN_POS_CENTER)
    window:show_all()
    
    window:connect('delete-event', gtk.main_quit)
    area:connect('draw', draw, area)
    
    gtk.main()
end

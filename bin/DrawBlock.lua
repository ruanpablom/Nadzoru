require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')

function DrawBlock (FB)
    local origem = {150, 100}
    local inst = FB.label
    local nh, nv --normalizações
    local emax, vmax, ein, eout, vin, vout = 0, 0, 0, 0, 0, 0
    
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
    
    if vin > vout then
        vmax = vin
    else vmax = vout
    end
    
    if ein > eout then
        emax = ein
    else emax = eout
    end
    
    function draw(widget, cr)
        local iactev, iactvar , oactev, oactvar = {}, {}, {}, {}
        nh, nv = widget:get_allocated_size()
        nh , nv = nh/600, nv/600
        function add_input_event (label)
            local pos = {iactev[1], iactev[2] + 20*nv}
            
            cr:move_to (pos[1] - 1*nh, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0.7, 0)
            cr:rel_line_to (-15*nh, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] - 1*nh, pos[2])
            cr:rel_move_to (10*nh,5*nv)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*math.sqrt(nh*nv))
            cr:show_text(label)
            
            iactev[2] = iactev[2] + 40*nv
        end
        
        function add_input_var (label)
            local pos = {iactvar[1], iactvar[2] + 20*nv}
            
            cr:move_to (pos[1] - 1*nh, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0, 0.7)
            cr:rel_line_to (-15*nh, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] - 1*nh, pos[2])
            cr:rel_move_to (10*nh,5*nv)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*math.sqrt(nh*nv))
            cr:show_text(label)
            
            iactvar[2] = iactvar[2] + 40*nv
        end
        
        function add_output_event (label)
            local pos = {oactev[1], oactev[2] + 20*nv}
            
            cr:move_to (pos[1] + 1*nh, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0.7, 0)
            cr:rel_line_to (15*nh, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] + 1*nh, pos[2])
            cr:rel_move_to (-50*nh,5*nv)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*math.sqrt(nh*nv))
            cr:show_text(label)
            
            oactev[2] = oactev[2] + 40*nv
        end
        
        function add_output_var (label)
            local pos = {oactvar[1], oactvar[2] + 20*nv}
            
            cr:move_to (pos[1] + 1*nh, pos[2])  --  -1 para nao desenhar por cima do bloco
            cr:set_source_rgb (0, 0, 0.7)
            cr:rel_line_to (15*nh, 0)
            cr:stroke()
            cr:set_source_rgb (0, 0, 0)
            
            cr:move_to (pos[1] + 1*nh, pos[2])
            cr:rel_move_to (-50*nh,5*nv)
            cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
            cr:set_font_size(14*math.sqrt(nh*nv))
            cr:show_text(label)
            
            oactvar[2] = oactvar[2] + 40*nv
        end
        
        local width, height = widget:get_allocated_size()
        cr = cairo.Context.wrap(cr)
        -- Configuracao da linha (cor, tipo de extremidade, largura)
        cr:set_source_rgb(0, 0, 0)
        cr:set_line_cap(cairo.LINE_CAP_BUTT)
        cr:set_line_width(2*math.sqrt(nh*nv))

        -- Inicio do Desenho

        --local origem = {60, 60}
        local p1 = {origem[1]*nh, origem[2]*nv}   --ponto onde inicia a cabeça
        local p2 = {origem[1]*nh, (origem[2] + 40*emax + 30)*nv} --ponto onde inicia o corpo
        local p3 = {((135 + 7*#FB.FBType) + origem[1])*nh, origem[2]*nv}
        local p4 = {((135 + 7*#FB.FBType) + origem[1])*nh, (origem[2] + 40*emax + 30)*nv}
        
        iactev[1],  iactev[2]  = p1[1], p1[2]
        iactvar[1], iactvar[2] = p2[1], p2[2]
        oactev[1],  oactev[2]  = p3[1], p3[2]
        oactvar[1], oactvar[2] = p4[1], p4[2]
        --iactev, iactvar, oactev, oactvar = p1, p2, p3, p4
        --1) Desenha linha esquerda/vertical da Cabeça
        cr:move_to(origem[1]*nh , origem[2]*nv)
        
        cr:rel_line_to(0, 40*emax*nv)
        
        --2) Desenha a Divisao Cabeça/Corpo, esquerda
        cr:rel_line_to(600/18*nh, 0)
        cr:rel_line_to(0, 600/18*nv)
        cr:rel_line_to(-600/18*nh, 0)
        
        --3) Desenha linha esquerda/vertical do Corpo
        cr:rel_line_to(0, 40*vmax*nv)
        
        --4) Desenha linha horizontal inferior, baseado no tamanho da string FBType
        cr:rel_line_to((135 + 7*#FB.FBType)*nh, 0)
        
        --5) Desenha linha direita/vertical do Corpo
        cr:rel_line_to(0, -40*vmax*nv)
        
        --6) Desenha a Divisao Cabeça/Corpo, direita
        cr:rel_line_to(-600/18*nh, 0)
        cr:rel_line_to(0, -600/18*nv)
        cr:rel_line_to(600/18*nh, 0)
        
        --7) Desenha linha direita/vertical da Cabeça
        cr:rel_line_to(0, -40*emax*nv)
        
        --8) Desenha linha horizontal superior, baseado no tamanho da string FBType
        cr:rel_line_to(-(135 + 7*#FB.FBType)*nh, 0)
        
        --Desenha o bloco
        cr:stroke()
        
        --9) Inserir os Eventos e Variáveis
        for i, v in pairs ( FB.flag ) do
            if v == 'InputEvent' then 
                add_input_event (i) 
            elseif v == 'InputVar' then
                add_input_var (i)
            elseif v == 'OutputEvent' then
                add_output_event (i)
            elseif v == 'OutputVar' then
                add_output_var (i)
            end
        end
        
        --10) Inserir o tipo do bloco
        cr:move_to ((origem[1] + (135 + 7*#FB.FBType)/2 -4.53*#FB.FBType )*nh , (origem[2] +50/3 + 40*emax)*nv )
        cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        cr:set_font_size(14*math.sqrt(nh*nv))
        cr:show_text (FB.FBType)
        cr:stroke()
       
       --11) Inserir o nome da Instância do Bloco
        ---------------------------------------------
        cr:move_to ((origem[1] + (135 + 7*#FB.FBType)/2 - 4.53*#inst)*nh  , (origem[2] -15)*nv )
        cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        cr:set_font_size(14*math.sqrt(nh*nv))
        cr:show_text (inst)
        cr:stroke()
        
        return false
    end


    local window = gtk.Window.new()
    local area   = gtk.DrawingArea.new()
    window:set('default-width', 600, 'default-height', 600)
    window:add(area)
    window:set('title', "FB Viewer", 'window-position', gtk.WIN_POS_CENTER)
    window:show_all()

    window:connect('delete-event', gtk.main_quit)
    area:connect('draw', draw, area)

    gtk.main()
end

function FBViewerLOAD(self)
    local LOAD
    local StructType
    local open_dialog = gtk.FileChooserDialog.new('Load a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-open', gtk.RESPONSE_OK)
    local file_name
    
    --~ 1º passo - Identificar a Estrutura Raiz
    if (open_dialog:run() == gtk.RESPONSE_OK) then
        file_name 		= open_dialog:get_filenames()
        file_name       = file_name[1]
        dofile(file_name)
        f(self)
        self.Drawing_Area:queue_draw()
        
        --~ LOAD      = io.open(file_name, 'r') 
        --~ local i         = 0
        --~ for l in LOAD:lines() do
            --~ i = i + 1
            --~ if i == 1 then
                --~ self.Library = l
            --~ elseif i == 2 then
                --~ self._File   = l
            --~ elseif i == 3 then
                --~ StructType   = l
            --~ else break
            --~ end
        --~ end
        --~ LOAD:close()
    end
    
    --~ --2º Passo - Importar a Estrutura
    --~ if StructType == 'BlockView' or StructType == 'CompView' then
        --~ ImportFB()
    --~ elseif StructType == 'ResourceView' then
        --~ ImportResource()
    --~ elseif StructType == 'DeviceView' then
        --~ ImportDevice()
    --~ elseif StructType == 'SystemView' then
        --~ ImportSystem()
    --~ end
    --~ 
    --~ --3º Passo - Carregar as Posições
    --~ LOAD      = io.open(file_name, 'r')
    --~ local i = 0
    --~ for l in LOAD:lines() do
        --~ i = i +1
        --~ if (i ~= 1) and (i ~= 2) and (i ~= 3) then 
            --~ if i == 4 then
                --~ local x, y                   = select(3, l:find('.+%s+(.+)%s+(.+)'))
                --~ x, y                         = tonumber(x), tonumber(y)
                --~ self.Struct.ORIGEM           = {x, y}
                --~ self.Struct.X, self.Struct.Y = x, y
                --~ self.Struct:MOVE(self.Drawing_Area, true, false)
            --~ else
                --~ 
            --~ end
        --~ end
        --~ 
            --~ 
    --~ end
    --~ LOAD:close()
    open_dialog:hide()
end

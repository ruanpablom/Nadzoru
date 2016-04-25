function FBViewerSAVE(self)
        if self._File then
            local file_name   = string.gsub(self._File, '.xml', '.fbv')
            local save_dialog = gtk.FileChooserDialog.new('Save a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-save', gtk.RESPONSE_OK)
            if (save_dialog:run() == gtk.RESPONSE_OK) then
                dir        = save_dialog:get_filenames()
                file_name  = dir[1]..'/'..file_name
                local SAVE = io.open(file_name, 'w')
                
                
                --~ percorre a árvore até o topo -> struct recebe a primeira estrutura
                local struct
                if self.Struct.UPPER then
                    struct = self.Struct.UPPER
                    while true do
                        if struct.UPPER then
                            struct = struct.UPPER
                        else
                            break
                        end
                    end
                else struct = self.Struct
                end
                
                --Escrita do arquivo de configuração
                SAVE:write("f = function(self)\n")
                SAVE:write("self.Library = '"..self.Library.."'\n")
                SAVE:write("self._File= '"..self._File.."'\n")
                local tipo = string.gsub(struct._Type, 'View', '')
                tipo = tipo:gsub('Comp', 'FB')
                tipo = tipo:gsub('Block', 'FB')
                SAVE:write('Import'..tipo..'()'..'\n')
                SAVE:write('self.Struct.ORIGEM= {'..struct.ORIGEM[1] ..', '.. struct.ORIGEM[2]..'}\n')
                SAVE:write('self.Struct.X= '..struct.ORIGEM[1]..'\n')
                SAVE:write('self.Struct.Y= '..struct.ORIGEM[2]..'\n')
                SAVE:write('self.Struct:MOVE(self.Drawing_Area, true)\n')
                
                local function BlockSAVE(struct)
                    if type(struct.ECC) == 'table' then
                        for i, v in ipairs(struct.ECC.STATE_LIST) do
                            local str = ".ECC['"..v.NAME.."']"
                            local parent = struct
                            while parent do
                                if parent.UPPER then
                                    str = "['"..parent.NAME.."']"..str
                                end
                                parent = parent.UPPER
                            end
                            SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                            SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                            SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                            SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                        end
                    end
                end
                
                local function CompSAVE(struct)
                    for i, v in ipairs(struct.BLOCKS) do
                        local str = "['"..v.NAME.."']"
                        local parent = struct
                        while parent do
                            if parent.UPPER then
                                str = "['"..parent.NAME.."']"..str
                            end
                            parent = parent.UPPER
                        end
                        if v_Type == 'CompView' then
                            SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                            SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                            SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                            SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                            CompSAVE(v)            
                        else                       
                            SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                            SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                            SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                            SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                            BlockSAVE(v)
                        end
                    end
                end
                
                local function ResourceSAVE(struct)
                    for i, v in ipairs(struct.BLOCKS) do
                        local str = "['"..v.NAME.."']"
                        local parent = struct
                        while parent do
                            if parent.UPPER then
                                str = "['"..parent.NAME.."']"..str
                            end
                            parent = parent.UPPER
                        end
                        if v_Type == 'CompView' then
                            SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                            SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                            SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                            SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                            CompSAVE(v)            
                        else                       
                            SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                            SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                            SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                            SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                            BlockSAVE(v)
                        end
                    end
                end
                
                local function DeviceSAVE(struct)
                    for i, v in ipairs(struct.BLOCKS) do
                        local str = "['"..v.NAME.."']"
                        local parent = struct
                        while parent do
                            if parent.UPPER then
                                str = "['"..parent.NAME.."']"..str
                            end
                            parent = parent.UPPER
                        end
                        SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                        SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                        SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                        SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                        ResourceSAVE(v)
                    end
                end
                
                local function SystemSAVE(struct)
                    for i, v in ipairs(struct.BLOCKS) do
                        local str = "['"..v.NAME.."']"
                        local parent = struct
                        while parent do
                            if parent.UPPER then
                                str = "['"..parent.NAME.."']"..str
                            end
                            parent = parent.UPPER
                        end
                        SAVE:write('self.Struct'..str..'.ORIGEM= {'..v.ORIGEM[1]..' ,'..v.ORIGEM[2]..'}\n')
                        SAVE:write('self.Struct'..str..'.X= '..v.ORIGEM[1]..'\n')
                        SAVE:write('self.Struct'..str..'.Y= '..v.ORIGEM[2]..'\n')
                        SAVE:write('self.Struct'..str..':MOVE(self.Drawing_Area, true)\n')
                        DeviceSAVE(v)
                    end
                end
                
                --~ 1º caso -> struct é um BlockView
                if struct._Type == 'BlockView' and type(struct.ECC) == 'table' then
                    BlockSAVE(struct)
                end
                
                --~ 2º caso -> struct é um CompView
                if struct._Type == 'CompView' then
                    CompSAVE(struct)
                end
                
                --~ 3º caso -> struct é um ResourceView
                if struct._Type == 'ResourceView' then
                    ResourceSAVE(struct)
                end
                
                --~ 4º caso -> struct é um DeviceView
                if struct._Type == 'DeviceView' then
                    DeviceSAVE(struct)
                end
                
                --~ 5º caso -> struct é um SystemView
                if struct._Type == 'SystemView' then
                    SystemSAVE(struct)
                end
                SAVE:write("end")
                SAVE:close()
            end
            save_dialog:hide()
        end
    end

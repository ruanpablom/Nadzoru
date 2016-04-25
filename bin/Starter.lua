require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')

Starter = {
    event = 'start',
    _Functionality = 'Starter'
}


function Starter:exe( override )
    LOG_FILE:write('Starter--- '..self.label..' initialized\n')
    if( override == 1 ) then
        LOG_FILE   = io.open('LOG_FILE', 'w')
        COEF_FILE  = io.open('COEF_FILE', 'w')
        GEOM_FILE  = io.open('GEOM_FILE', 'w')
        GEOM_FILE:write( "equations = {\n" )
        LOG_FILE:write('Starter--- '..self.label..' execution completed\n')
        LOG_FILE:write('Starter--- '..self.label .. ' returned event: '..self.event ..'\n')
        self._Resource:exe(self.event, self.label)

        LOG_FILE:write('\n\nEXECUTION COMPLETED \n\n\n')
        LOG_FILE:flush()
        COEF_FILE:flush()
        GEOM_FILE:flush()
        print('**execution completed**')
    else
        local answer = 'n'
        local win    = gtk.Window.new()
        win:set_position(gtk.WIN_POS_CENTER)
        win:set('default-height', 50, 'default-width', 50)
        win:connect('delete-event', function ()
                                        win:hide()
                                    end
        )
        local box    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
        local button = gtk.Button.new_with_label('START')
        local flag = -1
        function exe_start()
            flag = -flag
            if flag == 1 then
                LOG_FILE   = io.open('LOG_FILE', 'w')
                COEF_FILE  = io.open('COEF_FILE', 'w')
                GEOM_FILE  = io.open('GEOM_FILE', 'w')
                GEOM_FILE:write( "equations = {\n" )
                LOG_FILE:write('Starter--- '..self.label..' execution completed\n')
                LOG_FILE:write('Starter--- '..self.label .. ' returned event: '..self.event ..'\n')
                self._Resource:exe(self.event, self.label)

                LOG_FILE:write('\n\nEXECUTION COMPLETED \n\n\n')
                LOG_FILE:flush()
                COEF_FILE:flush()
                --GEOM_FILE:flush()
                print('**execution completed**')
            end
            button:set('label', 'Execution Ok\n Click to Exit')
            if flag == -1 then
                win:hide()
            end

        end

        button:connect('clicked', exe_start)
        box:add(button)
        win:add(box)
        win:show_all()
    end

    --~ io.write('Start resource--- '..self._ResourceName..'?'.. '(y/n)')
    --~ local answer = io.read('*l')

end

Starter.__index = Starter

SIFB_Class.Starter = Starter

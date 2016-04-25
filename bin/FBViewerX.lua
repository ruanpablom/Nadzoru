N = 1

require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')
require('System')
require('ResourceView')
require('BlockView')
require('CompView')
require('ECCView')
require('DeviceView')
require('SystemView')
require('GASR_Compiler')
require('FBViewerSAVE')
require('FBViewerLOAD')

local n_blocks = 0

local function clone( t, deep )
    local r = {}
    for k, v in pairs( t ) do
        if deep and type( v ) == 'table'
            then r[ k ] = clone( v, false )
            else r[ k ] = v
            end
    end
    return r
end


ApStructs  = {}
Edit_Lines = false

struct = ""
local handler_id
click_flag = false
local drawing_type = 'closed'
FBViewer = {}

FBViewer.MOVE = function (widget)
    for i, v in ipairs (ApStructs) do
        if v:MOVE(widget) then
            v.DRAGGED = true
        end
    end
    
end

FBViewer.CLICK = function (widget)

    if not click_flag then
        handler_id  = widget:connect('motion-notify-event', FBViewer.MOVE, widget)
        
        local selected
        for i = #ApStructs, 1, -1   do
            if ApStructs[i]:get_clicked (widget) then 
                selected = i
                break 
            end
        end
        for i, v in ipairs (ApStructs) do
            v.DRAGGED = false
            if i ~= selected then
                v.CORPO.CLICKED = false
            end
        end
    end
  
        click_flag = true

end

FBViewer.RELEASE = function (widget)

    click_flag = false
    --~ handler_id  = widget:connect('motion-notify-event', FBViewer.MOVE, widget)
    widget:disconnect(handler_id)
    for i, v in ipairs (ApStructs) do
        if v.DRAGGED  then
            v.CORPO.CLICKED = false
        end
    end
    widget:queue_draw()
end

FBViewer.__index = FBViewer


function FBViewer.new(self)
    
    local self = {}
    self.Library = " "
    self.File    = " "
    --funcao de desenho
    --~ self.PrimalStructure = {}
    self.Draw = function (widget, cr)
        cr = cairo.Context.wrap(cr)
        if self.Struct ~= 'Empty' and self.Struct ~=nil then
            self.Struct:draw(widget, cr)
            for i = 1, n_blocks do
                self.Combo:remove()
            end
            n_blocks = 0
            if self.Struct.BLOCKS then
                for i, v in ipairs(self.Struct.BLOCKS) do
                    self.Combo:insert_text(i,v.INSTANCIA.NAME)
                    n_blocks = n_blocks+1
                end
            end
        end
    end
    
    --Main_Window
    self.Main_Window = gtk.Window.new()
    self.Main_Window:connect('delete-event', gtk.main_quit)
    self.Main_Window:set('title', "GASR FB-Viewer", 'window-position', gtk.WIN_POS_CENTER)
    self.Main_Window:set('default-width', 1270, 'default-height', 750)
    --Main_Box
    self.Main_Box  = gtk.Box.new( gtk.ORIENTATION_VERTICAL, 0 )
    
    --Horizontal_Box (top/toolbar)  -- HBox1
    self.HBox1 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL, 5)
    
    --toolbar
    self.Toolbar = gtk.Toolbar.new()
    self.Toolbar:set("toolbar-style", gtk.TOOLBAR_ICONS)
    self.Toolbar:set('height-request', 40)
    --toolbar itens
    --toolbar itens => toolbuttons
    function ZoomIn(widget)
        N = N*1.05
        self.Drawing_Area:queue_draw()
    end
    
    function ZoomOut(widget)
        N = N/1.05
        self.Drawing_Area:queue_draw()
    end
    
    local function GoBack()
        --print(self.Struct.UPPER)
		--if self.Struct.DrawType then
        if self.Struct ~= 'Empty' and self.Struct then    
			if self.Struct.UPPER then
                self.Struct.DrawType = 'closed'
                self.Struct = self.Struct.UPPER
            end
            for i, v in ipairs (ApStructs) do
                v.CORPO.CLICKED = false
            end
            ApStructs = nil ApStructs = {}
            self.Drawing_Area:queue_draw()
        end
    end
    local function GoForward()
            local str = self.Combo:get_active_text()
			if str ~= nil then
				self.Struct = self.Struct[str]
          
				ApStructs = nil ApStructs = {}
				self.Drawing_Area:queue_draw()
			end

    end
    
    
    function Edit()
        Edit_Lines = not Edit_Lines
        self.Drawing_Area:queue_draw()
    end
    
    local function Reset()
        N = 1
        self.Drawing_Area:queue_draw()
    end
    
    local function OpenStruct()
        if self.Struct ~= 'Empty' then
            self.Struct.DrawType = 'open'
            self.Drawing_Area:queue_draw()
        end
    end
    
    local function CloseStruct()
        --(self.Struct)
		if self.Struct ~= 'Empty' and self.Struct ~=nil then
            self.Struct.DrawType = 'closed'
            self.Drawing_Area:queue_draw()
        end
    end
	
	local function Start()   --Funcao provisória para apresentação
		if(self.Struct.INSTANCIA.NAME=="System") then
			self.Struct['RTE_Lua']['STEP-NC_DATA1']['START_WORK']._Functionality()
		elseif (self.Struct.INSTANCIA.NAME=="RTE_Lua") then
			self.Struct['STEP-NC_DATA1']['START_WORK']._Functionality()
		elseif (self.Struct.INSTANCIA.NAME=="STEP-NC_DATA1") then
			self.Struct['START_WORK']._Functionality()
		elseif (self.Struct.INSTANCIA.NAME=="START_WORK") then
			self.Struct._Functionality()
		end
    end
    
    self.toolbutton1 = gtk.ToolButton.new() --zoom in
    self.toolbutton1:set('stock-id', 'gtk-zoom-in')
    
    
    self.toolbutton2 = gtk.ToolButton.new() --zoom out
    self.toolbutton2:set('stock-id', 'gtk-zoom-out')
    
    self.toolbutton3 = gtk.ToolButton.new() -- go-back
    self.toolbutton3:set('stock-id', 'gtk-go-back')
    
    self.toolbutton3_5 = gtk.ToolButton.new() -- go-back
    self.toolbutton3_5:set('stock-id', 'gtk-go-forward')
    
    --toolbutton 4 -- edit lines
    local icon_edit  = gtk.Image.new_from_file('mouse.png')
    self.toolbutton4 = gtk.ToggleToolButton.new()
    self.toolbutton4:set('stock-id', 'gtk-color-picker')
    
    --toolbutton 5 -- reset
    
    self.toolbutton5 = gtk.ToolButton.new()--icon_rezoom)
    self.toolbutton5:set('stock-id', 'gtk-zoom-100')
    
    self.toolbutton6 = gtk.ToolButton.new()
    self.toolbutton6:set('stock-id', 'gtk-convert')
    
    self.toolbutton7 = gtk.ToolButton.new()
    self.toolbutton7:set('stock-id', 'gtk-save')
    
    self.toolbutton8 = gtk.ToolButton.new()
    self.toolbutton8:set('stock-id', 'gtk-open')
    
    self.toolbutton9 = gtk.ToolButton.new()
    self.toolbutton9:set('stock-id', 'gtk-dnd-multiple')
    
    self.toolbutton10 = gtk.ToolButton.new()
    self.toolbutton10:set('stock-id', 'gtk-dnd')
	
	self.toolbutton11 = gtk.ToolButton.new()
    self.toolbutton11:set('stock-id', 'gtk-ok') --botao provisorio
    
    --Toolbar itens => separators
    self.sep1 = gtk.SeparatorToolItem.new()
    self.sep2 = gtk.SeparatorToolItem.new()
    self.sep3 = gtk.SeparatorToolItem.new()    
    self.sep4 = gtk.SeparatorToolItem.new()    
    
    --Horizontal_Box (down/paned_window)  -- HBox2
    self.HBox2 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL, 5)
    
    --sidebox
    self.Sidebox = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5)
    
    --paned window (in HBox 2, contents: drawing area and combobox) -- Paned
    self.Paned = gtk.Paned.new()
    
    --caixa do lado esquerdo da paned window
    --function special_sub( s )
        --~ local replace = {
            --~ ["%+"] = "%%%+",
            --~ ["%*"] = "%%%*",
            --~ ["%-"] = "%%%-",
            --~ ["%?"] = "%%%?",            
        --~ }
        --~ for k, v in pairs( replace ) do
            --~ local aux = s
            --~ s, t = string.gsub( s, k, v )
        --~ end
     
        --return s:gsub( '%W', function( c ) print('hallo', c) return '%' .. c end )
    --~ end
    --".-([^%/]*)$"
    function GetType(root, FBType)
        local Type
        local funcoes = {}
        -- tratamento de estados
        funcoes[ '!DOCTYPE' ] = function( l )
            if( l:find( "FBType" ) ~= nil ) then
                Type = "FBType"
            elseif( l:find( "ResourceType" ) ~= nil ) then
                Type = "ResourceType"
            elseif( l:find( "DeviceType" ) ~= nil ) then
                Type = "DeviceType"
            elseif( l:find( "System" ) ~= nil ) then
                Type = "System"
            end
        end
       
        
        --leitura de arquivo para tipo
        --print("DEBUG+ ", root, FBType)
		local file = io.open( root..FBType, 'r')
		--local file = io.open( FBType, 'r')
        local i = 1
        for l in file:lines() do  -- iterate lines
        if( i == 2 ) then
                    funcoes[ '!DOCTYPE' ]( l )
                    break
                end
        i = i + 1
        end
        file:close()
        
        return Type
        end
    
    
    function PreImportXML(dialog)
        dialog:set_current_folder(self.Library)
        if( dialog:run() == gtk.RESPONSE_OK ) then
            local names = dialog:get_filenames()
            local file = names[1]
            local aux = self.Library
            file = select( 3, file:find( ".-([^%\\]*)$" ) )
            self._File = file
            local Type = GetType(self.Library..'/', file)
            if Type == 'FBType' then
                ImportFB()
            elseif Type == 'ResourceType' then
                ImportResource()
            elseif Type == 'DeviceType' then
                ImportDevice()
            elseif Type == 'System' then
                ImportSystem()
            end
        end
        dialog:hide()
    end
    function ImportResource()
            self.Struct = ResourceView.new((Resource.importXML (self.Library..'/', self._File, "Resource")))
            --~ self.PrimalStructure = ResourceView.new((Resource.importXML (self.Library..'/', self._File, "Resource")))
            ApStructs  = nil ApStructs = {}
            click_flag = false
            self.Drawing_Area:queue_draw()
    end
    
    function ImportDevice()
            
            self.Struct  = DeviceView.new((Device.importXML (self.Library..'/', self._File, "Device")))
            --~ self.PrimalStructure = DeviceView.new((Device.importXML (self.Library..'/', self._File, "Device")))
            ApStructs = nil ApStructs = {}
            click_flag = false
            self.Drawing_Area:queue_draw()
      
    end
    
    function ImportFB()
            local struct = FB.importXML (self.Library..'/', self._File, "FunctionBlock")
            if struct.Class == "Composite" or struct.Class == "Comp" then
                self.Struct = CompView.new(struct)
                --~ self.PrimalStructure = CompView.new(struct)
            else
                self.Struct = BlockView.new(struct)
                --~ self.PrimalStructure = BlockView.new(struct)
                
            end
            ApStructs = nil ApStructs = {}
            click_flag = false
            self.Drawing_Area:queue_draw()
    end
    
    function ImportSystem()
        self.Struct = SystemView.new(System.importXML (self.Library..'/', self._File, "System"))
        --~ self.PrimalStructure = SystemView.new(System.importXML (self.Library..'/', self._File, "System"))
        ApStructs = nil ApStructs = {}
        click_flag = false
        self.Drawing_Area:queue_draw()
        
    
        
    end
    
    function SetLibrary(dialog)
        if dialog:run() == gtk.RESPONSE_OK then
            local names  = dialog:get_filenames()
            self.Library = names[1]
            self.SetLibraryEntry:set('text', names[1])
        end
        dialog:hide()
    end
    
    
    self.PanedBoxLeft     = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5) 
    self.FileChooser      = gtk.FileChooserDialog.new('Open a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-ok', gtk.RESPONSE_OK)
    --~ self.Library = '/home/gabriel/Dropbox/Projeto_LAPAS/Biblioteca FB (oficial)'
    --~ self.Library = '/home/gabriel/Dropbox/Projeto_LAPAS/Biblioteca FB (oficial)'
     --~ self.Library = '/home/gabriel/Dropbox/Projeto_LAPAS/Biblioteca FB (oficial)'
    self.Library = 'C:\\Documents and Settings\\FrankII\\Meus documentos\\Dropbox\\H.A.R.B.S\\GASR-FBViewer-RTE_for_Windows\\Biblioteca FB (oficial)'
    self.LibraryChooser   = gtk.FileChooserDialog.new('Set Library Folder', self.Main_Window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-ok', gtk.RESPONSE_OK)
    self.SetLibraryButton = gtk.Button.new_with_label('Set XML Library')
    self.SetLibraryButton:connect('clicked', SetLibrary, self.LibraryChooser)
    self.SetLibraryEntry  = gtk.Entry.new()
    self.SetLibraryEntry:set('text', '')
    self.SetLibraryLabel  = gtk.Label.new('Current Library')
    
    
    self.SystemButton     = gtk.Button.new_with_label('Import XML')
    
    self.SystemButton:connect('clicked', PreImportXML, self.FileChooser)

    
    
    --scrolled window
    self.Scroll = gtk.ScrolledWindow.new()
    self.Scroll:set_policy(true, true)
    self.Scroll:set_hadjustment(true)
    self.Scroll:set_vadjustment(true)
    
    --ComboBox  --Combo
    --~ self.Here_goes_treeview = gtk.Label.new('Here goes\nthe treeview')
    self.Combo = gtk.ComboBoxText.new()
    
    
    --Drawing_Area
    self.Drawing_Area   = gtk.DrawingArea.new()
    self.Drawing_Area:connect('draw', self.Draw, self.Drawing_Area)
    self.Drawing_Area:set_size_request(5000, 5000)
    self.Drawing_Area:add_events(gdk.POINTER_MOTION_MASK)
    self.Drawing_Area:add_events(gdk.BUTTON_PRESS_MASK)
    self.Drawing_Area:add_events(gdk.BUTTON_RELEASE_MASK)
    
    --~ self.Drawing_Area:connect('button-press-event', FBViewer.CLICK, self.Drawing_Area)
    --~ self.Drawing_Area:connect('button-release-event', FBViewer.RELEASE, self.Drawing_Area)
    --self.Drawing_Area:connect('motion-notify-event',funcao,self.Drawing_Area)


    --Compilador arquivo GASR_Compiler.lua
    function RunCompiler()
        local Compiler = GASR_Compiler.new()
        GASR_Compiler.Run(Compiler)
    end
    
   
    
    
    --connecting buttons
    self.toolbutton1:connect ('clicked', ZoomIn , self.Drawing_Area)
    self.toolbutton2:connect ('clicked', ZoomOut, self.Drawing_Area)
    self.toolbutton3:connect ('clicked', GoBack)
    self.toolbutton3_5:connect ('clicked', GoForward)
    self.toolbutton4:connect ('clicked', Edit)
    self.toolbutton5:connect ('clicked', Reset)
    self.toolbutton6:connect ('clicked', RunCompiler )
    self.toolbutton7:connect ('clicked', FBViewerSAVE, self )
    self.toolbutton8:connect ('clicked', FBViewerLOAD, self )
    self.toolbutton9:connect ('clicked', OpenStruct, self )
    self.toolbutton10:connect ('clicked', CloseStruct, self )
    self.toolbutton11:connect ('clicked', Start, self )
    --Packing
    self.Scroll:add_with_viewport(self.Drawing_Area)
    --~ self.Sidebox:pack_start(self.Here_goes_treeview, false, false, 0)
    --~ self.Sidebox:pack_start(self.FBButton, false, false, 0)
    --~ self.Sidebox:pack_start(self.ResourceButton, false, false, 0)
    --~ self.Sidebox:pack_start(self.DeviceButton, false, false, 0)
    
    self.Sidebox:pack_start(self.SetLibraryButton, false, false, 0)
    self.Sidebox:pack_start(self.SetLibraryLabel, false, false, 0)
    self.Sidebox:pack_start(self.SetLibraryEntry, false, false, 0)
    self.Sidebox:pack_start(self.SystemButton, false, false, 0)
    self.Sidebox:pack_start(self.Combo, false, false, 0)
    
    self.Paned:add1(self.Sidebox)
    self.Paned:add2(self.Scroll)
    self.HBox2:pack_start(self.Paned, true, true, 0)
    self.Toolbar:add(self.toolbutton1, self.toolbutton2, self.toolbutton5, self.sep1, self.toolbutton3,self.toolbutton3_5,  self.sep2, self.toolbutton4, self.sep3, self.toolbutton6, self.sep4, self.toolbutton7, self.toolbutton8, self.toolbutton9, self.toolbutton10, self.toolbutton11 ) 
    self.HBox1:pack_start(self.Toolbar, true, true, 0)
    self.Main_Box:pack_start(self.HBox1, false, false, 0)
    self.Main_Box:pack_end(self.HBox2, true, true, 0)
    self.Main_Window:add(self.Main_Box)
    
    setmetatable(self, FBViewer)
    return self
end

function FBViewer:run(inst, flag)
    if inst then
        ApStructs       = nil ApStructs = {}
        if inst.Class     == 'Basic' then
            self.Struct = BlockView.new(inst)
        elseif inst.Class == 'Composite'  then
            self.Struct = CompView.new(inst)
        elseif inst.Class == 'Resource' then
            self.Struct = ResourceView.new(inst)
        elseif inst.Class == 'Device' then
            self.Struct = DeviceView.new(inst)
        else 
            self.Struct = BlockView.new(inst)
        end
    else
        self.Struct = 'Empty'
    end
    self.Main_Window:show_all()
    gtk.main()
    return true
end

--local fb  = Resource.importXML('XML/', 'STEP-NC_DATA.xml', 'fb')
--F = FBViewer.new()
--F:run(fb)


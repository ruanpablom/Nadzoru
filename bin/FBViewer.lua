require('FBE_Requires')

--CLONE TABLE FUNCTION----------------------------------------
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

--GLOBAL VARS INITIALIZING-------------------------------------
ApStructs  = {}
Edit_Lines = false
N          = 1
struct 	   = ""
local handler_id
click_flag = false
local drawing_type = 'closed'
FBViewer = {}

--MOVE BLOCK FUNCTION-----------------------------------------
FBViewer.MOVE = function (widget, event)
    local a, b, x, y = gdk.event_motion_get(event)
    for i, v in ipairs (ApStructs) do
        if v:MOVE(widget, false, false,false, x, y) then
            v.DRAGGED = true
        end
    end
    
end
--CLICK CALLBACK FUNCTION--------------------------------------
FBViewer.CLICK = function (widget, event)

    if not click_flag then
        handler_id  = widget:connect('motion-notify-event', FBViewer.MOVE, widget)
        local a, b, x, y = gdk.event_motion_get(event)
        local selected
        for i = #ApStructs, 1, -1   do
            if ApStructs[i]:get_clicked (widget, x, y) then 
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

--RELEASE CALLBACK FUNCTION------------------------------------
FBViewer.RELEASE = function (widget)

    click_flag = false
    --~ handler_id  = widget:connect('motion-notify-event', FBViewer.MOVE, widget)
    if handler_id then
		widget:disconnect(handler_id)
		for i, v in ipairs (ApStructs) do
			if v.DRAGGED  then
				v.CORPO.CLICKED = false
			end
		end
	end
    widget:queue_draw()
end

FBViewer.__index = FBViewer


function FBViewer.new(self)
    --START-UP----------------------------------------------------
    local self = {}
    self.Library 	 	  = " "
    self.File    	 	  = " "
    self._IsEditMode 	  = false
	self._IsEditModeBasic = false
	self._IsEditModeComp  = false
	self._IsEditModeSIFB  = false
	self._IsEditModeRes   = false
	--DRAWING CALLBACK FUNCTION-----------------------------------
    self.Draw = function (widget, cr)
        cr = cairo.Context.wrap(cr)
        if self.Struct ~= 'Empty' then
            self.Struct:draw(widget, cr)
        end
    end
    --ENVIRONMENT FUNCTIONS---------------------------------------
	--SET SOFTWARE TO RUN MODE------------------------------------
	function RunMode(self)
		if self._IsEditModeBasic then
			self.ScrollBox:remove(self.EditBox)
		elseif self._IsEditModeComp then
			self.ScrollBox:remove(self.EditBoxComp)
		elseif self._IsEditModeSIFB then
			self.ScrollBox:remove(self.EditBoxSIFB)
		elseif self._IsEditModeRes then
			self.ScrollBox:remove(self.EditBoxRes)
		end
		if self._IsEditMode then
			self.Main_Window:hide()
			self.Main_Window:show_all()
			self._IsEditMode 	  = false
			self._IsEditModeBasic = false
			self._IsEditModeComp  = false
		end
	end
	--FUNCTION TO CALL EDIT BASIC FB FROM TEMPLATE---------------------
		function PreEditBasicFB( self , dont_load )
			if not self._IsEditModeBasic then
				RunMode(self)
			end
			if dont_load then
				EditBasicFB( self , false )
			else
				EditBasicFB( self , true )
			end
		end
	--FUNCTION TO CALL EDIT COMPFB FB FROM TEMPLATE----------------
	function PreEditCompFB( self , dont_load )
		if not self._IsEditModeComp then
			RunMode(self)
		end
		if dont_load then
			EditCompFB( self , false )
		else
			EditCompFB( self , true )
		end
		
	end
	--FUNCTION TO CALL EDIT SIFB FB FROM TEMPLATE----------------
	function PreEditSIFB( self , dont_load )
		if not self._IsEditModeSIFB then
			RunMode(self)
		end
		if dont_load then
			EditSIFB( self , false )
		else
			EditSIFB( self , true )
		end
	end
	
	function PreEditResource( self , dont_load )
		if not self._IsEditModeRes then
			RunMode(self)
		end
		if dont_load then
			EditResource( self, false )
		else
			EditResource( self , true )
		end
	end
	
	function PreEditDevice( self , dont_load )
	end
	
	function PreEditSystem( self , dont_load )
	end
	
	
	function EditMode()
		if self._IsEditMode then return end
		if not self.Struct._Type then return end
		if self.Struct._Type == 'BlockView' and self.Struct._FunctionBlock.Class == 'ServiceInterface' then
			PreEditSIFB (self, true)
		elseif self.Struct._Type == 'BlockView' then
			PreEditBasicFB (self, true)
		elseif self.Struct._Type == 'CompView' then
			PreEditCompFB (self, true)
		elseif self.Struct._Type == 'ResourceView' then
			PreEditResource (self, true)			
		elseif self.Struct._Type == 'DeviceView' then
			PreEditDevice (self, true)			
		elseif self.Struct._Type == 'SystemView' then
			PreEditSystem (self, true)		
		end
	end
	
	--Function to open
	function Create(self)
		local window = gtk.Window.new()
		window:set('title', "Create", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local basicb = gtk.Button.new_with_label("Create new BasicFB")
		local compb  = gtk.Button.new_with_label("Create new CompFB")
		local sifbb  = gtk.Button.new_with_label("Create new SIFB")
		local resb   = gtk.Button.new_with_label("Create new Resource")
		local devb   = gtk.Button.new_with_label("Create new Device")
		local sysb   = gtk.Button.new_with_label("Create new System")
		
		local function f_PreEditBasicFB()
			window:hide()
			PreEditBasicFB(self)
		end
		
		local function f_PreEditCompFB()
			window:hide()
			PreEditCompFB(self)
		end
		
		local function f_PreEditSIFB()
			window:hide()
			PreEditSIFB(self)
		end
		
		local function f_PreEditResource()
			window:hide()
			PreEditResource(self)
		end
		
		basicb:connect('clicked', f_PreEditBasicFB)
		compb:connect('clicked', f_PreEditCompFB)
		sifbb:connect('clicked', f_PreEditSIFB)
		resb:connect('clicked', f_PreEditResource)
		Vbox:add(basicb, sifbb, compb, resb, devb, sysb)
		window:add(Vbox)
		window:show_all()
		
		
	end
	--ZOOM IN-----------------------------------------------------
    function ZoomIn(widget)
        N = N*1.05
        self.Drawing_Area:queue_draw()
    end
    
	--ZOOM OUT----------------------------------------------------
    function ZoomOut(widget)
        N = N/1.05
        self.Drawing_Area:queue_draw()
    end
    
    --GO BACK-----------------------------------------------------
    local function GoBack()
        if self.Struct.DrawType then
            if self.Struct.UPPER then
                self.Struct.DrawType = 'closed'
                self.Struct = self.Struct.UPPER
                self.Struct.DrawType = 'open'
            else
                self.Struct.DrawType = 'closed'
            end
            for i, v in ipairs (ApStructs) do
                v.CORPO.CLICKED = false
            end
            ApStructs = nil ApStructs = {}
            self.Drawing_Area:queue_draw()
			self.CurrentStructEntry:set('text', self.Struct._FunctionBlock.FBType)
		end
    end
    
	--KEY PRESS CALLBACK FUNCTION----------------------------------
    local function keyPressed(widget, event)
		---local _, _, val = gdk.event_key_get(event)
		---val = gdk.keyval_to_unicode(val)
		---if(val==8) then GoBack()
		---elseif(val==115) then FBViewerSAVE(self)
		---elseif(val==108) then FBViewerLOAD(self)
		---end
    end
    
    --SET EDIT CONNECTIONS POSITION MODE ON-------------------------
	function Edit()
        Edit_Lines = not Edit_Lines
        self.Drawing_Area:queue_draw()
    end
    
	--RESET ZOOM TO 100%--------------------------------------------
    local function Reset()
        N = 1
        self.Drawing_Area:queue_draw()
    end
    
	--Compilador--------------------------------------------------------
    local function RunCompiler()
        local Compiler = GASR_Compiler.new()
        Compiler:Run()
    end
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
	--LOADING FROM XML FUNCTIONS-------------------------------------------
    
	--GET IEC61499 ENTITY TYPE FROM XML------------------------------------
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
        --print(root, FBType)
		local file = io.open( root..FBType, 'r')
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
    
    --PRE IMPORT FROM XML--------------------------------------------------
    function PreImportXML(dialog)
        dialog:set_current_folder(self.Library)
        if( dialog:run() == gtk.RESPONSE_OK ) then
            local names = dialog:get_filenames()
            local file  = names[1]
            local aux   = self.Library
            --print(file)
			file 		= select( 3, file:find( ".-([^%/]*)$"  ) )
			self._File  = file
			local Type  = GetType(self.Library..'/', file)
            if Type == 'FBType' then
                ImportFB()
            elseif Type == 'ResourceType' then
                ImportResource()
            elseif Type == 'DeviceType' then
                ImportDevice()
            elseif Type == 'System' then
                ImportSystem()
            end
			self.CurrentStructEntry:set('text', self.Struct._FunctionBlock.FBType)
			if self._IsEditMode then
				RunMode(self)
			end
		end
		dialog:hide()
    end
    
	--IMPORT RESOURCE TYPE---------------------------------------------------
	function ImportResource()
        self.Struct = ResourceView.new((Resource.importXML (self.Library..'/', self._File, "Resource")))
        --~ self.PrimalStructure = ResourceView.new((Resource.importXML (self.Library..'/', self._File, "Resource")))
        ApStructs  = nil ApStructs = {}
        click_flag = false
        self.Drawing_Area:queue_draw()
    end
    
	--IMPORT DEVICE TYPE-----------------------------------------------------
    function ImportDevice()
		self.Struct  = DeviceView.new((Device.importXML (self.Library..'/', self._File, "Device")))
		ApStructs = nil ApStructs = {}
		click_flag = false
		self.Drawing_Area:queue_draw()
    end
    
	--IMPORT FUNCTION BLOCK TYPE---------------------------------------------
    function ImportFB()
		local struct = FB.importXML (self.Library..'/', self._File, "FunctionBlock")
		
		if struct.Class == "Composite" or struct.Class == "Comp" then
            self.Struct = CompView.new(struct)
        else
            self.Struct = BlockView.new(struct)
        end
        ApStructs = nil ApStructs = {}
        click_flag = false
        self.Drawing_Area:queue_draw()
    end
    
	--IMPORT SYSTEM TYPE-------------------------------------------------------
    function ImportSystem()
        self.Struct = SystemView.new(System.importXML (self.Library..'/', self._File, "System"))
        --~ self.PrimalStructure = SystemView.new(System.importXML (self.Library..'/', self._File, "System"))
        ApStructs = nil ApStructs = {}
        click_flag = false
        self.Drawing_Area:queue_draw()
        
    end
    
	--SET FB LIBRARY-----------------------------------------------------------
    function SetLibrary(dialog)
        if dialog:run() == gtk.RESPONSE_OK then
            local names  = dialog:get_filenames()
            self.Library = names[1]
            self.SetLibraryEntry:set('text', names[1])
        end
        dialog:hide()
    end
    
	function show_about()
		self._about:run()
		self._about:hide()
	end
	
	--WIDGETS------------------------------------------------------
    --Main_Window--------------------------------------------------
    self.Main_Window = gtk.Window.new()
    self.Main_Window:connect('delete-event', gtk.main_quit)
    self.Main_Window:set('title', "GASR FB-Viewer", 'window-position', gtk.WIN_POS_CENTER)
    self.Main_Window:set('default-width', 1270, 'default-height', 750)
    --Main_Box-----------------------------------------------------
    self.Main_Box  = gtk.Box.new( gtk.ORIENTATION_VERTICAL, 0 )
    --Vbox-- Hbox1 + Hbox2
	self.VBox  = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5)
    --Horizontal_Box (top/toolbar)-- HBox1-------------------------
    self.HBox1 = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5) --tool
	self.HBox11 = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5) --menu
    
	--Horizontal box = Scroll + Edit Mode--------------------------
	self.ScrollBox = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5)
    
	--EditBox------------------------------------------------------
	self.EditBox      = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5)
	self.EditBoxComp  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5)
	self.EditBoxSIFB  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5)
	self.EditBoxRes   = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 5)
	
	--Drawing_Area------------------------------------------------------
    self.Drawing_Area   = gtk.DrawingArea.new()
    self.Drawing_Area:set_size_request(5000, 5000)
	self.Drawing_Area:connect('draw', self.Draw, self.Drawing_Area)
    self.Drawing_Area:add_events(gdk.POINTER_MOTION_MASK)
    self.Drawing_Area:add_events(gdk.BUTTON_PRESS_MASK  )
    self.Drawing_Area:add_events(gdk.BUTTON_RELEASE_MASK)
    self.Main_Window:add_events(gdk.BUTTON_RELEASE_MASK )
    self.Drawing_Area:connect('button-press-event',   FBViewer.CLICK, self.Drawing_Area  )  --Connecting Events
    self.Drawing_Area:connect('button-release-event', FBViewer.RELEASE, self.Drawing_Area)
    self.Main_Window:connect('key-press-event',       keyPressed, self.Main_Window       )
    --self.Drawing_Area:connect('motion-notify-event',funcao,self.Drawing_Area)

	
	--toolbar------------------------------------------------------
    self.Toolbar = gtk.Toolbar.new()
    self.Toolbar:set("toolbar-style", gtk.TOOLBAR_ICONS)
    self.Toolbar:set('height-request', 40)
    
	--paned window ----------------------------------------------------
    self.Paned = gtk.Paned.new()  --(in HBox 2, contents: drawing area and combobox)
    self.PanedBoxLeft        = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5) 
    self.FileChooser         = gtk.FileChooserDialog.new('Open a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-ok', gtk.RESPONSE_OK)
	self.filter 			 = gtk.FileFilter.new()
    self.filter:add_pattern('*.xml')
    self.filter:add_pattern('*.xml')
    self.filter:set_name("XML Files")
    self.FileChooser:add_filter(self.filter)
    --~ self.Library         = '/home/gabriel/Dropbox/Projeto_LAPAS/Biblioteca FB (oficial)'
    self.Library             = 'Biblioteca FB (oficial)'
    self.LibraryChooser      = gtk.FileChooserDialog.new('Set Library Folder', self.Main_Window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-ok', gtk.RESPONSE_OK)
    self.SetLibraryButton    = gtk.Button.new_with_label('Set XML Library')
    self.SetLibraryButton:connect('clicked', SetLibrary, self.LibraryChooser)
    self.SetLibraryEntry     = gtk.Entry.new()
    self.SetLibraryEntry:set('text', 'Biblioteca FB (oficial)')
    self.SetLibraryLabel     = gtk.Label.new('Current Library')
	self.CurrentStructLabel  = gtk.Label.new('Current IEC61499 Struct.')
	self.CurrentStructEntry  = gtk.Entry.new()
	
	--Actions-------------------------------------------------------
	self.a_run_mode      = gtk.Action.new("Run", nil, "Run Mode", 'gtk-media-play')
	self.a_run_mode:set('label', 'Run Mode')
	self.a_run_mode:connect('activate', RunMode, self)
	self.a_edit_mode      = gtk.Action.new("Edit", nil, "Edit Mode", 'gtk-edit')
	self.a_edit_mode:set('label', 'Edit Mode')
	self.a_edit_mode:connect('activate', EditMode, self)
	self.a_zoom_in       = gtk.Action.new("Zoom In", nil, "Zoom In", 'gtk-zoom-in')
	self.a_zoom_in:connect('activate', ZoomIn, self.Drawing_Area)
	self.a_zoom_out      = gtk.Action.new("Zoom Out", nil, "Zoom Out", 'gtk-zoom-out')
	self.a_zoom_out:connect('activate', ZoomOut, self.Drawing_Area)
	self.a_reset_zoom    = gtk.Action.new("Reset Zoom", nil, "Reset Zoom to 100%", 'gtk-zoom-100')
	self.a_reset_zoom:connect('activate', Reset)
	self.a_go_back       = gtk.Action.new("Go Back", nil, "Go Back", 'gtk-go-back') 
	self.a_go_back:connect('activate', GoBack)
	self.a_click_conn    = gtk.Action.new("Click Connections", nil, "Toogle Connection Select On/Off", 'gtk-color-picker')
	self.a_click_conn:connect('activate', Edit)
	self.a_compiler      = gtk.Action.new("Run Compiler", nil, "STEP-NC->FB Compiler", 'gtk-convert')
	self.a_compiler:set('label', 'STEP-NC Compiler')
	self.a_compiler:connect('activate', RunCompiler)
	self.a_save          = gtk.Action.new("Save", nil, "Save (.xml)", 'gtk-save')
	self.a_save:connect('activate', FBViewerSAVE, self)
	self.a_open          = gtk.Action.new("Open", nil, "Open (.xml)", 'gtk-open')
	self.a_open:connect('activate', PreImportXML, self.FileChooser)
	self.a_create        = gtk.Action.new("Create", nil, "Create New Structure", 'gtk-file')
	self.a_create:set('label', 'New Structure')
	self.a_create:connect('activate', Create, self)
	self.a_quit          = gtk.Action.new("Quit", nil, "Quit", 'gtk-quit')
	self.a_quit:connect('activate', gtk.main_quit)
	self.a_about = gtk.Action.new("About", nil, "About this application...", 'gtk-about')
	self.a_about:connect('activate', show_about, self)
	
	
	--menu------------------------------------------------------------
	self._Menubar       = gtk.MenuBar.new()
	self._MenuFile      = gtk.Menu.new()
	self._file_item     = gtk.MenuItem.new_with_mnemonic("_File")
	self._open_item     = self.a_open:create_menu_item()
	self._save_item     = self.a_save:create_menu_item()
	self._compiler_item = self.a_compiler:create_menu_item()
	self._run_item      = self.a_run_mode:create_menu_item()
	self._edit_item     = self.a_edit_mode:create_menu_item()
	self._create_item   = self.a_create:create_menu_item()
	self._quit_item     = self.a_quit:create_menu_item()
	self._MenuFile:append(self._open_item)
	self._MenuFile:append(self._save_item)
	self._MenuFile:append(self._compiler_item)
	self._MenuFile:append(self._create_item)
	self._MenuFile:append(self._run_item)
	self._MenuFile:append(self._edit_item)
	self._MenuFile:append(self._quit_item)
	self._file_item:set_submenu(self._MenuFile)
	--about---------------------------------------------------------
	self._help = gtk.Menu.new()
	self._help_item = gtk.MenuItem.new_with_mnemonic("_Help")
	self._about_item = self.a_about:create_menu_item()
	self._help_item:set_submenu(self._help)
	self._help:append(self._about_item)
	self._help_item:set_submenu(self._help)
	
	self._about = gtk.AboutDialog.new()
	self._logo = gdk.Pixbuf.new_from_file('icon.png')
	self._about:set('program-name', "GASR Function Block Environment", 'authors', {"Gabriel Hermann Negri"},
	'comments', "02/2013", 'license', 'LGPL 3+', 'logo', self._logo, 'title', 'About')

	self._Menubar:append(self._file_item)
	self._Menubar:append(self._help_item)
	
	
    
    
    
    --Toolbar itens => separators--------------------------------------
    self.sep0 = gtk.SeparatorToolItem.new()
	self.sep1 = gtk.SeparatorToolItem.new()
    self.sep2 = gtk.SeparatorToolItem.new()
    self.sep3 = gtk.SeparatorToolItem.new()    
    self.sep4 = gtk.SeparatorToolItem.new()    
	self.sep5 = gtk.SeparatorToolItem.new()   
    
    --Horizontal_Box (down/paned_window)  -- HBox2---------------------
    self.HBox2 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL, 5)
    
    --sidebox----------------------------------------------------------
    self.Sidebox = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 5)
    

    --scrolled window--------------------------------------------------
    self.Scroll = gtk.ScrolledWindow.new()
    self.Scroll:set_policy(true, true)
    self.Scroll:set_hadjustment(true)
    self.Scroll:set_vadjustment(true)
    
    
    
    
    --Packing-----------------------------------------------------------
	self.Scroll:add_with_viewport(self.Drawing_Area)
    self.Sidebox:pack_start(self.SetLibraryButton,   false, false, 0 )
    self.Sidebox:pack_start(self.SetLibraryLabel,    false, false, 0 )
    self.Sidebox:pack_start(self.SetLibraryEntry,    false, false, 0 )
	self.Sidebox:pack_start(self.CurrentStructLabel, false, false, 0 )
    self.Sidebox:pack_start(self.CurrentStructEntry, false, false, 0 )
    self.Paned:add1(self.Sidebox)
    self.ScrollBox:pack_start(self.Scroll,           true, true, 0   )
	self.Paned:add2(self.ScrollBox)
    self.HBox2:pack_start(self.Paned,                true, true, 0   )
    self.Toolbar:add(self.a_run_mode:create_tool_item(),  self.sep0, self.a_zoom_in:create_tool_item(), self.a_zoom_out:create_tool_item()             ,
				     self.a_reset_zoom:create_tool_item(),self.sep1, self.a_go_back:create_tool_item(), self.sep2, self.a_click_conn:create_tool_item(),
					 self.sep3, self.a_compiler:create_tool_item(), self.sep4, self.a_save:create_tool_item(), self.a_open:create_tool_item(),
					 self.sep5, self.a_edit_mode:create_tool_item(), self.a_create:create_tool_item()
					)
    self.HBox1:pack_start(self.Toolbar,              true, true, 0   )
	self.HBox11:pack_start(self._Menubar, 			 true, true, 0)
    self.VBox:pack_start(self.HBox11, false, false, 0)
	self.VBox:pack_start(self.HBox1, false, false, 0)
	self.Main_Box:pack_start(self.VBox, 			 false, false, 0 )
    self.Main_Box:pack_end(self.HBox2, 			     true, true, 0   )
    self.Main_Window:add(self.Main_Box)
    
	--Initializing Editors----------------------------------------------
	EditBasicFB_Initialize(self)
	EditCompFB_Initialize(self)
	EditSIFB_Initialize(self)
	EditResource_Initialize(self)
	
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




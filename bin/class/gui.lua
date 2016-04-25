--[[
    This file is part of nadzoru.

    nadzoru is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    nadzoru is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with nadzoru.  If not, see <http://www.gnu.org/licenses/>.

    Copyright (C) 2011 Yuri Kaszubowski Lopes, Eduardo Harbs, Andre Bittencourt Leal and Roberto Silvio Ubertino Rosso Jr.
--]]

--[[
module "Gui"
--]]
Gui = letk.Class( function( self, fn, data )
    self.note         = gtk.Notebook.new()
    self.tab          = letk.List.new()

    self.window       = gtk.Window.new(gtk.WINDOW_TOPLEVEL)
    self.menu_box     = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 0)
    self.hbox         = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    self.vbox         = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 0)
	self.event_box    = gtk.Box.new(gtk.ORIENTATION_VERTICAL, 0)

    self.menubar      = gtk.MenuBar.new()
    --self.toolbar      = gtk.Toolbar.new()
    --self.hbox         = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
    --self.statusbar    = gtk.Statusbar.new()

    --self.context      = self.statusbar:get_context_id("default")
    --self.statusbar:push(self.context, "Statusbar message")

    self.actions   = {}
    self.menu      = {}
    self.menu_item = {}

    --Actions
    self:add_action('quit', nil, "Quit nadzoru", 'gtk-quit', function()
		gtk.main_quit()
		os.exit()
	end)
    self:add_action('remove_current_tab', "Remove Tab", "Remove The Active Tab", 'gtk-delete', function( data ) data.gui:remove_current_tab() end, self )

    --ToolBar
    --~ self:add_toolbar('quit')
    --~ self:add_toolbar('remove_current_tab')

	--Menu Box
	self.menu_box:pack_end(self.hbox, true, true, 0)
    self.window:add(self.menu_box)
    
    --Hbox
	self.hbox:pack_end(self.event_box, false, false, 0)
    self.hbox:pack_start(self.vbox, true, true, 0)
    
    -- ** Workspace ** --
    self.level_box = gtk.ComboBoxText.new()
	local level_list = get_list('level')
	for _,t in ipairs(level_list) do
		self.level_box:append_text(t)
	end
	self.level_box:set('active', 0)
	
	local atm_flag = false
	self.level_box:connect('changed', function(data)
		local editor
		if not atm_flag then
			editor = self:get_current_content()
		end
		fn.change_level(data, level_list[self.level_box:get('active')+1], editor and editor.automaton)
	end, data)
	
	self.note:connect('switch-page', function(data, _, tab)
		atm_flag = true
		local editor = self.tab:get(tab+1) and self.tab:get(tab+1).content
		if editor and editor.automaton then
			self.level_box:set('active', level_list[editor.automaton.level])
		end
		atm_flag = false
	end, data)
    
	self.treeview_events      = Treeview.new( true )
	self.btn_to_automaton     = gtk.Button.new()
	self.ta_box               = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL, 0)
	self.img_to_automaton     = gtk.Image.new_from_file( './images/icons/to_automaton.png' )
	self.ta_box:pack_start(self.img_to_automaton, true, true, 0)
	self.btn_to_automaton:add(self.ta_box)
	
	self.btn_add_event        = gtk.Button.new_from_stock( 'gtk-add' )
	self.btn_delete_event     = gtk.Button.new_from_stock( 'gtk-delete' )
    self.btn_to_automaton:connect('clicked', fn.to_automaton, data )
	self.btn_add_event:connect('clicked', fn.add_event, data )
    self.btn_delete_event:connect('clicked', fn.delete_event, data )
	
	self.treeview_events:add_column_text("Events",100, fn.edit_event, data)
	self.treeview_events:add_column_toggle("Con", 50, fn.toggle_controllable, data )
	self.treeview_events:add_column_toggle("Obs", 50, fn.toggle_observable, data )
	self.treeview_events:add_column_text("Ref", 50, fn.edit_refinement, data )
	
	self.treeview_events.columns[1]:set('sizing', gtk.TREE_VIEW_COLUMN_AUTOSIZE)
	self.treeview_events.columns[2]:set('sizing', gtk.TREE_VIEW_COLUMN_AUTOSIZE)
	self.treeview_events.columns[3]:set('sizing', gtk.TREE_VIEW_COLUMN_AUTOSIZE)
	self.treeview_events.render[2]:set('width', 32)
	self.treeview_events.render[3]:set('width', 32)
	
	self.event_box:pack_start( gtk.Label.new_with_mnemonic('Level:'), false, false, 0 )
	self.event_box:pack_start( self.level_box, false, false, 0 )
	self.event_box:pack_start( self.treeview_events:build(), true, true, 0 )
	self.event_box:pack_start( self.btn_to_automaton, false, false, 0 )
	self.event_box:pack_start( self.btn_add_event, false, false, 0 )
	self.event_box:pack_start( self.btn_delete_event, false, false, 0 )
	
	self.treeview_events.scrolled:set('width-request', 165)
	self.treeview_events.render[1]:set('width', 36)
    self.treeview_events:update()

    --** Packing it! (menu_box) **--
    self.menu_box:pack_start(self.menubar, false, false, 0)
    --self.vbox:pack_start(self.toolbar, false, false, 0)
    self.vbox:pack_start(self.note, true, true, 0)
    --self.vbox:pack_start(self.statusbar, false, false, 0)

    --** window defines **--
    self.window:set("title", "nadzoru", "width-request", 800,
        "height-request", 600, "window-position", gtk.WIN_POS_CENTER,
        "icon-name", "gtk-about")

    self.window:connect("delete-event", function()
		gtk.main_quit()
		os.exit()
	end)
    
    self.note:set('enable-popup', true, 'scrollable', true, 'show-border', true)
end, Object )

---Refreshs the Gui.
--Refreshs the gtk window.
--@param self Gui in which the operation is applied.
function Gui:run()
    self.window:show_all()
end

---Adds a new action to the gui.
--Creates a new action and connects a callback to it.
--@param self Gui in which the action is added.
--@param name Name of the action.
--@param caption TODO
--@param hint Description of the action.
--@param icon TODO
--@param callback Function to be called when the action is executed.
--@param param Param to be used in the callback.
function Gui:add_action(name, caption, hint, icon, callback, param)
    self.actions[name] = gtk.Action.new( name, caption, hint, icon)
    self.actions[name]:connect("activate", callback, { gui = self, param = param })
end

---Appends a new menu to the gui.
--TODO
--@param self Gui in which the menu is added.
--@param name Name of the menu.
--@param caption TODO
--@return New menu.
function Gui:append_menu( name, caption )
    self.menu[name] = gtk.Menu.new()
    local menu_item = gtk.MenuItem.new_with_mnemonic( caption )
    menu_item:set_submenu( self.menu[name] )
    self.menubar:append( menu_item )
    self.window:show_all()

    self.menu_item[name] = {}

    return menu_item
end

---Prepends a new menu to the gui.
--TODO
--@param self Gui in which the menu is added.
--@param name Name of the menu.
--@param caption TODO
--@return New menu.
function Gui:prepend_menu( name, caption )
    self.menu[name] = gtk.Menu.new()
    local menu_item = gtk.MenuItem.new_with_mnemonic( caption )
    menu_item:set_submenu( self.menu[name] )
    self.menubar:prepend( menu_item )
    self.window:show_all()

    self.menu_item[name] = {}

    return menu_item
end

---Appends a new submenu to a menu.
--TODO
--@param self Gui in which the submenu is added.
--@param parent Parent menu in which the submenu is added.
--@param name Name of the menu.
--@param caption TODO
--@return New menu.
function Gui:append_sub_menu( parent, name, caption )
    self.menu[name] = gtk.Menu.new()
    local menu_item = gtk.MenuItem.new_with_mnemonic( caption )
    menu_item:set_submenu( self.menu[name] )
    self.menu[parent]:append( menu_item )
    self.window:show_all()

    self.menu_item[name] = {}

    return menu_item
end

---Prepend a new submenu to a menu.
--TODO
--@param self Gui in which the submenu is added.
--@param parent Parent menu in which the submenu is added.
--@param name Name of the menu.
--@param caption TODO
--@return New menu.
function Gui:prepend_sub_menu( parent, name, caption )
    self.menu[name] = gtk.Menu.new()
    local menu_item = gtk.MenuItem.new_with_mnemonic( caption )
    menu_item:set_submenu( self.menu[name] )
    self.menu[parent]:prepend( menu_item )
    self.window:show_all()

    self.menu_item[name] = {}

    return menu_item
end

---Appends a separator line to a menu.
--Creates a separator and appends it to the menu 'name'.
--@param self Gui in which the separator is created.
--@param name Name of the menu in which th separator is added.
function Gui:append_menu_separator( name )
    local separator = gtk.SeparatorMenuItem.new()
    self.menu[name]:append( separator )
end

---Prepend a separator line to a menu.
--Creates a separator and prepends it to the menu 'name'.
--@param self Gui in which the separator is created.
--@param name Name of the menu in which th separator is added.
function Gui:prepend_menu_separator( name )
    local separator = gtk.SeparatorMenuItem.new()
    self.menu[name]:prepend( separator )
end

---Removes a menu from the gui.
--@param self Gui in which the menu is removed.
--@param menu Menu to be removed.
function Gui:remove_menu( menu )
    self.menubar:remove( menu )
    self.menu_item[name] = nil --Wouldn't it be 'menu' instead of 'name'?
end

---TODO
--TODO
--@param self Gui in which the operation is applied.
--@param menu_name TODO
--@param action_name TODO
--@param ... TODO
--@return TODO
function Gui:append_menu_item( menu_name, action_name, ...  )
    local menu_item

    if type( action_name ) == 'string' then
        menu_item = self.actions[action_name]:create_menu_item()
    elseif type( action_name ) == 'table' then
        if action_name.type and action_name.type == 'check' then
            menu_item = gtk.CheckMenuItem.new_with_label( action_name.caption or '?' )
            menu_item:connect("activate", action_name.fn, { gui = self, param = action_name.param })
        elseif action_name.type and action_name.type == 'radio' then
            local ra = gtk.RadioAction.new( '', action_name.caption or '?' )
            if self.menu_item[menu_name].radioaction then
                ra:set( 'group', self.menu_item[menu_name].radioaction )
            end
            self.menu_item[menu_name].radioaction = ra
            menu_item = ra:create_menu_item()
            ra:connect("toggled", action_name.fn, { gui = self, param = action_name.param })
        else
            menu_item = gtk.MenuItem.new_with_label( action_name.caption or '?' )
            menu_item:connect("activate", action_name.fn, { gui = self, param = action_name.param })
        end
    else
        return
    end
    if self.menu[menu_name] then
        self.menu[menu_name]:append ( menu_item )
        self.menu_item[menu_name][ #self.menu_item[menu_name] +1] = menu_item
        self.window:show_all()
    end
    if (...) then
        return menu_item, self:append_menu_item( menu_name, ... )
    end

    return menu_item
end

---TODO
--TODO
--@param self Gui in which the operation is applied.
--@param menu_name TODO
--@param action_name TODO
--@param ... TODO
--@return TODO
function Gui:prepend_menu_item( menu_name, action_name, ...  )
    local menu_item

    if type( action_name ) == 'string' then
        menu_item = self.actions[action_name]:create_menu_item()
    elseif type( action_name ) == 'table' then
        if action_name.type and action_name.type == 'check' then
            menu_item = gtk.CheckMenuItem.new_with_label( action_name.caption or '?' )
        elseif action_name.type and action_name.type == 'radio' then
            local ra = gtk.RadioAction.new( '', "Automaton" )
            if self.menu_item[menu_name].radioaction then
                ra:set( 'group', self.menu_item[menu_name].radioaction )
            end
            self.menu_item[menu_name].radioaction = ra
            menu_item = ra:create_menu_item()
        else
            menu_item = gtk.MenuItem.new_with_label( action_name.caption or '?' )
        end
        menu_item:connect("activate", action_name.fn, { gui = self, param = action_name.param })
    else
        return
    end
    self.menu[menu_name]:prepend ( menu_item )
    self.menu_item[menu_name][ #self.menu_item[menu_name] +1] = menu_item
    self.window:show_all()
    if (...) then
        return menu_item, self:prepend_menu_item( menu_name, ... )
    end

    return menu_item
end

---TODO
--TODO
--@param self Gui in which the operation is applied.
--@param menu_name TODO
--@param menu_item TODO
function Gui:remove_menu_item( menu_name, menu_item )
    self.menu[menu_name]:remove( menu_item )
    local pos
    for ch, val in ipairs( self.menu_item[menu_name] ) do
        if val == menu_item then
            pos = ch
        end
    end
    if pos then
        local last = #self.menu_item[menu_name]
        self.menu_item[menu_name][pos] = nil
        self.menu_item[menu_name][pos] = self.menu_item[menu_name][last]
    end
end

--~ function Gui:add_toolbar( action_name, ... )
    --~ self.toolbar:add( self.actions[action_name]:create_tool_item() )
    --~ self.window:show_all()
    --~ if (...) then
        --~ self:add_toolbar( ... )
    --~ end
--~ end

---Adds a new tab to the Gui.
--Creates a label and the close button. Adds the tab to the gtk notebook and refreshs the window.
--@param self Gui in which the operation is applied.
--@param widget TODO
--@param title Name of the tab.
--@param destroy_callback Function to be called when the tab is removed.
--@param param Parameter to be used in the destroy callback.
--@param content Content of the tab is being added.
--@return TODO
--@see Gui:remove_current_tab
function Gui:add_tab( widget, title, destroy_callback, param, content )
	local label = gtk.Label.new(title)
    local btnClose = gtk.Button.new_with_mnemonic('Close This Tab')
    widget:pack_start(btnClose, false, true, 0)
    btnClose:connect('clicked', self.remove_current_tab, self)
    
    local note =  self.note:insert_page( widget, label, -1)
    self.tab:add({ destroy_callback = destroy_callback, param = param, widget = widget, content = content }, note + 1)
    self.window:show_all()
    self.note:set_current_page(note)

    return note
end

---Closes current selected tab.
--Finds the id of the current tab and removes it.
--@param self Gui in which the operation is applied.
function Gui:remove_current_tab( )
    local id = self.note:get_current_page()
    self:remove_tab(id)
end

---Closes a tab.
--Finds the tab represented by id, removes it from the gtk notebook, calls it's destroy callback with it's destroy parameter and refreshs the window.
--@param self Gui in which the operation is applied.
--@param id Id of the tab.
function Gui:remove_tab( id )
    if id then
        self.note:remove_page( id )
        local destroy = self.tab:remove( id + 1 )
        if destroy and destroy.destroy_callback then
            destroy.destroy_callback( destroy.param )
        end
    end
    self.window:show_all()
end

---Changes the name of a tab.
--TODO
--@param self Gui in which the operation is applied.
--@param widget TODO
--@param title New name of the tab.
function Gui:set_tab_page_title( widget, title )
    local page_label = self.note:get_tab_label( widget )
	page_label:set_text( title )

    self.window:show_all()
end

---Return the content of the current tab.
--Gets the id of the current tab. Returns its content.
--@param self Gui in which the operation is applied.
--@return Content of the current tab.
function Gui:get_current_content()
	local id = self.note:get_current_page()
	local tab = self.tab:get(id+1)
	if tab then
		return tab.content
	end
end

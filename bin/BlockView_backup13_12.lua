require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')
require('System')
require('ECCView')
require('SDView')

E_SPC  = 25  --espaçamento entre os eventos
V_SPC  = 25  --espaçamento entre as variáveis
T_SPC  = 10  --largura do bloco dependendo do tipo do bloco
SH_SPC = 10  --largura do separador, horizontal
SV_SPC = 13  --largura do separador, vertical


local IN_WITHS          = 0
local OUT_WITHS         = 0
BlockView               = {}
BlockView.BODY          = {}
BlockView.EVENT         = {}
BlockView.VAR           = {}
BlockView.FBTYPE        = {}
BlockView.LABEL         = {}
BlockView.WITH          = {}
BlockView.XTREME        = {}
BlockView.FUNCTIONALITY = {}

local function clone( t, deep )
    local r = {}
    for k, v in pairs( t ) do
        if deep and type( v ) == 'table' 
            then r[ k ] = clone( v, true )
            else r[ k ] = v
        end
    end
    return r
end


function BlockView.FUNCTIONALITY.new (FB,funct)
    local funcao
    if funct == 'Starter' then
        funcao = function()
            --print(FB._Resourcelabel, FB.label)
            FB._Resource[FB.label]:exe()
        end
    end
    return funcao
end

BlockView.BODY.__index = BlockView.BODY 
function BlockView.BODY.new(BV)
    local self = {}
    self.TOP        = {BV.ORIGEM[1], BV.ORIGEM[2], BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]}  --(x1, y1, x2, y2)
   
    self.LEFT_TOP   = {BV.ORIGEM[1], BV.ORIGEM[2], BV.ORIGEM[1], BV.ORIGEM[2] + BV.EMAX*E_SPC}
   
    self.LEFT_DOWN  = {BV.ORIGEM[1], BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC,BV.ORIGEM[1],BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC  }
   
    self.DOWN       = {BV.ORIGEM[1], BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC , BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC }
   
    self.RIGHT_DOWN = {BV.ORIGEM[1]+ BV._BodyWidth,BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC, BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC}
   
    self.RIGHT_TOP  = {BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2] + BV.EMAX*E_SPC,BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]}
    
    self.WIDTH  = BV._BodyWidth
    self.HEIGHT = BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC
    setmetatable (self, BlockView.BODY)
    return self
end

function BlockView.BODY:draw(widget, cr)
    if self.CLICKED 
        then
        cr:set_source_rgb (0.8, 0.6, 0.6)
        else
        cr:set_source_rgb (0.8, 0.8, 0.9)
    end
    cr:set_line_width (2*N)
    cr:rectangle(self.LEFT_TOP[1]*N, self.LEFT_TOP[2]*N, (self.RIGHT_TOP[1]-self.LEFT_TOP[1])*N, (self.RIGHT_TOP[2] - self.LEFT_TOP[2])*N)
    cr:rectangle((self.LEFT_TOP[3]+SH_SPC)*N, self.LEFT_TOP[4]*N , (self.RIGHT_TOP[3]-self.LEFT_TOP[3]-2*SH_SPC)*N, SV_SPC*N)
    cr:rectangle(self.LEFT_DOWN[1]*N, self.LEFT_DOWN[2]*N, (self.RIGHT_TOP[1]-self.LEFT_TOP[1])*N, (self.RIGHT_DOWN[2] - self.LEFT_DOWN[2])*N)
    cr:fill()
    cr:move_to ( self.TOP[1]*N, self.TOP[2]*N )
    cr:line_to ( self.TOP[3]*N, self.TOP[4]*N )
    cr:move_to ( self.LEFT_TOP[1]*N, self.LEFT_TOP[2]*N )
    cr:line_to ( self.LEFT_TOP[3]*N, self.LEFT_TOP[4]*N )
    cr:rel_line_to ( SH_SPC*N, 0 )
    cr:rel_line_to ( 0, SV_SPC*N )
    cr:rel_line_to ( -SH_SPC*N, 0 )
    cr:move_to ( self.LEFT_DOWN[1]*N, self.LEFT_DOWN[2]*N )
    cr:line_to ( self.LEFT_DOWN[3]*N, self.LEFT_DOWN[4]*N )
    cr:move_to ( self.DOWN[1]*N, self.DOWN[2]*N )
    cr:line_to ( self.DOWN[3]*N, self.DOWN[4]*N )
    cr:move_to ( self.RIGHT_DOWN[1]*N, self.RIGHT_DOWN[2]*N )
    cr:line_to ( self.RIGHT_DOWN[3]*N, self.RIGHT_DOWN[4]*N )
    cr:rel_line_to ( -SH_SPC*N, 0 )
    cr:rel_line_to ( 0, -SV_SPC*N )
    cr:rel_line_to ( SH_SPC*N, 0 )
    cr:move_to ( self.RIGHT_TOP[1]*N, self.RIGHT_TOP[2]*N )
    cr:line_to ( self.RIGHT_TOP[3]*N, self.RIGHT_TOP[4]*N )
    cr:set_source_rgb (0, 0, 0)
    cr:stroke()
end

BlockView.EVENT.__index = BlockView.EVENT 
function BlockView.EVENT.new(name, tipo, slot, BV)  
    local self = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = name
    self.TIPO       = tipo
    self.SLOT       = slot
    self._BodyWidth = BV._BodyWidth
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputEvent'  
        then
            BV.XTREME[name]  = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
            self.POS    = {self.ORIGEM[1]+ 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
            self.TARGET = {self.ORIGEM[1], self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
        else
            BV.XTREME[name]  = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
            self.POS    = {self.ORIGEM[1] + BV._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
            self.TARGET    = {self.ORIGEM[1]  + BV._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
    end
    self.CONNECT_POS = {self.TARGET[1], self.TARGET[2] - 2}
    setmetatable ( self , BlockView.EVENT )
    return self
end

function BlockView.EVENT:draw(widget, cr)
    cr:set_source_rgb (0, 0, 0)
    cr:set_line_width (1*N)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    
    if self.TIPO == 'OutputEvent' then
        local t_ext = cairo.TextExtents.create()
        cr:text_extents(self.NAME, t_ext)
        local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
        cr:move_to((self.POS[1] -txt_width/N -2)*N, self.POS[2]*N)
    else
        cr:move_to(self.POS[1]*N, self.POS[2]*N)
    end
    cr:show_text(self.NAME)
    cr:set_source_rgb (0, 0.4, 0)
    cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC)*N)
    if self.TIPO == 'InputEvent' 
        then 
            cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
            cr:rel_line_to(-10*self.IN_WITHS*N, 0)
        else
            cr:move_to((self.ORIGEM[1]+ self._BodyWidth)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
            cr:rel_line_to(10*self.OUT_WITHS*N, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

BlockView.VAR.__index = BlockView.VAR
function BlockView.VAR.new(name, tipo, slot,BV)  
    local self = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = name
    self.TIPO       = tipo
    self.SLOT       = slot
    self._BodyWidth = BV._BodyWidth
    self.EMAX       = BV.EMAX
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputVar' 
        then
            BV.XTREME[name] = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
            self.POS        = {self.ORIGEM[1] + 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.TARGET     = {self.ORIGEM[1] , self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.CONNECT_POS = {self.TARGET[1]-10*self.IN_WITHS, self.TARGET[2] -2}
        else
            BV.XTREME[name] = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
            self.POS    = {self.ORIGEM[1] + self._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.TARGET = {self.ORIGEM[1] + self._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.CONNECT_POS = {self.TARGET[1]+10*self.IN_WITHS, self.TARGET[2] -2}
    end
    setmetatable ( self , BlockView.VAR )
    return self
end

function BlockView.VAR:draw(widget, cr)
    cr:set_source_rgb (0, 0, 0)
    cr:set_line_width (1*N)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    
    if self.TIPO == 'OutputVar' then
        local t_ext = cairo.TextExtents.create()
        cr:text_extents(self.NAME, t_ext)
        local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
        cr:move_to((self.POS[1] -txt_width/N -2)*N, self.POS[2]*N)
    else
        cr:move_to(self.POS[1]*N, self.POS[2]*N)
    end
    cr:show_text(self.NAME)
    cr:set_source_rgb (0, 0, 0.4)
    cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC)*N)
    if self.TIPO == 'InputVar' 
        then 
            cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
            cr:rel_line_to(-10*self.IN_WITHS*N, 0)
        else
            cr:move_to((self.ORIGEM[1]+ self._BodyWidth)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
            cr:rel_line_to(10*self.OUT_WITHS*N, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

BlockView.FBTYPE.__index = BlockView.FBTYPE
BlockView.FBTYPE.new = function ( BV)
    local self      = {}
    
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.FBType
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1] , self.ORIGEM[2]+BV.EMAX*E_SPC + 10}
    
    setmetatable(self, BlockView.FBTYPE)
    return self
end

function BlockView.FBTYPE:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
end

BlockView.LABEL.__index = BlockView.LABEL
BlockView.LABEL.new = function ( BV)
    local self      = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.label
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1], self.ORIGEM[2]-5}
    setmetatable(self, BlockView.LABEL)
    return self
end

function BlockView.LABEL:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
end

BlockView.WITH.__index = BlockView.WITH
BlockView.WITH.new = function (  BV, event, slot )
    local self = {}
    self.SLOT    = slot
    self.FLAG    = BV.flag[event]
    self.TARGET  = {}
    if BV.flag[event] == 'InputEvent' 
        then 
        self.POS   = BV.IN_EVENT_TARGET[event]
        for i, v in ipairs(BV.with[event]) do
            self.TARGET[i] = BV.IN_VAR_TARGET[v]
        end
        else
        self.POS     = BV.OUT_EVENT_TARGET[event]
        for i, v in ipairs(BV.with[event]) do
            self.TARGET[i] = BV.OUT_VAR_TARGET[v]
        end
    end
    setmetatable(self, BlockView.WITH)
    return self
end

function BlockView.WITH:draw(widget, cr)
    cr:set_source_rgb (0, 0, 0)
    cr:set_line_width(1*N)
    local far = 0
    for i, v in ipairs (self.TARGET) do
        if v[2] > far then far = v[2] end
        if self.FLAG == 'InputEvent' 
            then
            cr:rectangle((self.POS[1] - 7.5*self.SLOT - 2)*N, (v[2]-4)*N , 4*N, 4*N)
            else
            cr:rectangle((self.POS[1] + 7.5*self.SLOT - 2)*N, (v[2]-4)*N , 4*N, 4*N)
        end
    end
    if self.FLAG == 'InputEvent' 
        then
        cr:rectangle((self.POS[1] - 7.5*self.SLOT - 2)*N, (self.POS[2]-4)*N , 4*N, 4*N)
        cr:move_to ((self.POS[1]  - 7.5*self.SLOT)*N, self.POS[2]*N)
        cr:line_to ((self.POS[1]  - 7.5*self.SLOT)*N, far*N)
        else                       
        cr:rectangle((self.POS[1] + 7.5*self.SLOT - 2)*N, (self.POS[2]-4)*N , 4*N, 4*N)
        cr:move_to ((self.POS[1]  + 7.5*self.SLOT)*N, self.POS[2]*N)
        cr:line_to ((self.POS[1]  + 7.5*self.SLOT)*N, far*N)
    end 
    
    cr:stroke()
    cr:set_line_width (2*N)
end

function BlockView:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= (self.ORIGEM[1] + self.CORPO.WIDTH)*N and y >= self.ORIGEM[2]*N and y <= (self.ORIGEM[2] + self.CORPO.HEIGHT)*N then
        if self.CORPO.CLICKED then
            self:double_click(widget)
        end
        self.CORPO.CLICKED = true
        widget:queue_draw()
        return true
    else
        self.CORPO.CLICKED = false
        widget:queue_draw()
        return false
    end
end

function BlockView:double_click(widget)
    --print(self.INSTANCIA.NAME, self.ORIGEM[1], self.ORIGEM[2])
    ApStructs = nil ApStructs = {}
    self.CORPO.CLICKED = false
    if type(self._Functionality) =='function' then
        self._Functionality()
        return false
    end
    self.DrawType = 'open'
    F.Struct = self
    widget:queue_draw()
    return true
end

function BlockView:MOVE(widget, LOAD, b, c, x, y)
    if LOAD or static then
        x, y = self.X, self.Y
    end
    if self.CORPO.CLICKED  or LOAD then
        self.ORIGEM[1], self.ORIGEM[2] = self.ORIGEM[1] + x/N - self.X/N, self.ORIGEM[2] +  y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        self.X, self.Y = x, y
        self.CORPO = BlockView.BODY.new(self)
        for i, v in ipairs (self.ineventlist) do
            self.ineventlist[i] = BlockView.EVENT.new(v.NAME, 'InputEvent', i, self)
            self.IN_EVENT_TARGET[v.NAME]  = self.ineventlist[i].TARGET
        end
        for i, v in ipairs (self.outeventlist) do
            self.outeventlist[i] = BlockView.EVENT.new(v.NAME, 'OutputEvent', i, self)
            self.OUT_EVENT_TARGET[v.NAME] = self.outeventlist[i].TARGET
        end
        for i, v in ipairs (self.invarlist) do
            self.invarlist[i] = BlockView.VAR.new(v.NAME, 'InputVar', i, self)
            self.IN_VAR_TARGET[v.NAME]  = self.invarlist[i] .TARGET
        end
        for i, v in ipairs (self.outvarlist) do
            self.outvarlist[i] = BlockView.VAR.new(v.NAME, 'OutputVar', i, self)
            self.OUT_VAR_TARGET[v.NAME] = self.outvarlist[i] .TARGET
        end
        
        self.WITH_LIST = nil
        self.WITH_LIST = {}
        local in_slot, out_slot = 0, 0
        for i, v in ipairs (self.ineventlist) do
            if self.with[v.NAME] then
                in_slot = in_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v.NAME, in_slot )
            end
        end
        for i, v in ipairs (self.outeventlist) do
            if self.with[v.NAME] then
                out_slot = out_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v.NAME, out_slot )
            end
        end
    
        self.TIPO  = BlockView.FBTYPE.new( self)
        self.INSTANCIA = BlockView.LABEL.new( self)
        self.CORPO.CLICKED = not LOAD
        if self.UPPER then
            self.UPPER:MOVE(widget, LOAD, self, true) 
        end
        widget:queue_draw()
        return true
    end
    widget:queue_draw()
    return false
end

BlockView.__index = BlockView
BlockView.new = function(FB, origem)
    --função que instancia e retira informações do function block
    local self = clone(FB, false)
    self.NAME             = FB.label
    self._FunctionBlock   = FB
    self._Type            = 'BlockView'
    self.XTREME           = {}
    self.with             = clone(FB.with, true)
    self.flag             = clone(FB.flag, true)
    if origem then origem = {tonumber(origem[1]), tonumber(origem[2])} end
    self.ORIGEM           = origem or {200, 150}
    self.SLOT             = {}
    self.SLOT.IEV, self.SLOT.IVAR, self.SLOT.OEV, self.SLOT.OVAR = 0, 0, 0, 0
    self.MAIOR_VAR        = 0
    self.MAIOR_EV         = 0
    self.CONNECTION_LIST  = {}
    self.ineventlist      = {}
    self.outeventlist     = {}
    self.invarlist        = {}
    self.outvarlist       = {}
    self.IN_EVENT_TARGET  = {}
    self.OUT_EVENT_TARGET = {}
    self.IN_VAR_TARGET    = {}
    self.OUT_VAR_TARGET   = {}
    self.WITH_LIST   = {}
    self.IN_WITHS, self.OUT_WITHS = 0, 0
    
    -- testa se há funcionalidade gráfica do bloco  (STARTER)
    if FB.Functionality == 'Starter' then
        self._Functionality = BlockView.FUNCTIONALITY.new(FB,'Starter')
    end
    
    local max_string_in, max_string_out = 0, 0
    
    -- Conta quantos Withs, e detecta maiores strings (ev ou var) de entrada e saida
    for i, v in pairs (FB.with) do
        if FB.flag[i] == 'InputEvent' 
            then
                self.IN_WITHS  = self.IN_WITHS +1
                if #i > max_string_in then
                    max_string_in = #i
                end
            else
                self.OUT_WITHS = self.OUT_WITHS +1
                if #i > max_string_out then
                    max_string_out = #i
                end
        end
    end
    
    -- Conta eventos e variáveis de entrada e saída
    self.EIN, self.EOUT, self.VIN, self.VOUT = #FB.ineventlist, #FB.outeventlist, #FB.invarlist, #FB.outvarlist
    
    if self.VIN > self.VOUT then self.VMAX = self.VIN else self.VMAX = self.VOUT end --retira vmax
        if self.VMAX == 0 then self.VMAX = 1 end
    
    if self.EIN > self.EOUT then self.EMAX = self.EIN else self.EMAX = self.EOUT end --retira emax
        if self.EMAX == 0 then self.EMAX = 1 end

    
    --determina largura do corpo de acordo com o tamanho do tipo ou maiores variáveis ou eventos
    --(tamanho da string)
    local max_string   = max_string_in + 20 + max_string_out
    if max_string > #self.FBType then
        self._BodyWidth = max_string*T_SPC
    else
        self._BodyWidth    = #self.FBType*T_SPC
    end
    
    --cria o corpo
    self.CORPO         = BlockView.BODY.new(self)
    self.CORPO.CLICKED = false
   
    --cria os eventos e variáveis
    for i, v in ipairs (FB.ineventlist) do
        self.ineventlist[i]       = BlockView.EVENT.new(v, 'InputEvent', i, self)
        self.ineventlist[v]       = self.ineventlist[i]
        self.IN_EVENT_TARGET[v]   = self.ineventlist[i] .TARGET
        self.ineventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.outeventlist) do
        self.outeventlist[i]       = BlockView.EVENT.new(v, 'OutputEvent', i, self)
        self.outeventlist[v]       = self.outeventlist[i]
        self.OUT_EVENT_TARGET[v]   = self.outeventlist[i].TARGET
        self.outeventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.invarlist) do
        self.invarlist[i]       = BlockView.VAR.new(v, 'InputVar', i, self)
        self.invarlist[v]       = self.invarlist[i]
        self.IN_VAR_TARGET[v]   = self.invarlist[i] .TARGET
        self.invarlist[v].SLOT2 = i + self.EIN
    end
    for i, v in ipairs (FB.outvarlist) do
        self.outvarlist[i]       = BlockView.VAR.new(v, 'OutputVar', i, self)
        self.outvarlist[v]       = self.outvarlist[i]  
        self.OUT_VAR_TARGET[v]   = self.outvarlist[i] .TARGET
        self.outvarlist[v].SLOT2 = i + self.EOUT
    end
   
   
    --crias os WITH's
    local in_slot, out_slot = 0, 0
    for i, v in ipairs (FB.ineventlist) do
        if FB.with[v] then
            in_slot = in_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v, in_slot )
        end
    end
    for i, v in ipairs (FB.outeventlist) do
        if FB.with[v] then
            out_slot = out_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v, out_slot )
        end
    end

    --instancia ECC ou SD (ServiceDiagram)
    
    if FB.Class == 'ServiceInterface' then
        self.SD       = SDView.new(FB)
        self.SD.UPPER = self
    else
        self.ECC       = ECCView.new(FB)
        self.ECC.UPPER = self
    end
    
    self.TIPO  = BlockView.FBTYPE.new( self)
    self.INSTANCIA = BlockView.LABEL.new( self)
    setmetatable (self, BlockView)
    return self
end

function BlockView:draw (widget, cr)
    if self.DrawType == 'open' then
        ApStructs = nil ApStructs = {}
        --~ self.CORPO.CLICKED = false
        if self.ECC then
            self.ECC:draw(widget, cr)
        else
            self.SD:draw(widget, cr)
        end
    else
        local already_is = false
        for i, v in ipairs(ApStructs) do
            if self.INSTANCIA.NAME == v.INSTANCIA.NAME then
                already_is = true
            end
        end
        if not already_is then
            ApStructs[#ApStructs+1] = self
        end
        cr:set_antialias (1)
        cr:set_source_rgb(0.9, 0.9, 0.9)
        self.CORPO:draw (widget, cr) --desenha o corpo
        for i, v in ipairs(self.ineventlist) do --adiciona eventos de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outeventlist) do --adiciona eventos de saída
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.invarlist) do --adiciona variáveis de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outvarlist) do --adiciona variáveis de saída
            v:draw(widget, cr)
        end
        m = 0
        for i, v in ipairs(self.WITH_LIST) do --adiciona WITH
            v:draw(widget, cr)
        end
        self.TIPO:draw(widget, cr)
        self.INSTANCIA:draw(widget, cr)
    end
end






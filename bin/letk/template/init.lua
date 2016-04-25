local Grammar = require 'letk.template.grammar'
local Blocks  = require 'letk.template.blocks'

local Template = {}
Template.__index = Template

function Template.new( file )
    self = {}

    setmetatable( self, Template )

    self.file   = file
    self.blocks = {}

    return self
end

function Template:__call( Context )
    if not Context then print('ERRO: no Context') return false end
    
    self.errors = {}

    if not self.chunks then
        self:compile( Context )
    end

    local list = self:parse()

    return self:execute( list )
end

function Template:compile( Context )
    local f = io.open( self.file, 'r' )
    if not f then print('ERRO: file not found') return false end

    self.context  = Context

    local s       = f:read("*a")

    self.chunks   = Grammar:match( s )
    self.chunk_id = 1
end

function Template:parse( fl )
    if type( fl ) == 'table' then
        for c,v in ipairs( fl ) do
            fl[v] = true
        end
    end

    local list = {}

    while true do
        local chunk = self.chunks[ self.chunk_id ]
        if not chunk then break end
        if type( chunk ) == 'string' then
            --~ chunk = chunk:gsub( '^\n', '' )
            chunk = chunk--:gsub('[ \t\r]*\n[ \t\r]*', '\n'):gsub('\n+', '\n'):gsub('^\n', '')
            chunk = { block='print', [1] = string.format( '%q', chunk ) }
            self.chunks[ self.chunk_id ] = chunk
        elseif chunk.var then
            chunk.block='var'
        end

        self.chunk_id = self.chunk_id + 1

        if fl and fl[ chunk.block ] then
            return list, chunk
        end

        if chunk.block then
            local block = Blocks[ chunk.block ]
            if not block then
                print( "Erro, invalid block:", chunk.block, chunk[1] )
            else
                local fn = block( self, chunk )
                if fn then
                    list[#list +1] = fn
                end
            end
        end
    end

    return list
end

function Template:execute( list )
    local result = {}
    for i, item in ipairs( list ) do
        local t = type( item )
        local val
        if t == 'string' then
            val = item
        elseif t == 'function' then
            val = item( self, self.context )
        else
            print('ERRO template execution')
        end
        result[ i ] = tostring( val or '' )
    end
    if #self.errors == 0 then
        return table.concat( result, '' )
    else
        local err = table.concat( self.errors, '\n' )
        print( err )
        return err
    end
end

return Template

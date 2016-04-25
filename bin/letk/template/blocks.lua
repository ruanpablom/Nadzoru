local function block_if( template, chunk )
    local eval, err        = loadstring( 'return ' .. chunk[ 1 ] )
    if not( eval ) then 
        table.insert( template.erros, 'ERROR(if)' .. err )
        return false
    end
    local tlist, end_chunk = template:parse{ 'else', 'elseif', 'end', 'endif' }

    local flist

    if end_chunk.block == 'else' then
        flist, end_chunk  = template:parse{ 'end', 'endif' }
    end

    if end_chunk.block == 'elseif' then
        flist, end_chunk = block_if( template, end_chunk )
    end

    return function()
        if template.context:eval( eval ) then
            return template:execute( tlist )
        else
            if type( flist ) == 'table' then
                return template:execute( flist )
            elseif type( flist ) == 'function' then
                return flist()
            end
            return ''
        end
    end
end

local function block_print( template, chunk )
    if not chunk[ 1 ] or chunk[ 1 ] == '' then
        return
    end

    local eval, err = loadstring( 'return ' .. chunk[ 1 ] )
    if not( eval ) then 
        table.insert( template.erros, 'ERROR(print)' .. err )
        return false
    end

    return function( )
        local res =  template.context:eval( eval )
        return res
    end
end

local function block_var( template, chunk )
    if not chunk.var or chunk.var == '' then
        return
    end

    local eval, err = loadstring( 'return ' .. chunk.var )
    if not( eval ) then 
        table.insert( template.erros, 'ERROR(var)' .. err )
        return false
    end

    return function( )
        local res =  template.context:eval( eval )
        return res
    end
end

local function block_for( template, chunk )
    --* blocks list *--
    local lists      = {}
    local delimiters = { 'first', 'last', 'empty', 'loop', 'endfor', 'end', 'notlast', 'notfirst' }

    local list, end_chunk
    local last_end_chunk = 'loop'
    while true do
        list, end_chunk  = template:parse( delimiters )
        if not list or not end_chunk then
            print("ERRO: end for loop not find", chunk[1])
            return
        end
        lists[#lists +1] = {
            last_end_chunk,
            list,
        }

        last_end_chunk = end_chunk.block

        if end_chunk.block == 'end' or end_chunk.block == 'endfor' then
            break
        end
    end

    --* arguments and expression *--
    local mode
    local arglist
    local explist

    if chunk[1]:match('^%s*(%w+)%s*=%s*.-%s*$' ) then
        --numeric for
        mode = 'numeric'
        arglist, explist = chunk[1]:match('^%s*([^%s=]+)%s*=%s*(.-)%s*$' )
        if not arglist then print("ERRO: invalid for", chunk[1]) end
    else
         --generic for
        mode = 'generic'
        arglist, explist = chunk[1]:match( '^%s*(.-)%s+in%s+(.-)%s*$' )
        if not arglist then print("ERRO: invalid for", chunk[1]) end
        arglist = string.split( arglist, ',' )
        for i, arg in ipairs( arglist ) do
            arglist[ i ] = string.trim( arg )
        end
    end

    local eval, err = loadstring( 'return ' .. explist )
    if not( eval ) then 
        table.insert( template.erros, 'ERROR(for)' .. err )
        return false
    end

    return function( )
        local for_ctx, result = {}, {}
        template.context:push( for_ctx, 'FOR' )

        local run             = false
        if mode == 'numeric' then
            local a,b,c = template.context:eval( eval )
            for i = a, b, c or 1 do
                run = true
                for_ctx[ arglist ] = i
                for _, lst in ipairs( lists ) do
                    if
                        lst[1] == 'loop' or
                        ( i == a                and lst[1] == 'first' ) or
                        ( i ~= a                and lst[1] == 'notfirst' ) or
                        ( i > ( b - (c or 1) )  and lst[1] == 'last'  ) or
                        ( i <= ( b - (c or 1) ) and lst[1] == 'notlast'  )
                    then
                        result[#result +1] = template:execute( lst[2] )
                    end
                end
            end
        elseif mode == 'generic' then
            local iter, tbl, var  = template.context:eval( eval )
            local values = { iter( tbl, var ) }
            var = values[ 1 ]
            while var do
                local next_values = { iter( tbl, var ) }
                local next_var    = next_values[1]
                local islast      = next_var == nil

                for i, arg in ipairs( arglist ) do
                    for_ctx[ arg ] = values[ i ]
                end

                for _, lst in ipairs( lists ) do
                    if
                        (lst[1] == 'loop') or
                        ( not run        and lst[1] == 'first' ) or
                        ( run            and lst[1] == 'notfirst' ) or
                        ( islast         and lst[1] == 'last'  ) or
                        ( not islast     and lst[1] == 'notlast'  )
                    then
                        result[#result +1] = template:execute( lst[2] )
                    end
                end

                values = next_values
                var    = next_var
                run = true
            end
        end
        if not run then
            for _, lst in ipairs( lists ) do
                if lst[1] == 'empty' then
                    result[#result +1] = template:execute( lst[2] )
                end
            end
        end

        template.context:pop()

        return table.concat( result )
    end
end

local function block_cycle( template, chunk )
    local external_key
    local explist = string.gsub( chunk[ 1 ], '%s+as%s+([%w_]+)%s*$', function( t )
        external_key = t
        return ''
    end )

    local itens, err = loadstring( 'return ' .. explist )
    if not( itens ) then 
        table.insert( template.erros, 'ERROR(cycle)' .. err )
        return false
    end

    local iter
    local values
    return function( template, context )
        if values == nil then
            values = { context:eval( itens ) }
            iter = 0
        end

        iter = ( iter % #values ) + 1
        local value = values[ iter ]

        if external_key then
            local for_ctx = template.context:get_ctx('FOR')
            if for_ctx then
                for_ctx[ external_key ] = value
            end
        end

        return value
    end
end

local function block_if_changed( template, chunk )
    local eval, err = loadstring( 'return ' .. chunk[ 1 ] )
    if not( eval ) then 
        table.insert( template.erros, 'ERROR(if_changed)' .. err )
        return false
    end
    
    local tlist, end_chunk = template:parse{ 'else', 'end' }
    local flist
    if end_chunk.block == 'else' then
        flist = template:parse{ 'end' }
    end
    local last_value
    return function()
        local new_value = template.context:eval( eval )
        if new_value ~= last_value then
            last_value = new_value
            return template:execute( tlist )
        elseif flist then
            return template:execute( flist )
        end
    end
end

local function block_block( template, chunk )
    local name = string.match( chunk[ 1 ], '^%s*([%w_-]+)%s*$' )
    local list = template:parse{ 'end', 'endblock' }

    template.blocks[ name ] = list

    return function( )
        return template:execute( template.blocks[ name ] )
    end
end

local function block_extends( template, chunk )
    local block_file_name = chunk[ 1 ]
    local fn_file_name, err    = loadstring( 'return ' .. block_file_name)
    if not( fn_file_name ) then 
        table.insert( template.erros, 'ERROR(extends)' .. err )
        return false
    end

    local list_ignored = template:parse()

    return function( )
        local template_name = template.context:eval( fn_file_name )
        local new_template  = template.new( template_name )
        new_template:compile( template.context )
        local list          = new_template:parse()
        for k, blk in pairs( template.blocks ) do
            new_template.blocks[ k ] = blk
        end
        return template:execute( list )
    end
end

local function block_include( template, chunk )
    local eval = chunk[1]
    local file, with = eval:match( '^(.-)%s+with%s+(.+)%s*$' )
    if file and with then
        if with:match( '%S' ) then
            eval = file .. ', {' .. with .. '}'
        end
    end
    local f, err = loadstring( 'return ' .. eval )
    if not( f ) then 
        table.insert( template.erros, 'ERROR(include)' .. err )
        return false
    end
    
    return function( )
        local template_name, ctx = template.context:eval( f )
        local new_template = template.new( template_name )
        if type( ctx ) ~= 'table' then
            ctx = {}
        end
        template.context:push( ctx )
        local result = new_template( template.context )
        template.context:pop()
        return result
    end
end

local function block_with( template, chunk )
    local with, err = loadstring( 'return {' .. chunk[ 1 ] .. '}' )
    if not( with ) then 
        table.insert( template.erros, 'ERROR(with)' .. err )
        return false
    end
    local list = template:parse{ 'end', 'endwith' }
    return function(  )
        local ctx = template.context:eval( with )
        template.context:push( ctx, 'WITH' )
        local result = template:execute( list )
        template.context:pop( )
        return result
    end
end

local function block_set( template, chunk )
    local f, err = loadstring( chunk[ 1 ] )
    if not( f ) then 
        table.insert( template.erros, 'ERROR(set)' .. err )
        return false
    end
    
    return function(  )
        template.context:update( f )
    end
end

return {
    [ 'if' ]          = block_if,
    [ 'elseif' ]      = block_if,
    [ 'print' ]       = block_print,
    [ 'var' ]         = block_var,
    [ 'for' ]         = block_for,
    [ 'cycle' ]       = block_cycle,
    [ 'ifchanged' ]   = block_if_changed,
    [ 'block' ]       = block_block,
    [ 'extends' ]     = block_extends,
    [ 'include' ]     = block_include,
    [ 'with' ]        = block_with,
    [ 'set' ]         = block_set,
}

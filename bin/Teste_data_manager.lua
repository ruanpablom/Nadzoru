--print( 'file = '..FILENAME )
file = io.open( 'COEF_FILE', 'r' )

function pick_a_line()
    local L
	for l in file:lines() do
        L = l
        print( l )
	end
	return L
end

function line_to_stream( line )
	if( line == '' ) then
		return line
	else
		local stream = {}
		local i = 1
		for text in string.gmatch( line, '(%S+)' ) do
			stream[ i ] = tostring(text)
			i = i + 1
		end
		return stream
	end
end

local line = pick_a_line()
if( line == nil ) then
    line = ''
end
stream = line_to_stream( line )
if( type( stream ) == 'table' ) then
    print( stream[1] )
else
    print( stream )
end

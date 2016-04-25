local lpeg = require 'lpeg'

--Patters
local V = lpeg.V --Variable (non-terminal)
local P = lpeg.P --Matches string literally or exactly number characters
local S = lpeg.S --Set
local R = lpeg.R --Range

--Capture
local C  = lpeg.C  --Simple Captures
local Ct = lpeg.Ct --Table Capture
local Cc = lpeg.Cc --Constant Capture
local Cg = lpeg.Cg --Group Capture

local SS = V'IGNORED'^0
local Sp = V'IGNORED'^1

local Grammar = {
    "Start", -- initial
    Start    = Ct( ( V'Literal' + V'Tag' )^ 0 ),
    Tag      = Ct(
        V'Comment' +
        (S' '^0 * V'BlockTag' * S' '^0 * S'\n') +
        V'BlockTag' +
        V'ExprTag'
    ),
    Literal  = C( ( 1 - V'Tag' )^1 ),
    Comment  = P'{#' * ( 1 - P'#}' )^0 * P'#}',
    BlockTag = P'{%' * SS * Cg (V'Ident', 'block' ) *
                       Sp * C( ( 1 - P'%}' ) ^ 0 ) *
                       SS * P'%}',
    ExprTag  = P'{{' * Cg( ( 1 - P'}}' )^0, 'var' ) * P'}}',
    Ident    = R( 'az', 'AZ', '__' ) * R( 'az', 'AZ', '09', '__' ) ^ 0,
    IGNORED  = S' \t\r\n\f',
}

return P( Grammar )

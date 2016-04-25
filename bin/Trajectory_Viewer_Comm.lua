Trajectory_Viewer_Comm = {}
Trajectory_Viewer_Comm.__index = Trajectory_Viewer_Comm
function Trajectory_Viewer_Comm:exe(event)
    self.CONFIRMATION ='RSP'
    LOG_FILE:write('FileWriter: '..self.label..' initialized with event: '..event..'\n')
    GEOM_FILE:write( "}\n" )
    GEOM_FILE:close()
    local f = loadfile( 'TrajectoryViewer.lua' )
    f()
--    if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then --Is self.INPUTS[ 1 ] correct?
--        GEOM_FILE:write( "{" )
--    end
--    for i, v in ipairs (self.INPUTS) do
--        if type (self[v]) == 'table' then
--            for j, k in ipairs (self[v]) do
--                COEF_FILE:write(k..' ')
--                if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then --Is self.INPUTS[ 1 ] correct?
--                    GEOM_FILE:write( k.."," )
--                end
--            end
--        else
--            COEF_FILE:write(self[v]..' ')
--            if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then --Is self.INPUTS[ 1 ] correct?
--                GEOM_FILE:write( self[v].."," )
--            end
--        end
--    end
--    if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then --Is self.INPUTS[ 1 ] correct?
--        GEOM_FILE:write( "},\n" )
--    end
--    COEF_FILE:write('\n')
    LOG_FILE:write('FileWriter: '..self.label..' execution complete\n')
    LOG_FILE:write('FileWriter: '..self.label..' returned event '..self.CONFIRMATION..'\n')
    return {self.CONFIRMATION}, self.label
end

SIFB_Class.Trajectory_Viewer_Comm = Trajectory_Viewer_Comm

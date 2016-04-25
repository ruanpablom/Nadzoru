Modbus_read_4 = {}

Modbus_read_4.__index = Modbus_read_4


function Modbus_read_4:exe(event)
    
    LOG_FILE:write('Modbus_read_4--- '..self.label..' started with event: '..event..'\n')
    local label
    self.output = {}
    
    local p = io.popen('java -jar modbus.jar.jar ' ..self.PORT..' '..self.INIT_REG..' '..self.NUM_REG, 'r')

    for i = 1, tonumber(self.NUM_REG)  do
        d = p:read()
        if d == nil then
            break
        end
        if p then p:close() end
        self['RD_'..tostring(i)] = tonumber(d)
    end
    
    return {"CNF"} , self.label
    
end
SIFB_Class.Modbus_read_4 = Modbus_read_4

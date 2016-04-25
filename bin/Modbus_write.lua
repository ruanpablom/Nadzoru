Modbus_write_1 = {}

Modbus_write_1.__index = Modbus_write_1


function Modbus_write:exe(event)
    
    LOG_FILE:write('Modbus_write--- '..self.label..' started with event: '..event..'\n')

    local p = io.popen('java -jar MODBUS_write_1.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.SD_1, 'r')
    local d = p:read()
    print('RETORNOU: ', d)
    
    return {"CNF"} , self.label
    
end

SIFB_Class.Modbus_write_1 = Modbus_write_1

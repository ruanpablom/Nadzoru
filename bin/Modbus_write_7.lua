Modbus_write_7 = {}

Modbus_write_7.__index = Modbus_write_7


function Modbus_write_7:exe(event)

    LOG_FILE:write('Modbus_write_7--- '..self.label..' started with event: '..event..'\n')

    print( 'EXE = '..'java -jar MODBUS_write_7.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.PAGE)
    local p = io.popen('java -jar MODBUS_write_7.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.PAGE, 'r')
    local d = p:read()
    print('RETORNOU: ', d)
    if p then p:close() end

    return {"CNF"} , self.label

end

SIFB_Class.Modbus_write_7 = Modbus_write_7

Modbus_write_12 = {}

Modbus_write_12.__index = Modbus_write_12


function Modbus_write_12:exe(event)

    LOG_FILE:write('Modbus_write_12--- '..self.label..' started with event: '..event..'\n')
    print( 'EXE = '..'java -jar MODBUS_write_12.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.SD_6..' '..self.SD_7..' '..self.SD_8..' '..self.SD_9..' '..self.SD_10..' '..self.PAGE )
	local p
    while true do
		p = io.popen('java -jar MODBUS_write_12.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.SD_6..' '..self.SD_7..' '..self.SD_8..' '..self.SD_9..' '..self.SD_10..' '..self.PAGE, 'r')
		if p then break
		end
    end
    local d = p:read()
	
    print('RETORNOU: ', d)
	if p then p:close() end
    return {"CNF"} , self.label

end

SIFB_Class.Modbus_write_12 = Modbus_write_12

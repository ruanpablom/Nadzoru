--~ RUN_UNTIL_LOOP_RESPONSE -> escreve 1 variavel (1057 - inicio de operação) e lê 1 variável ( 1058 - status da máquina 0 - livre; 1 - ocupado);  enquanto ocupado, ler 1058. Se 1058 == 0, setar evento de saída para enviar proxima equação
Run_untill_loop_response = {}

Run_untill_loop_response.__index = Run_untill_loop_response


function Run_untill_loop_response:exe(event)
    
    LOG_FILE:write('Run_untill_loop_response--- '..self.label..' started with event: '..event..'\n')

    local p = io.popen('java -jar MODBUS_write_1.jar '.. self.PORT .. ' '..self.REG_WRITE..' 1, 'r')
    local d = p:read()
    
    if d then  --conseguiu escrever
        while true do
            local p = io.popen('java -jar MODBUS_read.jar '.. self.PORT .. ' '..self.REG_READ..' '..self.NUM_REG)
            d = p:read()
            if p then p:close() end
            if d =='0' then
                return {"CNF"} , self.label
            end
        end
    end
    
    
    
end

SIFB_Class.Run_untill_loop_response = Run_untill_loop_response

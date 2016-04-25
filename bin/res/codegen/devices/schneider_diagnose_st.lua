Devices['schneider_diagnose_st'] = letk.Class( Devices['base'] )

Devices['schneider_diagnose_st'].template_file 	= 'schneider_diagnose_st.XPG'
Devices['schneider_diagnose_st'].file_extension	= 'XPG'
Devices['schneider_diagnose_st'].company 		= 'Schneider Automation'
Devices['schneider_diagnose_st'].product 		= 'Unity Pro M V4.1 - 90415E'
Devices['schneider_diagnose_st'].datetime 		= os.date("%Y-%m-%d-%H:%M:%S")
Devices['schneider_diagnose_st'].content 		= 'Structured source file'
Devices['schneider_diagnose_st'].project 		= 'Project' -- encontrar funçao que copie o nome do projeto .nza
Devices['schneider_diagnose_st'].ns         	= '' --number suffix
Devices['schneider_diagnose_st'].rack         	= '64576'

Devices['schneider_diagnose_st'].models = {
	['Other'] = true,
}

Devices['schneider_diagnose_st'].channel		= {1, 2, 3}
--Devices['schneider'].

Devices['schneider_diagnose_st']:set_option('failure_id', {
    caption = "Multiplas Falhas?",
    type    = 'choice',
    { {1} , "Não"},
    { {2} , "Sim"},
})

Devices['schneider_diagnose_st']:set_option('espacovirgula', {
    caption = "Separacao por espaço?",
    type    = 'choice',
    { {1} , "Não"},
    { {2} , "Sim"},
})
Devices['schneider_diagnose_st']:set_option('sensormap', {
    caption = "Incluir FB Sensor_Map",
    type    = 'choice',
    { {1} , "Não"},
    { {2} , "Sim"},
})

Devices['schneider_diagnose_st']:set_option('history', {
    caption = "Histórico de Eventos?",
    type    = 'choice',
    { {1} , "Não"},
    { {2} , "50 Eventos"},
    { {3} , "100 Eventos"},
    { {4} , "200 Eventos"},
    { {5} , "Numero de Eventos"},
    { {6} , "2 x Numero de Eventos"},
})
------------------------------------------------------------------------

--
Devices['m340diast'] = letk.Class( Devices['schneider_diagnose_st'] ):init_options()
Devices['m340diast'].display      = true
Devices['m340diast'].name         = 'Schneider - M340 - Diagnose - ST'

Start_feature = {}
Start_feature.__index = Start_feature
function Start_feature:exe(event)
    self.CONFIRMATION ='IND'
    LOG_FILE:write('Start_feature: '..self.label..' initialized with event: '..event..'\n')
    COEF_FILE:write('Starting Feature '..self.feature..'\n')
    LOG_FILE:write('Start_feature: '..self.label..' execution complete\n')
    LOG_FILE:write('Start_feature: '..self.label..' returned event '..self.CONFIRMATION..'\n')
    return {self.CONFIRMATION}, self.label
end

SIFB_Class.Start_feature = Start_feature

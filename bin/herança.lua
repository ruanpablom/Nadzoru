--~ a = {
    --~ oi = 'oi',
--~ }
--~ a.__index = a
--~ a.__newindex = function (tab, key, value)
    --~ print('set new value to ', key, value)
    --~ end
--~ 
--~ local b = {}
--~ setmetatable (b, a)
--~ b.oi = 10
--~ b.yellow = 'hello'





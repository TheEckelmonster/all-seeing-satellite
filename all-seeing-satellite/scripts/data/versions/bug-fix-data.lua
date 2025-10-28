local Data = require("scripts.data.data")

local bug_fix_data = {}

bug_fix_data.value = 0
bug_fix_data.warned = false
bug_fix_data.valid = true

function bug_fix_data:new(o)
    Log.debug("bug_fix_data:new")
    Log.info(o)

    local defaults = {
        value = bug_fix_data.value,
        warned = bug_fix_data.warned,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(bug_fix_data, Data)
bug_fix_data.__index = bug_fix_data
return bug_fix_data
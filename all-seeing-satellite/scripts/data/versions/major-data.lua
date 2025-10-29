local Data = require("scripts.data.data")

local major_data = {}

major_data.value = 0
major_data.warned = false
major_data.valid = true

function major_data:new(o)
    Log.debug("major_data:new")
    Log.info(o)

    local defaults = {
        value = major_data.value,
        warned = major_data.warned,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(major_data, Data)
major_data.__index = major_data
return major_data
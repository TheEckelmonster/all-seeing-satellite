local Data = require("scripts.data.data")

local satellite_toggle_data = {}

satellite_toggle_data.planet_name = nil
satellite_toggle_data.toggle = false

function satellite_toggle_data:new(o)
    Log.debug("satellite_toggle_data:new")
    Log.info(o)

    local defaults = {
        planet_name = self.planet_name,
        toggle = self.toggle,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(satellite_toggle_data, Data)
satellite_toggle_data.__index = satellite_toggle_data
return satellite_toggle_data
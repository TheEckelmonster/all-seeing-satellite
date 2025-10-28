local Data = require("scripts.data.data")

local rocket_silo_data = {}

rocket_silo_data.unit_number = -1
rocket_silo_data.entity = nil
rocket_silo_data.surface = nil
rocket_silo_data.surface_index = -1
rocket_silo_data.force = nil
rocket_silo_data.force_index = -1

function rocket_silo_data:new(o)
    Log.debug("rocket_silo_data:new")
    Log.info(o)

    local defaults = {
        unit_number = self.unit_number,
        entity = self.entity,
        surface = self.surface,
        surface_index =  self.surface_index,
        force = self.force,
        force_index = self.force_index,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(rocket_silo_data, Data)
rocket_silo_data.__index = rocket_silo_data
return rocket_silo_data
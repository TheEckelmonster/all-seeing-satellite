local Data = require("scripts.data.data")

local satellite_data = {}

satellite_data.entity = nil
satellite_data.force = nil
satellite_data.force_index = -1
satellite_data.planet_name = nil
satellite_data.scan_count = 0
satellite_data.tick_off_cooldown = 0
satellite_data.tick_to_die = 0
satellite_data.satellite_toggled_by_player = nil
satellite_data.surface_index = -1
satellite_data.cargo_pod = nil
satellite_data.cargo_pod_unit_number = -1

function satellite_data:new(o)
    Log.debug("satellite_data:new")
    Log.info(o)

    local defaults = {
        entity = self.entity,
        force = self.force,
        force_index = self.force_index,
        planet_name = self.planet_name,
        scan_count = self.scan_count,
        tick_off_cooldown = self.tick_off_cooldown,
        tick_to_die = self.tick_to_die,
        satellite_toggled_by_player = self.satellite_toggled_by_player,
        surface_index = self.surface_index,
        cargo_pod = self.cargo_pod,
        cargo_pod_unit_number = self.cargo_pod_unit_number,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(satellite_data, Data)
satellite_data.__index = satellite_data
return satellite_data
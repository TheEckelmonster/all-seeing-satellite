local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local satellite_data = Data:new()

satellite_data.entity = nil
satellite_data.force = nil
satellite_data.planet_name = nil
satellite_data.scan_count = 0
satellite_data.tick_off_cooldown = 0
satellite_data.tick_to_die = 0
satellite_data.satellite_toggled_by_player = nil
satellite_data.surface_index = -1

function satellite_data:new(obj)
    Log.debug("satellite_data:new")
    Log.info(obj)

    obj = obj and Data:new(obj) or Data:new()

    local defaults = {
        entity = self.entity,
        force = self.force,
        planet_name = self.planet_name,
        scan_count = self.scan_count,
        tick_off_cooldown = self.tick_off_cooldown,
        tick_to_die = self.tick_to_die,
        satellite_toggled_by_player = self.satellite_toggled_by_player,
        surface_index = self.surface_index,
    }

    for k, v in pairs(defaults) do
        if (obj[k] == nil) then obj[k] = v end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

return satellite_data
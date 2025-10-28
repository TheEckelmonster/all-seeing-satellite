local Data = require("scripts.data.data")

local satellite_meta_data = {}

satellite_meta_data.planet_name = nil
satellite_meta_data.rocket_silos = {}
satellite_meta_data.satellites = {}
satellite_meta_data.satellite_dictionary = {}
satellite_meta_data.satellites_cooldown = {}
satellite_meta_data.satellites_in_orbit = 0
satellite_meta_data.satellites_launched = 0
satellite_meta_data.satellites_toggled = {}
satellite_meta_data.satellite_toggled_by_player = nil
satellite_meta_data.scanned = false
satellite_meta_data.surface_index = -1
satellite_meta_data.satellites_in_transit = {}

function satellite_meta_data:new(o)
    Log.debug("satellite_meta_data:new")
    Log.info(o)

    local defaults = {
        planet_name = self.planet_name,
        rocket_silos = {},
        satellites = {},
        satellite_dictionary = {},
        satellites_cooldown = {},
        satellites_in_orbit = self.satellites_in_orbit,
        satellites_launched = self.satellites_launched,
        satellites_toggled = {},
        satellite_toggled_by_player = self.satellite_toggled_by_player,
        scanned = self.scanned,
        surface_index = self.surface_index,
        satellites_in_transit = {},
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(satellite_meta_data, Data)
satellite_meta_data.__index = satellite_meta_data
return satellite_meta_data
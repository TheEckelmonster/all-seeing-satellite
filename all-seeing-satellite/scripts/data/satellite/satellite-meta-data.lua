local setmetatable = setmetatable

local Data = require("scripts.data.data")
local new_Data = Data.new

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
    -- Log.debug("satellite_meta_data:new")
    -- Log.info(o)

    local obj = o or {}

    obj.planet_name = obj.planet_name or nil
    obj.rocket_silos = obj.rocket_silos or {}
    obj.satellites = obj.satellites or {}
    obj.satellite_dictionary = obj.satellite_dictionary or {}
    obj.satellites_cooldown = obj.satellites_cooldown or {}
    obj.satellites_in_orbit = obj.satellites_in_orbit or 0
    obj.satellites_launched = obj.satellites_launched or 0
    obj.satellites_toggled = obj.satellites_toggled or {}
    obj.satellite_toggled_by_player = obj.satellite_toggled_by_player or nil
    obj.scanned = obj.scanned or false
    obj.surface_index = obj.surface_index or -1
    obj.satellites_in_transit = obj.satellites_in_transit or {}

    self.__index = self
    return setmetatable(new_Data(Data, obj), self)
end

setmetatable(satellite_meta_data, Data)
satellite_meta_data.__index = satellite_meta_data
return satellite_meta_data
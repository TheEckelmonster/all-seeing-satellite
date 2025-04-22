local Data = require("control.data.data")
local Log = require("libs.log.log")

local satellite_meta_data = Data:new()

satellite_meta_data.planet_name = nil
satellite_meta_data.rocket_silos = {}
satellite_meta_data.satellites = {}
satellite_meta_data.satellites_cooldown = {}
satellite_meta_data.satellites_in_orbit = 0
satellite_meta_data.satellites_launched = 0
satellite_meta_data.satellite_toggled_by_player = nil
satellite_meta_data.scanned = false
satellite_meta_data.surface_index = -1

function satellite_meta_data:new(obj)
  Log.debug("satellite_meta_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    planet_name = self.planet_name,
    rocket_silos = {},
    satellites = {},
    satellites_cooldown = {},
    satellites_in_orbit = self.satellites_in_orbit,
    satellites_launched = self.satellites_launched,
    satellite_toggled_by_player = self.satellite_toggled_by_player,
    scanned = self.scanned,
    surface_index = self.surface_index,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return satellite_meta_data
local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local satellite_toggle_data = Data:new()

satellite_toggle_data.planet_name = nil
satellite_toggle_data.toggle = false

function satellite_toggle_data:new(obj)
  Log.debug("satellite_toggle_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    planet_name = self.planet_name,
    toggle = self.toggle,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return satellite_toggle_data
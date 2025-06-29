local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local planet_data = Data:new()

planet_data.name = nil
planet_data.surface = nil
planet_data.magnitude = 1

function planet_data:new(obj)
  Log.debug("planet_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    name = self.name,
    surface = self.surface,
    magnitude = self.magnitude,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return planet_data
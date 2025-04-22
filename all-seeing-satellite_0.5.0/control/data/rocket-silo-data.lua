local Data = require("control.data.data")
local Log = require("libs.log.log")

local rocket_silo_data = Data:new()

rocket_silo_data.unit_number = -1
rocket_silo_data.entity = nil

function rocket_silo_data:new(obj)
  Log.debug("rocket_silo_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    unit_number = self.unit_number,
    entity = self.entity,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return rocket_silo_data
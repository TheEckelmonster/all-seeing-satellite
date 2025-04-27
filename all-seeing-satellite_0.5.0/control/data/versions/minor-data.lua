local Data = require("control.data.data")
local Log = require("libs.log.log")

local minor_data = Data:new()

minor_data.value = 0
minor_data.warned = false
minor_data.valid = true

function minor_data:new(obj)
  Log.debug("minor_data:new")
  Log.info(obj)

  obj = Data:new(obj) or Data:new()

  local defaults = {
    value = minor_data.value,
    warned = minor_data.warned,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return minor_data
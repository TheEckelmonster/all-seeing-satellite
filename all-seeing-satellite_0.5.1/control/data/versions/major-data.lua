local Data = require("control.data.data")
local Log = require("libs.log.log")

local major_data = Data:new()

major_data.value = 0
major_data.warned = false
major_data.valid = true

function major_data:new(obj)
  Log.debug("major_data:new")
  Log.info(obj)

  obj = Data:new(obj) or Data:new()

  local defaults = {
    value = major_data.value,
    warned = major_data.warned,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return major_data
local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local bug_fix_data = Data:new()

bug_fix_data.value = 0
bug_fix_data.warned = false
bug_fix_data.valid = true

function bug_fix_data:new(obj)
  Log.debug("bug_fix_data:new")
  Log.info(obj)

  obj = Data:new(obj) or Data:new()

  local defaults = {
    value = bug_fix_data.value,
    warned = bug_fix_data.warned,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return bug_fix_data
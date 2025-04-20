local Log = require("libs.log.log")

local data = {}

-- Audit fields
data.valid = false
data.created = nil
data.updated = nil

function data:new(obj)
  Log.debug("data:new")
  Log.info(obj)

  obj = obj or {}

  local defaults = {
    valid = self.valid,
    created = self.created or game and game.tick,
    updated = self.updated or game and game.tick,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function data:is_valid()
  Log.debug("data:is_valid")
  return self.created ~= nil and self.created >= 0 and self.updated ~= nil and self.updated >= self.created
end

return data
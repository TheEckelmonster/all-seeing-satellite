-- If already defined, return
if _data and _data.all_seeing_satellite then
  return _data
end

local data = {}

-- Audit fields
data.valid = false
data.created = nil
data.updated = -1

function data:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

data.all_seeing_satellite = true

local _data = data

return data
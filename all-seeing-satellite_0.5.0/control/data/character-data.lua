-- If already defined, return
if _character_data and _character_data.all_seeing_satellite then
  return _character_data
end

local Data = require("control.data.data")

local character_data = Data:new()

character_data.player_index = -1
character_data.character = {}
character_data.surface_index = -1
character_data.position = nil

function character_data:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

character_data.all_seeing_satellite = true

local _character_data = character_data

return character_data
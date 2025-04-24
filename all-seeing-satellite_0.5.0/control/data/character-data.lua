local Data = require("control.data.data")
local Log = require("libs.log.log")

local character_data = Data:new()

character_data.player_index = -1
character_data.unit_number = nil
character_data.character = nil
-- Default of nauvis (methinks?)
character_data.surface_index = 1
-- Default to the origin
character_data.position = { x = 0, y = 0,}

function character_data:new(obj)
  Log.debug("character_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    player_index = self.player_index,
    unit_number = self.unit_number,
    character = self.character,
    surface_index = self.surface_index,
    position = self.position,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return character_data
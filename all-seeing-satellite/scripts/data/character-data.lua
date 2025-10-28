local Data = require("scripts.data.data")

local character_data = {}

character_data.player_index = -1
character_data.unit_number = nil
character_data.character = nil
-- Default of nauvis (methinks?)
character_data.surface_index = 1
-- Default to the origin
character_data.position = { x = 0, y = 0, }

function character_data:new(o)
    Log.debug("character_data:new")
    Log.info(o)

    local defaults = {
        player_index = self.player_index,
        unit_number = self.unit_number,
        character = self.character,
        surface_index = self.surface_index,
        position = self.position,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(character_data, Data)
character_data.__index = character_data
return character_data
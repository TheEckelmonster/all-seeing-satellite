local Character_Data = require("scripts.data.character-data")
local Data = require("scripts.data.data")

local player_data = {}

player_data.character_data = Character_Data:new()
player_data.controller_type = {}
player_data.editor_mode_toggled = false
player_data.force_index = nil
player_data.force_index_stashed = nil
player_data.in_space = false
player_data.physical_surface_index = -1
player_data.physical_position = nil
player_data.physical_vehicle = nil
player_data.player_index = -1
player_data.position = nil
player_data.satellite_mode_allowed = false
player_data.satellite_mode_stashed = false
player_data.satellite_mode_toggled = false
player_data.surface_index = -1
player_data.vehicle = nil

function player_data:new(o)
    Log.debug("player_data:new")
    Log.info(o)

    local defaults = {
        character_data = Character_Data:new(),
        controller_type = self.controller_type,
        editor_mode_toggled = self.editor_mode_toggled,
        force_index = self.force_index,
        force_index_stashed = self.force_index_stashed,
        in_space = self.in_space,
        position = self.position,
        physical_surface_index = self.physical_surface_index,
        physical_position = self.physical_position,
        physical_vehicle = self.physical_vehicle,
        player_index = self.player_index,
        satellite_mode_allowed = self.satellite_mode_allowed,
        satellite_mode_stashed = self.satellite_mode_stashed,
        satellite_mode_toggled = self.satellite_mode_toggled,
        surface_index = self.surface_index,
        vehicle = self.vehicle,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(player_data, Data)
player_data.__index = player_data
return player_data
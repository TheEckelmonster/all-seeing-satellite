local Character_Data = require("control.data.character-data")
local Data = require("control.data.data")
local Log = require("libs.log.log")

local player_data = Data:new()

player_data.player_index = -1
player_data.character_data = Character_Data:new()
player_data.controller_type = {}
player_data.surface_index = -1
player_data.position = nil
player_data.vehicle = nil
player_data.physical_surface_index = -1
player_data.physical_position = nil
player_data.physical_vehicle = nil
player_data.satellite_mode_allowed = false
player_data.satellite_mode_stashed = false
player_data.satellite_mode_toggled = false
player_data.editor_mode_toggled = false

function player_data:new(obj)
  Log.debug("player_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    player_index = self.player_index,
    character_data = Character_Data:new(),
    controller_type = self.controller_type,
    surface_index = self.surface_index,
    position = self.position,
    vehicle = self.vehicle,
    physical_surface_index = self.physical_surface_index,
    physical_position = self.physical_position,
    physical_vehicle = self.physical_vehicle,
    satellite_mode_allowed = self.satellite_mode_allowed,
    satellite_mode_stashed = self.satellite_mode_stashed,
    satellite_mode_toggled = self.satellite_mode_toggled,
    editor_mode_toggled = self.editor_mode_toggled,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return player_data
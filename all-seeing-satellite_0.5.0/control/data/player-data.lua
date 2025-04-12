-- If already defined, return
if _player_data and _player_data.all_seeing_satellite then
  return _player_data
end

local Character_Data = require("control.data.character-data")
local Data = require("control.data.data")

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
player_data.satellite_mode_toggled = false
player_data.editor_mode_toggled = false

function player_data:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

player_data.all_seeing_satellite = true

local _player_data = player_data

return player_data
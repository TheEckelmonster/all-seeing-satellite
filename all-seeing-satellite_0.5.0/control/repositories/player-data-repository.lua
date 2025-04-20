-- If already defined, return
if _player_data_repository and _player_data_repository.all_seeing_satellite then
  return _player_data_repository
end

local Log = require("libs.log.log")
local Character_Data_Repository = require("control.repositories.character-data-repository")
local Player_Data = require("control.data.player-data")

local player_data_repository = {}

function player_data_repository.save_player_data(player_index, optionals)
  Log.debug("player_data_repository.save_player_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = Player_Data:new()

  if (not game) then return return_val end
  if (not player_index) then return return_val end

  optionals = optionals or {
    player = game.get_player(player_index)
  }

  local player = optionals.player or game.get_player(player_index)
  if (not player or not player.valid) then return return_val end

  if (not storage) then return end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then storage.all_seeing_satellite.player_data[player_index] = return_val end

  return_val = storage.all_seeing_satellite.player_data[player_index]
  local character_data = Character_Data_Repository.save_character_data(player_index)

  return_val.valid = true
  return_val.player_index = player.index
  return_val.character_data = character_data.valid and character_data or return_val.character_data
  return_val.controller_type = defines.controllers.character
  return_val.surface_index = player.surface_index
  return_val.position = player.position
  return_val.vehicle = player.vehicle
  return_val.physical_surface_index = player.physical_surface_index
  return_val.physical_position = player.physical_position
  return_val.physical_vehicle = player.physical_vehicle

  return player_data_repository.update_player_data(return_val)
end

function player_data_repository.update_player_data(update_data, optionals)
  Log.debug("player_data_repository.update_player_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Player_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end
  if (not update_data.player_index) then return return_val end

  optionals = optionals or {}

  local player_index = update_data.player_index

  if (not storage) then return end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.player_data[player_index] = return_val
    player_data_repository.save_player_data(player_index)
  end

  local player_data = storage.all_seeing_satellite.player_data[player_index]

  for k,v in pairs(update_data) do
    player_data[k] = v
  end

  player_data.updated = game.tick

  -- Don't think this is necessary, but oh well
  storage.all_seeing_satellite.player_data[player_index] = player_data

  return player_data
end

function player_data_repository.delete_player_data(player_index, optionals)
  Log.debug("player_data_repository.delete_player_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end
  if (not player_index) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (storage.all_seeing_satellite.player_data[player_index] ~= nil) then
    storage.all_seeing_satellite.player_data[player_index] = nil
  end
  return_val = true

  return return_val
end

function player_data_repository.get_player_data(player_index, optionals)
  Log.debug("player_data_repository.get_player_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = Player_Data:new()

  if (not player_index) then return return_val end
  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.player_data[player_index] = return_val
    player_data_repository.save_player_data(player_index)
  end

  return storage.all_seeing_satellite.player_data[player_index]
end

function player_data_repository.get_all_player_data(optionals)
  Log.debug("player_data_repository.get_all_player_data")
  Log.info(optionals)

  if (not game) then return end

  optionals = optionals or {}

  if (not storage) then return end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end

  return storage.all_seeing_satellite.player_data
end

player_data_repository.all_seeing_satellite = true

local _player_data_repository = player_data_repository

return player_data_repository
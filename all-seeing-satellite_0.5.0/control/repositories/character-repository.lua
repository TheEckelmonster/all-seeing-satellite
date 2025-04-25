-- If already defined, return
if _character_repository and _character_repository.all_seeing_satellite then
  return _character_repository
end

local Log = require("libs.log.log")
local Character_Data = require("control.data.character-data")
local Player_Data = require("control.data.player-data")

local character_repository = {}

function character_repository.save_character_data(player_index, optionals)
  Log.debug("character_repository.save_character_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = Character_Data:new()

  if (not game) then return return_val end
  if (not player_index) then return return_val end

  optionals = optionals or {
    player = game.get_player(player_index)
  }

  local player = optionals.player or game.get_player(player_index)
  if (not player or not player.valid) then return return_val end
  local force = player.force
  if (not force or not force.valid) then return return_val end

  local character = player.character
  if (not character) then return return_val end

  if (not storage) then return return_val end
  if (not storage.player_data) then storage.player_data = {} end
  if (not storage.player_data[force.index]) then storage.player_data[force.index] = {} end
  if (not storage.player_data[force.index][player_index]) then storage.player_data[force.index][player_index] = Player_Data:new() end
  if (not storage.player_data[force.index][player_index].character_data) then storage.player_data[force.index][player_index].character_data = return_val end

  return_val = storage.player_data[force.index][player_index].character_data
  return_val.valid = true
  return_val.player_index = player_index
  return_val.unit_number = character.unit_number
  return_val.character = character
  return_val.surface_index = character.surface_index
  return_val.position = character.position

  return character_repository.update_character_data(return_val)
end

function character_repository.update_character_data(update_data, optionals)
  Log.debug("character_repository.update_character_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Character_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end
  if (not update_data.player_index) then return return_val end

  local player_index = update_data.player_index

  optionals = optionals or {
    player = game.get_player(player_index)
  }

  local player = optionals.player or game.get_player(player_index)
  if (not player or not player.valid) then return return_val end
  local force = player.force
  if (not force or not force.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.player_data) then storage.player_data = {} end
  if (not storage.player_data[force.index]) then storage.player_data[force.index] = {} end
  if (not storage.player_data[force.index][player_index]) then storage.player_data[force.index][player_index] = Player_Data:new() end
  if (not storage.player_data[force.index][player_index].character_data) then
    -- If it doesn't exist, generate it
    character_repository.save_character_data(player_index)
  end

  local character_data = storage.player_data[force.index][player_index].character_data

  for k,v in pairs(update_data) do
    character_data[k] = v
  end

  character_data.updated = game.tick

  return character_data
end

function character_repository.delete_character_data(player_index, optionals)
  Log.debug("character_repository.delete_character_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end
  if (not player_index) then return return_val end

  optionals = optionals or {
    player = game.get_player(player_index)
  }

  local player = optionals.player or game.get_player(player_index)
  if (not player or not player.valid) then return return_val end
  local force = player.force
  if (not force or not force.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.player_data) then storage.player_data = {} end
  if (not storage.player_data[force.index]) then storage.player_data[force.index] = {} end
  if (storage.player_data[force.index][player_index] ~= nil) then
    storage.player_data[force.index][player_index] = nil
  end
  return_val = true

  return return_val
end

function character_repository.get_character_data(player_index, optionals)
  Log.debug("character_repository.get_character_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = Character_Data:new()

  if (not player_index) then return return_val end
  if (not game) then return return_val end

  optionals = optionals or {
    player = game.get_player(player_index)
  }

  local player = optionals.player or game.get_player(player_index)
  if (not player or not player.valid) then return return_val end
  local force = player.force
  if (not force or not force.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.player_data) then storage.player_data = {} end
  if (not storage.player_data[force.index]) then storage.player_data[force.index] = {} end
  if (not storage.player_data[force.index][player_index]) then storage.player_data[force.index][player_index] = Player_Data:new() end

  return storage.player_data[force.index][player_index].character_data
end

function character_repository.get_all_character_data(optionals)
  Log.debug("character_repository.get_all_character_data")
  Log.info(optionals)

  local return_val = {}

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.player_data) then storage.player_data = {} end

  local all_player_data = {}

  for force, f_player_data in pairs(storage.player_data) do
    for player_index, player_data in pairs(f_player_data) do
      table.insert(all_player_data, player_data)
    end
  end

  for player_index, player_data in pairs(all_player_data) do
    table.insert(return_val, player_data.character_data)
  end

  return return_val
end

character_repository.all_seeing_satellite = true

local _character_repository = character_repository

return character_repository
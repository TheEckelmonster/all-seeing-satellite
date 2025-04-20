-- If already defined, return
if _character_data_repository and _character_data_repository.all_seeing_satellite then
  return _character_data_repository
end

local Log = require("libs.log.log")
local Character_Data = require("control.data.character-data")

local character_data_repository = {}

--- @param player_index int
--- @param optionals table table containing any optional parameters to be used/considered
--- @return boolean true if successful, false if not
function character_data_repository.save_character_data(player_index, optionals)
  Log.debug("character_data_repository.save_character_data")
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

  local character = player.character
  if (not character) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then storage.all_seeing_satellite.player_data[player_index] = {} end
  if (not storage.all_seeing_satellite.player_data[player_index].character_data) then storage.all_seeing_satellite.player_data[player_index].character_data = return_val end

  return_val = storage.all_seeing_satellite.player_data[player_index].character_data
  return_val.valid = true
  return_val.player_index = player_index
  return_val.unit_number = character.unit_number
  return_val.character = character
  return_val.surface_index = character.surface_index
  return_val.position = character.position

  return character_data_repository.update_character_data(return_val)
end

function character_data_repository.update_character_data(update_data, optionals)
  Log.debug("character_data_repository.update_character_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Character_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end
  if (not update_data.player_index) then return return_val end

  optionals = optionals or {}

  local player_index = update_data.player_index

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then storage.all_seeing_satellite.player_data[player_index] = {} end
  if (not storage.all_seeing_satellite.player_data[player_index].character_data) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.player_data[player_index].character_data = return_val
    player_data_repository.save_character_data({ player_index = player_index })
  end

  local character_data = storage.all_seeing_satellite.player_data[player_index].character_data

  for k,v in pairs(update_data) do
    character_data[k] = v
  end

  character_data.updated = game.tick

  -- Don't think this is necessary, but oh well
  storage.all_seeing_satellite.player_data[player_index].character_data = character_data

  return character_data
end

function character_data_repository.delete_character_data(player_index, optionals)
  Log.debug("character_data_repository.delete_character_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end
  if (not player_index) then return return_val end

  optionals = optionals or {}

  if (not storage) then return end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (storage.all_seeing_satellite.player_data[player_index] ~= nil) then
    storage.all_seeing_satellite.player_data[player_index] = nil
  end
  return_val = true

  return return_val
end

function character_data_repository.get_character_data(player_index, optionals)
  Log.debug("character_data_repository.get_character_data")
  Log.info(player_index)
  Log.info(optionals)

  local return_val = Character_Data:new()

  if (not player_index) then return return_val end
  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end
  if (not storage.all_seeing_satellite.player_data[player_index]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.player_data[player_index] = return_val
    player_repository.save_player_data(player_index)
  end

  return storage.all_seeing_satellite.player_data[player_index]
end

function character_data_repository.get_all_character_data(optionals)
  Log.debug("character_data_repository.get_all_character_data")
  Log.info(optionals)

  local return_val = {}

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.player_data) then storage.all_seeing_satellite.player_data = {} end

  local all_player_data = storage.all_seeing_satellite.player_data

  for player_index, player_data in pairs(all_player_data) do
    table.insert(return_val, player_data.character_data)
  end

  return return_val
end

character_data_repository.all_seeing_satellite = true

local _character_data_repository = character_data_repository

return character_data_repository
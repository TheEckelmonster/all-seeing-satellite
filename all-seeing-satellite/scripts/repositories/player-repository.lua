local Character_Repository = require("scripts.repositories.character-repository")
local Player_Data = require("scripts.data.player-data")
local String_Utils = require("scripts.utils.string-utils")

local player_repository = {}

function player_repository.save_player_data(player_index, optionals)
    Log.debug("player_repository.save_player_data")
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
    local force = player.force
    if (not force or not force.valid) then return return_val end
    local surface = player.surface
    if (not surface or not surface.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.player_data) then storage.player_data = {} end
    if (not storage.player_data[player_index]) then storage.player_data[player_index] = return_val end

    return_val = storage.player_data[player_index]
    local character_data = Character_Repository.save_character_data(player_index)
    Log.info(character_data)

    return_val.character_data = character_data.valid and character_data or return_val.character_data
    return_val.controller_type = defines.controllers.character
    return_val.force_index = force.index

    return_val.in_space = return_val.in_space or String_Utils.find_invalid_substrings(surface.name)
    if (return_val.in_space ~= nil) then
        return_val.in_space = return_val.in_space
    else
        return_val.in_space = String_Utils.find_invalid_substrings(surface.name)
    end
    return_val.position = player.position
    return_val.physical_surface_index = player.physical_surface_index
    return_val.physical_position = player.physical_position
    return_val.physical_vehicle = player.physical_vehicle
    return_val.player_index = player.index
    return_val.satellite_mode_allowed = return_val.satellite_mode_allowed or false
    return_val.satellite_mode_stashed = return_val.satellite_mode_stashed or false
    return_val.surface_index = player.surface_index
    return_val.vehicle = player.vehicle
    -- return_val.valid = true
    return_val.valid = return_val.character_data and return_val.character_data.valid

    return player_repository.update_player_data(return_val)
end

function player_repository.update_player_data(update_data, optionals)
    Log.debug("player_repository.update_player_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Player_Data:new()

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
    if (not storage.player_data[player_index]) then
        -- If it doesn't exist, generate it
        player_repository.save_player_data(player_index)
    end

    local player_data = storage.player_data[player_index]

    for k, v in pairs(update_data) do
        player_data[k] = v
    end

    player_data.updated = game.tick

    return player_data
end

function player_repository.delete_player_data(player_index, optionals)
    Log.debug("player_repository.delete_player_data")
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
    if (storage.player_data[player_index] ~= nil) then
        storage.player_data[player_index] = nil
    end
    return_val = true

    return return_val
end

function player_repository.get_player_data(player_index, optionals)
    Log.debug("player_repository.get_player_data")
    Log.info(player_index)
    Log.info(optionals)

    local return_val = Player_Data:new()

    if (not player_index) then return return_val end
    if (not game) then return return_val end

    optionals = optionals or {
        player = game.get_player(player_index)
    }

    local player = optionals.player or game.get_player(player_index)
    if (not player or not player.valid) then return return_val end
    local force = player.force
    if (not force or not force.valid) then return return_val end
    local surface = player.surface
    if (not surface or not surface.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.player_data) then storage.player_data = {} end
    if (not storage.player_data[player_index]) then
        -- If it doesn't exist, generate it
        player_repository.save_player_data(player_index)
    end

    return storage.player_data[player_index]
end

function player_repository.get_all_player_data(optionals)
    Log.debug("player_repository.get_all_player_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.player_data) then storage.player_data = {} end

    return storage.player_data
end

return player_repository
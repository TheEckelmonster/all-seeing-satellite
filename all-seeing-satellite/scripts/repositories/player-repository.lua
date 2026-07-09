local storage
local player_data

local game
local get_player

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.player_data = storage.player_data or {}
    player_data = storage.player_data

    game = __game or _ENV.game
    get_player = get_player or game.get_player

    return game
end

local pairs = pairs

local defines = defines
local character_controller = defines.controllers.character

local Character_Repository = require("scripts.repositories.character-repository")
local save_character_data = Character_Repository.save_character_data
local Player_Data = require("scripts.data.player-data")
local new_Player_Data = Player_Data.new
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local player_repository = {}
player_repository.name = "player_repository"
player_repository.set_game = set_game

function player_repository.save_player_data(player_index)
    -- Log.debug("player_repository.save_player_data")
    -- Log.info(player_index)

    local return_val = nil

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end
    local surface = player.surface
    if (not surface or not surface.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    player_data[player_index] = player_data[player_index] or new_Player_Data(Player_Data, nil)

    return_val = player_data[player_index]
    local character_data = save_character_data(player_index)

    return_val.character_data = character_data or return_val.character_data
    return_val.controller_type = character_controller
    return_val.force_index = force.index

    return_val.in_space = return_val.in_space or find_invalid_substrings(surface.name)
    if (return_val.in_space ~= nil) then
        return_val.in_space = return_val.in_space
    else
        return_val.in_space = find_invalid_substrings(surface.name)
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

    return return_val
end

function player_repository.update_player_data(update_data)
    -- Log.debug("player_repository.update_player_data")
    -- Log.info(update_data)

    local return_val = nil

    if (not update_data) then return end
    if (not update_data.player_index) then return end

    local player_index = update_data.player_index

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return return_val end
    if (not player_data[player_index]) then
        -- If it doesn't exist, generate it
        player_repository.save_player_data(player_index)
    end

    return_val = player_data[player_index]
    if (not return_val) then return end

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = (game or set_game()).tick

    return return_val
end

function player_repository.delete_player_data(player_index)
    -- Log.debug("player_repository.delete_player_data")
    -- Log.info(player_index)

    local return_val = false

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return return_val end
    if (player_data[player_index] ~= nil) then
        player_data[player_index] = nil
    end
    return_val = true

    return return_val
end

function player_repository.get_player_data(player_index)
    -- Log.debug("player_repository.get_player_data")
    -- Log.info(player_index)

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end
    local surface = player.surface
    if (not surface or not surface.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    if (not player_data[player_index]) then
        -- If it doesn't exist, generate it
        player_repository.save_player_data(player_index)
    end

    return player_data[player_index]
end

function player_repository.get_all_player_data()
    -- Log.debug("player_repository.get_all_player_data")

    player_data = player_data or set_game() and player_data
    if (not player_data) then return {} end

    return player_data
end

function player_repository.init(__storage) storage = __storage end

return player_repository
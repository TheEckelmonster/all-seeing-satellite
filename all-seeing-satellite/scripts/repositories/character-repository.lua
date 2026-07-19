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

local Character_Data = require("scripts.data.character-data")
local new_Character_Data = Character_Data.new
local Player_Data = require("scripts.data.player-data")
local new_Player_Data = Player_Data.new

local character_repository = {}
character_repository.name = "character_repository"
character_repository.set_game = character_repository.set_game

function character_repository.save_character_data(player_index)
    -- Log.debug("character_repository.save_character_data")
    -- Log.info(player_index)

    local return_val = new_Character_Data(Character_Data, nil)

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end

    local character = player.character
    if (not character) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    if (not player_data[player_index]) then player_data[player_index] = new_Player_Data(Player_Data, nil) end
    if (not player_data[player_index].character_data) then player_data[player_index].character_data = return_val end

    return_val = player_data[player_index].character_data
    return_val.player_index = player_index
    return_val.unit_number = character.unit_number
    return_val.character = character
    return_val.character_name = character.name
    return_val.surface_index = character.surface_index
    return_val.position = character.position

    return_val.created = (game or set_game()).tick or 0

    return return_val
end

function character_repository.update_character_data(update_data)
    -- Log.debug("character_repository.update_character_data")
    -- Log.info(update_data)
    if (not update_data) then return end
    if (not update_data.player_index) then return end

    local player_index = update_data.player_index

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    if (not player_data[player_index]) then player_data[player_index] = new_Player_Data(Player_Data, nil) end
    if (not player_data[player_index].character_data) then
        -- If it doesn't exist, generate it
        if (not character_repository.save_character_data(player_index)) then return end
    end

    local character_data = player_data[player_index].character_data

    for k, v in pairs(update_data) do
        character_data[k] = v
    end

    character_data.updated = game.tick

    return character_data
end

function character_repository.delete_character_data(player_index)
    -- Log.debug("character_repository.delete_character_data")
    -- Log.info(player_index)

    local return_val = false

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    if (player_data[player_index] ~= nil) then
        player_data[player_index] = nil
    end
    return_val = true

    return return_val
end

function character_repository.get_character_data(player_index)
    -- Log.debug("character_repository.get_character_data")
    -- Log.info(player_index)

    if (not player_index) then return end

    local player = (game or set_game()) and get_player and get_player(player_index) or nil
    if (not player or not player.valid) then return end

    player_data = player_data or set_game() and player_data
    if (not player_data) then return end
    if (not player_data[player_index]) then player_data[player_index] = new_Player_Data(Player_Data, nil) end

    return player_data[player_index].character_data
end

function character_repository.get_all_character_data(optionals)
    -- Log.debug("character_repository.get_all_character_data")

    local return_val = {}

    player_data = player_data or set_game() and player_data
    if (not player_data) then return return_val end

    local count = 1

    for player_index, player_data in pairs(player_data) do
        return_val[count] = player_data.character_data
        count = count + 1
    end

    return return_val
end

function character_repository.init(__storage) storage = __storage end

return character_repository
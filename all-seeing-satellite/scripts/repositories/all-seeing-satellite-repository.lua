local storage
local all_seeing_satellite_data

local game

local All_Seeing_Satellite_Data = require("scripts.data.all-seeing-satellite-data")
local new_All_Seeing_Satelite_Data = All_Seeing_Satellite_Data.new

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.all_seeing_satellite = storage.all_seeing_satellite or new_All_Seeing_Satelite_Data(All_Seeing_Satellite_Data)
    all_seeing_satellite_data = storage.all_seeing_satellite

    game = __game or _ENV.game

    return game
end

local pairs = pairs

local all_seeing_satellite_repository = {}
all_seeing_satellite_repository.name = "all_seeing_satellite_repository"
all_seeing_satellite_repository.set_game = set_game

function all_seeing_satellite_repository.save_all_seeing_satellite_data()
    -- Log.debug("all_seeing_satellite_repository.save_all_seeing_satellite_data")
    return all_seeing_satellite_data or set_game() and all_seeing_satellite_data
end

function all_seeing_satellite_repository.update_all_seeing_satellite_data(update_data)
    -- Log.debug("all_seeing_satellite_repository.update_all_seeing_satellite_data")
    -- Log.info(update_data)
    if (not update_data) then return end

    all_seeing_satellite_data = all_seeing_satellite_data or set_game() and all_seeing_satellite_data

    for k, v in pairs(update_data) do all_seeing_satellite_data[k] = v end

    all_seeing_satellite_data.updated = (game or set_game()).tick

    return all_seeing_satellite_data
end

function all_seeing_satellite_repository.delete_all_seeing_satellite_data()
    -- Log.debug("all_seeing_satellite_repository.delete_all_seeing_satellite_data")
    if (not storage) then return false end
    storage.all_seeing_satellite = nil
    return true
end

function all_seeing_satellite_repository.get_all_seeing_satellite_data()
    -- Log.debug("all_seeing_satellite_repository.get_all_seeing_satellite_data")
    return all_seeing_satellite_data or set_game() and all_seeing_satellite_data
end

function all_seeing_satellite_repository.init(__storage) storage = __storage end

return all_seeing_satellite_repository
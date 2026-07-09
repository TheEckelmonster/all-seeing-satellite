local storage
local satellite_meta_data_repository

local game
local get_surface

local planets_dictionary

local Constants = Constants

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.satellite_meta_data_repository = storage.satellite_meta_data_repository or {}
    satellite_meta_data_repository = storage.satellite_meta_data_repository

    game = __game or _ENV.game
    get_surface = game.get_surface

    if (not Constants.mod_data or not Constants.mod_data.planets_dictionary) then Constants.get_planet_data({ reindex = true }) end
    planets_dictionary = Constants.mod_data.planets_dictionary

    return game
end

local pairs = pairs
local type = type

local STRING = Types.STRING

local Satellite_Meta_Data = require("scripts.data.satellite.satellite-meta-data")
local new_Satellite_Meta_Data = Satellite_Meta_Data.new
local Satellite_Toggle_Data = require("scripts.data.satellite.satellite-toggle-data")
local new_Satellite_Toggle_Data = Satellite_Toggle_Data.new
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local satellite_meta_repository = {}
satellite_meta_repository.name = "satellite_meta_repository"
satellite_meta_repository.set_game = set_game

function satellite_meta_repository.save_satellite_meta_data(planet_name)
    -- Log.debug("satellite_meta_repository.save_satellite_meta_data")
    -- Log.info(planet_name)

    local return_val = new_Satellite_Meta_Data(Satellite_Meta_Data)

    if (not planet_name or type(planet_name) ~= STRING) then return end
    if (find_invalid_substrings(planet_name)) then return end

    planets_dictionary = planets_dictionary or set_game() and planets_dictionary

    local surface = (game or set_game()) and get_surface and get_surface(planet_name) or nil
    if (not surface or not surface.valid) then return end
    if (surface.platform) then return end

    satellite_meta_data_repository = satellite_meta_data_repository or set_game() and satellite_meta_data_repository
    satellite_meta_data_repository[planet_name] = satellite_meta_data_repository[planet_name] or return_val

    return_val = satellite_meta_data_repository[planet_name]
    return_val.planet_name = planet_name
    return_val.surface_index = surface.index

    return_val.satellites_toggled = new_Satellite_Toggle_Data(Satellite_Toggle_Data, {
        planet_name = planet_name,
        toggle = false,
    })

    return_val.updated = (game or set_game()).tick or 0

    return return_val
end

function satellite_meta_repository.update_satellite_meta_data(update_data, planet_name)
    -- Log.debug("satellite_meta_repository.update_satellite_meta_data")
    -- Log.info(update_data)

    if (not update_data) then return end
    if (not planet_name or type(planet_name) ~= STRING) then return end

    satellite_meta_data_repository = satellite_meta_data_repository or set_game() and satellite_meta_data_repository
    satellite_meta_data_repository[planet_name] = satellite_meta_data_repository[planet_name] or satellite_meta_repository.save_satellite_meta_data(planet_name)

    local satellite_meta_data = satellite_meta_data_repository[planet_name]

    for k, v in pairs(update_data) do satellite_meta_data[k] = v end

    satellite_meta_data.updated = (game or set_game()).tick

    return satellite_meta_data
end

function satellite_meta_repository.delete_satellite_meta_data(planet_name)
    -- Log.debug("satellite_meta_repository.delete_satellite_meta_data")
    -- Log.info(planet_name)

    if (not planet_name or type(planet_name) ~= STRING) then return end

    satellite_meta_data_repository = satellite_meta_data_repository or set_game() and satellite_meta_data_repository

    if (satellite_meta_data_repository[planet_name] ~= nil) then satellite_meta_data_repository[planet_name] = nil end

    return true
end

function satellite_meta_repository.get_satellite_meta_data(planet_name)
    -- Log.debug("satellite_meta_repository.get_satellite_meta_data")
    -- Log.info(planet_name)

    if (not planet_name or type(planet_name) ~= STRING) then return end

    satellite_meta_data_repository = satellite_meta_data_repository or set_game() and satellite_meta_data_repository
    return satellite_meta_data_repository[planet_name]
end

function satellite_meta_repository.get_all_satellite_meta_data()
    -- Log.debug("satellite_meta_repository.get_all_satellite_meta_data")
    return satellite_meta_data_repository or set_game() and satellite_meta_data_repository
end

function satellite_meta_repository.init(__storage) storage = __storage end

return satellite_meta_repository
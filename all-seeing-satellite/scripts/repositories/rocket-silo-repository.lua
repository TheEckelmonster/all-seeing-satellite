local storage

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game

    return game
end

local pairs = pairs

local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local new_Rocket_Silo_Data = Rocket_Silo_Data.new
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data

local rocket_silo_repository = {}
rocket_silo_repository.name = "rocket_silo_repository"
rocket_silo_repository.set_game = rocket_silo_repository.set_game

function rocket_silo_repository.save_rocket_silo_data(rocket_silo)
    -- Log.debug("rocket_silo_repository.save_rocket_silo_data")
    -- Log.info(rocket_silo)

    local return_val = new_Rocket_Silo_Data(Rocket_Silo_Data, nil)

    if (not rocket_silo or not rocket_silo.valid) then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    if (not rocket_silo.force or not rocket_silo.force.valid) then return end

    local planet_name = rocket_silo.surface.name
    if (not planet_name) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end
    satellite_meta_data.rocket_silos = satellite_meta_data.rocket_silos or {}

    local rocket_silos = satellite_meta_data.rocket_silos

    return_val.unit_number = rocket_silo.unit_number
    return_val.entity = rocket_silo
    return_val.surface = rocket_silo.surface
    return_val.surface_index = rocket_silo.surface.index
    return_val.force = rocket_silo.force
    return_val.force_index = rocket_silo.force.index

    rocket_silos[return_val.unit_number] = return_val

    return return_val
end

function rocket_silo_repository.update_rocket_silo_data(update_data)
    -- Log.debug("rocket_silo_repository.update_rocket_silo_data")
    -- Log.info(update_data)

    local return_val = new_Rocket_Silo_Data(Rocket_Silo_Data, nil)

    if (not update_data.surface or not update_data.surface.valid) then return end

    local planet_name = update_data.surface.name
    -- if (not planet_name) then return return_val end
    if (not planet_name) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end
    satellite_meta_data.rocket_silos = satellite_meta_data.rocket_silos or {}

    local rocket_silos = satellite_meta_data.rocket_silos

    return_val = rocket_silos[update_data.unit_number]

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = (game or set_game()).tick

    return return_val
end

function rocket_silo_repository.delete_rocket_silo_data_by_unit_number(planet_name, unit_number)
    -- Log.debug("rocket_silo_repository.delete_rocket_silo_data_by_unit_number")
    -- Log.info(planet_name)
    -- Log.info(unit_number)

    local return_val = false

    if (not planet_name) then return end
    if (not unit_number) then return end

    if (not storage) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end
    satellite_meta_data.rocket_silos = satellite_meta_data.rocket_silos or {}

    local rocket_silos = satellite_meta_data.rocket_silos

    rocket_silos[unit_number] = nil

    return_val = true

    return return_val
end

function rocket_silo_repository.get_rocket_silo_data(planet_name, unit_number)
    -- Log.debug("rocket_silo_repository.get_charaget_rocket_silo_datacter_data")
    -- Log.info(planet_name)
    -- Log.info(unit_number)

    if (not planet_name) then return end
    if (not unit_number) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end
    satellite_meta_data.rocket_silos = satellite_meta_data.rocket_silos or {}

    local rocket_silos = satellite_meta_data.rocket_silos

    return rocket_silos[unit_number]
end

function rocket_silo_repository.init(__storage) storage = __storage end

return rocket_silo_repository
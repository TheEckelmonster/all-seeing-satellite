local storage

local game
local get_surface

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_surface = game.get_surface

    return game
end

local pairs = pairs
local table_remove = table.remove
local type = type

local TABLE = "table"
local STRING = "string"
local NUMBER = "number"

local Constants = Constants

local Satellite_Data = require("scripts.data.satellite.satellite-data")
local new_Satellite_Data = Satellite_Data.new
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local get_all_satellite_meta_data = Satellite_Meta_Repository.get_all_satellite_meta_data

local satellite_repository = {}
satellite_repository.name = "satellite_repository"
satellite_repository.set_game = set_game

function satellite_repository.save_satellite_data(data, optionals)
    -- Log.debug("satellite_repository.save_satellite_data")
    -- Log.info(data)

    local return_val = new_Satellite_Data(Satellite_Data)

    if (not data or type(data) ~= TABLE) then return end
    if (not data.entity or type(data.entity) ~= TABLE) then return end
    if (not data.planet_name or type(data.planet_name) ~= STRING) then return end
    if (not data.force or not data.force.valid) then return return_val end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end

    local surface = (game or set_game()) and get_surface and get_surface(planet_name) or nil
    if (not surface or not surface.valid) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    return_val.cargo_pod = nil
    return_val.cargo_pod_unit_number = data.cargo_pod_unit_number
    return_val.entity = data.entity
    return_val.force = data.force
    return_val.force_index = data.force_index
    return_val.planet_name = surface.name
    return_val.tick_to_die = data.death_tick or data.tick_to_die or 1
    return_val.tick_off_cooldown = (game or set_game()).tick
    return_val.surface_index = surface.index

    -- table_insert(satellite_meta_data.satellites, return_val)
    local satellites = satellite_meta_data.satellites
    satellites[#satellites+1] = return_val

    satellite_repository.add_satellite_data_to_cooldown({
        satellite = return_val,
        planet_name = planet_name,
    })

    if (type(return_val.cargo_pod_unit_number) == NUMBER) then
        satellite_meta_data.satellites_in_transit[return_val.cargo_pod_unit_number] = nil
        satellite_meta_data.satellite_dictionary[return_val.cargo_pod_unit_number] = return_val
    end

    -- return satellite_repository.update_satellite_data(return_val, return_val.cargo_pod_unit_number)
    return return_val
end

function satellite_repository.save_in_transit_satellite_data(data, optionals)
    -- Log.debug("satellite_repository.save_in_transit_satellite_data")
    -- Log.info(data)

    local return_val = new_Satellite_Data(Satellite_Data)

    if (not data or type(data) ~= TABLE) then return end
    if (not data.entity or type(data.entity) ~= TABLE) then return end
    if (not data.planet_name or type(data.planet_name) ~= STRING) then return end
    if (not data.force or not data.force.valid) then
        data.force = (game or set_game()).forces["player"]
        if (not data.force or not data.force.valid) then data.force = { valid = false, index = -1 } end
    end
    if (not data.force.index or type(data.force.index) ~= NUMBER) then data.force.index = -1 end

    local planet_name = data.planet_name
    if (not planet_name) then return end

    local surface = (game or set_game()) and get_surface and get_surface(planet_name) or nil
    if (not surface or not surface.valid) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    return_val.cargo_pod = data.cargo_pod
    return_val.cargo_pod_unit_number = data.cargo_pod_unit_number
    return_val.entity = data.entity
    return_val.force = data.force
    return_val.force_name = data.force.name
    return_val.force_index = data.force_index
    return_val.planet_name = planet_name
    return_val.tick_to_die = data.death_tick or data.tick_to_die or 1
    return_val.tick_off_cooldown = (game or set_game()).tick
    return_val.surface_index = surface.index

    satellite_meta_data.satellites_in_transit[return_val.cargo_pod_unit_number] = return_val
    satellite_meta_data.satellite_dictionary[return_val.cargo_pod_unit_number] = return_val

    return return_val
end

function satellite_repository.add_satellite_data_to_cooldown(data, optionals)
    -- Log.debug("satellite_repository.add_satellite_data_to_cooldown")
    -- Log.info(data)

    local return_val = false

    if (not data or type(data) ~= TABLE) then return end
    if (not data.satellite or type(data.satellite) ~= TABLE) then return end
    if (not data.planet_name or type(data.planet_name) ~= STRING) then return end

    local satellite = data.satellite
    if (not satellite) then return end

    local planet_name = data.planet_name
    if (not planet_name) then return end

    local surface = (game or set_game()) and get_surface and get_surface(planet_name) or nil
    if (not surface or not surface.valid) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    local tick = (game or set_game()).tick
    local max = -1
    for k, v in pairs(satellite_meta_data.satellites_cooldown) do
        if (k > max) then max = k end
    end
    tick = max + 1

    satellite_meta_data.satellites_cooldown[tick] = satellite

    return_val = true
    return return_val
end

function satellite_repository.update_satellite_data(update_data, unit_number, optionals)
    -- Log.debug("satellite_repository.update_satellite_data")
    -- Log.info(update_data)

    local return_val = new_Satellite_Data(Satellite_Data)

    if (not update_data or type(update_data) ~= TABLE) then return end
    if (not update_data.planet_name or type(update_data.planet_name) ~= STRING) then return end

    local planet_name = update_data.planet_name
    if (not planet_name) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end
    -- Use the provided index if it exists; otherwise update the most recently added satellite
    local index = #satellite_meta_data.satellites

    if (type(unit_number) ~= NUMBER) then unit_number = -1 end

    local found = false
    for i, satellite in pairs(satellite_meta_data.satellites) do
        if (satellite.cargo_pod_unit_number == unit_number) then
            return_val = satellite
            found = true
            break
        end
    end

    if (not found) then
        for i, satellite in pairs(satellite_meta_data.satellites) do
            if (i == index) then
                return_val = satellite
                break
            end
        end
    end

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = (game or set_game()).tick

    return return_val
end

function satellite_repository.delete_satellite_data_by_index(planet_name, index)
    -- Log.debug("satellite_repository.delete_satellite_data_by_index")
    -- Log.info(data)

    if (not planet_name or not index) then return end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    if (index > #satellite_meta_data.satellites) then return end

    local satellite = satellite_meta_data.satellites[index]

    table_remove(satellite_meta_data.satellites, index)

    for k, _satellite in pairs(satellite_meta_data.satellites_cooldown) do
        if (_satellite == satellite) then
            satellite_meta_data.satellites_cooldown[k] = nil
            break
        end
    end

    satellite_meta_data.updated = (game or set_game()).tick

    return true
end

function satellite_repository.delete_satellite_data_from_cooldown(data, optionals)
    -- Log.debug("satellite_repository.delete_satellite_data_from_cooldown")
    -- Log.info(data)

    local return_val = false

    if (not data or type(data) ~= TABLE) then return end
    if (not data.planet_name or type(data.planet_name) ~= STRING) then return end
    if (not data.id or type(data.id) ~= NUMBER) then return end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end
    local id = data.id
    if (id < 1) then return return_val end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    satellite_meta_data.satellites_cooldown[id] = nil

    satellite_meta_data.updated = (game or set_game()).tick

    return_val = true
    return return_val
end

function satellite_repository.get_satellite_data(data, optionals)
    -- Log.debug("satellite_repository.get_satellite_data")
    -- Log.info(data)
    -- Log.info(optionals)

    local return_val = new_Satellite_Data(Satellite_Data)

    if (not data or type(data) ~= TABLE) then return end
    if (not data.planet_name or type(data.planet_name) ~= STRING) then return end
    if (not data.index or type(data.index) ~= NUMBER) then return end

    local planet_name = data.planet_name
    if (not planet_name) then return end
    local index = data.index
    if (index < 1) then
        index = 1
    end

    local satellite_meta_data = get_satellite_meta_data(planet_name)
    if (not satellite_meta_data) then return end

    if (type(satellite_meta_data.satellites) == TABLE) then
        for i, satellite_data in pairs(satellite_meta_data.satellites) do
            if (i == index) then
                return_val = satellite_data; break
            end
        end
    end

    return return_val
end

function satellite_repository.get_all_satellite_data(optionals)
    -- Log.debug("satellite_repository.get_all_satellite_data")
    -- Log.info(optionals)

    local return_val = {}

    local all_satellite_meta_data = get_all_satellite_meta_data()

    for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
        return_val[planet_name] = {}
        for _, satellite_data in pairs(satellite_meta_data.satellites) do
            return_val[planet_name][#return_val[planet_name]+1] = satellite_data
        end
    end

    return return_val
end

function satellite_repository.init(__storage) storage = __storage end

return satellite_repository
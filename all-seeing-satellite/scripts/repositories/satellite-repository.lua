local Satellite_Data = require("scripts.data.satellite.satellite-data")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")

local satellite_repository = {}

function satellite_repository.save_satellite_data(data, optionals)
    Log.debug("satellite_repository.save_satellite_data")
    Log.info(data)
    Log.info(optionals)

    local return_val = Satellite_Data:new()

    if (not game) then return return_val end
    if (not data or type(data) ~= "table") then return return_val end
    if (not data.entity or type(data.entity) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end
    if (not data.force or not data.force.valid) then
        data.force = game.forces["player"]
        if (not data.force or not data.force.valid) then data.force = { valid = false, index = -1 } end
    end
    if (not data.force.index or type(data.force.index) ~= "number") then data.force.index = -1 end

    optionals = optionals or {}

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end

    local surface = game.get_surface(planet_name)
    if (not surface or not surface.valid) then return end

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not Satellite_Meta_Repository.save_satellite_meta_data(planet_name).valid) then return return_val end
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]

    return_val.cargo_pod = nil
    return_val.cargo_pod_unit_number = data.cargo_pod_unit_number
    return_val.entity = data.entity
    return_val.force = data.force
    return_val.force_index = data.force_index
    return_val.planet_name = surface.name
    return_val.tick_to_die = data.death_tick or data.tick_to_die or 1
    return_val.tick_off_cooldown = game.tick
    return_val.surface_index = surface.index

    return_val.valid = true

    table.insert(satellite_meta_data.satellites, return_val)

    satellite_repository.add_satellite_data_to_cooldown({
        satellite = return_val,
        planet_name = planet_name,
    })

    if (type(return_val.cargo_pod_unit_number) == "number") then
        satellite_meta_data.satellites_in_transit[return_val.cargo_pod_unit_number] = nil
        satellite_meta_data.satellite_dictionary[return_val.cargo_pod_unit_number] = return_val
    end

    return satellite_repository.update_satellite_data(return_val, return_val.cargo_pod_unit_number)
end

function satellite_repository.save_in_transit_satellite_data(data, optionals)
    Log.debug("satellite_repository.save_in_transit_satellite_data")
    Log.info(data)
    Log.info(optionals)

    local return_val = Satellite_Data:new()

    if (not game) then return return_val end
    if (not data or type(data) ~= "table") then return return_val end
    if (not data.entity or type(data.entity) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end
    if (not data.force or not data.force.valid) then
        data.force = game.forces["player"]
        if (not data.force or not data.force.valid) then data.force = { valid = false, index = -1 } end
    end
    if (not data.force.index or type(data.force.index) ~= "number") then data.force.index = -1 end

    optionals = optionals or {}

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end

    local surface = game.get_surface(planet_name)
    if (not surface or not surface.valid) then return end

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not Satellite_Meta_Repository.save_satellite_meta_data(planet_name).valid) then return return_val end
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]

    return_val.cargo_pod = data.cargo_pod
    return_val.cargo_pod_unit_number = data.cargo_pod_unit_number
    return_val.entity = data.entity
    return_val.force = data.force
    return_val.force_index = data.force_index
    return_val.planet_name = surface.name
    return_val.tick_to_die = data.death_tick or data.tick_to_die or 1
    return_val.tick_off_cooldown = game.tick
    return_val.surface_index = surface.index

    return_val.valid = true

    satellite_meta_data.satellites_in_transit[return_val.cargo_pod_unit_number] = return_val
    satellite_meta_data.satellite_dictionary[return_val.cargo_pod_unit_number] = return_val

    return return_val
end

function satellite_repository.add_satellite_data_to_cooldown(data, optionals)
    Log.debug("satellite_repository.add_satellite_data_to_cooldown")
    Log.info(data)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (not data or type(data) ~= "table") then return return_val end
    if (not data.satellite or type(data.satellite) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end

    optionals = optionals or {}

    local satellite = data.satellite
    if (not satellite) then return return_val end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end

    local surface = game.get_surface(planet_name)
    if (not surface or not surface.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not Satellite_Meta_Repository.save_satellite_meta_data(planet_name).valid) then return return_val end
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]

    local tick = game.tick
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
    Log.debug("satellite_repository.update_satellite_data")
    Log.info(update_data)
    Log.info(index)
    Log.info(optionals)

    local return_val = Satellite_Data:new()

    if (not game) then return return_val end
    if (not update_data or type(update_data) ~= "table") then return return_val end
    if (not update_data.planet_name or type(update_data.planet_name) ~= "string") then return return_val end

    optionals = optionals or {}

    local planet_name = update_data.planet_name
    if (not planet_name) then return return_val end

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not Satellite_Meta_Repository.save_satellite_meta_data(planet_name).valid) then return return_val end
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]
    -- Use the provided index if it exists; otherwise update the most recently added satellite
    local index = #satellite_meta_data.satellites

    if (type(unit_number) ~= "number") then unit_number = -1 end

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

    return_val.updated = game.tick

    return return_val
end

function satellite_repository.delete_satellite_data_by_index(data, optionals)
    Log.debug("satellite_repository.delete_satellite_data_by_index")
    Log.info(data)
    Log.info(optionals)

    local return_val = false

    if (not data or type(data) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end
    if (not data.index or type(data.index) ~= "number") then return return_val end
    if (not game) then return return_val end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end
    local index = data.index
    if (index < 1) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        Satellite_Meta_Repository.save_satellite_meta_data(planet_name)
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]
    if (not satellite_meta_data.valid) then return return_val end

    if (index > #satellite_meta_data.satellites) then return return_val end

    local satellite = satellite_meta_data.satellites[index]

    table.remove(satellite_meta_data.satellites, index)

    for k, _satellite in pairs(satellite_meta_data.satellites_cooldown) do
        if (_satellite == satellite) then
            satellite_meta_data.satellites_cooldown[k] = nil
            break
        end
    end

    satellite_meta_data.updated = game.tick
    return_val = true

    return return_val
end

function satellite_repository.delete_satellite_data_from_cooldown(data, optionals)
    Log.debug("satellite_repository.delete_satellite_data_from_cooldown")
    Log.info(data)
    Log.info(optionals)

    local return_val = false

    if (not data or type(data) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end
    if (not data.id or type(data.id) ~= "number") then return return_val end
    if (not game) then return return_val end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end
    local id = data.id
    if (id < 1) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        Satellite_Meta_Repository.save_satellite_meta_data(planet_name)
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]
    if (not satellite_meta_data.valid) then return return_val end

    satellite_meta_data.satellites_cooldown[id] = nil

    satellite_meta_data.updated = game.tick

    return_val = true
    return return_val
end

function satellite_repository.get_satellite_data(data, optionals)
    Log.debug("satellite_repository.get_satellite_data")
    Log.info(data)
    Log.info(optionals)

    local return_val = Satellite_Data:new()

    if (not data or type(data) ~= "table") then return return_val end
    if (not data.planet_name or type(data.planet_name) ~= "string") then return return_val end
    if (not data.index or type(data.index) ~= "number") then return return_val end
    if (not game) then return return_val end

    local planet_name = data.planet_name
    if (not planet_name) then return return_val end
    local index = data.index
    if (index < 1) then
        index = 1
    end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        Satellite_Meta_Repository.save_satellite_meta_data(planet_name)
    end

    local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]

    if (type(satellite_meta_data.satellites) == "table") then
        for i, satellite_data in pairs(satellite_meta_data.satellites) do
            if (i == index) then
                return_val = satellite_data; break
            end
        end
    end

    return return_val
end

function satellite_repository.get_all_satellite_data(optionals)
    Log.debug("satellite_repository.get_all_satellite_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
    if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end

    local all_satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data

    for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
        return_val[planet_name] = {}
        for i, satellite_data in pairs(satellite_meta_data.satellites) do
            table.insert(return_val[planet_name], satellite_data)
        end
    end

    return return_val
end

return satellite_repository
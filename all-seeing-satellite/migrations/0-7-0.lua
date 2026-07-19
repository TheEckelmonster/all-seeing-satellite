local pairs = pairs
local type = type

local PLAYER = "player"
local TABLE = "table"
local NUMBER = "number"

local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local save_satellite_meta_data = Satellite_Meta_Repository.save_satellite_meta_data
local update_satellite_meta_data = Satellite_Meta_Repository.update_satellite_meta_data
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local save_satellite_data = Satellite_Repository.save_satellite_data

local function migrate()
    local storage = _ENV.storage
    local storage_old = storage.storage_old
    local all_seeing_satellite_data = storage_old and storage_old.all_seeing_satellite
    local satellite_meta_data_repository = storage_old and storage_old.satellite_meta_data_repository or storage.satellite_meta_data_repository or nil

    if (all_seeing_satellite_data and not all_seeing_satellite_data.satellite_meta_data and not satellite_meta_data_repository) then return end

    --[[ Version 0.7.0:
        - icbm_meta_data, added:
            -> satellite_dictionary
            -> satellites_in_transit
        - satellite_data, enforced/added:
            -> force
            -> force_index
        - rocket_silo_data, enforced/added:
            -> force
            -> force_index
    ]]

    local all_satellite_meta_data = satellite_meta_data_repository or all_seeing_satellite_data.satellite_meta_data
    local player_force = game.forces[PLAYER]
    if (player_force and player_force.valid and type(all_satellite_meta_data) == TABLE) then
        for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
            if (type(satellite_meta_data) == TABLE) then
                satellite_meta_data.satellite_dictionary = satellite_meta_data.satellite_dictionary or {}
                satellite_meta_data.satellites_in_transit = satellite_meta_data.satellites_in_transit or {}
                if (type(satellite_meta_data.rocket_silos) == TABLE) then
                    for _, rocket_silo_data in pairs(satellite_meta_data.rocket_silos) do
                        if (type(rocket_silo_data) == TABLE and rocket_silo_data.valid) then
                            local entity = rocket_silo_data.entity

                            rocket_silo_data.force =    entity
                                                    and entity.valid
                                                    and entity.force
                                                    and entity.force.valid
                                                    and entity.force
                                                    or player_force

                            rocket_silo_data.force_index =  entity
                                                        and entity.valid
                                                        and entity.force
                                                        and entity.force.valid
                                                        and entity.force.index
                                                        or player_force.index
                        end
                    end
                end
                if (type(satellite_meta_data.satellites) == TABLE) then
                    for _, satellite_data in pairs(satellite_meta_data.satellites) do
                        if (type(satellite_data) == TABLE) then
                            satellite_data.force = player_force
                            satellite_data.force_index = player_force.index
                            if (type(satellite_data.cargo_pod_unit_number) == NUMBER) then
                                satellite_meta_data.satellite_dictionary[satellite_data.cargo_pod_unit_number] = satellite_data
                            end
                        end
                    end
                end
            end
        end
    end

    -- Satellites
    if (storage_old.satellites_in_orbit ~= nil and type(storage_old.satellites_in_orbit) == TABLE) then
        for planet_name, satellites in pairs(storage_old.satellites_in_orbit) do
            for i, satellite in pairs(satellites) do
                save_satellite_data(satellite)
            end
        end

        storage_old.satellites_in_orbit = nil
    end

    -- Satellite launch count
    if (storage_old.satellites_launched ~= nil and type(storage_old.satellites_launched) == TABLE) then
        for planet_name, value in pairs(storage_old.satellites_launched) do
            local satellite_meta_data = get_satellite_meta_data(planet_name)
            if (not satellite_meta_data) then goto continue end

            update_satellite_meta_data({ satellites_launched = satellite_meta_data.satellites_launched + value }, planet_name)
            update_satellite_meta_data({ satellites_in_orbit = #satellite_meta_data.satellites }, planet_name)

            ::continue::
        end

        storage_old.satellites_launched = nil
    end

    if (storage_old.all_seeing_satellite) then
        local all_satellite_meta_data = storage_old.all_seeing_satellite.satellite_meta_data
        if (type(all_satellite_meta_data) == TABLE) then
            for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
                save_satellite_meta_data(planet_name)
                update_satellite_meta_data(satellite_meta_data, planet_name)
            end
        end
        storage_old.all_seeing_satellite.satellite_meta_data = nil
    end
end

return migrate
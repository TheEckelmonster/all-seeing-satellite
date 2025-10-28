local TECL_Core_Utils = require("__TheEckelmonster-core-library__.libs.utils.core-utils")

local All_Seeing_Satellite_Data = require("scripts.data.all-seeing-satellite-data")
local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Character_Repository = require("scripts.repositories.character-repository")
local Constants = require("scripts.constants.constants")
local Player_Repository = require("scripts.repositories.player-repository")
local Research_Utils = require("scripts.utils.research-utils")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local Satellite_Toggle_Data = require("scripts.data.satellite.satellite-toggle-data")
local String_Utils = require("scripts.utils.string-utils")
local Version_Service = require("scripts.services.version-service")

local initialization = {}

local locals = {}

initialization.last_version_result = nil

function initialization.init(data)
    log({ Constants.mod_name .. ".init", Constants.mod_name })
    Log.debug("initialization.init")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Expllicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(true, data.maintain_data) -- from_scratch
end

function initialization.reinit(data)
    log({ Constants.mod_name .. ".reinit", Constants.mod_name })
    Log.debug("initialization.reinit")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Expllicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(false, data.maintain_data) -- as is
end

function locals.initialize(from_scratch, maintain_data)
    Log.debug("initialize")
    Log.info(from_scratch)
    Log.info(maintain_data)

    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    Log.info(all_seeing_satellite_data)

    all_seeing_satellite_data.do_nth_tick = false

    from_scratch = from_scratch or false
    maintain_data = maintain_data or false

    if (not from_scratch) then
        -- Version check
        local version_data = all_seeing_satellite_data.version_data
        if (version_data and not version_data.valid) then
            local version = initialization.last_version_result
            if (not version) then goto initialize end
            if (not version.major or not version.minor or not version.bug_fix) then goto initialize end
            if (not version.major.valid) then goto initialize end
            if (not version.minor.valid or not version.bug_fix.valid) then
                return locals.initialize(true, true)
            end

            ::initialize::
            return locals.initialize(true)
        else
            local version = Version_Service.validate_version()
            initialization.last_version_result = version
            if (not version or not version.valid) then
                version_data.valid = false
                return all_seeing_satellite_data
            end
        end
    end

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    -- All seeing satellite data
    if (from_scratch) then
        log({ Constants.mod_name .. ".initialization-anew", Constants.mod_name })
        if (game) then game.print({ Constants.mod_name .. ".initialization-anew", Constants.mod_name }) end

        local _storage = storage
        _storage.storage_old = nil

        storage = {}
        all_seeing_satellite_data = All_Seeing_Satellite_Data:new()
        storage.all_seeing_satellite = all_seeing_satellite_data

        storage.storage_old = _storage

        -- do migrations
        locals.migrate({ maintain_data = maintain_data, new_version_data = all_seeing_satellite_data.version_data })

        local version_data = all_seeing_satellite_data.version_data
        version_data.valid = true
    else
        if (not all_seeing_satellite_data) then
            storage.all_seeing_satellite = All_Seeing_Satellite_Data:new()
            all_seeing_satellite_data = storage.all_seeing_satellite
        end
        if (not all_seeing_satellite_data.staged_areas_to_chart) then all_seeing_satellite_data.staged_areas_to_chart = {} end
        if (not all_seeing_satellite_data.staged_chunks_to_chart) then all_seeing_satellite_data.staged_chunks_to_chart = {} end
    end

    storage.sa_active = sa_active ~= nil and sa_active or storage.sa_active
    storage.se_active = se_active ~= nil and se_active or storage.se_active

    Constants.get_planet_data({ reindex = true })

    -- Player data
    if (game) then
        for k, player in pairs(game.players) do
            local player_data = Player_Repository.get_player_data(player.index)
            if (not player_data.valid) then
                player_data = Player_Repository.save_player_data(player_data.player_index)
                if (not player_data.valid) then
                    Log.warn("Invalid player data detected")
                    Log.debug(player_data)
                    goto continue
                end
            end

            if (not player_data.character_data or not player_data.character_data.valid) then
                local character_data = Character_Repository.get_character_data(player_data.index)
                if (not character_data.valid) then
                    character_data = Character_Repository.save_character_data(player_data.index)

                    if (not character_data.valid) then
                        Log.warn("Invalid character data detected")
                        Log.debug(character_data)
                        Player_Repository.update_player_data({ player_index = player_data.player_index, valid = false, })
                        goto continue
                    end
                end
            end

            if (Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
                if (player_data.editor_mode_toggled or String_Utils.find_invalid_substrings(player.surface.name)) then
                    Player_Repository.update_player_data({ player_index = player.index, satellite_mode_stashed = true, })
                else
                    Player_Repository.update_player_data({ player_index = player.index, satellite_mode_allowed = true, })
                end
            else
                Player_Repository.update_player_data({ player_index = player.index, satellite_mode_allowed = false, })
            end

            if (player_data.in_space) then
                player_data.in_space = String_Utils.find_invalid_substrings(player.surface.name)
            end

            ::continue::
        end
    end

    -- Planet/rocket-silo data
    local planets = Constants.get_planet_data()
    if (type(planets) == "table") then
        for k, planet in pairs(planets) do
            -- Search for planets
            if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
                if (from_scratch or not all_seeing_satellite_data.satellite_meta_data[planet.name]) then
                    if (not maintain_data) then
                        Satellite_Meta_Repository.save_satellite_meta_data(planet.name)
                    else
                        Satellite_Meta_Repository.get_satellite_meta_data(planet.name)
                    end
                end

                local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)

                if (not satellite_meta_data.planet_name) then satellite_meta_data.planet_name = planet.name end

                if (not satellite_meta_data.satellites_toggled) then
                    satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
                        planet_name = planet.name,
                        toggle = false,
                        valid = true
                    })
                elseif (    satellite_meta_data.satellites_toggled
                        and not satellite_meta_data.satellites_toggled.valid)
                then
                    satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
                        planet_name = planet.name,
                        toggle = false,
                        valid = true
                    })
                end

                if (planet.surface and planet.surface.valid) then
                    local rocket_silos = planet.surface.find_entities_filtered({ type = "rocket-silo" })
                    for i = 1, #rocket_silos do
                        local rocket_silo = rocket_silos[i]
                        if (rocket_silo and rocket_silo.valid and rocket_silo.surface and rocket_silo.surface.valid) then
                            locals.add_rocket_silo(satellite_meta_data, rocket_silo)
                        end
                    end
                end
            end
        end
    end


    if (storage and storage.all_seeing_satellite) then
        storage.all_seeing_satellite.do_nth_tick = true
    end

    storage.all_seeing_satellite.valid = true

    if (from_scratch) then log("all-seeing-satellite: Initialization complete") end
    if (from_scratch and game) then game.print("all-seeing-satellite: Initialization complete") end
    Log.info(storage)

    return all_seeing_satellite_data
end

function locals.add_rocket_silo(satellite_meta_data, rocket_silo)
    Log.debug("add_rocket_silo")
    Log.info(satellite_meta_data)
    Log.info(rocket_silo)

    if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface or not rocket_silo.surface.valid) then
        Log.warn("Call to add_rocket_silo with an invalid rocket-silo")
        Log.debug(rocket_silo)
        return
    end

    Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function locals.migrate(data)
    Log.debug("migrate")
    Log.info(data)

    local storage_old = storage.storage_old
    if (not storage_old) then return end
    if (not type(storage_old) == "table") then return end

    TECL_Core_Utils.table.reassign(storage_old, storage, { field = "handles" })
    TECL_Core_Utils.table.reassign(storage_old, storage, { field = "event_handlers" })

    TECL_Core_Utils.table.reassign(storage_old, storage, { field = "player_data" })

    if (not data or type(data) ~= "table") then return end
    if (not data.maintain_data) then return end
    if (not data.new_version_data) then
        if (storage.all_seeing_satellite and storage.all_seeing_satellite.version_data) then
            data.new_version_data = storage.all_seeing_satellite.version_data
        else
            return
        end
    end

    if (storage_old.all_seeing_satellite) then
        Constants.get_planet_data({ reindex = true })

        local migration_start_message_printed = false
        if (storage_old.all_seeing_satellite.version_data and storage_old.all_seeing_satellite.version_data.created) then
            if (storage_old.all_seeing_satellite.version_data.created >= 0) then
                if (storage.tick and type(storage.tick) == "number" and storage.tick > 0) then
                    Log.debug(storage_old.all_seeing_satellite.version_data)
                    Log.debug(Constants.mod_name .. ": Migrating existing data")
                    game.print({ Constants.mod_name .. ".migrate-start", Constants.mod_name })
                    migration_start_message_printed = true
                end
            end
        end

        if (storage_old.all_seeing_satellite.version_data) then
            local prev_version_data = storage_old.all_seeing_satellite.version_data
            local new_version_data = data.new_version_data
            if (prev_version_data.major.value == 0) then
                if (prev_version_data.minor.value <= 6) then
                    Log.warn(prev_version_data.minor.value)
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 7) then
                        Log.warn(new_version_data.major.value)
                        Log.warn(new_version_data.minor.value)
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

                        if (storage_old.all_seeing_satellite) then
                            local all_satellite_meta_data = storage_old.all_seeing_satellite.satellite_meta_data
                            local player_force = game.forces["player"]
                            if (player_force and player_force.valid and type(all_satellite_meta_data) == "table") then
                                for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
                                    satellite_meta_data.satellite_dictionary = {}
                                    satellite_meta_data.satellites_in_transit = {}
                                    if (type(satellite_meta_data.rocket_silos) == "table") then
                                        for _, rocket_silo_data in pairs(satellite_meta_data.rocket_silos) do
                                            rocket_silo_data.force =    rocket_silo_data.entity
                                                                    and rocket_silo_data.entity.valid
                                                                    and rocket_silo_data.entity.force
                                                                    and rocket_silo_data.entity.force.valid
                                                                    and rocket_silo_data.entity.force
                                                                    or player_force
                                            rocket_silo_data.force_index =  rocket_silo_data.entity
                                                                        and rocket_silo_data.entity.valid
                                                                        and rocket_silo_data.entity.force
                                                                        and rocket_silo_data.entity.force.valid
                                                                        and rocket_silo_data.entity.force.index
                                                                        or player_force.index
                                        end
                                    end
                                    if (type(satellite_meta_data.satellites) == "table") then
                                        for _, satellite_data in pairs(satellite_meta_data.satellites) do
                                            if (type(satellite_data) == "table" and satellite_data.valid) then
                                                satellite_data.force = player_force
                                                satellite_data.force_index = player_force.index
                                                if (type(satellite_data.cargo_pod_unit_number) == "number") then
                                                    satellite_meta_data.satellite_dictionary[satellite_data.cargo_pod_unit_number] = satellite_data
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- local se_active  = script and script.active_mods and script.active_mods["space-exploration"]
        -- local dictionary =     not se_active and Constants.get_planets(true) and Constants.planets_dictionary
        --                     or Constants.get_space_exploration_universe(true) and Constants.space_exploration_dictionary

        -- if (Log.get_log_level().num_val <= 2) then
        --     log(serpent.block(dictionary))
        -- end

        -- Satellites
        if (storage_old.satellites_in_orbit ~= nil and type(storage_old.satellites_in_orbit) == "table") then
            for planet_name, satellites in pairs(storage_old.satellites_in_orbit) do
                for i, satellite in pairs(satellites) do
                    Satellite_Repository.save_satellite_data(satellite)
                end
            end

            storage_old.satellites_in_orbit = nil
        end

        -- Satellite launch count
        if (storage_old.satellites_launched ~= nil and type(storage_old.satellites_launched) == "table") then
            for planet_name, value in pairs(storage_old.satellites_launched) do
                local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)

                Satellite_Meta_Repository.update_satellite_meta_data({
                    planet_name = planet_name,
                    satellites_launched = satellite_meta_data.satellites_launched + value
                })

                Satellite_Meta_Repository.update_satellite_meta_data({
                    planet_name = planet_name,
                    satellites_in_orbit = #satellite_meta_data.satellites
                })
            end

            storage_old.satellites_launched = nil
        end

        if (storage_old.all_seeing_satellite) then
            local all_satellite_meta_data = storage_old.all_seeing_satellite.satellite_meta_data
            if (type(all_satellite_meta_data) == "table") then
                for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
                    Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
                    Satellite_Meta_Repository.update_satellite_meta_data(satellite_meta_data)
                end
            end
            storage_old.all_seeing_satellite.satellite_meta_data = nil
        end

        if (migration_start_message_printed) then
            Log.debug(Constants.mod_name .. ": Migration complete")
            game.print({ Constants.mod_name .. ".migrate-finish", Constants.mod_name})
        end
    end
end

return initialization

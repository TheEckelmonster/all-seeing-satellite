local script = script
local raise_event = script and script.raise_event or nil

local log = log
local type = type

local serpent = serpent
local serpent_block = serpent.block

local defines = defines
local defines_events =  defines.events

local Constants = Constants
local Log = Log

local TECL_Core_Utils = require("__TheEckelmonster-core-library__.libs.utils.core-utils")

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Character_Repository = require("scripts.repositories.character-repository")
local Custom_Events = require("prototypes.custom-events.custom-events")
local as_on_init_complete_name = Custom_Events.as_on_init_complete.name
local Migrations = require("scripts.migrations")
local Player_Repository = require("scripts.repositories.player-repository")
local Research_Utils = require("scripts.utils.research-utils")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Toggle_Data = require("scripts.data.satellite.satellite-toggle-data")
local String_Utils = require("scripts.utils.string-utils")
local Version_Data = require("scripts.data.version-data")
local Version_Service = require("scripts.services.version-service")

local initialization = {}

local locals = {}

initialization.last_version_result = nil

function initialization.init(data)
    log({ Constants.mod_name .. ".init", Constants.mod_name })
    Log.debug("initialization.init")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Explicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(true, data.maintain_data) -- from_scratch
end

function initialization.reinit(data)
    log({ Constants.mod_name .. ".reinit", Constants.mod_name })
    Log.debug("initialization.reinit")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Explicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(false, data.maintain_data) -- as is
end

function locals.initialize(from_scratch, maintain_data)
    Log.debug("initialize")
    Log.info(from_scratch)
    Log.info(maintain_data)

    from_scratch = from_scratch or false
    maintain_data = maintain_data or false

    if (not from_scratch) then
        -- Version check
        local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
        local version_data = storage.version_data or all_seeing_satellite_data.version_data
        if (version_data and not version_data.valid) then
            local version = initialization.last_version_result
            if (not version) then goto initialize end
            if (not version.major or not version.minor or not version.bug_fix) then goto initialize end
            if (not version.major.valid) then goto initialize end
            if (not version.minor.valid or not version.bug_fix.valid) then
                return
            end

            ::initialize::
            return locals.initialize(true)
        else
            local version = Version_Service.validate_version()
            initialization.last_version_result = version
            if (not version or not version.valid) then
                (version_data or {}).valid = false
                return
            end
        end
    end

    -- All seeing satellite data
    if (from_scratch) then
        log({ Constants.mod_name .. ".initialization-anew", Constants.mod_name })
        if (game) then game.print({ Constants.mod_name .. ".initialization-anew", Constants.mod_name }) end

        local _storage = _ENV.storage
        _storage.storage_old = nil

        _ENV.storage = {}
        local storage = _ENV.storage
        storage.storage_old = _storage

        local version_data = Version_Data:new()
        storage.version_data = version_data
        version_data.valid = true

        -- do migrations
        locals.migrate({ maintain_data = maintain_data, new_version_data = version_data })

        storage.storage_old = nil
    end

    Constants.get_planet_data({ reindex = true })

    -- Player data
    if (game) then
        for k, player in pairs(game.players) do
            local player_data = Player_Repository.get_player_data(player.index)
            if (not player_data) then
                player_data = Player_Repository.save_player_data(player.index)
                if (not player_data) then
                    Log.warn("Invalid player data detected")
                    Log.debug(player_data)
                    goto continue
                end
            end

            if (not player_data.character_data) then
                local character_data = Character_Repository.get_character_data(player_data.index)
                if (not character_data) then
                    character_data = Character_Repository.save_character_data(player_data.index)

                    if (not character_data) then
                        Log.warn("Invalid character data detected")
                        Log.debug(character_data)
                        Player_Repository.update_player_data({ player_index = player_data.player_index, })
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
        storage.satellite_meta_data_repository = storage.satellite_meta_data_repository or {}
        for k, planet in pairs(planets) do
            -- Search for planets
            local planet_name = planet.name
            if (planet and not String_Utils.find_invalid_substrings(planet_name)) then
                if (from_scratch or not storage.satellite_meta_data_repository[planet_name]) then
                    if (not maintain_data) then
                        Satellite_Meta_Repository.save_satellite_meta_data(planet_name)
                    else
                        Satellite_Meta_Repository.update_satellite_meta_data(Satellite_Meta_Repository.get_satellite_meta_data(planet_name), planet_name)
                    end
                end

                local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)

                if (satellite_meta_data) then
                    if (not satellite_meta_data.planet_name) then satellite_meta_data.planet_name = planet_name end

                    if (not satellite_meta_data.satellites_toggled) then
                        satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
                            planet_name = planet_name,
                            toggle = false,
                        })
                    elseif (not satellite_meta_data.satellites_toggled) then
                        satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
                            planet_name = planet_name,
                            toggle = false,
                        })
                    end
                end
            end
        end
    end

    if (raise_event) then
        raise_event(as_on_init_complete_name, { name = defines_events[as_on_init_complete_name], tick = game.tick, })
    else
        raise_event = script.raise_event
        raise_event(as_on_init_complete_name, { name = defines_events[as_on_init_complete_name], tick = game.tick, })
    end

    if (from_scratch) then log("all-seeing-satellite: Initialization complete") end
    if (from_scratch and game) then game.print("all-seeing-satellite: Initialization complete") end
end

function locals.migrate(params)
    -- Log.debug("migrate")
    -- Log.info(params)

    local storage_old = storage.storage_old
    if (type(storage_old) ~= "table") then return end

    if (params.maintain_data) then
        TECL_Core_Utils.table.reassign(storage_old, storage, { field = "event_handlers" })
        TECL_Core_Utils.table.reassign(storage_old, storage, { field = "handles" })

        TECL_Core_Utils.table.reassign(storage_old, storage, { field = "constants" })
        TECL_Core_Utils.table.reassign(storage_old, storage, { field = "player_data" })
        TECL_Core_Utils.table.reassign(storage_old, storage, { field = "satellite_meta_data_repository" })
    end

    local migration_start_message_printed = false
    local version_data = storage_old.version_data or storage_old.all_seeing_satellite and storage_old.all_seeing_satellite.version_data

    if (version_data and (version_data.created and version_data.created > 0 or game.tick > 0)) then
        Log.debug(Constants.mod_name .. ": Migrating existing data")
        game.print({ Constants.mod_name .. ".migrate-start", Constants.mod_name })
        migration_start_message_printed = true
    end

    if (params.maintain_data) then TECL_Core_Utils.table.reassign(storage_old, storage, { field = "all_seeing_satellite" }) end

    if ((version_data or storage_old.version_data) and params.new_version_data) then
        local prev_version_data = storage_old.version_data or version_data
        local new_version_data = params.new_version_data or storage.version_data

        if (    locals.validate_version({ version_data = prev_version_data })
            and locals.validate_version({ version_data = new_version_data })
        ) then
            log("previous version")
            log(serpent_block(string.format("%d.%d.%d", prev_version_data.major.value, prev_version_data.minor.value, prev_version_data.bug_fix.value )))

            log("new version")
            log(serpent_block(string.format("%d.%d.%d", new_version_data.major.value, new_version_data.minor.value, new_version_data.bug_fix.value )))

            local do_apply = nil
            for version, migration in pairs(Migrations) do
                do_apply = prev_version_data.major.value < version.major
                do_apply = do_apply or prev_version_data.minor.value < version.minor
                do_apply = do_apply or prev_version_data.bug_fix.value <= version.bug_fix

                if (do_apply and type(migration) == "function") then
                    log(serpent.block("Applying version "
                        .. version.major.. "."
                        .. version.minor .. "."
                        .. version.bug_fix
                        .. " migration"
                    ))
                    migration(params)
                end
            end
        end
    end

    if (migration_start_message_printed) then
        Log.debug(Constants.mod_name .. ": Migration complete")
        game.print({ Constants.mod_name .. ".migrate-finish", Constants.mod_name})
    end
end

function locals.validate_version(params)
    -- Log.debug("locals.validate_version")
    -- Log.info(params)

    local return_val = false

    if (not params or type(params) ~= "table") then return return_val end

    if (    type(params.version_data) == "table"
        and type(params.version_data.major) == "table"
        and type(params.version_data.major.value) == "number"
        and type(params.version_data.minor) == "table"
        and type(params.version_data.minor.value) == "number"
        and type(params.version_data.bug_fix) == "table"
        and type(params.version_data.bug_fix.value) == "number"
        and type(params.version_data.string_val) == "string"
    ) then
        return_val = true
    end

    return return_val
end

return initialization

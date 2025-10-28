--[[ Globals ]]
Constants = require("scripts.constants.constants")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local All_Seeing_Satellite_Controller = require("scripts.controllers.all-seeing-satellite-controller")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Fog_Of_War_Controller = require("scripts.controllers.fog-of-war-controller")
local Initialization = require("scripts.initialization")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Player_Controller = require("scripts.controllers.player-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Research_Controller = require("scripts.controllers.research-controller")
local Satellite_Controller = require("scripts.controllers.satellite-controller")
local Scan_Chunk_Controller = require("scripts.controllers.scan-chunk-controller")


local on_entity_died_filter = {}

for _, v in pairs(Rocket_Silo_Controller.filter) do
    table.insert(on_entity_died_filter, v)
end

for _, v in pairs(Player_Controller.filter) do
    table.insert(on_entity_died_filter, v)
end

--
-- Register events

script.on_event(Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name, Fog_Of_War_Controller.toggle)
script.on_event(Custom_Input_Constants.TOGGLE_SCANNING.name, Fog_Of_War_Controller.toggle_scanning)
script.on_event(Custom_Input_Constants.CANCEL_SCANNING.name, Fog_Of_War_Controller.cancel_scanning)
script.on_event(Custom_Input_Constants.TOGGLE_SATELLITE_MODE.name, Player_Controller.toggle_satellite_mode)

script.on_event(defines.events.on_player_created, Player_Controller.player_created)
script.on_event(defines.events.on_pre_player_died, Player_Controller.pre_player_died)
script.on_event(defines.events.on_player_died, Player_Controller.player_died)
script.on_event(defines.events.on_player_respawned, Player_Controller.player_respawned)
script.on_event(defines.events.on_player_joined_game, Player_Controller.player_joined_game)
script.on_event(defines.events.on_pre_player_left_game, Player_Controller.pre_player_left_game)
script.on_event(defines.events.on_pre_player_removed, Player_Controller.pre_player_removed)
script.on_event(defines.events.on_surface_cleared, Player_Controller.surface_cleared)
script.on_event(defines.events.on_surface_deleted, Player_Controller.surface_deleted)
script.on_event(defines.events.on_player_changed_surface, Player_Controller.changed_surface)
script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
    Player_Controller.cargo_pod_finished_ascending(event)
    Satellite_Controller.track_satellite_launches_ordered(event)
end) -- script.on_event(defines.events.on_cargo_pod_finished_ascending
script.on_event(defines.events.on_cargo_pod_finished_descending, Player_Controller.cargo_pod_finished_descending)
script.on_event(defines.events.on_player_toggled_map_editor, Player_Controller.player_toggled_map_editor)
script.on_event(defines.events.on_pre_player_toggled_map_editor, Player_Controller.pre_player_toggled_map_editor)
script.on_event(defines.events.on_cutscene_cancelled, Player_Controller.cutscene_cancelled)
script.on_event(defines.events.on_cutscene_finished, Player_Controller.cutscene_finished)

script.on_event(defines.events.on_surface_created, Planet_Controller.on_surface_created)

script.on_event(defines.events.on_rocket_launch_ordered, Player_Controller.rocket_launch_ordered)

script.on_event(defines.events.on_research_finished, Research_Controller.research_finished)


script.on_event(defines.events.on_player_selected_area, Scan_Chunk_Controller.stage_selected_chunks)
script.on_event(defines.events.on_player_reverse_selected_area, Scan_Chunk_Controller.clear_selected_chunks)

script.on_event(defines.events.on_entity_died, function(event)
        if (not event) then return end
        if (not event.entity or not event.entity.name) then return end

        if (event.entity.name == "character") then
            Player_Controller.entity_died(event)
        elseif (event.entity.name == "rocket-silo") then
            Rocket_Silo_Controller.rocket_silo_mined(event)
        end
    end,
    on_entity_died_filter
) -- script.on_event(defines.events.on_entity_died

--
-- rocket-silo tracking
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)

local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

local events = {
    [All_Seeing_Satellite_Controller.name] = All_Seeing_Satellite_Controller,
    [Fog_Of_War_Controller.name] = Fog_Of_War_Controller,
    [Planet_Controller.name] = Planet_Controller,
    [Player_Controller.name] = Player_Controller,
    [Rocket_Silo_Controller.name] = Rocket_Silo_Controller,
    [Research_Controller.name] = Research_Controller,
    [Satellite_Controller.name] = Satellite_Controller,
    [Scan_Chunk_Controller.name] = Scan_Chunk_Controller,
    [Settings_Controller.name] = Settings_Controller,
}


local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")

log(serpent.block(Log))

function events.on_init()
    if (    type(storage) ~= "table"
        and type(storage) ~= "userdata"
        and type(storage) ~= "boolean"
        and type(storage) ~= "number"
        and type(storage) ~= "string"
    ) then
        return
    end

    local return_val = 0

    storage.handles = {
        log_handle = {},
        setting_handle = {},
    }

    return_val =  Settings_Service.init({ storage_ref = storage.handles.setting_handle })
    return_val = Settings_Controller.init({ settings_service = Settings_Service })

    local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

    return_val = Log.init({
        storage_ref = storage.handles.log_handle,
        settings_service = Settings_Service,
        debug_level_name = log_settings[1].name,
        traceback_setting_name = log_settings[2].name,
        do_not_print_setting_name = log_settings[3].name,
    })
    Log.ready()

    Initialization.init({ maintain_data = false })
end
Event_Handler:register_event({
    event_name = "on_init",
    source_name = "events.on_init",
    func_name = "events.on_init",
    func = events.on_init,
})

local initialized_from_load = false

function events.on_load()
    if (type(storage) ~= "table") then return end

    local return_val = 0

    if (type(storage.handles) == "table") then
        initialized_from_load = true
        return_val = initialized_from_load and Settings_Service.init({ storage_ref = storage.handles.setting_handle })
        if (not return_val) then initialized_from_load = false end
        return_val = initialized_from_load and Settings_Controller.init({ settings_service = Settings_Service })
        if (not return_val) then initialized_from_load = false end

        local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

        return_val = initialized_from_load and Log.init({
            storage_ref = storage.handles.log_handle,
            debug_level_name = log_settings[1].name,
            traceback_setting_name = log_settings[2].name,
            do_not_print_setting_name = log_settings[3].name,
        })
        if (not return_val) then initialized_from_load = false end

        if (initialized_from_load) then Log.ready() end
    end

    Constants.get_planet_data({ on_load = true })

    Event_Handler:on_load_restore({ events = events })
end
Event_Handler:register_event({
    event_name = "on_load",
    source_name = "events.on_load",
    func_name = "events.on_load",
    func = events.on_load,
})

function events.on_configuration_changed(event)
    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    storage.sa_active = sa_active
    storage.se_active = se_active

    if (event.mod_changes) then
        --[[ Check if our mod updated ]]
        if (event.mod_changes[Constants.mod_name]) then
            game.print({ Constants.mod_name .. ".on-configuration-changed", Constants.mod_name })

            if (type(storage.handles) ~= "table") then
                storage.handles = {
                    log_handle = {},
                    setting_handle = {},
                }

                local return_val = 0
                return_val =  Settings_Service.init({ storage_ref = storage.handles.setting_handle })
                return_val = Settings_Controller.init({ settings_service = Settings_Service })

                local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

                return_val = Log.init({
                    storage_ref = storage.handles.log_handle,
                    settings_service = Settings_Service,
                    debug_level_name = log_settings[1].name,
                    traceback_setting_name = log_settings[2].name,
                    do_not_print_setting_name = log_settings[3].name,
                })

                Log.ready()
            end

            if (not initialized_from_load) then
                                storage.handles = {
                    log_handle = {},
                    setting_handle = {},
                }

                local return_val = 0
                return_val =  Settings_Service.init({ storage_ref = storage.handles.setting_handle })
                return_val = Settings_Controller.init({ settings_service = Settings_Service })

                local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

                return_val = Log.init({
                    storage_ref = storage.handles.log_handle,
                    settings_service = Settings_Service,
                    debug_level_name = log_settings[1].name,
                    traceback_setting_name = log_settings[2].name,
                    do_not_print_setting_name = log_settings[3].name,
                })

                Log.ready()
            end

            Initialization.init({ maintain_data = true })
        end
    end
end
Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "events.on_configuration_changed",
    func_name = "events.on_configuration_changed",
    func = events.on_configuration_changed,
})
--[[ Globals ]]
Constants = require("scripts.constants.constants")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

Filters = {}

local rocket_silo_controller_filter = { { filter = "type", type = "rocket-silo" } }
local player_controller_filter = { { filter = "name", name = "character" } }
local on_entity_died_filter = {}

for _, v in pairs(rocket_silo_controller_filter) do table.insert(on_entity_died_filter, v) end
for _, v in pairs(player_controller_filter) do table.insert(on_entity_died_filter, v) end

Filters.on_entity_died_filter = on_entity_died_filter

---

local All_Seeing_Satellite_Controller = require("scripts.controllers.all-seeing-satellite-controller")
local Fog_Of_War_Controller = require("scripts.controllers.fog-of-war-controller")
local Initialization = require("scripts.initialization")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Player_Controller = require("scripts.controllers.player-controller")
local Research_Controller = require("scripts.controllers.research-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")
local Satellite_Controller = require("scripts.controllers.satellite-controller")
local Scan_Chunk_Controller = require("scripts.controllers.scan-chunk-controller")


local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

local events = {
    [All_Seeing_Satellite_Controller.name] = All_Seeing_Satellite_Controller,
    [Fog_Of_War_Controller.name] = Fog_Of_War_Controller,
    [Planet_Controller.name] = Planet_Controller,
    [Player_Controller.name] = Player_Controller,
    [Rocket_Silo_Controller.name] = Rocket_Silo_Controller,
    [Rocket_Silo_Utils.name] = Rocket_Silo_Utils,
    [Research_Controller.name] = Research_Controller,
    [Satellite_Controller.name] = Satellite_Controller,
    [Scan_Chunk_Controller.name] = Scan_Chunk_Controller,
    [Settings_Controller.name] = Settings_Controller,
}


local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")

local did_init = false

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
    did_init = true
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
            if (not did_init) then
                game.print({ Constants.mod_name .. ".on-configuration-changed", Constants.mod_name })
            end

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
--[[ Globals ]]
Constants = require("scripts.constants.constants")
Custom_Events = require("prototypes.custom-events.custom-events")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
_Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")
Settings_Service = require("scripts.services.settings-service")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

Filters = {}

local rocket_silo_controller_filter = { { filter = "type", type = "rocket-silo" } }
local player_controller_filter = { { filter = "type", type = "character" } }
local on_entity_died_filter = {}

for _, v in pairs(rocket_silo_controller_filter) do table.insert(on_entity_died_filter, v) end
for _, v in pairs(player_controller_filter) do table.insert(on_entity_died_filter, v) end

Filters.on_entity_died_filter = on_entity_died_filter
Filters.rocket_silo_filter = rocket_silo_controller_filter

local FUNCTION = Types.FUNCTION
local STRING = Types.STRING

local Settings_Service = Settings_Service
local get_runtime_global_setting = Settings_Service.get_runtime_global_setting
local get_startup_setting = Settings_Service.get_startup_setting

local settings_registry = { registry = {}, }
Settings_Registry = settings_registry
function Settings_Registry:register_setting(params)
    if (not params) then return end
    if (type(params.func_name) ~= STRING) then return end
    if (type(params.func) ~= FUNCTION) then return end

    if (not self or not Settings_Registry) then
        self = self or {}
        Settings_Registry = self
    end
    self.registry = self.registry or {}
    self.registry[#self.registry+1] = { func_name = params.func_name, func = params.func, }
end

To_Set_Game = require("scripts.to-set-game")

---

local ipairs = ipairs
local type = type

local Custom_Events = Custom_Events

local All_Seeing_Satellite_Controller = require("scripts.controllers.all-seeing-satellite-controller")
local Character_Repository = require("scripts.repositories.character-repository")
local Fog_Of_War_Controller = require("scripts.controllers.fog-of-war-controller")
local Initialization = require("scripts.initialization")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Player_Controller = require("scripts.controllers.player-controller")
local Player_Repository = require("scripts.repositories.player-repository")
local Research_Controller = require("scripts.controllers.research-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")
local Satellite_Controller = require("scripts.controllers.satellite-controller")
local Scan_Chunk_Controller = require("scripts.controllers.scan-chunk-controller")

local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

--
-- Register events

local to_init_storage = {
    All_Seeing_Satellite_Controller,
    Fog_Of_War_Controller,
    -- Planet_Controller,
    Player_Controller,
    Scan_Chunk_Controller,
    Settings_Service,
    require("scripts.data.data"),
    require("scripts.repositories.all-seeing-satellite-repository"),
    require("scripts.repositories.scanning.area-to-chart-repository"),
    require("scripts.repositories.scanning.chunk-to-chart-repository"),
    require("scripts.repositories.character-repository"),
    require("scripts.repositories.player-repository"),
    require("scripts.repositories.rocket-silo-repository"),
    require("scripts.repositories.satellite-meta-repository"),
    require("scripts.repositories.satellite-repository"),
    require("scripts.services.all-seeing-satellite-service"),
    require("scripts.services.player-service"),
    require("scripts.services.satellite-service"),
    require("scripts.services.scan-chunk-service"),
    Rocket_Silo_Utils,
}

function to_init_storage.reinit_all(event)
    for _, v in ipairs(to_init_storage) do
        v.init(storage)
    end
end
Event_Handler:register_event({
    event_name = Custom_Events.as_on_init_complete.name,
    source_name = "to_init_storage.reinit_all",
    func_name = "to_init_storage.reinit_all",
    func = to_init_storage.reinit_all,
})

---
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
    if (type(storage) ~= "table") then return end

    local return_val = 0

    storage.handles = {
        log_handle = {},
    }

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

    for _, player in pairs(game.players) do
        Player_Repository.save_player_data(player.index)
        Character_Repository.save_character_data(player.index)
    end

    for _, v in ipairs(to_init_storage) do
        v.init(storage)
    end

    storage.settings_map = storage.settings_map or {}
    storage.settings_map.runtime_global = storage.settings_map.runtime_global or {}
    Settings_Map = storage.settings_map
    for _, setting_tbl in pairs(Runtime_Global_Settings_Constants.settings or {}) do
        Settings_Map.runtime_global[setting_tbl.name] = get_runtime_global_setting({ setting = setting_tbl.name, reindex = true, }) or setting_tbl.default_value
    end
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

    for _, v in ipairs(to_init_storage) do
        v.init(storage)
    end

    Settings_Map = storage.settings_map
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

            if (type(storage.handles) ~= "table" or not initialized_from_load) then
                storage.handles = {
                    log_handle = {},
                    -- setting_handle = {},
                }

                local return_val = 0

                local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

                return_val = Log.init({
                    storage_ref = storage.handles.log_handle,
                    debug_level_name = log_settings[1].name,
                    traceback_setting_name = log_settings[2].name,
                    do_not_print_setting_name = log_settings[3].name,
                })

                Log.ready()
            end

            Initialization.init({ maintain_data = true })

            for _, player in pairs(game.players) do
                Player_Repository.save_player_data(player.index)
                Character_Repository.save_character_data(player.index)
            end

            for _, v in ipairs(to_init_storage) do
                v.init(storage)
            end
        end
    end

    storage.settings_map = storage.settings_map or {}
    storage.settings_map.runtime_global = storage.settings_map.runtime_global or {}
    Settings_Map = storage.settings_map
    for _, setting_tbl in pairs(Runtime_Global_Settings_Constants.settings or {}) do
        Settings_Map.runtime_global[setting_tbl.name] = get_runtime_global_setting({ setting = setting_tbl.name, reindex = true, }) or setting_tbl.default_value
    end
end
Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "events.on_configuration_changed",
    func_name = "events.on_configuration_changed",
    func = events.on_configuration_changed,
})

local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local string_upper = string.upper
local DOT_STAR_CAPTURE_STRING = DOT_STAR_CAPTURE_STRING
local ESCAPED_DASH = ESCAPED_DASH
local UNDERSCORE = UNDERSCORE
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "settings_map.on_runtime_mod_setting_changed",
    func_name = "settings_map.on_runtime_mod_setting_changed",
    func = function (event)
        if (not event or not event.setting or not string_find(event.setting, MOD_NAME_PREFIX_ESCAPED)) then return end
        local trimmed = string_match(event.setting, MOD_NAME_PREFIX_ESCAPED .. DOT_STAR_CAPTURE_STRING)
        local subbed_to_upper = string_upper(string_gsub(trimmed, ESCAPED_DASH, UNDERSCORE))

        storage.settings_map = storage.settings_map or {}
        Settings_Map = storage.settings_map

        local setting_value = nil
        local setting = nil
        local planet = nil
        if (Runtime_Global_Settings_Constants.settings[subbed_to_upper]) then
            Settings_Map.runtime_global = Settings_Map.runtime_global or {}
            planet = Runtime_Global_Settings_Constants.settings[subbed_to_upper].planet
            Settings_Map.runtime_global[event.setting] = get_runtime_global_setting({ setting = event.setting, reindex = true, })
            setting_value = Settings_Map.runtime_global[event.setting]
            setting = Runtime_Global_Settings_Constants.settings[subbed_to_upper]
        elseif (Startup_Settings_Constants.settings[subbed_to_upper]) then
            Settings_Map.startup = Settings_Map.startup or {}
            planet = Startup_Settings_Constants.settings[subbed_to_upper].planet
            Settings_Map.startup[event.setting] = get_startup_setting({ setting = event.setting, reindex = true, })
            setting_value = Settings_Map.startup[event.setting]
            setting = Startup_Settings_Constants.settings[subbed_to_upper]
        end

        for _, registered in ipairs(Settings_Registry.registry or {}) do
            if (registered.func and type(registered.func) == FUNCTION) then registered.func(event, { setting_constant = setting, setting_value = setting_value, surface_name = planet, }) end
        end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "settings_map.on_runtime_mod_setting_changed",
    new_position = 1,
})
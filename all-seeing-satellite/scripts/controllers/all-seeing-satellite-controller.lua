local storage
local all_seeing_satellite_data

local game

local planets_dictionary

local All_Seeing_Satellite_Data = require("scripts.data.all-seeing-satellite-data")
local new_All_Seeing_Satellite_Data = All_Seeing_Satellite_Data.new

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.all_seeing_satellite = storage.all_seeing_satellite or new_All_Seeing_Satellite_Data(All_Seeing_Satellite_Data)
    all_seeing_satellite_data = storage.all_seeing_satellite

    game = __game or _ENV.game

    Set_Game_Funcs()

    if (not Constants.mod_data or not Constants.mod_data.planets_dictionary) then Constants.get_planet_data({ reindex = true }) end
    planets_dictionary = Constants.mod_data.planets_dictionary

    return game
end

local next = next

local All_Seeing_Satellite_Service = require("scripts.services.all-seeing-satellite-service")
local check_for_areas_to_stage = All_Seeing_Satellite_Service.check_for_areas_to_stage
local do_scan = All_Seeing_Satellite_Service.do_scan
local Fog_Of_War_Service = require("scripts.services.fog-of-war-service")
local toggle_FoW = Fog_Of_War_Service.toggle_FoW
local Satellite_Service = require("scripts.services.satellite-service")
local check_for_expired_satellites = Satellite_Service.check_for_expired_satellites

local all_seeing_satellite_controller = {}
all_seeing_satellite_controller.name = "all_seeing_satellite_controller"
all_seeing_satellite_controller.set_game = set_game

all_seeing_satellite_controller.planet_index = nil
all_seeing_satellite_controller.planet = nil

local nth_tick =   Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NTH_TICK.name })
                or Runtime_Global_Settings_Constants.settings.NTH_TICK.default_value

function all_seeing_satellite_controller.on_tick_pocess_scanning(event)
    all_seeing_satellite_data = all_seeing_satellite_data or set_game() and all_seeing_satellite_data

    if (all_seeing_satellite_data.do_scan and all_seeing_satellite_controller.planet) then
        if (check_for_areas_to_stage()) then do_scan(all_seeing_satellite_controller.planet.name) end
    end
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "all_seeing_satellite_controller.on_tick_pocess_scanning",
    func_name = "all_seeing_satellite_controller.on_tick_pocess_scanning",
    func = all_seeing_satellite_controller.on_tick_pocess_scanning,
})

function all_seeing_satellite_controller.check_for_expired_satellites(event)
    all_seeing_satellite_data = all_seeing_satellite_data or set_game() and all_seeing_satellite_data

    planets_dictionary = planets_dictionary or set_game() and planets_dictionary
    all_seeing_satellite_controller.planet_index, all_seeing_satellite_controller.planet = next(planets_dictionary, all_seeing_satellite_controller.planet_index)

    local planet = all_seeing_satellite_controller.planet

    if (not planet or not all_seeing_satellite_controller.planet_index) then return end
    if (not planet.surface or not planet.surface.valid) then return end

    check_for_expired_satellites(planet.name, event.tick)
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "all_seeing_satellite_controller.check_for_expired_satellites",
    func_name = "all_seeing_satellite_controller.check_for_expired_satellites",
    func = all_seeing_satellite_controller.check_for_expired_satellites,
})

function all_seeing_satellite_controller.on_nth_tick(event)
    all_seeing_satellite_data = all_seeing_satellite_data or set_game() and all_seeing_satellite_data

    planets_dictionary = planets_dictionary or set_game() and planets_dictionary
    all_seeing_satellite_controller.planet_index, all_seeing_satellite_controller.planet = next(planets_dictionary, all_seeing_satellite_controller.planet_index)

    local planet = all_seeing_satellite_controller.planet

    if (not planet or not all_seeing_satellite_controller.planet_index) then return end
    if (not planet.surface or not planet.surface.valid) then return end

    toggle_FoW(planet)
end
Event_Handler:register_event({
    event_name = "on_nth_tick",
    nth_tick = nth_tick,
    source_name = "all_seeing_satellite_controller.on_nth_tick",
    func_name = "all_seeing_satellite_controller.on_nth_tick",
    func = all_seeing_satellite_controller.on_nth_tick,
})

function all_seeing_satellite_controller.on_runtime_mod_setting_changed(event)
    -- Log.debug("all_seeing_satellite_controller.on_runtime_mod_setting_changed")
    -- Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find(Constants.mod_name, 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name) then
        local satellite_time_to_live = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name, reindex = true })
        if (type(satellite_time_to_live) == "number") then
            if (satellite_time_to_live == 0) then
                Event_Handler:unregister_event({
                    event_name = "on_tick",
                    source_name = "all_seeing_satellite_controller.check_for_expired_satellites",
                })
                Log.warn("all_seeing_satellite_controller.check_for_expired_satellites unregistered")
            else
                local event_handler = Event_Handler:register_event({
                    event_name = "on_tick",
                    source_name = "all_seeing_satellite_controller.check_for_expired_satellites",
                    func_name = "all_seeing_satellite_controller.check_for_expired_satellites",
                    func = all_seeing_satellite_controller.check_for_expired_satellites,
                })
                -- Log.warn(event_handler)
                Satellite_Service.recalculate_satellite_time_to_die(event.tick)
            end
        end
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.NTH_TICK.name) then
        local new_nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NTH_TICK.name, reindex = true })
        if (    type(new_nth_tick) == "number"
            and new_nth_tick >= Runtime_Global_Settings_Constants.settings.NTH_TICK.minimum_value
            and new_nth_tick <= Runtime_Global_Settings_Constants.settings.NTH_TICK.maximum_value
        ) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = nth_tick
            Event_Handler:unregister_event({
                event_name = "on_nth_tick",
                nth_tick = prev_nth_tick,
                source_name = "all_seeing_satellite_controller.on_nth_tick",
            })

            local event_handler = Event_Handler:register_event({
                event_name = "on_nth_tick",
                nth_tick = new_nth_tick,
                source_name = "all_seeing_satellite_controller.on_nth_tick",
                func_name = "all_seeing_satellite_controller.on_nth_tick",
                func = all_seeing_satellite_controller.on_nth_tick,
            })
            nth_tick = new_nth_tick
            -- Log.warn(event_handler)
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "all_seeing_satellite_controller.on_runtime_mod_setting_changed",
    func_name = "all_seeing_satellite_controller.on_runtime_mod_setting_changed",
    func = all_seeing_satellite_controller.on_runtime_mod_setting_changed,
})

function all_seeing_satellite_controller.init(__storage) storage = __storage end

return all_seeing_satellite_controller
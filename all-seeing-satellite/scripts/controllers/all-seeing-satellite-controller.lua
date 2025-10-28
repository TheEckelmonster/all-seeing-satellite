local All_Seeing_Satellite_Service = require("scripts.services.all-seeing-satellite-service")
local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Fog_Of_War_Service = require("scripts.services.fog-of-war-service")
local Planet_Utils = require("scripts.utils.planet-utils")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Satellite_Service = require("scripts.services.satellite-service")

local all_seeing_satellite_controller = {}
all_seeing_satellite_controller.name = "all_seeing_satellite_controller"

all_seeing_satellite_controller.planet_index = nil
all_seeing_satellite_controller.planet = nil

local nth_tick =   Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NTH_TICK.name })
                or Runtime_Global_Settings_Constants.settings.NTH_TICK.default_value

function all_seeing_satellite_controller.on_tick_pocess_scanning(event)
    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (all_seeing_satellite_data.do_scan and all_seeing_satellite_controller.planet) then
        if (Planet_Utils.allow_scan(all_seeing_satellite_controller.planet.name)) then
            if (All_Seeing_Satellite_Service.check_for_areas_to_stage()) then
                All_Seeing_Satellite_Service.do_scan(all_seeing_satellite_controller.planet.name)
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "all_seeing_satellite_controller.on_tick_pocess_scanning",
    func_name = "all_seeing_satellite_controller.on_tick_pocess_scanning",
    func = all_seeing_satellite_controller.on_tick_pocess_scanning,
})

function all_seeing_satellite_controller.check_for_expired_satellites(event)
    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (not Constants.mod_data or not Constants.mod_data.planets_dictionary) then Constants.get_planet_data({ reindex = true }) end
    all_seeing_satellite_controller.planet_index, all_seeing_satellite_controller.planet = next(Constants.mod_data.planets_dictionary, all_seeing_satellite_controller.planet_index)

    local planet = all_seeing_satellite_controller.planet

    if (not planet or not all_seeing_satellite_controller.planet_index) then return end
    if (not planet.surface or not planet.surface.valid) then return end

    Satellite_Service.check_for_expired_satellites({ tick = game.tick, planet_name = planet.name })
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "all_seeing_satellite_controller.check_for_expired_satellites",
    func_name = "all_seeing_satellite_controller.check_for_expired_satellites",
    func = all_seeing_satellite_controller.check_for_expired_satellites,
})

function all_seeing_satellite_controller.on_nth_tick(event)
    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.do_nth_tick and all_seeing_satellite_data.version_data) then return end

    if (not Constants.mod_data.planets_dictionary) then Constants.get_planet_data({ reindex = true }) end
    all_seeing_satellite_controller.planet_index, all_seeing_satellite_controller.planet = next(Constants.mod_data.planets_dictionary, all_seeing_satellite_controller.planet_index)

    local planet = all_seeing_satellite_controller.planet

    if (not planet or not all_seeing_satellite_controller.planet_index) then return end
    if (not planet.surface or not planet.surface.valid) then return end

    Fog_Of_War_Service.toggle_FoW(planet)

    if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DO_LAUNCH_ROCKETS.name })) then
        Rocket_Silo_Service.launch_rocket({ tick = event.tick, planet = planet })
    end
end
Event_Handler:register_event({
    event_name = "on_nth_tick",
    nth_tick = nth_tick,
    source_name = "all_seeing_satellite_controller.on_nth_tick",
    func_name = "all_seeing_satellite_controller.on_nth_tick",
    func = all_seeing_satellite_controller.on_nth_tick,
})

function all_seeing_satellite_controller.on_runtime_mod_setting_changed(event)
    Log.debug("all_seeing_satellite_controller.on_runtime_mod_setting_changed")
    Log.info(event)

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
                Log.warn(event_handler)
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
            Log.warn(event_handler)
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "all_seeing_satellite_controller.on_runtime_mod_setting_changed",
    func_name = "all_seeing_satellite_controller.on_runtime_mod_setting_changed",
    func = all_seeing_satellite_controller.on_runtime_mod_setting_changed,
})

return all_seeing_satellite_controller
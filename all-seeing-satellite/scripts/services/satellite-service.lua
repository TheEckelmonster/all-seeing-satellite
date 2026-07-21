local storage
local satellite_meta_data_repository

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.satellite_meta_data_repository = storage.satellite_meta_data_repository or {}
    satellite_meta_data_repository = storage.satellite_meta_data_repository

    game = __game or _ENV.game

    Set_Game_Funcs()

    return game
end

local string_find = string.find

local ipairs = ipairs
local pairs = pairs
local type = type

local script = script
local active_mods = script and script.active_mods

local defines = defines
local inventory_cargo_unit = defines.inventory.cargo_unit
local defines_cargo_destination_station = defines.cargo_destination.station
local defines_cargo_destination_orbit = defines.cargo_destination.orbit

local CARGO_LANDING_PAD = "cargo-landing-pad"
local MSG_SATELLITE_OUT_OF_FUEL = "messages.satellite-out-of-fuel"
local SATELLITE = "satellite"
local TABLE = Types.TABLE

local RAISE_DESTROYED_TBL = { raise_destroy = true, }

local Runtime_Global_Settings_Constants = Runtime_Global_Settings_Constants
local Settings_Registry = Settings_Registry

local TECL_String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")
local format_surface_name = TECL_String_Utils.format_surface_name

local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local save_satellite_meta_data = Satellite_Meta_Repository.save_satellite_meta_data
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local save_in_transit_satellite_data = Satellite_Repository.save_in_transit_satellite_data
local delete_satellite_data_by_index = Satellite_Repository.delete_satellite_data_by_index
local get_all_satellite_data = Satellite_Repository.get_all_satellite_data
local Satellite_Utils = require("scripts.utils.satellite-utils")
local satellite_launched = Satellite_Utils.satellite_launched
local get_num_satellites_in_orbit = Satellite_Utils.get_num_satellites_in_orbit
local calculate_tick_to_die = Satellite_Utils.calculate_tick_to_die

local sa_active = active_mods and active_mods["space-age"]

local track_satellites_launched_for_research = not sa_active and Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.TRACK_SATELLITES_LAUNCHED_FOR_RESEARCH.name, })
local satellite_out_of_fuel_message = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_OUT_OF_FUEL_MESSAGE.name, })

local satellite_service = {}
satellite_service.name = "satellite_service"
satellite_service.set_game = set_game

function satellite_service.track_satellite_launches_ordered(event)
    -- Log.debug("satellite_service.track_satellite_launches_ordered")
    -- Log.info(event)
    if (not event) then return end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    local cargo_pod = event.cargo_pod
    if (not cargo_pod.cargo_pod_destination) then return end

    local cargo_pod_destination = cargo_pod.cargo_pod_destination
    if (    sa_active
        and cargo_pod_destination
        and (   cargo_pod_destination.type == defines_cargo_destination_station
            and cargo_pod_destination.station
            and cargo_pod_destination.station.type == CARGO_LANDING_PAD
            or  cargo_pod_destination.type == defines_cargo_destination_orbit
        )
        and cargo_pod_destination.transform_launch_products
        and cargo_pod_destination.transform_launch_products == true
        and event.launched_by_rocket
        or
            not sa_active
        and track_satellites_launched_for_research
        and cargo_pod_destination
        and cargo_pod_destination.station
        and cargo_pod_destination.type == defines.cargo_destination.station
        and event.launched_by_rocket
    ) then
        local inventory = cargo_pod.get_inventory(inventory_cargo_unit)

        if (inventory and inventory.valid) then
            local surface_name = nil
            local tick = event.tick
            local surface = cargo_pod.surface
            local force = cargo_pod.force
            for _, item in ipairs(inventory.get_contents()) do
                if (item.name == SATELLITE) then
                    surface_name = nil
                    if (cargo_pod.surface and cargo_pod.surface.valid) then surface_name = cargo_pod.surface.name end
                    local satellite_meta_data = get_satellite_meta_data(surface_name)
                    if (satellite_meta_data) then
                        local destroy_on_success = true
                        local satellite_in_transit_data = satellite_meta_data.satellites_in_transit[cargo_pod.unit_number]
                        if (not satellite_in_transit_data) then
                            satellite_in_transit_data = save_in_transit_satellite_data({
                                cargo_pod = cargo_pod,
                                cargo_pod_unit_number = cargo_pod.unit_number,
                                planet_name = surface.name,
                                surface_index = surface.index,
                                force = force,
                                force_index = force.index,
                                entity = item,
                            })
                            if (satellite_in_transit_data and not sa_active and track_satellites_launched_for_research) then destroy_on_success = false end
                        end

                        if (satellite_in_transit_data) then
                            satellite_launched(satellite_in_transit_data, tick, satellite_meta_data)

                            if (destroy_on_success) then
                                -- Log.debug("destroying cargo pod")
                                if (cargo_pod.destroy(RAISE_DESTROYED_TBL)) then
                                    -- Log.debug("cargo pod destroyed")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function satellite_service.check_for_expired_satellites(planet_name, tick)
    -- Log.debug("satellite_service.check_for_expired_satellites")
    -- Log.info(event)
    -- Log.info(event.planet_name)

    if (not planet_name) then return end

    tick = tick or (game or set_game()).tick or 0

    satellite_meta_data_repository = satellite_meta_data_repository or set_game() and satellite_meta_data_repository
    satellite_meta_data_repository[planet_name] = satellite_meta_data_repository[planet_name] or save_satellite_meta_data(planet_name)
    local satellite_meta_data = satellite_meta_data_repository[planet_name]

    for i, satellite_data in pairs(satellite_meta_data.satellites) do
        if (tick >= satellite_data.tick_to_die) then
            if (satellite_meta_data.satellites_launched and #satellite_meta_data.satellites > 0) then
                delete_satellite_data_by_index(satellite_data.planet_name, i)
                if (satellite_meta_data.satellites_in_orbit) then
                    get_num_satellites_in_orbit(satellite_meta_data)
                end
                if (satellite_out_of_fuel_message) then
                    local force = satellite_data.force
                    if (force and force.valid) then
                        force.print({ MSG_SATELLITE_OUT_OF_FUEL, format_surface_name({ string_data = satellite_data.planet_name }) })
                    end
                end
            end
        elseif (tick < satellite_data.tick_to_die) then
            --[[ Satellites are nominally ordered by their tick_to_die ("created" tick, technically)
                -> if one is found to still be valid, so are all after it
                -> no need to continue checking for expired satellites
            ]]
            return
        end
    end
end

function satellite_service.recalculate_satellite_time_to_die(tick)
    -- Log.debug("satellite_service.recalculate_satellite_time_to_die")
    -- Log.info(tick)
    tick = tick or 1 --math.huge

    if (tick > 1) then
        local all_satellite_data = get_all_satellite_data()
        if (type(all_satellite_data) == TABLE) then
            for _, satellites in pairs(all_satellite_data) do
                for _, satellite_data in pairs(satellites) do
                    satellite_data.tick_to_die = calculate_tick_to_die(satellite_data.created, satellite_data.entity)
                    satellite_data.updated = tick
                end
            end
        end
    end
end

local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_OUT_OF_FUEL_MESSAGE.name] = function (event, params) satellite_out_of_fuel_message = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.TRACK_SATELLITES_LAUNCHED_FOR_RESEARCH.name] = function (event, params) track_satellites_launched_for_research = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function satellite_service.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "satellite_service",
    func = satellite_service.on_runtime_mod_setting_changed
})

function satellite_service.init(__storage) storage = __storage end

return satellite_service
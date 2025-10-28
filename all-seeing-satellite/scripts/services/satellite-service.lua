local TECL_String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")

local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local Satellite_Utils = require("scripts.utils.satellite-utils")

local sa_active = scripts and scripts.active_mods and script.active_mods["space-age"]

local satellite_service = {}

function satellite_service.track_satellite_launches_ordered(event)
    Log.debug("satellite_service.track_satellite_launches_ordered")
    Log.info(event)

    if (not event) then return end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    local cargo_pod = event.cargo_pod
    if (not cargo_pod.cargo_pod_destination) then return end

    -- Check for a satellite if the cargo pod doesn't have a station and has a destination type of 1
    --   -> no station implies it was sent to "orbit"
    --   -> .type is 1 for some reason, and not defines.cargo_destination.orbit as I would have thought
    if (    cargo_pod.cargo_pod_destination
        and not cargo_pod.cargo_pod_destination.station
        and cargo_pod.cargo_pod_destination.type == 1
        and event.launched_by_rocket
        or
            not sa_active
        and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.TRACK_SATELLITES_LAUNCHED_FOR_RESEARCH.name})
        and cargo_pod.cargo_pod_destination
        and cargo_pod.cargo_pod_destination.station
        and cargo_pod.cargo_pod_destination.type == 1
        and event.launched_by_rocket
    ) then
        local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)

        if (inventory and inventory.valid) then
            for _, item in ipairs(inventory.get_contents()) do
                if (item.name == "satellite") then
                    local surface_name = nil
                    if (cargo_pod.surface and cargo_pod.surface.valid) then surface_name = cargo_pod.surface.name end
                    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
                    if (satellite_meta_data and satellite_meta_data.valid) then
                        local destroy_on_success = true
                        local satellite_in_transit_data = satellite_meta_data.satellites_in_transit[cargo_pod.unit_number]
                        if ((not satellite_in_transit_data or not satellite_in_transit_data.valid) and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.TRACK_SATELLITES_LAUNCHED_FOR_RESEARCH.name })) then
                            satellite_in_transit_data = Satellite_Repository.save_in_transit_satellite_data({
                                cargo_pod = cargo_pod,
                                cargo_pod_unit_number = cargo_pod.unit_number,
                                planet_name = cargo_pod.surface.name,
                                surface_index = cargo_pod.surface.index,
                                force = cargo_pod.force,
                                force_index = cargo_pod.force.index,
                                entity = item,
                            })
                            if (satellite_in_transit_data and satellite_in_transit_data.valid) then destroy_on_success = false end
                        end

                        if (satellite_in_transit_data and satellite_in_transit_data.valid) then
                            Satellite_Utils.satellite_launched(satellite_in_transit_data, event.tick, satellite_meta_data)

                            if (destroy_on_success) then
                                Log.info("destroying cargo pod")
                                if (cargo_pod.destroy()) then
                                    Log.debug("cargo pod destroyed")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function satellite_service.check_for_expired_satellites(event)
    Log.debug("satellite_service.check_for_expired_satellites")
    Log.info(event)
    Log.info(event.planet_name)

    if (not event) then return end
    if (not event.tick) then return end
    if (not event.planet_name) then return end

    local planet_name = event.planet_name
    if (not planet_name) then return end

    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
    if (not satellite_meta_data.valid) then return end

    for i, satellite_data in pairs(satellite_meta_data.satellites) do
        if (not satellite_data.valid) then
            goto continue
        end

        if (event.tick >= satellite_data.tick_to_die) then
            if (satellite_meta_data.satellites_launched and #satellite_meta_data.satellites > 0) then
                Satellite_Repository.delete_satellite_data_by_index({ planet_name = satellite_data.planet_name, index = i, })
                if (satellite_meta_data.satellites_in_orbit) then
                    Satellite_Utils.get_num_satellites_in_orbit(satellite_meta_data)
                end
                -- TODO: Change this to force.print
                if (satellite_data.force and satellite_data.force.valid) then
                    satellite_data.force.print({ "messages.satellite-out-of-fuel", TECL_String_Utils.format_surface_name({ string_data = satellite_data.planet_name }) })
                end
            end
        elseif (event.tick < satellite_data.tick_to_die) then
            --[[ Satellites are nominally ordered by their tick_to_die ("created" tick, technically)
                -> if one is found to still be valid, so are all after it
                -> no need to continue checking for expired satellites
            ]]
            return
        end
        ::continue::
    end
end

function satellite_service.recalculate_satellite_time_to_die(tick)
    Log.debug("satellite_service.recalculate_satellite_time_to_die")
    Log.info(tick)
    tick = tick or 1 --math.huge

    if (tick > 1) then
        local all_satellite_data = Satellite_Repository.get_all_satellite_data()
        if (type(all_satellite_data) == "table") then
            for planet_name, satellites in pairs(all_satellite_data) do
                for i, satellite_data in pairs(satellites) do
                    satellite_data.tick_to_die = Satellite_Utils.calculate_tick_to_die(satellite_data.created, satellite_data.entity)
                    satellite_data.updated = game.tick
                end
            end
        end
    end
end

return satellite_service
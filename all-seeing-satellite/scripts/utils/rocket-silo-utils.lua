local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")

local rocket_silo_utils = {}
rocket_silo_utils.name = "rocket_silo_utils"

function rocket_silo_utils.mine_rocket_silo(event)
    Log.debug("rocket_silo_utils.mine_rocket_silo")
    Log.info(event)
    local rocket_silo = event.entity

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
    end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
    Log.debug("rocket_silo_utils.add_rocket_silo")
    Log.info(rocket_silo)

    Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function rocket_silo_utils.launch_rocket(event)
    Log.debug("rocket_silo_utils.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick or not event.planet or not event.planet.valid) then return end
    if (not event.planet.name) then return end
    local planet = event.planet
    if (not planet) then return end

    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)

    for _, rocket_silo_data in pairs(satellite_meta_data.rocket_silos) do
        local rocket_silo = nil

        if (rocket_silo_data.entity and rocket_silo_data.entity.valid) then
            rocket_silo = rocket_silo_data.entity
        end

        if (rocket_silo and rocket_silo.valid and rocket_silo.type == "rocket-silo" and rocket_silo.rocket_silo_status == defines.rocket_silo_status.rocket_ready) then
            local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
            if (inventory) then
                for _, item in ipairs(inventory.get_contents()) do
                    if (item.name == "satellite") then
                        local rocket = rocket_silo.rocket

                        if (rocket and rocket.valid) then
                            local cargo_pod = rocket.attached_cargo_pod

                            local nth_tick = game.tick + (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_LAUNCH_DELAY.name }) or 0)
                            local source_name = "rocket_silo_utils.launch_rocket_event"

                            local event_handler_data = Event_Handler:register_event({
                                event_name = "on_nth_tick",
                                nth_tick = nth_tick,
                                source_name = source_name,
                                restore_on_load = true,
                                func = rocket_silo_utils.launch_rocket_event,
                                func_name = "rocket_silo_utils.launch_rocket_event",
                                func_data =
                                {
                                    nth_tick = nth_tick,
                                    source_name = source_name,
                                    cargo_pod = cargo_pod,
                                    rocket_silo = rocket_silo,
                                },
                                save_to_storage = true,
                            })

                            Log.warn(event_handler_data)
                        end
                    end
                end
            end
        end
    end
end

function rocket_silo_utils.launch_rocket_event(event, event_data)
    Log.debug("rocket_silo_utils.launch_rocket_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.rocket_silo.valid and event_data.rocket_silo.type == "rocket-silo" and event_data.rocket_silo.rocket_silo_status ~= defines.rocket_silo_status.rocket_ready) then return end

    if (event_data.rocket_silo and event_data.rocket_silo.valid) then
        local inventory = event_data.rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
        if (inventory and inventory.valid) then
            for _, item in ipairs(inventory.get_contents()) do
                if (item.name == "satellite") then
                    local rocket = event_data.rocket_silo.rocket

                    if (rocket and rocket.valid) then
                        local cargo_pod = rocket.attached_cargo_pod

                        if (cargo_pod and cargo_pod.valid) then
                            cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }

                            if (event_data.rocket_silo.launch_rocket()) then
                                Log.info("Launched satellite: " .. serpent.block(rocket_silo))
                                local in_transit_satellite_data = {
                                    cargo_pod = cargo_pod,
                                    cargo_pod_unit_number = cargo_pod.unit_number,
                                    planet_name = event_data.rocket_silo.surface.name,
                                    surface_index = event_data.rocket_silo.surface.index,
                                    force = event_data.rocket_silo.force,
                                    force_index = event_data.rocket_silo.force.index,
                                    entity = item,
                                }
                                local returned_data = Satellite_Repository.save_in_transit_satellite_data(in_transit_satellite_data)
                                Log.warn(returned_data)
                            else
                                Log.info("Failed to launch satellite: " .. serpent.block(event_data.rocket_silo))
                            end
                        end
                    end
                end
            end
        end
    end
end

return rocket_silo_utils
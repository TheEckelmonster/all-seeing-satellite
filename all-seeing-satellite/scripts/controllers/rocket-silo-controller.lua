local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_controller = {}
rocket_silo_controller.name = "rocket_silo_controller"

function rocket_silo_controller.rocket_silo_built(event)
    Log.debug("rocket_silo_controller.rocket_silo_built")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
end
Event_Handler:register_events({
    {
        event_name = "on_built_entity",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
    },
    {
        event_name = "on_robot_built_entity",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
    },
    {
        event_name = "script_raised_built",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
    },
    {
        event_name = "script_raised_revive",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
    },
})

function rocket_silo_controller.rocket_silo_mined(event)
    Log.debug("rocket_silo_controller.rocket_silo_mined")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_mined(event)
end
Event_Handler:register_events({
    {
        event_name = "on_entity_died",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
    },
    {
        event_name = "on_player_mined_entity",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
    },
    {
        event_name = "on_robot_mined_entity",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
    },
    {
        event_name = "script_raised_destroy",
        filter = Filters.rocket_silo_filter,
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
    },
})

return rocket_silo_controller
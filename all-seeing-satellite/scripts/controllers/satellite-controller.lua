local Satellite_Service = require("scripts.services.satellite-service")

local satellite_controller = {}
satellite_controller.name = "satellite_controller"

function satellite_controller.track_satellite_launches_ordered(event)
    Log.debug("satellite_controller.track_satellite_launches_ordered")
    Log.info(event)

    Satellite_Service.track_satellite_launches_ordered(event)
end
Event_Handler:register_event({
    event_name = "on_cargo_pod_finished_ascending",
    source_name = "satellite_controller.track_satellite_launches_ordered",
    func_name = "satellite_controller.track_satellite_launches_ordered",
    func = satellite_controller.track_satellite_launches_ordered,
})

return satellite_controller
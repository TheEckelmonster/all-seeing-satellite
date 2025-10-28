local Satellite_Service = require("scripts.services.satellite-service")

local satellite_controller = {}
satellite_controller.name = "satellite_controller"

function satellite_controller.check_for_expired_satellites(event)
    Log.debug("satellite_controller.check_for_expired_satellites")
    Log.info(event)
    Satellite_Service.check_for_expired_satellites(event)
end

function satellite_controller.track_satellite_launches_ordered(event)
    Log.debug("satellite_controller.track_satellite_launches_ordered")
    Log.info(event)
    Satellite_Service.track_satellite_launches_ordered(event)
end

return satellite_controller
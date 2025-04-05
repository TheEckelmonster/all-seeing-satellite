-- If already defined, return
if _satellite_controller and _satellite_controller.all_seeing_satellite then
  return _satellite_controller
end

local Log = require("libs.log.log")
local Satellite_Service = require("control.services.satellite-service")

local satellite_controller = {}

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

satellite_controller.all_seeing_satellite = true

local _satellite_controller = satellite_controller

return satellite_controller
-- If already defined, return
if _planet_service and _planet_service.all_seeing_satellite then
  return _planet_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Initialization = require("control.initialization")

local planet_service = {}

function planet_service.on_surface_created(event)
  Log.info(event)
  local planets = Constants.get_planets(true)
  Log.info(planets)
  Initialization.reinit()
end

planet_service.all_seeing_satellite = true

local _planet_service = planet_service

return planet_service
-- -- If already defined, return
-- if _planet and _planet.all_seeing_satellite then
--   return _planet
-- end

-- local Constants = require("libs.constants.constants")
-- local Log = require("libs.log.log")
-- local Initialization = require("control.initialization")

-- local planet = {}

-- function planet.on_surface_created(event)
--   Log.info("planet.on_surface_created")
--   local planets = Constants.get_planets(true)
--   Log.info(planets)
--   Initialization.reinit()
-- end

-- planet.all_seeing_satellite = true

-- local _planet = planet

-- return planet
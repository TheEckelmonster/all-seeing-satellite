local Planet_Service = require("scripts.services.planet-service")

local planet_controller = {}
planet_controller.name = "planet_controller"

function planet_controller.on_surface_created(event)
    Log.debug("planet_controller.on_surface_created")
    Log.info(event)
    Planet_Service.on_surface_created(event)
end

return planet_controller
-- If already defined, return
if _rocket_silo_controller and _rocket_silo_controller.all_seeing_satellite then
  return _rocket_silo_controller
end

local Log = require("libs.log.log")
local Rocket_Silo_Service = require("control.services.rocket-silo-service")

local rocket_silo_controller = {}

rocket_silo_controller.filter = {{ filter = "type", type = "rocket-silo" }}

function rocket_silo_controller.rocket_silo_built(event)
  Log.debug("rocket_silo_controller.rocket_silo_built")
  Log.info(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
  end
end

function rocket_silo_controller.rocket_silo_mined(event)
  Log.debug("rocket_silo_controller.rocket_silo_mined")
  Log.info(event)
  Rocket_Silo_Service.rocket_silo_mined(event)
end

function rocket_silo_controller.rocket_silo_mined_script(event)
  Log.debug("rocket_silo_controller.rocket_silo_mined_script")
  Log.info(event)
  Rocket_Silo_Service.rocket_silo_mined(event)
end

function rocket_silo_controller.launch_rocket(event)
  Log.debug("rocket_silo_controller.launch_rocket")
  Log.info(event)
  Rocket_Silo_Service.launch_rocket(event)
end

rocket_silo_controller.all_seeing_satellite = true

local _rocket_silo_controller = rocket_silo_controller

return rocket_silo_controller
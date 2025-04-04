-- If already defined, return
if _rocket_silo_controller and _rocket_silo_controller.all_seeing_satellite then
  return _rocket_silo_controller
end

local Log = require("libs.log.log")
local Log_Constants = require("libs.constants.log-constants")
local Rocket_Silo_Service = require("control.services.rocket-silo-service")

local rocket_silo_controller = {}

rocket_silo_controller.filter = {{ filter = "type", type = "rocket-silo" }}

function rocket_silo_controller.rocket_silo_built(event)
  Log.info(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
    Rocket_Silo_Service.add_rocket_silo(rocket_silo)
  end
end

function rocket_silo_controller.rocket_silo_mined(event)
  Log.info(event)
  Rocket_Silo_Service.mine_rocket_silo(event)
end

function rocket_silo_controller.rocket_silo_mined_script(event)
  Log.info(event)
  Rocket_Silo_Service.mine_rocket_silo(event)
end

function rocket_silo_controller.launch_rocket(event)
  Log.info(event)
  Rocket_Silo_Service.launch_rocket(event)
end

function rocket_silo_controller.rocket_silo_built(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
  end
end

function rocket_silo_controller.rocket_silo_mined(event)
  Log.info(event)
  Rocket_Silo_Service.mine_rocket_silo(event)
end

function rocket_silo_controller.rocket_silo_mined_script(event)
  Log.info(event)
  Rocket_Silo_Service.mine_rocket_silo(event)
end

rocket_silo_controller.all_seeing_satellite = true

local _rocket_silo_controller = rocket_silo_controller

return rocket_silo_controller
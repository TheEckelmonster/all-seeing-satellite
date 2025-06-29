-- If already defined, return
if _rocket_silo_service and _rocket_silo_service.all_seeing_satellite then
  return _rocket_silo_service
end

local Log = require("libs.log.log")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")

local rocket_silo_service = {}

function rocket_silo_service.rocket_silo_built(rocket_silo)
  Log.debug("rocket_silo_service.rocket_silo_built")
  Log.info(rocket_silo)

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
    Rocket_Silo_Utils.add_rocket_silo(rocket_silo)
    Log.info("Built rocket silo")
    Log.info(serpent.block(rocket_silo))
  end
end

function rocket_silo_service.rocket_silo_mined(event)
  Log.debug("rocket_silo_service.rocket_silo_mined")
  Log.info(event)
  Rocket_Silo_Utils.mine_rocket_silo(event)
end

function rocket_silo_service.rocket_silo_mined_script(event)
  Log.debug("rocket_silo_service.rocket_silo_mined_script")
  Log.info(event)
  Rocket_Silo_Utils.mine_rocket_silo(event)
end

function rocket_silo_service.launch_rocket(event)
  Log.debug("rocket_silo_service.launch_rocket")
  Log.info(event)
  Rocket_Silo_Utils.launch_rocket(event)
end

rocket_silo_service.all_seeing_satellite = true

local _rocket_silo_service = rocket_silo_service

return rocket_silo_service
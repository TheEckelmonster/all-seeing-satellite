-- If already defined, return
if _rocket_silo and _rocket_silo.all_seeing_satellite then
  return _rocket_silo
end

local Rocket_Utils = require("libs.utils.rocket-utils")

local rocket_silo = {}

function rocket_silo.rocket_silo_built(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      Initialization.init()
    else
      Rocket_Utils.add_rocket_silo(rocket_silo)
      log("Built rocket silo")
      log(serpent.block(rocket_silo))
    end
  end
end

function rocket_silo.rocket_silo_mined(event)
  Rocket_Utils.mine_rocket_silo(event)
end

function rocket_silo.rocket_silo_mined_script(event)
  Rocket_Utils.mine_rocket_silo(event)
end

rocket_silo.all_seeing_satellite = true

local _rocket_silo = rocket_silo

return rocket_silo
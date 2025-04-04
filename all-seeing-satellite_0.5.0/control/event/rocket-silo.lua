-- -- If already defined, return
-- if _rocket_silo and _rocket_silo.all_seeing_satellite then
--   return _rocket_silo
-- end

-- local Log = require("libs.log.log")
-- local Log_Constants = require("libs.constants.log-constants")
-- local Rocket_Utils = require("control.utils.rocket-utils")
-- local Validations = require("control.validations.validations")

-- local rocket_silo = {}

-- function rocket_silo.rocket_silo_built(event)
-- 	local rocket_silo = event.entity

-- 	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
-- 		if (not Validations.is_storage_valid()) then
--       Log.error("Storage is invalid; initializing")
--       Initialization.init()
--     else
--       Rocket_Utils.add_rocket_silo(rocket_silo)
--       Log.info("Built rocket silo")
--       Log.info(serpent.block(rocket_silo))
--     end
--   end
-- end

-- function rocket_silo.rocket_silo_mined(event)
--   Log.info("Rocket silo mined")
--   Rocket_Utils.mine_rocket_silo(event)
-- end

-- function rocket_silo.rocket_silo_mined_script(event)
--   Log.info("Rocket silo mined script")
--   Rocket_Utils.mine_rocket_silo(event)
-- end

-- rocket_silo.all_seeing_satellite = true

-- local _rocket_silo = rocket_silo

-- return rocket_silo
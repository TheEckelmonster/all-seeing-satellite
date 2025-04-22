-- -- If already defined, return
-- if _validations and _validations.all_seeing_satellite then
--   return _validations
-- end

-- local Log = require("libs.log.log")

-- local validations = {}

-- function validations.validate_toggled_satellites_planet(satellites_toggled, planet_name)
--   return pcall(pcall_validate_toggled_satellites_planet, { satellites_toggled, planet_name })
-- end

-- function pcall_validate_toggled_satellites_planet(satellites_toggled, planet_name)
--   return storage.satellites_toggled[planet.name].valid
-- end

-- validations.all_seeing_satellite = true

-- local _validations = validations

-- return validations
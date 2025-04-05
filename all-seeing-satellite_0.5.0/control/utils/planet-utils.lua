-- If already defined, return
if _planet_utils and _planet_utils.all_seeing_satellite then
  return _planet_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Validations = require("control.validations.validations")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("control.services.settings-service")

local planet_utils = {}


function planet_utils.allow_toggle(surface_name)
  if (not Settings_Service.get_require_satellites_in_orbit()) then
    return true
  end

  if (surface_name) then
    return  Validations.is_storage_valid()
        and storage.satellites_launched
        and storage.satellites_launched[surface_name]
        and (
          storage.satellites_launched[surface_name] >= planet_utils.planet_launch_threshold(surface_name))
  end
  return false
end

function planet_utils.planet_launch_threshold(surface_name)
  if (not surface_name) then
    return Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value
  end

  local planet_multiplier = get_planet_multiplier(surface_name)
  local return_val = Settings_Service.get_global_launch_satellite_threshold(surface_name) * planet_multiplier * planet_multiplier

  if (get_planet_multiplier(surface_name) < 1) then
    Log.debug("floor")
    return_val = math.floor(return_val)
  else
    Log.debug("ceil")
    return_val = math.ceil(return_val)
  end

  return return_val
end

function get_planet_multiplier(surface_name)
  local planets = Constants.get_planets()
  local planet_multiplier = 1

  if (planets) then
    for _, planet in ipairs(planets) do
      if (planet and planet.name == surface_name) then
        planet_multiplier = planet.magnitude
        break
      end
    end
  end

  Log.info(planet_multiplier)

  if (not planet_multiplier) then
    planet_multiplier = 1
  end

  return planet_multiplier
end

planet_utils.all_seeing_satellite = true

local _planet_utils = planet_utils

return planet_utils
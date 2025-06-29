-- If already defined, return
if _planet_utils and _planet_utils.all_seeing_satellite then
  return _planet_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("scripts.services.settings-service")
local String_Utils = require("scripts.utils.string-utils")

local planet_utils = {}

function planet_utils.allow_toggle(surface_name)
  Log.debug("planet_utils.allow_toggle")
  Log.info(surface_name)

  if (String_Utils.find_invalid_substrings(surface_name)) then return false end

  if (not Settings_Service.get_require_satellites_in_orbit()) then return true end

  if (surface_name) then
    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
    return satellite_meta_data and satellite_meta_data.valid and satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
  end

  return false
end

function planet_utils.allow_satellite_mode(surface_name)
  Log.debug("planet_utils.allow_satellite_mode")
  Log.info(surface_name)

  if (String_Utils.find_invalid_substrings(surface_name)) then return false end

  if (not Settings_Service.get_restrict_satellite_mode()) then return true end

  if (surface_name) then
    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
    return satellite_meta_data and satellite_meta_data.valid and satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
  end

  return false
end

function planet_utils.planet_launch_threshold(surface_name)
  Log.debug("planet_utils.planet_launch_threshold")
  Log.info(surface_name)

  if (not surface_name) then
    -- Intentionally calling with nil parameter to each, so as to get the default_value for each setting
    return Settings_Service.get_global_launch_satellite_threshold() * Settings_Service.get_global_launch_satellite_threshold_modifier()
  end

  if (String_Utils.find_invalid_substrings(surface_name)) then return end

  local planet_magnitude = get_planet_magnitude(surface_name)
  local return_val = Settings_Service.get_global_launch_satellite_threshold(surface_name) * Settings_Service.get_global_launch_satellite_threshold_modifier(surface_name) * planet_magnitude^2

  if (planet_magnitude < 1) then
    Log.debug("floor")
    return_val = math.floor(return_val)
  else
    Log.debug("ceil")
    return_val = math.ceil(return_val)
  end

  return return_val
end

function planet_utils.allow_scan(surface_name)
  Log.debug("planet_utils.allow_scan")
  Log.info(surface_name)

  if (not surface_name) then return false end

  if (not Settings_Service.get_restrict_satellite_scanning()) then return true end

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)

  return satellite_meta_data and satellite_meta_data.valid and (satellite_meta_data.satellites_in_orbit > 0 or #satellite_meta_data.satellites > 0)
end

function get_planet_magnitude(surface_name)
  Log.debug("planet_utils.get_planet_magnitude")
  Log.info(surface_name)

  local planets = Constants.get_planets()
  local planet_magnitude = 1

  if (planets) then
    for _, planet in ipairs(planets) do
      if (planet and planet.name == surface_name) then
        planet_magnitude = planet.magnitude
        break
      end
    end
  end

  Log.info(planet_magnitude)

  if (not planet_magnitude) then
    planet_magnitude = 1
  end

  return planet_magnitude
end

planet_utils.all_seeing_satellite = true

local _planet_utils = planet_utils

return planet_utils
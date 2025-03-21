-- If already defined, return
if _validations and _validations.all_seeing_satellite then
  return _validations
end

local Log = require("libs.log")

local validations = {}

function validations.is_storage_valid()
  return storage.all_seeing_satellite and storage.all_seeing_satellite.valid
end

function validations.validate_satellites_launched(planet_name)
  Log.debug(planet_name)
  if (not storage.satellites_launched) then
    Log.warn("storage.satellites_launched was nil")
    Log.warn("initializing storage.satellites_launched to {}")
    storage.satellites_launched = {}
  end

  if (not planet_name) then
    Log.error("Planet name is nil - How?")
    return false
  end

  if (not storage.satellites_launched[planet_name]) then
    Log.warn("No value found for satellites_launched[" .. planet_name .. "]")
    Log.warn("Setting satellites_launched[" .. planet_name .. "] to 0")
    storage.satellites_launched[planet_name] = 0
  end

  return true
end

function validations.validate_satellites_in_orbit(planet_name)
  if (not storage.satellites_in_orbit) then
    Log.warn("storage.satellites_in_orbit was nil")
    Log.warn("initializing storage.satellites_in_orbit to {}")
    storage.satellites_in_orbit = {}
  end

  if (not planet_name) then
    Log.error("Planet name is nil - How?")
    return false
  end

  if (not storage.satellites_in_orbit[planet_name]) then
    Log.warn("No value found for satellites_launched[" .. planet_name .. "]")
    Log.warn("Setting satellites_launched[" .. planet_name .. "] to {}")
    storage.satellites_in_orbit[planet_name] = {}
  end

  return true
end

function validations.validate_toggled_satellites_planet(satellites_toggled, planet_name)
  return pcall(pcall_validate_toggled_satellites_planet, {satellites_toggled, planet_name})
end

function pcall_validate_toggled_satellites_planet(satellites_toggled, planet_name)
  return storage.satellites_toggled[planet.name].valid
end

validations.all_seeing_satellite = true

local _validations = validations

return validations
-- If already defined, return
if _validations and _validations.all_seeing_satellite then
  return _validations
end

local validations = {}

function validations.is_storage_valid()
  return storage.all_seeing_satellite and storage.all_seeing_satellite.valid
end

function validations.validate_satellites_launched(planet_name)
  if (not storage.satellites_launched) then
    storage.satellites_launched = {}
  end

  if (not planet_name) then
    return false
  end

  if (not storage.satellites_launched[planet_name]) then
    storage.satellites_launched[planet_name] = 0
  end

  return true
end

function validations.validate_satellites_in_orbit(planet_name)
  if (not storage.satellites_in_orbit) then
    storage.satellites_in_orbit = {}
  end

  if (not planet_name) then
    return false
  end

  if (not storage.satellites_in_orbit[planet_name]) then
    storage.satellites_in_orbit[planet_name] = {}
  end

  return true
end

validations.all_seeing_satellite = true

local _validations = validations

return validations
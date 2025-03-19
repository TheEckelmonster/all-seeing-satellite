-- If already defined, return
if _string_constants and _string_constants.all_seeing_satellite then
  return _string_constants
end

local string_constants = {}

string_constants.PLANET_MAGNITUDE_DECIMAL_SHIFT = {}
string_constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value = 100

string_constants.all_seeing_satellite = true

local _string_constants = string_constants

return string_constants
-- If already defined, return
if _string_utils and _string_utils.all_seeing_satellite then
  return _string_utils
end

local String_Constants = require("libs.constants.string-constants")

local string_utils = {}

-- ../libs/utils/constants.lua has a copy of this function
--   -> done to avoid a circular reference
function string_utils.find_invalid_substrings(string)
  return string.find(string, "EE_", 1, true)
      or string.find(string, "TEST", 1, true)
      or string.find(string, "test", 1, true)
end

function string_utils.is_all_seeing_satellite_added_planet(string)
  if (not is_string_valid(string)) then
    return
  end
  return string.find(string, "all-seeing-satellite-", 1, true)
end

function string_utils.get_planet_name(string)
  if (not is_string_valid(string)) then
    return
  end

  local i, j = string.find(string, "all-seeing-satellite-", 1, true)
  if (j) then
    local x, y = string.find(string, "_", j + 1, true)

    if (j and x) then
      return string.sub(string, j + 1, x -1)
    end
  end
end

function string_utils.get_planet_magnitude(string)
  if (not is_string_valid(string)) then
    return
  end

  local i, j = string.find(string, "all-seeing-satellite-", 1, true)

  if (j) then
    local x, y = string.find(string, "_", j + 1, true)
    if (y) then
      return string.sub(string, y + 1, -1) / String_Constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value
    end
  end
end

function is_string_valid(string)
  return string and #string > 0
end

string_utils.all_seeing_satellite = true

local _string_utils = string_utils

return string_utils
-- If already defined, return
if _string_utils and _string_utils.all_seeing_satellite then
  return _string_utils
end

local Log = require("libs.log.log")
local String_Constants = require("libs.constants.string-constants")

local string_utils = {}

function string_utils.find_invalid_substrings(string)
  Log.debug("string_utils.find_invalid_substrings")
  Log.info(string)

  return type(string) ~= "string"
      or string:find("EE_", 1, true)
      or string:find("TEST", 1, true)
      or string:find("test", 1, true)
      or string:find("platform-", 1, true)
end

function string_utils.is_all_seeing_satellite_added_planet(string)
  Log.debug("string_utils.is_all_seeing_satellite_added_planet")
  Log.info(string)

  if (not is_string_valid(string)) then
    return
  end

  return string.find(string, "all-seeing-satellite-", 1, true)
end

function string_utils.get_planet_name(string)
  Log.debug("string_utils.get_planet_name")
  Log.info(string)

  if (not is_string_valid(string)) then
    return
  end

  local i, j = string.find(string, "all-seeing-satellite-", 1, true)
  if (j) then
    Log.debug("Found prefix")
    local x, y = string.find(string, "_", j + 1, true)

    if (j and x) then
      Log.debug("Getting planet name")
      return string.sub(string, j + 1, x -1)
    end
  end
end

function string_utils.get_planet_magnitude(string)
  Log.debug("string_utils.get_planet_magnitude")
  Log.info(string)

  if (not is_string_valid(string)) then
    return
  end

  local i, j = string.find(string, "all-seeing-satellite-", 1, true)

  if (j) then
    Log.debug("Found prefix")
    local x, y = string.find(string, "_", j + 1, true)
    if (y) then
      Log.debug("Getting planet magnitude")
      return string.sub(string, y + 1, -1) / String_Constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value
    end
  end
end

function is_string_valid(string)
  Log.debug("string_utils, is_string_valid")
  Log.info(string)

  return string and type(string) == "string" and #string > 0
end

string_utils.all_seeing_satellite = true

local _string_utils = string_utils

return string_utils
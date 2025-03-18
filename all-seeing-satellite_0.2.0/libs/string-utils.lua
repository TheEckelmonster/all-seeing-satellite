-- If already defined, return
if _string_utils and _string_utils.all_seeing_satellite then
  return _string_utils
end

local string_utils = {}

function string_utils.find_invalid_substrings(string)
  return string.find(string, "-", 1, true)
      or string.find(string, "EE_", 1, true)
      or string.find(string, "TEST", 1, true)
      or string.find(string, "test", 1, true)
end

string_utils.all_seeing_satellite = true

local _string_utils = string_utils

return string_utils
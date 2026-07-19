local string_find = string.find

local TECL_String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")
local is_string_valid = TECL_String_Utils.is_string_valid

local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local string_utils = {}

function string_utils.find_invalid_substrings(string_data)
    -- Log.debug("string_utils.find_invalid_substrings")
    -- Log.info(string_data)

    return
        (not is_string_valid(string_data))
        or
        (      string_find(string_data, "EE_", 1, true)
            or string_find(string_data, "TEST", 1, true)
            or string_find(string_data, "test", 1, true)
            or string_find(string_data, "platform-", 1, true)
            or string_find(string_data, "aai-signals", 1, true)
        )
        or
        (       se_active
            and (string_find(string_data, "starmap-", 1, true))
        )
end

return string_utils
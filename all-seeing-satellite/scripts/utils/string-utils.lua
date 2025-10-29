local TECL_String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")

local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local string_utils = {}

function string_utils.find_invalid_substrings(string_data)
    Log.debug("string_utils.find_invalid_substrings")
    Log.info(string_data)

    return
        (not TECL_String_Utils.is_string_valid(string_data))
        or
        (      string_data:find("EE_", 1, true)
            or string_data:find("TEST", 1, true)
            or string_data:find("test", 1, true)
            or string_data:find("platform-", 1, true)
            or string_data:find("aai-signals", 1, true)
        )
        or
        (       se_active
            and (string_data:find("starmap-", 1, true))
        )
end

return string_utils
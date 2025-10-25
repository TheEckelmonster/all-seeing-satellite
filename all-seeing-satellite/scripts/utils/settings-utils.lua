-- If already defined, return
if _settings_utils and _settings_utils.all_seeing_satellite then
    return _settings_utils
end

local Log = require("libs.log.log")

local settings_utils = {}

settings_utils.all_seeing_satellite = true

local _settings_utils = settings_utils

return settings_utils
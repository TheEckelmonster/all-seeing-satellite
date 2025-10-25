local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")

-- This intionally resides here
--   Moving it to log-constants.lua causes a circular dependence by requiring the log-constants-functions
--   which would require the log-constants, requiring the log-constants-functions, requiring the log-constants,
--   etc..
local LOGGING_LEVEL = {
    type = "string-setting",
    name = Log_Constants.settings.LOGGING_LEVEL.name,
    setting_type = "runtime-global",
    order = "aba",
    default_value = Log_Constants.settings.LOGGING_LEVEL.value,
    allowed_values = Log_Constants_Functions.levels.get_names()
}

data:extend({
    LOGGING_LEVEL,
    Log_Constants.settings.DO_TRACEBACK,
    Log_Constants.settings.DO_TRACEBACK,
    Log_Constants.settings.DO_NOT_PRINT,
})
local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")

data:extend({
  {
    type = "string-setting",
    name = Log_Constants.settings.DEBUG_LEVEL.name,
    setting_type = "runtime-global",
    order = "aba",
    default_value = Log_Constants.settings.DEBUG_LEVEL.value,
    allowed_values = Log_Constants_Functions.levels.get_names()
  },
  Log_Constants.settings.DO_TRACEBACK,
  Log_Constants.settings.DO_NOT_PRINT,
})
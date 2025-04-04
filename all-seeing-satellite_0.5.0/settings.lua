require("libs.log.log-settings")
local Settings_Constants = require("libs.constants.settings-constants")

data:extend({
  {
    type = "bool-setting",
    name = Settings_Constants.REQUIRE_SATELLITES_IN_ORBIT.name,
    setting_type = "runtime-global",
    order = "aaa",
    default_value = Settings_Constants.REQUIRE_SATELLITES_IN_ORBIT.value,
  },
  {
    type = "int-setting",
    name = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name,
    setting_type = "runtime-global",
    order = "bbb",
    default_value = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value,
    maximum_value = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.max,
    minimum_value = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.min,
  },
  {
    type = "int-setting",
    name = Settings_Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name,
    setting_type = "runtime-global",
    order = "ccc",
    default_value = Settings_Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value,
    -- maximum_value = 100,
    minimum_value = Settings_Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.min,
  },
})
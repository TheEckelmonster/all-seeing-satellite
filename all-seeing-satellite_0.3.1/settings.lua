local Constants = require("libs.constants")

data:extend({
  {
    type = "bool-setting",
    name = Constants.REQUIRE_SATELLITES_IN_ORBIT.name,
    setting_type = "runtime-global",
    order = "aaa",
    default_value = Constants.REQUIRE_SATELLITES_IN_ORBIT.value,
  },
  {
    type = "int-setting",
    name = Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name,
    setting_type = "runtime-global",
    order = "bbb",
    default_value = Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value,
    maximum_value = Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.max,
    minimum_value = Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.min,
  },
  {
    type = "int-setting",
    name = Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name,
    setting_type = "runtime-global",
    order = "ccc",
    default_value = Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value,
    -- maximum_value = 100,
    minimum_value = Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.min,
  },
})
local Constants = require("libs.constants")

data:extend({
  {
    type = "bool-setting",
    name = Constants.REQUIRE_SATELLITES_IN_ORBIT.name,
    setting_type = "runtime-global",
    default_value = true,
  },
  {
    type = "int-setting",
    name = Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name,
    setting_type = "runtime-global",
    default_value = 1,
    maximum_value = 100,
    minimum_value = 0,
  },
})
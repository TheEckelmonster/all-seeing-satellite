require("libs.log.log-settings")
local Settings_Constants = require("libs.constants.settings-constants")

data:extend({
  Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT,
  Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD,
  Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE,
})
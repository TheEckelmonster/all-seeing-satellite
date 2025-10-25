local Settings_Constants = require("libs.constants.settings-constants")

data:extend({
    Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE,
    Settings_Constants.settings.DO_LAUNCH_ROCKETS,
    Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD,
    Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER,
    Settings_Constants.settings.NTH_TICK.setting,
    Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT,
    Settings_Constants.settings.RESTRICT_SATELLITE_MODE,
    Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING,
    Settings_Constants.settings.SATELLITE_BASE_QUALITY_FACTOR,
    Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION,
    Settings_Constants.settings.SATELLITE_SCAN_MODE,
})
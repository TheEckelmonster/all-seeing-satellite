-- If already defined, return
if _settings_constants and _settings_constants.all_seeing_satellite then
  return _settings_constants
end

local settings_constants = {}

settings_constants.hotkeys = {}

settings_constants.HOTKEY_EVENT_NAME = {}
settings_constants.HOTKEY_EVENT_NAME.value = "N"
settings_constants.HOTKEY_EVENT_NAME.name = "all-seeing-satellite-toggle"

settings_constants.hotkeys.SCAN_SELECTED_CHUNK = {}
settings_constants.hotkeys.SCAN_SELECTED_CHUNK.value = "M"
settings_constants.hotkeys.SCAN_SELECTED_CHUNK.name = "all-seeing-satellite-scan-selected-chunk"

settings_constants.REQUIRE_SATELLITES_IN_ORBIT = {}
settings_constants.REQUIRE_SATELLITES_IN_ORBIT.value = true
settings_constants.REQUIRE_SATELLITES_IN_ORBIT.name = "all-see-satellite-require-satellites-in-orbit"

settings_constants.DEBUG_LEVEL = {}
settings_constants.DEBUG_LEVEL.value = "None"
settings_constants.DEBUG_LEVEL.name = "all-seeing-satellite-debug-level"

settings_constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD = {}
settings_constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value = 3
settings_constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.max = 100
settings_constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.min = 0
settings_constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name = "all-seeing-satellite-global-launch-satellite-threshold"

settings_constants.DEFAULT_SATELLITE_TIME_TO_LIVE = {}
settings_constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value = 20
-- settings_constants.DEFAULT_SATELLITE_TIME_TO_LIVE.max = -- What should be the maximum, if any?
settings_constants.DEFAULT_SATELLITE_TIME_TO_LIVE.min = 1
settings_constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name = "all-seeing-satellite-default-satellite-time-to-live"

settings_constants.all_seeing_satellite = true

local _settings_constants = settings_constants

return settings_constants
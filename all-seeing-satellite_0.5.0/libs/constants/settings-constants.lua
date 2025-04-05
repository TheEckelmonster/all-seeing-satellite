-- If already defined, return
if _settings_constants and _settings_constants.all_seeing_satellite then
  return _settings_constants
end

local settings_constants = {}

settings_constants.settings = {}

settings_constants.hotkeys = {}

settings_constants.HOTKEY_EVENT_NAME = {}
settings_constants.HOTKEY_EVENT_NAME.value = "N"
settings_constants.HOTKEY_EVENT_NAME.name = "all-seeing-satellite-toggle"

settings_constants.hotkeys.SCAN_SELECTED_CHUNK = {}
settings_constants.hotkeys.SCAN_SELECTED_CHUNK.value = "M"
settings_constants.hotkeys.SCAN_SELECTED_CHUNK.name = "all-seeing-satellite-scan-selected-chunk"

settings_constants.DEBUG_LEVEL = {}
settings_constants.DEBUG_LEVEL.value = "None"
settings_constants.DEBUG_LEVEL.name = "all-seeing-satellite-debug-level"

settings_constants.settings.REQUIRE_SATELLITES_IN_ORBIT = {
  type = "bool-setting",
  name = "all-see-satellite-require-satellites-in-orbit",
  setting_type = "runtime-global",
  order = "aaa",
  default_value = true,
}

settings_constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD = {
  type = "int-setting",
  name = "all-seeing-satellite-global-launch-satellite-threshold",
  setting_type = "runtime-global",
  order = "bbb",
  default_value = 3,
  maximum_value = 111,
  minimum_value = 0,
}

settings_constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE = {
  type = "double-setting",
  name = "all-seeing-satellite-default-satellite-time-to-live",
  setting_type = "runtime-global",
  order = "ccc",
  default_value = 20,
  -- maximum_value = 111,  -- What should be the maximum, if any?
  minimum_value = 0,
}

settings_constants.settings.NTH_TICK = {}
settings_constants.settings.NTH_TICK.value = 1
settings_constants.settings.NTH_TICK.setting = {
  type = "int-setting",
  name = "all-seeing-satellite-nth-tick",
  setting_type = "runtime-global",
  order = "edd",
  default_value = settings_constants.settings.NTH_TICK.value,
  maximum_value = 111,
  minimum_value = 0,
}

settings_constants.all_seeing_satellite = true

local _settings_constants = settings_constants

return settings_constants
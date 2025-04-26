-- If already defined, return
if _settings_service and _settings_service.all_seeing_satellite then
  return _settings_service
end

local Log = require("libs.log.log")
local Settings_Constants = require("libs.constants.settings-constants")

local settings_service = {}

-- NTH_TICK
function settings_service.get_nth_tick()
  local setting = Settings_Constants.settings.NTH_TICK.setting.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.NTH_TICK.setting.name]) then
    setting = settings.global[Settings_Constants.settings.NTH_TICK.setting.name].value
  end

  return setting
end

-- REQUIRE_SATELLITES_IN_ORBIT
function settings_service.get_require_satellites_in_orbit()
  local setting = Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.name]) then
    setting = settings.global[Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.name].value
  end

  return setting
end

-- DEFAULT_SATELLITE_TIME_TO_LIVE
function settings_service.get_default_satellite_time_to_live()
  local setting = Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name]) then
    setting = settings.global[Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name].value
  end

  return setting
end

-- GLOBAL_LAUNCH_SATELLITE_THRESHOLD
function settings_service.get_global_launch_satellite_threshold(surface_name)
  local setting = Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.default_value

  if (settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"]) then
    setting = settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"].value
  elseif (settings.global[Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name]) then
    setting = settings.global[Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name].value
  end

  return setting
end

-- GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER
function settings_service.get_global_launch_satellite_threshold_modifier(surface_name)
  local setting = Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.default_value

  if (settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold-modifier"]) then
    setting = settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold-modifier"].value
  elseif (settings.global[Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.name]) then
    setting = settings.global[Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.name].value
  end

  return setting
end

-- SATELLITE_SCAN_MODE
function settings_service.get_satellite_scan_mode()
  local setting = Settings_Constants.settings.SATELLITE_SCAN_MODE.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.SATELLITE_SCAN_MODE.name]) then
    setting = settings.global[Settings_Constants.settings.SATELLITE_SCAN_MODE.name].value
  end

  return setting
end

-- RESTRICT_SATELLITE_SCANNING
function settings_service.get_restrict_satellite_scanning()
  local setting = Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name]) then
    setting = settings.global[Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name].value
  end

  return setting
end

-- RESTRICT_SATELLITE_MODE
function settings_service.get_restrict_satellite_mode()
  local setting = Settings_Constants.settings.RESTRICT_SATELLITE_MODE.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name]) then
    setting = settings.global[Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name].value
  end

  return setting
end

-- DO_LAUNCH_ROCKETS
function settings_service.get_do_launch_rockets()
  local setting = Settings_Constants.settings.DO_LAUNCH_ROCKETS.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.DO_LAUNCH_ROCKETS.name]) then
    setting = settings.global[Settings_Constants.settings.DO_LAUNCH_ROCKETS.name].value
  end

  return setting
end

-- SATELLITE_SCAN_COOLDOWN_DURATION
function settings_service.get_satellite_scan_cooldown_duration()
  local setting = Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION.default_value

  if (settings and settings.global and settings.global[Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION.name]) then
    setting = settings.global[Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION.name].value
  end

  return setting
end

function settings_service.mod_setting_changed(event)
  Log.info(event)
  if (event and event.setting) then
    if (event.setting == Settings_Constants.DEBUG_LEVEL.name) then
      invoke(event, Log.get_log_level)
    end
  end
end

function invoke(event, fun)
  Log.debug("Mod settings changed")
  Log.info(event)
  fun(event)
end

settings_service.all_seeing_satellite = true

local _settings_service = settings_service

return settings_service
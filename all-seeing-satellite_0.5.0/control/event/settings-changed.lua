-- If already defined, return
if _settings_changed and _settings_changed.all_seeing_satellite then
  return _settings_changed
end

local Log = require("libs.log")
local Log_Constants = require("libs.constants.log-constants")
local Settings_Constants = require("libs.constants.settings-constants")
local Satellite = require("control.event.satellite")

local settings_changed = {}

function settings_changed.mod_setting_changed(event)
  if (event and event.setting) then
    if (event.setting == Settings_Constants.DEBUG_LEVEL.name) then
      invoke(event, Log.get_log_level)
    elseif (event.setting == Settings_Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name) then
      invoke(event, function (event) Satellite.recalculate_satellite_time_to_die(event.tick) end)
    end
  end
end

function invoke(event, fun)
  Log.debug("Mod settings changed")
  Log.info(event)
  fun(event)
end

settings_changed.all_seeing_satellite = true

local _settings_changed = settings_changed

return settings_changed
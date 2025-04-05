-- If already defined, return
if _settings_service and _settings_service.all_seeing_satellite then
  return _settings_service
end

local Log = require("libs.log.log")
local Log_Constants = require("libs.constants.log-constants")
local Settings_Constants = require("libs.constants.settings-constants")
local Satellite_Controller = require("control.controllers.satellite-controller")

local settings_service = {}

function settings_service.mod_setting_changed(event)
  Log.info(event)
  if (event and event.setting) then
    if (event.setting == Settings_Constants.DEBUG_LEVEL.name) then
      invoke(event, Log.get_log_level)
    elseif (event.setting == Settings_Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name) then
      invoke(event, function (event) Satellite_Controller.recalculate_satellite_time_to_die(event) end)
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
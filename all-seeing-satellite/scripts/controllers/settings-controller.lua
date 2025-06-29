-- If already defined, return
if _settings_controller and _settings_controller.all_seeing_satellite then
  return _settings_controller
end

local Log = require("libs.log.log")
local Satellite_Service = require("scripts.services.satellite-service")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("scripts.services.settings-service")

local settings_controller = {}

function settings_controller.mod_setting_changed(event)
  Log.debug("settings_controller.mod_setting_changed")
  Log.info(event)
  if (event and event.setting) then
    if (event.setting == Settings_Constants.DEBUG_LEVEL.name) then
      Settings_Service.mod_setting_changed(event)
    elseif (event.setting == Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name) then
      Satellite_Service.recalculate_satellite_time_to_die(event.tick)
    end
  end
end

settings_controller.all_seeing_satellite = true

local _settings_controller = settings_controller

return settings_controller
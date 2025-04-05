-- If already defined, return
if _settings_controller and _settings_controller.all_seeing_satellite then
  return _settings_controller
end

local Log = require("libs.log.log")
local Settings_Service = require("control.services.settings-service")

local settings_controller = {}

settings_controller.all_seeing_satellite = true

function settings_controller.mod_setting_changed(event)
  Log.info(event)
  Settings_Service.mod_setting_changed(event)
end

local _settings_controller = settings_controller

return settings_controller
-- If already defined, return
if _settings_service and _settings_service.all_seeing_satellite then
  return _settings_service
end

local Log = require("libs.log.log")
local Storage_Service = require("control.services.storage-service")

local settings_service = {}


settings_service.all_seeing_satellite = true

local _settings_service = settings_service

return settings_service
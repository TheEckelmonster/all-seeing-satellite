-- If already defined, return
if _settings_changed and _settings_changed.all_seeing_satellite then
  return _settings_changed
end

local Satellite = require("control.event.satellite")

local settings_changed = {}

function settings_changed.mod_setting_changed(event)
  Satellite.recalculate_satellite_time_to_die(event.tick)
end

settings_changed.all_seeing_satellite = true

local _settings_changed = settings_changed

return settings_changed
-- If already defined, return
if _all_seeing_satellite_controller and _all_seeing_satellite_controller.all_seeing_satellite then
  return _all_seeing_satellite_controller
end

local Log = require("libs.log.log")
local Satellite_Service = require("control.services.satellite-service")
local Scan_Chunk_Service = require("control.services.scan-chunk-service")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")

local all_seeing_satellite_controller = {}

function all_seeing_satellite_controller.do_tick(event)
  local tick = event.tick
  local nth_tick = Settings_Service.get_nth_tick()
  -- local nth_tick = Settings_Constants.settings.NTH_TICK.value

  -- if (settings and settings.global and settings.global[Settings_Constants.settings.NTH_TICK.setting.name]) then
  --   nth_tick = settings.global[Settings_Constants.settings.NTH_TICK.setting.name].value
  -- end

  local offset = 1 + nth_tick
  local tick_modulo = tick % offset

  if (nth_tick ~= tick_modulo) then return end

  -- Check/validate the storage version
  -- if (not Version_Validations.validate_version()) then return end

  local return_val = Storage_Service.get_area_to_chart()
  if (not return_val or not return_val.obj or not return_val.valid) then return end
  local area_to_chart = return_val.obj
  Scan_Chunk_Service.scan_selected_chunk(area_to_chart)
  Storage_Service.remove_area_to_chart_from_stage("stack")
end

all_seeing_satellite_controller.all_seeing_satellite = true

local _all_seeing_satellite_controller = all_seeing_satellite_controller

return all_seeing_satellite_controller
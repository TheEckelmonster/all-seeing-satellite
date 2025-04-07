-- If already defined, return
if _all_seeing_satellite_controller and _all_seeing_satellite_controller.all_seeing_satellite then
  return _all_seeing_satellite_controller
end

local All_Seeing_Satellite_Service = require("control.services.all-seeing-satellite-service")
local Log = require("libs.log.log")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")

local all_seeing_satellite_controller = {}

function all_seeing_satellite_controller.do_tick(event)
  local tick = event.tick
  local nth_tick = Settings_Service.get_nth_tick()
  local offset = 1 + nth_tick
  local tick_modulo = tick % offset

  -- Check/validate the storage version
  -- if (not Version_Validations.validate_version()) then return end

  if (nth_tick ~= tick_modulo) then return end

  if (not Storage_Service.get_scan_in_progress()) then
    All_Seeing_Satellite_Service.check_for_areas_to_stage()
  else

  end
  All_Seeing_Satellite_Service.do_scan()
end

all_seeing_satellite_controller.all_seeing_satellite = true

local _all_seeing_satellite_controller = all_seeing_satellite_controller

return all_seeing_satellite_controller
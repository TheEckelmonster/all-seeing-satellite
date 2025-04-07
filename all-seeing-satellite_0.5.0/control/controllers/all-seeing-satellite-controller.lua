-- If already defined, return
if _all_seeing_satellite_controller and _all_seeing_satellite_controller.all_seeing_satellite then
  return _all_seeing_satellite_controller
end

local All_Seeing_Satellite_Service = require("control.services.all-seeing-satellite-service")
local Log = require("libs.log.log")
local Fog_Of_War_Service = require("control.services.fog-of-war-service")
local Rocket_Silo_Service = require("control.services.rocket-silo-service")
local Satellite_Service = require("control.services.satellite-service")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")

local all_seeing_satellite_controller = {}

function all_seeing_satellite_controller.do_tick(event)
  if (not Storage_Service.get_do_nth_tick()) then return end

  local tick = event.tick
  local nth_tick = Settings_Service.get_nth_tick()
  local offset = 1 + nth_tick
  local tick_modulo = tick % offset

  -- Check/validate the storage version
  -- if (not Version_Validations.validate_version()) then return end
  if (tick_modulo == 0) then
    Fog_Of_War_Service.toggle_FoW()
  end

  if (tick_modulo == 7) then
    Satellite_Service.check_for_expired_satellites({ tick = game.tick })
  end

  if (tick_modulo == 14) then
    Rocket_Silo_Service.launch_rocket({ tick = game.tick })
  end

  -- if (nth_tick ~= tick_modulo) then return end

  if (tick_modulo % 2 == 0 and Storage_Service.get_do_scan()) then
    All_Seeing_Satellite_Service.check_for_areas_to_stage()
    All_Seeing_Satellite_Service.do_scan()
  end
end

all_seeing_satellite_controller.all_seeing_satellite = true

local _all_seeing_satellite_controller = all_seeing_satellite_controller

return all_seeing_satellite_controller
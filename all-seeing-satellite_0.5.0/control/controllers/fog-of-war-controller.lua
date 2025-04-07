-- If already defined, return
if _fog_of_war_controllerr and _fog_of_war_controllerr.all_seeing_satellite then
  return _fog_of_war_controllerr
end

local Log = require("libs.log.log")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Storage_Service = require("control.services.storage-service")

local fog_of_war_controller = {}

function fog_of_war_controller.toggle_scanning(event)
  Log.debug("fog_of_war_controller.toggle_scanning")
  -- Validate inputs
  if (not event) then return end
  if (event.input_name ~= Custom_Input_Constants.TOGGLE_SCANNING.name) then return end
  if (not event.player_index) then return end
  if (not game or not game.players or not game.players[event.player_index] or not game.players[event.player_index].force) then return end
  if (Storage_Service.get_do_scan()) then
    game.players[event.player_index].force.print("Toggling scan(s) off")
    Log.warn("toggling scan(s) off")
    Storage_Service.set_do_scan(false)
  else
    game.players[event.player_index].force.print("Toggling scan(s) on")
    Log.warn("toggling scan(s) on")
    Storage_Service.set_do_scan(true)
  end
end

function fog_of_war_controller.cancel_scanning(event)
  Log.debug("fog_of_war_controller.cancel_scanning")
    -- Validate inputs
  if (not event) then return end
  if (event.input_name ~= Custom_Input_Constants.CANCEL_SCANNING.name) then return end
  if (not event.player_index) then return end
  if (not game or not game.players or not game.players[event.player_index] or not game.players[event.player_index].force) then return end
  game.players[event.player_index].force.print("Cancelling scan(s)")
  Log.warn("cancelling scan(s)")
  Storage_Service.clear_stages()
end

fog_of_war_controller.all_seeing_satellite = true

local _fog_of_war_controllerr = fog_of_war_controller

return fog_of_war_controller
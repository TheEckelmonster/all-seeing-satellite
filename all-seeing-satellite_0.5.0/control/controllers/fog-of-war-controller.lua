-- If already defined, return
if _fog_of_war_controllerr and _fog_of_war_controllerr.all_seeing_satellite then
  return _fog_of_war_controllerr
end

local Log = require("libs.log.log")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Planet_Utils = require("control.utils.planet-utils")
local Fog_Of_War_Utils = require("control.utils.fog-of-war-utils")
local Research_Utils = require("control.utils.research-utils")
local String_Utils = require("control.utils.string-utils")
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
  game.players[event.player_index].force.cancel_charting()
  Log.warn("cancelling scan(s)")
  Storage_Service.clear_stages()
end

function fog_of_war_controller.toggle(event)
  Log.debug("fog_of_war_controller.toggle")
  -- Validate inputs
  if (event.input_name ~= Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name and event.prototype_name ~= Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name) then
    return
  end

  local player = game.players[event.player_index]
  local satellites_toggled = storage.satellites_toggled

  if (player and player.surface and player.surface.name) then
    local surface_name = player.surface.name

    if (  not Planet_Utils.allow_toggle(surface_name)
      and not Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
      if (not storage.warn_technology_not_available_yet and player.force) then
        player.force.print("Rocket Silo/Satellite not researched yet")
      end
      storage.warn_technology_not_available_yet = true
      return
    end

    storage.satellite_toggled_by_player = player

    if (String_Utils.find_invalid_substrings(surface_name)) then
      Log.debug("Invalid surface!")
      Log.debug(surface_name)
      Log.debug("Toggled by player:")
      Log.debug(player)
      return
    end

    local satellite
    for k,_satellite in pairs(satellites_toggled) do
      if (_satellite and _satellite.planet_name == surface_name) then
        satellite = _satellite
        break
      end
    end

    if (satellite) then
      if (satellite.toggle) then
        if (Planet_Utils.allow_toggle(surface_name)) then
          Fog_Of_War_Utils.print_toggle_message("Disabled satellite(s) orbiting ", surface_name, true)
        else
          Fog_Of_War_Utils.print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
        end
        satellite.toggle = false
      elseif (not satellite.toggle) then
        if (Planet_Utils.allow_toggle(surface_name)) then
          Fog_Of_War_Utils.print_toggle_message("Enabled satellite(s) orbiting ", surface_name, true)
          satellite.toggle = true
        else
          Fog_Of_War_Utils.print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
          -- This shouldn't be necessary, but oh well
          satellite.toggle = false
        end
      else
        Log.error("This shouldn't be possible")
      end
    else
      Log.error("satetllite was nil")
      Log.error("Reinitializing")
      Log.debug(surface_name)
      Initialization.reinit()
    end
  end
end

fog_of_war_controller.all_seeing_satellite = true

local _fog_of_war_controllerr = fog_of_war_controller

return fog_of_war_controller
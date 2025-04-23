-- If already defined, return
if _fog_of_war_controllerr and _fog_of_war_controllerr.all_seeing_satellite then
  return _fog_of_war_controllerr
end

local All_Seeing_Satellite_Repository = require("control.repositories.all-seeing-satellite-repository")
local Log = require("libs.log.log")
local Constants = require("libs.constants.constants")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Fog_Of_War_Utils = require("control.utils.fog-of-war-utils")
local Initialization = require("control.initialization")
local Planet_Utils = require("control.utils.planet-utils")
local Research_Utils = require("control.utils.research-utils")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local String_Utils = require("control.utils.string-utils")

local fog_of_war_controller = {}

function fog_of_war_controller.toggle_scanning(event)
  Log.debug("fog_of_war_controller.toggle_scanning")
  Log.info(event)

  -- Validate inputs
  if (not event) then return end
  if (event.input_name ~= Custom_Input_Constants.TOGGLE_SCANNING.name) then return end
  if (not event.player_index) then return end
  if (not game or not game.players or not game.players[event.player_index] or not game.players[event.player_index].force) then return end

  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.valid) then return end

  if (all_seeing_satellite_data.do_scan) then
    -- game.players[event.player_index].force.print("Toggling scan(s) off")
    game.get_player(event.player_index).force.print("Toggling scan(s) off")
    Log.warn("toggling scan(s) off")
    all_seeing_satellite_data.do_scan = false
  else
    -- game.players[event.player_index].force.print("Toggling scan(s) on")
    game.get_player(event.player_index).force.print("Toggling scan(s) on")
    Log.warn("toggling scan(s) on")
    all_seeing_satellite_data.do_scan = true
  end
  all_seeing_satellite_data.updated = game.tick
end

function fog_of_war_controller.cancel_scanning(event)
  Log.debug("fog_of_war_controller.cancel_scanning")
  Log.info(event)

  -- Validate inputs
  if (not event) then return end
  if (event.input_name ~= Custom_Input_Constants.CANCEL_SCANNING.name) then return end
  if (not event.player_index) then return end
  if (not game or not game.players or not game.players[event.player_index] or not game.players[event.player_index].force) then return end
  -- game.players[event.player_index].force.print("Cancelling scan(s)")
  -- game.players[event.player_index].force.cancel_charting()
  game.get_player(event.player_index).force.print("Cancelling scan(s)")
  game.get_player(event.player_index).force.cancel_charting()
  Log.warn("cancelling scan(s)")

  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.valid) then return end

  all_seeing_satellite_data.staged_areas_to_chart = {}
  all_seeing_satellite_data.staged_chunks_to_chart = {}
  all_seeing_satellite_data.updated = game.tick
end

function fog_of_war_controller.toggle(event)
  Log.debug("fog_of_war_controller.toggle")
  Log.info(event)

  if (not event) then return end
  local name = event.input_name or event.prototype_name

  if (name ~= Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name) then return end

  local player = game.get_player(event.player_index)
  if (not player or not player.valid) then return end
  if (not player.surface or not player.surface.valid) then return end

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(player.surface.name)
  if (not satellite_meta_data.valid) then return end

  local satellites_toggled = satellite_meta_data.satellites_toggled

  if (player and player.surface and player.surface.name) then
    local surface_name = player.surface.name

    if (  not Planet_Utils.allow_toggle(surface_name)
      and not Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name))
    then
      player.print("Rocket Silo/Satellite not researched yet")
      -- all_seeing_satellite_data.warn_technology_not_available_yet = true
      return
    end

    Satellite_Meta_Repository.update_satellite_meta_data({
      planet_name = satellite_meta_data.planet_name,
      satellite_toggled_by_player = player,
    })

    if (String_Utils.find_invalid_substrings(surface_name)) then
      Log.debug("Invalid surface name!")
      Log.debug(surface_name)
      Log.debug("Toggled by player:")
      Log.debug(player)

      player.print("Invalid surface name detected: " .. surface_name)
      return
    end

    if (satellites_toggled.toggle) then
      if (Planet_Utils.allow_toggle(surface_name)) then
        Fog_Of_War_Utils.print_toggle_message("Disabled satellite(s) orbiting ", surface_name, true)
        player.force.cancel_charting(surface_name)
      else
        Fog_Of_War_Utils.print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
      end
      satellites_toggled.toggle = false
    elseif (not satellites_toggled.toggle) then
      if (Planet_Utils.allow_toggle(surface_name)) then
        Fog_Of_War_Utils.print_toggle_message("Enabled satellite(s) orbiting ", surface_name, true)
        satellites_toggled.toggle = true
      else
        Fog_Of_War_Utils.print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
        -- This shouldn't be necessary, but oh well
        satellites_toggled.toggle = false
      end
    else
      Log.error("This shouldn't be possible")
    end
  end
end

fog_of_war_controller.all_seeing_satellite = true

local _fog_of_war_controllerr = fog_of_war_controller

return fog_of_war_controller
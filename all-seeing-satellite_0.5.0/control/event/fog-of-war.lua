-- If already defined, return
if _fog_of_war and _fog_of_war.all_seeing_satellite then
  return _fog_of_war
end

local Constants = require("libs.constants.constants")
local Initialization = require("control.initialization")
local Log = require("libs.log.log")
local Settings_Constants = require("libs.constants.settings-constants")
local String_Utils = require("control.utils.string-utils")
local Planet_Utils = require("control.utils.planet-utils")
local Validations = require("control.validations.validations")

local Research = require("control.event.research")

local fog_of_war = {}

function fog_of_war.toggle_FoW(event)
  local player = storage.satellite_toggled_by_player

  if (Validations.is_storage_valid()) then
    for k, satellite in pairs(storage.satellites_toggled) do
      -- If inputs are valid, and the surface the player is currently viewing is toggled
      if (  satellite
        and satellite.toggle
        and player
        and player.force
        and player.surface
        and player.surface.name == satellite.planet_name)
      then
        if (Planet_Utils.allow_toggle(satellite.planet_name)) then
          game.forces[player.force.index].rechart(player.surface)
          return
        end
      end
    end
  end
end

function fog_of_war.toggle(event)
  -- Validate inputs
  if (event.input_name ~= Settings_Constants.HOTKEY_EVENT_NAME.name and event.prototype_name ~= Settings_Constants.HOTKEY_EVENT_NAME.name) then
    return
  end

  local player = game.players[event.player_index]
  local satellites_toggled = storage.satellites_toggled

  if (player and player.surface and player.surface.name) then
    local surface_name = player.surface.name

    if (  not Planet_Utils.allow_toggle(surface_name)
      and not Research.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
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
          print_toggle_message("Disabled satellite(s) orbiting ", surface_name, true)
        else
          print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
        end
        satellite.toggle = false
      elseif (not satellite.toggle) then
        if (Planet_Utils.allow_toggle(surface_name)) then
          print_toggle_message("Enabled satellite(s) orbiting ", surface_name, true)
          satellite.toggle = true
        else
          print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
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

function print_toggle_message(message, surface_name, add_count)
  if (Validations.is_storage_valid() and storage.satellites_launched and storage.satellites_launched[surface_name]) then
    if (add_count) then
      game.print(message
              .. surface_name
              .. " : "
              .. storage.satellites_launched[surface_name]
              ..  " orbiting, "
              .. serpent.block(Planet_Utils.planet_launch_threshold(surface_name))
              .. " minimum"
            )
    else
      game.print(message .. surface_name .. " : " .. storage.satellites_launched[surface_name])
    end
  else
    game.print(message .. surface_name)
  end
end

fog_of_war.all_seeing_satellite = true

local _fog_of_war = fog_of_war

return fog_of_war
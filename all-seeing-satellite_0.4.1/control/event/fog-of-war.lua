-- If already defined, return
if _fog_of_war and _fog_of_war.all_seeing_satellite then
  return _fog_of_war
end

local Constants = require("libs.constants.constants")
local Initialization = require("control.initialization")
local Log = require("libs.log")
local Settings_Constants = require("libs.constants.settings-constants")
local String_Utils = require("libs.utils.string-utils")
local Validations = require("libs.validations")

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
        if (allow_toggle(satellite.planet_name)) then
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

    if (  not allow_toggle(surface_name)
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
      Log.debug(plaer)
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
        if (allow_toggle(surface_name)) then
          print_toggle_message("Disabled satellite(s) orbiting ", surface_name, true)
        else
          print_toggle_message("Insufficient satellite(s) orbiting ", surface_name, true)
        end
        satellite.toggle = false
      elseif (not satellite.toggle) then
        if (allow_toggle(surface_name)) then
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
              .. serpent.block(planet_launch_threshold(surface_name))
              .. " minimum"
            )
    else
      game.print(message .. surface_name .. " : " .. storage.satellites_launched[surface_name])
    end
  else
    game.print(message .. surface_name)
  end
end

function allow_toggle(surface_name)
  if (not settings.global[Settings_Constants.REQUIRE_SATELLITES_IN_ORBIT.name].value) then
    return true
  end

  if (surface_name) then
    return  Validations.is_storage_valid()
        and storage.satellites_launched
        and storage.satellites_launched[surface_name]
        and (
          storage.satellites_launched[surface_name] >= planet_launch_threshold(surface_name))
  end
  return false
end

function planet_launch_threshold(surface_name)
  if (not surface_name) then
    return Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value
  end

  local planet_multiplier = get_planet_multiplier(surface_name)
  local return_val = get_settings_val(surface_name) * planet_multiplier * planet_multiplier

  if (get_planet_multiplier(surface_name) < 1) then
    Log.debug("floor")
    return_val = math.floor(return_val)
  else
    Log.debug("ceil")
    return_val = math.ceil(return_val)
  end

  return return_val
end

function get_planet_multiplier(surface_name)
  local planets = Constants.get_planets()
  local planet_multiplier = 1

  if (planets) then
    for _, planet in ipairs(planets) do
      if (planet and planet.name == surface_name) then
        planet_multiplier = planet.magnitude
        break
      end
    end
  end

  Log.info(planet_multiplier)

  if (not planet_multiplier) then
    planet_multiplier = 1
  end

  return planet_multiplier
end

function get_settings_val(surface_name)
  local settings_val = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value

  if (settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"]) then
    settings_val = settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"].value
  elseif (settings.global[Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name]) then
    settings_val = settings.global[Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name].value
  end
  if (not settings_val) then
    settings_val = Settings_Constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value
  end

  return settings_val
end

fog_of_war.all_seeing_satellite = true

local _fog_of_war = fog_of_war

return fog_of_war
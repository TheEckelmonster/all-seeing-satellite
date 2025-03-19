-- If already defined, return
if _fog_of_war and _fog_of_war.all_seeing_satellite then
  return _fog_of_war
end

local Constants = require("libs.constants")
local String_Utils = require("libs.utils.string-utils")
local Validations = require("libs.validations")

local fog_of_war = {}

function fog_of_war.toggle_FoW(event)
  local player = storage.satellite_toggled_by_player

  if (Validations.is_storage_valid()) then
    for surface_name, enabled in pairs(storage.satellites_toggled) do
      -- If inputs are valid, and the surface the player is currently viewing is toggled
      if (  enabled
      and player
      and player.force
      and player.surface
      and player.surface.name == surface_name)
      then
        if (allow_toggle(surface_name)) then
          game.forces[player.force.index].rechart(player.surface)
        end
      end
    end
  end
end

function fog_of_war.toggle(event)
  -- Validate inputs
  if (event.input_name ~= Constants.HOTKEY_EVENT_NAME.setting and event.prototype_name ~= Constants.HOTKEY_EVENT_NAME.setting) then
    return
  end

  local player_from_storage = storage.player
  local player = game.players[event.player_index]
  local satellites_toggled = storage.satellites_toggled

  if (player and player.surface and player.surface.name) then
    storage.satellite_toggled_by_player = player

    local surface_name = player.surface.name

    if (String_Utils.find_invalid_substrings(surface_name)) then
      -- game.print("Invalid surface")
      return
    end

    if (satellites_toggled[surface_name]) then
      if (allow_toggle(surface_name)) then
        print_toggle_message("Disabled satellite(s) orbiting ", surface_name)
      else
        print_toggle_message("Insufficient satellite(s) orbiting ", surface_name)
      end
      satellites_toggled[surface_name] = false
    elseif (not satellites_toggled[surface_name]) then
      if (allow_toggle(surface_name)) then
        print_toggle_message("Enabled satellite(s) orbiting ", surface_name)
        satellites_toggled[surface_name] = true
      else
        print_toggle_message("Insufficient satellite(s) orbiting ", surface_name)
        -- This shouldn't be necessary, but oh well
        satellites_toggled[surface_name] = false
      end
    else
      log("This shouldn't be possible")
      game.print("all-seeing-satellite: This shouldn't be possible")
    end
  end
end

function print_toggle_message(message, surface_name)
  if (Validations.is_storage_valid() and storage.satellites_launched and storage.satellites_launched[surface_name]) then
    game.print(message .. surface_name .. " : " .. storage.satellites_launched[surface_name])
  else
    game.print(message .. surface_name)
  end
end

function allow_toggle(surface_name)
  if (not settings.global[Constants.REQUIRE_SATELLITES_IN_ORBIT.name].value) then
    return true
  end

  if (surface_name) then
    return  Validations.is_storage_valid()
        and storage.satellites_launched
        and storage.satellites_launched[surface_name]
        and (
              ( settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"]
            and storage.satellites_launched[surface_name] >= settings.global["all-seeing-satellite-" .. surface_name .. "-satellite-threshold"].value)
          or
              ( settings.global["all-seeing-satellite-global-launch-satellite-threshold"]
            and storage.satellites_launched[surface_name] >= settings.global["all-seeing-satellite-global-launch-satellite-threshold"].value)
        )
  end
  return false
end

fog_of_war.all_seeing_satellite = true

local _fog_of_war = fog_of_war

return fog_of_war
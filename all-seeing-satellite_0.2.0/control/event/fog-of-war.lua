-- If already defined, return
if _fog_of_war and _fog_of_war.all_seeing_satellite then
  return _fog_of_war
end

local fog_of_war = {}

function fog_of_war.toggle_FoW(event)
  local player = storage.satellite_toggled_by_player

  for k, v in pairs(storage.satellites_toggled) do
    -- If inputs are valid, and the surface the player is currently viewing is toggled
    if (v and player and player.force and player.surface.name == k) then
      game.forces[player.force.index].rechart(player.surface)
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

    if (satellites_toggled[surface_name]) then
      game.print("Disabled satellites(s) for " .. surface_name)
      satellites_toggled[surface_name] = false
    elseif (not satellites_toggled[surface_name]) then
      game.print("Enabled satellite(s) for " .. surface_name)
      satellites_toggled[surface_name] = true
    else
      game.print("all-seeing-satellite: This shouldn't be possible")
    end
  end
end

fog_of_war.all_seeing_satellite = true

local _fog_of_war = fog_of_war

return fog_of_war
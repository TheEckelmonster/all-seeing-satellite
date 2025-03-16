local Constants = require("libs.constants")

local nthTick = settings.startup[Constants.ON_NTH_TICK.setting]
-- local nthTick = settings.global[Constants.ON_NTH_TICK.setting]
local disableFoW = false

if (not nthTick or nthTick.value <= 0) then
  nthTick = Constants.ON_NTH_TICK.value
end

function init()
  storage.satellites_launched = {
    nauvis = 0,
    fulgora = 0,
    gleba = 0,
    vulcanus = 0,
    aquilo = 0
  }

  storage.satellite_toggled_by_player = nil

  -- storage._satellites_toggled = {}
  -- for k,v in pairs(game.surfaces) do
  --   table.insert(storage._satellites_toggled, {
  --     surface = v,
  --     toggled = false
  --   })
  -- end

  -- log(serpent.block(_satellites_toggled))

  storage.satellites_toggled = {
    nauvis = false,
    fulgora = false,
    gleba = false,
    vulcanus = false,
    aquilo = false
  }

  -- game.print("satellites_launched: " .. serpent.block(storage.satellites_launched))
  -- game.print("satellites_toggled: " .. serpent.block(storage.satellites_toggled))
end

function toggleFoW(event)
  local player = storage.satellite_toggled_by_player

  for k, v in pairs(storage.satellites_toggled) do
    -- If inputs are valid, and the surface the player is currently viewing is toggled
    if (v and player and player.force and player.surface.name == k) then
      game.forces[player.force.index].rechart(player.surface)
    end
  end

end

function toggle(event)
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

-- Regist events
script.on_init(init)
script.on_nth_tick(nthTick, toggleFoW)
script.on_event("all-seeing-satellite-toggle", toggle)
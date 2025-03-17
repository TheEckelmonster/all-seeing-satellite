local Constants = require("libs.constants")
local String_Utils = require("libs.string-utils")
local Validations = require("libs.validations")

local nthTick = settings.startup[Constants.ON_NTH_TICK.setting]
-- local nthTick = settings.global[Constants.ON_NTH_TICK.setting]
local disableFoW = false

if (not nthTick or nthTick.value <= 0) then
  nthTick = Constants.ON_NTH_TICK.value
end

function init()
  log("Initializing")
  if (game) then
    game.print("Initializing All Seeing Satellites")
  end

  storage.satellite_toggled_by_player = nil

  storage.satellites_launched = {}
  storage.satellites_toggled = {}
  storage.rocket_silos = {}

  -- for k,v in pairs(game.surfaces) do
  for k,surface in pairs(game.surfaces) do
    -- Search for planets
    if (not String_Utils.find_invalid_substrings(surface.name)) then
      -- table.insert(storage.satellites_launched, { surface.name, 0 })
      table.insert(storage.satellites_toggled, { surface.name, false })
    end
  -- end
  -- for k, surface in pairs(game.surfaces) do
    local rocket_silos = surface.find_entities_filtered({type = "rocket-silo"})
    for i=1,#rocket_silos do
      local rocket_silo = rocket_silos[i]
      if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then

        if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
          and not storage.rocket_silos[rocket_silo.surface.name])
        then
          storage.rocket_silos[rocket_silo.surface.name] = {}
        end

        if (storage.rocket_silos[rocket_silo.surface.name]) then
          table.insert(storage.rocket_silos[rocket_silo.surface.name], {
            unit_number = rocket_silo.unit_number,
            entity = rocket_silo
          })
        else
          log(serpent.block(rocket_silo.surface.name))
        end
      end
    end
  end
  log(serpent.block(storage.rocket_silos))
  -- game.print(serpent.block(storage.rocket_silos))

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = true
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

function trackSatelliteLaunchesOrdered(event)
  if (event and event.rocket and event.rocket.valid and event.rocket.cargo_pod) then
    local inventory = event.rocket.cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if (inventory) then
      for _, item in ipairs(inventory.get_contents()) do
        if (item.name == "satellite") then
          -- game.print(serpent.block(event.rocket_silo.surface))
          -- if (not storage.satellites_launched[event.rocket_silo.surface.name]) then
          --   storage.satellites_launched[event.rocket_silo.surface.name] = 0
          -- end
          -- storage.satellites_launched[event.rocket_silo.surface.name] = storage.satellites_launched[event.rocket_silo.surface.name] + 1
          -- game.print(serpent.block(storage.satellites_launched))
          satellite_launched(event.rocket_silo.surface.name)
        end
      end
    end
  end
end

function rocket_silo_built(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      init()
    else
      table.insert(storage.rocket_silos[rocket_silo.surface.name], rocket_silo)
      log(serpent.block(storage.rocket_silos))
      game.print(serpent.block(storage.rocket_silos))
    end
  end
end

function rocket_silo_mined(event)
	local rocket_silo = event.entity

  if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      init()
    else
      storage.rocket_silos[rocket_silo.surface.name][rocket_silo] = nil
      log(serpent.block(storage.rocket_silos))
      game.print(serpent.block(storage.rocket_silos))
    end
  end
end

function rocket_silo_mined_script(event)
	local rocket_silo = event.entity

  if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      init()
    else
      storage.rocket_silos[rocket_silo.surface.name][rocket_silo] = nil
      log(serpent.block(storage.rocket_silos))
      game.print(serpent.block(storage.rocket_silos))
    end
  end
end

function launch_rocket(event)
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    init()
  end

  local tick = event.tick
  local nth_tick = event.nth_tick

  if (storage.rocket_silos) then
    for _, planet in pairs(Constants.get_planets(false)) do
      log(serpent.block(storage.rocket_silos))
      -- game.print(serpent.block(storage.rocket_silos))
      for _, rocket_silo_unit_numbers in pairs(storage.rocket_silos) do
        for i=1, #rocket_silo_unit_numbers do
          local rocket_silos = storage.rocket_silos[planet.name]
          local rocket_silo = nil

          if (rocket_silos[i] and rocket_silos[i].entity) then
            rocket_silo = rocket_silos[i].entity
          end

          if (rocket_silo and rocket_silo.valid) then
            local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
            if (inventory) then
              for _, item in ipairs(inventory.get_contents()) do
                -- log(serpent.block(item))
                -- game.print(serpent.block(item))
                if (item.name == "satellite") then
                  local rocket = rocket_silo.rocket
                  -- log(serpent.block(rocket))
                  -- game.print(serpent.block(rocket))

                  if (rocket and rocket.valid) then
                    local cargo_pod = rocket.attached_cargo_pod
                    -- log(serpent.block(cargo_pod))
                    -- game.print(serpent.block(cargo_pod))

                    if (cargo_pod and cargo_pod.valid) then
                      cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }
                      if (cargo_pod.cargo_pod_destination) then
                        -- log(serpent.block(cargo_pod.cargo_pod_destination))
                        -- game.print(serpent.block(cargo_pod.cargo_pod_destination))
                      end
                    end
                  end

                  -- log(serpent.block(rocket_silo))
                  -- game.print(serpent.block(rocket_silo))

                  if (rocket_silo.launch_rocket()) then
                    log("Launched satellite: " .. serpent.block(rocket_silo))
                  else
                    log("Failed to launch satellite: " .. serpent.block(rocket_silo))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

function satellite_launched(planet_name)
  if (Validations.validate_satellites_launched(planet_name)) then
    storage.satellites_launched[planet_name] = storage.satellites_launched[planet_name] + 1
    log(serpent.block(storage.satellites_launched))
    game.print(serpent.block(storage.satellites_launched))
  else
    log("How did this happen?")
    log(serpent.block(planet_name))
  end
end

--
-- Register events

script.on_init(init)

script.on_nth_tick(nthTick, toggleFoW)
script.on_nth_tick(nthTick, launch_rocket)
script.on_event("all-seeing-satellite-toggle", toggle)
-- script.on_event(defines.events.on_rocket_launched, trackSatelliteLaunches)
script.on_event(defines.events.on_rocket_launch_ordered, trackSatelliteLaunchesOrdered)

-- rocket-silo tracking
script.on_event(defines.events.on_built_entity, rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_robot_built_entity, rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_built, rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_revive, rocket_silo_built, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_player_mined_entity, rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_robot_mined_entity, rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.on_entity_died, rocket_silo_mined, {{ filter = "type", type = "rocket-silo" }})
script.on_event(defines.events.script_raised_destroy, rocket_silo_mined_script, {{ filter = "type", type = "rocket-silo" }})
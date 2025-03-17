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

  for k,surface in pairs(game.surfaces) do
    -- Search for planets
    if (not String_Utils.find_invalid_substrings(surface.name)) then
      table.insert(storage.satellites_toggled, { surface.name, false })
    end

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
          add_rocket_silo(rocket_silo, true)
        else
          log(serpent.block(rocket_silo.surface.name))
        end
      end
    end
  end

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
  if (event and event.rocket and event.rocket.valid and event.rocket.cargo_pod and event.rocket.cargo_pod.valid) then

    log(serpent.block(event.rocket.cargo_pod))
    game.print(serpent.block(event.rocket.cargo_pod))
    log(serpent.block(event.rocket.cargo_pod.cargo_pod_destination))
    game.print(serpent.block(event.rocket.cargo_pod.cargo_pod_destination))

    -- Check for a satellite if the cargo pod doesn't have a station and has a destination type of 1
    --   -> no station implies it was sent to "orbit"
    --   -> .type is 1 for some reason, and not defines.cargo_destination.orbit as I would have thought
    if (  event.rocket.cargo_pod.cargo_pod_destination
      and not event.rocket.cargo_pod.cargo_pod_destination.station
      and event.rocket.cargo_pod.cargo_pod_destination.type == 1)
    then
      local inventory = event.rocket.cargo_pod.get_inventory(defines.inventory.cargo_unit)

      if (inventory) then
        for _, item in ipairs(inventory.get_contents()) do
          if (item.name == "satellite") then
            satellite_launched(event.rocket_silo.surface.name)
          end
        end
      end
    end
  end
end

function add_rocket_silo(--[[required]]rocket_silo, --[[optional]]is_init)
  -- Validate inputs
  is_init = is_init or false -- default value

  if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
    log("Call to add_rocket_silo with invalid input")
    log(serpent.block(rocket_silo))
    return
  end

  if (not storage.rocket_silos) then
    if (is_init) then
      storage.rocket_silos = {}
    else
      init()
    end
    return
  end

  if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
    and not storage.rocket_silos[rocket_silo.surface.name])
  then
    storage.rocket_silos[rocket_silo.surface.name] = {}
  end

  if (storage.rocket_silos[rocket_silo.surface.name]) then
    log("adding rocket silo to rocket_silos: ")
    log(serpent.block(rocket_silo))
    table.insert(storage.rocket_silos[rocket_silo.surface.name], {
      unit_number = rocket_silo.unit_number,
      entity = rocket_silo,
      valid = rocket_silo.valid
    })
  else
    log("This shouldn't be possible")
    log(serpent.block(rocket_silo.surface.name))
  end
end

function rocket_silo_built(event)
	local rocket_silo = event.entity

	if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      init()
    else
      add_rocket_silo(rocket_silo)
      log("Built rocket silo")
      log(serpent.block(rocket_silo))
    end
  end
end

function rocket_silo_mined(event)
  mine_rocket_silo(event)
end

function rocket_silo_mined_script(event)
  mine_rocket_silo(event)
end

function mine_rocket_silo(event)
  local rocket_silo = event.entity

  if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
		if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
      init()
    else
      log("Before removal")
      log(serpent.block(storage.rocket_silos[rocket_silo.surface.name]))
      local surface_rocket_silos = storage.rocket_silos[rocket_silo.surface.name]

      for i=1, #surface_rocket_silos do
        if (surface_rocket_silos[i] and surface_rocket_silos[i].entity == rocket_silo) then
          table.remove(surface_rocket_silos, i)
        end
      end

      log("After removal")
      log(serpent.block(storage.rocket_silos[rocket_silo.surface.name]))
    end
  end
end

function launch_rocket(event)
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    init()
  end

  local tick = event.tick
  local nth_tick = event.nth_tick

  local tick_mod = tick % nth_tick

  if (storage.rocket_silos) then
    for _, planet in pairs(Constants.get_planets(false)) do
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
                if (item.name == "satellite") then
                  local rocket = rocket_silo.rocket

                  if (rocket and rocket.valid) then
                    local cargo_pod = rocket.attached_cargo_pod

                    if (cargo_pod and cargo_pod.valid) then
                      cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }
                    end
                  end

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
-- script.on_evemt(defines.events.on_tick, launch_rocket)
script.on_event("all-seeing-satellite-toggle", toggle)
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
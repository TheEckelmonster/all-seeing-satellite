-- If already defined, return
if _satellite and _satellite.all_seeing_satellite then
  return _satellite
end

local Constants = require("libs.constants")
local Validations = require("libs.validations")

local satellite = {}

function satellite.track_satellite_launches_ordered(event)
  if (event and event.rocket and event.rocket.valid and event.rocket.cargo_pod and event.rocket.cargo_pod.valid) then

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
            start_satellite_countdown(item, event.tick, event.rocket_silo.surface.name)
          end
        end
      end
    end
  end
end

function satellite.check_for_dead_satellites(event)
  local tick = event.tick
  local offset = Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value / 2

  if (settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name]) then
    offset = settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name].value
  end

  local tick_modulo = tick % offset

  if (Validations.is_storage_valid()) then
    local planets = Constants.get_planets()
    if (planets) then
      for _, planet in pairs(planets) do
        if (storage.satellites_in_orbit) then
          for _, satellites in pairs(storage.satellites_in_orbit) do
            if (satellites) then
              for i, satellite in pairs(satellites) do
                if (not satellite or not satellite.entity) then
                  return
                end

                if (satellite.tick_created % offset ~= tick_modulo and satellite.tick_to_die % offset ~= tick_modulo) then
                  return
                end

                -- In theory:
                --   -> valid satellite
                --   -> unit_id and tick modulos match
                if (tick >= satellite.tick_to_die) then
                  if (i <= #satellites and satellites[i] and satellites[i].entity == satellite.entity) then
                    if (Validations.validate_satellites_launched(planet.name) and #satellites > 0) then
                      table.remove(satellites, i)
                      storage.satellites_launched[planet.name] = storage.satellites_launched[planet.name] - 1
                    end
                  elseif (i > #satellites) then
                    -- log("Index out of bounds")
                  elseif (not satellites[i]) then
                    -- log("satellites[" .. serpent.block(i) .. "] is nil")
                  elseif (satellites[i] ~= satellite) then
                    -- log("satellites[" .. serpent.block(i) .. "].entity ~= satellite.entity")
                  else
                    -- log("Unable to remove satellite for unknown reason")
                    -- log(serpent.block(i))
                    -- log(serpent.block(satellites))
                    -- log(serpent.block(satellites[i]))
                    -- log(serpent.block(satellites[i].entity))
                    -- log(serpent.block(satellite))
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
    -- log(serpent.block(storage.satellites_launched))
    -- game.print(serpent.block(storage.satellites_launched))
  else
    log("How did this happen?")
    log(serpent.block(planet_name))
  end
end

function start_satellite_countdown(satellite, tick, planet_name)
  log(serpent.block(satellite))
  game.print(serpent.block(satellite))
  log(serpent.block(tick))
  game.print(serpent.block(tick))

  if (  Validations.is_storage_valid()
    and satellite
    and tick
    and planet_name)
  then
    local death_tick = 0

    if (settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name]) then
      --         =  tick + settings value * 60 * 60) -> 3600 ticks per minute
      death_tick = (tick + (settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name].value) * constants.TICKS_PER_MINUTE)
    else
      --         =  tick + Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value * 3600 by default
      death_tick = (tick + (Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value * constants.TICKS_PER_MINUTE))
    end

    table.insert(storage.satellites_in_orbit[planet_name], {
      entity = satellite,
      tick_created = tick,
      tick_to_die = death_tick
    })
    -- log(serpent.block(storage.satellites_in_orbit))
    -- game.print(serpent.block(storage.satellites_in_orbit))
  end
end

satellite.all_seeing_satellite = true

local _satellite = satellite

return satellite
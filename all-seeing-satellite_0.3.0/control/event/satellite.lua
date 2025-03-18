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
            satellite_launched(event.rocket_silo.surface.name, item, event.tick)
          end
        end
      end
    end
  end
end

function satellite.check_for_expired_satellites(event)
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
                      if (Validations.validate_satellites_in_orbit(satellite.planet_name)) then
                        get_num_satellites_in_orbit(satellite.planet_name)
                      end
                      game.print("Satellite ran out of fuel orbiting " .. serpent.block(satellite.planet_name))
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

function satellite_launched(planet_name, item, tick)
  if (Validations.validate_satellites_launched(planet_name) and Validations.validate_satellites_in_orbit(planet_name)) then
    start_satellite_countdown(item, tick, planet_name)
  else
    log("How did this happen?")
    log(serpent.block(planet_name))
  end
end

function start_satellite_countdown(satellite, tick, planet_name)
  if (  Validations.is_storage_valid()
    and Validations.validate_satellites_launched(planet_name)
    and Validations.validate_satellites_in_orbit(planet_name)
    and satellite
    and tick
    and planet_name)
  then
    local death_tick = 0
    local quality_multiplier = 1

    log(serpent.block(satellite))
    game.print(serpent.block(satellite))

    if (satellite.quality == "normal") then
      quality_multiplier = 1
    elseif (satellite.quality == "uncommon") then
      quality_multiplier = 1.3
    elseif (satellite.quality == "rare") then
      quality_multiplier = 1.69
    elseif (satellite.quality == "epic") then
      quality_multiplier = 2.197
    elseif (satellite.quality == "legendary") then
      quality_multiplier = 2.8561
    end

    log("quality_multiplier = " .. serpent.block(quality_multiplier))
    game.print("quality_multiplier = " .. serpent.block(quality_multiplier))

    if (settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name]) then
              -- =  tick + settings value * 60 * 60 * quality_multiplier -> 3600 ticks per minute
      death_tick = (tick + (settings.global[Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name].value) * Constants.TICKS_PER_MINUTE * quality_multiplier)
    else
              -- =  tick + Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value * 3600 (by default) * quality_multiplier
      death_tick = (tick + (Constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value * Constants.TICKS_PER_MINUTE * quality_multiplier))
    end

    log("tick: " .. tick .. " : tick_to_die: " .. death_tick)
    game.print(serpent.block("tick: " .. tick .. " : tick_to_die: " .. death_tick))

    if (Validations.validate_satellites_in_orbit(planet_name)) then
      table.insert(storage.satellites_in_orbit[planet_name], {
        entity = satellite,
        planet_name = planet_name,
        tick_created = tick,
        tick_to_die = death_tick
      })

      get_num_satellites_in_orbit(planet_name)
    end
  end
end

function get_num_satellites_in_orbit(planet_name)
  if (Validations.validate_satellites_launched(planet_name) and Validations.validate_satellites_in_orbit(planet_name)) then
    storage.satellites_launched[planet_name] = #(storage.satellites_in_orbit[planet_name])
    return storage.satellites_launched[planet_name]
  end
  return 0
end

satellite.all_seeing_satellite = true

local _satellite = satellite

return satellite
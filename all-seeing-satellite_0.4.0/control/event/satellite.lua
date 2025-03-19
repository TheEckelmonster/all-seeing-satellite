-- If already defined, return
if _satellite and _satellite.all_seeing_satellite then
  return _satellite
end

local Constants = require("libs.constants")
local Satellite_Utils = require("libs.utils.satellite-utils")
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
            Satellite_Utils.satellite_launched(event.rocket_silo.surface.name, item, event.tick)
          end
        end
      end
    end
  end
end

function satellite.check_for_expired_satellites(event)
  local tick = event.tick
  local offset = Constants.TICKS_PER_SECOND / 2
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
                        Satellite_Utils.get_num_satellites_in_orbit(satellite.planet_name)
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

function satellite.recalculate_satellite_time_to_die(tick)
  if (tick and Validations.is_storage_valid()) then
    if (storage.satellites_in_orbit) then
      for _, satellites in pairs(storage.satellites_in_orbit) do
        if (satellites) then
          for _, satellite in pairs(satellites) do
            if (satellite) then
              satellite.tick_to_die = Satellite_Utils.calculate_tick_to_die(satellite.tick_created, satellite)
            end
          end
        end
      end
    end
  end
end

satellite.all_seeing_satellite = true

local _satellite = satellite

return satellite
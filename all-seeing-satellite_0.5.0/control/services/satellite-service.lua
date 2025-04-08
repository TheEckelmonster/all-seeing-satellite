-- If already defined, return
if _satellite_service and _satellite_service.all_seeing_satellite then
  return _satellite_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Utils = require("control.utils.satellite-utils")
local Storage_Service = require("control.services.storage-service")

local satellite_service = {}

function satellite_service.track_satellite_launches_ordered(event)
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

function satellite_service.check_for_expired_satellites(event)
  local tick = event.tick
  local offset = Constants.TICKS_PER_SECOND / 2
  local tick_modulo = tick % offset

  if (Storage_Service.is_storage_valid()) then
    local planets = Constants.get_planets()
    if (planets) then
      for _, planet in pairs(planets) do
        -- if (storage.satellites_in_orbit) then
        if (Storage_Service.get_all_satellites_in_orbit()) then
          for _, satellites in pairs(Storage_Service.get_all_satellites_in_orbit()) do
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
                    -- if (Validations.validate_satellites_launched(planet.name) and #satellites > 0) then
                    if (Storage_Service.get_satellites_launched(planet.name) and #satellites > 0) then
                      table.remove(satellites, i)
                      if (Storage_Service.get_satellites_in_orbit(satellite.planet_name)) then
                        Satellite_Utils.get_num_satellites_in_orbit(satellite.planet_name)
                      end
                      game.print("Satellite ran out of fuel orbiting " .. serpent.block(satellite.planet_name))
                    end
                  elseif (i > #satellites) then
                    Low.debug("Index out of bounds")
                  elseif (not satellites[i]) then
                    Log.debug("satellites[" .. serpent.block(i) .. "] is nil")
                  elseif (satellites[i] ~= satellite) then
                    Log.debug("satellites[" .. serpent.block(i) .. "].entity ~= satellite.entity")
                  else
                    Log.error("Unable to remove satellite for unknown reason")
                    Log.warn(i)
                    Log.warn(satellites)
                    Log.warn(satellites[i])
                    Log.warn(satellites[i].entity)
                    Log.warn(satellite)
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

function satellite_service.recalculate_satellite_time_to_die(tick)
  local tick = tick or 1 --math.huge

  if (tick > 1 and Storage_Service.is_storage_valid()) then
    if (Storage_Service.get_all_satellites_in_orbit()) then
      for _, satellites in pairs(Storage_Service.get_all_satellites_in_orbit()) do
        if (satellites) then
          for _, satellite in pairs(satellites) do
            if (satellite) then
              Log.debug(satellite)
              satellite.tick_to_die = Satellite_Utils.calculate_tick_to_die(satellite.tick_created, satellite)
              Log.debug(satellite)
            end
          end
        end
      end
    end
  end
end

satellite_service.all_seeing_satellite = true

local _satellite_service = satellite_service

return satellite_service
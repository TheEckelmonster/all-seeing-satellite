-- If already defined, return
if _satellite_service and _satellite_service.all_seeing_satellite then
  return _satellite_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Repository = require("control.repositories.satellite-repository")
local Satellite_Utils = require("control.utils.satellite-utils")

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

  local planets = Constants.get_planets()
  if (not planets) then return end

  local all_satellite_meta_data = Satellite_Meta_Repository.get_all_satellite_meta_data()

  for planet, satellite_meta_data in pairs(all_satellite_meta_data) do
    for i, satellite_data in pairs(satellite_meta_data.satellites) do
      if (not satellite_data or not satellite_data.entity) then
        return
      end

      if (satellite_data.created % offset ~= tick_modulo and satellite_data.tick_to_die % offset ~= tick_modulo) then
        return
      end

      -- In theory:
      --   -> valid satellite
      --   -> unit_id and tick modulos match
      if (tick >= satellite_data.tick_to_die) then
          if (satellite_meta_data.satellites_launched and #satellite_meta_data.satellites > 0) then
            Satellite_Repository.delete_satellite_data_by_index({ planet_name = satellite_data.planet_name, index = i, })
            if (satellite_meta_data.satellites_in_orbit) then
              Satellite_Utils.get_num_satellites_in_orbit(satellite_meta_data)
            end
            -- TODO: Change this to force.print
            game.print("Satellite ran out of fuel orbiting " .. serpent.block(satellite_data.planet_name))
          end
      end
    end
  end
end

function satellite_service.recalculate_satellite_time_to_die(tick)
  Log.debug("satellite_service.recalculate_satellite_time_to_die")
  Log.info(tick)
  tick = tick or 1 --math.huge

  if (tick > 1) then
    local all_satellite_data = Satellite_Repository.get_all_satellite_data()
    for _, satellite_data in pairs(all_satellite_data) do
      satellite_data.tick_to_die = Satellite_Utils.calculate_tick_to_die(satellite_data.created, satellite_data)
    end
  end
end

satellite_service.all_seeing_satellite = true

local _satellite_service = satellite_service

return satellite_service
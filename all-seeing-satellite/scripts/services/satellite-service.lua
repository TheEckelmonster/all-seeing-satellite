-- If already defined, return
if _satellite_service and _satellite_service.all_seeing_satellite then
  return _satellite_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local Satellite_Utils = require("scripts.utils.satellite-utils")

local satellite_service = {}

function satellite_service.track_satellite_launches_ordered(event)
  Log.debug("satellite_service.track_satellite_launches_ordered")
  Log.info(event)

  if (not event) then return end
  if (not event.cargo_pod or not event.cargo_pod.valid) then return end
  local cargo_pod = event.cargo_pod
  if (not cargo_pod.cargo_pod_destination) then return end

  -- Check for a satellite if the cargo pod doesn't have a station and has a destination type of 1
  --   -> no station implies it was sent to "orbit"
  --   -> .type is 1 for some reason, and not defines.cargo_destination.orbit as I would have thought
  if (  cargo_pod.cargo_pod_destination
    and not cargo_pod.cargo_pod_destination.station
    and cargo_pod.cargo_pod_destination.type == 1
    and event.launched_by_rocket)
  then
    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)

    if (inventory) then
      for _, item in ipairs(inventory.get_contents()) do
        if (item.name == "satellite") then
          Satellite_Utils.satellite_launched(cargo_pod.surface.name, item, event.tick)

          Log.info("destroying cargo pod")
          if (cargo_pod.destroy()) then
            Log.debug("cargo pod destroyed")
          end
        end
      end
    end
  end
end

function satellite_service.check_for_expired_satellites(event)
  Log.debug("satellite_service.check_for_expired_satellites")
  Log.info(event)
  Log.info(event.planet_name)

  if (not event) then return end
  if (not event.tick) then return end
  if (not event.planet_name) then return end

  local tick = event.tick
  local offset = Constants.TICKS_PER_SECOND / 2
  local tick_modulo = tick % offset

  local planet_name = event.planet_name
  if (not planet_name) then return end

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
  if (not satellite_meta_data.valid) then return end

  for i, satellite_data in pairs(satellite_meta_data.satellites) do
    if (not satellite_data.valid) then
      goto continue
    end

    if (tick >= satellite_data.tick_to_die) then
      if (satellite_meta_data.satellites_launched and #satellite_meta_data.satellites > 0) then
        Satellite_Repository.delete_satellite_data_by_index({ planet_name = satellite_data.planet_name, index = i, })
        if (satellite_meta_data.satellites_in_orbit) then
          Satellite_Utils.get_num_satellites_in_orbit(satellite_meta_data)
        end
        -- TODO: Change this to force.print
        game.print("Satellite ran out of fuel orbiting " .. serpent.line(satellite_data.planet_name))
      end
    end
    ::continue::
  end
end

function satellite_service.recalculate_satellite_time_to_die(tick)
  Log.debug("satellite_service.recalculate_satellite_time_to_die")
  Log.info(tick)
  tick = tick or 1 --math.huge

  if (tick > 1) then
    local all_satellite_data = Satellite_Repository.get_all_satellite_data()
    for _, satellite_data in pairs(all_satellite_data) do
      satellite_data.tick_to_die = Satellite_Utils.calculate_tick_to_die(satellite_data.created, satellite_data.entity)
    end
  end
end

satellite_service.all_seeing_satellite = true

local _satellite_service = satellite_service

return satellite_service
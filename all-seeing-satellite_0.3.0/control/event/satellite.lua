-- If already defined, return
if _satellite and _satellite.all_seeing_satellite then
  return _satellite
end

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
    -- game.print(serpent.block(storage.satellites_launched))
  else
    log("How did this happen?")
    log(serpent.block(planet_name))
  end
end

satellite.all_seeing_satellite = true

local _satellite = satellite

return satellite
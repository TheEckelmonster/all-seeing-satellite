-- If already defined, return
if _satellite_utils and _satellite_utils.all_seeing_satellite then
  return _satellite_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Settings_Service = require("control.services.settings-service")
local Validations = require("control.validations.validations")

local satellite_utils = {}

function satellite_utils.satellite_launched(planet_name, item, tick)
  if (Validations.validate_satellites_launched(planet_name) and Validations.validate_satellites_in_orbit(planet_name)) then
    satellite_utils.start_satellite_countdown(item, tick, planet_name)
  else
    Log.error("How did this happen?")
    Log.warn(planet_name, true)
  end
end

function satellite_utils.start_satellite_countdown(satellite, tick, planet_name)
  if (  Validations.is_storage_valid()
    and Validations.validate_satellites_launched(planet_name)
    and Validations.validate_satellites_in_orbit(planet_name)
    and satellite
    and tick
    and planet_name)
  then
    Log.debug("Calculating death tick")
    local death_tick = satellite_utils.calculate_tick_to_die(tick, satellite)
    Log.debug("death tick = " .. serpent.block(death_tick))

    if (Validations.validate_satellites_in_orbit(planet_name)) then
      Log.debug("Adding satellite to planet: " .. serpent.block(planet_name))
      table.insert(storage.satellites_in_orbit[planet_name], {
        entity = satellite,
        planet_name = planet_name,
        tick_created = tick,
        tick_to_die = death_tick
      })

      satellite_utils.get_num_satellites_in_orbit(planet_name)
    end
  end
end

function satellite_utils.get_num_satellites_in_orbit(planet_name)
  if (Validations.validate_satellites_launched(planet_name) and Validations.validate_satellites_in_orbit(planet_name)) then
    Log.debug("Setting num satellites launched for planet: " .. serpent.block(planet_name))
    storage.satellites_launched[planet_name] = #(storage.satellites_in_orbit[planet_name])
    return storage.satellites_launched[planet_name]
  end
  Log.warn("Validations failed for planet: " .. serpent.block(planet_name))
  return 0
end

function satellite_utils.calculate_tick_to_die(tick, satellite)
  local death_tick = 0
  local quality_multiplier = 1

  Log.debug(tick)

  if (tick and satellite) then
    Log.info(satellite)

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

    Log.debug(satellite.quality)
    Log.debug(quality_multiplier)

    death_tick = (tick + (Settings_Service.get_default_satellite_time_to_live() * Constants.TICKS_PER_MINUTE * quality_multiplier))
  end

  return death_tick
end

satellite_utils.all_seeing_satellite = true

local _satellite_utils = satellite_utils

return satellite_utils
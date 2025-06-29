-- If already defined, return
if _satellite_utils and _satellite_utils.all_seeing_satellite then
  return _satellite_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local Settings_Service = require("scripts.services.settings-service")

local satellite_utils = {}

function satellite_utils.satellite_launched(planet_name, item, tick)
  Log.debug("satellite_utils.satellite_launched")
  Log.info(planet_name)
  Log.info(item)
  Log.info(tick)

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
  if (satellite_meta_data and satellite_meta_data.valid) then
    satellite_utils.start_satellite_countdown(item, tick, satellite_meta_data)
  else
    Log.error("How did this happen?")
    Log.warn(planet_name, true)
  end
end

function satellite_utils.start_satellite_countdown(satellite, tick, satellite_meta_data)
  Log.debug("satellite_utils.start_satellite_countdown")
  Log.info(satellite)
  Log.info(tick)
  Log.info(satellite_meta_data)

  if (  satellite_meta_data
    and satellite_meta_data.valid
    and satellite
    and tick)
  then
    Log.debug("Calculating death tick")
    local death_tick = satellite_utils.calculate_tick_to_die(tick, satellite)
    Log.debug("death tick = " .. serpent.block(death_tick))

    if (satellite_meta_data.satellites_in_orbit >= 0) then
      Log.debug("Adding satellite to planet: " .. serpent.block(satellite_meta_data.planet_name))
      Satellite_Repository.save_satellite_data({
        planet_name = satellite_meta_data.planet_name,
        entity = satellite,
        death_tick = death_tick,
      })
      satellite_meta_data.satellites_launched = satellite_meta_data.satellites_launched + 1
      satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
    end
  end
end

function satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
  Log.debug("satellite_utils.get_num_satellites_in_orbit")
  Log.info(satellite_meta_data)

  if (satellite_meta_data and satellite_meta_data.valid) then
    Log.debug("Setting num satellites launched for planet: " .. serpent.block(satellite_meta_data.planet_name))
    satellite_meta_data.satellites_in_orbit = #satellite_meta_data.satellites
    return satellite_meta_data.satellites_in_orbit
  end
  Log.warn("Validations failed for satellite_meta_data: " .. serpent.line(satellite_meta_data))
  return 0
end

function satellite_utils.calculate_tick_to_die(tick, satellite)
  Log.debug("satellite_utils.calculate_tick_to_die")
  Log.info(tick)
  Log.info(satellite)

  local death_tick = 0
  local quality_multiplier = 1

  Log.debug(tick)

  if (tick and satellite) then
    Log.info(satellite)

    quality_multiplier = satellite_utils.get_quality_multiplier(satellite.quality)

    Log.debug(satellite.quality)
    Log.debug(quality_multiplier)

    death_tick = (tick + (Settings_Service.get_default_satellite_time_to_live() * Constants.TICKS_PER_MINUTE * quality_multiplier))
  end

  return death_tick
end

function satellite_utils.get_quality_multiplier(quality)
  Log.debug("satellite_utils.get_quality_multiplier")
  Log.info(quality)

  local return_val = 1

  if (not quality or not type(quality) == "string") then return return_val end
  if (not prototypes) then return return_val end
  if (not prototypes.quality) then return return_val end
  if (not prototypes.quality[quality]) then return return_val end
  if (not prototypes.quality[quality].level) then return return_val end

  return Settings_Service.get_satellite_base_quality_factor()^(prototypes.quality[quality].level)
end

satellite_utils.all_seeing_satellite = true

local _satellite_utils = satellite_utils

return satellite_utils
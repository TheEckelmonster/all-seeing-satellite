-- If already defined, return
if _satellite_utils and _satellite_utils.all_seeing_satellite then
  return _satellite_utils
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Repository = require("control.repositories.satellite-repository")
local Settings_Service = require("control.services.settings-service")
-- local Storage_Service = require("control.services.storage-service")

local satellite_utils = {}

function satellite_utils.satellite_launched(planet_name, item, tick)
  Log.debug("satellite_utils.satellite_launched")
  Log.info(planet_name)
  Log.info(item)
  Log.info(tick)

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
  -- Log.error(satellite_meta_data)
  -- if (Storage_Service.get_satellites_launched(planet_name) and Storage_Service.get_satellites_in_orbit(planet_name)) then
  -- if (satellite_meta_data and satellite_meta_data.valid and satellite_meta_data.satellite_launched and satellite_meta_data.satellites_in_orbit) then
  if (satellite_meta_data and satellite_meta_data.valid) then
    -- satellite_utils.start_satellite_countdown(item, tick, planet_name)
    satellite_utils.start_satellite_countdown(item, tick, satellite_meta_data)
  else
    Log.error("How did this happen?")
    Log.warn(planet_name, true)
  end
end

-- function satellite_utils.start_satellite_countdown(satellite, tick, planet_name)
function satellite_utils.start_satellite_countdown(satellite, tick, satellite_meta_data)
  Log.debug("satellite_utils.start_satellite_countdown")
  Log.info(satellite)
  Log.info(tick)
  -- Log.info(planet_name)
  Log.info(satellite_meta_data)

  -- if (  Storage_Service.is_storage_valid()
  --   and Storage_Service.get_satellites_launched(planet_name)
  --   and Storage_Service.get_satellites_in_orbit(planet_name)
  if (  satellite_meta_data
    and satellite_meta_data.valid
    -- and type(satellite_meta_data.satellite_launched) == "number"
    -- and type(satellite_meta_data.satellites_in_orbit) == "number"
    and satellite
    and tick)
    -- and planet_name)
  then
    Log.debug("Calculating death tick")
    local death_tick = satellite_utils.calculate_tick_to_die(tick, satellite)
    Log.debug("death tick = " .. serpent.block(death_tick))

    -- if (Storage_Service.get_satellites_in_orbit(planet_name)) then
    -- if (type(satellite_meta_data.satellites_in_orbit) == "number" and satellite_meta_data.satellites_in_orbit >= 0) then
    if (satellite_meta_data.satellites_in_orbit >= 0) then
      -- Log.debug("Adding satellite to planet: " .. serpent.block(planet_name))
      Log.debug("Adding satellite to planet: " .. serpent.block(satellite_meta_data.planet_name))
      -- Storage_Service.add_to_satellites_in_orbit(satellite, planet_name, tick, death_tick)
      Satellite_Repository.save_satellite_data({
        planet_name = satellite_meta_data.planet_name,
        entity = satellite,
        death_tick = death_tick,
      })
      satellite_meta_data.satellites_launched = satellite_meta_data.satellites_launched + 1
      -- satellite_utils.get_num_satellites_in_orbit(planet_name)
      satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
    end
  end
end

-- function satellite_utils.get_num_satellites_in_orbit(planet_name)
function satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
  Log.debug("satellite_utils.get_num_satellites_in_orbit")
  -- Log.info(planet_name)
  Log.info(satellite_meta_data)

  -- if (Storage_Service.get_satellites_launched(planet_name) and Storage_Service.get_satellites_in_orbit(planet_name)) then
  -- if (satellite_meta_data and satellite_meta_data.valid and satellite_meta_data.satellites_launched and satellite_meta_data.satellites_in_orbit) then
  if (satellite_meta_data and satellite_meta_data.valid) then
    -- Log.debug("Setting num satellites launched for planet: " .. serpent.block(planet_name))
    -- Storage_Service.set_satellites_launched(#Storage_Service.get_satellites_in_orbit(planet_name), planet_name)
    -- return Storage_Service.get_satellites_launched(planet_name)
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

  -- TODO: Make these configurable
  local exp = 0
  local b = 1.3

  if (quality == "normal") then
    return_val = b^(exp + 0) -- 1
  elseif (quality == "uncommon") then
    return_val = b^(exp + 1) -- 1.3
  elseif (quality == "rare") then
    return_val = b^(exp + 2) -- 1.69
  elseif (quality == "epic") then
    return_val = b^(exp + 3) -- 2.197
  elseif (quality == "legendary") then
    return_val = b^(exp + 4) -- 2.8561
  end

  return return_val
end

satellite_utils.all_seeing_satellite = true

local _satellite_utils = satellite_utils

return satellite_utils
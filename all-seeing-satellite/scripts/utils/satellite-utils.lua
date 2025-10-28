local Constants = require("scripts.constants.constants")
local Satellite_Repository = require("scripts.repositories.satellite-repository")

local quality_active = scripts and scripts.active_mods and scripts.active_mods["quality"]

local satellite_utils = {}

function satellite_utils.satellite_launched(satellite_in_transit_data, tick, satellite_meta_data)
    Log.debug("satellite_utils.satellite_launched")
    Log.info(satellite_in_transit_data)
    Log.info(satellite_meta_data)

    if (satellite_in_transit_data and satellite_in_transit_data.valid and satellite_meta_data and satellite_meta_data.valid) then
        satellite_utils.start_satellite_countdown(satellite_in_transit_data, tick, satellite_meta_data)
    else
        Log.error("How did this happen?")
        Log.warn(planet_name, true)
    end
end

function satellite_utils.start_satellite_countdown(satellite_in_transit_data, tick, satellite_meta_data)
    Log.debug("satellite_utils.start_satellite_countdown")
    Log.info(satellite_in_transit_data)
    Log.info(tick)
    Log.info(satellite_meta_data)

    if (    satellite_meta_data
        and satellite_meta_data.valid
        and satellite_in_transit_data
        and tick
    ) then
        Log.debug("Calculating death tick")
        local death_tick = satellite_utils.calculate_tick_to_die(tick, satellite_in_transit_data.entity)
        Log.debug("death tick = " .. tostring(death_tick))

        if (satellite_meta_data.satellites_in_orbit >= 0) then
            Log.debug("Adding satellite to planet: " .. serpent.block(satellite_meta_data.planet_name))

            satellite_in_transit_data.tick_to_die = death_tick
            Satellite_Repository.save_satellite_data(satellite_in_transit_data)

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

        quality_multiplier = quality_active and satellite_utils.get_quality_multiplier(satellite.quality) or 1

        Log.debug(satellite.quality)
        Log.debug(quality_multiplier)

        death_tick = (
            tick
            + ( Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name })
              * Constants.TICKS_PER_MINUTE
              * quality_multiplier
            )
        )
    end

    return death_tick
end

function satellite_utils.get_quality_multiplier(quality)
    Log.debug("satellite_utils.get_quality_multiplier")
    Log.info(quality)

    local return_val = 1

    if (not quality_active) then return return_val end

    if (not quality or not type(quality) == "string") then return return_val end
    if (not prototypes) then return return_val end
    if (not prototypes.quality) then return return_val end
    if (not prototypes.quality[quality]) then return return_val end
    if (not prototypes.quality[quality].level) then return return_val end

    return Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_BASE_QUALITY_FACTOR.name }) ^ (prototypes.quality[quality].level)
end

satellite_utils.all_seeing_satellite = true

local _satellite_utils = satellite_utils

return satellite_utils
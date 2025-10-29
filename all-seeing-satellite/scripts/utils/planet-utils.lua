local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local String_Utils = require("scripts.utils.string-utils")

local locals = {}

local planet_utils = {}

function planet_utils.allow_toggle(surface_name)
    Log.debug("planet_utils.allow_toggle")
    Log.info(surface_name)

    if (String_Utils.find_invalid_substrings(surface_name)) then return false end

    if (not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.name })) then return true end

    if (surface_name) then
        local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
        return satellite_meta_data and satellite_meta_data.valid and
        satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
    end

    return false
end

function planet_utils.allow_satellite_mode(surface_name)
    Log.debug("planet_utils.allow_satellite_mode")
    Log.info(surface_name)

    if (String_Utils.find_invalid_substrings(surface_name)) then return false end

    if (not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name })) then return true end

    if (surface_name) then
        local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
        return satellite_meta_data and satellite_meta_data.valid and
        satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
    end

    return false
end

function planet_utils.planet_launch_threshold(surface_name)
    Log.debug("planet_utils.planet_launch_threshold")
    Log.info(surface_name)

    local return_val = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.default_value
                     * Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.default_value

    if (not surface_name) then
        return return_val
    end

    if (String_Utils.find_invalid_substrings(surface_name)) then return end

    local planet_magnitude = locals.get_planet_magnitude(surface_name)
    return_val = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name })
                * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.name })
                * planet_magnitude ^ 2

    if (planet_magnitude < 1) then
        Log.debug("floor")
        return_val = math.floor(return_val)
    else
        Log.debug("ceil")
        return_val = math.ceil(return_val)
    end

    return return_val
end

function planet_utils.allow_scan(surface_name)
    Log.debug("planet_utils.allow_scan")
    Log.info(surface_name)

    if (not surface_name) then return false end

    if (not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name })) then return true end

    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)

    return satellite_meta_data and satellite_meta_data.valid and
    (satellite_meta_data.satellites_in_orbit > 0 or #satellite_meta_data.satellites > 0)
end

locals.get_planet_magnitude = function(surface_name)
    Log.debug("planet_utils.get_planet_magnitude")
    Log.info(surface_name)

    local planets = Constants.get_planet_data()
    local planet_magnitude = 1

    if (planets) then
        for _, planet in ipairs(planets) do
            if (planet and planet.name == surface_name) then
                planet_magnitude = planet.magnitude
                break
            end
        end
    end

    Log.info(planet_magnitude)

    if (not planet_magnitude) then
        planet_magnitude = 1
    end

    return planet_magnitude
end

return planet_utils
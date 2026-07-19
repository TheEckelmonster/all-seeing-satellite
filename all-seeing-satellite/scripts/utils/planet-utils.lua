local ipairs = ipairs
local math_ceil = math.ceil
local math_floor = math.floor
local string_find = string.find

local Constants = Constants
local get_planet_data = Constants.get_planet_data
local Runtime_Global_Settings_Constants = Runtime_Global_Settings_Constants

local DEFAULT_GLOBAL_LAUNCH_SATELLITE_THRESHOLD = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.default_value
local DEFAULT_GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.default_value

local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local require_satellites_in_orbit = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.name })
local restrict_satellite_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name })
local restrict_satellite_scanning = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name })
local global_launch_satellite_threshold = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name })
local global_launch_satellite_threshold_modifier = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.name })

local locals = {}

local planet_utils = {}

function planet_utils.allow_toggle(surface_name)
    -- Log.debug("planet_utils.allow_toggle")
    -- Log.info(surface_name)

    if (find_invalid_substrings(surface_name)) then return false end

    if (not require_satellites_in_orbit) then return true end

    if (surface_name) then
        local satellite_meta_data = get_satellite_meta_data(surface_name)
        return satellite_meta_data and satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
    end

    return false
end

function planet_utils.allow_satellite_mode(surface_name)
    -- Log.debug("planet_utils.allow_satellite_mode")
    -- Log.info(surface_name)

    if (find_invalid_substrings(surface_name)) then return false end

    if (not restrict_satellite_mode) then return true end

    if (surface_name) then
        local satellite_meta_data = get_satellite_meta_data(surface_name)
        return satellite_meta_data and satellite_meta_data.satellites_in_orbit >= planet_utils.planet_launch_threshold(surface_name)
    end

    return false
end

function planet_utils.planet_launch_threshold(surface_name)
    -- Log.debug("planet_utils.planet_launch_threshold")
    -- Log.info(surface_name)

    local return_val = DEFAULT_GLOBAL_LAUNCH_SATELLITE_THRESHOLD
                     * DEFAULT_GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER

    if (not surface_name) then
        return return_val
    end

    if (find_invalid_substrings(surface_name)) then return end

    local planet_magnitude = locals.get_planet_magnitude(surface_name)
    return_val =  global_launch_satellite_threshold
                * global_launch_satellite_threshold_modifier
                * planet_magnitude * planet_magnitude

    if (planet_magnitude < 1) then
        -- Log.debug("floor")
        return_val = math_floor(return_val)
    else
        -- Log.debug("ceil")
        return_val = math_ceil(return_val)
    end

    return return_val
end

function planet_utils.allow_scan(surface_name)
    -- Log.debug("planet_utils.allow_scan")
    -- Log.info(surface_name)

    if (not surface_name) then return false end

    if (not restrict_satellite_scanning) then return true end

    local satellite_meta_data = get_satellite_meta_data(surface_name)

    return satellite_meta_data and (satellite_meta_data.satellites_in_orbit > 0 or #satellite_meta_data.satellites > 0)
end

locals.get_planet_magnitude = function(surface_name)
    -- Log.debug("planet_utils.get_planet_magnitude")
    -- Log.info(surface_name)

    local planets = get_planet_data()
    local planet_magnitude = 1

    if (planets) then
        for _, planet in ipairs(planets) do
            if (planet and planet.name == surface_name) then
                planet_magnitude = planet.magnitude
                break
            end
        end
    end

    -- Log.info(planet_magnitude)

    if (not planet_magnitude) then
        planet_magnitude = 1
    end

    return planet_magnitude
end


local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.REQUIRE_SATELLITES_IN_ORBIT.name] = function (event, params) require_satellites_in_orbit = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name] = function (event, params) restrict_satellite_scanning = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name] = function (event, params) restrict_satellite_mode = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name] = function (event, params) global_launch_satellite_threshold = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER.name] = function (event, params) global_launch_satellite_threshold_modifier = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function planet_utils.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "planet_utils",
    func = planet_utils.on_runtime_mod_setting_changed
})

return planet_utils
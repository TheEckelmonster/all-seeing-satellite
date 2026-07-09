local storage

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game

    Set_Game_Funcs()

    return game
end

local string_find = string.find
local type = type

local STRING = Types.STRING
local TICKS_PER_MINUTE = Constants.TICKS_PER_MINUTE

local prototypes = prototypes
local Quality = prototypes.quality
local script = script

local Satellite_Repository = require("scripts.repositories.satellite-repository")

local quality_active = script and script.active_mods and script.active_mods["quality"]

local satellite_base_quality_factor = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_BASE_QUALITY_FACTOR.name, })
local satellite_default_time_to_live = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name, })

local satellite_utils = {}
satellite_utils.name = "satellite_utils"
satellite_utils.set_game = set_game

function satellite_utils.satellite_launched(satellite_in_transit_data, tick, satellite_meta_data)
    -- Log.debug("satellite_utils.satellite_launched")
    -- Log.info(satellite_in_transit_data)
    -- Log.info(satellite_meta_data)

    if (satellite_in_transit_data and satellite_meta_data) then
        satellite_utils.start_satellite_countdown(satellite_in_transit_data, tick, satellite_meta_data)
    end
end

function satellite_utils.start_satellite_countdown(satellite_in_transit_data, tick, satellite_meta_data)
    -- Log.debug("satellite_utils.start_satellite_countdown")
    -- Log.info(satellite_in_transit_data)
    -- Log.info(tick)
    -- Log.info(satellite_meta_data)

    if (    satellite_meta_data
        and satellite_in_transit_data
        and tick
    ) then
        -- Log.debug("Calculating death tick")
        local death_tick = satellite_utils.calculate_tick_to_die(tick, satellite_in_transit_data.entity)
        -- Log.debug("death tick = " .. tostring(death_tick))

        if (satellite_meta_data.satellites_in_orbit >= 0) then
            -- Log.debug("Adding satellite to planet: " .. serpent.block(satellite_meta_data.planet_name))

            satellite_in_transit_data.tick_to_die = death_tick
            Satellite_Repository.save_satellite_data(satellite_in_transit_data)

            satellite_meta_data.satellites_launched = satellite_meta_data.satellites_launched + 1
            satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
        end
    end
end

function satellite_utils.get_num_satellites_in_orbit(satellite_meta_data)
    -- Log.debug("satellite_utils.get_num_satellites_in_orbit")
    -- Log.info(satellite_meta_data)

    if (satellite_meta_data) then
        -- Log.debug("Setting num satellites launched for planet: " .. serpent.block(satellite_meta_data.planet_name))
        satellite_meta_data.satellites_in_orbit = #satellite_meta_data.satellites
        return satellite_meta_data.satellites_in_orbit
    end
    -- Log.warn("Validations failed for satellite_meta_data: " .. serpent.line(satellite_meta_data))
    return 0
end

function satellite_utils.calculate_tick_to_die(tick, satellite)
    -- Log.debug("satellite_utils.calculate_tick_to_die")
    -- Log.info(tick)
    -- Log.info(satellite)

    local death_tick = 0
    local quality_multiplier = 1

    -- Log.debug(tick)

    if (tick and satellite) then
        -- Log.info(satellite)

        quality_multiplier = quality_active and satellite_utils.get_quality_multiplier(satellite.quality) or 1

        -- Log.debug(satellite.quality)
        -- Log.debug(quality_multiplier)

        death_tick = (
            tick
            + (   satellite_default_time_to_live
                * TICKS_PER_MINUTE
                * quality_multiplier
            )
        )
    end

    return death_tick
end

function satellite_utils.get_quality_multiplier(quality)
    -- Log.debug("satellite_utils.get_quality_multiplier")
    -- Log.info(quality)

    local return_val = 1

    if (not quality_active) then return return_val end

    if (not quality or not type(quality) == STRING) then return return_val end
    if (not Quality) then return return_val end

    local specific_quality = Quality[quality]
    if (not specific_quality) then return return_val end
    if (not specific_quality.level) then return return_val end

    return satellite_base_quality_factor ^ (prototypes.quality[quality].level)
end


local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_BASE_QUALITY_FACTOR.name] = function (event, params) satellite_base_quality_factor = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.DEFAULT_SATELLITE_TIME_TO_LIVE.name] = function (event, params) satellite_default_time_to_live = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function satellite_utils.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "satellite_utils",
    func = satellite_utils.on_runtime_mod_setting_changed
})

function satellite_utils.init(__storage) storage = __storage end

return satellite_utils
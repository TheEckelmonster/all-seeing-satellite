local type = type

local BOOLEAN = "boolean"
local STRING = "string"
local TABLE = "table"

local EMPTY_STRING = ""

local MSG_TOGGLE_VALID_FULL = "messages.toggle-valid-full"
local MSG_TOGGLE_VALID = "messages.toggle-valid"
local MSG_TOGGLE_DEFAULT = "messages.toggle-default"

local TECL_String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")
local format_surface_name = TECL_String_Utils.format_surface_name

local Planet_Utils = require("scripts.utils.planet-utils")
local planet_launch_threshold = Planet_Utils.planet_launch_threshold
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data

local fog_of_war_utils = {}

function fog_of_war_utils.print_toggle_message(data)
    -- Log.debug("fog_of_war_utils.print_toggle_message")
    -- Log.info(data)

    if (not data or type(data) ~= TABLE) then return end
    if (not data.message or type(data.message) ~= TABLE) then return end
    if (not data.surface_name or type(data.surface_name) ~= STRING) then return end
    if (not data.add_count or type(data.add_count) ~= BOOLEAN) then data.add_count = false end
    if (not data.force or not data.force.valid) then return end

    local formatted_surface_name = format_surface_name({ string_data = data.surface_name }) or data.surface_name

    local satellite_meta_data = get_satellite_meta_data(data.surface_name)
    if (satellite_meta_data) then
        if (data.add_count) then
            data.force.print({
                EMPTY_STRING,
                data.message,
                {
                    MSG_TOGGLE_VALID_FULL,
                    formatted_surface_name,
                    satellite_meta_data.satellites_in_orbit,
                    planet_launch_threshold(data.surface_name),
                },
            })
        else
            data.force.print({ EMPTY_STRING, data.message, { MSG_TOGGLE_VALID, formatted_surface_name, satellite_meta_data.satellites_in_orbit } })
        end
    else
        data.force.print({ EMPTY_STRING, data.message, { MSG_TOGGLE_DEFAULT, formatted_surface_name } })
    end
end

return fog_of_war_utils
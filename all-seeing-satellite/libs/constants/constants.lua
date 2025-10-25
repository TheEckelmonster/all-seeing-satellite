-- If already defined, return
if _constants and _constants.all_seeing_satellite then
    return _constants
end

local Log = require("libs.log.log")
local Planet_Data = require("scripts.data.planet-data")
local String_Utils = require("scripts.utils.string-utils")

local locals = {}

local constants = {}

constants.mod_name = "all-seeing-satellite"

constants.TICKS_PER_SECOND = 60
constants.SECONDS_PER_MINUTE = 60
constants.TICKS_PER_MINUTE = constants.TICKS_PER_SECOND * constants.SECONDS_PER_MINUTE

constants.DEFAULT_RESEARCH = {}
constants.DEFAULT_RESEARCH.name = "rocket-silo"

constants.CHUNK_SIZE = 32

constants.optionals = {}
constants.optionals.DEFAULT = {}
constants.optionals.DEFAULT.mode = "queue"
constants.optionals.mode = {}
constants.optionals.mode.stack = "stack"
constants.optionals.mode.queue = "queue"

function constants.get_planets(reindex)
    if (not reindex and constants.planets and #constants.planets > 0) then
        return constants.planets
    end

    Log.debug("Reindexing constants.planets")
    return locals.get_planets()
end

locals.get_planets = function()
    constants.planets = {}
    constants.planets_dictionary = {}

    if (prototypes) then
        local planet_prototypes = prototypes.mod_data["all-seeing-satellite-mod-data"]

        if (planet_prototypes and type(planet_prototypes) == "table") then
            Log.debug("Found planet prototypes")
        end
        Log.info(planet_prototypes)

        for planet_name, planet_data in pairs(planet_prototypes.data) do
            if (not String_Utils.find_invalid_substrings(planet_name)
                    and planet_data and type(planet_data) == "table")
            then
                Log.debug("Found valid planet")
                Log.info(planet_data)
                if (planet_name and game) then
                    local planet_surface = game.get_surface(planet_name)
                    local planet_magnitude = planet_data.magnitude

                    if (not planet_magnitude or type(planet_magnitude) ~= "number" or planet_magnitude <= 0) then
                        Log.warn("Planet magnitude not found, or was invalid - defaulting to 1")
                        planet_magnitude = 1
                    end

                    -- Surface can be nil
                    -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                    local new_planet_data = Planet_Data:new({
                        name = planet_name,
                        surface = planet_surface,
                        magnitude = planet_magnitude,
                        valid = true,
                    })

                    Log.debug("Adding planet")
                    Log.info(new_planet_data)
                    table.insert(constants.planets, new_planet_data)
                    constants.planets_dictionary[planet_name] = new_planet_data
                end
            end
        end
    end

    return constants.planets
end

constants.all_seeing_satellite = true

local _constants = constants

return constants
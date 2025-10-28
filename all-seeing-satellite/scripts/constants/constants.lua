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
constants.mod_data = {
    planets = {},
    planets_dictionary = {},
}

function constants.new_mod_data()
    return
    {
        planets = {},
        planets_dictionary = {},
    }
end

function constants.get_planet_data(data)
    if (not data or type(data) ~= "table") then data = { reindex = false } end

    if (data.on_load) then
        locals.get_planet_data({ on_load = true })
        return
    end

    if (not data.reindex and constants.mod_data and constants.mod_data.planets and #constants.mod_data.planets > 0) then
        return constants.mod_data.planets
    end

    Log.debug("Reindexing constants.mod_data.planets")
    return locals.get_planet_data()
end

locals.get_planet_data = function(data)
    if (not data or type(data) ~= "table") then data = { on_load = false } end

    constants.mod_data = constants.new_mod_data()

    if (prototypes) then
        local planet_prototypes = prototypes.mod_data["all-seeing-satellite-mod-data"]

        if (type(planet_prototypes) == "table") then
            Log.debug("Found planet prototypes")
        end
        Log.info(planet_prototypes)

        for planet_name, planet_data in pairs(planet_prototypes.data.planet) do
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
                    table.insert(constants.mod_data.planets, new_planet_data)
                    constants.mod_data.planets_dictionary[planet_name] = new_planet_data
                end
            end
        end
    end

    if (data.on_load) then
        if (type(storage) == "table") then constants.mod_data = storage.constants end
    else
        if (type(storage) == "table" and type(storage.constants) ~= "table") then storage.constants = {} end
        if (type(storage) == "table") then storage.constants = constants.mod_data end
    end

    return constants.mod_data and constants.mod_data.planets or nil
end

return constants
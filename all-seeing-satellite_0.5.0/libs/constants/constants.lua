-- If already defined, return
if _constants and _constants.all_seeing_satellite then
  return _constants
end

local Log = require("libs.log.log")
local String_Utils = require("control.utils.string-utils")

local constants = {
  nauvis = {},
  fulgora = {},
  gleba = {},
  vulcanus = {}
}

constants.ON_NTH_TICK = {}
constants.ON_NTH_TICK.value = 60
constants.ON_NTH_TICK.setting = "all-seeing-satellite-on-nth-tick"

constants.TICKS_PER_SECOND = 60
constants.SECONDS_PER_MINUTE = 60
constants.TICKS_PER_MINUTE = constants.TICKS_PER_SECOND * constants.SECONDS_PER_MINUTE

constants.DEFAULT_RESEARCH = {}
constants.DEFAULT_RESEARCH.name = "rocket-silo"

function constants.get_planets(reindex)
  if (not reindex and constants.planets) then
    return constants.planets
  end

  Log.debug("Reindexing constants.planets")
  return get_planets()
end

function get_planets()
  constants.planets = {}

  if (prototypes) then
    local planet_prototypes = prototypes.get_entity_filtered({{ filter = "type", type = "constant-combinator"}})
    if (planet_prototypes and #planet_prototypes > 0) then
      Log.debug("Found planet prototypes")
    end
    Log.info(planet_prototypes)

    for key, planet in pairs(planet_prototypes) do
      if (  String_Utils.is_all_seeing_satellite_added_planet(key)
        and planet and planet.valid)
      then
        Log.debug("Found valid planet")
        Log.info(planet)
        local planet_name = String_Utils.get_planet_name(key)
        if (planet_name and game) then
          -- TODO: Need to add functionality to change '-' to '_' within planet_name
          -- Do I though?
          local planet_surface = game.get_surface(planet_name)
          local planet_magnitude = String_Utils.get_planet_magnitude(key)

          if (not planet_magnitude) then
            Log.warn("No planet magnitude found, defaulting to 1")
            planet_magnitude = 1
          end

          -- Surface can be nil
          -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
          local _planet = {
            name = planet_name,
            surface = planet_surface,
            magnitude = planet_magnitude,
          }

          Log.debug("Adding planet")
          Log.info(_planet)
          table.insert(constants.planets, _planet)
        end
      end
    end
  end

  return constants.planets
end

-- TODO: Not needed anymore?
function find_invalid_substrings(string)
  Log.debug(string)
  return string.find(string, "-", 1, true)
      or string.find(string, "EE_", 1, true)
      or string.find(string, "TEST", 1, true)
      or string.find(string, "test", 1, true)
end

constants.all_seeing_satellite = true

local _constants = constants

return constants
-- If already defined, return
if _constants and _constants.all_seeing_satellite then
  return _constants
end

local String_Utils = require("libs.utils.string-utils")

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
constants.TICKS_PER_MINUTE = constants.TICKS_PER_SECOND * 60

constants.HOTKEY_EVENT_NAME = {}
constants.HOTKEY_EVENT_NAME.value = "N"
constants.HOTKEY_EVENT_NAME.name = "all-seeing-satellite-toggle"

constants.REQUIRE_SATELLITES_IN_ORBIT = {}
constants.REQUIRE_SATELLITES_IN_ORBIT.value = true
constants.REQUIRE_SATELLITES_IN_ORBIT.name = "all-see-satellite-require-satellites-in-orbit"

constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD = {}
constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.value = 3
constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.max = 100
constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.min = 0
constants.GLOBAL_LAUNCH_SATELLITE_THRESHOLD.name = "all-seeing-satellite-global-launch-satellite-threshold"

constants.DEFAULT_SATELLITE_TIME_TO_LIVE = {}
constants.DEFAULT_SATELLITE_TIME_TO_LIVE.value = 20
-- constants.DEFAULT_SATELLITE_TIME_TO_LIVE.max = -- What should be the maximum, if any?
constants.DEFAULT_SATELLITE_TIME_TO_LIVE.min = 1
constants.DEFAULT_SATELLITE_TIME_TO_LIVE.name = "all-seeing-satellite-default-satellite-time-to-live"

constants.DEFAULT_RESEARCH = {}
constants.DEFAULT_RESEARCH.name = "rocket-silo"

function constants.get_planets(reindex)
  if (not reindex and constants.planets) then
    return constants.planets
  end

  return get_planets()
end

function get_planets()
  constants.planets = {}

  if (prototypes) then
    local planet_prototypes = prototypes.get_entity_filtered({{ filter = "type", type = "constant-combinator"}})

    for key, planet in pairs(planet_prototypes) do
      if (  String_Utils.is_all_seeing_satellite_added_planet(key)
        and planet and planet.valid)
      then
        local planet_name = String_Utils.get_planet_name(key)
        if (planet_name and game) then
          local planet_surface = game.get_surface(planet_name)
          -- if (planet_surface) then
          local planet_magnitude = String_Utils.get_planet_magnitude(key)

          if (not planet_magnitude) then
            planet_magnitude = 1
          end

          -- Surface can be nil
          -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
          table.insert(constants.planets, {
            name = planet_name,
            surface = planet_surface,
            magnitude = planet_magnitude,
          })
          -- end
        end
      end
    end
  end

  return constants.planets
end

function find_invalid_substrings(string)
  return string.find(string, "-", 1, true)
      or string.find(string, "EE_", 1, true)
      or string.find(string, "TEST", 1, true)
      or string.find(string, "test", 1, true)
end

constants.all_seeing_satellite = true

local _constants = constants

return constants
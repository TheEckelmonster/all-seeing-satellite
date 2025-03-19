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

  constants.planets = {}

  if (game and game.surfaces) then
    for k, surface in pairs(game.surfaces) do
      -- Search for planets
      if (not find_invalid_substrings(surface.name)) then
        table.insert(constants.planets, { name = k, surface = surface })
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
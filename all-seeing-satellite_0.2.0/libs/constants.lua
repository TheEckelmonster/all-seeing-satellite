-- If already defined, return
if _constants and _constants.all_seeing_satellite then
  return _constants
end

local String_Utils = require("libs.string-utils")

local constants = {
  nauvis = {},
  fulgora = {},
  gleba = {},
  vulcanus = {}
}

constants.ON_NTH_TICK = {}
constants.ON_NTH_TICK.value = 60
constants.ON_NTH_TICK.setting = "all-seeing-satellite-on-nth-tick"

constants.HOTKEY_EVENT_NAME = {}
constants.HOTKEY_EVENT_NAME.value = "N"
constants.HOTKEY_EVENT_NAME.setting = "all-seeing-satellite-toggle"

function constants.get_planets(reindex)
  if (not reindex and constants.planets) then
    return constants.planets
  end

  constants.planets = {}

  for k, surface in pairs(game.surfaces) do
    -- Search for planets
    if (not String_Utils.find_invalid_substrings(surface.name)) then
      table.insert(constants.planets, { name = k, surface = surface })
    end
  end

  return constants.planets
end

constants.all_seeing_satellite = true

local _constants = constants

return constants
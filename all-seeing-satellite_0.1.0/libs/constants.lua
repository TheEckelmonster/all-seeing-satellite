-- If already defined, return
if _constants and _constants.all_seeing_satellite then
  return _constants
end

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

constants.all_seeing_satellite = true

local _constants = constants

return constants
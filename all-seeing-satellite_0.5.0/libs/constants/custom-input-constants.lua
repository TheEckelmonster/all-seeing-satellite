-- If already defined, return
if _custom_input_constants and _custom_input_constants.all_seeing_satellite then
  return _custom_input_constants
end

local custom_input_constants = {}

custom_input_constants.FOG_OF_WAR_TOGGLE = {
  type = "custom-input",
  name = "all-seeing-satellite-fog-of-war-toggle",
  key_sequence = "N",
  consuming = "none",
  localised_name = 'Toggle Satellite'
}

custom_input_constants.SCAN_SELECTED_CHUNK = {
  type = "custom-input",
  name = "all-seeing-satellite-scan-selected-chunk",
  key_sequence = "M",
  consuming = "game-only",
  localised_name = 'Scan Selected Area',
  item_to_spawn = "satellite-scanning-remote",
  action = "spawn-item",
}

custom_input_constants.TOGGLE_SCANNING = {
  type = "custom-input",
  name = "all-seeing-satellite-toggle-scanning",
  key_sequence = "CONTROL + SPACE",
  consuming = "none",
  localised_name = 'Toggle Scanning'
}

custom_input_constants.CANCEL_SCANNING = {
  type = "custom-input",
  name = "all-seeing-satellite-cancel-scanning",
  key_sequence = "CONTROL + SHIFT + SPACE",
  consuming = "none",
  localised_name = 'Cancel Scanning'
}

custom_input_constants.all_seeing_satellite = true

local _custom_input_constants = custom_input_constants

return custom_input_constants
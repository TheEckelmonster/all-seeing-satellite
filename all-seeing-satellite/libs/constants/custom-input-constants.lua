local custom_input_constants = {}

local prefix = "all-seeing-satellite-"

custom_input_constants.FOG_OF_WAR_TOGGLE = {
    type = "custom-input",
    name = prefix .. "fog-of-war-toggle",
    key_sequence = "N",
    consuming = "none",
    localised_name = 'Toggle Satellite'
}

custom_input_constants.SCAN_SELECTED_CHUNK = {
    type = "custom-input",
    name = prefix .. "scan-selected-chunk",
    key_sequence = "M",
    consuming = "game-only",
    localised_name = 'Scan Selected Area',
    item_to_spawn = "satellite-scanning-remote",
    action = "spawn-item",
}

custom_input_constants.TOGGLE_SCANNING = {
    type = "custom-input",
    name = prefix .. "toggle-scanning",
    key_sequence = "CONTROL + SPACE",
    consuming = "none",
    localised_name = 'Toggle Scanning'
}

custom_input_constants.CANCEL_SCANNING = {
    type = "custom-input",
    name = prefix .. "cancel-scanning",
    key_sequence = "CONTROL + SHIFT + SPACE",
    consuming = "none",
    localised_name = 'Cancel Scanning'
}

custom_input_constants.TOGGLE_SATELLITE_MODE = {
    type = "custom-input",
    name = prefix .. "toggle-satellite-mode",
    key_sequence = "COMMA",
    consuming = "none",
    localised_name = 'Toggle Satellite Mode'
}

return custom_input_constants
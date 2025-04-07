Settings_Constants = require("libs.constants.settings-constants")

data:extend({
  {
    type = "custom-input",
    name = Settings_Constants.hotkeys.FOG_OF_WAR_TOGGLE.name,
    key_sequence = Settings_Constants.hotkeys.FOG_OF_WAR_TOGGLE.value,
    consuming = "none",
    localised_name = 'Toggle Satellite'
  },
  {
    type = "custom-input",
    name = Settings_Constants.hotkeys.SCAN_SELECTED_CHUNK.name,
    key_sequence = Settings_Constants.hotkeys.SCAN_SELECTED_CHUNK.value,
    consuming = "game-only",
    localised_name = 'Scan Selected Area',
    item_to_spawn = "satellite-scanning-remote",
    action = "spawn-item",
  },
  {
    type = "custom-input",
    name = Settings_Constants.hotkeys.TOGGLE_SCANNING.name,
    key_sequence = Settings_Constants.hotkeys.TOGGLE_SCANNING.value,
    consuming = "none",
    localised_name = 'Toggle Scanning'
  },
  {
    type = "custom-input",
    name = Settings_Constants.hotkeys.CANCEL_SCANNING.name,
    key_sequence = Settings_Constants.hotkeys.CANCEL_SCANNING.value,
    consuming = "none",
    localised_name = 'Cancel Scanning'
  },
})
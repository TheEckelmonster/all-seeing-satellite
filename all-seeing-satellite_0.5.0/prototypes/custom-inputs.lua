Constants = require("libs.constants.settings-constants")

data:extend({
  {
    type = "custom-input",
    name = Constants.HOTKEY_EVENT_NAME.name,
    key_sequence = Constants.HOTKEY_EVENT_NAME.value,
    consuming = "none",
    localised_name = 'Toggle Satellite'
  },
  {
    type = "custom-input",
    name = Constants.hotkeys.SCAN_SELECTED_CHUNK.name,
    key_sequence = Constants.hotkeys.SCAN_SELECTED_CHUNK.value,
    consuming = "game-only",
    localised_name = 'Scan Chunk',
    include_selected_prototype = true,
    -- item_to_spawn = "spidertron-remote",
    -- action = "lua"
  }
})
local Settings_Utils = require("__TheEckelmonster-core-library__.libs.utils.settings-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

data:extend(Settings_Utils.order_settings({ settings = Runtime_Global_Settings_Constants.settings }).array)

local Constants = require("scripts.constants.constants")
local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")

data:extend(Log_Settings.create({ prefix = Constants.mod_name, settings_array = Runtime_Global_Settings_Constants.settings }))
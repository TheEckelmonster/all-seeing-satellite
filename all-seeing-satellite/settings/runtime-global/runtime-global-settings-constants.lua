local Constants = require("scripts.constants.constants")

local  prefix = Constants.mod_name

local runtime_global_settings_constants = {
    hotkeys = {},
    DEBUG_LEVEL = {
        value = "None",
        name = prefix .. "-debug-level",
    },
    NTH_TICK = { value = 10 },
    settings = {
        REQUIRE_SATELLITES_IN_ORBIT = {
            type = "bool-setting",
            name = prefix .. "-require-satellites-in-orbit",
            setting_type = "runtime-global",
            order = "",
            default_value = true,
        },
        RESTRICT_SATELLITE_SCANNING = {
            type = "bool-setting",
            name = prefix .. "-restrict-satellite-scanning",
            setting_type = "runtime-global",
            order = "",
            default_value = true,
        },
        RESTRICT_SATELLITE_MODE = {
            type = "bool-setting",
            name = prefix .. "-restrict-satellite-mode",
            setting_type = "runtime-global",
            order = "",
            default_value = true,
        },
        TRACK_SATELLITES_LAUNCHED_FOR_RESEARCH = {
            type = "bool-setting",
            name = prefix .. "-track-satellites-launched-for-research",
            setting_type = "runtime-global",
            order = "",
            default_value = true,
        },
        DO_LAUNCH_ROCKETS = {
            type = "bool-setting",
            name = prefix .. "-do-launch-rockets",
            setting_type = "runtime-global",
            order = "",
            default_value = true,
        },
        ROCKET_LAUNCH_DELAY = {
            type = "int-setting",
            name = prefix .. "-rocket-launch-delay",
            setting_type = "runtime-global",
            order = "",
            default_value = 30,
            minimum_value = 0,
            maximum_value = 2 ^ 32,
        },
        SATELLITE_BASE_QUALITY_FACTOR = {
            type = "double-setting",
            name = prefix .. "-satellite-base-quality-factor",
            setting_type = "runtime-global",
            order = "",
            default_value = 1.3,
            -- maximum_value = 11,
            minimum_value = 1,
        },
        GLOBAL_LAUNCH_SATELLITE_THRESHOLD = {
            type = "int-setting",
            name = prefix .. "-global-launch-satellite-threshold",
            setting_type = "runtime-global",
            order = "",
            default_value = 3,
            maximum_value = 111,
            minimum_value = 0,
        },
        GLOBAL_LAUNCH_SATELLITE_THRESHOLD_MODIFIER = {
            type = "double-setting",
            name = prefix .. "-global-launch-satellite-threshold-modifier",
            setting_type = "runtime-global",
            order = "",
            default_value = 1,
            maximum_value = 11,
            minimum_value = 0,
        },
        DEFAULT_SATELLITE_TIME_TO_LIVE = {
            type = "double-setting",
            name = prefix .. "-default-satellite-time-to-live",
            setting_type = "runtime-global",
            order = "",
            default_value = 20,
            maximum_value = 1111, -- What should be the maximum, if any?
            minimum_value = 0,
        },
        SATELLITE_SCAN_COOLDOWN_DURATION = {
            type = "double-setting",
            name = prefix .. "-satellite-scan-cooldown-duration",
            setting_type = "runtime-global",
            order = "",
            default_value = 0.85,
            maximum_value = 1111, -- What should be the maximum, if any?
            minimum_value = 0,
        },
        SATELLITE_SCAN_MODE = {
            type = "string-setting",
            name = prefix .. "-satellite-scan-mode",
            setting_type = "runtime-global",
            order = "",
            default_value = "queue",
            allowed_values = { "queue", "stack" }
        },
        NTH_TICK = {
            type = "int-setting",
            name = prefix .. "-nth-tick",
            setting_type = "runtime-global",
            order = "",
            maximum_value = 11111,
            minimum_value = 1,
        },
        SATELLITE_MODE_VIEW_DISTANCE = {
            type = "int-setting",
            name = prefix .. "-satellite-mode-view-distance",
            setting_type = "runtime-global",
            order = "",
            default_value = 400,
            maximum_value = 2 ^ 11,
            minimum_value = 1,
        },
        SATELLITE_MODE_MAX_VIEW_DISTANCE = {
            type = "int-setting",
            name = prefix .. "-satellite-mode-max-view-distance",
            setting_type = "runtime-global",
            order = "",
            default_value = 400,
            maximum_value = 2 ^ 11,
            minimum_value = 1,
        },
    },
}

runtime_global_settings_constants.settings.NTH_TICK.default_value = runtime_global_settings_constants.NTH_TICK.value

return runtime_global_settings_constants
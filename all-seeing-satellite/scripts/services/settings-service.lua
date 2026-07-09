local storage
local storage_startup_settings
local storage_runtime_settings

local settings = settings
local settings_startup = settings.startup
local settings_runtime = settings.global

local type = type

local TABLE = "table"
local STRING = "string"

local settings_service = {}

function settings_service.get_runtime_global_setting(params)
    if (not params or not type(params) == TABLE) then return end
    if (not params.setting or type(params.setting) ~= STRING) then return end

    if (not storage_runtime_settings) then
        storage.settings_map = storage.settings_map or {}
        storage.settings_map.runtime_global = storage.settings_map.runtime_global or {}
        storage_runtime_settings = storage.settings_map.runtime_global
    end

    local setting = storage_runtime_settings and storage_runtime_settings[params.setting]

    if (setting == nil or params.reindex) then
        setting = settings_runtime[params.setting] and settings_runtime[params.setting].value
    end

    if (storage_runtime_settings) then storage_runtime_settings[params.setting] = setting end
    return setting
end

function settings_service.get_startup_setting(params)

    if (not params or not type(params) == TABLE) then return end
    if (not params.setting or type(params.setting) ~= STRING) then return end

    if (not storage_runtime_settings) then
        storage.settings_map = storage.settings_map or {}
        storage.settings_map.startup = storage.settings_map.startup or {}
        storage_runtime_settings = storage.settings_map.startup
    end

    local setting = storage_startup_settings and storage_startup_settings[params.setting]

    if (setting == nil or params.reindex) then
        setting = settings_startup[params.setting] and settings_startup[params.setting].value
    end

    if (storage_startup_settings) then storage_startup_settings[params.setting] = setting end

    return setting
end

function settings_service.init(__storage)
    storage = __storage or _ENV.storage

    if (storage and storage.settings_map) then
        if (storage.settings_map.startup) then storage_startup_settings = storage.settings_map.startup end
        if (storage.settings_map.runtime_global) then storage_runtime_settings = storage.settings_map.runtime_global end
    end
end

return settings_service
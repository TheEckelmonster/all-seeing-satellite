local pairs = pairs

local Satellite_Meta_Data = require("scripts.data.satellite.satellite-meta-data")
local new_Satellite_Meta_Data = Satellite_Meta_Data.new

local function migrate()
    local storage = _ENV.storage
    local all_seeing_satellite_data = storage.storage_old and storage.storage_old.all_seeing_satellite or storage.all_seeing_satellite or nil

    if (not all_seeing_satellite_data) then return end

    storage.satellite_meta_data_repository = storage.satellite_meta_data_repository or {}
    for k, v in pairs(all_seeing_satellite_data.satellite_meta_data or {}) do
        storage.satellite_meta_data_repository[k] = new_Satellite_Meta_Data(Satellite_Meta_Data, v)
    end

    all_seeing_satellite_data.satellite_meta_data = nil
    all_seeing_satellite_data.version_data = nil
end

return migrate
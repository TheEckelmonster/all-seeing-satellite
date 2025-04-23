-- If already defined, return
if _version_repository and _version_repository.all_seeing_satellite then
  return _version_repository
end

local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")
local Log = require("libs.log.log")
local Version_Data = require("control.data.version-data")
local Bug_Fix_Data = require("control.data.versions.bug-fix-data")
local Major_Data = require("control.data.versions.major-data")
local Minor_Data = require("control.data.versions.minor-data")

local version_repository = {}

function version_repository.save_version_data(optionals)
  Log.debug("version_repository.save_version_data")
  Log.info(optionals)

  local return_val = Version_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.version_data) then storage.all_seeing_satellite.version_data = return_val end

  return_val = storage.all_seeing_satellite.version_data

  return version_repository.update_version_data(return_val)
end

function version_repository.update_version_data(update_data, optionals)
  Log.debug("version_repository.update_version_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Version_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.version_data) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.version_data = return_val
    version_repository.save_version_data()
  end

  local version_data = storage.all_seeing_satellite.version_data

  for k, v in pairs(update_data) do
    version_data[k] = v
  end

  version_data.updated = game.tick

  -- Don't think this is necessary, but oh well
  storage.all_seeing_satellite.version_data = version_data

  return version_data
end

function version_repository.get_version_data(optionals)
  Log.debug("version_repository.get_version_data")
  Log.info(optionals)

  local return_val = Version_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.version_data) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.version_data = return_val
    version_repository.save_version_data()
  end

  return storage.all_seeing_satellite.version_data
end

version_repository.all_seeing_satellite = true

local _version_repository = version_repository

return version_repository
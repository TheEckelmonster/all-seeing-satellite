-- If already defined, return
if _all_seeing_satellite_repository and _all_seeing_satellite_repository.all_seeing_satellite then
  return _all_seeing_satellite_repository
end

local Log = require("libs.log.log")
local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")

local all_seeing_satellite_repository = {}

function all_seeing_satellite_repository.save_all_seeing_satellite_data(optionals)
  Log.warn("all_seeing_satellite_repository.save_all_seeing_satellite_data")
  Log.info(optionals)

  local return_val = All_Seeing_Satellite_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = return_val end

  return_val = storage.all_seeing_satellite

  return all_seeing_satellite_repository.update_all_seeing_satellite_data(return_val)
end

function all_seeing_satellite_repository.update_all_seeing_satellite_data(update_data, optionals)
  Log.warn("all_seeing_satellite_repository.update_all_seeing_satellite_data")
  Log.warn(update_data)
  Log.info(optionals)

  local return_val = All_Seeing_Satellite_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite = return_val
    all_seeing_satellite_repository.save_all_seeing_satellite_data()
  end

  return_val = storage.all_seeing_satellite

  for k,v in pairs(update_data) do
    return_val[k] = v
  end

  return_val.updated = game.tick

  -- Don't think this is necessary, but oh well
  storage.all_seeing_satellite = return_val

  return return_val
end

function all_seeing_satellite_repository.delete_all_seeing_satellite_data(optionals)
  Log.warn("all_seeing_satellite_repository.delete_all_seeing_satellite_data")
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (storage.all_seeing_satellite ~= nil) then
    storage.all_seeing_satellite = nil
  end
  return_val = true

  return return_val
end

function all_seeing_satellite_repository.get_all_seeing_satellite_data(optionals)
  Log.debug("all_seeing_satellite_repository.get_all_seeing_satellite_data")
  Log.info(optionals)

  local return_val = All_Seeing_Satellite_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite = return_val
    all_seeing_satellite_repository.save_all_seeing_satellite_data()
  end

  return_val = storage.all_seeing_satellite

  return return_val
end

all_seeing_satellite_repository.all_seeing_satellite = true

local _all_seeing_satellite_repository = all_seeing_satellite_repository

return all_seeing_satellite_repository
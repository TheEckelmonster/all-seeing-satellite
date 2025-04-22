-- If already defined, return
if _satellite_meta_repository and _satellite_meta_repository.all_seeing_satellite then
  return _satellite_meta_repository
end

local Log = require("libs.log.log")
local Satellite_Meta_Data = require("control.data.satellite.satellite-meta-data")

local satellite_meta_repository = {}

function satellite_meta_repository.save_satellite_meta_data(planet_name, optionals)
  Log.debug("satellite_meta_repository.save_satellite_meta_data")
  Log.info(planet_name)
  Log.info(optionals)

  local return_val = Satellite_Meta_Data:new()

  if (not game) then return return_val end
  if (not planet_name or type(planet_name) ~= "string") then return return_val end

  optionals = optionals or {
    surface = game.get_surface(planet_name)
  }

  local surface = optionals.surface or game.get_surface(planet_name)
  if (not surface or not surface.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then storage.all_seeing_satellite.satellite_meta_data[planet_name] = return_val end

  return_val = storage.all_seeing_satellite.satellite_meta_data[planet_name]
  return_val.planet_name = planet_name
  return_val.surface_index = surface.index
  return_val.valid = true

  return satellite_meta_repository.update_satellite_meta_data(return_val)
end

function satellite_meta_repository.update_satellite_meta_data(update_data, optionals)
  Log.debug("satellite_meta_repository.update_satellite_meta_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Satellite_Meta_Data:new()

  if (not game) then return return_val end
  if (not update_data) then return return_val end
  if (not update_data.planet_name or type(update_data.planet_name) ~= "string") then return return_val end

  optionals = optionals or {}

  local planet_name = update_data.planet_name

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = return_val
    satellite_meta_repository.save_satellite_meta_data(planet_name)
  end

  local satellite_meta_data = storage.all_seeing_satellite.satellite_meta_data[planet_name]

  for k,v in pairs(update_data) do
    satellite_meta_data[k] = v
  end

  satellite_meta_data.updated = game.tick

  -- Don't think this is necessary, but oh well
  storage.all_seeing_satellite.satellite_meta_data[planet_name] = satellite_meta_data

  return satellite_meta_data
end

function satellite_meta_repository.delete_satellite_meta_data(planet_name, optionals)
  Log.debug("satellite_meta_repository.delete_satellite_meta_data")
  Log.info(planet_name)
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end
  if (not planet_name or type(planet_name) ~= "string") then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (storage.all_seeing_satellite.satellite_meta_data[planet_name] ~= nil) then
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = nil
  end
  return_val = true

  return return_val
end

function satellite_meta_repository.get_satellite_meta_data(planet_name, optionals)
  Log.debug("satellite_meta_repository.get_satellite_meta_data")
  Log.info(planet_name)
  Log.info(optionals)

  local return_val = Satellite_Meta_Data:new()

  if (not game) then return return_val end
  if (not planet_name or type(planet_name) ~= "string") then return return_val end
  
  optionals = optionals or {}
  
  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = return_val
    satellite_meta_repository.save_satellite_meta_data(planet_name)
  end

  return storage.all_seeing_satellite.satellite_meta_data[planet_name]
end

function satellite_meta_repository.get_all_satellite_meta_data(optionals)
  Log.debug("satellite_meta_repository.get_all_satellite_meta_data")
  Log.info(optionals)

  local return_val = {}

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end

  return storage.all_seeing_satellite.satellite_meta_data
end

satellite_meta_repository.all_seeing_satellite = true

local _satellite_meta_repository = satellite_meta_repository

return satellite_meta_repository
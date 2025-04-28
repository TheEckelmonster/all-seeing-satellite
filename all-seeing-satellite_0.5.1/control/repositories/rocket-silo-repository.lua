-- If already defined, return
if _rocket_silo_repository and _rocket_silo_repository.all_seeing_satellite then
  return _rocket_silo_repository
end

local Log = require("libs.log.log")
local Rocket_Silo_Data = require("control.data.rocket-silo-data")
local Satellite_Meta_Data = require("control.data.satellite.satellite-meta-data")

local rocket_silo_repository = {}

function rocket_silo_repository.save_rocket_silo_data(rocket_silo, optionals)
  Log.debug("rocket_silo_repository.save_rocket_silo_data")
  Log.info(rocket_silo)
  Log.info(optionals)

  local return_val = Rocket_Silo_Data:new()

  if (not game) then return return_val end
  if (not rocket_silo or not rocket_silo.valid) then return return_val end
  if (not rocket_silo.surface or not rocket_silo.surface.valid) then return return_val end

  optionals = optionals or {}

  local planet_name = rocket_silo.surface.name
  if (not planet_name) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = Satellite_Meta_Data:new()
    Satellite_Meta_Data.save_satellite_meta_data(planet_name)
  end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos) then storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos = {} end

  local rocket_silos = storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos

  return_val.unit_number = rocket_silo.unit_number
  return_val.entity = rocket_silo
  return_val.valid = true

  rocket_silos[return_val.unit_number] = return_val

  return rocket_silo_repository.update_rocket_silo_data(return_val)
end

function rocket_silo_repository.update_rocket_silo_data(update_data, optionals)
  Log.debug("rocket_silo_repository.update_rocket_silo_data")
  Log.info(update_data)
  Log.info(optionals)

  local return_val = Rocket_Silo_Data:new()

  if (not game) then return return_val end
  if (not update_data or not update_data.valid) then return return_val end
  if (not update_data.surface or not update_data.surface.valid) then return return_val end

  optionals = optionals or {}

  local planet_name = update_data.surface.name
  if (not planet_name) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = Satellite_Meta_Data:new()
    Satellite_Meta_Data.save_satellite_meta_data(planet_name)
  end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos) then storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos = {} end

  local rocket_silos = storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos

  return_val = rocket_silos[update_data.unit_number]

  for k,v in pairs(update_data) do
    return_val[k] = v
  end

  return_val.updated = game.tick

  return return_val
end

function rocket_silo_repository.delete_rocket_silo_data_by_unit_number(planet_name, unit_number, optionals)
  Log.debug("rocket_silo_repository.delete_rocket_silo_data_by_unit_number")
  Log.info(planet_name)
  Log.info(unit_number)
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end
  if (not planet_name) then return return_val end
  if (not unit_number) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = Satellite_Meta_Data:new()
    Satellite_Meta_Data.save_satellite_meta_data(planet_name)
  end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos) then storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos = {} end

  local rocket_silos = storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos

  rocket_silos[unit_number] = nil

  return_val = true

  return return_val
end

function rocket_silo_repository.get_rocket_silo_data(planet_name, unit_number, optionals)
  Log.debug("rocket_silo_repository.get_charaget_rocket_silo_datacter_data")
  Log.info(planet_name)
  Log.info(unit_number)
  Log.info(optionals)

  local return_val = Rocket_Silo_Data:new()

  if (not game) then return return_val end
  if (not planet_name) then return return_val end
  if (not unit_number) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data) then storage.all_seeing_satellite.satellite_meta_data = {} end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name]) then
    -- If it doesn't exist, generate it
    storage.all_seeing_satellite.satellite_meta_data[planet_name] = Satellite_Meta_Data:new()
    Satellite_Meta_Data.save_satellite_meta_data(planet_name)
  end
  if (not storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos) then storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos = {} end

  local rocket_silos = storage.all_seeing_satellite.satellite_meta_data[planet_name].rocket_silos

  return rocket_silos[unit_number]
end

rocket_silo_repository.all_seeing_satellite = true

local _rocket_silo_repository = rocket_silo_repository

return rocket_silo_repository
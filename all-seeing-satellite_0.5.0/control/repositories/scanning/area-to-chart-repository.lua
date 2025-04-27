-- If already defined, return
if _area_to_chart_repository and _area_to_chart_repository.all_seeing_satellite then
  return _area_to_chart_repository
end

local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")
local Area_To_Chart_Data = require("control.data.scanning.area-to-chart-data")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")

local area_to_chart_repository = {}

function area_to_chart_repository.save_area_to_chart_data(data, optionals)
  Log.debug("area_to_chart_repository.save_area_to_chart_data")
  Log.info(data)
  Log.info(optionals)

  local return_val = Area_To_Chart_Data:new()

  if (not game) then return return_val end
  if (not data or type(data) ~= "table") then return return_val end
  if (not data.area) then return return_val end
  if (not data.area.left_top or not data.area.right_bottom) then return return_val end
  if (not data.area.left_top.x or not data.area.left_top.y) then return return_val end
  if (not data.area.right_bottom.x or not data.area.right_bottom.y) then return return_val end
  if (not data.player_index) then return return_val end
  if (not data.surface) then return return_val end

  optionals = optionals or { mode = Constants.optionals.mode.DEFAULT.mode }

  local surface = data.surface
  if (not surface or not surface.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart

  local center = {
    x = (data.area.left_top.x + data.area.right_bottom.x) / 2,
    y = (data.area.left_top.y + data.area.right_bottom.y) / 2
  }

  local radius = math.floor(math.sqrt((center.x - data.area.right_bottom.x)^2 + (center.y - data.area.right_bottom.y)^2) / Constants.CHUNK_SIZE)

  return_val.area = data.area
  return_val.center = center
  return_val.id = game.tick
  return_val.player_index = data.player_index
  return_val.pos = { x = center.x, y = center.y, }
  return_val.radius = radius
  return_val.surface = data.surface
  return_val.surface_index = surface.index
  return_val.valid = true

  table.insert(staged_areas_to_chart, return_val)

  return area_to_chart_repository.update_area_to_chart_data(return_val)
end

function area_to_chart_repository.update_area_to_chart_data(update_data, index, optionals)
  Log.debug("area_to_chart_repository.update_area_to_chart_data")
  Log.info(update_data)
  Log.info(index)
  Log.info(optionals)

  local return_val = Area_To_Chart_Data:new()

  if (not game) then return return_val end
  if (not update_data or type(update_data) ~= "table") then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart
  -- Use the provided index if it exists; otherwise update the most recently added area
  -- index = index or table_size(staged_areas_to_chart)
  index = index or #staged_areas_to_chart

  for i, area_to_chart in pairs(staged_areas_to_chart) do
    if (i == index) then return_val = area_to_chart; break end
  end

  for k,v in pairs(update_data) do
    return_val[k] = v
  end

  return_val.updated = game.tick

  return return_val
end

function area_to_chart_repository.delete_area_to_chart_data(data, optionals)
  Log.debug("area_to_chart_repository.delete_area_to_chart_data")
  Log.info(data)
  Log.info(optionals)

  local return_val = false

  if (not data or type(data) ~= "table") then return return_val end
  if (not data.pos or type(data.pos) ~= "number") then return return_val end
  if (not game) then return return_val end

  local index_pos = data.pos
  if (index_pos < 1) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart

  -- if (index_pos > table_size(staged_areas_to_chart)) then return return_val end
  if (index_pos > #staged_areas_to_chart) then return return_val end

  table.remove(staged_areas_to_chart, index_pos)
  return_val = true

  return return_val
end

function area_to_chart_repository.delete_area_to_chart_data_by_id(id, optionals)
  Log.debug("area_to_chart_repository.delete_area_to_chart_data_by_id")
  Log.info(id)
  Log.info(optionals)

  local return_val = false

  if (not id or type(id) ~= "number") then return return_val end
  if (not game) then return return_val end

  if (id < 1) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart

  for k, area_to_chart_data in pairs(staged_areas_to_chart) do
    if (area_to_chart_data.id == id) then
      staged_areas_to_chart[k] = nil
      return_val = true
      break
    end
  end

  return return_val
end

function area_to_chart_repository.get_area_to_chart_data(optionals)
  Log.debug("area_to_chart_repository.get_area_to_chart_data")
  Log.info(optionals)

  local return_val = Area_To_Chart_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart

  for _, v in pairs(staged_areas_to_chart) do
    return_val = v
    if (optionals.mode == Constants.optionals.mode.queue) then break end
  end

  return return_val
end

function area_to_chart_repository.get_area_to_chart_data_by_index(data, optionals)
  Log.debug("area_to_chart_repository.get_area_to_chart_data_by_index")
  Log.info(data)
  Log.info(optionals)

  local return_val = Area_To_Chart_Data:new()

  if (not data or type(data) ~= "table") then return return_val end
  if (not data.pos or type(data.pos) ~= "number") then return return_val end
  if (not game) then return return_val end

  local index_pos = data.pos
  if (index_pos < 1) then
    index_pos = 1
  end

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart

  -- if (index_pos > table_size(staged_areas_to_chart)) then return return_val end
  if (index_pos > #staged_areas_to_chart) then return return_val end

  for i, area_to_chart in pairs(staged_areas_to_chart) do
    if (i == index_pos) then return_val = area_to_chart; break end
  end

  return return_val
end

function area_to_chart_repository.get_all_area_to_chart_data(optionals)
  Log.debug("area_to_chart_repository.get_all_area_to_chart_data")
  Log.info(optionals)

  local return_val = {}

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  return storage.all_seeing_satellite.staged_areas_to_chart
end

area_to_chart_repository.all_seeing_satellite = true

local _area_to_chart_repository = area_to_chart_repository

return area_to_chart_repository
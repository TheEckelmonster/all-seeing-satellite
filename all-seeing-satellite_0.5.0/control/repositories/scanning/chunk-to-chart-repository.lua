-- If already defined, return
if _chunk_to_chart_repository and _chunk_to_chart_repository.all_seeing_satellite then
  return _chunk_to_chart_repository
end

local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")
local Chunk_To_Chart_Data = require("control.data.scanning.chunk-to-chart-data")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")

local chunk_to_chart_repository = {}

function chunk_to_chart_repository.save_chunk_to_chart_data(data, optionals)
  Log.warn("chunk_to_chart_repository.save_chunk_to_chart_data")
  Log.warn(data)
  Log.info(optionals)

  local return_val = Chunk_To_Chart_Data:new()

  if (not game) then return return_val end
  local tick = game.tick
  if (not data or type(data) ~= "table") then return return_val end
  if (not data.chunk_to_chart) then return return_val end
  local chunk_to_chart = data.chunk_to_chart
  if (not chunk_to_chart.valid) then return end
  -- if (not data.area) then return return_val end
  -- if (not data.player_index) then return return_val end
  -- if (not data.surface) then return return_val end
  if (not data.pos) then return return_val end
  if (not data.pos.x or not data.pos.y) then return return_val end
  if (not data.i) then return return_val end
  if (not data.j) then return return_val end

  optionals = optionals or {}

  local surface = chunk_to_chart.surface
  if (not surface or not surface.valid) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart[tick]) then storage.all_seeing_satellite.staged_chunks_to_chart[tick] = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart[tick]

  -- local center = {
  --   x = (data.area.left_top.x + data.area.right_bottom.x) / 2,
  --   y = (data.area.left_top.y + data.area.right_bottom.y) / 2
  -- }

  -- local radius = math.floor(math.sqrt((center.x - event.area.right_bottom.x)^2 + (center.y - event.area.right_bottom.y)^2) / 16)

  return_val[optionals.mode] = { i = data.i, j = data.j, }

  return_val.area = chunk_to_chart.area
  return_val.center = chunk_to_chart.center
  return_val.id = game.tick
  return_val.parent_id = chunk_to_chart.id
  return_val.player_index = chunk_to_chart.player_index
  -- return_val.pos = { x = center.x, y = center.y, }
  return_val.pos = data.pos
  return_val.radius = chunk_to_chart.radius
  return_val.surface = surface
  return_val.surface_index = surface.index
  return_val.valid = true

  table.insert(staged_chunks_to_chart, return_val)
  -- table.insert(storage.all_seeing_satellite.staged_chunks_to_chart[tick], chunk_to_chart)

  return chunk_to_chart_repository.update_chunk_to_chart_data(return_val)
end

function chunk_to_chart_repository.update_chunk_to_chart_data(update_data, index, optionals)
  Log.warn("chunk_to_chart_repository.update_chunk_to_chart_data")
  Log.debug(update_data)
  Log.info(index)
  Log.info(optionals)

  local return_val = Chunk_To_Chart_Data:new()

  if (not game) then return return_val end
  if (not update_data or type(update_data) ~= "table") then return return_val end

  optionals = optionals or {}

  local tick = game.tick

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart[tick]) then storage.all_seeing_satellite.staged_chunks_to_chart[tick] = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart[tick]
  -- Use the provided index if it exists; otherwise update the most recently added chunk
  -- index = index or table_size(staged_chunks_to_chart)
  index = index and index >= 1 and index <= #staged_chunks_to_chart and index or #staged_chunks_to_chart

  for i, chunk_to_chart in pairs(staged_chunks_to_chart) do
    if (i == index) then return_val = chunk_to_chart; break end
  end

  if (not return_val.valid) then return return_val end

  for k,v in pairs(update_data) do
    return_val[k] = v
  end

  return_val.updated = tick

  return return_val
end

-- function storage_service.remove_chunk_to_chart_from_stage(optionals)
--   Log.debug("storage_service.remove_chunk_to_chart_from_stage")
--   optionals = optionals or {
--    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
--   }

--   if (not storage) then return end
--   if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
--     Initialization.reinit()
--     return
--   end

--   if (not storage.all_seeing_satellite.staged_chunks_to_chart) then return end

--   if (table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
--     if (optionals.mode == Constants.optionals.mode.queue) then
--       for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
--         storage.all_seeing_satellite.staged_chunks_to_chart[k] = nil
--         break
--       end
--     else
--       local obj = {}
--       for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
--         obj.k = k
--         obj.v = storage.all_seeing_satellite.staged_chunks_to_chart[k]
--         break
--       end
--       storage.all_seeing_satellite.staged_chunks_to_chart[obj.k] = nil
--     end
--   end

--   return storage.all_seeing_satellite.staged_chunks_to_chart
-- end

function chunk_to_chart_repository.delete_chunk_to_chart_data(optionals)
  Log.debug("chunk_to_chart_repository.delete_chunk_to_chart_data")
  Log.info(optionals)

  local return_val = false

  if (not game) then return return_val end

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart

  if (table_size(staged_chunks_to_chart) > 0) then
    if (optionals.mode == Constants.optionals.mode.queue) then
      for k, v in pairs(staged_chunks_to_chart) do
        staged_chunks_to_chart[k] = nil
        return_val = true
        break
      end
    else
      local obj = {}
      for k, v in pairs(staged_chunks_to_chart) do
        obj.k = k
        obj.v = staged_chunks_to_chart[k]
        -- break
      end
      staged_chunks_to_chart[obj.k] = nil
      return_val = true
    end
  end

  return staged_chunks_to_chart
end

function chunk_to_chart_repository.delete_chunk_to_chart_data_by_index(data, optionals)
  Log.debug("chunk_to_chart_repository.delete_chunk_to_chart_data_by_index")
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
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart

  if (index_pos > table_size(staged_chunks_to_chart)) then return return_val end

  table.remove(staged_chunks_to_chart, index_pos)
  return_val = true

  return return_val
end

function chunk_to_chart_repository.get_chunk_to_chart_data(optionals)
  Log.debug("chunk_to_chart_repository.get_chunk_to_chart_data")
  Log.info(optionals)

  local return_val = Chunk_To_Chart_Data:new()

  if (not game) then return return_val end

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart

  -- if (table_size(staged_chunks_to_chart) > 0) then
    -- Log.warn("staged_chunks_to_chart: found something to chart; mode = " .. serpent.line(optionals.mode))
    for _, v in pairs(staged_chunks_to_chart) do
      return_val = v
      if (optionals.mode == Constants.optionals.mode.queue) then break end
    end
  -- else
  --   Log.info("didn't find anything to chart")
  -- end

  return return_val
end

function chunk_to_chart_repository.get_chunk_to_chart_data_by_index(data, optionals)
  Log.debug("chunk_to_chart_repository.get_chunk_to_chart_data")
  Log.info(data)
  Log.info(optionals)

  local return_val = Chunk_To_Chart_Data:new()

  if (not data or type(data) ~= "table") then return return_val end
  if (not data.pos or type(data.pos) ~= "number") then return return_val end
  if (not game) then return return_val end

  local index_pos = data.pos
  if (index_pos < 1) then
    index_pos = 1
  end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = All_Seeing_Satellite_Data:new() end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local staged_chunks_to_chart = storage.all_seeing_satellite.staged_chunks_to_chart

  -- if (index_pos > table_size(staged_chunks_to_chart)) then return return_val end
  if (index_pos > #staged_chunks_to_chart) then return return_val end

  for i, chunks_to_chart in pairs(staged_chunks_to_chart) do
    if (i == index_pos) then return_val = chunks_to_chart; break end
  end

  return return_val
end

function chunk_to_chart_repository.get_all_chunk_to_chart_data(optionals)
  Log.debug("chunk_to_chart_repository.get_all_chunk_to_chart_data")
  Log.info(optionals)

  local return_val = {}

  if (not game) then return return_val end

  optionals = optionals or {}

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite) then storage.all_seeing_satellite = {} end
  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  return storage.all_seeing_satellite.staged_chunks_to_chart
end

chunk_to_chart_repository.all_seeing_satellite = true

local _chunk_to_chart_repository = chunk_to_chart_repository

return chunk_to_chart_repository
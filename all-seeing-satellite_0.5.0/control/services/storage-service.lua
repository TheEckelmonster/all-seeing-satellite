-- If already defined, return
if _storage_service and _storage_service.all_seeing_satellite then
  return _storage_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Initialization = require("control.initialization")
local Settings_Service = require("control.services.settings-service")

local storage_service = {}

function storage_service.stage_area_to_chart(event, optionals)
  Log.debug("storage_service.stage_area_to_chart")

  local optionals = optionals or { mode = Constants.optionals.mode.DEFAULT.mode }

  if (not event.tick) then return end
  if (not event.area or not event.area.left_top or not event.area.right_bottom) then return end
  if (not event.area.left_top.x or not event.area.left_top.y) then return end
  if (not event.area.right_bottom.x or not event.area.right_bottom.y) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  Log.debug("adding area to staged_areas_to_chart")
  Log.info(event.area)

  local center = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }

  local radius = math.floor(math.sqrt((center.x - event.area.right_bottom.x)^2 + (center.y - event.area.right_bottom.y)^2) / 16)

  local area_to_chart = {
    id = event.tick,
    valid = true,
    area = event.area,
    player_index = event.player_index,
    surface = event.surface,
    center = center,
    radius = radius,
    pos = {
      x = center.x,
      y = center.y,
    },
    started = false,
    complete = false,
    -- mode = optionals.mode
    -- i = 0,
    -- j = 0,
  }

  area_to_chart[optionals.mode] = {
    i = 0,
    j = 0,
  }

  storage.all_seeing_satellite.staged_areas_to_chart[area_to_chart.id] = area_to_chart

  -- if (not storage.all_seeing_satellite.staged_areas_to_chart_dictionary) then storage.all_seeing_satellite.staged_areas_to_chart_dictionary = {} end

  -- storage.all_seeing_satellite.staged_areas_to_chart_dictionary[event.tick] = area_to_chart
end

---
-- @param id -> The tick the area was selected by a given player
function storage_service.get_area_to_chart_by_id(id)
  Log.debug("storage_service.get_area_to_chart_by_id")
  Log.info(id)

  local return_val = { valid = false }

  if (not id or id < 0) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart_dictionary) then storage.all_seeing_satellite.staged_areas_to_chart_dictionary = {} end

  return_val.obj = storage.all_seeing_satellite.staged_areas_to_chart_dictionary[id]
  return_val.valid = true

  return return_val
end

function storage_service.get_area_to_chart(optionals)
  Log.debug("storage_service.get_area_to_chart")

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  local return_val = { valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return return_val end

  if (optionals and optionals.mode == Constants.optionals.mode.stack and table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    Log.warn("found something to chart; mode = stack")
    for _, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
      return_val.obj = v
    end
    return_val.valid = true
  elseif (optionals and optionals.mode == Constants.optionals.mode.queue and table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    Log.warn("found something to chart; mode = queue")
    for _, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
      return_val.obj = v
      break
    end
    return_val.valid = true
  else
    Log.debug("didn't find anything to chart")
  end

  return return_val
end

function storage_service.remove_area_to_chart_from_stage(optionals)
  Log.debug("storage_service.remove_area_to_chart_from_stage")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return end

  if (table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    if (optionals.mode == Constants.optionals.mode.stack.queue) then
      for k, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
        storage.all_seeing_satellite.staged_areas_to_chart[k] = nil
        break
      end
    else
      local obj = {}
      for k, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
        obj.k = k
        obj.v = storage.all_seeing_satellite.staged_areas_to_chart[k]
      end
      storage.all_seeing_satellite.staged_areas_to_chart[obj.k] = nil
    end
  end
end

function storage_service.remove_area_to_chart_from_stage_by_id(id, optionals)
  Log.debug("storage_service.remove_area_to_chart_from_stage_by_id")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end
  if (not id or id < 0) then return end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return end

  storage.all_seeing_satellite.staged_areas_to_chart[id] = nil
end

function storage_service.stage_chunk_to_chart(area_to_chart, center, i, j, optionals)
  Log.debug("storage_service.stage_chunk_to_chart")
  if (not area_to_chart or not area_to_chart.valid) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local tick = 0
  if (game) then tick = game.tick end
  if (not tick) then tick = 0 end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart[tick]) then storage.all_seeing_satellite.staged_chunks_to_chart[tick] = {} end

  local chunk_to_chart = {
    parent_id = area_to_chart.id,
    id = tick,
    valid = area_to_chart.valid,
    area = area_to_chart.area,
    player_index = area_to_chart.player_index,
    surface = area_to_chart.surface,
    center = area_to_chart.center,
    radius = area_to_chart.radius,
    pos = {
      x = center.x,
      y = center.y,
    },
    -- i = i,
    -- j = j,
    -- optionals.mode = {
    --   i = i,
    --   j = j,
    -- }
  }

  chunk_to_chart[optionals.mode] = {
    i = i,
    j = j,
  }

  table.insert(storage.all_seeing_satellite.staged_chunks_to_chart[tick], chunk_to_chart)
end

function storage_service.get_staged_chunk_to_chart(optionals)
  Log.debug("storage_service.get_staged_chunk_to_chart")

  optionals = optionals or {
    mode = Constants.optionals.mode.stack
  }

  local return_val = { valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  if (optionals and optionals.mode == Constants.optionals.mode.stack and table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    Log.warn("found something to chart; mode = stack")
    for _, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
      return_val.obj = v
    end
    return_val.valid = true
  elseif (optionals and optionals.mode == Constants.optionals.mode.queue and table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    Log.warn("found something to chart; mode = queue")
    for _, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
      return_val.obj = v
      break
    end
    return_val.valid = true
  else
    Log.debug("didn't find anything to chart")
  end

  return return_val
end

function storage_service.remove_chunk_to_chart_from_stage(optionals)
  Log.debug("storage_service.remove_chunk_to_chart_from_stage")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then return end

  if (table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    if (optionals.mode == Constants.optionals.mode.queue) then
      for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
        storage.all_seeing_satellite.staged_chunks_to_chart[k] = nil
        break
      end
    else
      local obj = {}
      for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
        obj.k = k
        obj.v = storage.all_seeing_satellite.staged_chunks_to_chart[k]
      end
      storage.all_seeing_satellite.staged_chunks_to_chart[obj.k] = nil
    end
  end
end

function storage_service.remove_chunk_to_chart_from_stage_by_id(id, optionals)
  Log.debug("storage_service.remove_chunk_to_chart_from_stage_by_id")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not id or id < 0) then return end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then return end

  storage.all_seeing_satellite.staged_chunks_to_chart[id] = nil
end

function storage_service.mod_settings_changed()
  Log.debug("storage_service.mod_settings_changed")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  storage.all_seeing_satellite.have_mod_settings_changed = true
end

function storage_service.have_mod_settings_changed()
  Log.debug("storage_service.have_mod_settings_changed")
  local return_val = false

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end

  if (storage.all_seeing_satellite.have_mod_settings_changed) then return_val = true end

  return return_val
end

function storage_service.get_scan_in_progress()
  Log.debug("storage_service.get_scan_in_progress")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (storage.all_seeing_satellite.scan_in_progress == nil) then storage.all_seeing_satellite.scan_in_progress = false end

  return storage.all_seeing_satellite.scan_in_progress
end

function storage_service.set_scan_in_progress(set_val)
  Log.debug("storage_service.have_mod_settings_changed")

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  storage.all_seeing_satellite.scan_in_progress = set_val
end

storage_service.all_seeing_satellite = true

local _storage_service = storage_service

return storage_service
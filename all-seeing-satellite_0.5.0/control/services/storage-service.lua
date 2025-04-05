-- If already defined, return
if _storage_service and _storage_service.all_seeing_satellite then
  return _storage_service
end

local Log = require("libs.log.log")
local Initialization = require("control.initialization")
local Planet_Utils = require("control.utils.planet-utils")

local storage_service = {}

function storage_service.stage_area_to_chart(area)
  if (not area or not area.left_top or not area.right_bottom) then return end
  if (not area.left_top.x or not area.left_top.y) then return end
  if (not area.right_bottom.x or not area.right_bottom.y) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart
  if (not staged_areas_to_chart) then staged_areas_to_chart = {} end

  Log.debug("adding area to staged_areas_to_chart")
  Log.info(area)
  table.insert(staged_areas_to_chart, {
    area = area,
    center = {
      x = (area.left_top.x + area.right_bottom.x) / 2,
      y = (area.left_top.y + area.right_bottom.y) / 2
    }
  })

  storage.all_seeing_satellite.staged_areas_to_chart = staged_areas_to_chart

  -- game.forces[event.player_index].chart(event.surface, selected_area)
end

function storage_service.get_area_to_chart()
  local return_val = { valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return return_val end

  if (#storage.all_seeing_satellite.staged_areas_to_chart > 0) then
    return_val.area = storage.all_seeing_satellite.staged_areas_to_chart[1]
    return_val.valid = true
  end

  return return_val
end

storage_service.all_seeing_satellite = true

local _storage_service = storage_service

return storage_service
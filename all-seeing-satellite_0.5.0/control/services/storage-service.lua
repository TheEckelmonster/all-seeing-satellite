-- If already defined, return
if _storage_service and _storage_service.all_seeing_satellite then
  return _storage_service
end

local Log = require("libs.log.log")
local Initialization = require("control.initialization")
local Planet_Utils = require("control.utils.planet-utils")

local storage_service = {}

function storage_service.stage_area_to_chart(area)
  Log.error(area)
  if (not area or not area.left_top or not area.right_bottom) then return end
  if (not area.left_top.x or area.left_top.y) then return end
  if (not area.right_bottom.x or area.right_bottom.y) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then Initialization.reinit() end

  table.insert(storage.all_seeing_satellite.staged_areas_to_chart, {
    area = area,
    center = {
      x = (area.left_top.x + area.right_bottom.x) / 2,
      y = (area.left_top.y + area.right_bottom.y) / 2
    }
  })

  -- game.forces[event.player_index].chart(event.surface, selected_area)
end

storage_service.all_seeing_satellite = true

local _storage_service = storage_service

return storage_service
-- If already defined, return
if _storage_service and _storage_service.all_seeing_satellite then
  return _storage_service
end

local Log = require("libs.log.log")
local Initialization = require("control.initialization")

local storage_service = {}

function storage_service.stage_area_to_chart(event)
  Log.debug("storage_service.stage_area_to_chart")
  if (not event.area or not event.area.left_top or not event.area.right_bottom) then return end
  if (not event.area.left_top.x or not event.area.left_top.y) then return end
  if (not event.area.right_bottom.x or not event.area.right_bottom.y) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  local staged_areas_to_chart = storage.all_seeing_satellite.staged_areas_to_chart
  if (not staged_areas_to_chart) then staged_areas_to_chart = {} end

  Log.debug("adding area to staged_areas_to_chart")
  Log.info(event.area)

  local center = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }

  -- local width = math.abs(math.abs(event.area.left_top.x) - math.abs(event.area.right_bottom.x))/2
  -- local length = math.abs(math.abs(event.area.left_top.y) - math.abs(event.area.right_bottom.y))/2
  local width = math.abs(event.area.right_bottom.x - center.x)
  local length = math.abs(event.area.right_bottom.y - center.y)

  table.insert(staged_areas_to_chart, {
    area = event.area,
    player_index = event.player_index,
    surface = event.surface,
    center = center,
    radius = width < length and width or length,
    current_radius_length = 0,
    complete = false
  })

  -- Pretty sure this isn't necessary; but not 100% sure
  storage.all_seeing_satellite.staged_areas_to_chart = staged_areas_to_chart
end

function storage_service.get_area_to_chart()
  Log.debug("storage_service.get_area_to_chart")
  local return_val = { valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end
  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return return_val end

  if (#storage.all_seeing_satellite.staged_areas_to_chart > 0) then
    Log.debug("found something to chart")
    return_val.obj = storage.all_seeing_satellite.staged_areas_to_chart[#storage.all_seeing_satellite.staged_areas_to_chart]
    return_val.valid = true
  end

  return return_val
end

function storage_service.remove_area_to_chart_from_stage(optional)
  Log.debug("storage_service.remove_area_to_chart_from_stage")
  optional = optional or {
   mode = "stack"
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return end

  if (#storage.all_seeing_satellite.staged_areas_to_chart > 0) then
    if (optional.mode == "queue") then
      table.remove(storage.all_seeing_satellite.staged_areas_to_chart, 1)
    else
      table.remove(storage.all_seeing_satellite.staged_areas_to_chart, #storage.all_seeing_satellite.staged_areas_to_chart)
    end
  end

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

storage_service.all_seeing_satellite = true

local _storage_service = storage_service

return storage_service
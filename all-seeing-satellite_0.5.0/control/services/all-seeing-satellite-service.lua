-- If already defined, return
if _all_seeing_satellite_service and _all_seeing_satellite_service.all_seeing_satellite then
  return _all_seeing_satellite_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Scan_Chunk_Service = require("control.services.scan-chunk-service")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")

local all_seeing_satellite_service = {}

function all_seeing_satellite_service.check_for_areas_to_stage()
  Log.debug("all_seeing_satellite_service.check_for_areas_to_stage")

  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode,
  }

  -- TODO: Make the mode a configurable user setting
  local return_val = Storage_Service.get_area_to_chart(optionals)
  if (not return_val or not return_val.obj or not return_val.valid) then
    return_val = Storage_Service.get_area_to_chart({ mode = Constants.optionals.mode.queue })
    if (not return_val or not return_val.obj or not return_val.valid) then return end
  end
  Log.debug(return_val)
  local area_to_chart = return_val.obj

  if (not Planet_Utils.allow_toggle(area_to_chart.surface.name)) then return end

  if (not area_to_chart.started) then
    area_to_chart.started = true
  end

  -- optionals.i = area_to_chart.i
  -- optionals.j = area_to_chart.j
  if (not area_to_chart[optionals.mode]) then area_to_chart[optionals.mode] = { i = 0, j = 0 } end

  optionals.i = area_to_chart[optionals.mode].i
  optionals.j = area_to_chart[optionals.mode].j

  -- Scan_Chunk_Service.stage_selected_area(area_to_chart, optionals)
  Scan_Chunk_Service.stage_selected_area(area_to_chart, optionals)

  if (area_to_chart.complete) then
    Log.error("removing area")
    -- TODO: Make the mode a configurable user setting
    Storage_Service.remove_area_to_chart_from_stage_by_id(area_to_chart.id, optionals)
  end
end

function all_seeing_satellite_service.do_scan()
  Log.debug("all_seeing_satellite_service.do_scan")
  -- TODO: Make the mode a configurable user setting
  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  local return_val = Storage_Service.get_staged_chunk_to_chart(optionals)
  if (not return_val or not return_val.obj or not return_val.valid) then
    return_val = Storage_Service.get_staged_chunk_to_chart({ mode = Constants.optionals.mode.queue })
    if (not return_val or not return_val.obj or not return_val.valid) then return end
  end
  Log.debug(return_val)
  local area_to_chart = return_val.obj

  for k, v in pairs(area_to_chart) do
    Log.warn(k)
    Log.warn(v)

    if (Planet_Utils.allow_toggle(v.surface.name)) then
      Scan_Chunk_Service.scan_selected_chunk(v)
    end
  end
  -- TODO: Make this configurable
  Storage_Service.remove_chunk_to_chart_from_stage(optionals)
end

all_seeing_satellite_service.all_seeing_satellite = true

local _all_seeing_satellite_service = all_seeing_satellite_service

return all_seeing_satellite_service
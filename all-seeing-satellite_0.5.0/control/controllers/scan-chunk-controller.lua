-- If already defined, return
if _scan_chunk_controller and _scan_chunk_controller.all_seeing_satellite then
  return _scan_chunk_controller
end

local All_Seeing_Satellite_Repository = require("control.repositories.all-seeing-satellite-repository")
local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Scan_Chunk_Service = require("control.services.scan-chunk-service")
-- local Storage_Service = require("control.services.storage-service")

local scan_chunk_controller = {}

function scan_chunk_controller.stage_selected_chunks(event)
  Log.debug("scan_chunk_controller.stage_selected_chunk")
  Log.info(event)

  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.valid) then return end
  if (not all_seeing_satellite_data.do_nth_tick) then return end

  if (not event or not event.item or event.item ~= "satellite-scanning-remote") then return end
  if (not event.surface or not event.surface.valid) then return end
  -- No need to scan in space
  if (event.surface.platform ~= nil) then return end
  if (not event.player_index or not event.area) then return end
  if (not Planet_Utils.allow_scan(event.surface.name)) then return end

  -- Scan_Chunk_Service.-OLDstage_selected_chunk(event)
  Scan_Chunk_Service.stage_selected_area(event)
end

function scan_chunk_controller.clear_selected_chunks(event)
  Log.debug("scan_chunk_controller.clear_selected_chunks")
  Log.info(event)

  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.valid) then return end
  if (not all_seeing_satellite_data.do_nth_tick) then return end

  if (not event or not event.item or event.item ~= "satellite-scanning-remote") then return end
  if (not event.surface or not event.surface.valid) then return end
  -- No need to scan in space
  if (event.surface.platform ~= nil) then return end
  if (not event.player_index or not event.area) then return end
  if (not Planet_Utils.allow_scan(event.surface.name)) then return end

  Scan_Chunk_Service.clear_selected_chunks(event)
end

scan_chunk_controller.all_seeing_satellite = true

local _scan_chunk_controller = scan_chunk_controller

return scan_chunk_controller
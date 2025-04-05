-- If already defined, return
if _scan_chunk_service and _scan_chunk_service.all_seeing_satellite then
  return _scan_chunk_service
end

local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Storage_Service = require("control.services.storage-service")

local scan_chunk_service = {}

function scan_chunk_service.scan_selected_chunk(event)
  Log.info(event)
  if (not event or not event.item or not event.item == "satellite-targeting-remote") then return end
  if (not event.surface or not event.surface or not event.surface.valid) then return end
  if (not event.player_index or not event.area) then return end
  if (not Planet_Utils.allow_toggle(event.surface)) then return end

  Storage_Service.stage_area_to_chart(event.area)
end

scan_chunk_service.all_seeing_satellite = true

local _scan_chunk_service = scan_chunk_service

return scan_chunk_service
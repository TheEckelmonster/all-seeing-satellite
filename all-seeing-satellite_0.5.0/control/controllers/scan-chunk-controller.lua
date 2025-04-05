-- If already defined, return
if _scan_chunk_controller and _scan_chunk_controller.all_seeing_satellite then
  return _scan_chunk_controller
end

local Log = require("libs.log.log")
local Scan_Chunk_Service = require("control.services.scan-chunk-service")

local scan_chunk_controller = {}

function scan_chunk_controller.stage_selected_chunk(event)
  Log.debug("scan_chunk_controller.stage_selected_chunk")
  Log.info(event)
  Scan_Chunk_Service.stage_selected_chunk(event)
end

scan_chunk_controller.all_seeing_satellite = true

local _scan_chunk_controller = scan_chunk_controller

return scan_chunk_controller
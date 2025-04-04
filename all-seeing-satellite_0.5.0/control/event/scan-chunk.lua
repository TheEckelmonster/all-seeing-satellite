-- If already defined, return
if _scan_chunk and _scan_chunk.all_seeing_satellite then
  return _scan_chunk
end

local Log = require("libs.log.log")
local Planet_Utils = require("libs.utils.planet-utils")

local scan_chunk = {}

function scan_chunk.scan_selected_chunk(event)
  if (not event.item or not event.item == "satellite-targeting-remote") then return end
  Log.debug(event)

  
  if (not surface or not surface.valid) then return end
  
  -- surface.request_to_generate_chunks(selected_position)
  if (not event.player_index or not event.surface or not event.area) then return end
  if (not Planet_Utils.allow_toggle(event.surface)) then return end
  
  local selected_area = event.area
  local calc_position = {
    x = (math.abs(eselected_area.left_top.x) - math.abs(selected_area.right_bottom.x)) / 2,
    y = (math.abs(selected_area.left_top.y) - math.abs(selected_area.right_bottom.y)) / 2
  }
  
  if (calc_position.x > 32 * 1) then
    selected_area.left_top.x = selected_area.left_top.x / (32 * 1)
    selected_area.right_bottom.x = selected_area.right_bottom.x / (32 * 1)
  end

  if (calc_position.y > 32 * 1) then
    selected_area.left_top.y = selected_area.left_top.y / (32 * 1)
    selected_area.right_bottom.y = selected_area.right_bottom.y / (32 * 1)
  end

  game.forces[event.player_index].chart(event.surface, selected_area)
end

scan_chunk.all_seeing_satellite = true

local _scan_chunk = scan_chunk

return scan_chunk
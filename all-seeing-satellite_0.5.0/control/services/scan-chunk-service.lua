-- If already defined, return
if _scan_chunk_service and _scan_chunk_service.all_seeing_satellite then
  return _scan_chunk_service
end

local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Storage_Service = require("control.services.storage-service")

local scan_chunk_service = {}

function scan_chunk_service.stage_selected_chunk(event)
  Log.debug("scan_chunk_service.stage_selected_chunk")
  Log.info(event)
  if (not event or not event.item or not event.item == "satellite-targeting-remote") then return end
  if (not event.surface or not event.surface or not event.surface.valid) then return end
  if (not event.player_index or not event.area) then return end
  if (not Planet_Utils.allow_toggle(event.surface)) then return end

  Log.debug("staging area")
  Storage_Service.stage_area_to_chart(event)
end

function scan_chunk_service.scan_selected_chunk(area_to_chart)
  Log.debug("scan_chunk_service.scan_selected_chunk")
  Log.info(area_to_chart)
  if (not area_to_chart) then return end
  Log.debug("1")
  if (not game or not game.forces) then return end
  Log.debug("2")
  if (not area_to_chart.player_index or not game.forces[area_to_chart.player_index]) then return end
  Log.debug("3")
  if (not area_to_chart.surface) then return end
  Log.debug("4")
  if (not area_to_chart.center or not area_to_chart.center.x or not area_to_chart.center.y) then return end
  Log.warn("scanning")
  -- game.forces[area_to_chart.player_index].chart(
  --   area_to_chart.surface,
  --   {
  --     {
  --       area_to_chart.center.x - 32,
  --       area_to_chart.center.y - 32
  --     },
  --     {
  --       area_to_chart.center.x + 32,
  --       area_to_chart.center.y + 32
  --     }
  --   }
  -- )

  local radius = math.ceil(area_to_chart.radius / 32)

  for c=0, radius do
    for a=0, c do
      game.forces[area_to_chart.player_index].chart(
        area_to_chart.surface,
        {
          {
            (area_to_chart.center.x + 32 * a) - 32, (area_to_chart.center.y + 32 * math.sqrt(c^2 - a^2)) - 32
          },
          {
            (area_to_chart.center.x + 32 * a) + 32, (area_to_chart.center.y + 32 * math.sqrt(c^2 - a^2)) + 32
          }
        }
      )

      game.forces[area_to_chart.player_index].chart(
        area_to_chart.surface,
        {
          {
            (area_to_chart.center.x - 32 * a) - 32, (area_to_chart.center.y + 32 * math.sqrt(c^2 - a^2)) - 32
          },
          {
            (area_to_chart.center.x - 32 * a) + 32, (area_to_chart.center.y + 32 * math.sqrt(c^2 - a^2)) + 32
          }
        }
      )

      game.forces[area_to_chart.player_index].chart(
        area_to_chart.surface,
        {
          {
            (area_to_chart.center.x - 32 * a) - 32, (area_to_chart.center.y - 32 * math.sqrt(c^2 - a^2)) - 32
          },
          {
            (area_to_chart.center.x - 32 * a) + 32, (area_to_chart.center.y - 32 * math.sqrt(c^2 - a^2)) + 32
          }
        }
      )

      game.forces[area_to_chart.player_index].chart(
        area_to_chart.surface,
        {
          {
            (area_to_chart.center.x + 32 * a) - 32, (area_to_chart.center.y - 32 * math.sqrt(c^2 - a^2)) - 32
          },
          {
            (area_to_chart.center.x + 32 * a) + 32, (area_to_chart.center.y - 32 * math.sqrt(c^2 - a^2)) + 32
          }
        }
      )
    end
  end

  area_to_chart.complete = true

  return area_to_chart.complete
end

scan_chunk_service.all_seeing_satellite = true

local _scan_chunk_service = scan_chunk_service

return scan_chunk_service
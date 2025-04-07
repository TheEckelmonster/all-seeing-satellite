-- If already defined, return
if _scan_chunk_service and _scan_chunk_service.all_seeing_satellite then
  return _scan_chunk_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Settings_Service = require("control.services.settings-service")
local Storage_Service = require("control.services.storage-service")

local scan_chunk_service = {}

function scan_chunk_service.stage_selected_chunk(event)
  Log.debug("scan_chunk_service.stage_selected_chunk")
  Log.info(event)
  if (not event or not event.item or not event.item == "satellite-targeting-remote") then return end
  if (not event.surface or not event.surface or not event.surface.valid) then return end
  if (not event.player_index or not event.area) then return end
  if (not Planet_Utils.allow_toggle(event.surface)) then return end

  local optionals = { mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode }

  Log.debug("staging area")
  Storage_Service.stage_area_to_chart(event, optionals)
end

function scan_chunk_service.stage_selected_area(area_to_chart, optionals)
  Log.debug("scan_chunk_service.stage_selected_chunk")
  Log.info(area_to_chart)

  optionals = optionals or { mode = Settings_Service.get_satellite_scan_mode() }

  if (not area_to_chart) then return end
  Log.debug("1")
  if (not game or not game.forces) then return end
  Log.debug("2")
  if (not area_to_chart.player_index or not game.forces[area_to_chart.player_index]) then return end
  Log.debug("3")
  if (not area_to_chart.surface) then return end
  Log.debug("4")
  if (not area_to_chart.center or not area_to_chart.center.x or not area_to_chart.center.y) then return end
  Log.warn("staging chunk(s)")

  local radius = area_to_chart.radius

  if (optionals and optionals.i == nil) then optionals.i = 0 end
  if (optionals and optionals.j == nil) then optionals.j = 0 end

  Log.warn(area_to_chart)

  -- if (not area_to_chart.i or area_to_chart.i < 0 or optionals.i < 0) then return end
  -- if (not area_to_chart.j or area_to_chart.j < 0 or optionals.j < 0) then return end
  if (not area_to_chart[optionals.mode].i or area_to_chart[optionals.mode].i < 0 or optionals.i < 0) then return end
  if (not area_to_chart[optionals.mode].j or area_to_chart[optionals.mode].j < 0 or optionals.j < 0) then return end

  -- local i = area_to_chart.i >= 0 and area_to_chart.i <= radius and area_to_chart.i or optionals.i
  -- local j = area_to_chart.j >= 0 and area_to_chart.j <= radius and area_to_chart.j or optionals.j
  local i = area_to_chart[optionals.mode].i >= 0 and area_to_chart[optionals.mode].i <= radius and area_to_chart[optionals.mode].i or optionals.i
  local j = area_to_chart[optionals.mode].j >= 0 and area_to_chart[optionals.mode].j <= radius and area_to_chart[optionals.mode].j or optionals.j

  if (area_to_chart[optionals.mode].i > radius  or optionals.i > radius) then
    area_to_chart.complete = true
    return
  end

  local c = 0
  if (optionals.mode == Constants.optionals.mode.stack) then
    c = radius - i
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    c = i
  end

  if (optionals.mode == "stack") then
    if (area_to_chart[optionals.mode].j > c or optionals.j > c) then
      area_to_chart[optionals.mode].i = area_to_chart[optionals.mode].i + 1
      area_to_chart[optionals.mode].j = 0
      return
    end
  elseif (optionals.mode == "queue") then
    if (area_to_chart[optionals.mode].j > i or optionals.j > i) then
      area_to_chart[optionals.mode].i = area_to_chart[optionals.mode].i + 1
      area_to_chart[optionals.mode].j = 0
      return
    end
  end

  local a = 0
  if (optionals.mode == Constants.optionals.mode.stack) then
    if (j > c) then
      return
    end
    a = c - j
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    a = j
  end

  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * a), y = (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * a), y = (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * a), y = (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * a), y = (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) },
    i,
    j,
    optionals
  )

-- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
-- seems like overkill/unoptimal, though

  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + 16 * a) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + 16 * a) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - 16 * a) },
    i,
    j,
    optionals
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - 16 * a) },
    i,
    j,
    optionals
  )

  j = j + 1
  area_to_chart[optionals.mode].j = j

  Log.warn(storage.all_seeing_satellite)

  return area_to_chart.complete
end

function scan_chunk_service.scan_selected_chunk(area_to_chart, optionals)
  Log.debug("scan_chunk_service.scan_selected_chunk")
  Log.info(area_to_chart)

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

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

  Log.error(area_to_chart)

  game.forces[area_to_chart.player_index].chart(
    area_to_chart.surface, {
      {(area_to_chart.pos.x) - 16, (area_to_chart.pos.y) - 16},
      {(area_to_chart.pos.x) + 16, (area_to_chart.pos.y) + 16}
    })

  return area_to_chart.complete
end

scan_chunk_service.all_seeing_satellite = true

local _scan_chunk_service = scan_chunk_service

return scan_chunk_service
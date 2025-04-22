-- If already defined, return
if _scan_chunk_service and _scan_chunk_service.all_seeing_satellite then
  return _scan_chunk_service
end

local Area_To_Chart_Repository = require("control.repositories.scanning.area-to-chart-repository")
local Chunk_To_Chart_Repository = require("control.repositories.scanning.chunk-to-chart-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Settings_Service = require("control.services.settings-service")
-- local Storage_Service = require("control.services.storage-service")

local scan_chunk_service = {}

function scan_chunk_service.stage_selected_area(event)
  Log.debug("scan_chunk_service.stage_selected_area")
  Log.info(event)

  if (not event) then return end

  local optionals = { mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode }

  Log.debug("staging area")
  -- Storage_Service.stage_area_to_chart(event, optionals)
  Area_To_Chart_Repository.save_area_to_chart_data(event, optionals)
end

function scan_chunk_service.clear_selected_chunks(event)
  Log.error("scan_chunk_service.clear_selected_chunks")
  Log.warn(event)
end

function scan_chunk_service.stage_selected_chunk(area_to_chart, optionals)
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

  Log.debug(area_to_chart)

  if (not area_to_chart[optionals.mode]) then area_to_chart[optionals.mode] = {} end
  if (not area_to_chart[optionals.mode].i) then area_to_chart[optionals.mode].i = 0 end
  if (not area_to_chart[optionals.mode].j) then area_to_chart[optionals.mode].j = 0 end

  if (area_to_chart[optionals.mode].i < 0 or optionals.i < 0) then return end
  if (area_to_chart[optionals.mode].j < 0 or optionals.j < 0) then return end

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

  if (optionals.mode == Constants.optionals.mode.stack) then
    if (area_to_chart[optionals.mode].j > c or optionals.j > c) then
    -- if (area_to_chart[optionals.mode].j > i or optionals.j > i) then
      area_to_chart[optionals.mode].i = area_to_chart[optionals.mode].i + 1
      area_to_chart[optionals.mode].j = 0
      i = area_to_chart[optionals.mode].i
      j = 0
      -- return
    end
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    if (area_to_chart[optionals.mode].j > i or optionals.j > i) then
      area_to_chart[optionals.mode].i = area_to_chart[optionals.mode].i + 1
      area_to_chart[optionals.mode].j = 0
      i = area_to_chart[optionals.mode].i
      j = 0
      -- return
    end
  end

  local a = 0
  if (optionals.mode == Constants.optionals.mode.stack) then
    if (j > c) then
      -- return
      area_to_chart[optionals.mode].i = area_to_chart[optionals.mode].i + 1
      area_to_chart[optionals.mode].j = 0
      -- i = area_to_chart[optionals.mode].i
      -- j = 0
      return
    end
    a = c - j
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    a = j
  end

  -- TODO: Parameterize this
  local distance_modifier = 16

  if (i == 0 and j == 0 and optionals.mode == Constants.optionals.mode.queue) then
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x), y = (area_to_chart.center.y) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x), y = (area_to_chart.center.y) },
      i = i,
      j = j,
    }, optionals)
  elseif (i == 0 and j == 0 and optionals.mode == Constants.optionals.mode.stack) then
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x), y = (area_to_chart.center.y + distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x), y = (area_to_chart.center.y + distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x), y = (area_to_chart.center.y - distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x), y = (area_to_chart.center.y - distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
  else
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y + distance_modifier * math.sqrt(c^2 - a^2)) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y + distance_modifier * math.sqrt(c^2 - a^2)) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y + distance_modifier * math.sqrt(c^2 - a^2)) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y + distance_modifier * math.sqrt(c^2 - a^2)) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y - distance_modifier * math.sqrt(c^2 - a^2)) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x - distance_modifier * a), y = (area_to_chart.center.y - distance_modifier * math.sqrt(c^2 - a^2)) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y - distance_modifier * math.sqrt(c^2 - a^2)) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x + distance_modifier * a), y = (area_to_chart.center.y - distance_modifier * math.sqrt(c^2 - a^2)) },
      i = i,
      j = j,
    }, optionals)

  -- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
  -- seems like overkill/unoptimal, though
  -- TODO: Improve this

    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x + distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x + distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x - distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x - distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x - distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x - distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
    -- Storage_Service.stage_chunk_to_chart(
    --   area_to_chart,
    --   { x = (area_to_chart.center.x + distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - distance_modifier * a) },
    --   i,
    --   j,
    --   optionals
    -- )
    Chunk_To_Chart_Repository.save_chunk_to_chart_data({
      chunk_to_chart = area_to_chart,
      pos = { x = (area_to_chart.center.x + distance_modifier * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - distance_modifier * a) },
      i = i,
      j = j,
    }, optionals)
  end

  if (optionals.mode == Constants.optionals.mode.stack) then
    -- if (i == 0 and j == 0) then
      -- j = j + math.pi/4
    -- else
      j = j + 1
    -- end
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    j = j + 1
  end

  -- j = j + 1
  area_to_chart[optionals.mode].j = j

  Log.debug(storage.all_seeing_satellite)

  return area_to_chart.complete
end

function scan_chunk_service.scan_selected_chunk(chunk_to_chart, optionals)
  Log.warn("scan_chunk_service.scan_selected_chunk")
  Log.warn(chunk_to_chart)

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  local return_val = false

  if (not chunk_to_chart) then return return_val end
  Log.warn("1")
  if (not game or not game.forces) then return return_val end
  Log.warn("2")
  if (not chunk_to_chart.player_index or not game.forces[chunk_to_chart.player_index]) then return return_val end
  Log.warn("3")
  if (not chunk_to_chart.surface) then return return_val end
  Log.warn("4")
  if (not chunk_to_chart.pos or not chunk_to_chart.pos.x or not chunk_to_chart.pos.y) then return return_val end
  Log.warn("scanning")

  Log.info(chunk_to_chart)

  -- TODO: Parameterize this
  local distance_modifier = 16

  game.forces[chunk_to_chart.player_index].chart(
    chunk_to_chart.surface, {
      {(chunk_to_chart.pos.x) - distance_modifier, (chunk_to_chart.pos.y) - distance_modifier},
      {(chunk_to_chart.pos.x) + distance_modifier, (chunk_to_chart.pos.y) + distance_modifier}
    })

  return_val = true
  return return_val
end

scan_chunk_service.all_seeing_satellite = true

local _scan_chunk_service = scan_chunk_service

return scan_chunk_service
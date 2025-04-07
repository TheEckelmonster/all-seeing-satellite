-- If already defined, return
if _scan_chunk_service and _scan_chunk_service.all_seeing_satellite then
  return _scan_chunk_service
end

local Constants = require("libs.constants.constants")
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

  local optionals = { mode = Constants.optionals.DEFAULT.mode }

  Log.debug("staging area")
  Storage_Service.stage_area_to_chart(event, optionals)
end

function scan_chunk_service.stage_selected_area(area_to_chart, optionals)
  Log.debug("scan_chunk_service.stage_selected_chunk")
  Log.info(area_to_chart)

  optionals = optionals or { mode = Constants.optionals.DEFAULT.mode }

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

  -- local radius = math.floor(area_to_chart.radius / 16)
  local radius = area_to_chart.radius

  -- if (optionals.mode == Constants.optionals.mode.stack) then
  --   if (optionals and optionals.i == nil) then optionals.i = radius end
  --   if (optionals and optionals.j == nil) then optionals.j = radius end
  -- elseif (optionals.mode == Constants.optionals.mode.queue) then
    if (optionals and optionals.i == nil) then optionals.i = 0 end
    if (optionals and optionals.j == nil) then optionals.j = 0 end
  -- end

  -- for i=0, radius do
  --   local c = 0
  --   if (optionals.mode == "stack") then
  --     c = radius - i
  --   elseif (optionals.mode == "queue")
  --     c = i
  --   end
  -- local i = math.sqrt((area_to_chart.center.x - area_to_chart.pos.x)^2 + (area_to_chart.center.y - area_to_chart.pos.y)^2)

  Log.warn(area_to_chart)

  if (not area_to_chart.i or area_to_chart.i < 0 or optionals.i < 0) then return end
  if (not area_to_chart.j or area_to_chart.j < 0 or optionals.j < 0) then return end

  local i = area_to_chart.i >= 0 and area_to_chart.i <= radius and area_to_chart.i or optionals.i
  local j = area_to_chart.j >= 0 and area_to_chart.j <= radius and area_to_chart.j or optionals.j

  Log.error("i: " .. serpent.block(i))
  Log.error("j: " .. serpent.block(j))

  if (area_to_chart.i > radius  or optionals.i > radius) then
    area_to_chart.complete = true
    return
  end

  -- if (optionals.mode == "stack") then
  --   if (area_to_chart.j < i or optionals.j < i) then
  --     area_to_chart.i = area_to_chart.i - 1
  --     area_to_chart.j = area_to_chart.i
  --     return
  --   end
  -- elseif (optionals.mode == "queue") then
  --   if (area_to_chart.j > i or optionals.j > i) then
  --     area_to_chart.i = area_to_chart.i + 1
  --     area_to_chart.j = 0
  --     return
  --   end
  -- end

  if (area_to_chart.j > i or optionals.j > i) then
    area_to_chart.i = area_to_chart.i + 1
    area_to_chart.j = 0
    return
  end

  local c = 0
  if (optionals.mode == Constants.optionals.mode.stack) then
    c = radius - i
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    c = i
  end

  -- for j=0, c do
  --   local a = 0
  --   if (optionals.mode == "stack") then
  --     a = c - j
  --   elseif (optionals.mode == "queue")
  --     a = j
  --   end
  -- local j = area_to_chart.j
  local a = 0
  if (optionals.mode == Constants.optionals.mode.stack) then
    Log.error("c: " .. serpent.block(c))
    Log.error("j: " .. serpent.block(j))
    -- a = c - j
    if (j > c) then
      c = 0
    else
      a = (c - j)
    end
    -- a = j - c
    -- Log.error("radius: " .. serpent.block(radius))
    -- a = radius - j
  elseif (optionals.mode == Constants.optionals.mode.queue) then
    a = j
  end

  Log.error("c: " .. serpent.block(c))
  Log.error("a: " .. serpent.block(a))

  -- This shouldn't be necesary, but for now..
  if (a > c) then
    Log.error("a: " .. serpent.block(a))
    a = c
  end

  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * a), y = (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * a), y = (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * a), y = (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * a), y = (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) },
    i,
    j
  )

-- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
-- seems like overkill/unoptimal, though

  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + 16 * a) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y + 16 * a) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - 16 * a) },
    i,
    j
  )
  Storage_Service.stage_chunk_to_chart(
    area_to_chart,
    { x = (area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)), y = (area_to_chart.center.y - 16 * a) },
    i,
    j
  )

  -- Increment/decrement based on the mode for the next iteration
  -- if (optionals.mode == "stack") then
  --   j = j - 1
  -- elseif (optionals.mode == "queue") then
    j = j + 1
  -- end

  area_to_chart.j = j
    -- end
  -- end

  Log.warn(storage.all_seeing_satellite)

  -- area_to_chart.complete = true

  return area_to_chart.complete
end

function scan_chunk_service.scan_selected_chunk(area_to_chart, optionals)
  Log.debug("scan_chunk_service.scan_selected_chunk")
  Log.info(area_to_chart)

  optionals = optionals or {
    mode = Constants.optionals.DEFAULT.mode
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

  -- game.forces[area_to_chart.player_index].chart(
  --   area_to_chart.surface, {
  --     {(area_to_chart.center.x + 16 * a) - 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) - 16},
  --     {(area_to_chart.center.x + 16 * a) + 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) + 16}
  --   })

  -- local radius = math.floor(area_to_chart.radius / 16)

  -- for i=0, radius do
  --   local c = 0
  --   if (optionals.mode == "stack") then
  --     c = radius - i
  --   elseif (optionals.mode == "queue")
  --     c = i
  --   end

  --   for j=0, c do
  --     local a = 0
  --     if (optionals.mode == "stack") then
  --       a = c - j
  --     elseif (optionals.mode == "queue")
  --       a = j
  --     end

  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x + 16 * a) - 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) - 16},
  --         {(area_to_chart.center.x + 16 * a) + 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x - 16 * a) - 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) - 16},
  --         {(area_to_chart.center.x - 16 * a) + 16, (area_to_chart.center.y + 16 * math.sqrt(c^2 - a^2)) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x - 16 * a) - 16, (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) - 16},
  --         {(area_to_chart.center.x - 16 * a) + 16, (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x + 16 * a) - 16, (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) - 16},
  --         {(area_to_chart.center.x + 16 * a) + 16, (area_to_chart.center.y - 16 * math.sqrt(c^2 - a^2)) + 16}
  --       })

  --     -- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
  --     -- seems like overkill/unoptimal, though

  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)) - 16, (area_to_chart.center.y + 16 * a) - 16},
  --         {(area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)) + 16, (area_to_chart.center.y + 16 * a) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)) - 16, (area_to_chart.center.y + 16 * a) - 16},
  --         {(area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)) + 16, (area_to_chart.center.y + 16 * a) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)) - 16, (area_to_chart.center.y - 16 * a) - 16},
  --         {(area_to_chart.center.x - 16 * math.sqrt(c^2 - a^2)) + 16, (area_to_chart.center.y - 16 * a) + 16}
  --       })
  --     game.forces[area_to_chart.player_index].chart(
  --       area_to_chart.surface, {
  --         {(area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)) - 16, (area_to_chart.center.y - 16 * a) - 16},
  --         {(area_to_chart.center.x + 16 * math.sqrt(c^2 - a^2)) + 16, (area_to_chart.center.y - 16 * a) + 16}
  --       })
  --   end
  -- end

  -- area_to_chart.complete = true

  return area_to_chart.complete
end

scan_chunk_service.all_seeing_satellite = true

local _scan_chunk_service = scan_chunk_service

return scan_chunk_service
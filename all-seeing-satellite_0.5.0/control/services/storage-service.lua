-- If already defined, return
if _storage_service and _storage_service.all_seeing_satellite then
  return _storage_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Initialization = require("control.initialization")
local Settings_Service = require("control.services.settings-service")

local storage_service = {}

function storage_service.is_storage_valid()
  return storage.all_seeing_satellite and storage.all_seeing_satellite.valid
end

function storage_service.stage_area_to_chart(event, optionals)
  Log.debug("storage_service.stage_area_to_chart")

  local optionals = optionals or { mode = Constants.optionals.mode.DEFAULT.mode }

  if (not event.tick) then return end
  if (not event.area or not event.area.left_top or not event.area.right_bottom) then return end
  if (not event.area.left_top.x or not event.area.left_top.y) then return end
  if (not event.area.right_bottom.x or not event.area.right_bottom.y) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then storage.all_seeing_satellite.staged_areas_to_chart = {} end

  Log.debug("adding area to staged_areas_to_chart")
  Log.info(event.area)

  local center = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }

  local radius = math.floor(math.sqrt((center.x - event.area.right_bottom.x)^2 + (center.y - event.area.right_bottom.y)^2) / 16)

  local area_to_chart = {
    id = event.tick,
    valid = true,
    area = event.area,
    player_index = event.player_index,
    surface = event.surface,
    center = center,
    radius = radius,
    pos = {
      x = center.x,
      y = center.y,
    },
    started = false,
    complete = false,
  }

  area_to_chart[optionals.mode] = {
    i = 0,
    j = 0,
  }

  storage.all_seeing_satellite.staged_areas_to_chart[area_to_chart.id] = area_to_chart
end

---
-- @param id -> The tick the area was selected by a given player
function storage_service.get_area_to_chart_by_id(id)
  Log.debug("storage_service.get_area_to_chart_by_id")
  Log.info(id)

  local return_val = { valid = false }

  if (not id or id < 0) then return return_val end

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.staged_areas_to_chart_dictionary) then storage.all_seeing_satellite.staged_areas_to_chart_dictionary = {} end

  return_val.obj = storage.all_seeing_satellite.staged_areas_to_chart_dictionary[id]
  return_val.valid = true

  return return_val
end

function storage_service.get_area_to_chart(optionals)
  Log.debug("storage_service.get_area_to_chart")

  optionals = optionals or {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  local return_val = { obj = {}, valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return return_val end

  if (optionals and optionals.mode == Constants.optionals.mode.stack and table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    Log.warn("staged_areas_to_chart: found something to chart; mode = stack")
    for _, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
      return_val.obj = v
    end
    return_val.valid = true
  elseif (optionals and optionals.mode == Constants.optionals.mode.queue and table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    Log.warn("staged_areas_to_chart: found something to chart; mode = queue")
    for _, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
      return_val.obj = v
      break
    end
    return_val.valid = true
  else
    Log.debug("didn't find anything to chart")
  end

  return return_val
end

function storage_service.remove_area_to_chart_from_stage(optionals)
  Log.debug("storage_service.remove_area_to_chart_from_stage")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return end

  if (table_size(storage.all_seeing_satellite.staged_areas_to_chart) > 0) then
    if (optionals.mode == Constants.optionals.mode.stack.queue) then
      for k, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
        storage.all_seeing_satellite.staged_areas_to_chart[k] = nil
        break
      end
    else
      local obj = {}
      for k, v in pairs(storage.all_seeing_satellite.staged_areas_to_chart) do
        obj.k = k
        obj.v = storage.all_seeing_satellite.staged_areas_to_chart[k]
      end
      storage.all_seeing_satellite.staged_areas_to_chart[obj.k] = nil
    end
  end
end

function storage_service.remove_area_to_chart_from_stage_by_id(id, optionals)
  Log.debug("storage_service.remove_area_to_chart_from_stage_by_id")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end
  if (not id or id < 0) then return end

  if (not storage.all_seeing_satellite.staged_areas_to_chart) then return end

  storage.all_seeing_satellite.staged_areas_to_chart[id] = nil
end

function storage_service.stage_chunk_to_chart(area_to_chart, center, i, j, optionals)
  Log.debug("storage_service.stage_chunk_to_chart")
  if (not area_to_chart or not area_to_chart.valid) then return end

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  local tick = 0
  if (game) then tick = game.tick end
  if (not tick) then tick = 0 end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart[tick]) then storage.all_seeing_satellite.staged_chunks_to_chart[tick] = {} end

  local chunk_to_chart = {
    parent_id = area_to_chart.id,
    id = tick,
    valid = area_to_chart.valid,
    area = area_to_chart.area,
    player_index = area_to_chart.player_index,
    surface = area_to_chart.surface,
    center = area_to_chart.center,
    radius = area_to_chart.radius,
    pos = {
      x = center.x,
      y = center.y,
    },
  }

  chunk_to_chart[optionals.mode] = {
    i = i,
    j = j,
  }

  table.insert(storage.all_seeing_satellite.staged_chunks_to_chart[tick], chunk_to_chart)
end

function storage_service.get_staged_chunks_to_chart(optionals)
  Log.debug("storage_service.get_staged_chunks_to_chart")

  optionals = optionals or {
    mode = Constants.optionals.mode.queue
  }

  local return_val = { obj = {}, valid = false }

  if (not storage) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return return_val
  end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then storage.all_seeing_satellite.staged_chunks_to_chart = {} end

  if (optionals and optionals.mode == Constants.optionals.mode.stack and table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    Log.warn("get_staged_chunks_to_chart: found something to chart; mode = stack")
    for _, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
      return_val.obj = v
    end
    return_val.valid = true
  elseif (optionals and optionals.mode == Constants.optionals.mode.queue and table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    Log.warn("get_staged_chunks_to_chart: found something to chart; mode = queue")
    for _, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
      return_val.obj = v
      break
    end
    return_val.valid = true
  else
    Log.warn("didn't find anything to chart")
  end

  return return_val
end

function storage_service.remove_chunk_to_chart_from_stage(optionals)
  Log.debug("storage_service.remove_chunk_to_chart_from_stage")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then return end

  if (table_size(storage.all_seeing_satellite.staged_chunks_to_chart) > 0) then
    if (optionals.mode == Constants.optionals.mode.queue) then
      for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
        storage.all_seeing_satellite.staged_chunks_to_chart[k] = nil
        break
      end
    else
      local obj = {}
      for k, v in pairs(storage.all_seeing_satellite.staged_chunks_to_chart) do
        obj.k = k
        obj.v = storage.all_seeing_satellite.staged_chunks_to_chart[k]
        break
      end
      storage.all_seeing_satellite.staged_chunks_to_chart[obj.k] = nil
    end
  end

  return storage.all_seeing_satellite.staged_chunks_to_chart
end

function storage_service.remove_chunk_to_chart_from_stage_by_id(id, optionals)
  Log.debug("storage_service.remove_chunk_to_chart_from_stage_by_id")
  optionals = optionals or {
   mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  if (not id or id < 0) then return end

  if (not storage.all_seeing_satellite.staged_chunks_to_chart) then return end

  storage.all_seeing_satellite.staged_chunks_to_chart[id] = nil
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

function storage_service.get_do_scan()
  Log.debug("storage_service.get_do_scan")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (storage.all_seeing_satellite.do_scan == nil) then storage.all_seeing_satellite.do_scan = false end

  return storage.all_seeing_satellite.do_scan
end

function storage_service.set_do_scan(set_val)
  Log.debug("storage_service.set_do_scan")

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (set_val == nil) then set_val = false end

  storage.all_seeing_satellite.do_scan = set_val
end

function storage_service.clear_stages()
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then
    Initialization.reinit()
    return
  end

  Log.warn("clearing stages")
  storage.all_seeing_satellite.staged_areas_to_chart = {}
  storage.all_seeing_satellite.staged_chunks_to_chart = {}
end

function storage_service.get_do_nth_tick()
  Log.debug("storage_service.get_do_scan")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (storage.all_seeing_satellite.do_nth_tick == nil) then storage.all_seeing_satellite.do_nth_tick = false end

  return storage.all_seeing_satellite.do_nth_tick
end

function storage_service.set_do_nth_tick(set_val)
  Log.debug("storage_service.set_do_scan")

  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (set_val == nil) then set_val = false end

  storage.all_seeing_satellite.do_nth_tick = set_val
end

function storage_service.get_all_satellites_launched()
  Log.debug("storage_service.get_all_satellites_launched")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_launched) then
    storage.all_seeing_satellite.satellites_launched = {}
    -- Check for pre 0.5.x
    Log.warn("checking for pre 0.5.x")
    if (storage.satellites_launched ~= nil) then
      -- Migrate
      Log.warn("migrating satellites_launched")
      storage.all_seeing_satellite.satellites_launched = storage.satellites_launched
      storage.satellites_launched = nil
    end
  end

  return storage.all_seeing_satellite.satellites_launched
end

function storage_service.get_satellites_launched(surface_name)
  Log.debug("storage_service.get_satellites_launched")
  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_launched) then
    storage.all_seeing_satellite.satellites_launched = {}
    -- Check for pre 0.5.x
    Log.warn("checking for pre 0.5.x")
    if (storage.satellites_launched ~= nil) then
      -- Migrate
      Log.warn("migrating satellites_launched")
      storage.all_seeing_satellite.satellites_launched = storage.satellites_launched
      storage.satellites_launched = nil
    end
  end

  if (storage.all_seeing_satellite.satellites_launched[surface_name] == nil) then storage.all_seeing_satellite.satellites_launched[surface_name] = 0 end

  return storage.all_seeing_satellite.satellites_launched[surface_name]
end

function storage_service.set_satellites_launched(set_val, surface_name)
  Log.debug("storage_service.set_satellites_launched")

  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (set_val == nil) then set_val = 0 end
  if (not storage.all_seeing_satellite.satellites_launched) then storage.all_seeing_satellite.satellites_launched = {} end

  storage.all_seeing_satellite.satellites_launched[surface_name] = set_val
end

function storage_service.get_all_satellites_in_orbit()
  Log.debug("storage_service.get_all_satellites_in_orbit")
  if (not storage) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then
    storage.all_seeing_satellite.satellites_in_orbit = {}
    -- Check for pre 0.5.x
    Log.warn("checking for pre 0.5.x")
    if (storage.satellites_in_orbit ~= nil) then
      -- Migrate
      Log.warn("migrating satellites_in_orbit")
      -- Check/add missing properties
      for planet_name, satellites in pairs(storage.satellites_in_orbit) do
        if (not storage.all_seeing_satellite.satellites_in_orbit[planet_name]) then storage.all_seeing_satellite.satellites_in_orbit[planet_name] = {} end
        for _, satellite in pairs(satellites) do
          if (satellite) then
            satellite.tick_off_cooldown = satellite.tick_created
            satellite.scan_count = 0

            if (not storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown = {} end
            storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown[satellite.tick_off_cooldown] = satellite
          end
        end
        storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites = storage.satellites_in_orbit[planet_name]
      end
      storage.satellites_in_orbit = nil
    end
  end

  return storage.all_seeing_satellite.satellites_in_orbit
end

function storage_service.get_satellites_in_orbit(surface_name)
  Log.debug("storage_service.get_satellites_in_orbit")
  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then
    storage.all_seeing_satellite.satellites_in_orbit = {}
    -- Check for pre 0.5.x
    Log.warn("checking for pre 0.5.x")
    if (storage.satellites_in_orbit ~= nil) then
      -- Migrate
      Log.warn("migrating satellites_in_orbit")
      -- Check/add missing properties
      for planet_name, satellites in pairs(storage.satellites_in_orbit) do
        if (not storage.all_seeing_satellite.satellites_in_orbit[planet_name]) then storage.all_seeing_satellite.satellites_in_orbit[planet_name] = {} end
        for _, satellite in pairs(satellites) do
          if (satellite) then
            satellite.tick_off_cooldown = satellite.tick_created
            satellite.scan_count = 0

            if (not storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown = {} end
            storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites_cooldown[satellite.tick_off_cooldown] = satellite
          end
        end
        storage.all_seeing_satellite.satellites_in_orbit[planet_name].satellites = storage.satellites_in_orbit[planet_name]
      end
      storage.satellites_in_orbit = nil
    end
  end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites = {} end

  return storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites
end

function storage_service.set_satellites_in_orbit(set_val, surface_name)
  Log.debug("storage_service.set_satellites_in_orbit")

  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[planet_name]) then storage.all_seeing_satellite.satellites_in_orbit[planet_name] = {} end

  storage.all_seeing_satellite.satellites_in_orbit[surface_name] = set_val
end

function storage_service.add_to_satellites_in_orbit(satellite, surface_name, tick, death_tick)
  Log.debug("storage_service.add_to_satellites_in_orbit")

  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned == nil) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned = false end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end

  local _satellite = {
    entity = satellite,
    planet_name = surface_name,
    tick_created = tick,
    tick_to_die = death_tick,
    tick_off_cooldown = tick + math.random(0, 111),
    scan_count = 0,
  }

  table.insert(storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites, _satellite)

  storage_service.add_to_satellites_in_orbit_cooldown(surface_name, _satellite)
end

function storage_service.set_satellites_in_orbit_scanned(set_val, surface_name)
  Log.debug("storage_service.set_satellites_in_orbit_scanned")
  Log.debug(surface_name)

  if (not storage or not surface_name or set_val == nil) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned == nil) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned = false end

  storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned = set_val
end

function storage_service.get_satellites_in_orbit_scanned(surface_name)
  Log.debug("storage_service.add_to_satellites_in_orbit")

  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned == nil) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned = false end

  return storage.all_seeing_satellite.satellites_in_orbit[surface_name].scanned
end

function storage_service.add_to_satellites_in_orbit_cooldown(surface_name, satellite)
  Log.debug("storage_service.add_to_satellites_in_orbit_cooldown")

  if (not storage or not surface_name or not satellite) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end

  local tick = satellite.tick_off_cooldown and satellite.tick_off_cooldown or game.tick
  while (storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[tick] ~= nil) do
    tick = tick + 1
  end

  storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[tick] = satellite
end

function storage_service.get_satellites_in_orbit_cooldown(surface_name)
  Log.debug("storage_service.get_satellites_in_orbit_cooldown")

  if (not storage or not surface_name) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end

  return storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown
end

function storage_service.dequeue_satellites_in_orbit_cooldown(surface_name)
  Log.debug("storage_service.dequeue_satellites_in_orbit_cooldown")

  local return_val = {
    valid = false
  }

  if (not storage or not surface_name) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end


  if (  storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then
    for k,v in pairs(storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) do
      return_val.obj = v
      return_val.valid = true
      storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[k] = nil
      break
    end
  end

  return return_val
end

function storage_service.dequeue_satellites_in_orbit_cooldown(surface_name)
  Log.debug("storage_service.dequeue_satellites_in_orbit_cooldown")

  local return_val = {
    valid = false
  }

  if (not storage or not surface_name) then return return_val end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end


  if (  storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then
    for k,v in pairs(storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) do

      return_val.obj = storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[k]
      return_val.valid = true
      storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[k] = nil

      return return_val
    end
  end
end

function storage_service.remove_from_satellites_in_orbit_cooldown_by_id(surface_name, id)
  Log.debug("storage_service.remove_from_satellites_in_orbit_cooldown_by_id")

  if (not storage or not surface_name or not id) then return end
  if (not storage.all_seeing_satellite or not storage.all_seeing_satellite.valid) then Initialization.reinit() end
  if (not storage.all_seeing_satellite.satellites_in_orbit) then storage.all_seeing_satellite.satellites_in_orbit = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name]) then storage.all_seeing_satellite.satellites_in_orbit[surface_name] = {} end
  if (not storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown = {} end

  if (  storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown) then
    storage.all_seeing_satellite.satellites_in_orbit[surface_name].satellites_cooldown[id] = nil
  end
end

storage_service.all_seeing_satellite = true

local _storage_service = storage_service

return storage_service
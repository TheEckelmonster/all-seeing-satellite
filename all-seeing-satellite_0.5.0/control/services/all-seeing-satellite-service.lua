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
local Satellite_Utils = require("control.utils.satellite-utils")

local all_seeing_satellite_service = {}

function all_seeing_satellite_service.check_for_areas_to_stage()
  Log.debug("all_seeing_satellite_service.check_for_areas_to_stage")

  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode,
  }

  local return_val = false

  local obj_wrapper = Storage_Service.get_area_to_chart(optionals)
  if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then
    obj_wrapper = Storage_Service.get_area_to_chart({ mode = Constants.optionals.mode.queue })
    if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then return return_val end
  end
  Log.debug(obj_wrapper)
  local area_to_chart = obj_wrapper.obj

  if (not Planet_Utils.allow_scan(area_to_chart.surface.name)) then return return_val end

  if (not area_to_chart.started) then
    if (area_to_chart.player_index and game and game.players and game.players[area_to_chart.player_index] and game.players[area_to_chart.player_index].force) then
      Log.warn("starting scan")
      game.players[area_to_chart.player_index].force.print("Starting scan")
    end
    Storage_Service.set_satellites_in_orbit_scanned(false, area_to_chart.surface.name)
    Scan_Chunk_Service.stage_selected_area(area_to_chart, optionals)
    area_to_chart.started = true
  end

  if (not area_to_chart[optionals.mode]) then area_to_chart[optionals.mode] = { i = 0, j = 0 } end

  optionals.i = area_to_chart[optionals.mode].i
  optionals.j = area_to_chart[optionals.mode].j


  obj_wrapper = Storage_Service.get_staged_chunks_to_chart(optionals)
  if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then
    obj_wrapper = Storage_Service.get_staged_chunks_to_chart({ mode = Constants.optionals.mode.queue })
    if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then return end
  end
  Log.debug(obj_wrapper)
  local chunks_to_chart = obj_wrapper.obj

  Log.debug(chunks_to_chart)
  Log.debug(#chunks_to_chart)
  Log.debug(area_to_chart.complete)

  if (not Settings_Service.get_restrict_satellite_scanning()) then
    Scan_Chunk_Service.stage_selected_area(area_to_chart, optionals)
  else
    local satellites = Storage_Service.get_satellites_in_orbit_cooldown(area_to_chart.surface.name)
    Log.debug(satellites)
    if (satellites) then
      -- Search for a satellite not on cooldown
      for _, satellite in pairs(satellites) do
        if (satellite and satellite.tick_off_cooldown and game.tick > satellite.tick_off_cooldown) then
          if ( Storage_Service.get_satellites_in_orbit_scanned(area_to_chart.surface.name)
            or (chunks_to_chart and #chunks_to_chart == 0 and not area_to_chart.complete)
          ) then
            Log.warn("hello")
            Scan_Chunk_Service.stage_selected_area(area_to_chart, optionals)
            Storage_Service.set_satellites_in_orbit_scanned(false, area_to_chart.surface.name)
          end
        end
        break
      end
    end
  end

  if (area_to_chart.complete) then
    Log.error("removing area")
    Storage_Service.remove_area_to_chart_from_stage_by_id(area_to_chart.id, optionals)

    obj_wrapper = Storage_Service.get_area_to_chart(optionals)
    if (not obj_wrapper or not obj_wrapper.obj) then
      obj_wrapper = Storage_Service.get_area_to_chart({ mode = Constants.optionals.mode.queue })
      if (not obj_wrapper or not obj_wrapper.obj) then return return_val end
    end
    Log.debug(obj_wrapper)
    local _area_to_check = obj_wrapper.obj

    if (_area_to_check and #_area_to_check == 0 and chunks_to_chart and #chunks_to_chart == 0) then
      Log.debug("scan complete")
      if (area_to_chart and area_to_chart.player_index and game and game.players and game.players[area_to_chart.player_index] and game.players[area_to_chart.player_index].force) then
        game.players[area_to_chart.player_index].force.print("Scan complete")
      end
    end
  end
end

function all_seeing_satellite_service.do_scan(surface_name)
  Log.debug("all_seeing_satellite_service.do_scan")
  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  local obj_wrapper = Storage_Service.get_staged_chunks_to_chart(optionals)
  if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then
    obj_wrapper = Storage_Service.get_staged_chunks_to_chart({ mode = Constants.optionals.mode.queue })
    if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then return end
  end
  Log.debug(obj_wrapper)
  local chunks_to_chart = obj_wrapper.obj

  local i = 0
  local did_break = false
  local do_break = false
  for k, chunk_to_chart in pairs(chunks_to_chart) do
    Log.debug(k)
    Log.debug(chunk_to_chart)

    -- TODO: Make this configurable
    -- if (i > 150) then
    --   did_break = true
    --   Log.error("breaking outer")
    --   break
    -- end
    -- Log.error("k: " .. serpent.block(k))
    -- Log.error("chunk_to_chart: " .. serpent.block(chunk_to_chart))

    if (game and game.players and game.players[chunk_to_chart.player_index] and game.players[chunk_to_chart.player_index].force) then
      local force = game.players[chunk_to_chart.player_index].force
      if (force.is_chunk_charted(chunk_to_chart.surface, chunk_to_chart.pos)) then
        chunks_to_chart[k] = nil

        if (chunks_to_chart and #chunks_to_chart == 0) then
          local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
          if (result and table_size(result) == 0) then
            Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
          end
        end

        goto continue_outer
      end
    end

    if (not Settings_Service.get_restrict_satellite_scanning()) then
      if (Scan_Chunk_Service.scan_selected_chunk(chunk_to_chart, optionals)) then
        chunks_to_chart[k] = nil

        if (chunks_to_chart and #chunks_to_chart == 0) then
          local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
          if (result and table_size(result) == 0) then
            Log.warn("scan complete")
            game.players[chunk_to_chart.player_index].force.print("Scan complete")
            Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
          end
        end
      end
    else
      if (Planet_Utils.allow_scan(chunk_to_chart.surface.name)) then

        local satellites = Storage_Service.get_satellites_in_orbit_cooldown(chunk_to_chart.surface.name)
        Log.warn(satellites)

        if (not satellites) then break end

        for id, satellite in pairs(satellites) do
          Log.warn("game.tick: " .. serpent.block(game.tick))
          Log.warn("id: " .. serpent.block(id))
          Log.warn(satellite)
          if (satellite.tick_off_cooldown < game.tick) then

            if (Scan_Chunk_Service.scan_selected_chunk(chunk_to_chart, optionals)) then
              Log.warn("scanned")
              -- set scan cooldown, accounting for quality
              local quality_modifier = Satellite_Utils.get_quality_multiplier(satellite.quality)
              local cooldown_duration = Settings_Service.get_satellite_scan_cooldown_duration()
              local use_cooldown = 0
              if (cooldown_duration > 0) then use_cooldown = 1 end

              -- TODO: Make scan count modifier a configurable setting; the 0.1 value, currently
              satellite.tick_off_cooldown = game.tick + math.floor(satellite.scan_count * 0.1 * use_cooldown) + math.floor(((Constants.TICKS_PER_SECOND * cooldown_duration) * (1 / quality_modifier)))
              satellite.scan_count = satellite.scan_count + 1

              Storage_Service.add_to_satellites_in_orbit_cooldown(chunk_to_chart.surface.name, satellite)
              Storage_Service.remove_from_satellites_in_orbit_cooldown_by_id(chunk_to_chart.surface.name, id)
              chunks_to_chart[k] = nil

              if (chunks_to_chart and #chunks_to_chart == 0) then
                local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
                if (result and table_size(result) == 0) then
                  Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
                end
              end

              i = i + 1
            end
          else
            Log.warn("breaking")
            do_break = true
          end
          break
        end
      end
    end

    if (do_break) then break end

    ::continue_outer::
    i = i + 1
  end
end

all_seeing_satellite_service.all_seeing_satellite = true

local _all_seeing_satellite_service = all_seeing_satellite_service

return all_seeing_satellite_service
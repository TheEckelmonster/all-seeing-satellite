-- If already defined, return
if _all_seeing_satellite_service and _all_seeing_satellite_service.all_seeing_satellite then
  return _all_seeing_satellite_service
end

local Area_To_Chart_Repository = require("control.repositories.scanning.area-to-chart-repository")
local Chunk_To_Chart_Repository = require("control.repositories.scanning.chunk-to-chart-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Repository = require("control.repositories.satellite-repository")
local Scan_Chunk_Service = require("control.services.scan-chunk-service")
local Settings_Service = require("control.services.settings-service")
-- local Storage_Service = require("control.services.storage-service")
local Satellite_Utils = require("control.utils.satellite-utils")

local all_seeing_satellite_service = {}

function all_seeing_satellite_service.check_for_areas_to_stage()
  Log.debug("all_seeing_satellite_service.check_for_areas_to_stage")

  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode,
  }

  local return_val = false

  -- local obj_wrapper = Storage_Service.get_area_to_chart(optionals)
  -- if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then
  --   obj_wrapper = Storage_Service.get_area_to_chart({ mode = Constants.optionals.mode.queue })
  --   if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then return return_val end
  -- end
  -- Log.debug(obj_wrapper)
  -- local area_to_chart = obj_wrapper.obj
  local area_to_chart = Area_To_Chart_Repository.get_area_to_chart_data(optionals)
  Log.debug(area_to_chart)
  if (not area_to_chart.valid) then return return_val end

  if (not Planet_Utils.allow_scan(area_to_chart.surface.name)) then return return_val end

  if (not area_to_chart.started) then
    -- if (area_to_chart.player_index and game and game.players and game.players[area_to_chart.player_index] and game.players[area_to_chart.player_index].force) then
    if (area_to_chart.player_index and game and game.players and game.get_player(area_to_chart.player_index) and game.get_player(area_to_chart.player_index).force) then
      Log.warn("starting scan")
      -- game.players[area_to_chart.player_index].force.print("Starting scan")
      game.get_player(area_to_chart.player_index).force.print("Starting scan")
    end
    -- Storage_Service.set_satellites_in_orbit_scanned(false, area_to_chart.surface.name)
    Satellite_Meta_Repository.update_satellite_meta_data({
      planet_name = area_to_chart.surface.name,
      scanned = false,
    })

    -- Scan_Chunk_Service.-OLDstage_selected_area(area_to_chart, optionals)
    Scan_Chunk_Service.stage_selected_chunk(area_to_chart, optionals)

    Area_To_Chart_Repository.update_area_to_chart_data({
      started = true,
    })
    -- area_to_chart.started = true
  end

  if (not area_to_chart[optionals.mode]) then area_to_chart[optionals.mode] = { i = 0, j = 0 } end

  optionals.i = area_to_chart[optionals.mode].i
  optionals.j = area_to_chart[optionals.mode].j

  -- obj_wrapper = Storage_Service.get_staged_chunks_to_chart(optionals)
  -- if (not obj_wrapper or not obj_wrapper.obj) then
  --   obj_wrapper = Storage_Service.get_staged_chunks_to_chart({ mode = Constants.optionals.mode.queue })
  --   if (not obj_wrapper or not obj_wrapper.obj) then return return_val end
  -- end
  -- Log.debug(obj_wrapper)
  -- local chunks_to_chart = obj_wrapper.obj
  local chunks_to_chart = Chunk_To_Chart_Repository.get_chunk_to_chart_data(optionals)
  -- Log.warn(chunks_to_chart)
  -- if (not chunks_to_chart.valid) then return end

  -- Log.warn(chunks_to_chart)
  -- Log.warn(#chunks_to_chart)
  -- Log.warn(area_to_chart.complete)

  if (not Settings_Service.get_restrict_satellite_scanning()) then
    -- Scan_Chunk_Service.-OLDstage_selected_area(area_to_chart, optionals)
    Scan_Chunk_Service.stage_selected_chunk(area_to_chart, optionals)
  else
    -- local satellites = Storage_Service.get_satellites_in_orbit_cooldown(area_to_chart.surface.name)
    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(area_to_chart.surface.name)
    if (not satellite_meta_data.valid) then return return_val end
    local satellites = satellite_meta_data.satellites_cooldown
    -- Log.warn(area_to_chart.surface.name)
    -- Log.warn(satellites)
    -- if (satellites) then
      -- Search for a satellite not on cooldown
      for k, satellite in pairs(satellites) do
        -- Log.error(k)
        -- Log.error(satellite)
        if (satellite and satellite.tick_off_cooldown and game.tick > satellite.tick_off_cooldown) then
          -- if ( Storage_Service.get_satellites_in_orbit_scanned(area_to_chart.surface.name)
          if ( satellite_meta_data.scanned
            or (chunks_to_chart and #chunks_to_chart == 0 and not area_to_chart.complete)
          ) then
            Log.warn("hello")
            -- Scan_Chunk_Service.-OLDstage_selected_area(area_to_chart, optionals)
            Scan_Chunk_Service.stage_selected_chunk(area_to_chart, optionals)
            -- Storage_Service.set_satellites_in_orbit_scanned(false, area_to_chart.surface.name)
            Satellite_Meta_Repository.update_satellite_meta_data({
              planet_name = area_to_chart.surface.name,
              scanned = false,
            })
          end
        end
        break
      end
    -- end
  end

  if (area_to_chart.complete) then
    Log.error("removing area")
    -- Storage_Service.remove_area_to_chart_from_stage_by_id(area_to_chart.id, optionals)
    -- Area_To_Chart_Repository.delete_area_to_chart_data_by_id(area_to_chart.id)
    if (not Area_To_Chart_Repository.delete_area_to_chart_data_by_id(area_to_chart.id)) then return return_val end

    -- obj_wrapper = Storage_Service.get_area_to_chart(optionals)
    -- if (not obj_wrapper or not obj_wrapper.obj) then
    --   obj_wrapper = Storage_Service.get_area_to_chart({ mode = Constants.optionals.mode.queue })
    --   if (not obj_wrapper or not obj_wrapper.obj) then return return_val end
    -- end
    -- Log.debug(obj_wrapper)
    -- local _area_to_check = obj_wrapper.obj
    local _area_to_check = Area_To_Chart_Repository.get_area_to_chart_data(optionals)
    Log.debug(area_to_chart)
    if (not area_to_chart.valid) then return return_val end

    if (_area_to_check and #_area_to_check == 0 and chunks_to_chart and #chunks_to_chart == 0) then
      Log.debug("scan complete")
      -- if (area_to_chart and area_to_chart.player_index and game and game.players and game.players[area_to_chart.player_index] and game.players[area_to_chart.player_index].force) then
      if (area_to_chart and area_to_chart.player_index and game and game.players and game.get_player(area_to_chart.player_index) and game.get_player(area_to_chart.player_index).force) then
        game.players[area_to_chart.player_index].force.print("Scan complete")
      end
    end
  end

  return_val = true
  return return_val
end

function all_seeing_satellite_service.do_scan(surface_name)
  Log.debug("all_seeing_satellite_service.do_scan")
  local optionals = {
    mode = Settings_Service.get_satellite_scan_mode() or Constants.optionals.DEFAULT.mode
  }

  -- local obj_wrapper = Storage_Service.get_staged_chunks_to_chart(optionals)
  -- if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then
  --   obj_wrapper = Storage_Service.get_staged_chunks_to_chart({ mode = Constants.optionals.mode.queue })
  --   if (not obj_wrapper or not obj_wrapper.obj or not obj_wrapper.valid) then return end
  -- end
  -- Log.debug(obj_wrapper)
  -- local chunks_to_chart = obj_wrapper.obj
  local chunks_to_chart = Chunk_To_Chart_Repository.get_chunk_to_chart_data(optionals)
  Log.debug(chunks_to_chart)
  -- if (not chunks_to_chart.valid) then return end

  if (chunks_to_chart and #chunks_to_chart == 0) then

    -- local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
    local result = Chunk_To_Chart_Repository.delete_chunk_to_chart_data(optionals)

    if (result and table_size(result) == 0) then
      -- Storage_Service.set_satellites_in_orbit_scanned(true, surface_name)
      Satellite_Meta_Repository.update_satellite_meta_data({
        planet_name = surface_name,
        scanned = true,
      })
    end
    return
  end

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
      if ( chunk_to_chart.surface.is_chunk_generated(chunk_to_chart.pos)
        or force.is_chunk_charted(chunk_to_chart.surface, chunk_to_chart.pos)
        or force.is_chunk_visible(chunk_to_chart.surface, chunk_to_chart.pos)
        or force.is_chunk_requested_for_charting(chunk_to_chart.surface, chunk_to_chart.pos)
      ) then
        chunks_to_chart[k] = nil

        if (chunks_to_chart and #chunks_to_chart == 0) then
          -- local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
          local result = Chunk_To_Chart_Repository.delete_chunk_to_chart_data(optionals)
          if (result and table_size(result) == 0) then
            -- Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
            Satellite_Meta_Repository.update_satellite_meta_data({
              planet_name = chunk_to_chart.surface.name,
              scanned = true,
            })
          end
        end

        goto continue_outer
      end
    end

    if (not Settings_Service.get_restrict_satellite_scanning()) then
      if (Scan_Chunk_Service.scan_selected_chunk(chunk_to_chart, optionals)) then
        chunks_to_chart[k] = nil

        if (chunks_to_chart and #chunks_to_chart == 0) then
          -- local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
          local result = Chunk_To_Chart_Repository.delete_chunk_to_chart_data(optionals)
          if (result and table_size(result) == 0) then
            Log.warn("scan complete")
            -- game.players[chunk_to_chart.player_index].force.print("Scan complete")
            game.get_player(chunk_to_chart.player_index).force.print("Scan complete")
            -- Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
            Satellite_Meta_Repository.update_satellite_meta_data({
              planet_name = chunk_to_chart.surface.name,
              scanned = true,
            })
          end
        end
      end
    else
      if (Planet_Utils.allow_scan(chunk_to_chart.surface.name)) then

        -- local satellites = Storage_Service.get_satellites_in_orbit_cooldown(chunk_to_chart.surface.name)
        local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(chunk_to_chart.surface.name)
        if (not satellite_meta_data.valid) then return end
        local satellites = satellite_meta_data.satellites_cooldown
        Log.warn(satellites)

        -- if (not satellites) then break end
        if (not satellite_meta_data.satellites_cooldown) then break end

        -- for id, satellite in pairs(satellites) do
        for id, satellite in pairs(satellite_meta_data.satellites_cooldown) do
          Log.info("game.tick: " .. serpent.block(game.tick))
          Log.info("id: " .. serpent.block(id))
          Log.info(satellite)
          if (satellite.tick_off_cooldown < game.tick) then

            if (Scan_Chunk_Service.scan_selected_chunk(chunk_to_chart, optionals)) then
              Log.warn("scanned")
              -- set scan cooldown, accounting for quality
              local quality_modifier = Satellite_Utils.get_quality_multiplier(satellite.quality)
              local cooldown_duration = Settings_Service.get_satellite_scan_cooldown_duration()
              local use_cooldown = 0
              if (cooldown_duration > 0) then use_cooldown = 1 end

              -- TODO: Make scan count modifier a configurable setting; the 0.1 value, currently
              satellite.tick_off_cooldown = game.tick + math.floor(satellite.scan_count * 0.025 * use_cooldown) + math.floor(((Constants.TICKS_PER_SECOND * cooldown_duration) * (1 / quality_modifier)))
              satellite.scan_count = satellite.scan_count + 1

              -- Storage_Service.add_to_satellites_in_orbit_cooldown(chunk_to_chart.surface.name, satellite)
              -- Storage_Service.remove_from_satellites_in_orbit_cooldown_by_id(chunk_to_chart.surface.name, id)
              Satellite_Repository.add_satellite_data_to_cooldown({
                satellite = satellite,
                planet_name = chunk_to_chart.surface.name,
              })
              -- Storage_Service.remove_from_satellites_in_orbit_cooldown_by_id(chunk_to_chart.surface.name, id)
              satellite_meta_data.satellites_cooldown[id] = nil
              satellite_meta_data.updated = game.tick
              -- Satellite_Repository.delete_satellite_data_by_id
              chunks_to_chart[k] = nil

              if (chunks_to_chart and #chunks_to_chart == 0) then
                -- local result = Storage_Service.remove_chunk_to_chart_from_stage(optionals)
                local result = Chunk_To_Chart_Repository.delete_chunk_to_chart_data(optionals)
                if (result and table_size(result) == 0) then
                  -- Storage_Service.set_satellites_in_orbit_scanned(true, chunk_to_chart.surface.name)
                  Satellite_Meta_Repository.update_satellite_meta_data({
                    planet_name = chunk_to_chart.surface.name,
                    scanned = true,
                  })
                end
              end

              i = i + 1
              break
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
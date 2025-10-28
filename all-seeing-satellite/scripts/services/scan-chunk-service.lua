local Area_To_Chart_Repository = require("scripts.repositories.scanning.area-to-chart-repository")
local Chunk_To_Chart_Repository = require("scripts.repositories.scanning.chunk-to-chart-repository")

local scan_chunk_service = {}

function scan_chunk_service.stage_selected_area(event)
    Log.debug("scan_chunk_service.stage_selected_area")
    Log.info(event)

    if (not event) then return end

    local optionals = { mode = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name }) or Constants.optionals.DEFAULT.mode }

    Log.debug("staging area")
    Area_To_Chart_Repository.save_area_to_chart_data(event, optionals)
end

function scan_chunk_service.clear_selected_chunks(event)
    Log.debug("scan_chunk_service.clear_selected_chunks")
    Log.info(event)

    local return_val = false

    if (not event) then return return_val end
    if (not game) then return return_val end
    if (not event.player_index) then return return_val end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return return_val end
    local force = player.force
    if (not force or not force.valid) then return return_val end

    if (not event.surface or not event.surface.valid) then return return_val end
    local surface = event.surface

    if (not event.area) then return return_val end
    if (not event.area.left_top or not event.area.right_bottom) then return return_val end
    if (not event.area.left_top.x or not event.area.left_top.y) then return return_val end
    if (not event.area.right_bottom.x or not event.area.right_bottom.y) then return return_val end

    -- local area = event.area

    -- local area_width = math.abs(area.left_top.x - area.right_bottom.x) / 32
    -- Log.warn(area_width)
    -- local area_height = math.abs(area.left_top.y - area.right_bottom.y) / 32
    -- Log.warn(area_height)

    -- local start = area.left_top

    -- local i = 0
    -- local j = 0

    -- while j <= area_width do
    --   while i <= area_height do
    --     force.unchart_chunk({ x = start.x + 32 * i, y = start.y + 32 * j } , surface)
    --     -- unchart_chunk({ x = start.x + 32 * (i - 1), y = start.y + 32 * (j - 1) } , surface)
    --     i = i + 1
    --   end
    --   i = 0
    --   j = j + 1
    -- end

    return_val = true
    return return_val
end

function scan_chunk_service.stage_selected_chunk(chunk_to_chart, optionals)
    Log.debug("scan_chunk_service.stage_selected_chunk")
    Log.info(chunk_to_chart)

    optionals = optionals or { mode = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name }) }

    if (not chunk_to_chart) then return end
    Log.debug("1")
    if (not game or not game.forces) then return end
    Log.debug("2")
    if (not chunk_to_chart.player_index or not game.forces[chunk_to_chart.player_index]) then return end
    Log.debug("3")
    if (not chunk_to_chart.surface) then return end
    Log.debug("4")
    if (not chunk_to_chart.center or not chunk_to_chart.center.x or not chunk_to_chart.center.y) then return end
    Log.debug("staging chunk(s)")

    local radius = chunk_to_chart.radius

    if (optionals and optionals.i == nil) then optionals.i = 0 end
    if (optionals and optionals.j == nil) then optionals.j = 0 end

    Log.debug(chunk_to_chart)

    if (not chunk_to_chart[optionals.mode]) then chunk_to_chart[optionals.mode] = {} end
    if (not chunk_to_chart[optionals.mode].i) then chunk_to_chart[optionals.mode].i = 0 end
    if (not chunk_to_chart[optionals.mode].j) then chunk_to_chart[optionals.mode].j = 0 end

    if (chunk_to_chart[optionals.mode].i < 0 or optionals.i < 0) then return end
    if (chunk_to_chart[optionals.mode].j < 0 or optionals.j < 0) then return end

    local i = chunk_to_chart[optionals.mode].i >= 0 and chunk_to_chart[optionals.mode].i <= radius and
    chunk_to_chart[optionals.mode].i or optionals.i
    local j = chunk_to_chart[optionals.mode].j >= 0 and chunk_to_chart[optionals.mode].j <= radius and
    chunk_to_chart[optionals.mode].j or optionals.j

    if (chunk_to_chart[optionals.mode].i > radius or optionals.i > radius) then
        chunk_to_chart.complete = true
        return
    end

    local c = 0
    if (optionals.mode == Constants.optionals.mode.stack) then
        c = radius - i
    elseif (optionals.mode == Constants.optionals.mode.queue) then
        c = i
    end

    if (optionals.mode == Constants.optionals.mode.stack) then
        if (chunk_to_chart[optionals.mode].j > c or optionals.j > c) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            i = chunk_to_chart[optionals.mode].i
            j = 0
        end
    elseif (optionals.mode == Constants.optionals.mode.queue) then
        if (chunk_to_chart[optionals.mode].j > i or optionals.j > i) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            i = chunk_to_chart[optionals.mode].i
            j = 0
        end
    end

    local a = 0
    if (optionals.mode == Constants.optionals.mode.stack) then
        if (j > c) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            return
        end
        a = c - j
    elseif (optionals.mode == Constants.optionals.mode.queue) then
        a = j
    end

    local distance_modifier = Constants.CHUNK_SIZE

    if (i == 0 and j == 0 and optionals.mode == Constants.optionals.mode.queue) then
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x), y = (chunk_to_chart.center.y) },
            i = i,
            j = j,
        }, optionals)
    elseif (i == 0 and j == 0 and optionals.mode == Constants.optionals.mode.stack) then
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x + distance_modifier * a), y = (chunk_to_chart.center.y) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x - distance_modifier * a), y = (chunk_to_chart.center.y) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x), y = (chunk_to_chart.center.y + distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x), y = (chunk_to_chart.center.y - distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
    else
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x + distance_modifier * a), y = (chunk_to_chart.center.y + distance_modifier * math.sqrt(c ^ 2 - a ^ 2)) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x - distance_modifier * a), y = (chunk_to_chart.center.y + distance_modifier * math.sqrt(c ^ 2 - a ^ 2)) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x - distance_modifier * a), y = (chunk_to_chart.center.y - distance_modifier * math.sqrt(c ^ 2 - a ^ 2)) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x + distance_modifier * a), y = (chunk_to_chart.center.y - distance_modifier * math.sqrt(c ^ 2 - a ^ 2)) },
            i = i,
            j = j,
        }, optionals)

        -- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
        -- seems like overkill/unoptimal, though
        -- TODO: Improve this

        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x + distance_modifier * math.sqrt(c ^ 2 - a ^ 2)), y = (chunk_to_chart.center.y + distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x - distance_modifier * math.sqrt(c ^ 2 - a ^ 2)), y = (chunk_to_chart.center.y + distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x - distance_modifier * math.sqrt(c ^ 2 - a ^ 2)), y = (chunk_to_chart.center.y - distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
        Chunk_To_Chart_Repository.save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (chunk_to_chart.center.x + distance_modifier * math.sqrt(c ^ 2 - a ^ 2)), y = (chunk_to_chart.center.y - distance_modifier * a) },
            i = i,
            j = j,
        }, optionals)
    end

    j = j + 1

    chunk_to_chart[optionals.mode].j = j

    Log.debug(storage.all_seeing_satellite)

    return chunk_to_chart.complete
end

function scan_chunk_service.scan_selected_chunk(chunk_to_chart, optionals)
    Log.debug("scan_chunk_service.scan_selected_chunk")
    Log.info(chunk_to_chart)

    optionals = optionals or {
        mode = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name }) or Constants.optionals.DEFAULT.mode
    }

    local return_val = false

    if (not chunk_to_chart) then return return_val end
    Log.debug("1")
    if (not game or not game.forces) then return return_val end
    Log.debug("2")
    if (not chunk_to_chart.player_index or not game.forces[chunk_to_chart.player_index]) then return return_val end
    Log.debug("3")
    if (not chunk_to_chart.surface) then return return_val end
    Log.debug("4")
    if (not chunk_to_chart.pos or not chunk_to_chart.pos.x or not chunk_to_chart.pos.y) then return return_val end
    Log.debug("scanning")

    Log.info(chunk_to_chart)

    local distance_modifier = Constants.CHUNK_SIZE / 2

    game.forces[chunk_to_chart.player_index].chart(
        chunk_to_chart.surface, {
            { (chunk_to_chart.pos.x) - distance_modifier, (chunk_to_chart.pos.y) - distance_modifier },
            { (chunk_to_chart.pos.x) + distance_modifier, (chunk_to_chart.pos.y) + distance_modifier }
        })

    return_val = true
    return return_val
end

return scan_chunk_service
local storage

local game
local get_player

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_player = get_player or game.get_player

    Set_Game_Funcs()

    return game
end

local math_sqrt = math.sqrt

local string_find = string.find

local HALF_CHUNK = Constants.CHUNK_SIZE / 2
local MODE_QUEUE = Constants.optionals.mode.queue
local MODE_STACK = Constants.optionals.mode.stack

local Area_To_Chart_Repository = require("scripts.repositories.scanning.area-to-chart-repository")
local Chunk_To_Chart_Repository = require("scripts.repositories.scanning.chunk-to-chart-repository")
local save_chunk_to_chart_data = Chunk_To_Chart_Repository.save_chunk_to_chart_data

local satellite_scan_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name, })

local scan_chunk_service = {}

function scan_chunk_service.stage_selected_area(event)
    -- Log.debug("scan_chunk_service.stage_selected_area")
    -- Log.info(event)

    if (not event) then return end

    Area_To_Chart_Repository.save_area_to_chart_data(event)
end

function scan_chunk_service.clear_selected_chunks(event)
    Log.debug("scan_chunk_service.clear_selected_chunks")
    Log.info(event)

    local return_val = false

    if (not event) then return return_val end
    if (not event.player_index) then return return_val end

    local player = (game or set_game()) and get_player and get_player(event.player_index)
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

local fallback_optionals = {}
function scan_chunk_service.stage_selected_chunk(chunk_to_chart, optionals)
    -- Log.debug("scan_chunk_service.stage_selected_chunk")
    -- Log.info(chunk_to_chart)

    if (not optionals) then
        fallback_optionals.mode, fallback_optionals.i, fallback_optionals.j = satellite_scan_mode, 0, 0
        optionals = fallback_optionals
    end

    if (not chunk_to_chart) then return end
    -- Log.debug("1")
    game = game or set_game()
    if (not game or not game.forces) then return end
    -- Log.debug("2")
    if (not chunk_to_chart.player_index or not game.forces[chunk_to_chart.player_index]) then return end
    -- Log.debug("3")
    if (not chunk_to_chart.surface) then return end
    -- Log.debug("4")
    if (not chunk_to_chart.center or not chunk_to_chart.center.x or not chunk_to_chart.center.y) then return end
    -- Log.debug("staging chunk(s)")

    local radius = chunk_to_chart.radius

    if (optionals and optionals.i == nil) then optionals.i = 0 end
    if (optionals and optionals.j == nil) then optionals.j = 0 end

    -- Log.debug(chunk_to_chart)

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
    if (optionals.mode == MODE_STACK) then
        c = radius - i
    elseif (optionals.mode == MODE_QUEUE) then
        c = i
    end

    if (optionals.mode == MODE_STACK) then
        if (chunk_to_chart[optionals.mode].j > c or optionals.j > c) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            i = chunk_to_chart[optionals.mode].i
            j = 0
        end
    elseif (optionals.mode == MODE_QUEUE) then
        if (chunk_to_chart[optionals.mode].j > i or optionals.j > i) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            i = chunk_to_chart[optionals.mode].i
            j = 0
        end
    end

    local a = 0
    if (optionals.mode == MODE_STACK) then
        if (j > c) then
            chunk_to_chart[optionals.mode].i = chunk_to_chart[optionals.mode].i + 1
            chunk_to_chart[optionals.mode].j = 0
            return
        end
        a = c - j
    elseif (optionals.mode == MODE_QUEUE) then
        a = j
    end

    local distance_modifier = Constants.CHUNK_SIZE

    local center_x, center_y = chunk_to_chart.center.x, chunk_to_chart.center.y
    if (i == 0 and j == 0 and optionals.mode == MODE_QUEUE) then
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = center_x, y = center_y },
            i = i,
            j = j,
        })
    elseif (i == 0 and j == 0 and optionals.mode == MODE_STACK) then
        local distance_modifier_a = distance_modifier * a
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x + distance_modifier_a), y = center_y },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x - distance_modifier_a), y = center_y },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = center_x, y = (center_y + distance_modifier_a) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = center_x, y = (center_y - distance_modifier_a) },
            i = i,
            j = j,
        })
    else
        local distance_modifier_a = distance_modifier * a
        local distance_modifier_sqrt = distance_modifier * math_sqrt((c * c) - (a * a))
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x + distance_modifier_a), y = (center_y + distance_modifier_sqrt) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x - distance_modifier_a), y = (center_y + distance_modifier_sqrt) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x - distance_modifier_a), y = (center_y - distance_modifier_sqrt) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x + distance_modifier_a), y = (center_y - distance_modifier_sqrt) },
            i = i,
            j = j,
        })

        -- Not sure why part of the circle is missing, but doing it again with x and y ~flipped fixes the issue;
        -- seems like overkill/unoptimal, though
        -- TODO: Improve this

        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x + distance_modifier_sqrt), y = (center_y + distance_modifier_a) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x - distance_modifier_sqrt), y = (center_y + distance_modifier_a) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x - distance_modifier_sqrt), y = (center_y - distance_modifier_a) },
            i = i,
            j = j,
        })
        save_chunk_to_chart_data({
            chunk_to_chart = chunk_to_chart,
            pos = { x = (center_x + distance_modifier_sqrt), y = (center_y - distance_modifier_a) },
            i = i,
            j = j,
        })
    end

    j = j + 1

    chunk_to_chart[optionals.mode].j = j

    -- Log.debug(storage.all_seeing_satellite)

    return chunk_to_chart.complete
end

-- function scan_chunk_service.scan_selected_chunk(chunk_to_chart, optionals)
function scan_chunk_service.scan_selected_chunk(chunk_to_chart)
    -- Log.debug("scan_chunk_service.scan_selected_chunk")
    -- Log.info(chunk_to_chart)

    local return_val = false

    if (not chunk_to_chart) then return return_val end
    -- Log.debug("1")
    game = game or set_game()
    if (not game or not game.forces) then return return_val end
    -- Log.debug("2")
    if (not chunk_to_chart.player_index or not game.forces[chunk_to_chart.player_index]) then return return_val end
    -- Log.debug("3")
    if (not chunk_to_chart.surface) then return return_val end
    -- Log.debug("4")
    if (not chunk_to_chart.pos or not chunk_to_chart.pos.x or not chunk_to_chart.pos.y) then return return_val end
    -- Log.debug("scanning")

    -- Log.info(chunk_to_chart)

    local distance_modifier = HALF_CHUNK

    local position = chunk_to_chart.pos

    game.forces[chunk_to_chart.player_index].chart(
        chunk_to_chart.surface,
        {
            { (position.x) - distance_modifier, (position.y) - distance_modifier },
            { (position.x) + distance_modifier, (position.y) + distance_modifier },
        }
    )

    return_val = true
    return return_val
end

local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name] = function (event, params) satellite_scan_mode = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function scan_chunk_service.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "scan_chunk_service",
    func = scan_chunk_service.on_runtime_mod_setting_changed
})

function scan_chunk_service.init(__storage) storage = __storage end

return scan_chunk_service
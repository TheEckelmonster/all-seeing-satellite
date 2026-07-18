local storage

local game
local get_player

local force_funcs

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_player = get_player or game.get_player

    Set_Game_Funcs()
    force_funcs = _ENV.Force_Funcs

    return game
end

local string_find = string.find
local table_sort = table.sort
local type = type

local CHUNK_SIZE = Constants.CHUNK_SIZE
local HALF_CHUNK = Constants.CHUNK_SIZE / 2
local MODE_QUEUE = Constants.optionals.mode.queue

local Simple_Queue = Simple_Queue or require("scripts.data.simple-queue")
local new_Simple_Queue = Simple_Queue.new

local Chunk_To_Chart_Repository = require("scripts.repositories.scanning.chunk-to-chart-repository")
local save_chunk_to_chart_data = Chunk_To_Chart_Repository.save_chunk_to_chart_data

local satellite_scan_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name, })

local scan_chunk_service = {}

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
local function sort(a, b) return a.dist_sq < b.dist_sq end
function scan_chunk_service.stage_selected_chunk(chunk_to_chart, optionals)
    if (not chunk_to_chart) then return end

    if (not chunk_to_chart.surface) then return end
    if (not chunk_to_chart.center) then return end
    local center = chunk_to_chart.center
    if (not center.x or not center.y) then return end

    if (not optionals) then
        fallback_optionals.mode = satellite_scan_mode
        optionals = fallback_optionals
    end
    optionals.mode = optionals.mode or satellite_scan_mode
    local selected_mode = optionals.mode
    chunk_to_chart[selected_mode] = chunk_to_chart[selected_mode] or {}
    local mode = chunk_to_chart[selected_mode]
    local radius = chunk_to_chart.radius or 0

    -- local chunk_list = chunk_to_chart.chunk_list
    -- if (not chunk_list) then
    --     chunk_to_chart.chunk_list = new_Simple_Queue(Simple_Queue)
    --     chunk_list = chunk_to_chart.chunk_list

    --     local chunk_count = 0
    --     for x = -radius, radius do
    --         for y = -radius, radius do
    --             local dist_sq = (x * x) + (y * y)
    --             if dist_sq <= (radius * radius) then
    --                 chunk_count = chunk_count + 1

    --                 chunk_list.q[chunk_count] = { x = x, y = y, dist_sq = dist_sq, }
    --                 chunk_list.last = chunk_count + 1
    --             end
    --         end
    --     end

    --     table_sort(chunk_list.q, sort)
    --     chunk_list.count = chunk_count
    -- end
    local chunk_list = chunk_to_chart.chunk_list
    if (not chunk_list) then
        chunk_to_chart.chunk_list = new_Simple_Queue(Simple_Queue)
        chunk_list = chunk_to_chart.chunk_list

        chunk_to_chart.gen_x = -radius
        chunk_to_chart.gen_y = -radius
        chunk_to_chart.gen_count = 0
    end

    if chunk_to_chart.gen_x and chunk_to_chart.gen_x <= radius then
        local budget = 256
        local evaluations = 0
        local chunk_count = chunk_to_chart.gen_count

        local x = chunk_to_chart.gen_x
        local y = chunk_to_chart.gen_y
        local radius_sq = radius * radius

        while (x <= radius) and (evaluations < budget) do
            while (y <= radius) and (evaluations < budget) do
                evaluations = evaluations + 1
                local dist_sq = (x * x) + (y * y)
                if (dist_sq <= radius_sq) then
                    chunk_count = chunk_count + 1
                    chunk_list.q[chunk_count] = { x = x, y = y, dist_sq = dist_sq }
                    chunk_list.last = chunk_count + 1
                end
                y = y + 1
            end

            if y > radius then
                x = x + 1
                y = -radius
            end
        end

        chunk_to_chart.gen_x = x
        chunk_to_chart.gen_y = y
        chunk_to_chart.gen_count = chunk_count

        if (x > radius) then
            table_sort(chunk_list.q, sort)
            chunk_list.count = chunk_count
            chunk_to_chart.gen_x = nil
            chunk_to_chart.gen_y = nil
        else
            return chunk_to_chart.complete
        end
    end

    chunk_list = chunk_list or chunk_to_chart.chunk_list
    local chunk_count = chunk_list.count
    local step = chunk_list.first
    if (selected_mode ~= MODE_QUEUE) then step = chunk_count end

    if (step > chunk_count or chunk_count < 1) then
        mode.step = step
        chunk_to_chart.complete = true
        return true
    end

    local target_chunk = chunk_list.q[step]
    if (not target_chunk) then
        mode.step = step
        chunk_to_chart.complete = true
        return true
    end

    local center_x = center.x
    local center_y = center.y

    local final_x = center_x + (target_chunk.x * CHUNK_SIZE)
    local final_y = center_y + (target_chunk.y * CHUNK_SIZE)

    save_chunk_to_chart_data(chunk_to_chart, { x = final_x, y = final_y })

    if (selected_mode == MODE_QUEUE) then
        step = step + 1
    else
        step = step - 1
    end

    if (chunk_count > 0) then
        if (satellite_scan_mode == MODE_QUEUE) then
            chunk_list.q[chunk_list.first] = nil
            chunk_list.first = chunk_list.first + 1
        else
            chunk_list.q[chunk_count] = nil
            chunk_list.count = chunk_count - 1
        end
    end

    mode.step = step
    if (selected_mode == MODE_QUEUE) then
        if (step > chunk_list.count) then
            chunk_to_chart.complete = true
            return true
        end
    else
        if (step < chunk_list.first) then
            chunk_to_chart.complete = true
            return true
        end
    end

    return chunk_to_chart.complete
end

function scan_chunk_service.scan_selected_chunk(chunk_to_chart)
    -- Log.debug("scan_chunk_service.scan_selected_chunk")
    -- Log.info(chunk_to_chart)
    if (not chunk_to_chart) then return end

    local force_index = chunk_to_chart.force_index
    if (not force_index or force_index < 1) then
        if (not chunk_to_chart.player_index or not ((game or set_game()) and get_player)) then return end
        local player = get_player(chunk_to_chart.player_index)
        if (not player or not player.valid) then return end
        local force = player.force
        if (not force or not force.valid) then return end
        force_index = force.index
    end

    force_funcs = force_funcs or set_game() and force_funcs
    if (not force_funcs[force_index]) then return end
    if (not force_funcs[force_index].chart) then return end
    if (not chunk_to_chart.surface) then return end
    local pos = chunk_to_chart.pos
    if (not pos or not pos.x or not pos.y) then return end

    local pos_x, pos_y = pos.x, pos.y

    force_funcs[force_index].chart(
        chunk_to_chart.surface,
        {
            { (pos_x) - HALF_CHUNK, (pos_y) - HALF_CHUNK },
            { (pos_x) + HALF_CHUNK, (pos_y) + HALF_CHUNK },
        }
    )

    return true
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
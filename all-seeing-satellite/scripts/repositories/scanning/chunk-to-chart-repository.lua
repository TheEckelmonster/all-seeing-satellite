local storage

local game
local get_player

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_player = game.get_player

    Set_Game_Funcs()

    return game
end

local pairs = pairs
local string_find = string.find
local table_remove = table.remove
local table_size = table_size
local type = type

local OPTIONAL_MODE_QUEUE = Constants.optionals.mode.queue

local NUMBER = Types.NUMBER
local TABLE = Types.TABLE

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local get_all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data
local Chunk_To_Chart_Data = require("scripts.data.scanning.chunk-to-chart-data")
local new_Chunk_To_Chart_Data = Chunk_To_Chart_Data.new

local satellite_scan_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name, })

local chunk_to_chart_repository = {}
chunk_to_chart_repository.name = "chunk_to_chart_repository"
chunk_to_chart_repository.set_game = set_game

function chunk_to_chart_repository.save_chunk_to_chart_data(chunk_to_chart, pos)
    -- Log.debug("chunk_to_chart_repository.save_chunk_to_chart_data")
    -- Log.info(params)

    if (not chunk_to_chart) then return end
    if (not pos) then return end
    if (not pos.x or not pos.y) then return end

    if (not chunk_to_chart.player_index or not ((game or set_game()) and get_player)) then return end
    local player = get_player(chunk_to_chart.player_index)
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end

    local surface = chunk_to_chart.surface
    if (not surface or not surface.valid) then return end

    local tick = (game or set_game()).tick

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    all_seeing_satellite_data.staged_chunks_to_chart[tick] = all_seeing_satellite_data.staged_chunks_to_chart[tick] or {}
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart[tick]

    local return_val = new_Chunk_To_Chart_Data(Chunk_To_Chart_Data)

    return_val.area = chunk_to_chart.area
    return_val.center = chunk_to_chart.center
    return_val.id = tick
    return_val.player_index = chunk_to_chart.player_index
    return_val.force_index = force.index
    return_val.pos = pos
    return_val.radius = chunk_to_chart.radius
    return_val.surface = surface
    return_val.surface_index = surface.index

    staged_chunks_to_chart[#staged_chunks_to_chart+1] = return_val

    return return_val
end

function chunk_to_chart_repository.update_chunk_to_chart_data(update_data, index)
    -- Log.debug("chunk_to_chart_repository.update_chunk_to_chart_data")
    -- Log.info(update_data)
    -- Log.info(index)

    local return_val = new_Chunk_To_Chart_Data(Chunk_To_Chart_Data)

    if (not update_data or type(update_data) ~= TABLE) then return return_val end

    local tick = (game or set_game()).tick

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    all_seeing_satellite_data.staged_chunks_to_chart[tick] = all_seeing_satellite_data.staged_chunks_to_chart[tick] or {}
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart[tick]
    -- Use the provided index if it exists; otherwise update the most recently added chunk
    index = index and index >= 1 and index <= #staged_chunks_to_chart and index or #staged_chunks_to_chart

    for i, chunk_to_chart in pairs(staged_chunks_to_chart) do
        if (i == index) then
            return_val = chunk_to_chart; break
        end
    end

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = tick

    return return_val
end

function chunk_to_chart_repository.delete_chunk_to_chart_data()
    -- Log.debug("chunk_to_chart_repository.delete_chunk_to_chart_data")

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart

    if (table_size(staged_chunks_to_chart) > 0) then
        if (satellite_scan_mode == OPTIONAL_MODE_QUEUE) then
            for k, v in pairs(staged_chunks_to_chart) do
                staged_chunks_to_chart[k] = nil
                break
            end
        else
            local obj = {}
            for k, v in pairs(staged_chunks_to_chart) do
                obj.k = k
                obj.v = staged_chunks_to_chart[k]
            end
            staged_chunks_to_chart[obj.k] = nil
        end
    end

    return staged_chunks_to_chart
end

function chunk_to_chart_repository.delete_chunk_to_chart_data_by_index(params)
    -- Log.debug("chunk_to_chart_repository.delete_chunk_to_chart_data_by_index")
    -- Log.info(params)
    -- Log.info(optionals)

    local return_val = false

    if (not params or type(params) ~= TABLE) then return end
    if (not params.pos or type(params.pos) ~= NUMBER) then return end

    local index_pos = params.pos
    if (index_pos < 1) then return return_val end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart

    if (index_pos > table_size(staged_chunks_to_chart)) then return end

    table_remove(staged_chunks_to_chart, index_pos)
    return_val = true

    return return_val
end

function chunk_to_chart_repository.get_chunk_to_chart_data()
    -- Log.debug("chunk_to_chart_repository.get_chunk_to_chart_data")

    local return_val = new_Chunk_To_Chart_Data(Chunk_To_Chart_Data)

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart

    for _, v in pairs(staged_chunks_to_chart) do
        return_val = v
        if (satellite_scan_mode == OPTIONAL_MODE_QUEUE) then break end
    end

    return return_val
end

function chunk_to_chart_repository.get_chunk_to_chart_data_by_index(params)
    -- Log.debug("chunk_to_chart_repository.get_chunk_to_chart_data")
    -- Log.info(params)

    local return_val = new_Chunk_To_Chart_Data(Chunk_To_Chart_Data)

    if (not params or type(params) ~= TABLE) then return end
    if (not params.pos or type(params.pos) ~= NUMBER) then return end

    local index_pos = params.pos
    if (index_pos < 1) then index_pos = 1 end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_chunks_to_chart = all_seeing_satellite_data.staged_chunks_to_chart

    if (index_pos > #staged_chunks_to_chart) then return end

    for i, chunks_to_chart in pairs(staged_chunks_to_chart) do
        if (i == index_pos) then
            return_val = chunks_to_chart; break
        end
    end

    return return_val
end

function chunk_to_chart_repository.get_all_chunk_to_chart_data()
    -- Log.debug("chunk_to_chart_repository.get_all_chunk_to_chart_data")

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    return all_seeing_satellite_data.staged_chunks_to_chart
end

local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name] = function (event, params) satellite_scan_mode = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function chunk_to_chart_repository.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "chunk_to_chart_repository",
    func = chunk_to_chart_repository.on_runtime_mod_setting_changed
})

function chunk_to_chart_repository.init(__storage) storage = __storage end

return chunk_to_chart_repository
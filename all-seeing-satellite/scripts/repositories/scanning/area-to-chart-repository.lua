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

local math_floor = math.floor
local math_sqrt = math.sqrt

local string_find = string.find

local pairs = pairs
local table_remove = table.remove
local type = type

local CHUNK_SIZE = Constants.CHUNK_SIZE
local OPTIONAL_MODE_QUEUE = Constants.optionals.mode.queue

local NUMBER = Types.NUMBER
local TABLE = Types.TABLE

local Area_To_Chart_Data = require("scripts.data.scanning.area-to-chart-data")
local new_Area_To_Chart_Data = Area_To_Chart_Data.new
local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local get_all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data

local satellite_scan_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name, })

local area_to_chart_repository = {}
area_to_chart_repository.name = "area_to_chart_repository"
area_to_chart_repository.set_game = set_game

function area_to_chart_repository.save_area_to_chart_data(params)
    -- Log.debug("area_to_chart_repository.save_area_to_chart_data")
    -- Log.info(params)

    local return_val = new_Area_To_Chart_Data(Area_To_Chart_Data)

    if (not params or type(params) ~= TABLE) then return end
    if (not params.area) then return end
    local area = params.area
    if (not area.left_top or not params.area.right_bottom) then return end
    local left_top = area.left_top
    if (not left_top.x or not left_top.y) then return end
    local right_bottom = area.right_bottom
    if (not right_bottom.x or not right_bottom.y) then return end

    if (not params.player_index or not ((game or set_game()) and get_player)) then return end
    local player = get_player(params.player_index)
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end

    local surface = params.surface
    if (not surface or not surface.valid) then return end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    all_seeing_satellite_data.staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart or {}
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    local center = {
        x = (left_top.x + right_bottom.x) / 2,
        y = (left_top.y + right_bottom.y) / 2
    }

    local dx = center.x - right_bottom.x
    local dy = center.y - right_bottom.y
    local radius = math_floor(math_sqrt((dx * dx) + (dy * dy)) / CHUNK_SIZE)

    return_val.area = area
    return_val.center = center
    return_val.id = (game or set_game()).tick
    return_val.player_index = params.player_index
    return_val.force_index = force.index
    return_val.pos = return_val.pos or {}
    local pos = return_val.pos
    pos.x, pos.y = center.x, center.y
    return_val.radius = radius
    return_val.surface = surface
    return_val.surface_name = surface.name
    return_val.surface_index = surface.index

    staged_areas_to_chart[#staged_areas_to_chart+1] = return_val

    return return_val
end

function area_to_chart_repository.update_area_to_chart_data(update_data, index)
    -- Log.debug("area_to_chart_repository.update_area_to_chart_data")
    -- Log.info(update_data)
    -- Log.info(index)

    local return_val = new_Area_To_Chart_Data(Area_To_Chart_Data)

    if (not update_data or type(update_data) ~= TABLE) then return end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    -- Use the provided index if it exists; otherwise update the most recently added area
    index = index or #staged_areas_to_chart

    for i, area_to_chart in pairs(staged_areas_to_chart) do
        if (i == index) then
            return_val = area_to_chart; break
        end
    end

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = (game or set_game()).tick

    return return_val
end

function area_to_chart_repository.delete_area_to_chart_data(params)
    -- Log.debug("area_to_chart_repository.delete_area_to_chart_data")
    -- Log.info(params)

    local return_val = false

    if (not params or type(params) ~= TABLE) then return end
    if (not params.pos or type(params.pos) ~= NUMBER) then return end

    local index_pos = params.pos
    if (index_pos < 1) then return end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    if (index_pos > #staged_areas_to_chart) then return end

    table_remove(staged_areas_to_chart, index_pos)
    return_val = true

    return return_val
end

function area_to_chart_repository.delete_area_to_chart_data_by_id(id)
    -- Log.debug("area_to_chart_repository.delete_area_to_chart_data_by_id")
    -- Log.info(id)

    local return_val = false

    if (not id or type(id) ~= NUMBER) then return end

    if (id < 1) then return end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    for k, area_to_chart_data in pairs(staged_areas_to_chart) do
        if (area_to_chart_data.id == id) then
            staged_areas_to_chart[k] = nil
            return_val = true
            break
        end
    end

    return return_val
end

function area_to_chart_repository.get_area_to_chart_data()
    -- Log.debug("area_to_chart_repository.get_area_to_chart_data")

    local return_val = new_Area_To_Chart_Data(Area_To_Chart_Data)

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    for _, v in pairs(staged_areas_to_chart) do
        return_val = v
        if (satellite_scan_mode == OPTIONAL_MODE_QUEUE) then break end
    end

    return return_val
end

function area_to_chart_repository.get_area_to_chart_data_by_index(params)
    -- Log.debug("area_to_chart_repository.get_area_to_chart_data_by_index")
    -- Log.info(params)

    local return_val = new_Area_To_Chart_Data(Area_To_Chart_Data)

    if (not params or type(params) ~= TABLE) then return end
    if (not params.pos or type(params.pos) ~= NUMBER) then return end

    local index_pos = params.pos
    if (index_pos < 1) then
        index_pos = 1
    end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    local staged_areas_to_chart = all_seeing_satellite_data.staged_areas_to_chart

    if (index_pos > #staged_areas_to_chart) then return end

    for i, area_to_chart in pairs(staged_areas_to_chart) do
        if (i == index_pos) then
            return_val = area_to_chart; break
        end
    end

    return return_val
end

function area_to_chart_repository.get_all_area_to_chart_data()
    -- Log.debug("area_to_chart_repository.get_all_area_to_chart_data")

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end
    return all_seeing_satellite_data.staged_areas_to_chart
end

local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name] = function (event, params) satellite_scan_mode = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function area_to_chart_repository.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "area_to_chart_repository",
    func = area_to_chart_repository.on_runtime_mod_setting_changed
})

function area_to_chart_repository.init(__storage) storage = __storage end

return area_to_chart_repository
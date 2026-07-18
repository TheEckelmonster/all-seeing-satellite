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

local ipairs = ipairs
local math_floor = math.floor
local pairs = pairs
local string_find = string.find

local table_size = table_size
local script = script
local active_mods = script and script.active_mods

local TICKS_PER_SECOND = Constants.TICKS_PER_SECOND

local MSG_SCAN_COMPLETE_TBL = { "messages.scan-complete", }
local MSG_START_SCAN_TBL = { "messages.start-scan", }

local EMPTY = EMPTY

local Data_Utils = Data_Utils
local Settings_Registry = Settings_Registry

local Area_To_Chart_Repository = require("scripts.repositories.scanning.area-to-chart-repository")
local get_area_to_chart_data = Area_To_Chart_Repository.get_area_to_chart_data
local update_area_to_chart_data = Area_To_Chart_Repository.update_area_to_chart_data
local delete_area_to_chart_data_by_id = Area_To_Chart_Repository.delete_area_to_chart_data_by_id
local Chunk_To_Chart_Repository = require("scripts.repositories.scanning.chunk-to-chart-repository")
local get_chunk_to_chart_data = Chunk_To_Chart_Repository.get_chunk_to_chart_data
local delete_chunk_to_chart_data = Chunk_To_Chart_Repository.delete_chunk_to_chart_data
local Planet_Utils = require("scripts.utils.planet-utils")
local allow_scan = Planet_Utils.allow_scan
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local update_satellite_meta_data = Satellite_Meta_Repository.update_satellite_meta_data
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local Satellite_Repository = require("scripts.repositories.satellite-repository")
local add_satellite_data_to_cooldown = Satellite_Repository.add_satellite_data_to_cooldown
local Scan_Chunk_Service = require("scripts.services.scan-chunk-service")
local stage_selected_chunk = Scan_Chunk_Service.stage_selected_chunk
local scan_selected_chunk = Scan_Chunk_Service.scan_selected_chunk
local Satellite_Utils = require("scripts.utils.satellite-utils")
local get_quality_multiplier = Satellite_Utils.get_quality_multiplier

local quality_active = active_mods and active_mods["quality"]

local satellite_scan_cooldown_duration = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION.name, }) * TICKS_PER_SECOND
local satellite_scan_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name, })
local restrict_satellite_scanning = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name, })

local all_seeing_satellite_service = {}

function all_seeing_satellite_service.check_for_areas_to_stage()
    -- Log.debug("all_seeing_satellite_service.check_for_areas_to_stage")

    local optionals = { mode = satellite_scan_mode, }

    local area_to_chart = get_area_to_chart_data()

    if (not area_to_chart) then return end
    if (not allow_scan(area_to_chart.surface_name)) then return end

    if (not area_to_chart.started) then
        local player = (game or set_game()) and get_player and get_player(area_to_chart.player_index)
        if (player and player.valid) then
            player.force.print(MSG_START_SCAN_TBL)
        end

        update_satellite_meta_data({ scanned = false, }, area_to_chart.surface_name)
        stage_selected_chunk(area_to_chart, optionals)
        update_area_to_chart_data({ started = true, })
    end

    local chunks_to_chart = get_chunk_to_chart_data()

    if (not restrict_satellite_scanning) then
        stage_selected_chunk(area_to_chart, optionals)
    else
        local satellite_meta_data = get_satellite_meta_data(area_to_chart.surface.name)
        if (not satellite_meta_data) then return end
        local satellites = satellite_meta_data.satellites_cooldown

        local tick = (game or set_game()).tick

        for k, satellite in pairs(satellites) do
            if (satellite and satellite.tick_off_cooldown and tick > satellite.tick_off_cooldown) then
                if (    satellite_meta_data.scanned
                    or  (chunks_to_chart and #chunks_to_chart == 0 and not area_to_chart.complete)
                ) then
                    stage_selected_chunk(area_to_chart, optionals)
                    update_satellite_meta_data({ scanned = false, }, area_to_chart.surface.name)
                end
            end
            break
        end
    end

    if (area_to_chart.complete) then
        if (not delete_area_to_chart_data_by_id(area_to_chart.id)) then return end

        local _area_to_check = get_area_to_chart_data()
        if (not area_to_chart) then return end

        if (_area_to_check and #_area_to_check == 0 and chunks_to_chart and #chunks_to_chart == 0) then
            if (area_to_chart and area_to_chart.player_index) then
                local player = (game or set_game()) and get_player and get_player(area_to_chart.player_index)
                if (player and player.valid) then
                    player.force.print(MSG_SCAN_COMPLETE_TBL)
                end
            end
        end
    end

    return true
end

function all_seeing_satellite_service.do_scan(surface_name)
    -- Log.debug("all_seeing_satellite_service.do_scan")
    local chunks_to_chart = get_chunk_to_chart_data()
    if (not chunks_to_chart) then
        return
    elseif (chunks_to_chart and #chunks_to_chart == 0) then
        local result = delete_chunk_to_chart_data()

        if (result and table_size(result) == 0) then
            update_satellite_meta_data({ scanned = true, }, surface_name)
        end

        return
    end

    local tick = (game or set_game()).tick

    local i = 0
    local do_break = false
    local chunk_surface_name = EMPTY
    for k, chunk_to_chart in ipairs(chunks_to_chart) do
        chunk_surface_name = chunk_to_chart.surface.name or EMPTY

        if (not restrict_satellite_scanning) then
            if (scan_selected_chunk(chunk_to_chart)) then
                chunks_to_chart[k] = nil

                if (chunks_to_chart and #chunks_to_chart == 0) then
                    local result = delete_chunk_to_chart_data()
                    if (result and table_size(result) == 0) then
                        local area_to_chart = get_area_to_chart_data()

                        if (area_to_chart and area_to_chart.complete) then
                            local player = (game or set_game()) and get_player and get_player(area_to_chart.player_index)
                            if (player and player.valid) then
                                player.force.print(MSG_SCAN_COMPLETE_TBL)
                            end
                        end
                        update_satellite_meta_data({ scanned = true, }, chunk_surface_name)
                    end
                end
            end
        else
            if (allow_scan(chunk_surface_name)) then
                local satellite_meta_data = get_satellite_meta_data(chunk_surface_name)
                if (not satellite_meta_data) then return end
                if (not satellite_meta_data.satellites_cooldown) then break end

                for id, satellite in pairs(satellite_meta_data.satellites_cooldown) do
                    if (satellite.tick_off_cooldown < tick) then
                        if (scan_selected_chunk(chunk_to_chart)) then
                            local quality_modifier = quality_active and get_quality_multiplier(satellite.quality) or 1
                            local use_cooldown = 0
                            if (satellite_scan_cooldown_duration > 0) then use_cooldown = 1 end

                            quality_modifier = ((quality_modifier - 1) * 2) + 1

                            satellite.tick_off_cooldown = tick
                                + math_floor(satellite.scan_count * 0.025 * use_cooldown)
                                + math_floor((satellite_scan_cooldown_duration) * (1 / quality_modifier))
                            satellite.scan_count = satellite.scan_count + 1

                            add_satellite_data_to_cooldown({
                                satellite = satellite,
                                planet_name = chunk_surface_name,
                            })
                            satellite_meta_data.satellites_cooldown[id] = nil
                            satellite_meta_data.updated = tick
                            chunks_to_chart[k] = nil

                            if (chunks_to_chart and #chunks_to_chart == 0) then
                                local result = delete_chunk_to_chart_data()
                                if (result and table_size(result) == 0) then
                                    update_satellite_meta_data({ scanned = true, }, chunk_surface_name)
                                end
                            end

                            i = i + 1
                            break
                        end
                    else
                        do_break = true
                    end
                    break
                end
            end
        end

        if (do_break) then break end

        i = i + 1
    end
end

local update_settings = {}

update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_COOLDOWN_DURATION.name] = function (event, params) satellite_scan_cooldown_duration = (params.setting_value or 1) * TICKS_PER_SECOND end
update_settings[Runtime_Global_Settings_Constants.settings.SATELLITE_SCAN_MODE.name] = function (event, params) satellite_scan_mode = params.setting_value end
update_settings[Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_SCANNING.name] = function (event, params) restrict_satellite_scanning = params.setting_value end

local STRING = Types.STRING
local MOD_NAME_PREFIX = MOD_NAME_PREFIX
function all_seeing_satellite_service.on_runtime_mod_setting_changed(event, params)
    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, MOD_NAME_PREFIX, 1, true) == 1)) then return end

    if (update_settings[event.setting]) then
        update_settings[event.setting](event, params)
    end
end
Settings_Registry:register_setting({
    func_name = "all_seeing_satellite_service",
    func = all_seeing_satellite_service.on_runtime_mod_setting_changed
})

function all_seeing_satellite_service.init(__storage) storage = __storage end

return all_seeing_satellite_service
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

local SATELLITE_SCANNING_REMOTE = "satellite-scanning-remote"

local MSG_3PARAM_TBL =  { [1] = "", [2] = { "messages.scanning-invalid-surface-detected",}}
local MSG_6PARAM_TBL =  { [1] = "", [2] = { "toggle.insufficient", }, [4] = " : ", [6] = { "toggle.insufficient-suffix", }, }

local MSG_SCANNING_NOT_ALLOWED_IN_SPACE_TBL = { "messages.scanning-not-allowed-in-space", }
local MSG_SCANNING_NOT_ALLOWED_TBL = { "messages.scanning-not-allowed", }

local MSG_WARN_ROCKET_SILO_RESEARCH = { "messages.warn-rocket-silo-research", }

local MSG_WARN_SCANNING_NOT_ENABLED_TBL = { "messages.warn-scanning-not-enabled", }
local MSG_TOGGLE_SCANNING_TBL = { "messages.toggle-scanning", }
local MSG_CANCEL_SCANNING_TBL = { "messages.cancel-scanning", }

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local get_all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data
local Planet_Utils = require("scripts.utils.planet-utils")
local allow_scan = Planet_Utils.allow_scan
local Research_Utils = require("scripts.utils.research-utils")
local has_technology_researched = Research_Utils.has_technology_researched
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local Scan_Chunk_Service = require("scripts.services.scan-chunk-service")
local clear_selected_chunks = Scan_Chunk_Service.clear_selected_chunks
local String_Utils = require("scripts.utils.string-utils")

local scan_chunk_controller = {}
scan_chunk_controller.name = "scan_chunk_controller"
scan_chunk_controller.set_game = set_game

function scan_chunk_controller.stage_selected_chunks(event)
    -- Log.debug("scan_chunk_controller.stage_selected_chunk")
    -- Log.info(event)

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (not event or not event.item or event.item ~= SATELLITE_SCANNING_REMOTE) then return end
    if (not event.player_index or not event.area) then return end

    local player = (game or set_game()) and get_player and get_player(event.player_index)
    if (not player or not player.valid) then return end

    if (not event.surface or not event.surface.valid) then return end

    local surface_name = event.surface.name
    local player_print = player.print

    -- No need to scan in space
    if (event.surface.platform ~= nil) then
        player_print(MSG_SCANNING_NOT_ALLOWED_IN_SPACE_TBL)
        return
    end

    if (String_Utils.find_invalid_substrings(surface_name)) then
        MSG_3PARAM_TBL[3] = surface_name
        player_print(MSG_3PARAM_TBL)
        player_print(MSG_SCANNING_NOT_ALLOWED_TBL)
        return
    end

    if (not allow_scan(surface_name)) then
        if (not has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
            player_print(MSG_WARN_ROCKET_SILO_RESEARCH)
        else
            local satellite_meta_data = get_satellite_meta_data(surface_name)
            if (not satellite_meta_data) then return end
            MSG_6PARAM_TBL[3], MSG_6PARAM_TBL[5] = surface_name, satellite_meta_data.satellites_in_orbit
            player_print(MSG_6PARAM_TBL)
        end

        return
    end

    if (not all_seeing_satellite_data.do_scan) then
        player_print(MSG_WARN_SCANNING_NOT_ENABLED_TBL)
        player_print(MSG_TOGGLE_SCANNING_TBL)
        player_print(MSG_CANCEL_SCANNING_TBL)
        return
    end

    Scan_Chunk_Service.stage_selected_area(event)
end
Event_Handler:register_event({
    event_name = "on_player_selected_area",
    source_name = "scan_chunk_controller.stage_selected_chunks",
    func_name = "scan_chunk_controller.stage_selected_chunks",
    func = scan_chunk_controller.stage_selected_chunks,
})

function scan_chunk_controller.clear_selected_chunks(event)
    -- Log.debug("scan_chunk_controller.clear_selected_chunks")
    -- Log.info(event)

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (not event or not event.item or event.item ~= SATELLITE_SCANNING_REMOTE) then return end
    if (not event.surface or not event.surface.valid) then return end
    -- No need to scan in space
    if (event.surface.platform ~= nil) then return end
    if (not event.player_index or not event.area) then return end
    if (not event.surface or not event.surface.valid) then return end
    if (not allow_scan(event.surface.name)) then return end

    clear_selected_chunks(event)
end
-- Event_Handler:register_event({
--     event_name = "on_player_reverse_selected_area",
--     source_name = "scan_chunk_controller.clear_selected_chunks",
--     func_name = "scan_chunk_controller.clear_selected_chunks",
--     func = scan_chunk_controller.clear_selected_chunks,
-- })

function scan_chunk_controller.init(__storage) storage = __storage end

return scan_chunk_controller
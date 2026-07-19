local storage

local game
local get_player
local get_surface

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_player = get_player or game.get_player
    get_surface = get_surface or game.get_surface

    Set_Game_Funcs()

    return game
end

local MSG_CANCELLING_SCANS = "messages.cancelling-scans"
local MSG_RESEARCH_NOT_MET = "messages.research-not-met"
local MSG_INVALID_SURFACE_DETECTED = "messages.invalid-surface-detected"
local MSG_TOGGLE_SCAN_OFF = "messages.toggle-scans-off"
local MSG_TOGGLE_SCAN_ON  = "messages.toggle-scans-on"

local MSG_TOGGLE_SCAN_OFF_TBL = { MSG_TOGGLE_SCAN_OFF, }
local MSG_TOGGLE_SCAN_ON_TBL  = { MSG_TOGGLE_SCAN_ON, }
local MSG_CANCELLING_SCANS_TBL = { MSG_CANCELLING_SCANS, }
local MSG_RESEARCH_NOT_MET_TBL = { MSG_RESEARCH_NOT_MET, }

local TOGGLE_DISABLED = "toggle.disabled"
local TOGGLE_ENABLED = "toggle.enabled"
local TOGGLE_INSUFFICIENT = "toggle.insufficient"

local TOGGLE_DISABLED_TBL = { TOGGLE_DISABLED,}
local TOGGLE_ENABLED_TBL = { TOGGLE_ENABLED, }
local TOGGLE_INSUFFICIENT_TBL = { TOGGLE_INSUFFICIENT, }

local Event_Handler = Event_Handler

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local get_all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local TOGGLE_FOG_OF_WAR_CUSTOM_INPUT_NAME = Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name
local TOGGLE_SCANNING_CUSTOM_INPUT_NAME = Custom_Input_Constants.TOGGLE_SCANNING.name
local Fog_Of_War_Utils = require("scripts.utils.fog-of-war-utils")
local print_toggle_message = Fog_Of_War_Utils.print_toggle_message
local Initialization = require("scripts.initialization")
local Planet_Utils = require("scripts.utils.planet-utils")
local allow_toggle = Planet_Utils.allow_toggle
local Research_Utils = require("scripts.utils.research-utils")
local has_technology_researched = Research_Utils.has_technology_researched
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data
local update_satellite_meta_data = Satellite_Meta_Repository.update_satellite_meta_data
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local fog_of_war_controller = {}
fog_of_war_controller.name = "fog_of_war_controller"
fog_of_war_controller.set_game = set_game

function fog_of_war_controller.toggle_scanning(event)
    -- Log.debug("fog_of_war_controller.toggle_scanning")
    -- Log.info(event)

    -- Validate inputs
    if (not event) then return end
    if (event.input_name ~= TOGGLE_SCANNING_CUSTOM_INPUT_NAME) then return end
    if (not event.player_index) then return end
    local player = (game or set_game()) and get_player and get_player(event.player_index)
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end

    local all_seeing_satellite_data = get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data) then return end

    if (all_seeing_satellite_data.do_scan) then
        force.print(MSG_TOGGLE_SCAN_OFF_TBL)
        all_seeing_satellite_data.do_scan = false
    else
        force.print(MSG_TOGGLE_SCAN_ON_TBL)
        all_seeing_satellite_data.do_scan = true
    end
    all_seeing_satellite_data.updated = event.tick
end
Event_Handler:register_event({
    event_name = Custom_Input_Constants.TOGGLE_SCANNING.name,
    source_name = "fog_of_war_controller.toggle_scanning",
    func_name = "fog_of_war_controller.toggle_scanning",
    func = fog_of_war_controller.toggle_scanning,
})

function fog_of_war_controller.cancel_scanning(event)
    -- Log.debug("fog_of_war_controller.cancel_scanning")
    -- Log.info(event)

    -- Validate inputs
    if (not event) then return end
    if (event.input_name ~= Custom_Input_Constants.CANCEL_SCANNING.name) then return end
    if (not event.player_index) then return end
    local player = (game or set_game()) and get_player and get_player(event.player_index)
    if (not player or not player.valid) then return end
    local force = player.force
    if (not force or not force.valid) then return end
    force.print(MSG_CANCELLING_SCANS_TBL)
    force.cancel_charting()

    local all_seeing_satellite_data = get_all_seeing_satellite_data()

    all_seeing_satellite_data.staged_areas_to_chart = {}
    all_seeing_satellite_data.staged_chunks_to_chart = {}
    all_seeing_satellite_data.updated = game.tick
end
Event_Handler:register_event({
    event_name = Custom_Input_Constants.CANCEL_SCANNING.name,
    source_name = "fog_of_war_controller.cancel_scanning",
    func_name = "fog_of_war_controller.cancel_scanning",
    func = fog_of_war_controller.cancel_scanning,
})

function fog_of_war_controller.toggle(event)
    -- Log.debug("fog_of_war_controller.toggle")
    -- Log.info(event)

    if (not event) then return end
    local name = event.input_name or event.prototype_name

    if (name ~= TOGGLE_FOG_OF_WAR_CUSTOM_INPUT_NAME) then return end

    local player = (game or set_game()) and get_player and get_player(event.player_index)
    if (not player or not player.valid) then return end
    if (not player.surface or not player.surface.valid) then return end
    if (not player.force or not player.force.valid) then return end

    local satellite_meta_data = get_satellite_meta_data(player.surface.name)
    if (not satellite_meta_data) then return end

    local satellites_toggled = satellite_meta_data.satellites_toggled

    if (not satellites_toggled) then Initialization.reinit() end

    if (player and player.surface and player.surface.name) then
        local surface_name = player.surface.name

        if (    not allow_toggle(surface_name)
            and not has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)
        ) then
            player.print(MSG_RESEARCH_NOT_MET_TBL)
            return
        end

        update_satellite_meta_data({ satellite_toggled_by_player = player, }, satellite_meta_data.planet_name)

        if (find_invalid_substrings(surface_name)) then

            player.print({ MSG_INVALID_SURFACE_DETECTED, surface_name, })
            return
        end

        if (satellites_toggled.toggle) then
            if (allow_toggle(surface_name)) then
                print_toggle_message({ message = TOGGLE_DISABLED_TBL, surface_name = surface_name, add_count = true, force = player.force })
                player.force.cancel_charting(surface_name)
            else
                print_toggle_message({ message = TOGGLE_INSUFFICIENT_TBL, surface_name = surface_name, add_count = true, force = player.force })
            end
            satellites_toggled.toggle = false
        elseif (not satellites_toggled.toggle) then
            if (allow_toggle(surface_name)) then
                print_toggle_message({ message = TOGGLE_ENABLED_TBL, surface_name = surface_name, add_count = true, force = player.force })
                satellites_toggled.toggle = true
            else
                print_toggle_message({ message = TOGGLE_INSUFFICIENT_TBL, surface_name = surface_name, add_count = true, force = player.force })
                -- This shouldn't be necessary, but oh well
                satellites_toggled.toggle = false
            end
        else
            Log.error("This shouldn't be possible")
        end
    end
end
Event_Handler:register_event({
    event_name = Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name,
    source_name = "fog_of_war_controller.toggle",
    func_name = "fog_of_war_controller.toggle",
    func = fog_of_war_controller.toggle,
})

function fog_of_war_controller.init(__storage) storage = __storage end

return fog_of_war_controller
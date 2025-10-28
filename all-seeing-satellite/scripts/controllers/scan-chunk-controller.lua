local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Constants = require("scripts.constants.constants")
local Planet_Utils = require("scripts.utils.planet-utils")
local Research_Utils = require("scripts.utils.research-utils")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Scan_Chunk_Service = require("scripts.services.scan-chunk-service")
local String_Utils = require("scripts.utils.string-utils")

local scan_chunk_controller = {}
scan_chunk_controller.name = "scan_chunk_controller"

function scan_chunk_controller.stage_selected_chunks(event)
    Log.debug("scan_chunk_controller.stage_selected_chunk")
    Log.info(event)

    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.valid) then return end
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (not event or not event.item or event.item ~= "satellite-scanning-remote") then return end
    if (not event.player_index or not event.area) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    if (not event.surface or not event.surface.valid) then return end

    -- No need to scan in space
    if (event.surface.platform ~= nil) then
        player.print("Scanning not allowed in space")
        return
    end

    if (String_Utils.find_invalid_substrings(event.surface.name)) then
        player.print("Invalid surface detected for scanning: " .. event.surface.name)
        player.print("Scanning not allowed")
        return
    end

    if (not Planet_Utils.allow_scan(event.surface.name)) then
        if (not Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
            player.print("Rocket Silo/Satellite not researched yet")
        else
            local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(event.surface.name)
            if (not satellite_meta_data.valid) then return end
            player.print("Insufficient satellite(s) orbiting "
                .. event.surface.name
                .. " : "
                .. satellite_meta_data.satellites_in_orbit
                .. " orbiting, 1 minimum"
            )
        end

        return
    end

    if (not all_seeing_satellite_data.do_scan) then
        player.print("Scanning is not currently enabled")
        player.print({ "message.all-seeing-toggle-scanning" })
        player.print({ "message.all-seeing-cancel-scanning" })
        return
    end

    Scan_Chunk_Service.stage_selected_area(event)
end

function scan_chunk_controller.clear_selected_chunks(event)
    Log.debug("scan_chunk_controller.clear_selected_chunks")
    Log.info(event)

    local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
    if (not all_seeing_satellite_data.valid) then return end
    if (not all_seeing_satellite_data.do_nth_tick) then return end

    if (not event or not event.item or event.item ~= "satellite-scanning-remote") then return end
    if (not event.surface or not event.surface.valid) then return end
    -- No need to scan in space
    if (event.surface.platform ~= nil) then return end
    if (not event.player_index or not event.area) then return end
    if (not Planet_Utils.allow_scan(event.surface.name)) then return end

    Scan_Chunk_Service.clear_selected_chunks(event)
end

return scan_chunk_controller
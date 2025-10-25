-- If already defined, return
if _research_controller and _research_controller.all_seeing_satellite then
    return _research_controller
end

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Player_Repository = require("scripts.repositories.player-repository")
local String_Utils = require("scripts.utils.string-utils")

local research_controller = {}

function research_controller.research_finished(event)
    Log.debug("research_controller.research_finished")
    Log.info(event)

    if (not event) then return end
    if (not event.research or not event.research.valid or not event.research.researched) then return end
    if (not event.name == "rocket-silo") then return end
    local force = event.research.force
    if (not force or not force.valid) then return end

    for _, player in pairs(force.players) do
        if (player.valid and player.surface and player.surface.valid) then
            if (String_Utils.find_invalid_substrings(player.surface.name)) then goto continue end
            if (not Constants.planets_dictionary) then Constants.get_planets(true) end
            if (not Constants.planets_dictionary[player.surface.name]) then goto continue end

            local player_data = Player_Repository.get_player_data(player.index)
            if (not player_data.valid) then goto continue end
            if (player_data.editor_mode_toggled) then
                Player_Repository.update_player_data({ player_index = player.index, satellite_mode_stashed = true, })
            else
                Player_Repository.update_player_data({ player_index = player.index, satellite_mode_allowed = true, })
            end
        end
        ::continue::
    end
end

research_controller.all_seeing_satellite = true

local _research_controller = research_controller

return research_controller
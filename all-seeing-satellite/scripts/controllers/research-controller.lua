local planets_dictionary

local pairs = pairs

local ROCKET_SILO = "rocket-silo"

local Constants = Constants
local get_planet_data = Constants.get_planet_data

local Player_Repository = require("scripts.repositories.player-repository")
local get_player_data = Player_Repository.get_player_data
local update_player_data = Player_Repository.update_player_data
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local research_controller = {}
research_controller.name = "research_controller"

function research_controller.on_research_finished(event)
    -- Log.debug("research_controller.on_research_finished")
    -- Log.info(event)

    if (not event) then return end
    if (not event.research or not event.research.valid or not event.research.researched) then return end
    if (not event.name == ROCKET_SILO) then return end
    local force = event.research.force
    if (not force or not force.valid) then return end

    planets_dictionary = planets_dictionary or Constants.mod_data.planets_dictionary or get_planet_data({ reindex = true }) and Constants.mod_data.planets_dictionary

    for _, player in pairs(force.players) do
        if (player.valid and player.surface and player.surface.valid) then
            if (find_invalid_substrings(player.surface.name)) then goto continue end
            if (not planets_dictionary[player.surface.name]) then goto continue end

            local player_data = get_player_data(player.index)
            if (not player_data) then goto continue end
            if (player_data.editor_mode_toggled) then
                update_player_data({ player_index = player.index, satellite_mode_stashed = true, })
            else
                update_player_data({ player_index = player.index, satellite_mode_allowed = true, })
            end
        end
        ::continue::
    end
end
Event_Handler:register_event({
    event_name = "on_research_finished",
    source_name = "research_controller.on_research_finished",
    func_name = "research_controller.on_research_finished",
    func = research_controller.on_research_finished,
})

return research_controller
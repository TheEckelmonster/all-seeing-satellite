local Player_Repository = require("scripts.repositories.player-repository")
local String_Utils = require("scripts.utils.string-utils")

local research_controller = {}
research_controller.name = "research_controller"

function research_controller.on_research_finished(event)
    Log.debug("research_controller.on_research_finished")
    Log.info(event)

    if (not event) then return end
    if (not event.research or not event.research.valid or not event.research.researched) then return end
    if (not event.name == "rocket-silo") then return end
    local force = event.research.force
    if (not force or not force.valid) then return end

    for _, player in pairs(force.players) do
        if (player.valid and player.surface and player.surface.valid) then
            if (String_Utils.find_invalid_substrings(player.surface.name)) then goto continue end
            if (not Constants.mod_data.planets_dictionary) then Constants.get_planet_data({ reindex = true }) end
            if (not Constants.mod_data.planets_dictionary[player.surface.name]) then goto continue end

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
Event_Handler:register_event({
    event_name = "on_research_finished",
    source_name = "research_controller.on_research_finished",
    func_name = "research_controller.on_research_finished",
    func = research_controller.on_research_finished,
})

return research_controller
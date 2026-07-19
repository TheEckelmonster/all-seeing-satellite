local Planet_Utils = require("scripts.utils.planet-utils")
local allow_toggle = Planet_Utils.allow_toggle
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local get_satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data

local fog_of_war_service = {}

function fog_of_war_service.toggle_FoW(planet)
    -- Log.debug("fog_of_war_controller.toggle_FoW")
    -- Log.info(planet)

    if (not planet) then return end
    if (not planet.surface or not planet.surface.valid) then return end

    local satellite_meta_data = get_satellite_meta_data(planet.name)
    if (not satellite_meta_data) then return end
    local player = satellite_meta_data.satellite_toggled_by_player
    local player_surface = player and player.valid and player.surface or nil
    local satellite_toggle_data = satellite_meta_data.satellites_toggled

    if (    satellite_toggle_data
        and satellite_toggle_data.toggle
        and player
        and player.valid
        and player.force
        and player.force.valid
        and player_surface
        and player_surface.valid
        and player_surface.name == satellite_toggle_data.planet_name
    ) then
        if (allow_toggle(satellite_toggle_data.planet_name)) then
            player.force.rechart(planet.name)
            return
        end
    end
end

return fog_of_war_service
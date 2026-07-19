local ipairs = ipairs
local pairs = pairs
local string_find = string.find

local PLATFROM_PATTERN = "platform%-[%d]*"

To_Set_Game = To_Set_Game or {}

function Set_Game_Funcs()
    local game = _ENV.game

    _ENV.Forces = _ENV.Forces or {}
    Forces = _ENV.Forces
    Forces.list = Forces.list or {}

    _ENV.Force_Funcs = _ENV.Force_Funcs or {}
    Force_Funcs = _ENV.Force_Funcs
    for name, force in pairs(game.forces) do
        if (force.valid) then
            local index = force.index
            Forces[name] = force
            Forces.list[index] = name
            Force_Funcs[index] = Force_Funcs[index] or {}
            Force_Funcs[name] = Force_Funcs[index] or {}
            Force_Funcs[name].print = Force_Funcs[name].print or force.print
            Force_Funcs[name].chart = Force_Funcs[name].chart or force.chart
        else
            Forces[name] = nil
        end
    end

    _ENV.Surfaces = _ENV.Surfaces or {}
    Surfaces = _ENV.Surfaces
    Surfaces.list = Surfaces.list or {}

    _ENV.Surface_Funcs = _ENV.Surface_Funcs or {}
    Surface_Funcs = _ENV.Surface_Funcs
    for name, surface in pairs(game.surfaces) do
        if (surface.valid and not string_find(surface.name, PLATFROM_PATTERN)) then
            Surfaces[name] = surface
            Surfaces.list[surface.index] = name

            Surface_Funcs[name] = Surface_Funcs[name] or {}
            Surface_Funcs[name].find_entity = Surface_Funcs[name].find_entity or surface.find_entity
        else
            Surfaces[name], Surface_Funcs[name] = nil, nil
        end
    end
end
To_Set_Game.set_game_funcs = Set_Game_Funcs

To_Set_Game.to_set = {
    require("scripts.controllers.all-seeing-satellite-controller"),
    require("scripts.controllers.fog-of-war-controller"),
    require("scripts.controllers.player-controller"),
    require("scripts.controllers.scan-chunk-controller"),
    require("scripts.data.data"),
    require("scripts.repositories.all-seeing-satellite-repository"),
    require("scripts.repositories.scanning.area-to-chart-repository"),
    require("scripts.repositories.scanning.chunk-to-chart-repository"),
    require("scripts.repositories.character-repository"),
    require("scripts.repositories.player-repository"),
    require("scripts.repositories.rocket-silo-repository"),
    require("scripts.repositories.satellite-meta-repository"),
    require("scripts.repositories.satellite-repository"),
    require("scripts.services.all-seeing-satellite-service"),
    require("scripts.services.player-service"),
    require("scripts.services.satellite-service"),
    require("scripts.services.scan-chunk-service"),
    require("scripts.utils.rocket-silo-utils"),
}

function Set_game_all(event)
    local __game, __storage = _ENV.game, _ENV.storage
    __storage.settings_map = __storage.settings_map or {}
    __storage.settings_map.runtime_global = __storage.settings_map.runtime_global or {}

    Set_Game_Funcs()

    for _, v in ipairs(To_Set_Game.to_set or {}) do
        if (type(v.set_game) == "function") then
            v.set_game(event, __game, __storage)
        end
    end
end
To_Set_Game.set_game_all = Set_game_all
Event_Handler:register_events({
    {
        event_name = Custom_Events.as_on_init_complete.name,
        source_name = "To_Set_Game.set_game_all",
        func_name = "To_Set_Game.set_game_all",
        func = To_Set_Game.set_game_all,
    },
    {
        event_name = "on_configuration_changed",
        source_name = "To_Set_Game.set_game_all",
        func_name = "To_Set_Game.set_game_all",
        func = To_Set_Game.set_game_all,
    },
})

return To_Set_Game
local Constants = require("libs.constants")

-- local SHORTCUT_NAME = 'CSOP-toggle'
-- local HOTKEY_EVENT_NAME = 'CSOP-toggle'

-- local SETTING_AVAILABLE_FROM_NAME = 'CSOP-available-from'
-- local SETTING_REVEAL_NAME = 'CSOP-reveal'

-- function enabled(player_index, set)
--     local player = game.players[player_index]
--     -- game.print(game.table_to_json({player_index, set, 'is', player.is_shortcut_toggled(SHORTCUT_NAME)}))
--     local available_from = settings.global[SETTING_AVAILABLE_FROM_NAME].value
--     if set ~= nil then
--         local force = player.force
--         if not set or
--             available_from == 'Start' or
--             -- available_from == 'Construction robotics researched' and force.ghost_time_to_live > 0 or
--             available_from == 'Construction robotics researched' and force.technologies['construction-robotics'].researched or
--             available_from == 'Rocket launched' and force.rockets_launched > 0 or
--             available_from == 'Satellite launched' and force.get_item_launched('satellite') > 0
--             then
--             for _, p in pairs(force.players) do
--                 p.set_shortcut_toggled(SHORTCUT_NAME, set)
--             end
--         else
--             player.print('Clear skies available from '..available_from..'. (Runtime map settings)')
--         end
--     end
--     return player.is_shortcut_toggled(SHORTCUT_NAME)
-- end

-- function toggle(event)
--     -- game.print(game.table_to_json(event))
--     if event.input_name ~= HOTKEY_EVENT_NAME and event.prototype_name ~= SHORTCUT_NAME then return end
--     enabled(event.player_index, not enabled(event.player_index))
-- end

-- script.on_nth_tick(60, function(event)
--     local forces = {}
--     for _, player in pairs(game.connected_players) do
--         if player.is_shortcut_toggled(SHORTCUT_NAME) then
--             forces[player.force.index] = true
--         end
--     end
--     local reveal = settings.global[SETTING_REVEAL_NAME].value
--     for force_index in pairs(forces) do
--         if reveal == 'Discovered' then
--             game.forces[force_index].rechart()
--         elseif reveal == 'Generated' then
--             game.forces[force_index].chart_all()
--         end
--     end
-- end)

-- script.on_event(defines.events.on_lua_shortcut, toggle)
-- script.on_event(HOTKEY_EVENT_NAME, toggle)

function toggleFoW(event)
  -- game.print("Tick: " .. event.tick)
end

script.on_nth_tick(60, toggleFoW)
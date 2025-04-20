local All_Seeing_Satellite_Controller = require("control.controllers.all-seeing-satellite-controller")
local Constants = require("libs.constants.constants")
local Custom_Input_Constants = require("libs.constants.custom-input-constants")
local Fog_Of_War_Controller = require("control.controllers.fog-of-war-controller")
local Log = require("libs.log.log")
local Planet_Controller = require("control.controllers.planet-controller")
local Player_Controller = require("control.controllers.player-controller")
local Rocket_Silo_Controller = require("control.controllers.rocket-silo-controller")
local Satellite_Controller = require("control.controllers.satellite-controller")
local Scan_Chunk_Controller = require("control.controllers.scan-chunk-controller")
local Settings_Controller = require("control.controllers.settings-controller")
local Settings_Constants = require("libs.constants.settings-constants")
local Settings_Service = require("control.services.settings-service")

local nth_tick = Settings_Service.get_nth_tick()

if (not nth_tick or nth_tick <= 0) then
  nth_tick = Settings_Constants.settings.NTH_TICK.value
end

local on_entity_died_filter = {}

for _, v in pairs(Rocket_Silo_Controller.filter) do
  table.insert(on_entity_died_filter, v)
end

for _, v in pairs(Player_Controller.filter) do
  table.insert(on_entity_died_filter, v)
end

--
-- Register events

Log.info("Registering events")

-- script.on_init(init)

script.on_event(defines.events.on_tick, All_Seeing_Satellite_Controller.do_tick)

script.on_event(Custom_Input_Constants.FOG_OF_WAR_TOGGLE.name, Fog_Of_War_Controller.toggle)
script.on_event(Custom_Input_Constants.TOGGLE_SCANNING.name, Fog_Of_War_Controller.toggle_scanning)
script.on_event(Custom_Input_Constants.CANCEL_SCANNING.name, Fog_Of_War_Controller.cancel_scanning)
script.on_event(Custom_Input_Constants.TOGGLE_SATELLITE_MODE.name, Player_Controller.toggle_satellite_mode)

script.on_event(defines.events.on_player_created, Player_Controller.player_created)
script.on_event(defines.events.on_pre_player_died, Player_Controller.pre_player_died)
script.on_event(defines.events.on_player_died, Player_Controller.player_died)
script.on_event(defines.events.on_player_respawned, Player_Controller.player_respawned)
script.on_event(defines.events.on_player_joined_game, Player_Controller.player_joined_game)
script.on_event(defines.events.on_pre_player_left_game, Player_Controller.pre_player_left_game)
script.on_event(defines.events.on_pre_player_removed, Player_Controller.pre_player_removed)
script.on_event(defines.events.on_surface_cleared, Player_Controller.surface_cleared)
script.on_event(defines.events.on_surface_deleted, Player_Controller.surface_deleted)
script.on_event(defines.events.on_player_changed_surface, Player_Controller.changed_surface)
script.on_event(defines.events.on_cargo_pod_finished_ascending, Player_Controller.cargo_pod_finished_ascending)
script.on_event(defines.events.on_cargo_pod_finished_descending, Player_Controller.cargo_pod_finished_descending)
script.on_event(defines.events.on_player_toggled_map_editor, Player_Controller.player_toggled_map_editor)
script.on_event(defines.events.on_pre_player_toggled_map_editor, Player_Controller.pre_player_toggled_map_editor)

script.on_event(defines.events.on_surface_created, Planet_Controller.on_surface_created)

script.on_event(defines.events.on_rocket_launch_ordered, function (event)
  Player_Controller.rocket_launch_ordered(event)
  Satellite_Controller.track_satellite_launches_ordered(event)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings_Controller.mod_setting_changed)

script.on_event(defines.events.on_player_selected_area, Scan_Chunk_Controller.stage_selected_chunks)
script.on_event(defines.events.on_player_reverse_selected_area, Scan_Chunk_Controller.clear_selected_chunks)

script.on_event(defines.events.on_entity_died, function (event)
  if (not event) then return end
  if (not event.entity or not event.entity.name) then return end

  if (event.entity.name == "character") then
    Player_Controller.entity_died(event)
  elseif (event.entity.name == "rocket-silo") then
    Rocket_Silo_Controller.rocket_silo_mined(event)
  end
end,
-- Rocket_Silo_Controller.filter)
on_entity_died_filter)

--
-- rocket-silo tracking
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)

Log.info("Finished registering events")
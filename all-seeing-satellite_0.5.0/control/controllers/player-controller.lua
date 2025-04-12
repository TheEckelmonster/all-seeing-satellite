-- If already defined, return
if _player_controller and _player_controller.all_seeing_satellite then
  return _player_controller
end

local Log = require("libs.log.log")
local Player_Service = require("control.services.player-service")
local Player_Data_Repository = require("control.repositories.player-data-repository")
local Character_Data_Repository = require("control.repositories.character-data-repository")

local player_controller = {}

function player_controller.toggle_satellite_mode(event)
  Log.debug("player_controller.toggle_satellite_mode")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_data = Player_Data_Repository.get_player_data(event.player_index)

  if (not player_data.valid) then return end -- This should, in theory, only happen if the player does not exist
  if (not player_data.satellite_mode_allowed) then return end

  Player_Service.toggle_satellite_mode(event)
end

function player_controller.player_created(event)
  Log.debug("player_controller.player_created")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.pre_player_died(event)
  Log.debug("player_controller.pre_player_died")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.player_died(event)
  Log.debug("player_controller.player_died")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.player_respawned(event)
  Log.debug("player_controller.player_respawned")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.player_joined_game(event)
  Log.debug("player_controller.player_joined_game")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.update_player_data({ player_index = event.player_index })
end

function player_controller.pre_player_left_game(event)
  Log.debug("player_controller.pre_player_left_game")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.pre_player_removed(event)
  Log.debug("player_controller.pre_player_removed")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.delete_player_data(event.player_index)
end

function player_controller.surface_cleared(event)
  Log.debug("player_controller.surface_cleared")
  Log.info(event)

  if (not event) then return end
  if (not event.surface_index) then return end

  local all_player_data = Player_Data_Repository.get_all_player_data()

  for player_index, player_data in pairs(all_player_data) do
    if (player_data.surface_index and player_data.surface_index == event.surface_index) then
      Player_Data_Repository.save_player_data(event.player_index)
    end
  end
end

function player_controller.surface_deleted(event)
  Log.debug("player_controller.surface_deleted")
  Log.info(event)

  if (not event) then return end
  if (not event.surface_index) then return end

  local all_player_data = Player_Data_Repository.get_all_player_data()

  for player_index, player_data in pairs(all_player_data) do
    if (player_data.surface_index and player_data.surface_index == event.surface_index) then
      Player_Data_Repository.save_player_data(event.player_index)
    end
  end
end

function player_controller.changed_surface(event)
  Log.debug("player_controller.changed_surface")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end
  if (not event.surface_index) then return end
  if (not event.launched_by_rocket) then return end
  local player = game.get_player(event.player_index)

  if (player.controller_type == defines.controllers.character) then
    Log.warn("1")
    Player_Data_Repository.save_player_data(event.player_index)
  elseif (player.controller_type == defines.controllers.remote) then
    Log.warn("2")
  elseif (player.controller_type == defines.controllers.god) then
    Log.warn("3")
  else
    Log.warn("4")
  end
end

function player_controller.cargo_pod_finished_ascending(event)
  Log.debug("player_controller.cargo_pod_finished_ascending")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  Player_Data_Repository.save_player_data(event.player_index)
end

function player_controller.cargo_pod_finished_descending(event)
  Log.debug("player_controller.cargo_pod_finished_descending")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_data = Player_Data_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then return end -- This should, in theory, only happen if the player does not exist

  if (not event.launched_by_rocket) then
    player_data.satellite_mode_allowed = true
    Player_Data_Repository.save_player_data(event.player_index)

  end
end

function player_controller.rocket_launch_ordered(event)
  Log.debug("player_controller.rocket_launch_ordered")
  Log.info(event)

  if (not event) then return end
  if (not event.rocket or not event.rocket.valid) then return end
  local rocket = event.rocket
  if (not rocket.cargo_pod or not rocket.cargo_pod.valid) then return end
  local cargo_pod = rocket.cargo_pod
  local passenger = cargo_pod.get_passenger()
  if (not passenger or not passenger.valid) then return end

  if (passenger and passenger.valid and passenger.player and passenger.player.valid) then
    local player_data = Player_Data_Repository.get_player_data(passenger.player.index)

    if (not player_data.valid) then return end -- This should, in theory, only happen if the player does not exist

    player_data.satellite_mode_allowed = false
    Player_Data_Repository.save_player_data(passenger.player.index)
  end
end

function player_controller.player_toggled_map_editor(event)
  Log.debug("player_controller.player_toggled_map_editor")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_data = Player_Data_Repository.get_player_data(event.player_index)
  if (not player_data.valid) then return end

  if (player_data.editor_mode_toggled) then
    player_data.satellite_mode_allowed = false
  elseif (not player_data.editor_mode_toggled) then
    if (not player_data.character_data.character or not player_data.character_data.character.valid) then
      local character_data = Character_Data_Repository.save_character_data(event.player_index)
      if (character_data.valid) then
        player_data.character_data = character_data
        player_data.satellite_mode_allowed = true
      end
    end
  end
end

function player_controller.pre_player_toggled_map_editor(event)
  Log.debug("player_controller.pre_player_toggled_map_editor")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end
  local player_data = Player_Data_Repository.get_player_data(event.player_index)

  if (player_data.editor_mode_toggled) then
    player_data.editor_mode_toggled = false
  elseif (not player_data.editor_mode_toggled) then
    player_data.editor_mode_toggled = true
  end
end

player_controller.all_seeing_satellite = true

local _player_controller = player_controller

return player_controller
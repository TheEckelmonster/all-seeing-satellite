-- If already defined, return
if _player_service and _player_service.all_seeing_satellite then
  return _player_service
end

local Log = require("libs.log.log")
local Player_Data_Repository = require("control.repositories.player-data-repository")

local player_service = {}

function player_service.toggle_satellite_mode(event)
  Log.debug("player_service.toggle_satellite_mode")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_index = event.player_index
  local player = game.get_player(player_index)
  local player_data = Player_Data_Repository.get_player_data(player_index)
  local position_to_place = player_data.physical_position
  local physical_surface = game.surfaces[player_data.physical_surface_index]

  local update_player_data_fun = function (index, toggled, player)
    Player_Data_Repository.update_player_data({
      player_index = index,
      satellite_mode_toggled = toggled,
    })
    -- if (player and player.game_view_settings) then
    --   Log.error("disabling surface list")
    --   -- If satellite mode is toggled on, don't show the surface list
    --   player.game_view_settings.show_surface_list = not toggled
    -- end
  end

  if (player and player.valid and player_data.valid and physical_surface and physical_surface.valid) then

    if (player.controller_type == defines.controllers.god) then
      if (player_data.controller_type == defines.controllers.character) then
        local character_position = player_data.character_data.character.position
        position_to_place =     physical_surface.can_place_entity({ name = "character", position = character_position })
                            and character_position
                            or physical_surface.find_non_colliding_position("character", character_position, 42, 0.01)
      end

      player.teleport(position_to_place, physical_surface)

      player.set_controller({ type = defines.controllers.character, character = player_data.character_data.character })
      update_player_data_fun(player_index, false, player)
    elseif (player.controller_type == defines.controllers.character) then
      player.set_controller({ type = defines.controllers.god })
      update_player_data_fun(player_index, true, player)
    elseif (player.controller_type == defines.controllers.remote) then
      local toggled = false

      if (player_data.controller_type == defines.controllers.remote or player_data.controller_type == defines.controllers.god) then
        toggled = false
      elseif (player_data.controller_type == defines.controllers.character) then
        player.set_controller({ type = defines.controllers.god })
        toggled = true
      end

      if (not toggled) then
        player.teleport(position_to_place, physical_surface)
        player.set_controller({ type = defines.controllers.character, character = player_data.character_data.character })
      end
      update_player_data_fun(player_index, toggled, player)
    end
  end
end

player_service.all_seeing_satellite = true

local _player_service = player_service

return player_service
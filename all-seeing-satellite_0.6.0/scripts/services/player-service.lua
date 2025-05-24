-- If already defined, return
if _player_service and _player_service.all_seeing_satellite then
  return _player_service
end

local Character_Repository = require("scripts.repositories.character-repository")
local Log = require("libs.log.log")
local Player_Repository = require("scripts.repositories.player-repository")
local Settings_Service = require("scripts.services.settings-service")

local player_service = {}

function player_service.toggle_satellite_mode(event)
  Log.debug("player_service.toggle_satellite_mode")
  Log.info(event)

  if (not event) then return end
  if (not event.player_index) then return end

  local player_index = event.player_index
  local player = game.get_player(player_index)
  local player_data = Player_Repository.get_player_data(player_index)
  local position_to_place = player_data.physical_position
  local physical_surface = game.get_surface(player_data.physical_surface_index)

  local update_player_data_fun = function (index, toggled, player)
    Player_Repository.update_player_data({
      player_index = index,
      satellite_mode_toggled = toggled,
    })
    if (player and player.game_view_settings) then
      Log.debug("disabling surface list")
      -- If satellite mode is toggled on, don't show the surface list
      player.game_view_settings.show_surface_list = not toggled
      -- But show the surface list if satellites aren't required
      if (not Settings_Service.get_restrict_satellite_mode()) then
        player.game_view_settings.show_surface_list = true
      end
    end
  end

  if (player and player.valid and player_data.valid and physical_surface and physical_surface.valid) then
    if (player.controller_type == defines.controllers.god) then
      if (player_data.controller_type == defines.controllers.character) then
        local character_position
        if (not player_data.character_data.character or not player_data.character_data.character.valid) then
          character_position = player_data.character_data.position
        else
          character_position = player_data.character_data.character.position
        end

        local no_character = false
        if (character_position == nil) then
          no_character = true
          character_position = player_data.position
        end

        position_to_place =     physical_surface.can_place_entity({ name = "character", position = character_position })
                            and character_position
                            or physical_surface.find_non_colliding_position("character", character_position, 42, 0.01)
      end

      -- raise_teleported = true
      player.teleport(position_to_place, physical_surface, true)

      if (no_character) then
        Log.error("No character found; creating a new one")
        player.create_character()
      else
        player.set_controller({ type = defines.controllers.character, character = player_data.character_data.character })
      end
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
        -- raise_teleported = true
        player.teleport(position_to_place, physical_surface, true)
        player.set_controller({ type = defines.controllers.character, character = player_data.character_data.character })
      end
      update_player_data_fun(player_index, toggled, player)
    end
  end
end

function player_service.disable_satellite_mode_and_die(data)
  if (not data or type(data) ~= "table") then return end
  if (not data.player_index) then return end
  if (not data.character) then
    local player = game.get_player(player_index)
    if (not player or not player.valid) then return end
    if (not player.character or not player.character.valid) then return end
    data.character = player.character
  end

  local player_index = data.player_index
  if (player_index < 0) then return end

  local character = data.character
  if (not character or not character.valid) then return end

  local player = game.get_player(player_index)
  if (not player or not player.valid) then return end

  local character_data = Character_Repository.get_character_data(player_index)
  if (not character_data or not character_data.valid) then return end

  local surface = game.get_surface(character_data.surface_index)
  if (not surface or not surface.valid) then return end

  local character_position = character.position

  position_to_place =     surface.can_place_entity({ name = "character", position = character_position })
                      and character_position
                      or surface.find_non_colliding_position("character", character_position, 84, 0.01)

  -- raise_teleported = true
  player.teleport(position_to_place, surface, true)
  player.set_controller({ type = defines.controllers.god })
  player.create_character(character)
  player.game_view_settings.show_surface_list = true

  local player_data = Player_Repository.get_player_data(player_index)
  if (not player_data.valid) then return end

  player.force = player_data.force_index_stashed or 1

  Player_Repository.update_player_data({
    player_index = player_index,
    satellite_mode_toggled = false,
  })

  Character_Repository.update_character_data({
    player_index = player_index,
    character = character,
    position = character.position,
  })

  local player_character_position = player.character.position
  player.character.die()
  local character_corpse = surface.find_entity("character-corpse", player_character_position)
  character_corpse.destroy()

  local actual_corpse = surface.find_entity("character-corpse", character_position)

  if (actual_corpse) then
    player.add_pin({
      always_visible = true,
      entity = actual_corpse,
    })
  end
end

player_service.all_seeing_satellite = true

local _player_service = player_service

return player_service
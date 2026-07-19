local storage

local game
local get_entity_by_unit_number
local get_player
local get_surface

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game
    get_entity_by_unit_number = get_entity_by_unit_number or game.get_entity_by_unit_number
    get_player = get_player or game.get_player
    get_surface = get_surface or game.get_surface

    Set_Game_Funcs()

    return game
end

local type = type

local defines = defines

local controller_character = defines.controllers.character
local controller_god = defines.controllers.god

local CHARACTER_CORPSE = "character-corpse"

local NUMBER = "number"
local TABLE = "table"

local Character_Repository = require("scripts.repositories.character-repository")
local get_character_data = Character_Repository.get_character_data
local save_character_data = Character_Repository.save_character_data
local update_character_data = Character_Repository.update_character_data
local Player_Repository = require("scripts.repositories.player-repository")
local get_player_data = Player_Repository.get_player_data
local update_player_data = Player_Repository.update_player_data

local player_service = {}
player_service.name = "player_service"
player_service.set_game = set_game

function player_service.toggle_satellite_mode(event)
    -- Log.debug("player_service.toggle_satellite_mode")
    -- Log.info(event)

    if (not event) then return end
    if (not event.player_index) then return end

    local player_index = event.player_index
    local player = (game or set_game()) and get_player and get_player(player_index)
    local player_data = get_player_data(player_index)
    if (not player_data) then return end
    local character_data = player_data.character_data
    if (not character_data) then return end
    local position_to_place = player_data.physical_position
    local physical_surface = (game or set_game()) and get_surface and get_surface(player_data.physical_surface_index)

    local update_player_data_fun = function(index, toggled, player)
        if (player.character and player.character.valid) then
            if (player.character ~= character_data.character or not character_data.character.valid) then
                save_character_data(player_index)
            end
        end
        update_player_data({
            player_index = index,
            satellite_mode_toggled = toggled,
        })
        if (player and player.game_view_settings) then
            -- Log.debug("disabling surface list")
            -- If satellite mode is toggled on, don't show the surface list
            player.game_view_settings.show_surface_list = not toggled
            -- But show the surface list if satellites aren't required
            if (not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.RESTRICT_SATELLITE_MODE.name })) then
                player.game_view_settings.show_surface_list = true
            end
        end
    end

    if (player and player.valid and physical_surface and physical_surface.valid) then
        local ret = update_player_data({
            player_index = player_index,
            physical_position = player.physical_position,
            position = player.position,
        })

        if (ret and ret.character_data and ret.character_data.player_index < 1) then
            save_character_data(player_index)
        else
            update_character_data({
                character_name = player.character and player.character.valid and player.character.name or nil,
                character = player.character and player.character.valid and player.character or nil,
                player_index = player_index,
                physical_position = player.physical_position,
                position = player.position,
            })
        end

        local distance     = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_MODE_VIEW_DISTANCE.name })
        local max_distance = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SATELLITE_MODE_MAX_VIEW_DISTANCE.name })

        if (type(distance) ~= NUMBER) then distance = Runtime_Global_Settings_Constants.settings.SATELLITE_MODE_VIEW_DISTANCE.default_value end
        if (type(max_distance) ~= NUMBER) then max_distance = Runtime_Global_Settings_Constants.settings.SATELLITE_MODE_MAX_VIEW_DISTANCE.default_value end

        local zoom_limit = { distance = distance, max_distance = max_distance }
        local god_controller_zoom_limits = { furthest = zoom_limit, furthest_game_view = zoom_limit, }

        local character = nil

        if (player.controller_type == controller_god) then
            player.teleport(position_to_place, physical_surface, true)

            if (character_data.character and character_data.character.valid) then
                character = character_data.character
            else
                local surface = (game or set_game()) and get_surface and get_surface(player_data.physical_surface_index)
                local possible_character = surface.find_entity(character_data.character_name, player_data.physical_position)
                if (not possible_character or not possible_character.valid) then possible_character = (game or set_game()) and get_entity_by_unit_number and get_entity_by_unit_number(character_data.unit_number) end

                character = possible_character or player.create_character() and player.character or nil
                if (not character or not character.valid) then return end
            end
            character_data.character = character

            player.set_controller({ type = controller_character, character = character })
            update_player_data_fun(player_index, false, player)
        elseif (player.controller_type == controller_character) then
            player.set_controller({ type = controller_god })
            update_player_data_fun(player_index, true, player)

            player.zoom_limits = god_controller_zoom_limits
        elseif (player.controller_type == defines.controllers.remote) then
            local toggled = false

            if (player_data.controller_type == controller_character) then
                player.set_controller({ type = controller_god })
                toggled = true

                player.zoom_limits = god_controller_zoom_limits
            end

            if (not toggled) then
                if (character_data.character and character_data.character.valid) then
                    character = character_data.character
                else
                    local surface = (game or set_game()) and get_surface and get_surface(player_data.physical_surface_index)
                    local possible_character = surface.find_entity(character_data.character_name, player_data.physical_position)

                    character = possible_character or player.create_character() and player.character or nil
                    if (not character or not character.valid) then return end
                end
                character_data.character = character

                player.teleport(position_to_place, physical_surface, true)
                player.set_controller({ type = controller_character, character = character })
            end
            update_player_data_fun(player_index, toggled, player)
        end
    end
end

function player_service.disable_satellite_mode_and_die(data)
    if (not data or type(data) ~= TABLE) then return end
    if (not data.player_index) then return end

    local player_index = data.player_index
    if (player_index < 0) then return end

    if (not data.character) then
        local player = (game or set_game()) and get_player and get_player(player_index)
        if (not player or not player.valid) then return end
        if (not player.character or not player.character.valid) then return end
        data.character = player.character
    end

    local character = data.character
    if (not character or not character.valid) then return end

    local player = (game or set_game()) and get_player and get_player(player_index)
    if (not player or not player.valid) then return end

    local character_data = get_character_data(player_index)
    if (not character_data) then return end

    local surface = (game or set_game()) and get_surface and get_surface(character_data.surface_index)
    if (not surface or not surface.valid) then return end

    local character_position = character.position


    local player_data = Player_Repository.get_player_data(player_index)
    if (not player_data) then return end

    player.set_controller({ type = controller_god })
    player.create_character(character)
    player.game_view_settings.show_surface_list = true

    player.force = player_data.force_index_stashed or 1

    update_player_data({
        player_index = player_index,
        satellite_mode_toggled = false,
    })

    update_character_data({
        player_index = player_index,
        character = character,
        position = character.position,
    })

    local player_character_position = player.character.position
    player.character.die()
    local character_corpse = surface.find_entity(CHARACTER_CORPSE, player_character_position)
    if (character_corpse and character_corpse.valid) then
        character_corpse.destroy()
    end

    local actual_corpse = surface.find_entity(CHARACTER_CORPSE, character_position)

    if (actual_corpse and actual_corpse.valid) then
        player.add_pin({
            always_visible = true,
            entity = actual_corpse,
        })

        player.teleport(actual_corpse.position, surface, true)
    end
end

function player_service.init(__storage) storage = __storage end

return player_service
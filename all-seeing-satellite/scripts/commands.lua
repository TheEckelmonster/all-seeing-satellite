local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Core_Utils = require("__TheEckelmonster-core-library__.libs.utils.core-utils")
local String_Utils = require("__TheEckelmonster-core-library__.libs.utils.string-utils")

local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Initialization = require("scripts.initialization")
local Player_Repository = require("scripts.repositories.player-repository")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")

local locals = {}

local all_seeing_satellite_commands = {}

function all_seeing_satellite_commands.init(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.init")
        player.print("Initializing anew")
        Initialization.init()
        player.print("Initialization complete")
    end)
end

function all_seeing_satellite_commands.reinit(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.reinit")
        player.print("Reinitializing")
        Initialization.reinit()
        player.print("Reinitialization complete")
    end)
end

function all_seeing_satellite_commands.print_storage(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.print_storage")

        local file_name = "storage_" .. game.tick
        local exported_file_name = Core_Utils.table.traversal.traverse_print(storage, file_name, _, { full = true  })
        player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
    end)
end

function all_seeing_satellite_commands.print_satellites_launched(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.print_satellites_launched")
        local all_satellite_meta_data = Satellite_Meta_Repository.get_all_satellite_meta_data()

        for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
            log(String_Utils.format_surface_name({ string_data = satellite_meta_data.planet_name })
                .. ": "
                .. tostring(satellite_meta_data.satellites_in_orbit)
            )
            player.print(String_Utils.format_surface_name({ string_data = satellite_meta_data.planet_name })
                .. ": "
                .. tostring(satellite_meta_data.satellites_in_orbit)
            )
        end
    end)
end

function all_seeing_satellite_commands.set_do_nth_tick(command)
    locals.validate_command(command, function(player)
        _Log.info("commands.set_do_nth_tick")

        local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
        if (not all_seeing_satellite_data.valid) then return end

        if (command.parameter ~= nil and (command.parameter or command.parameter == "true" or command.parameter >= 1)) then
            log("Setting do_nth_tick to true")
            player.print("Setting do_nth_tick to true")
            all_seeing_satellite_data.do_nth_tick = true
        else
            log("Setting do_nth_tick to false")
            player.print("Setting do_nth_tick to false")
            all_seeing_satellite_data.do_nth_tick = false
        end
        all_seeing_satellite_data.updated = game.tick
    end)
end

function all_seeing_satellite_commands.get_do_nth_tick(command)
    locals.validate_command(command, function(player)
        _Log.info("commands.get_do_nth_tick")

        local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
        if (not all_seeing_satellite_data.valid) then return end

        if (all_seeing_satellite_data.do_nth_tick ~= nil) then
            log("do_nth_tick = " .. serpent.block(all_seeing_satellite_data.do_nth_tick))
            player.print("do_nth_tick = " .. serpent.block(all_seeing_satellite_data.do_nth_tick))
        else
            _Log.error("storage is either nil or invalid")
            player.print("storage is either nil or invalid; command failed")
        end
    end)
end

function all_seeing_satellite_commands.print_player_data(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.print_player_data")
        local player_data = Player_Repository.get_player_data(player.index)

        local file_name = "player_data_" .. game.tick
        local exported_file_name = Core_Utils.table.traversal.traverse_print(player_data, file_name, _, { full = true  })
        player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
    end)
end

function all_seeing_satellite_commands.print_table(event)
    locals.validate_command(event, function(player)
        _Log.info("commands.print_table")

        Core_Utils.commands.print_table({ player = player, event = event })
    end)
end

function all_seeing_satellite_commands.print_event_handlers(event)
    _Log.debug("all_seeing_satellite_commands.print_event_handlers")
    locals.validate_command(event, function (player)
        _Log.info("commands.print_event_handlers")

        if (Event_Handler) then
            local file_name = "Event_Handler.event_names_" .. game.tick
            local exported_file_name = Core_Utils.table.traversal.traverse_print(Event_Handler.event_names, file_name, _, { full = true  })
            player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))

            file_name = "Event_Handler.events_" .. game.tick
            exported_file_name = Core_Utils.table.traversal.traverse_print(Event_Handler.events, file_name, _, { full = true  })
            player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
        end
    end)
end

function locals.validate_command(event, fun)
    if (not _Log or not _Log.valid or not _Log._ready) then _Log = Log_Stub end
    _Log.info(event)
    if (event) then
        local player = nil

        if (game and event.player_index > 0 and game.players) then player = game.players[event.player_index] end
        if (player and player.valid) then fun(player) end
    end
end

--[[ TODO: Localise the command descriptions ]]
commands.add_command("all_seeing.init", "Initialize from scratch. Accepts a single parameter. Will erase existing data if said parameter is provided and equal to \"false\".", all_seeing_satellite_commands.init)
commands.add_command("all_seeing.reinit", "Tries to reinitialize, attempting to preserve existing data.", all_seeing_satellite_commands.reinit)
commands.add_command("all_seeing.print_storage", "Exports the underlying storage data to a .json file.", all_seeing_satellite_commands.print_storage)
commands.add_command("all_seeing.print_player_data", "Exports the given player's data to a .json file.", all_seeing_satellite_commands.print_player_data)
commands.add_command("all_seeing.satellites_launched", "Prints the the number of satellites launched for each surface/planet.", all_seeing_satellite_commands.print_satellites_launched)
commands.add_command("all_seeing.set_do_nth_tick", "Sets whether to process or not depending on the parameter passed.", all_seeing_satellite_commands.set_do_nth_tick)
commands.add_command("all_seeing.get_do_nth_tick", "Gets the value of the underlying variable for whether to process or not.", all_seeing_satellite_commands.get_do_nth_tick)

commands.add_command("all_seeing.print_event_handlers", "", all_seeing_satellite_commands.print_event_handlers)
commands.add_command("all_seeing.print_table", "", all_seeing_satellite_commands.print_table)

Core_Utils.table.traversal.set_prefix({ prefix = Constants.mod_name })

return all_seeing_satellite_commands
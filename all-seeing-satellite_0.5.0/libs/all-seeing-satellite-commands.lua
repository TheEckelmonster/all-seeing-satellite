-- If already defined, return
if _all_seeing_satellite_commands and _all_seeing_satellite_commands.all_seeing_satellite then
  return _all_seeing_satellite_commands
end

local Initialization = require("control.initialization")
local Log = require("libs.log.log")
local Player_Data_Repository = require("control.repositories.player-data-repository")
local Storage_Service = require("control.services.storage-service")

local all_seeing_satellite_commands = {}

function all_seeing_satellite_commands.init(event)
  validate_command(event, function (player)
    Log.info("commands.init", true)
    player.print("Initializing anew")
    Initialization.init()
    player.print("Initialization complete")
  end)
end

function all_seeing_satellite_commands.reinit(event)
  validate_command(event, function (player)
    Log.info("commands.reinit", true)
    player.print("Reinitializing")
    Initialization.reinit()
    player.print("Reinitialization complete")
  end)
end

function all_seeing_satellite_commands.print_storage(event)
  validate_command(event, function (player)
    Log.info("commands.print_storage", true)
    log(serpent.block(storage))
    player.print(serpent.block(storage))
    Log.debug(storage)
  end)
end

function all_seeing_satellite_commands.print_satellites_launched(event)
  validate_command(event, function (player)
    Log.info("commands.print_satellites_launched", true)
    local obj = Storage_Service.get_all_satellites_launched()
    log(serpent.block(obj))
    player.print(serpent.block(obj))
    Log.debug(storage)
  end)
end

function all_seeing_satellite_commands.set_do_nth_tick(command)
  validate_command(command, function (player)
    Log.info("commands.set_do_nth_tick", true)
    if (command.parameter ~= nil and (command.parameter or command.parameter == "true" or command.parameter >= 1)) then
      log("Setting do_nth_tick to true")
      player.print("Setting do_nth_tick to true")
      Storage_Service.set_do_nth_tick(true)
    else
      log("Setting do_nth_tick to false")
      player.print("Setting do_nth_tick to false")
      Storage_Service.set_do_nth_tick(false)
    end
  end)
end

function all_seeing_satellite_commands.get_do_nth_tick(command)
  validate_command(command, function (player)
    Log.info("commands.get_do_nth_tick", true)
    if (Storage_Service.get_do_nth_tick() ~= nil) then
      log("do_nth_tick = " .. serpent.block(Storage_Service.get_do_nth_tick()))
      player.print("do_nth_tick = " .. serpent.block(Storage_Service.get_do_nth_tick()))
    else
      Log.error("storage is either nil or invalid")
      player.print("storage is either nil or invalid; command failed")
    end
  end)
end

function all_seeing_satellite_commands.print_player_data(event)
  validate_command(event, function (player)
    Log.info("commands.print_player_data", true)
    local player_data = Player_Data_Repository.get_player_data(player.index)
    log(serpent.block(player_data))
    player.print(serpent.block(player_data))
  end)
end

function validate_command(event, fun)
  Log.info(event)
  if (event) then
    local player_index = event.player_index

    local player
    if (game and player_index > 0 and game.players) then
      player = game.players[player_index]
    end

    if (player) then
      fun(player)
    end
  end
end

commands.add_command("all_seeing.init","Initialize from scratch. Will erase existing data.", all_seeing_satellite_commands.init)
commands.add_command("all_seeing.reinit","Tries to reinitialize, attempting to preserve existing data.", all_seeing_satellite_commands.reinit)
commands.add_command("all_seeing.print_storage","Prints the underlying storage data.", all_seeing_satellite_commands.print_storage)
commands.add_command("all_seeing.print_player_data","Prints the given players data.", all_seeing_satellite_commands.print_player_data)
commands.add_command("all_seeing.satellites_launched","Prints the the number of satellites launched for each surface/planet.", all_seeing_satellite_commands.print_satellites_launched)
commands.add_command("all_seeing.set_do_nth_tick", "Sets whether to process or not depending on the parameter passed.", all_seeing_satellite_commands.set_do_nth_tick)
commands.add_command("all_seeing.get_do_nth_tick", "Gets the value of the underlying variable for whether to process or not.", all_seeing_satellite_commands.get_do_nth_tick)

all_seeing_satellite_commands.all_seeing_satellite = true

local _all_seeing_satellite_commands = all_seeing_satellite_commands

return all_seeing_satellite_commands
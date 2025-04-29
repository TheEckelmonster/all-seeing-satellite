-- If already defined, return
if _log and _log.all_seeing_satellite then
  return _log
end

Log_Constants = require("libs.log.log-constants")
Log_Constants_Functions = require("libs.log.log-constants-functions")

local Log = {}

-- Pretty much purely a convenience method
-- -> Allows printing directly to the game via logging
function Log.none(message, traceback)
  if (not is_game_loaded()) then return end
  log_message(message, Log_Constants.levels[Log_Constants.NONE.num_val], traceback)
end

function Log.info(message, traceback)
  if (not is_game_loaded()) then return end
  log_message(message, Log_Constants.levels[Log_Constants.INFO.num_val], traceback)
end

function Log.debug(message, traceback)
  if (not is_game_loaded()) then return end
  log_message(message, Log_Constants.levels[Log_Constants.DEBUG.num_val], traceback)
end

function Log.warn(message, traceback)
  if (not is_game_loaded()) then return end
  log_message(message, Log_Constants.levels[Log_Constants.WARN.num_val], traceback)
end

function Log.error(message, traceback)
  if (not is_game_loaded()) then return end
  log_message(message, Log_Constants.levels[Log_Constants.ERROR.num_val], traceback)
end

function Log.get_log_level()
  local _log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
  if (settings and settings.global and settings.global[Log_Constants.settings.LOGGING_LEVEL.name]) then
    _log_level = settings.global[Log_Constants.settings.LOGGING_LEVEL.name].value
    log_level = {
      level = Log_Constants.levels[Log_Constants.NONE.num_val],
      valid = false
    }

    if (log_level and _log_level == Log_Constants.NONE.string_val) then
      log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    elseif (log_level and _log_level == Log_Constants.ERROR.string_val) then
      log_level = Log_Constants.levels[Log_Constants.ERROR.num_val]
    elseif (log_level and _log_level == Log_Constants.WARN.string_val) then
      log_level = Log_Constants.levels[Log_Constants.WARN.num_val]
    elseif (log_level and _log_level == Log_Constants.DEBUG.string_val) then
      log_level = Log_Constants.levels[Log_Constants.DEBUG.num_val]
    elseif (log_level and _log_level == Log_Constants.INFO.string_val) then
      log_level = Log_Constants.levels[Log_Constants.INFO.num_val]
    else
      log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    end

    if (not storage.log_level and log_level) then
      -- storage.log_level = log_level
      storage.log_level = {
        level = log_level,
        valid = true
      }
    elseif (storage.log_level and log_level) then
      -- storage.log_level = log_level
      storage.log_level = {
        level = log_level,
        valid = true
      }
    else
      log("Didn't find log level from settings")
      if (game) then
        game.print("Didn't find log level from settings")
      end
      storage.log_level = {
        level = Log_Constants.levels[Log_Constants.NONE.num_val],
        valid = false
      }
    end
  end

  return log_level
end

function Log.set_log_level(new_log_level)
  local default_return_val = function ()
    log(debug.traceback())
    log("Setting storage.log_level to NONE and invalid")
    storage.log_level = {
      level = Log_Constants.levels[Log_Constants.NONE.num_val],
      valid = false
    }
    return
  end

  -- log(serpent.block(new_log_level))
  if (not new_log_level) then return default_return_val() end

  if (  new_log_level.level
  and new_log_level.level.num_val
  and new_log_level.level.num_val < 0)
  then
    return default_return_val()
  end

  if (  new_log_level.level
  and new_log_level.level.num_val
  and new_log_level.level.num_val >= 0)
  then
    -- log("Setting log level")
    storage.log_level = {
      level = new_log_level.level,
      valid = true
    }
    return
  end

  if (not is_number(new_log_level) and not is_string(new_log_level) and not new_log_level.valid) then return default_return_val() end

  if (is_number(new_log_level) and new_log_level >= 0) then
    storage.log_level = {
      level = Log_Constants_Functions.levels.get_level_by_value({ num_val = new_log_level }),
      valid = true
    }
    return
  end

  if (is_string(new_log_level)) then
    storage.log_level = {
      level = Log_Constants_Functions.levels.get_level_by_name({ string_val = new_log_level }),
      valid = true
    }
    return
  end

  local _new_log_level = Log_Constants_Functions.levels.get_level_by_name(new_log_level.level)
  log(serpent.block(_new_log_level))
  if (storage.log_level and storage.log_level.valid) then
    storage.log_level = {
      level = _new_log_level,
      valid = true
    }
    return
  end

  -- If made it this far, something went wrong
  -- -> return the default value
  log("Returning default log value")
  return default_return_val()
end

function log_message(message, log_level, traceback)
  -- Do nothing if the game is not loaded yet
  if (not is_game_loaded()) then return end

  -- log(serpent.block(log_level))
  log_level = log_level or Log_Constants.levels[Log_Constants.NONE.num_val]

  local _log_level = Log.get_log_level()
  if (not _log_level or not _log_level.valid) then
    log_print_message("Log level was invalid", { level = Log_Constants.levels[Log_Constants.NONE.num_val], valid = true })
    return
  end

  if (  log_level
    and log_level.valid
    and log_level.level
    and _log_level
    and _log_level.valid
    and _log_level.level
    and log_level.level.num_val >= _log_level.level.num_val) then
    log_print_message(message, log_level, traceback)
  end
end

function log_print_message(message, log_level, traceback)
  -- Do nothing if the game is not loaded yet
  if (not is_game_loaded()) then return end

  traceback = traceback or false

  -- Validate provided log_level
  if (not log_level or not log_level.valid) then
    -- Somethings really wrong if this is happening
    if (game) then
      game.print("log_level is nil or log_level is not valid")
    end
    log("returning")
    return
  end

  if (not storage or not storage.log_level or not storage.log_level.valid) then
    if (game) then
      game.print("log_level is nil or log_level is not valid")
    end
    if (storage) then
      log("log_level is nil or log_level is not valid")
      storage.log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    end
  end

  if (  log_level.valid
    and storage
    and storage.log_level
    and not storage.log_level.valid)
  then
    if (game) then
      game.print("log_level ~= storage.log_level")
    end
    Log.set_log_level(log_level)
  end

  -- Get the traceback setting
  local traceback_setting = nil
  if (not traceback
      and settings
      and settings.global
      and settings.global[Log_Constants.settings.DO_TRACEBACK.name])
  then
    traceback_setting = settings.global[Log_Constants.settings.DO_TRACEBACK.name]
  end

  if (traceback_setting and traceback_setting.value) then traceback = traceback_setting.value end

  -- Always print the traceback for a nil message
  -- log("traceback: " .. serpent.block(traceback))
  -- log("message: " .. serpent.block(message))
  -- if (message == nil and not traceback) then
  --   traceback = true
  -- end

  -- Always traceback messages that were broadcasted via logging
  -- or anything that used the .none(..) method
  if (  traceback
    or (  log_level
      and log_level.valid
      and log_level.level
      and log_level.level.num_val
        >= Log_Constants.levels[Log_Constants.NONE.num_val].level.num_val))
  then
    log(debug.traceback())
    message = "(traced) " .. serpent.block(message)
  end

  local do_prefix = log_level.level.num_val < Log_Constants.levels[Log_Constants.NONE.num_val].level.num_val
  log(log_level.level.string_val .. ": " .. serpent.block(message))

  local do_not_print = false
  if (settings and settings.global and settings.global[Log_Constants.settings.DO_NOT_PRINT.name]) then
    do_not_print = settings.global[Log_Constants.settings.DO_NOT_PRINT.name].value
  end

  if (game and not do_not_print) then
    game.print(
      do_print_prefix(log_level.level.string_val, do_prefix)
        .. serpent.block(message))
  end
end

function do_print_prefix(prefix, do_prefix)
  if (do_prefix) then return prefix ..  ": " else return Log_Constants.constants.EMPTY_STRING end
end

function is_game_loaded() return game end

function is_number(value)
  return tonumber(value) and true or false
end

function is_string(value)
  return tostring(value) and true or false
end

Log.all_seeing_satellite = true

local _log = Log

return Log
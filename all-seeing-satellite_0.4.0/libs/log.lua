-- If already defined, return
if _log and _log.all_seeing_satellite then
  return _log
end

Log_Constants = require("libs.constants.log-constants")
Settings_Constants = require("libs.constants.settings-constants")

local Log = {}

function Log.info(message, traceback)
  log_message(message, Log_Constants.levels.INFO.value, traceback)
end

function Log.debug(message, traceback)
  log_message(message, Log_Constants.levels.DEBUG.value, traceback)
end

function Log.warn(message, traceback)
  log_message(message, Log_Constants.levels.WARN.value, traceback)
end

function Log.error(message, traceback)
  log_message(message, Log_Constants.levels.ERROR.value, traceback)
end

function Log.get_log_level()
  local _log_level = Log_Constants.levels.NONE.name
  if (settings and settings.global and settings.global[Settings_Constants.DEBUG_LEVEL.name]) then
    _log_level = settings.global[Settings_Constants.DEBUG_LEVEL.name].value
    log_level = Log_Constants.levels.NONE


    if (_log_level == Log_Constants.levels.NONE.name) then
      log_level = Log_Constants.levels.NONE.value
    elseif (_log_level == Log_Constants.levels.ERROR.name) then
      log_level = Log_Constants.levels.ERROR.value
    elseif (_log_level == Log_Constants.levels.WARN.name) then
      log_level = Log_Constants.levels.WARN.value
    elseif (_log_level == Log_Constants.levels.DEBUG.name) then
      log_level = Log_Constants.levels.DEBUG.value
    elseif (_log_level == Log_Constants.levels.INFO.name) then
      log_level = Log_Constants.levels.INFO.value
    else
      log_level = Log_Constants.levels.NONE.value
    end

    if (not storage.log_level and log_level) then
      storage.log_level = log_level
    elseif (storage.log_level and log_level) then
      storage.log_level = log_level
    else
      log("Didn't find log level from settings")
      if (game) then
        game.print("Didn't find log level from settings")
      end
      storage.log_level = Log_Constants.levels.NONE.value
    end
  end

  return log_level
end

function Log.set_log_level(new_log_level)
  if (new_log_level >= 0) then
    storage.log_level = new_log_level
  else
    storage.log_level = Log_Constants.levels.NONE.value
  end
end

function log_message(message, log_level, traceback)
  log_level = log_level or Log_Constants.levels.NONE.value
  local _log_level = Log.get_log_level()

  if (log_level and log_level >= _log_level) then
    log_print_message(message, traceback)
  end
end

function log_print_message(message, traceback)
  if (traceback) then
    log(debug.traceback())
    log(serpent.block(message))
    if (game) then
      game.print(serpent.block(message))
    end
  else
    log(serpent.block(message))
    if (game) then
      game.print(serpent.block(message))
    end
  end
end

Log.all_seeing_satellite = true

local _log = Log

return Log
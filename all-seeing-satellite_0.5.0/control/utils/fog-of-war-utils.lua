-- If already defined, return
if _fog_of_war_utils and _fog_of_war_utils.all_seeing_satellite then
  return _fog_of_war_utils
end

local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Validations = require("control.validations.validations")

local fog_of_war_utils = {}

function fog_of_war_utils.print_toggle_message(message, surface_name, add_count)
  Log.debug("fog_of_war_utils.print_toggle_message")
  if (Validations.is_storage_valid() and storage.satellites_launched and storage.satellites_launched[surface_name]) then
    if (add_count) then
      game.print(message
              .. surface_name
              .. " : "
              .. storage.satellites_launched[surface_name]
              ..  " orbiting, "
              .. serpent.block(Planet_Utils.planet_launch_threshold(surface_name))
              .. " minimum"
            )
    else
      game.print(message .. surface_name .. " : " .. storage.satellites_launched[surface_name])
    end
  else
    game.print(message .. surface_name)
  end
end

fog_of_war_utils.all_seeing_satellite = true

local _fog_of_war_utils = fog_of_war_utils

return fog_of_war_utils
-- If already defined, return
if _fog_of_war_utils and _fog_of_war_utils.all_seeing_satellite then
  return _fog_of_war_utils
end

local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")

local fog_of_war_utils = {}

function fog_of_war_utils.print_toggle_message(message, surface_name, add_count)
  Log.debug("fog_of_war_utils.print_toggle_message")
  Log.info(message)
  Log.info(surface_name)
  Log.info(add_count)

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface_name)
  if (satellite_meta_data.valid) then
    if (add_count) then
      game.print(message
              .. surface_name
              .. " : "
              .. satellite_meta_data.satellites_in_orbit
              ..  " orbiting, "
              .. Planet_Utils.planet_launch_threshold(surface_name)
              .. " minimum"
            )
    else
      game.print(message .. surface_name .. " : " .. satellite_meta_data.satellites_in_orbit)
    end
  else
    game.print(message .. surface_name)
  end
end

fog_of_war_utils.all_seeing_satellite = true

local _fog_of_war_utils = fog_of_war_utils

return fog_of_war_utils
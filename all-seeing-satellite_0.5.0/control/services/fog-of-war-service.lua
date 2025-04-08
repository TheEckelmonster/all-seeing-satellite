-- If already defined, return
if _fog_of_war_service and _fog_of_war_service.all_seeing_satellite then
  return _fog_of_war_service
end

local Log = require("libs.log.log")
local Planet_Utils = require("control.utils.planet-utils")
local Storage_Service = require("control.services.storage-service")

local fog_of_war_service = {}

function fog_of_war_service.toggle_FoW()
  Log.debug("fog_of_war_controller.toggle_FoW")
  local player = storage.satellite_toggled_by_player

  if (Storage_Service.is_storage_valid()) then
    for k, satellite in pairs(storage.satellites_toggled) do
      -- If inputs are valid, and the surface the player is currently viewing is toggled
      if (  satellite
        and satellite.toggle
        and player
        and player.force
        and player.surface
        and player.surface.name == satellite.planet_name)
      then
        if (Planet_Utils.allow_toggle(satellite.planet_name)) then
          game.forces[player.force.index].rechart(player.surface)
          return
        end
      end
    end
  end
end

fog_of_war_service.all_seeing_satellite = true

local _fog_of_war_service = fog_of_war_service

return fog_of_war_service
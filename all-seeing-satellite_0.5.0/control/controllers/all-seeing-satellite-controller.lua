-- If already defined, return
if _all_seeing_satellite_controller and _all_seeing_satellite_controller.all_seeing_satellite then
  return _all_seeing_satellite_controller
end

local All_Seeing_Satellite_Service = require("control.services.all-seeing-satellite-service")
local All_Seeing_Satellite_Repository = require("control.repositories.all-seeing-satellite-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Fog_Of_War_Service = require("control.services.fog-of-war-service")
local Planet_Utils = require("control.utils.planet-utils")
local Rocket_Silo_Service = require("control.services.rocket-silo-service")
local Satellite_Service = require("control.services.satellite-service")
local Settings_Service = require("control.services.settings-service")
-- local Storage_Service = require("control.services.storage-service")
local Version_Validations = require("control.validations.version-validations")

local all_seeing_satellite_controller = {}

function all_seeing_satellite_controller.do_tick(event)
  -- if (not Storage_Service.get_do_nth_tick()) then return end
  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.do_nth_tick and all_seeing_satellite_data.version_data) then return end

  local tick = event.tick
  local nth_tick = Settings_Service.get_nth_tick()
  local offset = 1 + nth_tick
  local tick_modulo = tick % offset

  -- Check/validate the storage version
  if (not Version_Validations.validate_version()) then return end

  if (tick_modulo == 0 * (nth_tick / 3)) then

    -- TODO: Break this up over multiple ticks
    for k, planet in pairs(Constants.get_planets()) do
      Fog_Of_War_Service.toggle_FoW(planet)
    end

    -- Fog_Of_War_Service.toggle_FoW()
  end

  if (tick_modulo == 1 * math.floor((nth_tick / 3))) then
    -- TODO: Make this configurable
    -- i.e. a setting for infinite/no duration -> no need to check for expire satellites
    Satellite_Service.check_for_expired_satellites({ tick = game.tick })
  end

  if (tick_modulo == 2 * (math.floor(nth_tick / 3))) then
    -- TODO: Make this configurable
    -- Thinking just a simple boolean
    -- Rocket_Silo_Service.launch_rocket({ tick = game.tick })
    -- TODO: Break this up over multiple ticks
    for k, planet in pairs(Constants.get_planets()) do
      Rocket_Silo_Service.launch_rocket({ tick = game.tick, planet = planet })
    end

  end

  -- TODO: Make this configurable
  if (tick_modulo % 2 == 0) then
    -- if (not Storage_Service.get_do_scan()) then return end
    if (not all_seeing_satellite_data.do_scan) then return end

    -- TODO: Break this up over multiple ticks
    for k, planet in pairs(Constants.get_planets()) do
      if ( not Settings_Service.get_restrict_satellite_scanning()
        or not Settings_Service.get_require_satellites_in_orbit()
        or Planet_Utils.allow_scan(planet.name))
      then
        -- All_Seeing_Satellite_Service.check_for_areas_to_stage()
        -- All_Seeing_Satellite_Service.do_scan(planet.name)
        if (All_Seeing_Satellite_Service.check_for_areas_to_stage()) then
          All_Seeing_Satellite_Service.do_scan(planet.name)
        end
      end
    end
  end
end

all_seeing_satellite_controller.all_seeing_satellite = true

local _all_seeing_satellite_controller = all_seeing_satellite_controller

return all_seeing_satellite_controller
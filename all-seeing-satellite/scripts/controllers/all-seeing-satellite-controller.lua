-- If already defined, return
if _all_seeing_satellite_controller and _all_seeing_satellite_controller.all_seeing_satellite then
  return _all_seeing_satellite_controller
end

local All_Seeing_Satellite_Service = require("scripts.services.all-seeing-satellite-service")
local All_Seeing_Satellite_Repository = require("scripts.repositories.all-seeing-satellite-repository")
local Constants = require("libs.constants.constants")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")
local Fog_Of_War_Service = require("scripts.services.fog-of-war-service")
local Planet_Utils = require("scripts.utils.planet-utils")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Satellite_Service = require("scripts.services.satellite-service")
local Settings_Service = require("scripts.services.settings-service")
local Version_Validations = require("scripts.validations.version-validations")

local all_seeing_satellite_controller = {}

all_seeing_satellite_controller.planet_index = nil
all_seeing_satellite_controller.planet = nil

function all_seeing_satellite_controller.do_tick(event)
  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  if (not all_seeing_satellite_data.do_nth_tick and all_seeing_satellite_data.version_data) then return end

  local tick = event.tick
  local nth_tick = Settings_Service.get_nth_tick()
  local tick_modulo = tick % nth_tick

  if (tick % 2 == 0) then
    if (all_seeing_satellite_data.do_scan and all_seeing_satellite_controller.planet) then
      if (Planet_Utils.allow_scan(all_seeing_satellite_controller.planet.name)) then
        if (All_Seeing_Satellite_Service.check_for_areas_to_stage()) then
          All_Seeing_Satellite_Service.do_scan(all_seeing_satellite_controller.planet.name)
        end
      end
    end
  end

  if (tick_modulo ~= 0) then return end

  -- Check/validate the storage version
  if (not Version_Validations.validate_version()) then
    Initialization.reinit()
    return
  end

  if (not Constants.planets_dictionary) then Constants.get_planets(true) end
  all_seeing_satellite_controller.planet_index, all_seeing_satellite_controller.planet = next(Constants.planets_dictionary, all_seeing_satellite_controller.planet_index)

  local planet = all_seeing_satellite_controller.planet

  if (not planet or not all_seeing_satellite_controller.planet_index) then return end
  if (not planet.surface or not planet.surface.valid) then return end

  -- TODO: Make this configurable
  -- i.e. a setting for infinite/no duration -> no need to check for expired satellites
  Satellite_Service.check_for_expired_satellites({ tick = game.tick, planet_name = planet.name })

  Fog_Of_War_Service.toggle_FoW(planet)

  if (Settings_Service.get_do_launch_rockets()) then
    Rocket_Silo_Service.launch_rocket({ tick = game.tick, planet = planet })
  end
end

all_seeing_satellite_controller.all_seeing_satellite = true

local _all_seeing_satellite_controller = all_seeing_satellite_controller

return all_seeing_satellite_controller
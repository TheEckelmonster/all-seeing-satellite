-- If already defined, return
if _initialization and _initialization.all_seeing_satellite then
  return _initialization
end

local initialization = {}

local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")
local All_Seeing_Satellite_Repository = require("control.repositories.all-seeing-satellite-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Player_Repository = require("control.repositories.player-repository")
local Rocket_Silo_Data = require("control.data.rocket-silo-data")
local Rocket_Silo_Repository = require("control.repositories.rocket-silo-repository")
local Satellite_Meta_Data = require("control.data.satellite.satellite-meta-data")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Toggle_Data = require("control.data.satellite.satellite-toggle-data")
local String_Utils = require("control.utils.string-utils")
local Version_Data = require("control.data.version-data")
local Version_Service = require("control.services.version-service")

function initialization.init()
  log("Initializing All Seeing Satellites")
  Log.debug("Initializing All Seeing Satellites")

  return initialize(true) -- from_scratch
end

function initialization.reinit()
  log("Reinitializing All Seeing Satellites")
  Log.debug("Reinitializing All Seeing Satellites")

  return initialize(false) -- as is
end

function initialize(from_scratch)
  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  Log.info(all_seeing_satellite_data)

  all_seeing_satellite_data.do_nth_tick = false

  from_scratch = from_scratch or false

  if (from_scratch) then
    log("all-seeing-satellite: Initializing anew")
    if (game) then game.print("all-seeing-satellite: Initializing anew") end

    storage = {}
    all_seeing_satellite_data = All_Seeing_Satellite_Data:new()
    storage.all_seeing_satellite = all_seeing_satellite_data

    local version_data = all_seeing_satellite_data.version_data
    version_data.valid = true
  else
    if (not all_seeing_satellite_data) then
      storage.all_seeing_satellite = All_Seeing_Satellite_Data:new()
      all_seeing_satellite_data = storage.all_seeing_satellite
    end
    if (not all_seeing_satellite_data.staged_areas_to_chart) then all_seeing_satellite_data.staged_areas_to_chart = {} end
    if (not all_seeing_satellite_data.staged_chunks_to_chart) then all_seeing_satellite_data.staged_chunks_to_chart = {} end
  end

  if (all_seeing_satellite_data) then
    local version_data = all_seeing_satellite_data.version_data
    if (version_data and not version_data.valid) then
      return initialize(true)
    else
      local version = Version_Service.validate_version()
      if (not version or not version.valid) then
        version_data.valid = false
        return all_seeing_satellite_data
      end
    end

    if (game) then
      for k, player in pairs(game.players) do
        local player_data = Player_Repository.get_player_data(player.index)
        if (not player_data or not player_data.valid) then
          Log.error("Invalid player data detected")
          Log.debug(player_data)
        end
      end
    end
  end

  local planets = Constants.get_planets(true)

  for k, planet in pairs(planets) do
    -- Search for planets
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then

      if (from_scratch or not all_seeing_satellite_data.satellite_meta_data[planet.name]) then
        all_seeing_satellite_data.satellite_meta_data[planet.name] = Satellite_Meta_Repository.save_satellite_meta_data(planet.name)
      end

      local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)

      if (not satellite_meta_data.satellites_toggled) then
        satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
          planet_name = planet.name,
          toggle = false,
          valid = true
        })
      elseif (  satellite_meta_data.satellites_toggled
        and not satellite_meta_data.satellites_toggled.valid)
      then
        satellite_meta_data.satellites_toggled = Satellite_Toggle_Data:new({
          planet_name = planet.name,
          toggle = false,
          valid = true
        })
      end

      if (planet.surface) then
        local rocket_silos = planet.surface.find_entities_filtered({type = "rocket-silo"})
        for i=1, #rocket_silos do
          local rocket_silo = rocket_silos[i]
          if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
            add_rocket_silo(satellite_meta_data, rocket_silo)
          end
        end
      end
    end
  end

  if (storage and storage.all_seeing_satellite) then
    storage.all_seeing_satellite.do_nth_tick = true
  end

  storage.all_seeing_satellite.valid = true

  if (from_scratch) then log("all-seeing-satellite: Initialization complete") end
  if (from_scratch and game) then game.print("all-seeing-satellite: Initialization complete") end
  Log.info(storage)

  return all_seeing_satellite_data
end

function add_rocket_silo(satellite_meta_data, rocket_silo)
  Log.debug("add_rocket_silo")
  Log.info(satellite_meta_data)
  Log.info(rocket_silo)

  if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
    Log.warn("Call to add_rocket_silo with invalid input")
    Log.debug(rocket_silo)
    return
  end

  Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

initialization.all_seeing_satellite = true

local _initialization = initialization

return initialization
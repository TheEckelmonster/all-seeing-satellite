-- If already defined, return
if _initialization and _initialization.all_seeing_satellite then
  return _initialization
end

local All_Seeing_Satellite_Data = require("control.data.all-seeing-satellite-data")
local All_Seeing_Satellite_Repository = require("control.repositories.all-seeing-satellite-repository")
local Character_Repository = require("control.repositories.character-repository")
local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Player_Repository = require("control.repositories.player-repository")
local Research_Utils = require("control.utils.research-utils")
local Rocket_Silo_Data = require("control.data.rocket-silo-data")
local Rocket_Silo_Repository = require("control.repositories.rocket-silo-repository")
local Satellite_Meta_Data = require("control.data.satellite.satellite-meta-data")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Repository = require("control.repositories.satellite-repository")
local Satellite_Toggle_Data = require("control.data.satellite.satellite-toggle-data")
local String_Utils = require("control.utils.string-utils")
local Version_Data = require("control.data.version-data")
local Version_Service = require("control.services.version-service")

local initialization = {}

initialization.last_version_result = nil

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

function initialize(from_scratch, maintain_satellites)
  Log.debug("initialize")
  Log.info(from_scratch)
  Log.info(maintain_satellites)

  local all_seeing_satellite_data = All_Seeing_Satellite_Repository.get_all_seeing_satellite_data()
  Log.info(all_seeing_satellite_data)

  all_seeing_satellite_data.do_nth_tick = false

  from_scratch = from_scratch or false
  maintain_satellites = maintain_satellites or false

  if (not from_scratch) then
    -- Version check
    local version_data = all_seeing_satellite_data.version_data
    if (version_data and not version_data.valid) then
      local version = initialization.last_version_result
      if (not version) then goto initialize end
      if (not version.major or not version.minor or not version.bug_fix) then goto initialize end
      if (not version.major.valid) then goto initialize end
      if (not version.minor.valid or not version.bug_fix.valid) then
        return initialize(true, true)
      end

      ::initialize::
      return initialize(true)
    else
      local version = Version_Service.validate_version()
      initialization.last_version_result = version
      if (not version or not version.valid) then
        version_data.valid = false
        return all_seeing_satellite_data
      end
    end
  end

  -- All seeing satellite data
  if (from_scratch) then
    log("all-seeing-satellite: Initializing anew")
    if (game) then game.print("all-seeing-satellite: Initializing anew") end

    local _storage = storage
    _storage.storage_old = nil

    storage = {}
    all_seeing_satellite_data = All_Seeing_Satellite_Data:new()
    storage.all_seeing_satellite = all_seeing_satellite_data

    storage.storage_old = _storage

    -- do migrations
    migrate(maintain_satellites)

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

  -- Player data
  if (game) then
    for k, player in pairs(game.players) do
      local player_data = Player_Repository.get_player_data(player.index)
      if (not player_data.valid) then
        player_data = Player_Repository.save_player_data(player_data.player_index)
        if (not player_data.valid) then
          Log.warn("Invalid player data detected")
          Log.debug(player_data)
          goto continue
        end
      end

      if (not player_data.character_data or not player_data.character_data.valid) then
        local character_data = Character_Repository.get_character_data(player_data.index)
        if (not character_data.valid) then
          character_data = Character_Repository.save_character_data(player_data.index)

          if (not character_data.valid) then
            Log.warn("Invalid character data detected")
            Log.debug(character_data)
            Player_Repository.update_player_data({ player_index = player_data.player_index, valid = false, })
            goto continue
          end
        end
      end

      if (Research_Utils.has_technology_researched(player.force, Constants.DEFAULT_RESEARCH.name)) then
        if (player_data.editor_mode_toggled or String_Utils.find_invalid_substrings(player.surface.name)) then
          Player_Repository.update_player_data({ player_index = player.index, satellite_mode_stashed = true, })
        else
          Player_Repository.update_player_data({ player_index = player.index, satellite_mode_allowed = true, })
        end
      else
        Player_Repository.update_player_data({ player_index = player.index, satellite_mode_allowed = false, })
      end

      if (player_data.in_space) then
        player_data.in_space = String_Utils.find_invalid_substrings(player.surface.name)
      end

      ::continue::
    end
  end

  -- Planet/rocket-silo data
  local planets = Constants.get_planets(true)
  for k, planet in pairs(planets) do
    -- Search for planets
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
      if (from_scratch or not all_seeing_satellite_data.satellite_meta_data[planet.name]) then
        if (not maintain_satellites) then
          Satellite_Meta_Repository.save_satellite_meta_data(planet.name)
        else
          Satellite_Meta_Repository.get_satellite_meta_data(planet.name)
        end
      end

      local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)

      if (not satellite_meta_data.planet_name) then satellite_meta_data.planet_name = planet.name end

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

function migrate(maintain_satellites)
  Log.debug("migrate")
  Log.info(maintain_satellites)

  local storage_old = storage.storage_old
  if (not storage_old) then return end
  if (not type(storage_old) == "table") then return end

  -- Satellites
  if (storage_old.satellites_in_orbit ~= nil and type(storage_old.satellites_in_orbit) == "table") then
    for planet_name, satellites in pairs(storage_old.satellites_in_orbit) do
      for i, satellite in pairs(satellites) do
        Satellite_Repository.save_satellite_data(satellite)
      end
    end

    storage_old.satellites_in_orbit = nil
  end

  if (maintain_satellites) then
    if (storage_old.all_seeing_satellite) then
      local all_satellite_meta_data = storage_old.all_seeing_satellite.satellite_meta_data or {}
      for planet_name, satellite_meta_data in pairs(all_satellite_meta_data) do
        Satellite_Meta_Repository.get_satellite_meta_data(planet_name)
        Satellite_Meta_Repository.update_satellite_meta_data(satellite_meta_data)
      end
      storage_old.all_seeing_satellite.satellite_meta_data = nil
    end
  end

  -- Satellite launch count
  if (storage_old.satellites_launched ~= nil and type(storage_old.satellites_launched) == "table") then
    for planet_name, value in pairs(storage_old.satellites_launched) do
      local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet_name)

      Satellite_Meta_Repository.update_satellite_meta_data({
        planet_name = planet_name,
        satellites_launched = satellite_meta_data.satellites_launched + value
      })

      Satellite_Meta_Repository.update_satellite_meta_data({
        planet_name = planet_name,
        satellites_in_orbit = #satellite_meta_data.satellites
      })
    end

    storage_old.satellites_launched = nil
  end
end

initialization.all_seeing_satellite = true

local _initialization = initialization

return initialization
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
local Satellite_Meta_Data = require("control.data.satellite.satellite-meta-data")
local Satellite_Meta_Repository = require("control.repositories.satellite-meta-repository")
local Satellite_Toggle_Data = require("control.data.satellite.satellite-toggle-data")
local String_Utils = require("control.utils.string-utils")
local Validations = require("control.validations.validations")
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
  -- Log.error(all_seeing_satellite_data)

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

  -- if (not from_scratch and storage.satellites_toggled) then
  --   local remove_indices = {}

  --   Log.debug(storage.satellites_toggled)

  --   for i, satellite in ipairs(storage.satellites_toggled) do
  --     if (satellite and not satellite.valid) then
  --       table.insert(remove_indices, i)
  --     end
  --   end

  --   for i=0, #remove_indices do
  --     table.remove(storage.satellites_toggled, remove_indices[#remove_indices - i])
  --   end
  -- else
  --   storage.satellites_toggled = {}
  -- end

  -- Log.debug(storage.satellites_toggled)

  -- storage.rocket_silos = {}

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
          Log.warn(player_data)
        end
      end
    end
  end

  all_seeing_satellite_data.rocket_silos = {}

  local planets = Constants.get_planets(true)

  for k, planet in pairs(planets) do
    -- Search for planets
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then

      if (from_scratch or not all_seeing_satellite_data.satellite_meta_data[planet.name]) then
        -- all_seeing_satellite_data.satellite_meta_data[planet.name] = Satellite_Meta_Data:new({ surface_index = planet.surface.index })
        -- all_seeing_satellite_data.satellite_meta_data[planet.name] = Satellite_Meta_Data:new({ planet_name = planet.name })
        all_seeing_satellite_data.satellite_meta_data[planet.name] = Satellite_Meta_Repository.save_satellite_meta_data(planet.name)
        -- all_seeing_satellite_data.satellite_meta_data[planet.surface.index] = Satellite_Meta_Data:new({ surface_index = planet.surface.index })
      end

      -- if (not from_scratch) then
      --   if (storage.all_seeing_satellite.satellites_launched and not storage.all_seeing_satellite.satellites_launched[planet.name]) then
      --     storage.all_seeing_satellite.satellites_launched[planet.name] = 0
      --   end
      -- else
      --   if (not storage.all_seeing_satellite.satellites_launched) then
      --     storage.all_seeing_satellite.satellites_launched = {}
      --   end
      --   storage.all_seeing_satellite.satellites_launched[planet.name] = 0
      -- end

      -- if (not from_scratch) then
      --   if (storage.satellites_in_orbit and not storage.satellites_in_orbit[planet.name]) then
      --     storage.satellites_in_orbit[planet.name] = {}
      --   end
      -- else
      --   if (not storage.satellites_in_orbit) then
      --     storage.satellites_in_orbit = {}
      --   end
      --   storage.satellites_in_orbit[planet.name] = {}
      -- end

      -- if (storage.satellites_toggled) then
      --   if (not storage.satellites_toggled[planet.name]) then
      --     storage.satellites_toggled[planet.name] = {
      --       planet_name = planet.name,
      --       toggle = false,
      --       valid = true
      --     }
      --   elseif (  storage.satellites_toggled[planet.name]
      --     and not Validations.validate_toggled_satellites_planet(storage.satellites_toggled, planet.name))
      --   then
      --     storage.satellites_toggled[planet.name] = {
      --       planet_name = planet.name,
      --       toggle = false,
      --       valid = true
      --     }
      --   elseif (storage.satellites_toggled[planet.name].valid) then
      --     -- Is it though? Since the 0.4.x changes?
      --     local _toggle = storage.satellites_toggled[planet.name].toggled or (not storage.satellites_toggled[planet.name].toggled and storage.satellites_toggled[planet.name].toggle)

      --     if (not _toggle) then
      --       _toggle = false
      --     end

      --     storage.satellites_toggled[planet.name] = {
      --       planet_name = planet.name,
      --       toggle = _toggle,
      --       valid = true
      --     }
      --   end
      -- else
      --   Log.error("Initialization failed somehow", true)
      -- end

      -- local satellite_meta_data = all_seeing_satellite_data.satellite_meta_data[planet.name]
      -- local satellite_meta_data = all_seeing_satellite_data.satellite_meta_data[planet.surface.index]
      -- local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.surface.index)
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

      -- if (planet.surface) then
      --   local rocket_silos = planet.surface.find_entities_filtered({type = "rocket-silo"})
      --   for i=1, #rocket_silos do
      --     local rocket_silo = rocket_silos[i]
      --     if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then

      --       if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
      --         and not storage.rocket_silos[rocket_silo.surface.name])
      --       then
      --         storage.rocket_silos[rocket_silo.surface.name] = {}
      --       end

      --       if (storage.rocket_silos[rocket_silo.surface.name]) then
      --         add_rocket_silo(rocket_silo)
      --       else
      --         Log.error("Failed to add rocket silo")
      --         Log.debug(rocket_silo)
      --         Log.debug(rocket_silo.surface.name)
      --       end
      --     end
      --   end
      -- end

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

function add_rocket_silo(satellite_meta_data, rocket_silo, is_init)
  Log.debug("add_rocket_silo")
  Log.info(satellite_meta_data)
  Log.info(rocket_silo)
  Log.info(is_init)
  -- Validate inputs
  is_init = is_init or false

  -- if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
  --   Log.warn("Call to add_rocket_silo with invalid input")
  --   Log.debug(rocket_silo)
  --   return
  -- end

  -- if (not storage.rocket_silos) then
  --   if (is_init) then
  --     storage.rocket_silos = {}
  --   else
  --     Log.warn("storage.rocket_silos is nil; initializing")
  --     Initialization.init()
  --   end
  --   return
  -- end

  -- if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
  --   and not storage.rocket_silos[rocket_silo.surface.name])
  -- then
  --   storage.rocket_silos[rocket_silo.surface.name] = {}
  -- end

  -- if (storage.rocket_silos[rocket_silo.surface.name]) then
  --   table.insert(storage.rocket_silos[rocket_silo.surface.name], {
  --     unit_number = rocket_silo.unit_number,
  --     entity = rocket_silo,
  --     valid = rocket_silo.valid
  --   })
  -- else
  --   Log.error("This shouldn't be possible")
  --   Log.debug(rocket_silo.surface.name)
  -- end

  if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
    Log.warn("Call to add_rocket_silo with invalid input")
    Log.debug(rocket_silo)
    return
  end

  if (satellite_meta_data.rocket_silos) then
    table.insert(satellite_meta_data.rocket_silos, Rocket_Silo_Data:new({
      unit_number = rocket_silo.unit_number,
      entity = rocket_silo,
      valid = rocket_silo.valid
    }))
  else
    Log.error("This shouldn't be possible")
    Log.debug(rocket_silo.surface.name)
  end
end

initialization.all_seeing_satellite = true

local _initialization = initialization

return initialization
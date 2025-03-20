-- If already defined, return
if _initialization and _initialization.all_seeing_satellite then
  return _initialization
end

local initialization = {}

local Constants = require("libs.constants.constants")
local Log = require("libs.log")
local String_Utils = require("libs.utils.string-utils")
local Validations = require("libs.validations")

function initialization.init()
  log("Initializing")
  Log.debug("Initializing All Seeing Satellites")

  storage.satellite_toggled_by_player = nil

  storage.satellites_launched = {}
  storage.satellites_toggled = {}
  storage.rocket_silos = {}
  storage.satellites_in_orbit = {}

  local planets = Constants.get_planets(true)
  Log.debug(planets)
  for _, planet in pairs(planets) do
    -- Search for planets
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
      storage.satellites_launched[planet.name] = 0
      storage.satellites_in_orbit[planet.name] = {}
      table.insert(storage.satellites_toggled, {
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

          if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
            and not storage.rocket_silos[rocket_silo.surface.name])
          then
            storage.rocket_silos[rocket_silo.surface.name] = {}
          end

          if (storage.rocket_silos[rocket_silo.surface.name]) then
            add_rocket_silo(rocket_silo, true)
          else
            log(serpent.block(rocket_silo.surface.name))
          end
        end
      end
    end
  end

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = true

  Log.debug(storage)

  log("Finished initializing")
  Log.debug("Finished initializing All Seeing Satellites")
end

function initialization.reinit()
  log("Reinitializing")
  Log.debug("Reinitializing All Seeing Satellites")


  if (storage.satellites_toggled) then
    local remove_indices = {}

    Log.debug(storage.satellites_toggled)

    for i, satellite in ipairs(storage.satellites_toggled) do
      if (satellite and not satellite.valid) then
        table.insert(remove_indices, i)
      end
    end

    for i=0, #remove_indices do
      table.remove(storage.satellites_toggled, remove_indices[#remove_indices - i])
    end
  else
    storage.satellites_toggled = {}
  end

  Log.debug(storage.satellites_toggled)

  storage.rocket_silos = {}

  local planets = Constants.get_planets(true)
  Log.debug(planets)

  for _, planet in pairs(planets) do
    -- Search for planets
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then

      if (storage.satellites_launched and not storage.satellites_launched[planet.name]) then
        storage.satellites_launched[planet.name] = 0
      end

      if (storage.satellites_in_orbit and not storage.satellites_in_orbit[planet.name]) then
        storage.satellites_in_orbit[planet.name] = {}
      end

      if (storage.satellites_toggled) then
        if (not storage.satellites_toggled[planet.name]) then
          storage.satellites_toggled[planet.name] = {
            planet_name = planet.name,
            toggle = false,
            valid = true
          }
        elseif (  storage.satellites_toggled[planet.name]
          and not Validations.validate_toggled_satellites_planet(storage.satellites_toggled, planet.name))
        then
          storage.satellites_toggled[planet.name] = {
            planet_name = planet.name,
            toggle = false,
            valid = true
          }
        elseif (storage.satellites_toggled[planet.name].valid) then
          -- Is it though? Since the 0.4.x changes?
          local _toggle = storage.satellites_toggled[planet.name].toggled or (not storage.satellites_toggled[planet.name].toggled and storage.satellites_toggled[planet.name].toggle)

          if (not _toggle) then
            _toggle = false
          end

          storage.satellites_toggled[planet.name] = {
            planet_name = planet.name,
            toggle = _toggle,
            valid = true
          }
        end
      end
    end

    if (planet.surface) then
      local rocket_silos = planet.surface.find_entities_filtered({type = "rocket-silo"})
      for i=1, #rocket_silos do
        local rocket_silo = rocket_silos[i]
        if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then

          if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
          and not storage.rocket_silos[rocket_silo.surface.name])
          then
            storage.rocket_silos[rocket_silo.surface.name] = {}
          end

          if (storage.rocket_silos[rocket_silo.surface.name]) then
            add_rocket_silo(rocket_silo)
          else
            Log.error("Failed to add rocket silo")
            Log.debug(rocket_silo)
            Log.debug(rocket_silo.surface.name)
          end
        end
      end
    end
  end

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = true

  Log.debug(storage)

  log("Finished reinitializing")
  Log.debug("Finished reinitializing All Seeing Satellites")
end

function add_rocket_silo(--[[required]]rocket_silo, --[[optional]]is_init)
  -- Validate inputs
  is_init = is_init or false -- default value

  if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
    Log.warn("Call to add_rocket_silo with invalid input")
    Log.debug(rocket_silo)
    return
  end

  if (not storage.rocket_silos) then
    if (is_init) then
      storage.rocket_silos = {}
    else
      Log.warn("storage.rocket_silos is nil; initializing")
      Initialization.init()
    end
    return
  end

  if (  not String_Utils.find_invalid_substrings(rocket_silo.surface.name)
    and not storage.rocket_silos[rocket_silo.surface.name])
  then
    storage.rocket_silos[rocket_silo.surface.name] = {}
  end

  if (storage.rocket_silos[rocket_silo.surface.name]) then
    table.insert(storage.rocket_silos[rocket_silo.surface.name], {
      unit_number = rocket_silo.unit_number,
      entity = rocket_silo,
      valid = rocket_silo.valid
    })
  else
    Log.error("This shouldn't be possible")
    Log.debug(rocket_silo.surface.name)
  end
end

initialization.all_seeing_satellite = true

local _initialization = initialization

return initialization
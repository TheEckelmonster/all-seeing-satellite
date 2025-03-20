-- If already defined, return
if _initialization and _initialization.all_seeing_satellite then
  return _initialization
end

local initialization = {}

local Constants = require("libs.constants.constants")
local String_Utils = require("libs.utils.string-utils")

function initialization.init()
  log("Initializing")
  if (game) then
    game.print("Initializing All Seeing Satellites")
  end

  storage.satellite_toggled_by_player = nil

  storage.satellites_launched = {}
  storage.satellites_toggled = {}
  storage.rocket_silos = {}
  storage.satellites_in_orbit = {}

  local planets = Constants.get_planets(true)
  log(serpent.block(planets))
  game.print(serpent.block(planets))
  for _, planet in pairs(planets) do
    -- Search for planets
    -- if (planet or not String_Utils.find_invalid_substrings(planet.name)) then
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
      storage.satellites_launched[planet.name] = 0
      storage.satellites_in_orbit[planet.name] = {}
      -- table.insert(storage.satellites_toggled, { planet.name, false })
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

  log(serpent.block(storage))
  game.print(serpent.block(storage))

  log("Finished initializing")
  if (game) then
    game.print("Finished initializing All Seeing Satellites")
  end
end

function initialization.reinit()
  log("Reinitializing")
  if (game) then
    game.print("Reinitializing All Seeing Satellites")
  end

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = false

  -- storage.satellite_toggled_by_player = nil

  -- storage.satellites_launched = {}
  if (storage.satellites_toggled) then
    local remove_indices = {}

    log(serpent.block(storage.satellites_toggled))
    game.print(serpent.block(storage.satellites_toggled))

    for i, satellite in ipairs(storage.satellites_toggled) do
      if (satellite and not satellite.valid) then
        table.insert(remove_indices, i)
      end
    end

    for i=0, #remove_indices do
      log(serpent.block(storage.satellites_toggled))
      game.print(serpent.block(storage.satellites_toggled))
      log(serpent.block(remove_indices[#remove_indices - i]))
      game.print(serpent.block(remove_indices[#remove_indices - i]))
      table.remove(storage.satellites_toggled, remove_indices[#remove_indices - i])
    end
    -- for i, v in pairs(remove_indices) do
    --   log(serpent.block(storage.satellites_toggled))
    --   game.print(serpent.block(storage.satellites_toggled))
    --   log(serpent.block(#remove_indices - i))
    --   game.print(serpent.block(#remove_indices - i))
    --   table.remove(storage.satellites_toggled, #remove_indices - i)
    -- end

  else
    storage.satellites_toggled = {}
  end


  storage.rocket_silos = {}
  -- storage.satellites_in_orbit = {}

  local planets = Constants.get_planets(true)
  log(serpent.block(planets))
  game.print(serpent.block(planets))
  for _, planet in pairs(planets) do
    -- Search for planets
    -- if (planet or not String_Utils.find_invalid_substrings(planet.name)) then
    if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
      log(serpent.block(storage.satellites_launched))
      game.print(serpent.block(storage.satellites_launched))

      if (storage.satellites_launched and not storage.satellites_launched[planet.name]) then
        storage.satellites_launched[planet.name] = 0
      end

      log(serpent.block(storage.satellites_launched))
      game.print(serpent.block(storage.satellites_launched))

      if (storage.satellites_in_orbit and not storage.satellites_in_orbit[planet.name]) then
        storage.satellites_in_orbit[planet.name] = {}
      end

      if (storage.satellites_toggled) then
        log(serpent.block(storage.satellites_toggled))
        game.print(serpent.block(storage.satellites_toggled))

        if (not storage.satellites_toggled[planet.name]) then
          storage.satellites_toggled[planet.name] = {
            planet_name = planet.name,
            toggle = false,
            valid = true
          }
        elseif (not storage.satellites_toggled[planet.name].valid) then
          storage.satellites_toggled[planet.name] = {
            planet_name = planet.name,
            toggle = false,
            valid = true
          }
        elseif (storage.satellites_toggled[planet.name].valid) then
          -- Is it though? Since the 0.4.x changes?
          -- storage.satellites_toggled[planet.name].toggle = storage.satellites_toggled[planet.name].toggled or (not storage.satellites_toggled[planet.name].toggled and storage.satellites_toggled[planet.name].toggle)
          -- storage.satellites_toggled[planet.name].toggled = nil
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
            -- add_rocket_silo(rocket_silo, true)
            add_rocket_silo(rocket_silo)
          else
            log(serpent.block(rocket_silo.surface.name))
          end
        end
      end
    end
  end

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = true

  log(serpent.block(storage))
  game.print(serpent.block(storage))

  log("Finished reinitializing")
  if (game) then
    game.print("Finished reinitializing All Seeing Satellites")
  end
end

function add_rocket_silo(--[[required]]rocket_silo, --[[optional]]is_init)
  -- Validate inputs
  is_init = is_init or false -- default value

  if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
    log("Call to add_rocket_silo with invalid input")
    log(serpent.block(rocket_silo))
    return
  end

  if (not storage.rocket_silos) then
    if (is_init) then
      storage.rocket_silos = {}
    else
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
    -- log("adding rocket silo to rocket_silos: ")
    -- log(serpent.block(rocket_silo))
    table.insert(storage.rocket_silos[rocket_silo.surface.name], {
      unit_number = rocket_silo.unit_number,
      entity = rocket_silo,
      valid = rocket_silo.valid
    })
  else
    log("This shouldn't be possible")
    log(serpent.block(rocket_silo.surface.name))
  end
end

initialization.all_seeing_satellite = true

local _initialization = initialization

return initialization
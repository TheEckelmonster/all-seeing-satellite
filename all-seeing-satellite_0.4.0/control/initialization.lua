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

  -- prototypes.get_entity_filtered{{filter="crafting-category", crafting_category="crafting-with-fluid"}}
  local planet_prototypes = prototypes.get_entity_filtered({{ filter = "type", type = "constant-combinator"}})
  -- local planet_prototypes = prototypes.get_entity_filtered({{ filter = "flag", flag = "get-by-unit-number" }})

  for k,v in pairs(planet_prototypes) do
    if (String_Utils.is_all_seeing_satellite_added_planet(k)) then
      -- log(serpent.block(string.sub(k, 22)))
      -- game.print(serpent.block(string.sub(k, 22)))
      -- log(serpent.block(v))
      -- game.print(serpent.block(v))
      -- log(serpent.block(v.valid))
      -- game.print(serpent.block(v.valid))
      -- log(serpent.block(String_Utils.get_planet_name(k)))
      -- game.print(serpent.block(String_Utils.get_planet_name(k)))
      -- log(serpent.block(String_Utils.get_planet_magnitude(k)))
      -- game.print(serpent.block(String_Utils.get_planet_magnitude(k)))
    end
  end

  storage.satellite_toggled_by_player = nil

  storage.satellites_launched = {}
  storage.satellites_toggled = {}
  storage.rocket_silos = {}
  storage.satellites_in_orbit = {}

  for k, surface in pairs(game.surfaces) do
    -- Search for planets
    if (surface.planet or not String_Utils.find_invalid_substrings(surface.name)) then
      -- log(serpent.block(k))
      -- game.print(serpent.block(k))
      -- log(serpent.block(surface))
      -- game.print(serpent.block(surface))
      -- log(serpent.block(surface.planet))
      -- game.print(serpent.block(surface.planet))

      storage.satellites_launched[surface.name] = 0
      storage.satellites_in_orbit[surface.name] = {}
      table.insert(storage.satellites_toggled, { surface.name, false })
    end

    local rocket_silos = surface.find_entities_filtered({type = "rocket-silo"})
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

  storage.all_seeing_satellite = {}
  storage.all_seeing_satellite.valid = true

  -- log(serpent.block(storage))
  -- game.print(serpent.block(storage))
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
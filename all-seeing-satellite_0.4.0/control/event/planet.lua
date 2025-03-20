-- If already defined, return
if _planet and _planet.all_seeing_satellite then
  return _planet
end

local Constants = require("libs.constants.constants")
local Initialization = require("control.initialization")

local planet = {}

function planet.on_surface_created(event)
  log(serpent.block(event))
  game.print(serpent.block(event))

  local planets = Constants.get_planets(true)
  log(serpent.block(planets))
  game.print(serpent.block(planets))
  Initialization.reinit()
end

planet.all_seeing_satellite = true

local _planet = planet

return planet
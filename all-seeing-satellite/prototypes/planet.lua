local String_Constants = require("libs.constants.string-constants")

local planet_magnitude_data = {
  type = "mod-data",
  name = "all-seeing-satellite-mod-data",
  data = {},
}

-- Create a copy of the constant combinator
-- -> Why constant-combinator? Not really sure...something, something, I'm
--    hacking it to pass *constant* data from the data stage to the control stage
for k, planet in pairs(data.raw.planet) do
  -- local temp = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])

  -- local temp = {}
  -- temp.type = "mod-data"
  -- temp.data = {}
  -- temp.data.magnitude = 1

  local magnitude = 1

  if (planet and type(planet) == "table" and planet.magnitude and type(planet.magnitude) == "number" and planet.magnitude > 0) then
    magnitude = planet.magnitude
  end

  if (planet and type(planet) == "table" and planet.name and type(planet.name) == "string" and #planet.name > 0) then
    planet_magnitude_data.data[planet.name] = {
      magnitude = magnitude,
    }
  end

  -- temp.data.magnitude = magnitude

  -- temp.name = "all-seeing-satellite-" .. planet.name .. "_" .. (math.floor(magnitude * String_Constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value))

  -- log(temp.name)

  -- TODO: Look into/clean up miscellaneous properties that aren't needed/necessary
  -- data:extend({ temp })
end

log(serpent.block(planet_magnitude_data))
data:extend({ planet_magnitude_data })
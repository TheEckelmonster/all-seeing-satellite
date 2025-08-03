local String_Constants = require("libs.constants.string-constants")

-- Create a copy of the constant combinator
-- -> Why constant-combinator? Not really sure...something, something, I'm
--    hacking it to pass *constant* data from the data stage to the control stage
for k, planet in pairs(data.raw.planet) do
  local temp = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  local magnitude = 1

  if (planet and type(planet) == "table" and planet.magnitude and type(planet.magnitude) == "number" and planet.magnitude > 0) then
    magnitude = planet.magnitude
  end

  temp.name = "all-seeing-satellite-" .. planet.name .. "_" .. (math.floor(magnitude * String_Constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value))

  -- log(temp.name)

  -- TODO: Look into/clean up miscellaneous properties that aren't needed/necessary
  data:extend({ temp })
end
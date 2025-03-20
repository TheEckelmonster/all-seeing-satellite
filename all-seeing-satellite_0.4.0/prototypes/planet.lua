local String_Constants = require("libs.constants.string-constants")

-- Create a copy of the constant combinator
-- -> Why constant-combinator? Not really sure...something, something, I'm
--    hacking it to pass *constant* data from the data stage to the control stage
for k, planet in pairs(data.raw.planet) do
  local temp = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  temp.name = "all-seeing-satellite-" .. planet.name .. "_" .. (math.floor(planet.magnitude * String_Constants.PLANET_MAGNITUDE_DECIMAL_SHIFT.value))
  data:extend({ temp })
end
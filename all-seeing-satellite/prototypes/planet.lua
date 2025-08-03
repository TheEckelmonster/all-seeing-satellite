local planet_magnitude_data = {
  type = "mod-data",
  name = "all-seeing-satellite-mod-data",
  data = {},
}

for _, planet in pairs(data.raw.planet) do

  local magnitude = 1

  if (planet and type(planet) == "table" and planet.magnitude and type(planet.magnitude) == "number" and planet.magnitude > 0) then
    magnitude = planet.magnitude
  end

  if (planet and type(planet) == "table" and planet.name and type(planet.name) == "string" and #planet.name > 0) then
    planet_magnitude_data.data[planet.name] = {
      magnitude = magnitude,
    }
  end
end

-- log(serpent.block(planet_magnitude_data))
data:extend({ planet_magnitude_data })
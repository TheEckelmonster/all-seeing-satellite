-- If already defined, return
if _research and _research.all_seeing_satellite then
  return _research
end

local research = {}

function research.has_technology_researched(force, filter)
  if (filter and force and force.technologies) then
    for i, technology in pairs(force.technologies) do
      if (i and i == filter and technology.researched) then
        return true
      end
    end
  end

  return false
end

research.all_seeing_satellite = true

local _research = research

return research
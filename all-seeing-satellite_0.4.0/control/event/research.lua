-- If already defined, return
if _research and _research.all_seeing_satellite then
  return _research
end

local research = {}

research.all_seeing_satellite = true

local _research = research

return research
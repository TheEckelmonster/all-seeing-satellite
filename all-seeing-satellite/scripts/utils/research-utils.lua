local research = {}

function research.has_technology_researched(force, filter)
    if (filter and force and force.technologies) then
        for i, technology in pairs(force.technologies) do
            if (i and i == filter and technology.researched) then
                return true
            end
        end
    end
    Log.warn("rocket-silo technology not researched yet")
    return false
end

return research
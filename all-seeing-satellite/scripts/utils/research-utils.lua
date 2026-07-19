local research_utils = {}
research_utils.name = "research_utils"

function research_utils.has_technology_researched(force, filter)
    if (filter and force and force.valid and force.technologies) then
        if (force.technologies[filter]) then
            return force.technologies[filter].researched
        end
    end

    return false
end

return research_utils
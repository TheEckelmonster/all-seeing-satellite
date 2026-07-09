local data = data
local mods = mods

local pairs = pairs

local custom_events =
{
    {
        type = "custom-event",
        name = "as-on-init-complete"
    },
}

if (mods and not script) then
    data:extend(custom_events)
else
    local custom_events_dictionary = {}
    for k, v in pairs(custom_events) do
        local event_name = v.name:gsub("%-", "_")
        custom_events_dictionary[event_name] = v
    end

    return custom_events_dictionary
end
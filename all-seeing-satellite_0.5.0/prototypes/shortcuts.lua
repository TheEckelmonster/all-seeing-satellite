data:extend({
  {
    type = "shortcut",
    name = "give-satellite-scanning-remote",
    order = "f[spidertron-remote]",
    action = "spawn-item",
    localised_name = { "shortcut.create-satellite-scanning-remote" },
    associated_control_input = "give-satellite-scanning-remote",
    technology_to_unlock = "rocket-silo",
    unavailable_until_unlocked = true,
    item_to_spawn = "satellite-scanning-remote",
    icon = "__base__/graphics/icons/satellite.png",
    icon_size = 56,
    small_icon = "__base__/graphics/icons/satellite.png",
    small_icon_size = 24
  }
})

data:extend({
  {
    type = "shortcut",
    name = "give-satellite-targeting-remote",
    order = "f[spidertron-remote]",
    action = "spawn-item",
    -- action = "lua",
    localised_name = { "shortcut.make-satellite-targeting-remote" },
    associated_control_input = "give-satellite-targeting-remote",
    technology_to_unlock = "rocket-silo",
    unavailable_until_unlocked = true,
    item_to_spawn = "satellite-targeting-remote",
    icon = "__base__/graphics/icons/shortcut-toolbar/mip/artillery-targeting-remote-x56.png",
    icon_size = 56,
    small_icon = "__base__/graphics/icons/shortcut-toolbar/mip/artillery-targeting-remote-x24.png",
    small_icon_size = 24
  }
})

local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
  {
    type = "item",
    name = "satellite",
    icon = "__base__/graphics/icons/satellite.png",
    subgroup = "space-related",
    order = "d[rocket-parts]-e[satellite]",
    inventory_move_sound = item_sounds.mechanical_inventory_move,
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    stack_size = 1,
    weight = 1 * tons,
    -- rocket_launch_products = {{type = "item", name = "space-science-pack", amount = 1000}},
    send_to_orbit_mode = "automated"
  },
})
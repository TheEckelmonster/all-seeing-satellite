local Item_Sounds = require("__base__.prototypes.item_sounds")
local Settings_Constants = require("libs.constants.settings-constants")

data:extend({
    {
        type = "item",
        name = "satellite",
        icon = "__base__/graphics/icons/satellite.png",
        subgroup = "space-related",
        order = "d[rocket-parts]-e[satellite]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        stack_size = 1,
        weight = 1 * tons,
        -- rocket_launch_products = {{type = "item", name = "space-science-pack", amount = 1000}},
        send_to_orbit_mode = "automated"
    },
    {
        type = "selection-tool",
        name = "satellite-scanning-remote",
        icon = "__base__/graphics/icons/satellite.png",
        flags = { "only-in-cursor", "not-stackable", "spawnable" },
        subgroup = "spawnables",
        order = "b[turret]-e[artillery-turret]-b[remote]",
        inventory_move_sound = Item_Sounds.planner_inventory_move,
        pick_sound = Item_Sounds.planner_inventory_pickup,
        drop_sound = Item_Sounds.planner_inventory_move,
        stack_size = 1,
        draw_label_for_cursor_render = false,
        skip_fog_of_war = true,
        auto_recycle = false,
        select =
        {
            border_color = { 71, 255, 73 },
            mode = { "nothing" },
            cursor_box_type = "copy",
        },
        alt_select =
        {
            border_color = { 239, 153, 34 },
            mode = { "any-tile" },
            cursor_box_type = "copy",
        },
        open_sound = "__base__/sound/item-open.ogg",
        close_sound = "__base__/sound/item-close.ogg"
    },

})
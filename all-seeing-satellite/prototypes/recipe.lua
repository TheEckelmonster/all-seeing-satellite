local mods = mods
local sa_active = mods and mods["space-age"] and true
data:extend({
    {
        type = "recipe",
        name = "satellite",
        energy_required = 5,
        enabled = false,
        categories = { "crafting", },
        ingredients =
        {
            { type = "item", name = "low-density-structure", amount = 100 },
            { type = "item", name = "solar-panel",           amount = 100 },
            { type = "item", name = "accumulator",           amount = 100 },
            { type = "item", name = "radar",                 amount = 5 },
            { type = "item", name = "processing-unit",       amount = 100 },
            { type = "item", name = "rocket-fuel",           amount = 50 }
        },
        results = { { type = "item", show_details_in_recipe_tooltip = not sa_active, name = "satellite", amount = 1 } },
        requester_paste_multiplier = 1
    },
    {
        type = "recipe",
        name = "used-rocket-booster",
        icon = "__all-seeing-satellite__/graphics/icons/used-rocket-booster.png",
        energy_required = 10,
        enabled = false,
        categories = { "crafting-with-fluid", },
        category = "crafting-with-fluid",
        ingredients =
        {
            { type = "item",  name = "used-rocket-booster", amount = 1, },
            { type = "fluid", name = "water", amount = 100, },
        },
        results = {
            { type = "item",   show_details_in_recipe_tooltip = false, name = "low-density-structure", amount_min = 0, amount_max = 1, },
            { type = "item",   show_details_in_recipe_tooltip = false, name = "electronic-circuit",    amount_min = 0, amount_max = 2, },
            { type = "item",   show_details_in_recipe_tooltip = false, name = "plastic-bar",           amount_min = 0, amount_max = 2, },
            { type = "item",   show_details_in_recipe_tooltip = false, name = "steel-plate",           amount_min = 1, amount_max = 3, },
            { type = "item",   show_details_in_recipe_tooltip = false, name = "copper-cable",          amount_min = 1, amount_max = 4, },
            { type = "fluid",  show_details_in_recipe_tooltip = false, name = "heavy-oil",             amount_min = 10, amount_max = 25,},
        },
        requester_paste_multiplier = 1,
        hidden = true,
        hidden_in_factoriopedia = true,
    },
})
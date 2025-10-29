data:extend({
    {
        type = "recipe",
        name = "satellite",
        energy_required = 5,
        enabled = false,
        category = "crafting",
        ingredients =
        {
            { type = "item", name = "low-density-structure", amount = 100 },
            { type = "item", name = "solar-panel",           amount = 100 },
            { type = "item", name = "accumulator",           amount = 100 },
            { type = "item", name = "radar",                 amount = 5 },
            { type = "item", name = "processing-unit",       amount = 100 },
            { type = "item", name = "rocket-fuel",           amount = 50 }
        },
        results = { { type = "item", name = "satellite", amount = 1 } },
        requester_paste_multiplier = 1
    }
})
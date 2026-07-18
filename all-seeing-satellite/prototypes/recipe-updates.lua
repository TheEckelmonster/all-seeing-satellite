local used_rocket_booster_recycling = data.raw.recipe["used-rocket-booster-recycling"]

used_rocket_booster_recycling.energy_required = 1
used_rocket_booster_recycling.results = {
    { type = "item",  name = "processing-unit",       amount = 1, independent_probability = 0.05, },
    { type = "item",  name = "low-density-structure", amount = 1, independent_probability = 0.1, },
    { type = "item",  name = "steel-plate",           amount_min = 1, amount_max = 3, independent_probability = 0.25, },
    { type = "item",  name = "advanced-circuit",      amount_min = 1, amount_max = 3, independent_probability = 0.25, },
    { type = "item",  name = "battery",               amount_min = 1, amount_max = 3, independent_probability = 0.25, },
    { type = "item",  name = "iron-plate",            amount_min = 1, amount_max = 4, independent_probability = 0.45, },
    { type = "item",  name = "copper-plate",          amount_min = 1, amount_max = 4, independent_probability = 0.45, },
    { type = "item",  name = "plastic-bar",           amount_min = 1, amount_max = 4, independent_probability = 0.45, },
    { type = "item",  name = "copper-cable",          amount_min = 1, amount_max = 8, independent_probability = 0.60, },
}

used_rocket_booster_recycling.hidden = true
used_rocket_booster_recycling.hidden_in_factoriopedia = true
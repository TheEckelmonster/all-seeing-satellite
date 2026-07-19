local mods = mods
if (mods and mods["space-age"]) then
    table.insert(data.raw.technology["rocket-silo"].effects, { type = "unlock-recipe", recipe = "satellite" })
    table.insert(data.raw.technology["rocket-silo"].effects, { type = "unlock-recipe", recipe = "used-rocket-booster", hidden = true, })
end
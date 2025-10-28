local Constants = require("scripts.constants.constants")
local Mod_Data = require("__TheEckelmonster-core-library__.libs.mod-data.mod-data")
local Space_Data = require("__TheEckelmonster-core-library__.libs.mod-data.space-data")

local space_data = Space_Data.create_planet_data({
    mod_data = Mod_Data.create({
        name = Constants.mod_name .. "-mod-data"
    })
})

data:extend({
    space_data,
})
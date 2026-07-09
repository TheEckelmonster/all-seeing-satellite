local storage

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game

    -- Set_Game_Funcs()

    return game
end

local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")

local rocket_silo_utils = {}
rocket_silo_utils.name = "rocket_silo_utils"
rocket_silo_utils.set_game = set_game

function rocket_silo_utils.mine_rocket_silo(event)
    -- Log.debug("rocket_silo_utils.mine_rocket_silo")
    -- Log.info(event)
    local rocket_silo = event.entity

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        storage.rocket_silos = storage.rocket_silos or {}
        storage.rocket_silos[rocket_silo.unit_number] = nil
        Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
    end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
    -- Log.debug("rocket_silo_utils.add_rocket_silo")
    -- Log.info(rocket_silo)

    local saved_rocket_silo = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
    if (saved_rocket_silo and saved_rocket_silo.valid) then
        storage.rocket_silos = storage.rocket_silos or {}
        storage.rocket_silos[saved_rocket_silo.unit_number] = saved_rocket_silo
    end
end

function rocket_silo_utils.init(__storage) storage = __storage end

return rocket_silo_utils
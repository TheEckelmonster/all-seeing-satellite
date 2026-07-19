local storage

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    game = __game or _ENV.game

    return game
end

local setmetatable = setmetatable

local data = {}
data.name = "data"
data.set_game = set_game()

-- Audit fields
data.created = nil
data.updated = nil

function data:new(o, tick)
    -- Log.debug("data:new")
    -- Log.info(o)

    tick = tick or (game or set_game()) and game and game.tick or 0

    local obj = o or {}

    obj.created, obj.updated = tick, tick

    self.__index = self
    return setmetatable(obj, self)
end

function data:is_valid()
    Log.debug("data:is_valid")
    return self.created ~= nil and self.created >= 0 and self.updated ~= nil and self.updated >= self.created
end

function data.init(__storage) storage = __storage end

data.__index = data
return data
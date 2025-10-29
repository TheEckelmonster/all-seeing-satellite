local data = {}

-- Audit fields
data.valid = false
data.created = nil
data.updated = nil

function data:new(o)
    Log.debug("data:new")
    Log.info(o)

    local defaults = {
        valid = self.valid,
        created = game and game.tick or 0,
        updated = game and game.tick or 0,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function data:is_valid()
    Log.debug("data:is_valid")
    return self.created ~= nil and self.created >= 0 and self.updated ~= nil and self.updated >= self.created
end

data.__index = data
return data
local setmetatable = setmetatable

local simple_queue = {}

simple_queue.first = 1
simple_queue.last = 1
-- simple_queue.q = {}

function simple_queue:new(o)

    local obj = o or {}

    obj.first = obj.first or self.first or 1
    obj.last = obj.last or self.last or 1
    obj.q = obj.q or {}

    self.__index = self
    return setmetatable(obj, self)
end

simple_queue.__index = simple_queue

return simple_queue
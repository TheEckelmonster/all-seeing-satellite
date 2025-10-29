local Data = require("scripts.data.data")

local chunk_to_chart_data = {}

chunk_to_chart_data.area = {}

chunk_to_chart_data.center = { x = 0, y = 0, }

chunk_to_chart_data.complete = false
chunk_to_chart_data.id = -1
chunk_to_chart_data.parent_id = -1
chunk_to_chart_data.player_index = -1

chunk_to_chart_data.pos = { x = 0, y = 0, }

chunk_to_chart_data.queue = { i = 0, j = 0, }

chunk_to_chart_data.radius = 0
chunk_to_chart_data.surface = nil

chunk_to_chart_data.stack = { i = 0, j = 0, }

chunk_to_chart_data.started = false

function chunk_to_chart_data:new(o)
    Log.debug("chunk_to_chart_data:new")
    Log.info(o)

    local defaults = {
        area = self.area,
        center = { x = 0, y = 0, },
        complete = self.complete,
        id = self.id,
        parent_id = self.parent_id,
        player_index = self.player_index,
        pos = { x = 0, y = 0, },
        radius = self.radius,
        surface = self.surface,
        started = self.started,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(chunk_to_chart_data, Data)
chunk_to_chart_data.__index = chunk_to_chart_data
return chunk_to_chart_data
local setmetatable = setmetatable

local Data = require("scripts.data.data")

local chunk_to_chart_data = {}

chunk_to_chart_data.area = {}

chunk_to_chart_data.center = { x = 0, y = 0, }

chunk_to_chart_data.complete = false
chunk_to_chart_data.player_index = -1

chunk_to_chart_data.pos = { x = 0, y = 0, }

chunk_to_chart_data.radius = 0
chunk_to_chart_data.surface = nil

chunk_to_chart_data.started = false

function chunk_to_chart_data:new(o)
    -- Log.debug("chunk_to_chart_data:new")
    -- Log.info(o)

    local obj = o or {}

    -- obj.area = obj.area or self.area
    obj.area = obj.area or {}
    obj.center = obj.center or { x = 0, y = 0, }
    obj.complete = obj.complete or false
    obj.player_index = obj.player_index or -1
    obj.pos = obj.pos or { x = 0, y = 0, }
    obj.radius = obj.radius or 0
    obj.surface = obj.surface or nil
    obj.started = obj.started or false

    self.__index = self
    return setmetatable(obj, self)
end

setmetatable(chunk_to_chart_data, Data)
chunk_to_chart_data.__index = chunk_to_chart_data
return chunk_to_chart_data
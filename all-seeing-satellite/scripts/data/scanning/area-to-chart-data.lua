local Data = require("scripts.data.data")

local area_to_chart_data = {}

area_to_chart_data.area = {}

area_to_chart_data.center = { x = 0, y = 0, }

area_to_chart_data.complete = false
area_to_chart_data.id = -1
area_to_chart_data.player_index = -1

area_to_chart_data.pos = { x = 0, y = 0, }

area_to_chart_data.queue = { i = 0, j = 0, }

area_to_chart_data.radius = 0
area_to_chart_data.surface = nil

area_to_chart_data.stack = { i = 0, j = 0, }

area_to_chart_data.started = false


function area_to_chart_data:new(o)
    Log.debug("area_to_chart_data:new")
    Log.info(o)

    local defaults = {
        area = self.area,
        center = { x = 0, y = 0, },
        complete = self.complete,
        id = self.id,
        parent_id = self.parent_id,
        pos = { x = 0, y = 0, },
        queue = { i = 0, j = 0, },
        radius = self.radius,
        surface = self.surface,
        stack = { i = 0, j = 0, },
        started = self.started,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(area_to_chart_data, Data)
area_to_chart_data.__index = area_to_chart_data
return area_to_chart_data
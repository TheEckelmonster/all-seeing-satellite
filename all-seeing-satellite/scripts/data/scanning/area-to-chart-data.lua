local setmetatable = setmetatable

local Data = require("scripts.data.data")

local area_to_chart_data = {}

area_to_chart_data.area = {}

area_to_chart_data.center = { x = 0, y = 0, }

area_to_chart_data.complete = false
area_to_chart_data.id = -1
area_to_chart_data.player_index = -1

area_to_chart_data.pos = { x = 0, y = 0, }

area_to_chart_data.radius = 0
area_to_chart_data.surface = nil

area_to_chart_data.started = false


function area_to_chart_data:new(o)
    -- Log.debug("area_to_chart_data:new")
    -- Log.info(o)

    local obj = o or {}

    -- obj.area = obj.area or self.area
    obj.area = obj.area or {}
    obj.center = obj.center or { x = 0, y = 0, }
    obj.complete = obj.complete or false
    obj.pos = obj.pos or { x = 0, y = 0, }
    obj.radius = obj.radius or 0
    obj.surface = obj.surface or nil
    obj.started = obj.started or false

    self.__index = self
    return setmetatable(obj, self)
end

setmetatable(area_to_chart_data, Data)
area_to_chart_data.__index = area_to_chart_data
return area_to_chart_data
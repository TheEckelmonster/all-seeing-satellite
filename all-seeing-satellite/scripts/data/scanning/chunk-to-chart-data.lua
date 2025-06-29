local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local chunk_to_chart_data = Data:new()

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

function chunk_to_chart_data:new(obj)
  Log.debug("chunk_to_chart_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

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

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return chunk_to_chart_data
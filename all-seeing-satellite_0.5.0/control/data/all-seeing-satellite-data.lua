local Data = require("control.data.data")
local Log = require("libs.log.log")
local Version_Data = require("control.data.version-data")

local all_seeing_satellite_data = Data:new()

all_seeing_satellite_data.do_nth_tick = true

all_seeing_satellite_data.satellite_meta_data = {}

all_seeing_satellite_data.staged_areas_to_chart = {}
all_seeing_satellite_data.staged_chunks_to_chart = {}

all_seeing_satellite_data.version_data = Version_Data:new()

function all_seeing_satellite_data:new(obj)
  Log.debug("all_seeing_satellite_data:new")
  Log.info(obj)

  obj = obj and Data:new(obj) or Data:new()

  local defaults = {
    satellite_meta_data = self.satellite_meta_data,
    staged_areas_to_chart = self.staged_areas_to_chart,
    staged_chunks_to_chart = self.staged_chunks_to_chart,
    version_data = self.version_data,
    warn_technology_not_available_yet = self.warn_technology_not_available_yet,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return all_seeing_satellite_data
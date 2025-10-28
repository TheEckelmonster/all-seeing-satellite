local Data = require("scripts.data.data")
local Version_Data = require("scripts.data.version-data")

local all_seeing_satellite_data = {}

all_seeing_satellite_data.do_nth_tick = true

all_seeing_satellite_data.satellite_meta_data = {}

all_seeing_satellite_data.staged_areas_to_chart = {}
all_seeing_satellite_data.staged_chunks_to_chart = {}

all_seeing_satellite_data.version_data = Version_Data:new()

function all_seeing_satellite_data:new(o)
    Log.debug("all_seeing_satellite_data:new")
    Log.info(o)

    local defaults = {
        satellite_meta_data = {},
        staged_areas_to_chart = {},
        staged_chunks_to_chart = {},
        version_data = self.version_data,
        warn_technology_not_available_yet = self.warn_technology_not_available_yet,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

setmetatable(all_seeing_satellite_data, Data)
all_seeing_satellite_data.__index = all_seeing_satellite_data
return all_seeing_satellite_data
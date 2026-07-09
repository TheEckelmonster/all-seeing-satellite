local setmetatable = setmetatable

local Data = Data or require("__TheEckelmonster-core-library__.libs.data.data")
local new_Data = Data.new

local all_seeing_satellite_data = {}

all_seeing_satellite_data.do_nth_tick = true

all_seeing_satellite_data.satellite_meta_data = {}

all_seeing_satellite_data.staged_areas_to_chart = {}
all_seeing_satellite_data.staged_chunks_to_chart = {}

all_seeing_satellite_data.warn_technology_not_available_yet = nil


function all_seeing_satellite_data:new(o)
    -- Log.debug("all_seeing_satellite_data:new")
    -- Log.info(o)

    local obj = o or {}

    obj.do_nth_tick = obj.do_nth_tick or true
    obj.staged_areas_to_chart = obj.staged_areas_to_chart or {}
    obj.staged_chunks_to_chart = obj.staged_chunks_to_chart or {}
    obj.warn_technology_not_available_yet = obj.warn_technology_not_available_yet or nil

    self.__index = self
    return setmetatable(new_Data(Data, obj), self)
end

setmetatable(all_seeing_satellite_data, Data)
all_seeing_satellite_data.__index = all_seeing_satellite_data
return all_seeing_satellite_data
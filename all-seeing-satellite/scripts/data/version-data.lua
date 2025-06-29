local Data = require("scripts.data.data")
local Bug_Fix_Data = require("scripts.data.versions.bug-fix-data")
local Major_Data = require("scripts.data.versions.major-data")
local Minor_Data = require("scripts.data.versions.minor-data")
local Log = require("libs.log.log")

local version_data = Data:new()

version_data.major = Major_Data:new()
version_data.major.value = 0
version_data.major.valid = true
version_data.minor = Minor_Data:new()
version_data.minor.value = 6
version_data.minor.valid = true
version_data.bug_fix = Bug_Fix_Data:new()
version_data.bug_fix.value = 0
version_data.bug_fix.valid = true

version_data.string_val = version_data.major.value .. "." .. version_data.minor.value .. "." .. version_data.bug_fix.value

function version_data:new(obj)
  Log.debug("version_data:new")
  Log.info(obj)

  obj = Data:new(obj) or Data:new()

  local defaults = {
    created = self.created,
    updated = self.updated,
    valid = self.valid,
    major = self.major,
    minor = self.minor,
    bug_fix = self.bug_fix,
    string_val = self.string_val,
  }

  for k, v in pairs(defaults) do
    if (obj[k] == nil) then obj[k] = v end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function version_data:get_major()
  return self.major
end

function version_data:set_major(obj)
  self.major = obj
end

function version_data:get_minor()
  return self.minor
end

function version_data:set_minor(obj)
  self.minor = obj
end

function version_data:get_bug_fix()
  return self.bug_fix
end

function version_data:set_bug_fix(obj)
  self.bug_fix = obj
end

function version_data:to_string()
  Log.debug("version_data:to_string")
  Log.info(self.string_val)
  return self.string_val
end

return version_data
-- If already defined, return
if _storage_utils and _storage_utils.all_seeing_satellite then
  return _storage_utils
end

local Log = require("libs.log.log")

local storage_utils = {}

storage_utils.all_seeing_satellite = true

local _storage_utils = storage_utils

return storage_utils
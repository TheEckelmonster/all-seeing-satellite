local script = script

--[[
    Globals
]]

Util = require("__core__.lualib.util")
Deepcopy = Util.table.deepcopy

-- Constants
require("scripts.constants.strings")

Log = require("__TheEckelmonster-core-library__.libs.log.log")
Event_Handler = require("__TheEckelmonster-core-library__.scripts.event-handler")
Settings_Map = nil

---

--[[ Data types and metatables ]]

-- versions
local Bug_Fix_Data = require("__TheEckelmonster-core-library__.libs.data.versions.bug-fix-data")
local Major_Data = require("__TheEckelmonster-core-library__.libs.data.versions.major-data")
local Minor_Data = require("__TheEckelmonster-core-library__.libs.data.versions.minor-data")

script.register_metatable("Bug_Fix_Data", Bug_Fix_Data)
script.register_metatable("Major_Data", Major_Data)
script.register_metatable("Minor_Data", Minor_Data)

Simple_Queue = require("scripts.data.simple-queue")

script.register_metatable("Simple_Queue", Simple_Queue)

---

require("scripts.events")
require("scripts.commands")
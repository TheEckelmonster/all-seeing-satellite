local io = _ENV.io
local os = _ENV.os
local package = _ENV.package

local print = _ENV.print
local tostring = _ENV.tostring
local type = _ENV.type

-- ============================================================================
-- REQUIREMENT LINKS & DEPENDENCIES:
-- Lua 5.2 Binaries: https://luabinaries.sourceforge.net/download.html
-- 7-Zip Executable: https://7-zip.org
-- ============================================================================

-- Configuration variables
local factorio_version = "2.0"
local is_windows = package.config:sub(1,1) == "\\"

-- 1. EXTRACT CONTAINER DIRECTORY
local raw_path = (arg and (is_windows and arg[1] or arg[0])) or ... or ""
local script_dir = raw_path:match("(.*[/\\])") or ""

-- If running on Linux/Unix locally and path is relative, we can query PWD
if (script_dir == "" or script_dir == "." or script_dir == ".\\" or script_dir == "./") then
    local pipe = io.popen(package.config:sub(1,1) == "\\" and "cd" or "pwd")
    if pipe then
        script_dir = pipe:read("*l") .. package.config:sub(1,1)
        pipe:close()
    end
end

-- Scan for command line arguments
local cli_args = {...}

local do_backup = false
local do_auto_launch = false
local do_experimental = false
local do_tests = false

local flags = {
    ["-b"]             = function () do_backup = true end,
    ["--backup"]       = function () do_backup = true end,
    ["-al"]            = function () do_auto_launch = true end,
    ["--auto-launch"]  = function () do_auto_launch = true end,
    ["-e"]             = function () do_experimental = true end,
    ["--experimental"] = function () do_experimental = true end,
    ["-t"]             = function () do_tests = true end,
    ["--test"]         = function () do_tests = true end,
}

for i = 1, #cli_args do
    local argument = cli_args[i]
    if (type(flags[argument]) == "function") then flags[argument]() end
end

-- Look for the first info.json found inside any immediate subdirectory.
local function locate_manifest(base_dir)
    -- This assumes the parent directory name dictates the workspace boundaries.
    local clean_dir = base_dir:gsub("[/\\]$", "")
    local deduced_mod = clean_dir:match("([^/\\]+)$")

    if (deduced_mod) then
        return base_dir .. deduced_mod .. "/info.json", deduced_mod
    end
    return nil, nil
end
local presumed_manifest, deduced_mod = locate_manifest(script_dir)

-- 2. ROBUST MANIFEST EXTRACTOR
local function get_json_value(json_path, key, is_numeric)
    if not json_path then return nil end
    local file = io.open(json_path, "r")
    if not file then return nil end

    local content = file:read("*a")
    file:close()

    if (is_numeric) then
        -- Captures unquoted integers, decimals, or booleans (e.g., true, 1.0)
        return content:match('"' .. key .. '"%s*:%s*([%w%.]+)')
    else
        -- Captures traditional quoted text strings
        return content:match('"' .. key .. '"%s*:%s*"([^"]+)"')
    end
end

-- Dynamically map keys straight out of the Factorio manifest layout
local mod             = get_json_value(presumed_manifest, "name") or deduced_mod or "unknown-mod"
local version         = get_json_value(presumed_manifest, "version") or "0.0.1"
local factorio_target = get_json_value(presumed_manifest, "factorio_version") or factorio_version
local custom_dest     = get_json_value(presumed_manifest, "custom_output_directory")
local use_custom_dest = do_experimental and tostring(do_experimental)
                    or  get_json_value(presumed_manifest, "use_custom_output_directory", true)

local launch_toggle   = do_auto_launch and tostring(do_auto_launch)
                    or  get_json_value(presumed_manifest, "launch_game_after_build", true)

print("====================================================================")
print("FACTORIO BUILD ENGINE INITIALIZED")
print("Target Mod:       " .. mod)
print("Mod Version:      " .. version)
print("Factorio Version: " .. factorio_target)
print("Experimental:     " .. tostring(do_experimental))
print("Make Backup:      " .. tostring(do_backup))
print("Launch Toggle:    " .. tostring(launch_toggle))
print("====================================================================")

-- 3. ENVIRONMENT ROUTING
local home_dir   = is_windows and os.getenv("APPDATA") or os.getenv("HOME")
local seven_zip_path = ""
local destination = ""
local dev_path = ""

if (is_windows) then
    seven_zip_path = "D:/7-Zip/7z.exe"
    dev_path = "D:/mods/_dev/Factorio/" .. mod
else
    seven_zip_path = "7z"
    dev_path = home_dir .. "/mods/_dev/Factorio/" .. mod
end

-- if (custom_dest and custom_dest ~= "" and use_custom_dest) then
if (type(custom_dest) == "string" and custom_dest ~= "" and use_custom_dest == "true") then
    destination = custom_dest
    -- Enforce trailing path separators for user safety
    if (not destination:match("[/\\]$")) then
        destination = destination .. (is_windows and "\\" or "/")
    end
    print("Output Route:     [OVERRIDE] -> " .. destination)
else
    if (is_windows) then
        destination = home_dir .. "/Factorio/mods/"
    else
        local mac_path = home_dir .. "/Library/Application Support/factorio/mods/"
        local f = io.open(mac_path, "r")
        if (f) then
            destination = mac_path
            f:close()
        else
            destination = home_dir .. "/.factorio/mods/"
        end
    end
    print("Output Route:     [DEFAULT]  -> " .. destination)
end
print("====================================================================")

-- Package composition
local versioned_mod = mod .. "_" .. version
local zip = ".zip"
local dev_full = dev_path .. "/" .. mod
local dev_full_versioned = dev_full .. "_" .. version

if (do_tests) then
    print("\nExecuting LuaUnit Test Suite...")

    -- Run master discovery
    local success, status, code = os.execute("lua52 tests/run_all_tests.lua " .. script_dir .. mod)
    -- If tests fail, abort the deployment chain
    if (not success or code ~= 0) then
        print("> BUILD PIPELINE ABORTED: One or more unit tests failed.")
        os.exit(code or 1)
    end

    print("All test suites passed successfully!")
end

-- if (true) then return end

local function delete_file(path)
    local success, err = os.remove(path)
    if (success) then
        print("Successfully deleted: " .. path)
    else
        print("Notice: Could not delete " .. path .. " (" .. tostring(err) .. ")")
    end
end

local function copy_file(source, dest)
    local infile, err = io.open(source, "rb")
    if (not infile) then 
        print("Error opening source file: " .. tostring(err))
        return false 
    end

    local outfile, out_err = io.open(dest, "wb")
    if (not outfile) then 
        print("Error creating destination file: " .. tostring(out_err))
        infile:close()
        return false
    end

    local data = infile:read("*a")
    outfile:write(data)

    infile:close()
    outfile:close()
    return true
end

local function run_7z(args)
    local cmd
    if (is_windows) then
        cmd = '""' .. seven_zip_path .. '" ' .. args .. '"'
    else
        cmd = seven_zip_path .. " " .. args
    end
    os.execute(cmd)
end

-- 1. Delete the old .zip file from the dev directory natively via Lua
local dev_zip = dev_full_versioned .. zip
print("Deleting " .. dev_zip)
delete_file(dev_zip)

-- 2. Zip the contents of the mod folder
local source_folder = dev_full
print("> Zipping " .. source_folder .. "/ to " .. dev_zip)
run_7z('a -tzip "' .. dev_zip .. '" "' .. source_folder .. '"')

-- 3. Delete the old .zip file from the Factorio/mods folder natively via Lua
local dest_zip = destination .. versioned_mod .. zip
print("> Deleting " .. dest_zip)
delete_file(dest_zip)

-- 4. Copy the .zip from the dev folder to the Factorio/mods folder using Lua I/O
print("> Copying " .. dev_zip .. " to " .. destination)
local full_dest_path = destination .. versioned_mod .. zip
local success = copy_file(dev_zip, full_dest_path)
if success then
    print("Copy operation completed successfully.")

    if (do_backup) then
        -- Generate an isolated backup folder in your parent directory
        local backup_dir = script_dir .. "backups"
        -- Use standard OS mkdir commands to make sure the target directory exists
        os.execute(is_windows and ('mkdir "' .. backup_dir .. '" 2>nul') or ('mkdir -p "' .. backup_dir .. '"'))

        -- Build filename (YearMonthDay_HourMinuteSecond)
        local timestamp = os.date("%Y-%m-%d_%H%M%S")
        local backup_file_name = backup_dir .. (is_windows and "\\" or "/") .. versioned_mod .. "_" .. timestamp .. zip

        print("> Creating historical backup archive...")
        local backup_success = copy_file(dev_zip, backup_file_name)
        if backup_success then
            print("Backup stored -> " .. backup_file_name)
        else
            print("Warning: Backup archiving routine failed.")
        end
    end

    local default_exe_path =    get_json_value(presumed_manifest, "default_exe_path")
    local custom_exe_path =     get_json_value(presumed_manifest, "custom_exe_path")
    local use_custom_exe_path = do_experimental and tostring(do_experimental)
                            or  get_json_value(presumed_manifest, "use_custom_exe_path", true)

    local exe_path = type(custom_exe_path) == "string" and custom_exe_path or nil

    if ((not exe_path or use_custom_exe_path ~= "true") and type(default_exe_path) == "string") then
        exe_path = default_exe_path
    end

    if (launch_toggle == "true" and exe_path and exe_path ~= "") then
        print("> Launching target Factorio client...")
        os.execute('start "" "' .. exe_path .. '"')
    end
else
    print("Copy operation failed.")
end
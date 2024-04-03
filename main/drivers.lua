local constants = require("main.constants")

local M = {}

---@class Driver
---@field device string
---@field platform string
---@field dead_zone float
---@field maps Map[]

---@class Map
---@field index integer
---@field input_type integer
---@field hat_mask integer
---@field modifiers integer[]

---@param driver Driver
---@return string
function M.driver_to_string(driver)
    local s = "driver\n{\n"
    s = s .. ('\tdevice: "%s"\n'):format(driver.device)
    s = s .. ('\tplatform: "%s"\n'):format(driver.platform)
    s = s .. ('\tdead_zone: %.3f\n'):format(driver.dead_zone)
    for trigger_id = 0, #driver.maps do
        local map = driver.maps[trigger_id]
        if not table_empty(map) then
            local trigger_name = gdc.get_trigger_name(trigger_id)
            local input_type = gdc.get_input_type_name(map.input_type)
            s = s .. ("\tmap { input: %s type: %s index: %d "):format(trigger_name, input_type, map.index)

            if map.hat_mask then
                s = s .. ("hat_mask: %d "):format(map.hat_mask)
            end

            for _, modifier in ipairs(map.modifiers) do
                s = s .. ("mod { mod: %s } "):format(gdc.get_modifier_name(modifier))
            end

            s = s .. "}\n"
        end
    end

    s = s .. "}"

    return s
end

---@param s string
---@param name string
---@return string?
local function match_string(s, name)
    return s:match(name .. [[:%s*"([^"]+)"]])
end

---@param s string
---@param name string
---@return number?
local function match_number(s, name)
    return tonumber(s:match(name .. ":%s*([%d%.]+)"))
end

---@param s string
---@param name string
---@return string?
local function match_enum(s, name)
    return s:match(name .. ":%s*([%u_]+)")
end

local function parse_map_string(map_string)
    local input_name = assert(match_enum(map_string, "input"), "missing input name for a gamepad")
    if input_name == "GAMEPAD_RAW" then
        return
    end

    local input_type = match_enum(map_string, "type")
    local index = match_number(map_string, "index")
    local hat_mask = match_number(map_string, "hat_mask")

    local map = {
        type = input_type,
        index = index,
        hat_mask = hat_mask,
        modifiers = {}
    }

    for mod in map_string:gmatch("mod%s*{[^}]+}") do
        local mod = match_enum(mod, "mod")
        local modifier_id = constants.modifier_id(mod)
        if modifier_id then
            table.insert(map.modifiers, modifier_id)
        else
            error("Unknown modifier " .. mod)
        end
    end

    return constants.trigger_id(input_name), map
end

---@param gamepads string
---@return Driver[]
function M.parse_gamepads(gamepads)
    local drivers = {}

    local current_driver = { maps = {} }
    for line in gamepads:gmatch("[^\n]+") do
        local device = match_string(line, "device")
        if device then
            current_driver.device = device
        end

        local platform = match_string(line, "platform")
        if platform then
            current_driver.platform = platform
        end

        local dead_zone = match_number(line, "dead_zone")
        if dead_zone then
            current_driver.dead_zone = dead_zone
        end

        local map_string = line:match("map%s*{(.+)}")
        if map_string then
            local id, map = parse_map_string(map_string)
            if id then
                current_driver.maps[id] = map
            end
        end

        if line:match("^}") then
            table.insert(drivers, current_driver)
            current_driver = { maps = {} }
        end
    end

    return drivers
end

-- GitHub says to not use the direct URL, but use it we shall (until they inevitably change the format)
local GAMEPADS_URL =
"https://raw.githubusercontent.com/defold/defold/dev/engine/engine/content/builtins/input/default.gamepads"

---@param callback fun(gamepads: Driver[])
function M.fetch_latest_gamepads(callback)
    http.request(GAMEPADS_URL, "GET", function(_, _, response)
        local gamepads = M.parse_gamepads(response.response)
        callback(gamepads)
    end)
end

return M

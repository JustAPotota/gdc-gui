local protoc = require("pb.protoc")

local M = {}

local gamepads

local function init()
    protoc:parsefile("/input_ddf.proto")
    local gamepadsc = sys.load_resource("/builtins/input/default.gamepadsc")
    
end

function M.get_gamepads()
    if gamepads then
        return gamepads
    end

    init()
end

return M

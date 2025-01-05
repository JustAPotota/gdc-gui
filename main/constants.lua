local M = {}

M.MAX_TRIGGER = 24

M.TRIGGERS = {}
for i = 0, M.MAX_TRIGGER do
    M.TRIGGERS[i] = gdc.get_trigger_name(i)
end

M.MODIFIERS = {
    [gdc.MODIFIER_NEGATE] = gdc.get_modifier_name(gdc.MODIFIER_NEGATE),
    [gdc.MODIFIER_SCALE] = gdc.get_modifier_name(gdc.MODIFIER_SCALE),
    [gdc.MODIFIER_CLAMP] = gdc.get_modifier_name(gdc.MODIFIER_CLAMP),
}

M.INPUT_TYPES = {
    [gdc.INPUT_TYPE_AXIS] = gdc.get_input_type_name(gdc.INPUT_TYPE_AXIS),
    [gdc.INPUT_TYPE_BUTTON] = gdc.get_input_type_name(gdc.INPUT_TYPE_BUTTON),
    [gdc.INPUT_TYPE_HAT] = gdc.get_input_type_name(gdc.INPUT_TYPE_HAT),
}

---@param name string
---@return integer?
function M.modifier_id(name)
    for id = 0, 2 do
        if name == M.MODIFIERS[id] then
            return id
        end
    end
end

---@param name string
---@return integer?
function M.trigger_id(name)
    for id = 0, M.MAX_TRIGGER do
        if name == M.TRIGGERS[id] then
            return id
        end
    end
end

---@param name string
---@return integer?
function M.input_type_id(name)
    for id = 0, 2 do
        if name == M.INPUT_TYPES[id] then
            return id
        end
    end
end

return M

return function()
    local baseline_packet = gdc.get_gamepad_packet(self.gamepad)
    local packet = gdc.get_gamepad_packet(self.gamepad)
    local input_type, index, value, delta = gdc.compare_packets()
end
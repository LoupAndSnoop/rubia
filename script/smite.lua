--For smiting naughty naughty modders
local WAIT_TO_SMITE = 40 * 3600
local CHECK_FREQUENCY = 10 * 3600

rubia.timing_manager.register("clear-rubia", function()
    if storage.rubia_surface then
        storage.rubia_surface.clear(true)
    end
end)

local function naughty_check()
    if not storage.rubia_surface then return end
    local naughty_mod = false
    for _, mod in pairs(rubia.NAUGHTY_MODS) do
        if script.active_mods[mod] then
            naughty_mod = true
        end
    end

    if naughty_mod then
        rubia.timing_manager.wait_then_do(WAIT_TO_SMITE, "clear-rubia", {})
    end
end

local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_nth_tick(CHECK_FREQUENCY, "naughty-mod-check", naughty_check)
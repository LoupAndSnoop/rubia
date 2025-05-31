--This file provides warnings related to version changes.

local function trashsteroid_health_warning(config_change)
    local rubia_change = config_change.mod_changes["rubia"]
    if rubia_change and rubia_change.old_version <= "0.69.45" then
        rubia.timing_manager.wait_then_do(300, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-trashsteroid-health-scaling"},
            {color = {r=1,g=0.2,b=0.2,a=1}}}) 
    end
end


local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_configuration_changed(
    "version-change-warning-trashsteroid-health-scaling",
    trashsteroid_health_warning)
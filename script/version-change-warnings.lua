--This file provides warnings related to version changes.

local function trashsteroid_health_warning(config_change)
    local rubia_change = config_change.mod_changes["rubia"]
    if rubia_change and rubia.flib.is_newer_version(rubia_change.old_version, "0.69.46")
        and storage.rubia_surface then 
        rubia.timing_manager.wait_then_do(300, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-trashsteroid-health-scaling"},
            rubia.WARNING_PRINT_SETTINGS}) 
    end
end

local function craptonite_wall_update(config_change)
    local rubia_change = config_change.mod_changes["rubia"]
    if rubia_change and rubia.flib.is_newer_version(rubia_change.old_version, "0.69.56")
        and storage.rubia_surface and game.forces["player"]
        and game.forces["player"].technologies["rubia-project-trashdragon"].researched then 
        rubia.timing_manager.wait_then_do(302, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-craptonite-wall"},
            rubia.GREEN_PRINT_SETTINGS}) 
    end
end



local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_configuration_changed(
    "version-change-warning-trashsteroid-health-scaling",
    trashsteroid_health_warning)
event_lib.on_configuration_changed(
    "version-change-warning-craptonite-wall-update",
    craptonite_wall_update)
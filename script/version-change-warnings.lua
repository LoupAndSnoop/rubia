--This file provides warnings related to breaking version changes.

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

local function craptonite_wall_recipe_update(config_change)
    local rubia_change = config_change.mod_changes["rubia"]
    if rubia_change and rubia.flib.is_newer_version(rubia_change.old_version, "0.69.74")
        and storage.rubia_surface and game.forces["player"]
        and game.forces["player"].technologies["craptonite-wall"].researched then 
        rubia.timing_manager.wait_then_do(308, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-craptonite-wall-recipe"},
            rubia.WARNING_PRINT_SETTINGS}) 
    end
end

local function tangible_projectile_warning()
    local tangible_projectiles = script.active_mods["distant-misfires"]
        --or (script.active_mods["Krastorio2-spaced-out"] and settings.startup["kr-realistic-weapons"].value)
    if tangible_projectiles and not storage.warning_issued_tangible_projectiles then
        storage.warning_issued_tangible_projectiles = true
        rubia.timing_manager.wait_then_do(320, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-tangible-projectile-mod-warning"},
            rubia.WARNING_PRINT_SETTINGS}) 
    end
end


local function bz_mod_silo_warning(config_change)
    local bzmods = script.active_mods["bztin"] or script.active_mods["bzlead"]
    local rubia_change = config_change.mod_changes["rubia"]
    if bzmods 
        and rubia_change and (rubia_change.old_version == "0.69.83")
        and not storage.warning_issued_bzsilo then
        storage.warning_issued_bzsilo = true
        rubia.timing_manager.wait_then_do(310, "delayed-text-print",
            {"game", {"version-change-warnings.rubia-bzmod-silo-recipe-change"},
            rubia.WARNING_PRINT_SETTINGS}) 
    end
end


local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_configuration_changed(
    "version-change-warning-trashsteroid-health-scaling", trashsteroid_health_warning)
event_lib.on_configuration_changed(
    "version-change-warning-craptonite-wall-update", craptonite_wall_update)
event_lib.on_configuration_changed(
    "version-change-warning-craptonite-wall-recipe-update", craptonite_wall_recipe_update)
event_lib.on_configuration_changed(
    "version-change-warning-bz-mod-recipe-update", bz_mod_silo_warning)

event_lib.on_init("mod-warning-tangible-projectiles", tangible_projectile_warning)
event_lib.on_configuration_changed("mod-warning-tangible-projectiles", tangible_projectile_warning)
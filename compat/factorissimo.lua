--Factorissimo
if not (script.active_mods["Factorissimo2"] or script.active_mods["factorissimo-2-notnotmelon"]) then return end
--if not game.surfaces["rubia-factory-floor"] 

local function find_all_factories()
    if not storage.rubia_surface then return {} end
    
    local factories = {}
    local factory_names = {"factory-1", "factory-2", "factory-3"}
        --"factory-power-input-8", "factory-power-input-12", "factory-power-input-16",
        --"factory-requester-chest-factory-1", "factory-requester-chest-factory-2", "factory-requester-chest-factory-3"}
    for _, name in pairs(factory_names) do
        factories = rubia_lib.array_concat{factories, storage.rubia_surface.find_entities_filtered{name = name}}
    end

    return factories
end

local function destroy_all_factorissimo_factories()
    local factories = find_all_factories()
    for _, entry in pairs(factories) do
        if entry and entry.valid then entry.die() end
    end
end


rubia.timing_manager.register("destroy-factorissimo-factories", destroy_all_factorissimo_factories)

local function start_factorissimo_countdowns()
    --Only do this once.
    if storage.rubia_factorissimo_check_done then return end
    storage.rubia_factorissimo_check_done = true

    --if game.surfaces["rubia-factory-floor"] then
    --    game.surfaces["rubia-factory-floor"].global_effect = {speed = -100}
    --end

    local factories = find_all_factories()
    if not factories or table_size(factories) == 0 then return end --No factories

    local FINAL_COUNTDOWN_MINUTES = 80
    local function warn_at_x_minutes(minutes)
        rubia.timing_manager.wait_then_do(minutes * 3600, "delayed-text-print", 
            {"game", {"version-change-warnings.rubia-factorissimo-destruction_warning", FINAL_COUNTDOWN_MINUTES - minutes},
            rubia.WARNING_PRINT_SETTINGS})
    end
    for _, i in pairs({1,10,20,30,40}) do
        warn_at_x_minutes(FINAL_COUNTDOWN_MINUTES - i)
    end

    rubia.timing_manager.wait_then_do(FINAL_COUNTDOWN_MINUTES * 3600,"destroy-factorissimo-factories", {})
end


local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_configuration_changed("factorissimo-check", start_factorissimo_countdowns)


--[[
local function blow_away_factorissimo_factories()
    local nauvis = game.surfaces["nauvis"]
    if not nauvis then destroy_all_factorissimo_factories() end

    local drop_pod = nauvis.create_entity{
        name = "cargo-pod-container",
        position = {0,0},
        force = "player",
    }
    if not drop_pod then destroy_all_factorissimo_factories() end

    local inventory = drop_pod.get_inventory(defines.inventory.chest)
    if not inventory then destroy_all_factorissimo_factories() end

    local factories = find_all_factories()
    for _, entry in pairs(factories) do
        if entry and entry.valid then entry.mine{inventory = inventory, ignore_minable = true} end
    end

    game.print({"version-change-warnings.rubia-factorissimo-destruction-position",
        drop_pod.position.x,drop_pod.position.y, drop_pod.surface.name },
        rubia.WARNING_PRINT_SETTINGS)

    --In case we missed something
    destroy_all_factorissimo_factories()
end
]]

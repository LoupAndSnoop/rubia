if not mods["machine-upgrades"] then return end

--Machine-upgrades specific technologies
local mupgrades = require("__machine-upgrades__.lib.technology-maker")
local upgrade_data = {}

--Make lists of entities to be able to make proper techs.
local recyclers = mupgrades.find_machines_with_crafting_category("recycling")
local crushers = mupgrades.find_machines_with_crafting_category("crushing")


table.insert(upgrade_data, {
        handler = "rubia-biochamber-productivity-bonus",
        technology_name = "rubia-biochamber-productivity-bonus",
        modifier_icon = {icon="__space-age__/graphics/icons/biochamber.png"},
        entity_names = {"biochamber"},
        module_effects = {productivity = 0.1},
        effect_name = {"entity-name.biochamber"},
    })

if mods["secretas"] and table_size(recyclers) > 0 then
    table.insert(upgrade_data, {
        handler = "rubia-secretas-recycler-speed-bonus",
        technology_name = "rubia-craptonite-codpiece",
        modifier_icon = {icon="__quality__/graphics/icons/recycler.png"},
        entity_names = recyclers,
        module_effects = {speed = 0.2},
        effect_name = {"entity-name.recycler"},
    })
end


if mods["planet-muluna"] and table_size(crushers) > 0 then 
    local hidden_crushers = {}
    local max_qualities = math.max(table_size(data.raw.quality), 500)
    for i = 1, max_qualities, 1 do
        table.insert(hidden_crushers, "cerys-fulgoran-crusher-quality-" .. i)
    end

    table.insert(upgrade_data, {
        handler = "rubia-muluna-crushers",
        technology_name = "rubia-craptonite-belt-buckle",
        modifier_icon = {icon="__space-age__/graphics/icons/crusher.png"},
        entity_names = crushers,
        module_effects = {consumption = -0.2, speed = 0.2},
        effect_name = {"entity-name.crusher"},
        hidden_entity_names = hidden_crushers,
    })
end

if mods["janus"] then
    local time_distorter = data.raw["assembling-machine"]["janus-time-distorter"]
    time_distorter.allowed_effects = time_distorter.allowed_effects or {}
    table.insert(time_distorter.allowed_effects, "speed")
    table.insert(upgrade_data, {
        handler = "rubia-janus-time-distorter",
        technology_name = "rubia-craptonite-mask",
        modifier_icon = {icon=time_distorter.icon, icon_size = time_distorter.icon_size},
        entity_names = {"janus-time-distorter"},
        module_effects = {speed = 0.3},
        effect_name = {"entity-name.janus-time-distorter"},
    })
end


if (mods["lignumis"] or mods["wood-universe-modpack"]) then
    local lumber_mill = data.raw["assembling-machine"]["lumber-mill"]
    local lumber_mill_list = {"lumber-mill"}
    if mods["Age-of-Production"] then table.insert(lumber_mill_list, "aop-lumber-mill") end
    table.insert(upgrade_data, {
        handler = "rubia-lignumis-mill-productivity",
        technology_name = "rubia-craptonite-wood-charm",
        modifier_icon = {icon=lumber_mill.icon, icon_size = lumber_mill.icon_size},
        entity_names = lumber_mill_list,
        module_effects = {productivity = 0.25, consumption = -0.25},
        effect_name = {"entity-name.lumber-mill"},
    })
end

if mods["Paracelsin"] then
    local electrochemical_plant = data.raw["assembling-machine"]["electrochemical-plant"]
    table.insert(upgrade_data, {
        handler = "rubia-paracelsin-electrochem-bonus",
        technology_name = "rubia-craptonite-grillz",
        modifier_icon = {icon=electrochemical_plant.icon, icon_size = electrochemical_plant.icon_size},
        entity_names = {"electrochemical-plant"},
        module_effects = {productivity = 0.15, consumption = -0.20},
        effect_name = {"entity-name.electrochemical-plant"},
    })
end

if mods["Factorio-Tiberium"] then
    local reprocessor = data.raw["furnace"]["tiberium-reprocessor"]
    table.insert(upgrade_data, {
        handler = "rubia-tiberium-reprocessors",
        technology_name = "rubia-craptonite-tiber-implant",
        modifier_icon = {icon=reprocessor.icon, icon_size = reprocessor.icon_size},
        entity_names = {"tiberium-reprocessor"},
        module_effects = {productivity = 0.20},
        effect_name = {"entity-name.tiberium-reprocessor"},
    })
end


if table_size(upgrade_data) > 0 then
    mupgrades.handle_modifier_data(upgrade_data)
end

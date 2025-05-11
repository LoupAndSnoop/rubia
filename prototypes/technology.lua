require("util")
require("lib.lib")

--Cargo drop restriction
local cargo_drops_base = PlanetsLib.cargo_drops_technology_base(
    "rubia", "__rubia-assets__/graphics/planet/rubia-discovery.png", 256) --TODO Icon
    --TODO: Custom whitelist, because construction bots are allowed
--cargo_drops_base.name = "operation-iron-man"
--Internal tech name must remain planetslib-rubia-cargo-drops
cargo_drops_base.icons = nil
cargo_drops_base.icon = "__rubia-assets__/graphics/technology/operation-iron-man.png"
cargo_drops_base.icon_size = 256
cargo_drops_base.localised_name = {"technology-name.operation-iron-man"}
cargo_drops_base.localised_description = {"technology-description.operation-iron-man"}
cargo_drops_base.effects[1].effect_description = {"modifier-description.operation-iron-man-effect"}

data:extend({rubia_lib.merge(cargo_drops_base, {
    prerequisites = { "rubia-project-trashdragon" }, -- TODO
    unit = {
        count = 2000,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "military-science-pack", 1 },
            { "biorecycling-science-pack", 1 },
        },
        time = 60,
    },
    allows_productivity = true,
})})


--Make an array of recipe unlock effects, to unlock several recipes at once.
--Enter an array of strings of recipe neames.
local function unlock_recipes(recipe_names)
    local unlocks = {}
    for _, name in pairs(recipe_names) do
        table.insert(unlocks, {type = "unlock-recipe", recipe = name})
    end
end


data:extend({
--#region Core Rubia Progression
    {
        type = "technology",
        name = "planet-discovery-rubia",
        icons = util.technology_icon_constant_planet("__rubia-assets__/graphics/planet/rubia.png"),
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "rubia",
                use_icon_overlay_constant = true
            },
        },
        prerequisites = { "space-platform-thruster", "energy-shield-equipment", 
            "electric-energy-distribution-1", "railway"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "space-science-pack",           1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "rubia-progression-stage1",
        icon = "__rubia-assets__/graphics/technology/biorecycling.png",--"__rubia-assets__/graphics/icons/science/torus_clear_brown.png",
        icon_size = 256,
        essential = false,
        effects =
        {
            {type = "unlock-recipe", recipe = "biorecycling-plant"},
            {type = "unlock-recipe", recipe = "crapapult"},
            --{type = "unlock-recipe", recipe = "alt-gun-turret"},
            --{type = "unlock-recipe", recipe = "rubia-sniper-turret"}, -- TODO Shift?
            {type = "unlock-recipe", recipe = "rubia-wind-turbine"},

            {type = "unlock-recipe", recipe = "rubia-bacteria-A"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-ferric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-firearm-magazine"},
            {type = "unlock-recipe", recipe = "makeshift-biorecycling-science-pack"},
        },
        prerequisites = { "planet-discovery-rubia"},
        research_trigger = {type = "mine-entity", entity="rubia-spidertron-remnants"},  --"rubia-junk-pile"
    },
--[[    {
        type = "technology",
        name = "rubia-progression-stage1-machines",
        icon = "__rubia-assets__/graphics/technology/biorecycling.png",--"__rubia-assets__/graphics/icons/science/torus_clear_brown.png",
        icon_size = 256,
        essential = false,
        effects =
        {
            {type = "unlock-recipe", recipe = "biorecycling-plant"},
            {type = "unlock-recipe", recipe = "crapapult"},
            {type = "unlock-recipe", recipe = "alt-gun-turret"},
            {type = "unlock-recipe", recipe = "rubia-sniper-turret"}, -- TODO Shift?
            {type = "unlock-recipe", recipe = "rubia-wind-turbine"},
        },
        prerequisites = { "planet-discovery-rubia"},
        research_trigger = {type = "mine-entity", entity="rubia-spidertron-remnants"},
    },]]

    {
        type = "technology",
        name = "rubia-progression-stage2",
        icon = "__rubia-assets__/graphics/icons/science/sphere_tubed_clear_brown.png",
        icon_size = 64,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-bacteria-B"},
            --{type = "unlock-recipe", recipe = "biorecycle-bacteria-AB-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-engine"}, --OPTIONAL
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-processing-unit"},
            
            {type = "unlock-recipe", recipe = "ghetto-biorecycling-science-pack"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-makeshift-biorecycling-science-pack", count=1000},
    },

    {
        type = "technology",
        name = "rubia-scrapapalooza",
        icon = "__rubia-assets__/graphics/technology/scrapapalooza.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "biorecycle-scrapapalooza"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-spoilage", count=3},
    },
    {
        type = "technology",
        name = "rubia-sniper-turret",
        icon = "__rubia-assets__/graphics/technology/sniper-turret.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-sniper-turret"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-gun-turret", count=1000},
    },

    --[[{
        type = "technology",
        name = "rubia-progression-stage3",
        icon = "__rubia-assets__/graphics/icons/garbo-grabber-2.png",
        icon_size = 128,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "garbo-grabber"},
            --{type = "unlock-recipe", recipe = "biorecycle-bacteria-AB-ferric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-rail"},
        },
        prerequisites = { "rubia-progression-stage2"},
        research_trigger = {type = "craft-item", item="yeet-ghetto-biorecycling-science-pack", count=500},
    },]]

    {
        type = "technology",
        name = "craptonite-processing",
        icon = "__rubia-assets__/graphics/technology/craptonite-frame.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-rail"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-AB-elec-engine"},
            {type = "unlock-recipe", recipe = "garbo-grabber"},
            

            {type = "unlock-recipe", recipe = "assisted-frothing"},
            {type = "unlock-recipe", recipe = "craptonite-casting"},
            {type = "unlock-recipe", recipe = "biorecycling-science-pack"},

            --{type = "unlock-recipe", recipe = "rubia-armored-locomotive"},
            --{type = "unlock-recipe", recipe = "rubia-armored-cargo-wagon"},
            --{type = "unlock-recipe", recipe = "rubia-armored-fluid-wagon"},
        },
        prerequisites = { "rubia-progression-stage2"},
        research_trigger = {type = "craft-item", item="yeet-ghetto-biorecycling-science-pack", count=500},
        --prerequisites = {"rubia-progression-stage3"},
        --research_trigger = {type = "build-entity", entity="garbo-grabber"},
    },

    {
        type = "technology",
        name = "rubia-armored-train",
        icon = "__rubia-assets__/graphics/technology/poo-choo-train.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-armored-locomotive"},
            {type = "unlock-recipe", recipe = "rubia-armored-cargo-wagon"},
            {type = "unlock-recipe", recipe = "rubia-armored-fluid-wagon"},
        },
        prerequisites = {"craptonite-processing"},
        research_trigger = {type = "craft-item", item="craptonite-frame", count=10},
    },

    {--Shamelessly derrived from maraxsis
        type = "technology",
        name = "rubia-project-trashdragon",
        icon = "__rubia-assets__/graphics/technology/project-trashdragon.png",--"__base__/graphics/technology/rocket-silo.png",--"__rubia-assets__/graphics/technology/project_trashdragon.png",
        icon_size = 256,
        effects = {
            {
                type = "nothing",
                use_icon_overlay_constant = true,
                icon = "__base__/graphics/technology/rocket-silo.png",--"__rubia-assets__/graphics/technology/project_trashdragon.png",
                icon_size = 256,
                effect_description = {"modifier-description.rubia-project-trashdragon"}
            },
            {type = "unlock-recipe", recipe = "rocket-part-rubia"},
        },
        prerequisites = {"craptonite-processing"},
        research_trigger = {type = "craft-item", item="yeet-biorecycling-science-pack", count=1000},
        order = "ea[trashdragon]",
    },

--#endregion

--#region Planet Rewards
{
    type = "technology",
    name = "craptonite-wall",
    icon = "__rubia-assets__/graphics/technology/crap-wall.png",
    icon_size = 256,
    essential = false,
    effects = {{type = "unlock-recipe", recipe = "craptonite-wall"},},
    prerequisites = { "rubia-project-trashdragon", "production-science-pack"},
    unit =
    {
        count = 500,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "production-science-pack",    1 },
            { "military-science-pack",        1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    }
},
{
    type = "technology",
    name = "rubia-long-bulk-inserter",
    icon = "__rubia-assets__/graphics/technology/long-bulk-inserter.png",
    icon_size = 256,
    essential = false,
    effects = {{type = "unlock-recipe", recipe = "rubia-long-bulk-inserter"},},
    prerequisites = { "rubia-project-trashdragon", "utility-science-pack"},
    unit =
    {
        count = 1000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    }
},

{
    type = "technology",
    name = "rubia-efficiency-module4",
    icon = "__rubia-assets__/graphics/technology/efficiency-module-4.png",
    icon_size = 256,
    effects = {{type = "unlock-recipe", recipe = "rubia-efficiency-module4"},},
    prerequisites = { "rubia-project-trashdragon","efficiency-module-3"},
    unit =
    {
        count = 2000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "utility-science-pack",    1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    }
},
{
    type = "technology",
    name = "rubia-holmium-craptalysis",
    icon = "__rubia-assets__/graphics/technology/holmium-craptalysis.png",
    icon_size = 256,
    effects = {{type = "unlock-recipe", recipe = "rubia-holmium-craptalysis"},},
    prerequisites = { "rubia-project-trashdragon", "electromagnetic-science-pack"},
    unit =
    {
        count = 2000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "electromagnetic-science-pack", 1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    }
},
{
    type = "technology",
    name = "craptonite-axe",
    icon = "__rubia-assets__/graphics/technology/crap-axe.png",
    icon_size = 256,
    essential = false,
    effects = {{type = "character-mining-speed", modifier = 2}},
    prerequisites = { "rubia-project-trashdragon"},
    unit =
    {
        count = 1000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    },
},
--#endregion

--#region Biofusion science line
{
    type = "technology",
    name = "rubia-biofusion-science-pack",
    icon = "__rubia-assets__/graphics/technology/biofusion-science-pack.png",
    icon_size = 256,
    essential = false,
    effects = {
        {type = "unlock-recipe", recipe = "rubia-biofusion-science-pack"},
        {type = "nothing", use_icon_overlay_constant = false,
        icon = "__space-age__/graphics/icons/iron-bacteria-cultivation.png",
        effect_description = {"modifier-description.biofusion-bacteria-release"}}
    },
    prerequisites = {"rubia-project-trashdragon", "biolab"},
    research_trigger = {type = "craft-item", item="yeet-agricultural-science-pack", count=10000},
},

{
    type = "technology",
    name = "rubia-long-stack-inserter",
    icon = "__rubia-assets__/graphics/technology/long-stack-inserter.png",
    icon_size = 256,
    essential = false,
    effects = {{type = "unlock-recipe", recipe = "rubia-long-stack-inserter"},},
    prerequisites = { "stack-inserter", "rubia-long-bulk-inserter", 
        "rubia-biofusion-science-pack"},
    unit =
    {
        count = 1000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
        },
        time = 60
    }
},

{
    type = "technology",
    name = "rubia-nutrients-from-sludge",
    icon = "__rubia-assets__/graphics/icons/sludge-to-nutrients.png",
    icon_size = 256,
    essential = false,
    effects = {{type = "unlock-recipe", recipe = "rubia-nutrients-from-sludge"},},
    prerequisites = {"rubia-biofusion-science-pack"},
    research_trigger = {type = "craft-item", item="yeet-rubia-biofusion-science-pack", count=1000},
    --[[unit =
    {
        count = 1000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
        },
        time = 60
    }]]
},

{
    type = "technology",
    name = "rubia-nutrient-productivity",
    icons = util.technology_icon_constant_recipe_productivity(
        "__rubia-assets__/graphics/technology/nutrients-technology.png"),    
        --"__rubia-assets__/graphics/technology/craptonite-frame.png"),
    icon_size = 64,
    effects = {
        --{type = "change-recipe-productivity", recipe = "craptonite-casting", change = 0.1},
    },
    prerequisites = {"rubia-biofusion-science-pack"},
    unit = {
        count_formula = "1.5^L*1000",
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
        },
        time = 60
    },
    max_level = "infinite",
    upgrade = true
},

--#endregion

--#region Infinite research (general)
{
    type = "technology",
    name = "craptonite-productivity",
    icons = util.technology_icon_constant_recipe_productivity(
        "__rubia-assets__/graphics/technology/craptonite-frame.png"),
    icon_size = 256,
    effects = {
        {type = "change-recipe-productivity", recipe = "craptonite-casting", change = 0.1},
        {type = "change-recipe-productivity", recipe = "assisted-frothing", change = 0.1},
    },
    prerequisites = {"rubia-project-trashdragon"},
    unit = {
        count_formula = "1.5^L*1000",
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            { "biorecycling-science-pack",    1 },
        },
        time = 60
    },
    max_level = "infinite",
    upgrade = true
},
--Infinite braking force. Thanks to a mod by Velaanix
{
    type = "technology",
    name = "rubia-braking-force-8",
    localised_name = {"technology-name.braking-force"},
    localised_description = {"technology-description.rubia-braking-force-8"},
    icons = util.technology_icon_constant_braking_force("__base__/graphics/technology/braking-force.png"),
    effects =
    {
        {
        type = "train-braking-force-bonus",
        modifier = 0.2
        }
    },
    prerequisites = {"braking-force-7","rubia-project-trashdragon"},--, "metallurgic-science-pack"},
    unit =
    {
        count_formula = "2^(L-7)*500",
        ingredients =
        {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"military-science-pack", 1 },
        --{"metallurgic-science-pack", 1},
        {"biorecycling-science-pack",    1 },
        },
        time = 60
    },
    max_level = "infinite",
    upgrade = true
},
--#endregion

}
)

--#region Craptonite tools. Add on a per planet/mod basis
if data.raw.planet["fulgora"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-boots",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-boots.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "character-running-speed", modifier = 0.25},
            },
            prerequisites = {"craptonite-axe", "electromagnetic-science-pack"},
            research_trigger = {type = "craft-item", item="yeet-electromagnetic-science-pack", count=1000},
        },
    })
end
if data.raw.planet["vulcanus"] then 
    local reach_modifier = 2
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-hook",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-hookshot.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = 'character-build-distance', modifier = reach_modifier, hidden=true},
                {type = 'character-item-drop-distance', modifier = reach_modifier, hidden=true},
                {type = 'character-resource-reach-distance', modifier = reach_modifier, hidden=true},
                {type = 'character-reach-distance', modifier = reach_modifier},
            },
            prerequisites = {"craptonite-axe", "metallurgic-science-pack"},
            research_trigger = {type = "craft-item", item="yeet-metallurgic-science-pack", count=1000},
        },
    })
end

if data.raw.planet["gleba"] then
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-satchel",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-satchel.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = 'character-logistic-trash-slots', modifier = 10},
            },
            prerequisites = {"craptonite-axe", "carbon-fiber"},
            research_trigger = {type = "craft-item", item="yeet-carbon-fiber", count=2000}, --"yeet-agricultural-science-pack"
        },
    })
end

if data.raw.planet["aquilo"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-cannister",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-cannister.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "character-running-speed", modifier = 0.25},
                {type = "character-crafting-speed", modifier = 0.25},
                {type = "character-health-bonus", modifier = -50, 
                    icon="__rubia-assets__/graphics/technology/craptonite-tools/character-health-down.png", icon_size=64},
            },
            prerequisites = {"craptonite-axe", "cryogenic-science-pack"},
            research_trigger = {type = "craft-item", item="yeet-cryogenic-science-pack", count=1000},
        },
    })
end

--External mods
if mods["Moshine"] then 
    local moshine_module_multiplier = 0.1
    local moshine_tech = {
            type = "technology",
            name = "rubia-craptonite-cannister",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-circlet.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "change-recipe-productivity", recipe = "speed-module", change = moshine_module_multiplier},
                {type = "change-recipe-productivity", recipe = "productivity-module", change = moshine_module_multiplier},
                {type = "change-recipe-productivity", recipe = "efficiency-module", change = moshine_module_multiplier},
            },
            prerequisites = {"craptonite-axe", "moshine-tech-ai-tier-10"},
            research_trigger = {type = "craft-item", item="yeet-ai-tier-10", count=500},
        }
    if mods["quality"] then
        table.insert(moshine_tech.effects,
        {type = "change-recipe-productivity", recipe = "quality-module", change = moshine_module_multiplier})
    end
    data:extend({moshine_tech})
end

if mods["corrundum"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-glove",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-glove.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "character-crafting-speed", modifier = 1},
            },
            prerequisites = {"craptonite-axe", "electrochemical-science-pack"},
            research_trigger = {type = "craft-item", item="yeet-electrochemical-science-pack", count=1000},
        },
    })
end

if mods["Cerys-Moon-of-Fulgora"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-earring",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-earring.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "change-recipe-productivity", recipe = "plutonium-fuel", change = 0.25},
            },
            prerequisites = {"craptonite-axe", "cerys-applications-of-radioactivity"},
            research_trigger = {type = "craft-item", item="yeet-plutonium-239", count=1000},
        },
    })
end

if mods["maraxsis"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-lamp",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-lamp.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "nothing", icon_size = 64,
                icon = "__rubia-assets__/graphics/technology/craptonite-tools/lightbulb-icon.png",
                effect_description = {"modifier-description.rubia-craptonite-lamp"}},
            },
            prerequisites = {"craptonite-axe", "maraxsis-project-seadragon"},
            research_trigger = {type = "craft-item", item="yeet-hydraulic-science-pack", count=1000},
        },
    })
end

if mods["planet-muluna"] then  --TODO
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-belt-buckle",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-belt-buckle.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "character-running-speed", modifier = 0.1},
            },
            prerequisites = {"craptonite-axe"},
            research_trigger = {type = "craft-item", item="yeet-wood", count=10000},
        },
    })
end

--#endregion

--[[
if mods["maraxsis"] then
    data:extend(
    {
        {
            type = "technology",
            name = "petrol-dehydrogenation-and-combustion",
            icon_size = 64,
            icon = "__rubia-assets__/graphics/icons/catalytic-chemical-plant.png",
            essential = false,
            effects =
            {
                {
                    type = "unlock-recipe",
                    recipe = "petrol-dehydrogenation-and-combustion",
                },
                {
                    type = "unlock-recipe",
                    recipe = "petrol-dehydrogenation-and-combustion-maraxsis",
                },

    
    
            },
    
            prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","hydraulic-science-pack"},
            unit =
            {
                count = 1000,
                ingredients =
                {
                    { "automation-science-pack",      1 },
                    { "logistic-science-pack",        1 },
                    { "chemical-science-pack",        1 }, 
                    { "biorecycling-science-pack", 1 },
                    { "space-science-pack", 1 },
                    {"hydraulic-science-pack", 1}
                    
                },
                time = 60
            }
        }
    }
    )
end
]]
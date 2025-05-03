require("util")
require("lib.lib")

--Cargo drop restriction
local cargo_drops_base = PlanetsLib.cargo_drops_technology_base(
    "rubia", "__rubia__/graphics/technology/rubia-discovery.png", 256) --TODO Icon
    --TODO: Custom whitelist, because construction bots are allowed
--cargo_drops_base.name = "operation-iron-man"
--Internal tech name must remain planetslib-rubia-cargo-drops
cargo_drops_base.icons = nil
cargo_drops_base.icon = "__rubia__/graphics/technology/operation-iron-man.png"
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
        icons = util.technology_icon_constant_planet("__rubia__/graphics/technology/rubia-discovery.png"),
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
        prerequisites = { "space-platform-thruster", "energy-shield-equipment", "electric-energy-distribution-1"},
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
        icon = "__rubia__/graphics/technology/biorecycling.png",--"__rubia__/graphics/icons/science/torus_clear_brown.png",
        icon_size = 256,
        essential = false,
        effects =
        {
            {type = "unlock-recipe", recipe = "biorecycling-plant"},
            {type = "unlock-recipe", recipe = "crapapult"},
            {type = "unlock-recipe", recipe = "alt-gun-turret"},
            {type = "unlock-recipe", recipe = "rubia-sniper-turret"}, -- TODO Shift?
            {type = "unlock-recipe", recipe = "rubia-wind-turbine"},

            {type = "unlock-recipe", recipe = "rubia-bacteria-A"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-ferric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-firearm-magazine"},
            {type = "unlock-recipe", recipe = "makeshift-biorecycling-science-pack"},
        },
        prerequisites = { "planet-discovery-rubia"},
        research_trigger = {type = "mine-entity", entity="rubia-junk-pile"},
    },
--[[    {
        type = "technology",
        name = "rubia-progression-stage1-machines",
        icon = "__rubia__/graphics/technology/biorecycling.png",--"__rubia__/graphics/icons/science/torus_clear_brown.png",
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
        icon = "__rubia__/graphics/icons/science/sphere_tubed_clear_brown.png",
        icon_size = 64,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-bacteria-B"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-engine"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-processing-unit"},
            
            {type = "unlock-recipe", recipe = "ghetto-biorecycling-science-pack"},
        },
        prerequisites = { "rubia-progression-stage1"},--, "rubia-progression-stage1-machines"},
        research_trigger = {type = "craft-item", item="yeet-makeshift-biorecycling-science-pack", count=1000},
    },

    {
        type = "technology",
        name = "rubia-scrapapalooza",
        icon = "__rubia__/graphics/technology/scrapapalooza.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "biorecycle-scrapapalooza"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-spoilage", count=2},
    },


    {
        type = "technology",
        name = "rubia-progression-stage3",
        icon = "__rubia__/graphics/icons/garbo-gatherer-2.png",
        icon_size = 128,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "garbo-gatherer"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-AB-ferric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-rail"},
        },
        prerequisites = { "rubia-progression-stage2"},
        research_trigger = {type = "craft-item", item="yeet-ghetto-biorecycling-science-pack", count=100},
    },

    {
        type = "technology",
        name = "craptonite-processing",
        icon = "__rubia__/graphics/technology/craptonite-frame.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "assisted-frothing"},
            {type = "unlock-recipe", recipe = "craptonite-casting"},
            {type = "unlock-recipe", recipe = "biorecycling-science-pack"},

            {type = "unlock-recipe", recipe = "biorecycle-bacteria-AB-elec-engine"},

            --{type = "unlock-recipe", recipe = "rubia-armored-locomotive"},
            --{type = "unlock-recipe", recipe = "rubia-armored-cargo-wagon"},
            --{type = "unlock-recipe", recipe = "rubia-armored-fluid-wagon"},
        },
        prerequisites = {"rubia-progression-stage3"},
        research_trigger = {type = "build-entity", entity="garbo-gatherer"},
    },

    {
        type = "technology",
        name = "rubia-armored-train",
        icon = "__rubia__/graphics/technology/poo-choo-train.png",
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
        icon = "__rubia__/graphics/technology/project-trashdragon.png",--"__base__/graphics/technology/rocket-silo.png",--"__rubia__/graphics/technology/project_trashdragon.png",
        icon_size = 256,
        effects = {
            {
                type = "nothing",
                use_icon_overlay_constant = true,
                icon = "__base__/graphics/technology/rocket-silo.png",--"__rubia__/graphics/technology/project_trashdragon.png",
                icon_size = 256,
                effect_description = {"modifier-description.rubia-project-trashdragon"}
            },
            {type = "unlock-recipe", recipe = "rocket-part-rubia"},
        },
        prerequisites = {"craptonite-processing"},
        research_trigger = {type = "craft-item", item="yeet-biorecycling-science-pack", count=100},
        order = "ea[trashdragon]",
    },

--#endregion

--#region Planet Rewards
{
    type = "technology",
    name = "craptonite-wall",
    icon = "__rubia__/graphics/technology/crap-wall.png",
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
    icon = "__rubia__/graphics/technology/long-bulk-inserter.png",
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
    icon = "__rubia__/graphics/technology/efficiency-module-4.png",
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
    icon = "__rubia__/graphics/technology/holmium-craptalysis.png",
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
    icon = "__rubia__/graphics/technology/crap-axe.png",
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
--#region Infinite research
{
    type = "technology",
    name = "craptonite-productivity",
    icons = util.technology_icon_constant_recipe_productivity(
        "__rubia__/graphics/technology/craptonite-frame.png"),
    icon_size = 256,
    effects = {
        {
            type = "change-recipe-productivity",
            recipe = "craptonite-casting",
            change = 0.1
        },
        {
            type = "change-recipe-productivity",
            recipe = "assisted-frothing",
            change = 0.1
        },
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

--[[
if mods["maraxsis"] then
    data:extend(
    {
        {
            type = "technology",
            name = "petrol-dehydrogenation-and-combustion",
            icon_size = 64,
            icon = "__rubia__/graphics/icons/catalytic-chemical-plant.png",
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
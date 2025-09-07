require("util")
require("__rubia__.lib.lib")

--Cargo drop restriction
local cargo_drops_base = PlanetsLib.cargo_drops_technology_base(
    "rubia", "__rubia-assets__/graphics/planet/rubia.png", 256)
--cargo_drops_base.name = "operation-iron-man"
--Internal tech name must remain planetslib-rubia-cargo-drops
cargo_drops_base.icons = nil
cargo_drops_base.icon = "__rubia-assets__/graphics/technology/operation-iron-man.png"
cargo_drops_base.icon_size = 256
cargo_drops_base.localised_name = {"technology-name.operation-iron-man"}
cargo_drops_base.localised_description = {"technology-description.operation-iron-man"}
cargo_drops_base.effects[1].effect_description = {"modifier-description.operation-iron-man-effect"}

data:extend({rubia_lib.merge(cargo_drops_base, {
    prerequisites = { "rubia-project-trashdragon" },
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
    essential = true,
})})


--Make an array of recipe unlock effects, to unlock several recipes at once.
--Enter an array of strings of recipe neames.
local function unlock_recipes(recipe_names)
    local unlocks = {}
    for _, name in pairs(recipe_names) do
        table.insert(unlocks, {type = "unlock-recipe", recipe = name})
    end
end

--Science pack management
--Try to add the rubia science packs to labs.
rubia.try_add_science_packs_to_labs = function()
    --Add my science pack to all labs. Needs to be done in data-stage for Maraxsis
    local all_lab_types = data.raw['lab']
    local function try_add_science_pack_to_lab(lab, science_pack)
        if not rubia_lib.array_find(lab.inputs, science_pack) then
            table.insert(lab.inputs, science_pack) end
    end
    for _,lab in pairs(all_lab_types) do
        try_add_science_pack_to_lab(lab, "biorecycling-science-pack")
    end
    if data.raw.lab.biolab then --Add biofusion science only to biolab
        try_add_science_pack_to_lab(data.raw.lab.biolab,"rubia-biofusion-science-pack")
    else --We have no biolab. Must be some freaky other mod
        for _,lab in pairs(all_lab_types) do
            try_add_science_pack_to_lab(lab, "rubia-biofusion-science-pack")
        end
    end
end
rubia.try_add_science_packs_to_labs()

data:extend({
--#region MARK: Core Rubia Progression
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
            {type = "unlock-recipe", recipe = "rubia-wind-turbine"},

            {type = "unlock-recipe", recipe = "rubia-bacteria-A"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-ferric-scrap"},
        },
        prerequisites = { "planet-discovery-rubia"},
        research_trigger = {type = "mine-entity", entity="rubia-spidertron-remnants"},  --"rubia-junk-pile"
    },
        {
        type = "technology",
        name = "rubia-progression-stage1B",
        icon = "__rubia-assets__/graphics/technology/makeshift-biorecycling-science.png",
        icon_size = 256,
        essential = false,
        effects =
        {
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-firearm-magazine"},
            {type = "unlock-recipe", recipe = "makeshift-biorecycling-science-pack"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-firearm-magazine", count=300},
    },

    {
        type = "technology",
        name = "rubia-progression-stage2",
        icon = "__rubia-assets__/graphics/icons/science/sphere_tubed_clear_brown.png",
        icon_size = 64,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-bacteria-B"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-cupric-scrap"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-A-engine"},
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-processing-unit"},
            
            {type = "unlock-recipe", recipe = "ghetto-biorecycling-science-pack"},
        },
        prerequisites = { "rubia-progression-stage1B"},
        research_trigger = {type = "craft-item", item="yeet-makeshift-biorecycling-science-pack", count=1000},
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
            {type = "unlock-recipe", recipe = "rubia-rci-rocketizer"},
        },
        prerequisites = {"craptonite-processing"},
        research_trigger = {type = "craft-item", item="yeet-biorecycling-science-pack", count=1000},
        order = "ea[trashdragon]",
    },

--#endregion

--#region Optional Recipes
    {
        type = "technology",
        name = "rubia-scrapapalooza",
        icon = "__rubia-assets__/graphics/technology/scrapapalooza.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "biorecycle-scrapapalooza"},
        },
        prerequisites = { "rubia-progression-stage2"},
        research_trigger = {type = "craft-item", item="yeet-spoilage", count=3},
    },
    {
        type = "technology",
        name = "rubia-sniper-turret",
        icon = "__rubia-assets__/graphics/technology/sniper-turret.png",
        icon_size = 128,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "rubia-sniper-turret"},
        },
        prerequisites = { "rubia-progression-stage2"},
        research_trigger = {type = "craft-item", item="yeet-gun-turret", count=1000},
    },

    {
        type = "technology",
        name = "rubia-postgame-biorecycle-part1",
        icon = "__rubia-assets__/graphics/technology/biorecycling-batteries.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "biorecycle-bacteria-B-ferric-scrap"},
        },
        prerequisites = {"planetslib-rubia-cargo-drops"},
        research_trigger = {type = "craft-item", item="yeet-lubricant-barrel", count=100},
    },


--#endregion

--#region Planet Rewards
{
    type = "technology",
    name = "craptonite-wall",
    icon = "__rubia-assets__/graphics/technology/crap-wall.png",
    icon_size = 256,
    essential = false,
    effects = {
        {type = "unlock-recipe", recipe = "craptonite-wall"},
        --{type = "unlock-recipe", recipe = "rubia-refined-concrete"},
    },
    prerequisites = {"planetslib-rubia-cargo-drops", "production-science-pack"},
    unit =
    {
        count = 1000,
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
    prerequisites = {"planetslib-rubia-cargo-drops"},--, "utility-science-pack"},
    unit =
    {
        count = 1000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            --{ "utility-science-pack",         1 },
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
    prerequisites = {"planetslib-rubia-cargo-drops","efficiency-module-3"},
    unit =
    {
        count = 2000,
        ingredients =
        {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "utility-science-pack",         1 },
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
    prerequisites = {"planetslib-rubia-cargo-drops", "electromagnetic-science-pack"},
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
    prerequisites = {"planetslib-rubia-cargo-drops"},
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
    prerequisites = {"planetslib-rubia-cargo-drops", "biolab"},
    research_trigger = {type = "craft-item", item="yeet-agricultural-science-pack", count=5000},
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
    icon_size = 64,
    essential = false,
    effects = {{type = "unlock-recipe", recipe = "rubia-nutrients-from-sludge"},},
    prerequisites = {"rubia-biofusion-science-pack"},
    research_trigger = {type = "craft-item", item="yeet-rubia-biofusion-science-pack", count=1000},
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
        count_formula = "1.8^L*1000",
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
{
    type = "technology",
    name = "rubia-biofusion-promethium-science-pack",
    icon = "__rubia-assets__/graphics/technology/promethium-biofusion-science.png",
    icon_size = 256,
    effects = {{type = "unlock-recipe", recipe = "rubia-biofusion-promethium-science-pack"},},
    prerequisites = {"rubia-biofusion-science-pack", "promethium-science-pack"},
    unit = {
        count = 100000,
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "space-science-pack",           1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
            { "promethium-science-pack",      1 },
        },
        time = 60
    },
},
{
    type = "technology",
    name = "rubia-bio-utility-science-pack",
    icon = "__rubia-assets__/graphics/technology/rubia-utility-science-pack.png",
    icon_size = 256,
    effects = {
        {type = "unlock-recipe", recipe = "rubia-bio-utility-science-pack", hidden = true},
        {type = "nothing", icon_size = 64,
         icon = "__rubia-assets__/graphics/icons/rubia-utility-science-pack.png",
                effect_description = {"modifier-description.rubia-bio-utility-science-pack-unlock"}}
        },
    prerequisites = {"rubia-biofusion-science-pack", "rubia-postgame-biorecycle-part1"},
    unit = {
        count = 3000,
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
        },
        time = 60
    },
},

{
    type = "technology",
    name = "rubia-bio-flying-robot-frame",
    icon = "__rubia-assets__/graphics/technology/rubia-robotics.png",
    icon_size = 256,
    --[[icons = {
        {icon = "__base__/graphics/technology/robotics.png", icon_size = 256,},
        {icon = "__rubia-assets__/graphics/planet/rubia-icon.png", icon_size = 64,
        scale = 0.5 * 0.5,
        shift = {x=64 * 0.5/4, y =-64 * 0.5/4},}
    },]]
    effects = {
        {type = "unlock-recipe", recipe = "rubia-bio-flying-robot-frame"},--, hidden = true},
        --{type = "nothing", icon_size = 64,
        -- icon = "__rubia-assets__/graphics/icons/rubia-utility-science-pack.png",
        --        effect_description = {"modifier-description.rubia-bio-utility-science-pack-unlock"}}
        },
    prerequisites = {"rubia-biofusion-science-pack", "rubia-bio-utility-science-pack"},
    unit = {
        count = 3000,
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            { "utility-science-pack",         1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
        },
        time = 60
    },
},

--[[
{
    type = "technology",
    name = "rubia-biter-egg-productivity",
    localised_name = {"",{"item-name.biter-egg"}, " ", {"description.productivity-bonus"}},
    icons = util.technology_icon_constant_recipe_productivity(
        "__space-age__/graphics/technology/biter-egg-handling.png"),
    icon_size = 256,
    effects = {
        {type = "change-recipe-productivity", recipe = "biter-egg", change = 0.05},
    },
    prerequisites = {"rubia-biofusion-science-pack", "promethium-science-pack"},
    unit = {
        count_formula = "2^L*1000",
        ingredients = {
            { "automation-science-pack",      1 },
            { "logistic-science-pack",        1 },
            { "chemical-science-pack",        1 },
            { "military-science-pack",        1 },
            --{ "utility-science-pack",         1 },
            { "space-science-pack",           1 },
            { "agricultural-science-pack",    1 },
            { "biorecycling-science-pack",    1 },
            { "rubia-biofusion-science-pack", 1 },
            { "promethium-science-pack",      1 },
        },
        time = 60
    },
    max_level = "infinite",
    upgrade = true
},
]]

{ --Modeled from Maraxsis
    type = "technology",
    name = "rubia-cargo-landing-pad-capacity",
    icon = "__rubia-assets__/graphics/technology/operation-craptonite-man.png",
    icon_size = 256,
    --icons = util.technology_icon_constant_capacity("__space-age__/graphics/technology/space-platform.png"),--data.raw.technology["space-platform"].icon),
    --icon_size = data.raw.technology["space-platform"].icon_size,
    effects = {
        {type = "cargo-landing-pad-count", modifier = 1,
        --icon = "__base__/graphics/icons/cargo-landing-pad.png"
            icons = mupgrade_lib.make_technology_icon(
                {icon = "__base__/graphics/icons/cargo-landing-pad.png"}, "efficiency")
        },
    },
    prerequisites = {"rubia-biofusion-science-pack", "promethium-science-pack"},
    unit = {
        count = 10000,
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"chemical-science-pack",        1},
            {"military-science-pack",        1},
            {"production-science-pack",      1},
            {"utility-science-pack",         1},
            {"space-science-pack",           1},
            {"agricultural-science-pack",    1},
            {"biorecycling-science-pack",    1},
            {"rubia-biofusion-science-pack", 1},
            {"promethium-science-pack",      1},
        },
        time = 60
    },
}


})


if mods["machine-upgrades"] then
    local mupgrades = require("__machine-upgrades__.lib.technology-maker")
    data:extend({
    {
        type = "technology",
        name = "rubia-biochamber-productivity-bonus",
        icons = mupgrades.make_technology_icon({
            icon = "__space-age__/graphics/technology/biochamber.png",
            icon_size = 256}, "productivity"),
        essential = false,
        effects = {},
        prerequisites = {"rubia-nutrients-from-sludge"},
        unit = {
            count_formula = "2^L*1000",
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "agricultural-science-pack",    1 },
                { "biorecycling-science-pack",    1 },
                { "rubia-biofusion-science-pack", 1 },
            },
            time = 60
        },
        max_level = 10,
    },

    --[[
    {
        type = "technology",
        name = "rubia-biolab-pollution-bonus",
        --localised_name = {"", {"entity-name.biolab"}," ", {"description.pollution-bonus"}},
        icons = mupgrades.make_technology_icon({
            icon = "__space-age__/graphics/technology/biolab.png",
            icon_size = 256}, "pollution"),
        essential = false,
        effects = {},
        prerequisites = {"rubia-biofusion-science-pack"},
        unit = {
            count_formula = "2^L*1000",
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "agricultural-science-pack",    1 },
                { "biorecycling-science-pack",    1 },
                { "rubia-biofusion-science-pack", 1 },
            },
            time = 60
        },
        max_level = 16,
    },
    ]]

    })
end

--#endregion

--#region Infinite research (general)
data:extend({
{
    type = "technology",
    name = "craptonite-productivity",
    icons = util.technology_icon_constant_recipe_productivity(
        "__rubia-assets__/graphics/technology/craptonite-frame.png"),
    icon_size = 256,
    effects = {
        {type = "change-recipe-productivity", recipe = "craptonite-casting", change = 0.05},
        {type = "change-recipe-productivity", recipe = "assisted-frothing", change = 0.05},
    },
    prerequisites = {"planetslib-rubia-cargo-drops"},
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
    name = "braking-force-8",
    localised_name = {"technology-name.braking-force"},
    localised_description = {"technology-description.rubia-braking-force-8"},
    icons = util.technology_icon_constant_braking_force("__base__/graphics/technology/braking-force.png"),
    effects = {
        {type = "train-braking-force-bonus", modifier = 0.2}
    },
    prerequisites = {"braking-force-7","planetslib-rubia-cargo-drops"},--, "metallurgic-science-pack"},
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
            name = "rubia-craptonite-circlet",
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

    --Vanila galore continued adds modules
    if mods["vanilla_galore_continued"] then
        local vgal_recipe = {"vgal-tungsten-carbide-speed-module", "vgal-spoilage-efficiency-module",
            "vgal-biter-egg-productivity-module"}
        if mods["quality"] then table.insert(vgal_recipe, "vgal-superconductor-quality-module") end
        for _, entry in pairs(vgal_recipe) do
            table.insert(moshine_tech.effects,
                {type = "change-recipe-productivity", recipe = entry, 
                    change = moshine_module_multiplier, hidden = true})
        end
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
                {type = "character-crafting-speed", modifier = 0.5},
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
            research_trigger = {type = "craft-item", item="yeet-plutonium-239", count=300},
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
            research_trigger = {type = "craft-item", item="yeet-maraxsis-glass-panes", count=1000}, --"yeet-hydraulic-science-pack"
        },
    })
end

if mods["planet-muluna"] then
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

if mods["cubium"] then 
    local reach_modifier_cubium = 2
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-bracer",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-cube-bracelet.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = 'character-build-distance', modifier = reach_modifier_cubium, hidden=true},
                {type = 'character-item-drop-distance', modifier = reach_modifier_cubium, hidden=true},
                {type = 'character-resource-reach-distance', modifier = reach_modifier_cubium, hidden=true},
                {type = 'character-reach-distance', modifier = reach_modifier_cubium},
            },
            prerequisites = {"craptonite-axe", "cube-mastery-4"},
            research_trigger = {type = "craft-item", item="yeet-dream-concentrate-barrel", count=100},
        },
    })
end


if mods["secretas"] and mods["machine-upgrades"] then
    data:extend({
    {
        type = "technology",
        name = "rubia-craptonite-codpiece",
        icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-codpiece.png",
        icon_size = 256,
        essential = false,
        effects = {},
        prerequisites = {"craptonite-axe", "steam-recycler"},
        research_trigger = {type = "craft-item", item="yeet-steam-recycler", count=1000},
    },
    })
end
if mods["janus"] and mods["machine-upgrades"] then
    data:extend({
    {
        type = "technology",
        name = "rubia-craptonite-mask",
        icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-mask.png",
        icon_size = 256,
        essential = false,
        effects = {},
        prerequisites = {"craptonite-axe", "janus-time-science-pack"},
        research_trigger = {type = "craft-item", item="yeet-janus-time-science-pack", count=1000},
    },
    })
end

if (mods["lignumis"] or mods["wood-universe-modpack"]) and mods["machine-upgrades"] then
    --Lignumis/Wood universe use same internal names for stuff, and similar balance. The difference is the tech.
    local wooden_prerequisite = mods["lignumis"] and "lumber-mill" or "advanced-carpentry"
    data:extend({
    {
        type = "technology",
        name = "rubia-craptonite-wood-charm",
        icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-wood-charm.png",
        icon_size = 256,
        essential = false,
        effects = {},
        prerequisites = {"craptonite-axe", wooden_prerequisite},
        research_trigger = {type = "craft-item", item="yeet-lumber", count=10000},
    },
    })
end


if mods["Paracelsin"] and mods["machine-upgrades"] then
    data:extend({
    {
        type = "technology",
        name = "rubia-craptonite-grillz",
        icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-tooth-grillz.png",
        icon_size = 256,
        essential = false,
        effects = {{type = "character-health-bonus", modifier = -25, 
                    icon="__rubia-assets__/graphics/technology/craptonite-tools/character-health-down.png", icon_size=64},
        },
        prerequisites = {"craptonite-axe", "galvanization-science-pack"},
        research_trigger = {type = "craft-item", item="yeet-electric-coil", count=2000},
    },
    })
end

if mods["Factorio-Tiberium"] and mods["machine-upgrades"] then
    data:extend({
    {
        type = "technology",
        name = "rubia-craptonite-tiber-implant",
        icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-implant.png",
        icon_size = 256,
        essential = false,
        effects = {{type = "character-health-bonus", modifier = -50, 
                    icon="__rubia-assets__/graphics/technology/craptonite-tools/character-health-down.png", icon_size=64},
        },
        prerequisites = {"craptonite-axe", "tiberium-liquid-centrifuging"},
        research_trigger = {type = "craft-item", item="yeet-liquid-tiberium-barrel", count=1000},
    },
    })
end

--[[
----TODO: When Jahtra launches
if mods["jahtra"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-hip-replacement",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-hip-replacement.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "character-inventory-slots-bonus", modifier = 10},
                --{type = "character-running-speed", modifier = -0.1,
                --    icon="__rubia-assets__/graphics/technology/craptonite-tools/character-slow-speed-icon.png", icon_size=64},
                {type = "character-health-bonus", modifier = -50, 
                    icon="__rubia-assets__/graphics/technology/craptonite-tools/character-health-down.png", icon_size=64},
            },
            prerequisites = {"craptonite-axe", "jahtra-advanced-materials-science-pack"},
            research_trigger = {type = "craft-item", item="yeet-jahtra-high-performance-alloy", count=1000},
        },
    })
end]]

if mods["skewer_shattered_planet"] then 
    data:extend({
        {
            type = "technology",
            name = "rubia-craptonite-stopwatch",
            icon = "__rubia-assets__/graphics/technology/craptonite-tools/craptonite-stopwatch.png",
            icon_size = 256,
            essential = false,
            effects = {
                {type = "change-recipe-productivity", recipe = "kovarex-enrichment-process", change = 0.30},
            },
            prerequisites = {"craptonite-axe", "s3_californium"},
            research_trigger = {type = "craft-item", item="yeet-ske_hec_251_oxide", count=1000},
        },
    })
end

--#endregion
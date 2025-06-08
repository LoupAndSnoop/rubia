if not mods["Krastorio2-spaced-out"] then
    return
end

-- allows usage of krastorio2 utility functions
local data_util = require("__Krastorio2-spaced-out__.data-util")

-- add new recipes
data:extend({
    {
        type = "recipe",
        name = "kr-rubia-repair-pack",
        localised_name = {"item-name.repair-pack"},
        category = "biorecycling",
        energy_required = 10,
        enabled = false,
        ingredients = {
        { type = "item", name = "kr-rifle-magazine", amount = 3 },
        { type = "item", name = "rubia-bacteria-A", amount = 4 },
        },
        results = { { type = "item", name = "repair-pack", amount = 5 } },
        allow_productivity = true,
    },
    {
        type = "recipe",
        name = "kr-rubia-automation-core",
        localised_name = {"item-name.kr-automation-core"},
        category = "biorecycling",
        energy_required = 10,
        enabled = false,
        ingredients = {
        { type = "item", name = "copper-cable", amount = 5 },
        { type = "item", name = "rubia-bacteria-A", amount = 3 },
        },
        results = { { type = "item", name = "kr-automation-core", amount = 2 } },
        allow_productivity = true,
    },
    {
        type = "recipe",
        name = "kr-rubia-oxygen",
        localised_name = {"fluid-name.kr-oxygen"},
        category = "biorecycling",
        energy_required = 2,
        enabled = false,
        ingredients = {
            { type = "fluid", name = "rubia-bacterial-sludge", amount = 20 },
        },
        results = { { type = "fluid", name = "kr-oxygen", amount = 100 } },
        allow_productivity = true,
    },
})

data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-automation-core")
data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-repair-pack")
data_util.add_recipe_unlock("rubia-progression-stage1", "kr-rubia-oxygen")

--pistol ammo -> rifle ammo conversion
data_util.convert_ingredient("biorecycle-bacteria-A-firearm-magazine","firearm-magazine", "kr-rifle-magazine" )
data_util.convert_ingredient("biorecycle-bacteria-AB-elec-engine","firearm-magazine", "kr-rifle-magazine" )
data_util.add_or_replace_product("biorecycle-bacteria-A-ferric-scrap", "firearm-magazine", { type = "item", name = "kr-rifle-magazine", amount = 12 } )
data_util.add_or_replace_product("biorecycle-bacteria-B-cupric-scrap", "piercing-rounds-magazine", { type = "item", name = "kr-armor-piercing-rifle-magazine", amount = 2 } )

data.raw.technology["rubia-progression-stage1B"].research_trigger = { type = "craft-item",  item = "yeet-kr-rifle-magazine", count = 300 }
data.raw["simple-entity"]["rubia-junk-pile"].minable = {
      mining_particle = "iron-ore-particle",
      mining_time = 3,
      results = {
        {type = "item", name = "iron-gear-wheel", amount_min = 2, amount_max = 4},
        {type = "item", name = "iron-gear-wheel", probability=0.2, amount_min = 35, amount_max = 50},
        {type = "item", name = "iron-plate", probability=0.4, amount_min = 30, amount_max = 50},
        {type = "item", name = "kr-rifle-magazine", probability=0.5, amount_min = 20, amount_max = 40},
        {type = "item", name = "copper-cable", probability=0.7, amount_min = 20, amount_max = 40},
        {type = "item", name = "steel-plate", probability=0.15, amount_min = 30, amount_max = 40},
        --{type = "item", name = "pipe", probability=0.1, amount_min = 30, amount_max = 40},
        --{type = "item", name = "stone-brick", probability=0.3, amount_min = 20, amount_max = 40},
      }
}

--add mineral pump to spidertron corpse results
data.raw["simple-entity"]["rubia-spidertron-remnants"].minable = {
      mining_particle = "iron-ore-particle",
      mining_time = 4,
      results = {
        --Important drops
        {type = "item", name = "construction-robot", amount_min = 1, amount_max = 4},
        {type = "item", name = "steel-plate", amount_min = 3, amount_max = 7},
        {type = "item", name = "advanced-circuit", probability = 0.3, amount_min = 8, amount_max = 15},
        {type = "item", name = "gun-turret", probability=0.4, amount_min = 5, amount_max = 7},
        {type = "item", name = "electric-furnace", probability=0.4, amount_min = 1, amount_max = 3},
        {type = "item", name = "kr-mineral-water-pumpjack", probability=0.4, amount_min = 1, amount_max = 3},
        --Fun/helpful drops
        {type = "item", name = "fast-inserter", probability = 0.1, amount_min = 20, amount_max = 40},
        {type = "item", name = "fast-transport-belt", probability = 0.25, amount_min = 50, amount_max = 65},
        {type = "item", name = "underground-belt", probability = 0.12, amount_min = 20, amount_max = 30},
        {type = "item", name = "express-splitter", probability = 0.2, amount_min = 8, amount_max = 12},
        {type = "item", name = "pipe-to-ground", probability = 0.1, amount_min = 16, amount_max = 32},
        {type = "item", name = "assembling-machine-2", probability = 0.1, amount_min = 7, amount_max = 12},
        --{type = "item", name = "rail", probability = 0.08, amount_min = 50, amount_max = 80},
        {type = "item", name = "electric-mining-drill", probability = 0.07, amount_min = 10, amount_max = 20},
        {type = "item", name = "efficiency-module", probability = 0.1, amount_min = 15, amount_max = 30},
        {type = "item", name = "speed-module-2", probability = 0.08, amount_min = 15, amount_max = 25},
        {type = "item", name = "spoilage", probability = 0.03, amount_min = 1, amount_max = 1}
      }
}



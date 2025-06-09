if not mods["Krastorio2-spaced-out"] then return end

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

local junk_pile = data.raw["simple-entity"]["rubia-junk-pile"].minable.results
local _, entry = rubia_lib.compat.find_item_in_list(junk_pile, "firearm-magazine")
entry.name = "kr-rifle-magazine"

--add mineral pump to spidertron corpse results
local spider = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(spider, 5,
    {type = "item", name = "kr-mineral-water-pumpjack", probability=0.4, amount_min = 1, amount_max = 3})

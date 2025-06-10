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
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-b",
        surface_conditions = rubia.surface_conditions(),
        energy_required = 10,
        enabled = false,
        ingredients = {
        { type = "item", name = "iron-plate", amount = 3 },
        { type = "item", name = "rubia-bacteria-A", amount = 4 },
        },
        results = { { type = "item", name = "repair-pack", amount = 1 } },
        allow_productivity = true,
    },
    {
        type = "recipe",
        name = "kr-rubia-automation-core",
        localised_name = {"item-name.kr-automation-core"},
        category = "biorecycling",
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-c",
        surface_conditions = rubia.surface_conditions(),
        energy_required = 10,
        enabled = false,
        ingredients = {
        { type = "item", name = "copper-cable", amount = 5 },
        { type = "item", name = "iron-gear-wheel", amount = 3 },
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
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-d",
        surface_conditions = rubia.surface_conditions(),
        energy_required = 2,
        enabled = false,
        ingredients = {
            { type = "fluid", name = "rubia-bacterial-sludge", amount = 20 },
        },
        results = { { type = "fluid", name = "kr-oxygen", amount = 100 } },
        allow_productivity = true,
    },
})

--data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-automation-core")
--data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-repair-pack")
data_util.add_recipe_unlock("rubia-progression-stage2", "kr-rubia-oxygen")




--Add mineral pump to spidertron corpse results
local spider = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(spider, 5,
    {type = "item", name = "kr-mineral-water-pumpjack", probability=0.4, amount_min = 1, amount_max = 3})

---We can't make steel without coke.
--Need a recipe to make coke.
data:extend({
    {
    type ="recipe",
    name ="rubia-compat-k2so-coke",
    localised_name = {"recipe-name.rubia-compat-alloy-smelting-coke"},
    localised_description = {"recipe-description.rubia-compat-alloy-smelting-coke"},
    category = "biorecycling",
    subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-a",
    enabled = false,
    ingredients = {
        {type ="fluid", name ="rubia-bacterial-sludge", amount = 50},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 3,
    results = {
        {type ="item", name ="kr-coke", amount = 1},
    },
    allow_productivity = true,
    crafting_machine_tint = {r=0.1,g=0.1,b=0.1,a=1},
    auto_recycle = false,
    },
})
rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", "rubia-compat-k2so-coke")

--A new technology to house these techs
data:extend({
{
        type = "technology",
        name = "rubia-progression-stage1-compat-k2so",
        icon = "__Krastorio2Assets__/technologies/automation-core.png",
        icon_size = 256,
        essential = false,
        effects = {
            {type = "unlock-recipe", recipe = "kr-rubia-automation-core"},
            {type = "unlock-recipe", recipe = "kr-rubia-repair-pack"},
            {type = "unlock-recipe", recipe = "rubia-compat-k2so-coke"},
        },
        prerequisites = { "rubia-progression-stage1"},
        research_trigger = {type = "craft-item", item="yeet-copper-cable", count=50},
    },
})

----


---------
if settings.startup["kr-realistic-weapons"].value then
    --pistol ammo -> rifle ammo conversion
    data_util.convert_ingredient("biorecycle-bacteria-A-firearm-magazine","firearm-magazine", "kr-rifle-magazine" )
    data_util.convert_ingredient("biorecycle-bacteria-AB-elec-engine","firearm-magazine", "kr-rifle-magazine" )
    data_util.add_or_replace_product("biorecycle-bacteria-A-ferric-scrap", "firearm-magazine", { type = "item", name = "kr-rifle-magazine", amount = 12 } )
    data_util.add_or_replace_product("biorecycle-bacteria-B-cupric-scrap", "piercing-rounds-magazine", { type = "item", name = "kr-armor-piercing-rifle-magazine", amount = 2 } )
    data.raw.technology["rubia-progression-stage1B"].research_trigger.item = "yeet-kr-rifle-magazine"

    local junk_pile = data.raw["simple-entity"]["rubia-junk-pile"].minable.results
    local _, entry = rubia_lib.compat.find_item_in_list(junk_pile, "firearm-magazine")
    entry.name = "kr-rifle-magazine"

    --[[Ammo is too slow.
    local yellow_projectile = data.raw.projectile["kr-rifle-magazine-projectile"].ammo_type.action[1].action_delivery[1]
    yellow_projectile.starting_speed = yellow_projectile.starting_speed * 3
    yellow_projectile.direction_deviation = yellow_projectile.direction_deviation * 0.75
    yellow_projectile.range_deviation = yellow_projectile.range_deviation * 0.75
    ]]
end
-------
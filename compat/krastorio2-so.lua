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
        icons = rubia_lib.compat.make_rubia_superscripted_icon({
            icon = "__base__/graphics/icons/repair-pack.png",
        }),
        surface_conditions = rubia.surface_conditions(),
        energy_required = 10,
        enabled = false,
        ingredients = {
        { type = "item", name = "iron-plate", amount = 3 },
        { type = "item", name = "rubia-bacteria-A", amount = 4 },
        },
        results = { { type = "item", name = "repair-pack", amount = 1 } },
        allow_productivity = true,
        auto_recycle = false,
    },
    {
        type = "recipe",
        name = "kr-rubia-automation-core",
        localised_name = {"item-name.kr-automation-core"},
        category = "biorecycling",
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-c",
        icons = rubia_lib.compat.make_rubia_superscripted_icon({
            icon = "__Krastorio2Assets__/icons/items/automation-core.png",
        }),
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
        auto_recycle = false,
    },
    {
        type = "recipe",
        name = "kr-rubia-oxygen",
        localised_name = {"fluid-name.kr-oxygen"},
        category = "biorecycling",
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-b[k2so]-d",
        icons = rubia_lib.compat.make_rubia_superscripted_icon({
            icon = "__Krastorio2Assets__/icons/fluids/oxygen.png",
        }),
        surface_conditions = rubia.surface_conditions(),
        energy_required = 2,
        enabled = false,
        ingredients = {
            { type = "fluid", name = "rubia-bacterial-sludge", amount = 20 },
        },
        results = { { type = "fluid", name = "kr-oxygen", amount = 100 } },
        allow_productivity = true,
        auto_recycle = false,
    },
})

--data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-automation-core")
--data_util.add_recipe_unlock("rubia-progression-stage1B", "kr-rubia-repair-pack")
data_util.add_recipe_unlock("rubia-progression-stage2", "kr-rubia-oxygen")


--Add mineral pump to spidertron corpse results
local spider = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(spider, 5, rubia_lib.tech_cost_scale(
    {type = "item", name = "kr-mineral-water-pumpjack", probability=0.4, amount_min = 1, amount_max = 3}))

--BZ Tin adds solder to fuel refineries.
if mods["bztin"] then 
    local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
    table.insert(scrapapalooza, {type = "item", name = "kr-fuel-refinery", amount = 1, probability = 0.05})
    rubia_lib.compat.try_add_prerequisite("craptonite-processing","rubia-scrapapalooza")
end

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
    icons = rubia_lib.compat.make_rubia_superscripted_icon({
        icon = "__Krastorio2Assets__/icons/items/coke.png",
    }),
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

--Gun turret trap needs to be rebalanced.
local trap = data.raw["ammo-turret"]["rubia-gun-turret-trap"]
trap.attack_parameters.damage_modifier = trap.attack_parameters.damage_modifier / 2


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

    --Ammo is too slow.
    local function on_data_final_fixes()
        local SPEED_MULT = 1.5
        local DEV_MULT = 1
        local RANGE_DEV_MULT = 0.8
        local MIN_PROJECTILE_RANGE = 65

        local action_deliveries = {}
        for name, proto in pairs(data.raw.ammo) do
            if proto.ammo_category == "bullet" and proto.ammo_type and proto.ammo_type.action then
                local action = proto.ammo_type.action
                if action.action_delivery then table.insert(action_deliveries, action.action_delivery)
                else
                    for _, entry in pairs(action or {}) do
                        if entry.action_delivery then table.insert(action_deliveries, entry.action_delivery) end
                    end
                end
            end
        end
        for _, entry in pairs(action_deliveries) do
            for _, each in pairs(entry) do
                if type(each) == "table" then
                    if each.starting_speed then each.starting_speed = each.starting_speed * SPEED_MULT end
                    if each.direction_deviation then each.direction_deviation = each.direction_deviation * DEV_MULT end
                    if each.range_deviation then each.range_deviation = each.range_deviation * RANGE_DEV_MULT end
                    if each.max_range then each.max_range = math.max(each.max_range, MIN_PROJECTILE_RANGE) end
                end
            end
        end
    end
    table.insert(rubia_lib.compat.to_call_on_data_final_fixes, on_data_final_fixes)

end
-------
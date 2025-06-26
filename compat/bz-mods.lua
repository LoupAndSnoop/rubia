
--BZ Tin makes pumpjacks uncraftable
if mods["bztin"] then
    local minable = data.raw["simple-entity"]["rubia-junk-pile"].minable.results
    table.insert(minable,
        {type = "item", name = "tin-plate", probability = 0.4, amount_min = 5, amount_max = 20})
end

--Bz Lead makes pipes unobtainable
if mods["bzlead"] then
    data:extend({
    {
        type = "recipe",
        name = "rubia-compat-pipe",
        localised_name = {"entity-name.pipe"},
        category = "crafting",
        --subgroup = "rubia-compat-recipes", order = "g[rubia compat]-bz[bz mods]-a",
        surface_conditions = rubia.surface_conditions(),
        ingredients = {{type = "item", name = "iron-plate", amount = 1}},
        results = {{type="item", name="pipe", amount=1}},
        enabled = false,
        allow_productivity = true,
        auto_recycle = false,
    },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1", "rubia-compat-pipe")
end

--Both these mods change the recipe for green circuits.
if mods["bzcarbon"] or mods["bztin"] then
    local common_compat_prototypess = require("__rubia__.compat.common-compat-prototypes")
    local green_circ = common_compat_prototypess["electronic-circuit-recipe"]
    data:extend({green_circ})
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1", green_circ.name)
end

--These mods make chem plants uncraftable
if mods["bztin"] or mods["bzlead"] then
    local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
    table.insert(minable, {type = "item", name = "chemical-plant", 
        probability = 0.4, amount_min = 3, amount_max = 6})
end
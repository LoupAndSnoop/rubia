local common_compat_prototypes = require("__rubia__.compat.common-compat-prototypes")

--Bob's metals and intermediates makes O2 needed to smelt steel
if mods["bobplates"] then
    local spidertron = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
    table.insert(spidertron, rubia_lib.tech_cost_scale({type = "item", name = "bob-air-pump", 
        probability = 0.3, amount_min = 1, amount_max = 3}))

    --We don't need furnaces, but electric chemical furnaces
    local _, entry = rubia_lib.compat.find_item_in_list(spidertron, "electric-furnace")
    entry.name = "bob-electric-chemical-furnace"

    local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
    local _, entry = rubia_lib.compat.find_item_in_list(scrapapalooza, "electric-furnace")
    entry.name = "bob-electric-chemical-furnace"

    --Rocket fuel requires a bunch of crap. Add a new compressor recipe
    data:extend({
        {
            type = "recipe",
            name = "rubia-compat-bob-compressed-gas",
            icons = rubia_lib.compat.make_rubia_superscripted_icon(
                {icon ="__bobplates__/graphics/icons/liquid-air.png", icon_size = 32}),
            category = "chemical-plant-only",--"bob-air-pump",
            subgroup = "fluid-recipes", order = "r[rubia]-a",
            surface_conditions = rubia.surface_conditions(),
            energy_required = 2,
            ingredients = {
                {type = "fluid", name = "bob-liquid-air", amount = 120},
            },
            results = {
                {type = "fluid", name = "bob-oxygen", amount = 45},
                {type = "fluid", name = "bob-nitrogen-dioxide", amount = 75},
            },
            enabled = false,
            allow_productivity = true,
            auto_recycle = false,
        },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", "rubia-compat-bob-compressed-gas")

    rubia.ban_from_rubia(data.raw.recipe["bob-nitrogen"]) --Get your clean air out here!

    data:extend({
        {
            type = "recipe",
            name = "rubia-compat-bob-sludge-fermentation",
            icons = rubia_lib.compat.make_rubia_superscripted_icon(
                {icon ="__rubia-assets__/graphics/icons/bacterial-sludge.png", icon_size = 64}),
            category = "chemical-plant-only",--"bob-air-pump",
            subgroup = "fluid-recipes", order = "r[rubia]-b",
            surface_conditions = rubia.surface_conditions(),
            energy_required = 2,
            ingredients = {
                --{type = "fluid", name = "rubia-bacterial-sludge", amount = 20},
                {type = "fluid", name = "light-oil", amount = 5},
                {type = "fluid", name = "bob-nitrogen-dioxide", amount = 60},
            },
            results = {
                {type = "fluid", name = "bob-hydrogen", amount = 45},
                {type = "fluid", name = "bob-nitrogen", amount = 75},
            },
            enabled = false,
            allow_productivity = true,
            auto_recycle = false,
        },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage2", "rubia-compat-bob-sludge-fermentation")
end

if mods["bobelectronics"] then
    --Bob's electronics changes the recipe for green circuits.
    local green_circ = common_compat_prototypes["electronic-circuit-recipe"]
    data:extend({green_circ})
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1", green_circ.name)


end

if mods["bobassembly"] and mods["bobplates"] then
    local spidertron = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
    table.insert(spidertron, rubia_lib.tech_cost_scale({type = "item", name = "chemical-plant", 
        probability = 0.4, amount_min = 3, amount_max = 6}))
end

--Silos are super uncraftable in bob's revamp
if mods["bobrevamp"] then
    local silo_recipe = common_compat_prototypes["rocket-silo-recipe"]
    data:extend({silo_recipe})
    rubia_lib.compat.add_recipe_to_technology("rubia-project-trashdragon", silo_recipe.name)
end
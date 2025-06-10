--Data stage compat for alloy-smelting, which was made by saf the lamb.
if not mods["alloy-smelting"] then return end

--Main issue is when coke is needed for steel
if settings.startup["alloy-smelting-coke"].value then
    local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
    local _, entry = rubia_lib.compat.find_item_in_list(minable, "electric-furnace")
    entry.name = "electric-kiln"

    local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
    local _, entry = rubia_lib.compat.find_item_in_list(scrapapalooza, "electric-furnace")
    entry.name = "electric-kiln"

    --Need a recipe to make coke.
    data:extend({
        {
        type ="recipe",
        name ="rubia-compat-alloy-smelting-coke",
        category = "biorecycling",
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-a[alloy-smelt]",
        enabled = false,
        ingredients = {
            {type ="fluid", name ="rubia-bacterial-sludge", amount = 50},
        },
        surface_conditions = rubia.surface_conditions(),
        energy_required = 3,
        results = {
            {type ="item", name ="coke", amount = 1},
        },
        allow_productivity = true,
        crafting_machine_tint = {r=0.1,g=0.1,b=0.1,a=1},
        auto_recycle = false,
        },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", "rubia-compat-alloy-smelting-coke")
end
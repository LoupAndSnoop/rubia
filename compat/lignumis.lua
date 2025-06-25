--Data stage compat for wood logistics.
if not mods["lignumis"] then return end

local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(minable, 
    {type = "item", name = "long-handed-inserter", 
        probability = 0.15, amount_min = 15, amount_max = 30})
local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
table.insert(scrapapalooza, 
    {type = "item", name = "long-handed-inserter", probability = 0.1, amount = 1})


--If Lignumis complicates the circuit recipe, I need to bring it back.
if settings.startup["lignumis-circuit-progression"].value then
    data:extend({
    {
        type = "recipe",
        name = "rubia-compat-electronic-circuit",
        localised_name = {"item-name.electronic-circuit"},
        category = "electronics",
        surface_conditions = rubia.surface_conditions(),
        ingredients =
        {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "item", name = "copper-cable", amount = 3}
        },
        results = {{type="item", name="electronic-circuit", amount=1}},
        enabled = false,
        allow_productivity = true,
        auto_recycle = false,
    },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", "rubia-compat-electronic-circuit")
end
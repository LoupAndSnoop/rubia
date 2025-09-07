--Data stage compat for wood logistics.
if not mods["wood-logistics"] then return end

local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(minable, rubia_lib.tech_cost_scale(
    {type = "item", name = "long-handed-inserter", 
        probability = 0.15, amount_min = 15, amount_max = 30}, true))
local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
table.insert(scrapapalooza, 
    {type = "item", name = "long-handed-inserter", probability = 0.1, amount = 1})
table.insert(scrapapalooza, 
    {type = "item", name = "repair-pack", probability = 0.03, amount = 1})
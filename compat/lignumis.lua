--Data stage compat for wood logistics.
if not mods["lignumis"] then return end

local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(minable, 
    {type = "item", name = "long-handed-inserter", 
        probability = 0.15, amount_min = 15, amount_max = 30})
local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
table.insert(scrapapalooza, 
    {type = "item", name = "long-handed-inserter", probability = 0.1, amount = 1})
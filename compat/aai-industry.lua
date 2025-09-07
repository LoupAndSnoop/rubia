
if not mods["aai-industry"] then return end

---AAI industries changes green circuit recipe
local common_compat_prototypess = require("__rubia__.compat.common-compat-prototypes")
local green_circ = common_compat_prototypess["electronic-circuit-recipe"]
data:extend({green_circ})
rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1", green_circ.name)


--Chemical plant needs glass and stone brick. This must come from forage/scrapapalooza
local minable = data.raw["simple-entity"]["rubia-spidertron-remnants"].minable.results
table.insert(minable, 
    rubia_lib.tech_cost_scale(
        {type = "item", name = "chemical-plant", probability = 0.4, amount_min = 1, amount_max = 3}))
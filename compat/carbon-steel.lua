if not mods["carbon-steel"] then return end

--Cases where we don't need the recipe, because we already have compat
if mods["Krastorio2-spaced-out"] then return end

local common_compat_prototypes = require("__rubia__.compat.common-compat-prototypes")
local steel_plate = common_compat_prototypes["steel-plate-recipe"]
data:extend({steel_plate})
rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", steel_plate.name)
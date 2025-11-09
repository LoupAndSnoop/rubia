--This file tries to add the Rubia steel compat recipe for several smaller mods that change steel.

local carbon_steel_mods = {"carbon-steel", "SpaceAgeOverhaul"}
local mod_present = false
for _, entry in pairs(carbon_steel_mods) do
    mod_present = mod_present or (not not mods[entry])
end
if not mod_present then return end

--Cases where we don't need the recipe, because we already have compat
if mods["Krastorio2-spaced-out"] then return end

local common_compat_prototypes = require("__rubia__.compat.common-compat-prototypes")
local steel_plate = common_compat_prototypes["steel-plate-recipe"]
data:extend({steel_plate})
rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B", steel_plate.name)

--Overhauls with weird furnace recipe-category nonsense.
if mods["SpaceAgeOverhaul"] then steel_plate.additional_categories = {"advanced-smelting"} end

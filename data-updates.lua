
require("__rubia__.lib.lib")
require("__rubia__.prototypes.planet.surface-conditions")
require("__rubia__.prototypes.technology-updates")
require("__rubia__.prototypes.machine-upgrade-technologies")
local entity_swaps = require("__rubia__.prototypes.entity.simple-entity-swaps")
entity_swaps.make_auto_generated_prototypes()
require("__rubia__.prototypes.faux-quality-tooltips")


--Edits to vanilla recipes
--Make biofusion science possible
local bacteria_recipe = data.raw.recipe["iron-bacteria-cultivation"]
if bacteria_recipe then bacteria_recipe.surface_conditions = nil end


--------
---Other mods add surface properties
if data.raw["surface-property"].temperature then
  data.raw.planet.rubia.surface_properties["temperature"] = 324
end
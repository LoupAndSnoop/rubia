--Function to check all globals degined by Rubia during data stage.
--_G.all_globals = {}; for n in pairs(_G) do all_globals[n] = true end

_G.rubia = require("__rubia__.lib.constants") -- Global var to query for global constants
require("__rubia__.lib.lib")

require("__rubia__.prototypes.particles")
require("__rubia__.prototypes.sound-effects")
require("__rubia__.prototypes.factoriopedia-simulations")

require("__rubia__.prototypes.item-groups")
require("__rubia__.prototypes.item")
require("__rubia__.prototypes.recipe-category")
require("__rubia__.prototypes.recipe")
require("__rubia__.prototypes.technology")
require("__rubia__.prototypes.technology-hider-data")

require("__rubia__.prototypes.entity.resources")
require("__rubia__.prototypes.entity.wind-turbine")
require("__rubia__.prototypes.entity.garbo-grabber")
require("__rubia__.prototypes.entity.biorecycling-plant")
require("__rubia__.prototypes.entity.trashsteroids")
require("__rubia__.prototypes.entity.long-bulk-inserter")
require("__rubia__.prototypes.entity.long-stack-inserter")
require("__rubia__.prototypes.entity.sniper-turret")
require("__rubia__.prototypes.entity.crapapult")
require("__rubia__.prototypes.entity.simple-entity-swaps")

require("__rubia__.prototypes.entity.armored-trains")
require("__rubia__.prototypes.entity.craptonite-wall")
require("__rubia__.prototypes.entity.efficiency-module-4")

require("__rubia__.prototypes.planet.rubia-decoratives")
require("__rubia__.prototypes.planet.rubia-surface-traps")
require("__rubia__.prototypes.planet.rubia-map-gen")
require("__rubia__.prototypes.planet.planet")
require("__rubia__.prototypes.planet.procession-catalogue-rubia")
require("__rubia__.prototypes.planet.rubia-expressions")
require("__rubia__.prototypes.ambient-sounds")
require("__rubia__.prototypes.achievements")
require("__rubia__.prototypes.tips-and-tricks")

--Late stage data updates for compat.
require("__rubia__.prototypes.entity.rocketizer-merge")
require("__rubia__.compat.blueprint-shotgun")
require("__rubia__.compat.wood-logistics")
require("__rubia__.compat.lignumis")
require("__rubia__.compat.alloy-smelting")
require("__rubia__.compat.bz-mods")
require("__rubia__.compat.resource-spawner-overhaul")
require("__rubia__.compat.krastorio2-so")
require("__rubia__.compat.aai-industry")
require("__rubia__.compat.crushing-industry")

require("__rubia__.prototypes.data-script.recycling-fixes")


--log("All globals defined by Rubia:")
--for n in pairs(_G) do if not all_globals[n] then log(n) end end
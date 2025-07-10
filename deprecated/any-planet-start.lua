
if not mods["any-planet-start"] then return end

--[[
if mods["any-planet-start"] and APS then APS.add_planet{name = "rubia",
    filename = "__rubia__/compat/any-planet-start",
    technology = "planet-discovery-rubia"}
end]]


local utils = require("__any-planet-start__.utils")


data.raw.technology["electronics"].unit = nil
data.raw.technology["electronics"].research_trigger = {type = "mine-entity", entity="rubia-junk-pile"}


data:extend({
{
    type = "technology",
    name = "rubia-progression-stage1-compat-aps",
    icon = "__rubia__/graphics/planet/rubia.png",
    icon_size = 256,
    essential = true,
    effects = {
        {type = "unlock-recipe", recipe = "medium-electric-pole"},
        {type = "unlock-recipe", recipe = "pipe"},
        {type = "unlock-recipe", recipe = "pipe-to-ground"},
        {type = "unlock-recipe", recipe = "pumpjack"},
        {type = "unlock-recipe", recipe = "chemical-plant"},
    },
    prerequisites = {"electronics"},--{ "rubia-progression-stage1"},
    research_trigger = {type = "mine-entity", entity="rubia-junk-pile"},
},
})


--Locomotive
--utils.add_prerequisites("foundry", {"concrete", "lubricant"})



utils.set_prerequisites("steel-processing", nil)
utils.set_prerequisites("automation", {"electronics"})
utils.set_prerequisites("solar-energy", {"steel-processing", "electronics"})
utils.set_prerequisites("automation-science-pack", {"solar-energy"})
utils.set_prerequisites("steam-power", {"calcite-processing", "automation-science-pack"})
utils.set_prerequisites("oil-gathering", {"steel-processing", "electronics"})
utils.set_prerequisites("lubricant", {"oil-processing"})
utils.set_prerequisites("calcite-processing", {"oil-gathering"})
utils.set_prerequisites("sulfur-processing", {"oil-processing", "calcite-processing"})
utils.set_prerequisites("concrete", {"calcite-processing", "automation-2"})
utils.set_prerequisites("automation-2", {"automation", "automation-science-pack"})

utils.add_prerequisites("foundry", {"concrete", "lubricant"})
utils.add_prerequisites("big-mining-drill", {"advanced-circuit", "electric-engine"})
utils.add_prerequisites("flammables", {"logistic-science-pack"})
utils.add_prerequisites("sulfur-processing", {"logistic-science-pack"})
utils.add_prerequisites("plastics", {"logistic-science-pack"})
utils.add_prerequisites("research-speed-1", {"logistic-science-pack"})
utils.add_prerequisites("electric-engine", {"chemical-science-pack"})
utils.add_prerequisites("chemical-science-pack", {"engine"})

utils.remove_recipes("oil-processing", {"chemical-plant", "basic-oil-processing", "solid-fuel-from-petroleum-gas"})
utils.add_recipes("oil-processing", {"simple-coal-liquefaction", "heavy-oil-cracking", "light-oil-cracking"})
utils.remove_recipes("advanced-oil-processing", {"advanced-oil-processing", "heavy-oil-cracking", "light-oil-cracking"})
utils.add_recipes("advanced-oil-processing", {"solid-fuel-from-petroleum-gas"})

utils.add_recipes("solar-energy", {"medium-electric-pole", "iron-stick"})
utils.add_recipes("oil-gathering", {"pipe", "pipe-to-ground"})
utils.add_recipes("planet-discovery-nauvis", {"basic-oil-processing", "advanced-oil-processing"})
utils.add_recipes("low-density-structure", {"casting-low-density-structure"})

utils.insert_recipe("calcite-processing", "chemical-plant", 1)
utils.insert_recipe("foundry", "offshore-pump", 2)

utils.remove_recipes("electric-energy-distribution-1", {"medium-electric-pole"})
utils.remove_recipes("calcite-processing", {"simple-coal-liquefaction"})
utils.remove_recipes("concrete", {"iron-stick"})
utils.remove_recipes("railway", {"iron-stick"})
utils.remove_recipes("circuit-network", {"iron-stick"})
utils.remove_recipes("electric-energy-distribution-1", {"iron-stick"})
utils.remove_recipes("steam-power", {"offshore-pump", "pipe", "pipe-to-ground"})

utils.remove_packs("artillery", {"space-science-pack"})
utils.remove_packs("cliff-explosives", {"space-science-pack"})
utils.remove_packs("coal-liquefaction", {"space-science-pack"})
utils.remove_packs("turbo-transport-belt", {"space-science-pack"})

utils.set_trigger("automation", {type = "craft-item", item = "iron-plate", count = 50})
utils.set_trigger("steel-processing", {type = "craft-item", item = "iron-plate", count = 10})
utils.set_trigger("oil-gathering", {type = "craft-item", item = "steel-plate", count = 5})
utils.set_trigger("solar-energy", {type = "craft-item", item = "electronic-circuit", count = 15})
utils.set_trigger("oil-processing", {type = "mine-entity", entity = "sulfuric-acid-geyser"})
utils.set_trigger("lubricant", {type = "craft-fluid", fluid = "heavy-oil"})

utils.set_packs("steam-power", {"automation-science-pack"}, 25, 10)
utils.set_packs("automation-2", {"automation-science-pack"}, 15, 10)
utils.set_packs("concrete", {"automation-science-pack"}, 25, 15)

utils.ignore_multiplier("automation-2")
utils.ignore_multiplier("concrete")

local multiplier = settings.startup["aps-vulcanus-rock-multiplier"].value
if multiplier == 1 then return end
---@param results data.ProductPrototype[]
local function multiply_results(results)
    for _, item in pairs(results) do
        if item.amount then
            item.amount = item.amount * multiplier
        else
            local average = (item.amount_max + item.amount_min) / 2
            local range = average - item.amount_min
            average = average * multiplier
            item.amount_min = math.floor(average - range)
            item.amount_max = math.floor(average + range)
        end
    end
end

multiply_results(data.raw["simple-entity"]["big-volcanic-rock"].minable.results)
multiply_results(data.raw["simple-entity"]["huge-volcanic-rock"].minable.results)
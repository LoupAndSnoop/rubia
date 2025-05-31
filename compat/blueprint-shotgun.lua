--Compatibility for blueprint shotgun, because you can't craft it on Rubia.
if not mods["blueprint-shotgun"] then return end


data:extend({
{
    type = "recipe",
    name = "rubia-item-canister",
    localised_name = {"",{"item-name.item-canister"}," (",{"space-location-name.rubia"},")"},
    localised_description = {"recipe-description.item-canister"},
    category = "advanced-crafting",
    results = {{type = "item", name = "item-canister", amount = 1}},
    ingredients = {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "item", name = "copper-cable", amount = 2},
        {type = "item", name = "iron-stick", amount = 3},
    },
    surface_conditions = rubia.surface_conditions(),
    enabled = false,
    subgroup = "ammo",
}}) --[[@as data.RecipePrototype[] ]]

--We are always on a no-wood mode.
data.raw.recipe["blueprint-shotgun"].ingredients = {
        {type = "item", name = "iron-plate", amount = 15},
        {type = "item", name = "copper-cable", amount = 10},
        {type = "item", name = "electronic-circuit", amount = 5},
        {type = "item", name = "iron-gear-wheel", amount = 15},
    }

data:extend{{
    type = "technology",
    name = "rubia-blueprint-shotgun",
    localised_name = {"technology-name.blueprint-shotgun"},
    localised_description = {"technology-description.blueprint-shotgun"},
    icon = "__blueprint-shotgun__/graphics/blueprint-shotgun.png",
    icon_size = 64,
    effects = {
        {type = "unlock-recipe", recipe = "blueprint-shotgun",},
        {type = "unlock-recipe", recipe = "rubia-item-canister",
    },},
    research_trigger = {type = "mine-entity", entity="rubia-junk-pile"},
    prerequisites = {"rubia-progression-stage1"},
}} --[[@as data.TechnologyPrototype[] ]]



--[[
if not settings.startup["blueprint-shotgun-no-wood"].value then
    data:extend{{
        type = "recipe",
        name = "rubia-blueprint-shotgun",
        energy_required = 10,
        results = {{type = "item", name = "blueprint-shotgun", amount = 1}},
        ingredients = {
            {type = "item", name = "iron-plate", amount = 15},
            {type = "item", name = "copper-cable", amount = 10},
            {type = "item", name = "electronic-circuit", amount = 5},
            {type = "item", name = "iron-gear-wheel", amount = 15},
        },
        enabled = false,
        subgroup = "gun",
    }
    }
end]]
--Compatibility for blueprint shotgun, because you can't craft it on Rubia.
if not mods["blueprint-shotgun"] then return end

--Rubia versions to craft whenever.
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


local function on_data_updates()
    --We are always on a no-wood mode.
    data.raw.recipe["blueprint-shotgun"].ingredients = {
            {type = "item", name = "iron-plate", amount = 15},
            {type = "item", name = "copper-cable", amount = 10},
            {type = "item", name = "electronic-circuit", amount = 5},
            {type = "item", name = "iron-gear-wheel", amount = 15},
        }

    --Rubia icons
    local item_cannister_recipe = data.raw.recipe["rubia-item-canister"]
    item_cannister_recipe.icons = rubia_lib.compat.make_rubia_superscripted_icon(item_cannister_recipe)
end
table.insert(rubia_lib.compat.to_call_on_data_updates, on_data_updates)

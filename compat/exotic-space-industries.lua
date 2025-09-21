
if not mods["exotic-space-industries"] then return end
--[[Things we need
We need this basically everywhere
ei-copper-mechanical-parts

]]

--Need ei-copper-mechanical-parts early, for electric poles and misc
local junk = data.raw["simple-entity"]["rubia-junk-pile"].minable.results
table.insert(junk, {type = "item", name = "ei-copper-mechanical-parts", 
    probability = 0.4, amount_min = 5, amount_max = 20})

--Add an early recipe to make the parts.
data:extend({
      {
    type ="recipe",
    name = "rubia-compat-esi-copper-mech-parts",
    icons = rubia_lib.compat.make_rubia_superscripted_icon(
        {icon ="__exotic-space-industries-graphics-1__/graphics/items/copper-mechanical-parts.png",
        icon_size = 64}),
    category ="biorecycling",
    enabled = false,
    subgroup = "rubia-biorecycling", order = "c[rubia stage1]-b-b",

    ingredients = {
      {type ="item", name ="rubia-bacteria-A", amount = 1},
      {type ="item", name ="rubia-ferric-scrap", amount = 2},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 3,
    results = {
      {type ="item", name ="firearm-magazine", amount = 2},
      {type ="item", name ="ei-copper-mechanical-parts", amount = 3},
    },
    allow_productivity = true,
    crafting_machine_tint = data.raw.recipe["biorecycle-bacteria-A-ferric-scrap"].crafting_machine_tint,
  },
})

rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage1B",
    "rubia-compat-esi-copper-mech-parts")
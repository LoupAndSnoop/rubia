require "__rubia__.lib.lib"

local seconds = 60
local minutes = 60*seconds

--Machine tints. Primarily have 3 main colors: red, blue, and brown TODO
local crafting_machine_tint_brown = {
          primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
          secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
          tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
          quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000} --rgb(255, 136, 0)
}
local red_mult, blue_mult, purple_mult =4,4, 4
local crafting_machine_tint_red = {
  primary = {r = 1, g = 0.912/red_mult, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
  secondary = {r = 0.9, g = 0.797/red_mult, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
  tertiary = {r = 0.8, g = 0.635/red_mult, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
  quaternary = {r = 0.7, g = 0.804/red_mult, b = 0.000, a = 1.000} --rgb(255, 136, 0)
}
local crafting_machine_tint_blue = {
  primary = {r = 0.9/blue_mult, g = 0.912/blue_mult, b = 0.9, a = 1.000}, 
  secondary = {r = 0.9/blue_mult, g = 0.797/blue_mult, b = 0.8, a = 1.000}, 
  tertiary = {r = 0.8/blue_mult, g = 0.635/blue_mult, b = 0.8, a = 1.000},
  quaternary = {r = 0.7/blue_mult, g = 0.804/blue_mult, b = 0.7, a = 1.000}
}
local crafting_machine_tint_purple = {
  primary = {r = 1, g = 0.912/purple_mult, b = 1, a = 1.000}, 
  secondary = {r = 1, g = 0.797/purple_mult, b = 1, a = 1.000}, 
  tertiary = {r = 1, g = 0.635/purple_mult, b = 1, a = 1.000},
  quaternary = {r = 1, g = 0.804/purple_mult, b = 1, a = 1.000}
}

--Automatic recipe order for biorecycling. Append the relevant substring so all
--the recipes are together as needed.
--local function biorec_recipe_order(substring) return ""

--[[
--Modify the rocket silo to make it able to take the new rocket-part recipe.
for _, silo in pairs(data.raw["rocket-silo"]) do
  if silo.fixed_recipe == "rocket-part" then
      silo.fixed_recipe = nil
      silo.disabled_when_recipe_not_researched = true
      --silo.logistic_trash_inventory_size = 0; --This is a method to make entities with no logistic capability
  end
end]]

--Balance existing recipe(s)
--[[
data.raw.recipe["locomotive"].ingredients = { --Base = 30 steel, 20 eng, 10 circ
  {type ="item", name ="steel-plate", amount = 30},
  {type ="item", name ="engine-unit", amount = 20},
  {type ="fluid", name ="electronic-circuit", amount = 10}
}]]
for _, entry in pairs(data.raw.recipe["locomotive"].ingredients) do
  --Base = 30 steel, 20 eng, 10 circ
  if entry.name == "steel-plate" then entry.amount = 25; end 
  --if entry.name == "engine-unit" then entry.amount = 20; end
  if entry.name == "electronic-circuit" then entry.amount = 8; end
end


data:extend({
--#region Science
  {
    type ="recipe",
    name ="makeshift-biorecycling-science-pack",
    category ="biorecycling",
    enabled = false,

    ingredients = 
    {
      --{type ="item", name ="gun-turret", amount = 2},
      {type ="item", name ="rubia-wind-turbine", amount = 1},
      {type ="item", name ="biorecycling-plant", amount = 1},
      {type ="fluid", name ="rubia-bacterial-sludge", amount = 100}
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    results =
    {
      {type ="item", name ="makeshift-biorecycling-science-pack", amount = 2}
    },
    allow_productivity = true,
    main_product ="makeshift-biorecycling-science-pack",
    crafting_machine_tint = crafting_machine_tint_brown,
  },
  {
    type ="recipe",
    name ="ghetto-biorecycling-science-pack",
    category ="biorecycling",
    enabled = false,
    ingredients = 
    {
      {type ="item", name ="rocket-fuel", amount = 2},
      {type ="item", name ="advanced-circuit", amount = 1},
      {type ="item", name ="locomotive", amount = 1},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    results =
    {
      {type ="item", name ="ghetto-biorecycling-science-pack", amount = 4}
    },
    allow_productivity = true,
    main_product ="ghetto-biorecycling-science-pack",
    crafting_machine_tint = crafting_machine_tint_brown,
  },
  {
    type ="recipe",
    name ="biorecycling-science-pack",
    category ="biorecycling",
    enabled = false,
    ingredients = 
    {
      {type ="item", name ="craptonite-frame", amount = 4},
      {type ="item", name ="rubia-wind-turbine", amount = 2},
      {type ="item", name ="locomotive", amount = 1},
      {type ="fluid", name ="light-oil", amount = 5},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 20,
    results =
    {
      {type ="item", name ="biorecycling-science-pack", amount = 4},
      {type ="item", name ="craptonite-frame", amount = 3, ignored_by_productivity=3}
    },
    allow_productivity = true,
    main_product ="biorecycling-science-pack",
    crafting_machine_tint = crafting_machine_tint_brown,
  },
  {
    type ="recipe",
    name ="rubia-biofusion-science-pack",
    category ="organic",
    enabled = false,
    ingredients = 
    {
      {type ="item", name ="biter-egg", amount = 1},
      {type ="item", name ="iron-bacteria", amount = 1},
      {type ="fluid", name ="rubia-froth", amount = 400},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 15,
    results =
    {
      {type ="item", name ="rubia-biofusion-science-pack", amount = 1},
    },
    allow_productivity = true,
    main_product ="rubia-biofusion-science-pack",
    result_is_always_fresh = true,
    crafting_machine_tint = crafting_machine_tint_brown,
  },

  --[[Science yeeting
  {
    type = "recipe",
    name = "yeet-makeshift-biorecycling-science-pack",
    category = "crapapult",
    enabled = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = "makeshift-biorecycling-science-pack", amount = 1 }},
    results = {{ type = "item", name = "yeet-makeshift-biorecycling-science-pack", amount = 1 }},
    icon = "__rubia-assets__/graphics/icons/science/yeet_torus_clear_brown.png",
    icon_size = 64,
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "recipe",
    name = "yeet-ghetto-biorecycling-science-pack",
    icon = "__rubia-assets__/graphics/icons/science/yeet_sphere_tubed_clear_brown.png",
    icon_size = 64,
    category = "crapapult",
    enabled = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = "ghetto-biorecycling-science-pack", amount = 1 }},
    results = {{ type = "item", name = "yeet-ghetto-biorecycling-science-pack", amount = 1 }},
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "recipe",
    name = "yeet-biorecycling-science-pack",
    icon = "__rubia-assets__/graphics/icons/science/yeet_sphere_spiked_clear_brown.png",
    icon_size = 64,
    category = "crapapult",
    enabled = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = "biorecycling-science-pack", amount = 1 }},
    results = {{ type = "item", name = "yeet-biorecycling-science-pack", amount = 1 }},
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "recipe",
    name = "yeet-spoilage",
    icon = "__rubia-assets__/graphics/icons/science/yeet-spoilage.png",
    icon_size = 64,
    category = "crapapult",
    enabled = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = "spoilage", amount = 1 }},
    results = {{ type = "item", name = "yeet-spoilage", amount = 1 }},
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "recipe",
    name = "yeet-gun-turret",
    icon = "__rubia-assets__/graphics/icons/science/yeet-gun-turret.png",
    icon_size = 64,
    category = "crapapult",
    enabled = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = "gun-turret", amount = 1 }},
    results = {{ type = "item", name = "yeet-gun-turret", amount = 1 }},
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  --]]

  --#endregion
--#region Biorecycling Stage 1- Early Rubia

  {
    type ="recipe",
    name ="rubia-bacteria-A",
    category = "chemical-plant-only",
    additional_categories = {"cryogenics"},
    subgroup = "rubia-biorecycling", order = "c[rubia stage1]-a",
    enabled = false,
    ingredients = {
      {type ="fluid", name ="rubia-bacterial-sludge", amount = 20},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 1,
    results = {
      {type ="item", name ="rubia-bacteria-A", amount = 10},
    },
    allow_productivity = true,
    main_product ="rubia-bacteria-A",
    crafting_machine_tint = crafting_machine_tint_red,
  },
  {
    type ="recipe",
    name ="biorecycle-bacteria-A-ferric-scrap",
    icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-yellow-ammo+copper-cable.png",--bacteria-A+firearm-magazine.png",--"scrap-blue+bacteria-A.png",
    category ="biorecycling",
    enabled = false,
    subgroup = "rubia-biorecycling", order = "c[rubia stage1]-b",

    ingredients = {--Was 1:2=>6:2 at 3 energy. Now nerfed to 25% less copper
      {type ="item", name ="rubia-bacteria-A", amount = 2},
      {type ="item", name ="rubia-ferric-scrap", amount = 4},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 6,
    results = {
      {type ="item", name ="firearm-magazine", amount = 12},
      {type ="item", name ="copper-cable", amount = 3},
    },
    allow_productivity = true,
    crafting_machine_tint = crafting_machine_tint_red,
  },
  {
    type ="recipe",
    name ="biorecycle-bacteria-A-firearm-magazine",
    icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-iron-plate+bacteriaA.png",--"bacteria-A+firearm-magazine.png",
    category ="biorecycling",
    subgroup = "rubia-biorecycling", order = "c[rubia stage1]-c",
    enabled = false,
    ingredients = {
      {type ="item", name ="rubia-bacteria-A", amount = 2},
      {type ="item", name ="firearm-magazine", amount = 3},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 3 * 0.6 *1.5,
    results = {
      {type ="item", name ="iron-plate", amount = 2},
    },
    allow_productivity = true,
    crafting_machine_tint = crafting_machine_tint_red,
  },

--#endregion
--#region Biorecycling Stage 2- Midgame

{
  type ="recipe",
  name ="rubia-bacteria-B",
  category = "chemical-plant-only",
  additional_categories = {"cryogenics"},
  subgroup = "rubia-biorecycling", order = "d[rubia stage2]-a",
  enabled = false,
  ingredients = {
    {type ="fluid", name ="rubia-bacterial-sludge", amount = 50},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 3,
  results = {
    {type ="item", name ="rubia-bacteria-B", amount = 3},
  },
  allow_productivity = true,
  main_product ="rubia-bacteria-B",
  crafting_machine_tint = crafting_machine_tint_blue,
},

{
  type ="recipe",
  name ="biorecycle-bacteria-B-cupric-scrap",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-red-ammo+rail.png",--"scrap-red+bacteria-B.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "d[rubia stage2]-b",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 2},
    {type ="item", name ="rubia-cupric-scrap", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 3,
  results = {
    {type ="item", name ="rail", amount = 4},
    --{type ="item", name ="fast-transport-belt", amount = 2}, --TODO: Figure out?
    {type ="item", name ="piercing-rounds-magazine", amount = 2},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_blue,
},

{
  type ="recipe",
  name ="biorecycle-bacteria-A-cupric-scrap",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-processing-unit+engine.png",--"scrap-red+bacteria-A.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-c",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 5},
    {type ="item", name ="rubia-cupric-scrap", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 2.5,
  results = {
    {type ="item", name ="engine-unit", amount = 3},
    {type ="item", name ="processing-unit", amount = 5},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_red,
},

{
  type ="recipe",
  name ="biorecycle-bacteria-A-engine",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-engine+gear.png",--"bacteria-A+engine.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "d[rubia stage2]-c",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="engine-unit", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 5,
  results = {
    {type ="item", name ="steel-plate", amount = 3},
    {type ="item", name ="iron-gear-wheel", amount = 1},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_red,
},
{
  type ="recipe",
  name ="biorecycle-bacteria-B-processing-unit",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-advanced-circuit+light-oil.png",--"bacteria-B+blue-circ.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "d[rubia stage2]-d",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 3},
    {type ="item", name ="processing-unit",  amount = 3},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 4,
  results = {
    {type ="item", name ="advanced-circuit", amount = 1},
    {type ="fluid", name ="light-oil", amount = 25},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_blue,
},

--#endregion
--#region Biorecycling Stage 3- Final strech before clear
--[[{
  type ="recipe",
  name ="biorecycle-bacteria-AB-ferric-scrap",
  icon = "__rubia-assets__/graphics/icons/recipes/scrap-blue+bacteria-both.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-c",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="rubia-bacteria-B", amount = 2},
    {type ="item", name ="rubia-ferric-scrap", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 3,
  results = {
    {type ="item", name ="rail", amount = 4},
    --{type ="item", name ="fast-transport-belt", amount = 2}, --TODO: Figure out?
    {type ="item", name ="piercing-rounds-magazine", amount = 2},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_purple,
},]]
{
  type ="recipe",
  name ="biorecycle-bacteria-B-rail",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-steel+concrete.png",--"bacteria-B+rail.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-d",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 1},
    {type ="item", name ="rail", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 3,
  results = {
    {type ="item", name ="concrete", amount = 4},
    {type ="item", name ="steel-plate", amount = 1},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_purple,
},

--#endregion
--#region Biorecycling Stage 3B -Craptonite
{
  type ="recipe",
  name ="assisted-frothing",
  category = "biorecycling",
  additional_categories = {"organic"},
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-k",
  enabled = false,
  ingredients = {
    {type ="item", name ="craptonite-chunk", amount = 1},
    {type ="fluid", name ="rubia-bacterial-sludge", amount = 100},
    {type ="fluid", name ="light-oil", amount = 25},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 8,
  results = {
    {type ="fluid", name ="rubia-froth", amount = 100},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_brown,
},
{
  type ="recipe",
  name ="craptonite-casting",
  category = "organic-or-assembling",--"biorecycling",
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-l",
  enabled = false,
  ingredients = {
    {type ="item", name ="concrete", amount = 20},
    {type ="fluid", name ="rubia-froth", amount = 200},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 6,
  results = {
    {type ="item", name ="craptonite-frame", amount = 1},
    {type ="item", name ="concrete", amount = 10, ignored_by_productivity=10},
  },
  main_product = "craptonite-frame",
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_brown,
},

{
  type ="recipe",
  name ="biorecycle-bacteria-AB-elec-engine",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-elec-engine+copper.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "e[rubia stage3]-e",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="rubia-bacteria-B", amount = 3},
    {type ="item", name ="engine-unit", amount = 3},
    {type ="item", name ="processing-unit", amount = 5},
    {type ="item", name ="firearm-magazine", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 5,
  results = {
    {type ="item", name ="electric-engine-unit", amount = 1},
    {type ="item", name ="copper-plate", amount = 4},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_purple,
},
{
  type = "recipe",
  name ="rocket-part-rubia",
  energy_required = 3,
  surface_conditions = rubia.surface_conditions(),
  enabled = false,
  hide_from_player_crafting = true,
  auto_recycle = false,
  category = "rocket-building",
  ingredients =
  {
    {type = "item", name = "advanced-circuit", amount = 1},
    {type = "item", name = "craptonite-frame", amount = 1},
    {type = "item", name = "rocket-fuel", amount = 1}
  },
  results = {{type="item", name="rocket-part", amount=1}},
  allow_productivity = true
},

--#endregion
--#region Biorecycling Stage 4- Post clear
{
  type = "recipe",
  name = "rubia-nutrients-from-sludge",
  icon = "__rubia-assets__/graphics/icons/sludge-to-nutrients.png",
  icon_size = 64,
  subgroup = "agriculture-processes",
  order = "c[nutrients]-a[nutrients-from-spoilage]-b",
  category = "organic",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  ingredients = {
      { type = "fluid", name = "rubia-bacterial-sludge", amount = 20}, 
  },
  results = {{type = "item", name = "nutrients", amount = 1, percent_spoiled=0.5}},
  allow_productivity = true,
},


--#endregion

--#region Pre-clear Entity Recipes
  
  {
    type = "recipe",
    name = "biorecycling-plant",
    icon = "__rubia-assets__/graphics/icons/biorecycling-plant.png",
    icon_size = 64,
    --subgroup = "production-machine",
    --order = "c[assembling-machine-3]-ag[rubia]-a",
    category = "crafting",
    enabled = false,
    surface_conditions = rubia.surface_conditions(),
    energy_required = 6,
    ingredients = {
        { type = "item", name = "electronic-circuit", amount = 10}, 
        { type = "item", name = "steel-plate", amount = 8}, 
        { type = "item", name = "iron-gear-wheel", amount = 12}, 
    },
    results = {{
        type = "item", name = "biorecycling-plant", amount = 1
    }},
    allow_productivity = false,
},
{
  type = "recipe",
  name = "garbo-grabber",
  icon = "__rubia-assets__/graphics/icons/garbo-grabber.png",
  icon_size = 64,
  --subgroup = "production-machine",
  --order = "c[assembling-machine-3]-ag[rubia]-c",
  localised_description = {"item-description.garbo-grabber"},
  category = "crafting",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  ingredients = {
      { type = "item", name = "concrete", amount = 50},
      { type = "item", name = "advanced-circuit", amount = 30}, 
      { type = "item", name = "steel-plate", amount = 40}, 
      { type = "item", name = "gun-turret", amount = 1}, 
  },
  results = {{
      type = "item", name = "garbo-grabber", amount = 1
  }},
  allow_productivity = false,
},
{
  type = "recipe",
  name = "crapapult",
  icon = "__rubia-assets__/graphics/icons/crapapult-icon.png",
  icon_size = 64,
  --subgroup = "production-machine",
  --order = "c[assembling-machine-3]-ag[rubia]-b",
  category = "crafting",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 7,
  ingredients = {
      { type = "item", name = "copper-cable", amount = 50},
      { type = "item", name = "steel-plate", amount = 40}, 
      { type = "item", name = "gun-turret", amount = 1}, 
  },
  results = {{
      type = "item", name = "crapapult", amount = 1
  }},
  allow_productivity = false,
},
{
  type = "recipe",
  name = "rubia-sniper-turret",
  icon = "__rubia-assets__/graphics/icons/sniper-turret-icon.png",
  icon_size = 64,
  subgroup = "defensive-structure",
  --order = "b[turret]-a[gun-turret]-b",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  ingredients = {
        {type = "item", name = "processing-unit", amount = 20},
        {type = "item", name = "steel-plate", amount = 10},
        {type = "item", name = "gun-turret", amount = 1},
  },
  results = {{
      type = "item", name = "rubia-sniper-turret", amount = 1
  }},
  allow_productivity = false,
},

{
  type = "recipe",
  name = "rubia-wind-turbine",
  energy_required = 8,
  ingredients = {
      {type = "item", name = "iron-plate",      amount = 8},
      {type = "item", name = "iron-gear-wheel", amount = 5},
      {type = "item", name = "copper-cable",    amount = 6}
  },
  results = {
      {type = "item", name = "rubia-wind-turbine",      amount = 1}
  },

  main_product = "rubia-wind-turbine",
  category ="crafting",
  allow_productivity = false,
  allow_quality = true,
  enabled = false,
  surface_conditions = rubia.surface_conditions()
},

{
  type = "recipe",
  name = "rubia-armored-locomotive",
  energy_required = 10,
  ingredients = {
      {type = "item", name = "engine-unit",      amount = 20},
      {type = "item", name = "craptonite-frame", amount = 10},
      {type = "item", name = "advanced-circuit", amount = 10},
      {type = "item", name = "locomotive",       amount = 1}
  },
  results = {
      {type = "item", name = "rubia-armored-locomotive",      amount = 1}
  },

  main_product = "rubia-armored-locomotive",
  category ="advanced-crafting",
  allow_productivity = false,
  allow_quality = true,
  enabled = false,
  surface_conditions = rubia.surface_conditions()
},
{
  type = "recipe",
  name = "rubia-armored-cargo-wagon",
  category ="advanced-crafting",
  energy_required = 10,
  ingredients = {
      {type = "item", name = "craptonite-frame", amount = 10},
      {type = "item", name = "steel-plate",           amount = 10},
      {type = "item", name = "cargo-wagon",       amount = 1}
  },
  results = {
      {type = "item", name = "rubia-armored-cargo-wagon",      amount = 1}
  },

  main_product = "rubia-armored-cargo-wagon",
  allow_productivity = false,
  allow_quality = true,
  enabled = false,
  surface_conditions = rubia.surface_conditions()
},
{
  type = "recipe",
  name = "rubia-armored-fluid-wagon",
  category ="advanced-crafting",
  energy_required = 10,
  ingredients = {
      {type = "item", name = "craptonite-frame", amount = 10},
      {type = "item", name = "steel-plate",      amount = 10},
      {type = "item", name = "fluid-wagon",      amount = 1}
  },
  results = {
      {type = "item", name = "rubia-armored-fluid-wagon",      amount = 1}
  },

  main_product = "rubia-armored-fluid-wagon",
  allow_productivity = false,
  allow_quality = true,
  enabled = false,
  surface_conditions = rubia.surface_conditions()
},
{
	type = "recipe",
	name = "rubia-rci-rocketizer",
  category = "crafting",
  localised_description = {"entity-description.rci-rocketizer"},
	enabled = false,
  energy_required = 2,
	ingredients = {
    {type = "item", name = "steel-chest", amount = 1},
    {type = "item", name = "advanced-circuit", amount = 1},
    {type = "item", name = "craptonite-frame", amount = 1},
  },
	results = {{type="item", name="rci-rocketizer", amount=1}},
  auto_recycle = false,
},


--#endregion

--#region Optional recipes
{
  type ="recipe",
  name ="biorecycle-scrapapalooza",
  icon = "__rubia-assets__/graphics/icons/scrapapalooza.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "d[rubia stage2]-e",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 5},
    {type ="item", name ="rubia-bacteria-B", amount = 5},
    {type ="item", name ="rubia-ferric-scrap", amount = 5},
    {type ="item", name ="rubia-cupric-scrap", amount = 5},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  results = {
    {type = "item", name = "gun-turret", probability=0.5, amount = 2},
    {type = "item", name = "electric-furnace", probability=0.1, amount = 1},
    {type = "item", name = "fast-inserter", probability = 0.1, amount = 1},
    {type = "item", name = "fast-transport-belt", probability = 0.15, amount = 8},
    {type = "item", name = "underground-belt", probability = 0.1, amount = 2},
    {type = "item", name = "express-splitter", probability = 0.1, amount = 1},
    {type = "item", name = "pipe-to-ground", probability = 0.1, amount = 2},
    {type = "item", name = "assembling-machine-2", probability = 0.1, amount = 1},
    {type = "item", name = "chemical-plant", probability = 0.2, amount = 1},
  },
  allow_productivity = false,
  --allow_quality = false,
  crafting_machine_tint = crafting_machine_tint_purple,
},

{
  type ="recipe",
  name ="biorecycle-bacteria-B-ferric-scrap",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-battery+lube.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "f[rubia stage4]-e",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 2},
    {type ="item", name ="rubia-ferric-scrap", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 5,
  results = {
    {type = "item", name = "battery", amount = 2},
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "fluid", name = "lubricant", amount = 10},
  },
  crafting_machine_tint = crafting_machine_tint_blue,
},

--[[
{
  type ="recipe",
  name ="biorecycle-XXXXX",
  icon = "__rubia-assets__/graphics/icons/recipes/biorecycling-iron-plate-to-green-circuit.png",
  category ="biorecycling",
  subgroup = "rubia-biorecycling", order = "f[rubia stage4]-e",--XXXXXX
  enabled = false,
  ingredients = {
    {type ="item", name ="piercing-rounds-magazine", amount = 2},
    {type ="item", name ="iron-plate", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 5,
  results = {
    {type = "item", name = "firearm-magazine", amount = 2, ignored_by_productivity = 2},
    {type = "item", name = "electronic-circuit", amount = 1},
  },
  allow_productivity = true,
  --crafting_machine_tint = crafting_machine_tint_red,
},]]


--#endregion

--#region Post-clear Rewards
  {
    type = "recipe",
    name = "rubia-long-bulk-inserter",
    category ="advanced-crafting",
    enabled = false,
    --surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    ingredients =
    {
      {type = "item", name = "long-handed-inserter", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "advanced-circuit", amount = 3},
      {type = "item", name = "craptonite-frame", amount = 4},
    },
    results = {{type="item", name="rubia-long-bulk-inserter", amount=1}},
    allow_productivity=false,
    crafting_machine_tint = crafting_machine_tint_brown,
  },
  {
    type = "recipe",
    name = "rubia-long-stack-inserter",
    category ="advanced-crafting",
    enabled = false,
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    ingredients = {
      {type = "item", name = "rubia-long-bulk-inserter", amount = 1},
      {type = "item", name = "carbon-fiber", amount = 2},
      {type = "item", name = "uranium-238", amount = 5},
      {type = "item", name = "processing-unit", amount = 5},
    },
    results = {{type="item", name="rubia-long-stack-inserter", amount=1}},
    allow_productivity=false,
    crafting_machine_tint = crafting_machine_tint_brown,
  },

  {
    type = "recipe",
    name = "craptonite-wall",
    category ="advanced-crafting",
    order = "z-a-a",
    enabled = false,
    --surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    ingredients =
    {
      {type = "item", name = "craptonite-frame", amount = 1},
      {type = "item", name = "concrete", amount = 20},
      {type = "item", name = "iron-stick", amount = 8},
    },
    results = {{type="item", name="craptonite-wall", amount=1}},
    crafting_machine_tint = crafting_machine_tint_brown,
    allow_productivity=false,
  },

  --[[
  {
    type = "recipe",
    name = "rubia-refined-concrete",
    energy_required = 15 * 2,
    enabled = false,
    category = "biorecycling",
    subgroup = "rubia-biorecycling", order = "f[rubia-stage4]-f",
    icons = rubia_lib.compat.make_rubia_superscripted_icon(
      {icon= "__base__/graphics/icons/refined-concrete.png"}),
    surface_conditions = rubia.surface_conditions(),
    ingredients =
    {
      {type = "item", name = "concrete", amount = 20},
      {type = "item", name = "iron-stick", amount = 8},
      {type = "item", name = "steel-plate", amount = 1},
      {type = "fluid", name = "rubia-bacterial-sludge", amount = 200}
    },
    results = {{type="item", name="refined-concrete", amount=10}},
    crafting_machine_tint = crafting_machine_tint_blue,
  },
]]
  {
    type = "recipe",
    name = "rubia-efficiency-module4",
    enabled = false,
    category ="electronics",
    ingredients =
    {
      {type = "item", name = "efficiency-module-3", amount = 4},
      {type = "item", name = "craptonite-frame", amount = 5},
      {type = "item", name = "processing-unit", amount = 5}
    },
    energy_required = 30,
    results = {{type="item", name="rubia-efficiency-module4", amount=1}},
    allow_productivity=false,
  },

  {
    type = "recipe",
    name = "rubia-holmium-craptalysis",
    icon = "__rubia-assets__/graphics/icons/recipes/holmium-craptalysis.png",
    subgroup = "fulgora-processes", order = "b[holmium]-b[holmium-solution]-b",
    localised_description = {"technology-description.rubia-holmium-craptalysis"},

    enabled = false,
    category ="organic-or-chemistry",
    ingredients =
    {
      {type = "item", name = "holmium-ore", amount = 2},
      {type = "item", name = "stone", amount = 2},
      {type = "item", name = "craptonite-frame", amount = 3},
      {type = "fluid", name = "water", amount = 20},     
    },
    energy_required = 10,
    results = {{type="fluid", name="holmium-solution", amount=250},
              {type = "item", name = "craptonite-frame", amount = 3, probability = 0.95, ignored_by_productivity=4}},
    allow_productivity = true,
    auto_recycle=false,
  },

--#endregion
})

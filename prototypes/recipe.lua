require "lib.lib"

local seconds = 60
local minutes = 60*seconds

--Machine tints. Primarily have 3 main colors: red, blue, and brown TODO
local crafting_machine_tint_brown = {
          primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
          secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
          tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
          quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000} --rgb(255, 136, 0)
}
local crafting_machine_tint_red = {
  primary = {r = 1, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
  secondary = {r = 1, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
  tertiary = {r = 1, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
  quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000} --rgb(255, 136, 0)
}
local crafting_machine_tint_blue = {
  primary = {r = 0.9, g = 0.912, b = 1, a = 1.000}, 
  secondary = {r = 0.9, g = 0.797, b = 1, a = 1.000}, 
  tertiary = {r = 0.8, g = 0.635, b = 1, a = 1.000},
  quaternary = {r = 0.7, g = 0.804, b = 1, a = 1.000}
}
local crafting_machine_tint_purple = {
  primary = {r = 1, g = 0.912, b = 1, a = 1.000}, 
  secondary = {r = 1, g = 0.797, b = 1, a = 1.000}, 
  tertiary = {r = 1, g = 0.635, b = 1, a = 1.000},
  quaternary = {r = 1, g = 0.804, b = 1, a = 1.000}
}

--Modify the rocket silo to make it able to take the new rocket-part recipe.
for _, silo in pairs(data.raw["rocket-silo"]) do
  if silo.fixed_recipe == "rocket-part" then
      silo.fixed_recipe = nil
      silo.disabled_when_recipe_not_researched = true
  end
end


data:extend({
--#region Science
  {
    type ="recipe",
    name ="makeshift-biorecycling-science-pack",
    category ="biorecycling",
    --icon ="__rubia__/graphics/icons/makeshift-biorecycling-science-pack.png",
    enabled = false,
    ingredients = 
    {
      {type ="item", name ="gun-turret", amount = 1},
      {type ="item", name ="electric-mining-drill", amount = 1},
      {type ="fluid", name ="rubia-bacterial-sludge", amount = 100}
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    results =
    {
      {type ="item", name ="makeshift-biorecycling-science-pack", amount = 1}
    },
    allow_productivity = true,
    main_product ="makeshift-biorecycling-science-pack",
    crafting_machine_tint = crafting_machine_tint_brown,
  },
  {
    type ="recipe",
    name ="ghetto-biorecycling-science-pack",
    category ="biorecycling",
    --icon ="__rubia__/graphics/icons/science/sphere_tubed_clear_brown.png",
    enabled = false,
    ingredients = 
    {
      {type ="item", name ="rocket-fuel", amount = 1},
      {type ="item", name ="locomotive", amount = 1},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    results =
    {
      {type ="item", name ="ghetto-biorecycling-science-pack", amount = 1}
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
      {type ="item", name ="gun-turret", amount = 1},
      {type ="item", name ="advanced-circuit", amount = 1}
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 15,
    results =
    {
      {type ="item", name ="biorecycling-science-pack", amount = 1},
      {type ="item", name ="craptonite-frame", amount = 3, ignored_by_productivity=3}
    },
    allow_productivity = true,
    main_product ="biorecycling-science-pack",
    crafting_machine_tint = crafting_machine_tint_brown,
  },


  --Science yeeting
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
    icon = "__rubia__/graphics/icons/science/yeet_torus_clear_brown.png",
    icon_size = 64,
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "recipe",
    name = "yeet-ghetto-biorecycling-science-pack",
    icon = "__rubia__/graphics/icons/science/yeet_sphere_tubed_clear_brown.png",
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
    icon = "__rubia__/graphics/icons/science/yeet_sphere_spiked_clear_brown.png",
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



  --#endregion
--#region Biorecycling Stage 1- Early Rubia

  {
    type ="recipe",
    name ="rubia-bacteria-A",
    category ="chemical-plant-only",
    enabled = false,
    ingredients = {
      {type ="fluid", name ="rubia-bacterial-sludge", amount = 30},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 1,
    results = {
      {type ="item", name ="rubia-bacteria-A", amount = 5},
    },
    allow_productivity = true,
    main_product ="rubia-bacteria-A",
    crafting_machine_tint = crafting_machine_tint_red,
  },
  {
    type ="recipe",
    name ="biorecycle-bacteria-A-ferric-scrap",
    icon = "__rubia__/graphics/icons/recipes/scrap-blue+bacteria-A.png",
    category ="biorecycling",
    enabled = false,
    ingredients = {
      {type ="item", name ="rubia-bacteria-A", amount = 2},
      {type ="item", name ="rubia-ferric-scrap", amount = 1},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 1,
    results = {
      {type ="item", name ="firearm-magazine", amount = 4},
      {type ="item", name ="copper-cable", amount = 1, probability=0.5},
    },
    allow_productivity = true,
    crafting_machine_tint = crafting_machine_tint_red,
  },
  {
    type ="recipe",
    name ="biorecycle-bacteria-A-firearm-magazine",
    icon = "__rubia__/graphics/icons/recipes/bacteria-A+firearm-magazine.png",
    category ="biorecycling",
    enabled = false,
    ingredients = {
      {type ="item", name ="rubia-bacteria-A", amount = 1},
      {type ="item", name ="firearm-magazine", amount = 2},
    },
    surface_conditions = rubia.surface_conditions(),
    energy_required = 1,
    results = {
      {type ="item", name ="iron-plate", amount = 1},
    },
    allow_productivity = true,
    crafting_machine_tint = crafting_machine_tint_red,
  },

--#endregion
--#region Biorecycling Stage 2- Midgame

{
  type ="recipe",
  name ="rubia-bacteria-B",
  category ="chemical-plant-only",
  enabled = false,
  ingredients = {
    {type ="fluid", name ="rubia-bacterial-sludge", amount = 50},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="rubia-bacteria-B", amount = 1},
  },
  allow_productivity = true,
  main_product ="rubia-bacteria-B",
  crafting_machine_tint = crafting_machine_tint_blue,
},
{
  type ="recipe",
  name ="biorecycle-bacteria-B-cupric-scrap",
  icon = "__rubia__/graphics/icons/recipes/scrap-red+bacteria-B.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 3},
    {type ="item", name ="rubia-cupric-scrap", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="engine-unit", amount = 4},
    {type ="item", name ="processing-unit", amount = 10},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_blue,
},
{
  type ="recipe",
  name ="biorecycle-bacteria-A-engine",
  icon = "__rubia__/graphics/icons/recipes/bacteria-A+engine.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="engine-unit", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="steel-plate", amount = 4},
    {type ="item", name ="iron-gear-wheel", amount = 1},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_red,
},
{
  type ="recipe",
  name ="biorecycle-bacteria-B-processing-unit",
  icon = "__rubia__/graphics/icons/recipes/bacteria-B+blue-circ.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 2},
    {type ="item", name ="processing-unit", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="advanced-circuit", amount = 1},
    {type ="fluid", name ="light-oil", amount = 20},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_blue,
},

--#endregion
--#region Biorecycling Stage 3- Final strech before clear
{
  type ="recipe",
  name ="biorecycle-bacteria-AB-ferric-scrap",
  icon = "__rubia__/graphics/icons/recipes/scrap-blue+bacteria-both.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="rubia-bacteria-B", amount = 2},
    {type ="item", name ="rubia-ferric-scrap", amount = 1},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="rail", amount = 4},
    {type ="item", name ="fast-transport-belt", amount = 2}, --TODO: Figure out?
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_purple,
},
{
  type ="recipe",
  name ="biorecycle-bacteria-B-rail",
  icon = "__rubia__/graphics/icons/recipes/bacteria-B+rail.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-B", amount = 1},
    {type ="item", name ="rail", amount = 2},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="item", name ="concrete", amount = 3},
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
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="craptonite-chunk", amount = 1},
    {type ="fluid", name ="rubia-bacterial-sludge", amount = 50},
    {type ="fluid", name ="light-oil", amount = 30},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
  results = {
    {type ="fluid", name ="rubia-froth", amount = 10},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_brown,
},
{
  type ="recipe",
  name ="craptonite-casting",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="concrete", amount = 20},
    {type ="fluid", name ="rubia-froth", amount = 50},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 1,
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
  icon = "__rubia__/graphics/icons/recipes/bacteria-AB+elec-engine.png",
  category ="biorecycling",
  enabled = false,
  ingredients = {
    {type ="item", name ="rubia-bacteria-A", amount = 1},
    {type ="item", name ="rubia-bacteria-B", amount = 3},
    {type ="item", name ="engine-unit", amount = 2},
    {type ="item", name ="processing-unit", amount = 3},
  },
  surface_conditions = rubia.surface_conditions(),
  energy_required = 3,
  results = {
    {type ="item", name ="electric-engine-unit", amount = 1},
    {type ="item", name ="copper-cable", amount = 4},
  },
  allow_productivity = true,
  crafting_machine_tint = crafting_machine_tint_red,
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
    {type = "item", name = "processing-unit", amount = 1},
    {type = "item", name = "craptonite-frame", amount = 1},
    {type = "item", name = "rocket-fuel", amount = 1}
  },
  results = {{type="item", name="rocket-part", amount=1}},
  allow_productivity = true
},

--#endregion
--#region Biorecycling Stage 4- Post clear



--#endregion

--#region Pre-clear Entity Recipes
  
  {
    type = "recipe",
    name = "biorecycling-plant",
    icon = "__rubia__/graphics/entity/biorecycling-plant/biorecycling-plant-test.png",
    icon_size = 64,
    subgroup = "production-machine",
    order = "b[turret]-a[gun-turret]",
    category = "crafting",
    enabled = false,
    surface_conditions = rubia.surface_conditions(),
    energy_required = 10,
    ingredients = {
        { type = "item", name = "chemical-plant", amount = 1},
        { type = "item", name = "electronic-circuit", amount = 20}, 
        { type = "item", name = "steel-plate", amount = 20}, 
        { type = "item", name = "iron-gear-wheel", amount = 20}, 
    },
    results = {{
        type = "item", name = "biorecycling-plant", amount = 1
    }},
    allow_productivity = false,
},
{
  type = "recipe",
  name = "garbo-gatherer",
  icon = "__rubia__/graphics/icons/garbo-gatherer.png",
  icon_size = 64,
  subgroup = "production-machine",
  order = "b[turret]-a[gun-turret]",
  category = "crafting",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  ingredients = {
      { type = "item", name = "refined-concrete", amount = 100},
      { type = "item", name = "advanced-circuit", amount = 20}, 
      { type = "item", name = "steel-plate", amount = 50}, 
      { type = "item", name = "gun-turret", amount = 1}, 
  },
  results = {{
      type = "item", name = "garbo-gatherer", amount = 1
  }},
  allow_productivity = false,
},
{
  type = "recipe",
  name = "crapapult",
  icon = "__rubia__/graphics/icons/crapapult-icon.png",
  icon_size = 64,
  subgroup = "production-machine",
  order = "b[turret]-a[gun-turret]",
  category = "crafting",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  ingredients = {
      { type = "item", name = "copper-cable", amount = 50},
      { type = "item", name = "steel-plate", amount = 100}, 
      { type = "item", name = "gun-turret", amount = 1}, 
  },
  results = {{
      type = "item", name = "crapapult", amount = 1
  }},
  allow_productivity = false,
},
{
  type = "recipe",
  name = "sniper-turret",
  icon = "__rubia__/graphics/icons/sniper-turret-icon.png",
  icon_size = 64,
  subgroup = "defensive-structure",
  order = "b[turret]-a[gun-turret]",
  enabled = false,
  surface_conditions = rubia.surface_conditions(),
  energy_required = 10,
  ingredients = {
      { type = "item", name = "iron-plate", amount = 10},
      { type = "item", name = "steel-plate", amount = 10}, 
      { type = "item", name = "iron-gear-wheel", amount = 10}, 
  },
  results = {{
      type = "item", name = "sniper-turret", amount = 1
  }},
  allow_productivity = false,
},

{
  type = "recipe",
  name = "alt-gun-turret",
  icon_size = 64,
  subgroup = "defensive-structure",
  order = "b[turret]-a[gun-turret]",
  enabled = false,
  energy_required = 10,
  ingredients = {
      { type = "item", name = "iron-plate", amount = 10},
      { type = "item", name = "steel-plate", amount = 10}, 
      { type = "item", name = "iron-gear-wheel", amount = 10}, 
  },
  results = {{
      type = "item", name = "gun-turret", amount = 1
  }},
  allow_productivity = false,
  auto_recycle = false,
},
{
  type = "recipe",
  name = "rubia-wind-turbine",
  energy_required = 10,
  ingredients = {
      {type = "item", name = "iron-plate",      amount = 8},
      {type = "item", name = "iron-gear-wheel", amount = 6},
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


--#endregion
--#region Post-clear Rewards
  {
    type = "recipe",
    name = "long-bulk-inserter",
    category ="advanced-crafting",
    enabled = false,
    --surface_conditions = rubia.surface_conditions(),
    energy_required = 3,
    ingredients =
    {
      {type = "item", name = "long-handed-inserter", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "advanced-circuit", amount = 3},
      {type = "item", name = "craptonite-frame", amount = 4},
    },
    results = {{type="item", name="long-bulk-inserter", amount=1}},
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
      {type = "item", name = "refined-concrete", amount = 10},
    },
    results = {{type="item", name="craptonite-wall", amount=1}},
    crafting_machine_tint = crafting_machine_tint_brown,
    allow_productivity=false,
  },

--#endregion

    --[[
    {
      type ="recipe",
      name ="platinum-plate",
      category ="metallurgy",
      icon ="__rubia__/graphics/icons/platinum-plate.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="platinum-ore", amount = 4},
      },

      energy_required = 10,
      results =
      {
        {type ="item", name ="platinum-plate", amount = 1}
      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="platinum-plate",
      factoriopedia_description ="Refine platinum from ore."
    },]]
})


--[[
if mods["maraxsis"] then
  data:extend(
    {
      {
        type ="recipe",
        name ="petrol-dehydrogenation-and-combustion",
        category ="catalytic-chemistry",
        enabled = false,
        ingredients = 
        {
          {type ="fluid", name ="petroleum-gas", amount = 50} 
        },
        surface_conditions =
        {
            {
                property ="pressure",
                min = 6000,
                max = 6000
            }
        },
        energy_required = 30,
        results =
        {
          {type ="fluid", name ="carbon-dioxide", amount = 80, temperature = 1000},
          {type ="fluid", name ="maraxsis-hydrogen", amount = 250}
        },
        allow_productivity = true,
        main_product ="maraxsis-hydrogen",
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
          secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
          tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
          quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, --rgb(255, 136, 0)
        },
    },
    {
      type ="recipe",
      name ="petrol-dehydrogenation-and-combustion-maraxsis",
      category ="catalytic-chemistry",
      enabled = false,
      ingredients = 
      {
        {type ="fluid", name ="petroleum-gas", amount = 50}, 
        {type ="fluid", name ="maraxsis-oxygen", amount = 300}, 
      },
      surface_conditions =
      {
          {
              property ="pressure",
              min = 6000,
              max = 400000
          }
      },
      energy_required = 30,
      results =
      {
        {type ="fluid", name ="carbon-dioxide", amount = 80, temperature = 1000},
        {type ="fluid", name ="maraxsis-hydrogen", amount = 250}
      },
      allow_productivity = true,
      main_product ="maraxsis-hydrogen",
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
        secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
        tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
        quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, --rgb(255, 136, 0)
      },
    },
    }
  )
end]]
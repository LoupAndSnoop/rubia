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
  primary = {r = 1.000, g = 0.912, b = 1, a = 1.000}, 
  secondary = {r = 0.707, g = 0.797, b = 1, a = 1.000}, 
  tertiary = {r = 0.681, g = 0.635, b = 1, a = 1.000},
  quaternary = {r = 1.000, g = 0.804, b = 1, a = 1.000}
}
        


data:extend(
{
    --Basic Biorecycling for Stage 1


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
    --icon ="__rubia__/graphics/icons/biorecycling-science-pack.png",
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

  --#endregion

--#region Biorecycling Stage 1- Early Rubia

  {
    type ="recipe",
    name ="sludge-to-bacteria-A",
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
    auto_recycle = false,
  },

--#endregion
--#region Biorecycling Stage 2- Midgame



--#endregion
--#region Biorecycling Stage 3- Final strech before clear



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
  name = "crapapult",
  icon = "__rubia__/graphics/icons/crapapult-icon.png",
  icon_size = 64,
  subgroup = "production-machine",
  order = "b[turret]-a[gun-turret]",
  category = "crafting",
  enabled = false,
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


--#endregion
--#region Post-clear Rewards
  {
    type = "recipe",
    name = "long-bulk-inserter",
    category ="advanced-crafting",
    enabled = false,
    energy_required = 3,
    ingredients =
    {
      {type = "item", name = "long-handed-inserter", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "advanced-circuit", amount = 3},
      {type = "item", name = "craptonite-frame", amount = 4},
    },
    results = {{type="item", name="long-bulk-inserter", amount=1}},
    crafting_machine_tint = crafting_machine_tint_brown,
  },

--#endregion

{
  type = "recipe",
  icon = "__base__/graphics/icons/rocket-fuel.png",
  name = "rocket-fuel-catalytic-chemistry",
  energy_required = 15,
  enabled = false,
  category = "biorecycling",
  ingredients =
  {
    {type = "item", name = "solid-fuel", amount = 10},
    {type = "fluid", name = "light-oil", amount = 10}
  },
  results = {{type="item", name="rocket-fuel", amount=1}},
  crafting_machine_tint =
  {
    primary = {r = 194, g = 152, b = 198, a = 1.000}, --rgb(194, 152, 198)
    secondary = {r = 194, g = 140, b = 215, a = 1.000}, --rgb(194, 140, 215)
    tertiary = {r = 228, g = 197, b = 151, a = 1.000}, --rgb(228, 197, 151)
    quaternary = {r = 255, g = 187, b = 73, a = 1.000}, --rgb(255, 187, 73)
  },
  allow_productivity = true,
  main_product = "rocket-fuel",
  hide_from_player_crafting = true,
    },

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
    },
    {
      type ="recipe",
      name ="platinum-plate-production-alt",
      category ="smelting",
      icon ="__rubia__/graphics/icons/platinum-plate.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="platinum-ore", amount = 4},
      },

      energy_required = 12,
      results =
      {
        {type ="item", name ="platinum-plate", amount = 1}
      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="platinum-plate",
      factoriopedia_description ="Refine platinum from ore."
    },
    {
      type ="recipe",
      name ="catalytic-chemical-plant-recipe",
      category ="crafting",
      icon ="__rubia__/graphics/icons/catalytic-chemical-plant.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="platinum-plate", amount = 10},
        {type ="item", name ="electronic-circuit", amount = 2},
        {type ="item", name ="chemical-plant", amount = 1},
        {type ="item", name ="copper-cable", amount = 5},
      },

      energy_required = 20,
      results =
      {
        {type ="item", name ="catalytic-chemical-plant", amount = 1}
      },
      allow_productivity = false,
      allow_quality = true,
      main_product ="catalytic-chemical-plant",
      factoriopedia_description ="Produce a chemical plant that specializes in using platinum as a catalyst."
    },
    {
      type ="recipe",
      name ="pressurized-acid-neutralization",
      category ="chemistry-or-cryogenics",
      icon ="__space-age__/graphics/icons/fluid/acid-neutralisation.png",
      enabled = false,
      subgroup ="fluid-recipes",
      order ="d[other-chemistry]-a[pressurized-acid-neutralisation]",
      auto_recycle = false,
      enabled = false,
      surface_conditions =
      {
        {
          property ="pressure",
          min = 6000,
          max = 6000
        }
      },
      ingredients =
      {
        {type ="item", name ="calcite", amount = 1},
        {type ="fluid", name ="sulfuric-acid", amount = 1000},
        {type ="fluid", name ="water", amount = 180},
      },
      energy_required = 5,
      results =
      {
        {type ="fluid", name ="steam", amount = 12000, temperature = 500}
      },
      allow_productivity = false,
      always_show_products = true,
      show_amount_in_title = false,
      allow_decomposition = false,
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, -- #ffe809ff
        secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, -- #b4cb55ff
        tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, -- #ada17bff
        quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, -- #ffcd00ff
      },
      factoriopedia_description ="Even higher pressures and surface conditions on rubia let us get even more energy from acid neutralization.",
    },
    {
      type ="recipe",
      name ="pressurized-acid-neutralization-alt",
      category ="chemistry-or-cryogenics",
      icon ="__space-age__/graphics/icons/fluid/acid-neutralisation.png",
      enabled = false,
      subgroup ="fluid-recipes",
      order ="d[other-chemistry]-a[pressurized-acid-neutralisation]",
      auto_recycle = false,
      enabled = false,
      surface_conditions =
      {
        {
          property ="pressure",
          min = 6000,
          max = 6000
        }
      },
      ingredients =
      {
        {type ="item", name ="calcite", amount = 1},
        {type ="fluid", name ="sulfuric-acid", amount = 1000},
      },
      energy_required = 5,
      results =
      {
        {type ="fluid", name ="steam", amount = 10000, temperature = 500}
      },
      allow_productivity = false,
      always_show_products = true,
      show_amount_in_title = false,
      allow_decomposition = false,
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, -- #ffe809ff
        secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, -- #b4cb55ff
        tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, -- #ada17bff
        quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, -- #ffcd00ff
      },
      factoriopedia_description ="We need more water to capture all energy released, but this should help get things started.",
    },

    {
      type ="recipe",
      name ="dilute-acid-neutralization",
      category ="chemistry-or-cryogenics",
      icon ="__base__/graphics/icons/fluid/water.png",
      enabled = false,
      subgroup ="fluid-recipes",
      order ="d[other-chemistry]-b[pressurized-acid-neutralisation]",
      auto_recycle = false,
      enabled = false,
      surface_conditions =
      {
        {
          property ="pressure",
          min = 0,
          max = 6000
        }
      },
      ingredients =
      {
        {type ="item", name ="calcite", amount = 2},
        {type ="fluid", name ="sulfuric-acid-dilute", amount = 2000},
      },
      energy_required = 2,
      results =
      {
        {type ="fluid", name ="water", amount = 2000, temperature = 100}
      },
      allow_productivity = false,
      always_show_products = true,
      show_amount_in_title = false,
      allow_decomposition = false,
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, -- #ffe809ff
        secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, -- #b4cb55ff
        tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, -- #ada17bff
        quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, -- #ffcd00ff
      },
      factoriopedia_description ="We get enough heat energy from neutralization to boil water",
    },

    {
      type ="recipe",
      name ="destructive-dilute-acid-neutralization",
      category ="chemistry-or-cryogenics",
      icon ="__rubia__/graphics/icons/fluid/sulfuric-acid-dilute-X.png",
      enabled = false,
      subgroup ="fluid-recipes",
      order ="d[other-chemistry]-b[pressurized-acid-neutralisation]",
      auto_recycle = false,
      enabled = false,
      surface_conditions =
      {
        {
          property ="pressure",
          min = 0,
          max = 6000
        }
      },
      ingredients =
      {
        {type ="item", name ="calcite", amount = 5},
        {type ="fluid", name ="sulfuric-acid-dilute", amount = 4000},
      },
      energy_required = 8,
      results =
      {
        --{}
      },
      allow_productivity = false,
      always_show_products = true,
      show_amount_in_title = false,
      allow_decomposition = false,
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, -- #ffe809ff
        secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, -- #b4cb55ff
        tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, -- #ada17bff
        quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, -- #ffcd00ff
      },
      factoriopedia_description ="Heat the water, and boil it away.",
    },


    {
      type ="recipe",
      name ="hot-water-to-steam",
      category ="chemistry-or-cryogenics",
      icon ="__base__/graphics/icons/fluid/water.png",
      enabled = false,
      subgroup ="fluid-recipes",
      order ="d[other-chemistry]-c[pressurized-acid-neutralisation]",
      auto_recycle = false,
      enabled = false,
      surface_conditions =
      {
        {
          property ="pressure",
          min = 0,
          max = 6000
        }
      },
      ingredients =
      {
        {type ="item", name ="solid-fuel", amount = 5},
        {type ="fluid", name ="water", amount = 90, temperature = 100},
      },
      energy_required = 2,
      results =
      {
        {type ="fluid", name ="steam", amount = 1000, temperature = 500},
      },
      allow_productivity = false,
      always_show_products = true,
      show_amount_in_title = false,
      allow_decomposition = false,
      crafting_machine_tint =
      {
        primary = {r = 98, g = 168, b = 230, a = 1.000}, --rgb(98, 168, 230)
        secondary = {r = 85, g = 177, b = 203, a = 1.000}, --rgb(85, 177, 203)
        tertiary = {r = 123, g = 165, b = 173, a = 1.000}, --rgb(123, 165, 173)
        quaternary = {r = 0, g = 179, b = 255, a = 1.000}, --rgb(0, 179, 255)
      },

    },


    --STEP 1 Sulfur Redox 
    {
        type ="recipe",
        name ="petroleum-alkylation",
        category ="catalytic-chemistry",
        icon ="__rubia__/graphics/icons/petrol-alkylation.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="sulfuric-acid", amount = 100},
          {type ="fluid", name ="petroleum-gas", amount = 40},
        },

        energy_required = 7,
        results =
        {
          {type ="fluid", name ="light-oil", amount = 10}
        },
        allow_productivity = false,
        allow_quality = false,
        main_product ="light-oil",
        factoriopedia_description ="Large amounts of sulfuric acid can form carbocations, which are used as the basis for alkylation to form new carbon-carbon bonds.",
        crafting_machine_tint =
        {
          primary = {r = 194, g = 152, b = 198, a = 1.000}, --rgb(194, 152, 198)
          secondary = {r = 194, g = 140, b = 215, a = 1.000}, --rgb(194, 140, 215)
          tertiary = {r = 228, g = 197, b = 151, a = 1.000}, --rgb(228, 197, 151)
          quaternary = {r = 255, g = 187, b = 73, a = 1.000}, --rgb(255, 187, 73)
        },
    },
    {
        type ="recipe",
        name ="light-oil-alkylation",
        category ="catalytic-chemistry",
        icon ="__rubia__/graphics/icons/light-oil-alkylation.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="sulfuric-acid", amount = 100},
          {type ="fluid", name ="light-oil", amount = 40},
        },

        energy_required = 10,
        results =
        {
          {type ="fluid", name ="heavy-oil", amount = 10}
        },
        allow_productivity = false,
        allow_quality = false,
        main_product ="heavy-oil",
        factoriopedia_description ="Large amounts of sulfuric acid can form carbocations, which are used as the basis for alkylation to form new carbon-carbon bonds. We use this form heavy oil.",
        crafting_machine_tint =
        {
          primary = {r = 0.710, g = 0.633, b = 0.482, a = 1.000}, -- #b5a17aff
          secondary = {r = 0.745, g = 0.672, b = 0.527, a = 1.000}, -- #beab86ff
          tertiary = {r = 0.894, g = 0.773, b = 0.596, a = 1.000}, -- #e4c598ff
          quaternary = {r = 0.812, g = 0.583, b = 0.202, a = 1.000}, -- #cf9433ff
        },
    },
    {
        type ="recipe",
        name ="sulfur-combustion",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/fluid/sulfur-dioxide.png",
        enabled = false,
        surface_conditions =
        {
          {
            property ="pressure",
            min = 300,
            max = 110000
          }
        },
        ingredients =
        {

          {type ="item", name ="sulfur", amount = 1}

        },

        energy_required = 1,
        results =
        {
          {type ="fluid", name ="sulfur-dioxide", amount = 50}
        },
        allow_productivity = true,
        allow_quality = false,
        main_product ="sulfur-dioxide",
        factoriopedia_description ="Burning sulfur lets us get this gas, which we can use to make both sulfuric acid and water.",
        crafting_machine_tint =
        {
          primary = {r = 0.965, g = 0.482, b = 0.338, a = 1.000}, -- #f67a56ff
          secondary = {r = 0.831, g = 0.560, b = 0.222, a = 1.000}, -- #d38e38ff
          tertiary = {r = 0.728, g = 0.818, b = 0.443, a = 1.000}, -- #b9d070ff
          quaternary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
        },
    },
    {
        type ="recipe",
        name ="hydrogen-sulfide",
        category ="catalytic-chemistry",
        icon ="__rubia__/graphics/icons/fluid/hydrogen-sulfide.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="sulfur", amount = 1},
          {type ="fluid", name ="petroleum-gas", amount = 200},
        },

        energy_required = 15,
        results =
        {
          {type ="fluid", name ="hydrogen-sulfide", amount = 50},
          {type ="fluid", name ="petroleum-gas", amount = 170},
        },
        allow_productivity = false,
        allow_quality = false,
        maximum_productivity = 1,
        main_product ="hydrogen-sulfide",
        factoriopedia_description ="With a platinum catalyst, we can use petroleum to hydrogenate sulfur to get hydrogen sulfide.",
        crafting_machine_tint =
        {
          primary = {r = 246, g = 243, b = 86, a = 1.000}, --rgb(246, 243, 86)
          secondary = {r = 0.831, g = 0.560, b = 0.222, a = 1.000}, -- #d38e38ff
          tertiary = {r = 208, g = 198, b = 112, a = 1.000}, --rgb(208, 198, 112)
          quaternary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
        },
    },
    {
        type ="recipe",
        name ="sulfur-reduction",
        category ="chemistry",
        icon ="__base__/graphics/icons/fluid/water.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="hydrogen-sulfide", amount = 50},
          {type ="fluid", name ="sulfur-dioxide", amount = 50},
        },

        energy_required = 15,
        results =
        {
          {type ="item", name ="sulfur", amount = 2},
          {type ="fluid", name ="water", amount = 100},
        },
        allow_productivity = false,
        allow_quality = false,
        maximum_productivity = 1,
        main_product ="water",
        factoriopedia_description ="Sulfur is reduced to a zero oxidation state, while water is formed.",
        crafting_machine_tint =
        {
          primary = {r = 246, g = 255, b = 0, a = 1.000}, --rgb(246, 255, 0)
          secondary = {r = 0.211, g = 195, b = 56, a = 1.000}, --rgb(211, 195, 56)
          tertiary = {r = 225, g = 232, b = 27, a = 1.000}, --rgb(225, 232, 27)
          quaternary = {r = 239, g = 229, b = 048.191, a = 1.000}, --rgb(239, 229, 48)
        },
    },
    {
        type ="recipe",
        name ="sulfurous-oxidation",
        category ="catalytic-chemistry",
        icon ="__base__/graphics/icons/fluid/sulfuric-acid.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="water", amount = 50},
          {type ="fluid", name ="sulfur-dioxide", amount = 50},
        },

        energy_required = 10,
        results =
        {
          {type ="fluid", name ="sulfuric-acid", amount = 125},
        },
        allow_productivity = true,
        allow_quality = false,
        maximum_productivity = 2,
        main_product ="sulfuric-acid",
        factoriopedia_description ="In the presence of a platinum catalyst, sulfur-dioxide can react with the oxygen to form sulfur trioxide in situ. Sulfur trioxide then reacts with water to form sulfuric acid.",
        crafting_machine_tint =
        {
          primary = {r = 0.965, g = 0.482, b = 0.338, a = 1.000}, -- #f67a56ff
          secondary = {r = 0.831, g = 0.560, b = 0.222, a = 1.000}, -- #d38e38ff
          tertiary = {r = 0.728, g = 0.818, b = 0.443, a = 1.000}, -- #b9d070ff
          quaternary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
        },   
    },

    --STEP 2, Sulfate processing
    {
        type ="recipe",
        name ="hydrogen-sulfide-combustion",
        category ="chemistry",
        icon ="__base__/graphics/icons/fluid/water.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="hydrogen-sulfide", amount = 100},
        },

        surface_conditions =
        {
          {
            property ="pressure",
            min = 300,
            max = 110000
          }
        },

        energy_required = 10,
        results =
        {
          {type ="fluid", name ="sulfur-dioxide", amount = 200},
          {type ="fluid", name ="water", amount = 200},
        },
        allow_productivity = false,
        allow_quality = false,
        maximum_productivity = 1,
        main_product ="water",
        factoriopedia_description ="Combustion of hydrogen sulfide gives us more components to make sulfuric acid.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 110, b = 246, a = 1.000}, --rgb(86, 110, 246)
          secondary = {r = 61, g = 56, b = 211, a = 1.000}, --rgb(61, 56, 211)
          tertiary = {r = 138, g = 112, b = 208, a = 1.000}, --rgb(138, 112, 208)
          quaternary = {r = 48, g = 48, b = 239, a = 1.000}, --rgb(48, 48, 239)
        },
    },



    {
        type ="recipe",
        name ="chalcopyrite-refining",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/fluid/mixed-sulfate-solution.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="chalcopyrite-ore", amount = 5},
          {type ="fluid", name ="sulfuric-acid", amount = 500},
        },

        energy_required = 30,
        results =
        {
          {type ="fluid", name ="mixed-sulfate-solution", amount = 500},
        },
        surface_conditions =
        {
            {
                property ="pressure",
                min = 1000,
            },
        },
        allow_productivity = true, --I'll allow productivity for now
        allow_quality = false,
        maximum_productivity = 2,
        main_product ="mixed-sulfate-solution",
        auto_recycle = false,
        factoriopedia_description ="Chalcopyrite is FeCuS. We blast the ore heat and concentrated sulfuric acid fully oxidize the metals, forming a mixture of their aqueous sulfate salts.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
    },
    {
        type ="recipe",
        name ="reactive-displacement",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/fluid/iron-sulfate-solution.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="iron-plate", amount = 1},
          {type ="fluid", name ="mixed-sulfate-solution", amount = 200},
        },

        energy_required = 5,
        results =
        {
          {type ="fluid", name ="iron-sulfate-solution", amount = 200},
          {type ="item", name ="copper-ore", amount = 2}
        },
        allow_productivity = true, 
        auto_recycle = false,
        maximum_productivity = 1,
        main_product ="iron-sulfate-solution",
        factoriopedia_description ="Iron is more reactive than copper. Thus we can use it to displace copper ions in solution.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 246, b = 230, a = 1.000}, --rgb(86, 246, 230)
          secondary = {r = 56, g = 211, b = 190, a = 1.000}, --rgb(56, 211, 190)
          tertiary = {r = 112, g = 208, b = 205, a = 1.000}, --rgb(112, 208, 205)
          quaternary = {r = 48, g = 239, b = 194, a = 1.000}, --rgb(48, 239, 194)
        },
    },
    {
      type ="recipe",
      name ="super-saturated-displacement",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/iron-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="copper-plate", amount = 15},
        {type ="fluid", name ="mixed-sulfate-solution", amount = 200},
        {type ="fluid", name ="water", amount = 300},
        {type ="fluid", name ="sulfuric-acid", amount = 300},
      },

      energy_required = 20,
      results =
      {
        {type ="fluid", name ="iron-sulfate-solution", amount = 200},
        {type ="fluid", name ="copper-sulfate-solution", amount = 300},
        {type ="item", name ="copper-ore", amount = 5}
      },
      allow_productivity = true, 
      auto_recycle = false,
      maximum_productivity = 1,
      main_product ="iron-sulfate-solution",
      factoriopedia_description ="We can coax more copper out of a mixed solution with repeated supersaturation and recrystalization.",
      crafting_machine_tint =
      {
        primary = {r = 86, g = 246, b = 230, a = 1.000}, --rgb(86, 246, 230)
        secondary = {r = 56, g = 211, b = 190, a = 1.000}, --rgb(56, 211, 190)
        tertiary = {r = 112, g = 208, b = 205, a = 1.000}, --rgb(112, 208, 205)
        quaternary = {r = 48, g = 239, b = 194, a = 1.000}, --rgb(48, 239, 194)
      },
    },



    {
        type ="recipe",
        name ="force-reduction-iron",
        category ="chemistry",
        icon ="__base__/graphics/icons/iron-ore.png",
        enabled = false,
        ingredients =
        {

          --{type ="item", name ="iron-plate", amount = 1},
          {type ="fluid", name ="iron-sulfate-solution", amount = 300},
          {type ="fluid", name ="water", amount = 100}, --Why do I need more water, its aqueous already. Oh for washing the products...
        },

        energy_required = 10,
        results =
        {
          {type ="fluid", name ="sulfuric-acid-dilute", amount = 350}, --some fluid lost.
          {type ="item", name ="iron-ore", amount = 7}
        },
        allow_productivity = true,
        auto_recycle = false,
        maximum_productivity = 1,
        main_product ="iron-ore",
        --factoriopedia_description ="We can use voltage to pump electronics into the ionic solution. These electrons reduce aqueous ferric ions in to pure iron. However, an iron plate must be used to seed crystal growth, and of course the pure product must be shaped back into plates.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
    },
    {
        type ="recipe",
        name ="force-reduction-copper",
        category ="chemistry",
        icon ="__base__/graphics/icons/copper-ore.png",
        enabled = false,
        ingredients =
        {

          --{type ="item", name ="copper-plate", amount = 1},
          {type ="fluid", name ="copper-sulfate-solution", amount = 300},
          {type ="fluid", name ="water", amount = 100},
        },

        energy_required = 12,
        results =
        {
          {type ="fluid", name ="sulfuric-acid-dilute", amount = 350},
          {type ="item", name ="copper-ore", amount = 3}
        },
        allow_productivity = true, 
        maximum_productivity = 1,
        main_product ="copper-ore",
        auto_recycle = false,
        --factoriopedia_description ="Similiar to reduction of ferric sulfate, we pump electrons in and they reduce copper ions.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
    },
    -- STEP 3 optimization and plastics, and alkylation. (Alkylation moved to steps 3+4)

    {
        type ="recipe",
        name ="sulfonated-plastic",
        category ="catalytic-chemistry",
        icon ="__base__/graphics/icons/plastic-bar.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="solid-fuel", amount = 3},
          {type ="fluid", name ="sulfuric-acid", amount = 90},
          {type ="fluid", name ="sulfur-dioxide", amount = 110},
          {type ="fluid", name ="light-oil", amount = 10},
        },

        energy_required = 5,
        results =
        {
          {type ="item", name ="plastic-bar", amount = 4}
        },
        allow_productivity = true, 
        maximum_productivity = 5,
        main_product ="plastic-bar",
        auto_recycle = false,
        --factoriopedia_description ="With a platinum catalyst, we use sulfur dioxide and oxygen to form sulfur trioxide. Sulfur trioxide reacts with sulfuric acid to form fuming sulfuric acid, which can sulfonate hydrocarbons.",
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, -- #ffa342ff
          secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, -- #ffb85fff
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
          quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
        }
    },
    {
      type ="recipe",
      name ="sulfonated-plastic-production-alt",
      category ="catalytic-chemistry",
      icon ="__base__/graphics/icons/plastic-bar.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="solid-fuel", amount = 2},
        {type ="fluid", name ="sulfuric-acid", amount = 90},
        {type ="fluid", name ="sulfur-dioxide", amount = 110},
        {type ="fluid", name ="heavy-oil", amount = 8},
      },

      energy_required = 7,
      results =
      {
        {type ="item", name ="plastic-bar", amount = 5}
      },
      allow_productivity = true, 
      maximum_productivity = 5,
      main_product ="plastic-bar",
      auto_recycle = false,
      --factoriopedia_description ="With a platinum catalyst, we use sulfur dioxide and oxygen to form sulfur trioxide. Sulfur trioxide reacts with sulfuric acid to form fuming sulfuric acid, which can sulfonate hydrocarbons.",
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, -- #ffa342ff
        secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, -- #ffb85fff
        tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
        quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
      },
    },



    {
        type ="recipe",
        name ="calcium-sulfate-fish",
        category ="organic-or-chemistry",
        icon ="__space-age__/graphics/icons/nutrients.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="carbon", amount = 2},
          {type ="item", name ="calcium-sulfate", amount = 2},
          {type ="item", name ="raw-fish", amount = 1}
        },

        energy_required = 2,
        results =
        {
          {type ="item", name ="nutrients", amount = 40}
        },
        allow_productivity = true, 
        maximum_productivity = 2,
        main_product ="nutrients",
        --factoriopedia_description ="With a nitrogen and phosphorous source, we add more carbon and calcium sulfate to optimize nutrient production.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
        auto_recycle = false,

    },
    {
        type ="recipe",
        name ="calcium-sulfate-bioflux",
        category ="organic-or-chemistry",
        icon ="__space-age__/graphics/icons/nutrients.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="carbon", amount = 4},
          {type ="item", name ="calcium-sulfate", amount = 4},
          {type ="item", name ="bioflux", amount = 5}
        },

        energy_required = 4,
        results =
        {
          {type ="item", name ="nutrients", amount = 80}
        },
        allow_productivity = true, 
        maximum_productivity = 2,
        main_product ="nutrients",
        --factoriopedia_description ="With a nitrogen and phosphorous source, we add more carbon and calcium sulfate to optimize nutrient production."
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
        auto_recycle = false,

    },
    {
        type ="recipe",
        name ="calcium-sulfate-egg",
        category ="organic-or-chemistry",
        icon ="__space-age__/graphics/icons/nutrients.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="carbon", amount = 2},
          {type ="item", name ="calcium-sulfate", amount = 2},
          {type ="item", name ="biter-egg", amount = 1}
        },

        energy_required = 2,
        results =
        {
          {type ="item", name ="nutrients", amount = 40}
        },
        allow_productivity = true, 
        maximum_productivity = 2,
        main_product ="nutrients",
        --factoriopedia_description ="With a nitrogen and phosphorous source, we add more carbon and calcium sulfate to optimize nutrient production.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
        auto_recycle = false,

    },
    {
        type ="recipe",
        name ="calcium-sulfate",
        category ="organic-or-chemistry",
        icon ="__rubia__/graphics/icons/calcium-sulfate.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="calcite", amount = 2},
          {type ="fluid", name ="sulfuric-acid-dilute", amount = 100},
        },

        energy_required = 10,
        results =
        {
          {type ="item", name ="calcium-sulfate", amount = 2},
          {type ="fluid", name ="water", amount = 100}
        },
        allow_productivity = false, 
        maximum_productivity = 1,
        main_product ="calcium-sulfate",
        --factoriopedia_description ="We neutralize dilute sulfuric acid and collect the salt with evaporation. Adding calcite directly to concentrated sulfuric acid releases a lot of energy, making it difficult to collect a salt that way. Most of the time here is spent drying out the salt.",
        crafting_machine_tint =
        {
          primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
          secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
          tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
          quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
        },
        auto_recycle = false,
    },
    {
        type ="recipe",
        name ="sulfuric-acid-dilution",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/fluid/sulfuric-acid-dilute.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="sulfuric-acid", amount = 100},
          {type ="fluid", name ="water", amount = 400},
        },

        energy_required = 10,
        results =
        {
          {type ="fluid", name ="sulfuric-acid-dilute", amount = 500},
        },
        allow_productivity = false,
        allow_quality = false, 
        maximum_productivity = 1,
        main_product ="sulfuric-acid-dilute",
        factoriopedia_description ="Add acid to water to dilute safely, not the otherway around.",
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, --rgb(240, 194, 146)
          secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, --rgb(248, 209, 163)
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, --rgb(219, 186, 171)
          quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, --rgb(245, 174, 143)
        },
        auto_recycle = false,
    },
    {
        type ="recipe",
        name ="sulfuric-acid-concentration",
        category ="chemistry",
        icon ="__base__/graphics/icons/fluid/sulfuric-acid.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="sulfuric-acid-dilute", amount = 500},
        },

        energy_required = 150,
        results =
        {
          {type ="fluid", name ="sulfuric-acid", amount = 100},
          {type ="fluid", name ="steam", amount = 4400, temperature = 100},
        },
        allow_productivity = false, 
        allow_quality = false,
        maximum_productivity = 1,
        main_product ="sulfuric-acid",
        factoriopedia_description ="We spend alot of energy boiling off water into steam, which can be condensed back into water.",
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, -- #ffa342ff
          secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, -- #ffb85fff
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
          quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
        },
        auto_recycle = false,
    },
    {
      type ="recipe",
      name ="sulfuric-acid-concentration-alt",
      category ="chemistry",
      icon ="__base__/graphics/icons/fluid/sulfuric-acid.png",
      enabled = false,
      ingredients =
      {

        {type ="fluid", name ="sulfuric-acid-dilute", amount = 500},
      },

      energy_required = 60,
      results =
      {
        {type ="fluid", name ="sulfuric-acid", amount = 100},
      },
      allow_productivity = false, 
      allow_quality = false,
      maximum_productivity = 1,
      main_product ="sulfuric-acid",
      factoriopedia_description ="We spend alot of energy boiling off water, and don't bother to catch it.",
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, -- #ffa342ff
        secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, -- #ffb85fff
        tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
        quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
      },
      auto_recycle = false,
    },
    {
        type ="recipe",
        name ="calcium-sulfate-production-alt",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/calcium-sulfate.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="calcite", amount = 2},
          {type ="fluid", name ="sulfur-dioxide", amount = 50},
        },

        energy_required = 5,
        results =
        {
          {type ="item", name ="calcium-sulfate", amount = 2},
        },
        allow_productivity = false, 
        maximum_productivity = 1,
        main_product ="calcium-sulfate",
        factoriopedia_description ="Sulfur-dioxide and calcium carbonate react to form calcium sulfate and carbon dioxide.",
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, --rgb(240, 194, 146)
          secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, --rgb(248, 209, 163)
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, --rgb(219, 186, 171)
          quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, --rgb(245, 174, 143)
        },
        auto_recycle = false,
    },
    {
        type ="recipe",
        name ="stone-production",
        category ="chemistry",
        icon ="__base__/graphics/icons/stone.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="calcium-sulfate", amount = 2},
          {type ="item", name ="stone", amount = 1},
          {type ="item", name ="carbon", amount = 2},
        },

        energy_required = 5,
        results =
        {
          {type ="item", name ="stone", amount = 2},
          {type ="fluid", name ="sulfur-dioxide", amount = 50}
        },
        allow_productivity = false, 
        maximum_productivity = 1,
        main_product ="stone",
        factoriopedia_description ="Stone is represented by SiO2 (reactant) and CaSiO3 (product). Analagous to making stone on Vulcanus.",
        auto_recycle = false,
        crafting_machine_tint =
        {
          primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, --rgb(240, 194, 146)
          secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, --rgb(248, 209, 163)
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, --rgb(219, 186, 171)
          quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, --rgb(245, 174, 143)
        },

    },

    -- STEP 4. asphalt and concrete production.
    {
        type ="recipe",
        name ="asphalt-production",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/asphalt.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="heavy-oil", amount = 35},
          {type ="fluid", name ="sulfuric-acid", amount = 50}
        },

        energy_required = 15,
        results =
        {
          {type ="item", name ="asphalt", amount = 1},
        },
        allow_productivity = true, 
        main_product ="asphalt",
        factoriopedia_description ="We condense heavy oil into a concrete precusor.",
        auto_recycle = false,
        crafting_machine_tint =
        {
          primary = {r = 0.889, g = 0.628, b = 0.566, a = 1.000}, -- #e2a090ff
          secondary = {r = 0.803, g = 0.668, b = 0.644, a = 1.000}, -- #ccaaa4ff
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
          quaternary = {r = 1.000, g = 0.395, b = 0.127, a = 1.000}, -- #ff6420ff
        },

    },
    {
        type ="recipe",
        name ="asphalt-production-alt",
        category ="chemistry",
        icon ="__rubia__/graphics/icons/asphalt.png",
        enabled = false,
        ingredients =
        {

          {type ="fluid", name ="light-oil", amount = 160},
          {type ="fluid", name ="sulfuric-acid", amount = 75}
        },

        energy_required = 10,
        results =
        {
          {type ="item", name ="asphalt", amount = 1},
        },
        allow_productivity = true, 
        main_product ="asphalt",
        factoriopedia_description ="We can also use excess light oil to make asphalt. Reaction is faster, but less efficient.",
        auto_recycle = false,
        crafting_machine_tint =
        {
          primary = {r = 0.889, g = 0.628, b = 0.566, a = 1.000}, --rgb(226, 226, 144)
          secondary = {r = 0.803, g = 0.668, b = 0.644, a = 1.000}, --rgb(204, 203, 164)
          tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, --rgb(217, 196, 146)
          quaternary = {r = 1.000, g = 0.395, b = 0.127, a = 1.000}, --rgb(255, 240, 32)
        },

    },
    {
        type ="recipe",
        name ="concrete-production-from-asphalt",
        category ="crafting-with-fluid",
        icon ="__base__/graphics/icons/concrete.png",
        enabled = false,
        ingredients =
        {

          {type ="item", name ="asphalt", amount = 4},
          {type ="item", name ="stone", amount = 1},
          {type ="fluid", name ="water", amount = 50},
        },

        energy_required = 8,
        results =
        {
          {type ="item", name ="concrete", amount = 10},
        },
        allow_productivity = true, 
        main_product ="concrete",
        factoriopedia_description ="Asphalt and stone makes concrete.",
        auto_recycle = false,

    },
    {
      type ="recipe",
      name ="calcium-sulfate-recovery",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/calcium-sulfate.png",
      enabled = false,
      ingredients =
      {
        {type = "item", name = "nutrients", amount = 160},
        {type ="fluid", name ="sulfuric-acid", amount = 100}, 
        {type ="fluid", name ="water", amount = 600}, 
        {type ="fluid", name ="light-oil", amount = 150},

      },

      energy_required = 60,
      results =
      {
        {type ="item", name ="calcium-sulfate", amount = 2},
      },
      allow_productivity = true, 
      maximum_productivity = 2,
      main_product ="calcium-sulfate",
      crafting_machine_tint =
      {
        primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
        secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
        tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
        quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
      },
      auto_recycle = false,
    },



    --Other
    {
      type ="recipe",
      name ="pressure-laboratory-recipe",
      category ="crafting",
      icon ="__rubia__/graphics/icons/pressure-lab.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="chemical-plant", amount = 1},
        {type ="item", name ="platinum-plate", amount = 4},
        {type ="item", name ="lab", amount = 1},
        {type ="item", name ="steam-turbine", amount = 1},
        {type ="item", name ="steel-plate", amount = 10},
      },

      energy_required = 30,
      results =
      {
        {type ="item", name ="pressure-lab", amount = 1},
      },
      allow_productivity = false, 
      main_product ="pressure-lab",

    },
    {
      type ="recipe",
      name ="red-boiler-recipe",
      category ="crafting",
      icon ="__rubia__/graphics/icons/red-boiler.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="boiler", amount = 1},
        {type ="item", name ="copper-plate", amount = 10},
      },

      energy_required = 7,
      results =
      {
        {type ="item", name ="red-boiler", amount = 1},
      },
      allow_productivity = false, 
      main_product ="red-boiler",

    },
    {
      type ="recipe",
      name ="red-steam-engine-recipe",
      category ="crafting",
      icon ="__rubia__/graphics/icons/red-steam-engine.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="steam-engine", amount = 1},
        {type ="item", name ="copper-plate", amount = 10},
        {type ="item", name ="iron-plate", amount = 10},
      },

      energy_required = 7,
      results =
      {
        {type ="item", name ="red-steam-engine", amount = 1},
      },
      allow_productivity = false, 
      main_product ="red-steam-engine",

    },
    {
      type ="recipe",
      name ="thruster-fuel-oxidizer-to-steam",
      category ="catalytic-chemistry",
      icon ="__base__/graphics/icons/fluid/steam.png",
      enabled = false,
      ingredients =
      {

        {type ="fluid", name ="thruster-fuel", amount = 500},
        {type ="fluid", name ="water", amount = 150},
        {type ="fluid", name ="thruster-oxidizer", amount = 500},
      },

      energy_required = 20, --Alright, multiplied values wildly. Should be a fair nerf don't want to out class nuclear.
      results =
      {
        {type ="fluid", name ="steam", amount = 500, temperature = 500},
      },
      allow_productivity = true, 
      allow_quality = false,
      auto_recycle = false,
      main_product ="steam",
      crafting_machine_tint =
      {
        primary = {r = 0.881, g = 0.100, b = 0.000, a = 0.502}, -- #e0190080
        secondary = {r = 0.930, g = 0.767, b = 0.605, a = 0.502}, -- #edc39a80
        tertiary = {r = 0.873, g = 0.649, b = 0.542, a = 0.502}, -- #dea58a80
        quaternary = {r = 0.629, g = 0.174, b = 0.000, a = 0.502}, -- #a02c0080
      },

    },
    {
      type ="recipe",
      name ="carbon-dioxide-to-carbon",
      category ="catalytic-chemistry",
      icon ="__space-age__/graphics/icons/carbon.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="iron-plate", amount = 2},
        {type ="fluid", name = "sulfuric-acid", amount = 100},
        {type ="fluid", name = "carbon-dioxide", amount = 300},
      },

      energy_required = 5, 
      results =
      {
        {type ="item", name ="carbon", amount = 1},
        {type ="fluid", name ="iron-sulfate-solution", amount = 100},
      },
      allow_productivity = true, 
      allow_quality = true,
      auto_recycle = false,
      main_product ="carbon",
      crafting_machine_tint =
      {
        primary = {r = 86, g = 161, b = 246, a = 1.000}, --rgb(86, 161, 246)
        secondary = {r = 56, g = 136, b = 211, a = 1.000}, --rgb(56, 136, 211)
        tertiary = {r = 112, g = 146, b = 208, a = 1.000}, --rgb(112, 146, 208)
        quaternary = {r = 48, g = 147, b = 239, a = 1.000}, --rgb(48, 147, 239)
      },

    },
    {
      type ="recipe",
      name ="controlled-petrol-combustion",
      category ="chemistry",
      icon = "__rubia__/graphics/icons/fluid/carbon-dioxide.png",
      enabled = false,
      ingredients =
      {

        {type ="fluid", name = "petroleum-gas", amount = 300},
      },

      energy_required = 1, 
      results =
      {
        {type ="fluid", name = "carbon-dioxide", amount = 600, temperature = 1000},
      },
      allow_productivity = true, 
      allow_quality = true,
      auto_recycle = false,
      main_product ="carbon-dioxide",
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.735, b = 0.643, a = 1.000}, -- #ffbba4ff
        secondary = {r = 0.749, g = 0.557, b = 0.490, a = 1.000}, -- #bf8e7dff
        tertiary = {r = 0.637, g = 0.637, b = 0.637, a = 1.000}, -- #a2a2a2ff
        quaternary = {r = 119, g = 116, b = 116, a = 1.000}, --rgb(119, 116, 116)
      },


    },
    {
      type ="recipe",
      name ="ice-box-production",
      category ="crafting",
      icon = "__rubia__/graphics/icons/ice-box.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="wood", amount = 2},
        {type ="item", name = "plastic-bar", amount = 20},
      },

      energy_required = 2,
      results =
      {
        {type ="item", name ="ice-box", amount = 1},
      },
      allow_productivity = false, 
      allow_quality = true,
      auto_recycle = true,
      main_product ="ice-box",


    },
    {
      type ="recipe",
      name ="dry-ice-production",
      category ="cryogenics",
      icon = "__rubia__/graphics/icons/dry-ice.png",
      enabled = false,
      ingredients =
      {

        {type ="fluid", name ="carbon-dioxide", amount = 1000},
        {type ="fluid", name ="fluoroketone-cold", amount = 50},
      },

      energy_required = 7,
      results =
      {
        {type ="item", name ="dry-ice", amount = 500},
        {type ="fluid", name ="fluoroketone-hot", amount = 25},
      },
      allow_productivity = true, 
      maximum_productivity = 2,
      allow_quality = true,
      auto_recycle = false,
      main_product ="dry-ice",


    },
    {
      type ="recipe",
      name ="dry-ice-production-alt",
      category ="catalytic-chemistry",
      icon = "__rubia__/graphics/icons/dry-ice.png",
      enabled = false,
      ingredients =
      {

        {type ="fluid", name ="carbon-dioxide", amount = 1000},
        {type ="fluid", name ="water", amount = 500, maximum_temperature = 21},
      },

      energy_required = 150,
      results =
      {
        {type ="item", name ="dry-ice", amount = 500},
        {type ="fluid", name ="water", amount = 500, temperature = 90},
      },
      allow_productivity = false, 
      --maximum_productivity = true,
      allow_quality = true,
      auto_recycle = false,
      main_product ="dry-ice",


    },
    --Crystalization and recrystalization
    {
      type ="recipe",
      name ="copper-recrystalization",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/copper-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="copper-plate", amount = 5},
        {type ="fluid", name ="sulfuric-acid", amount = 200},
      },

      energy_required = 4,
      results =
      {
        {type ="fluid", name ="copper-sulfate-solution", amount = 200},
      },
      allow_productivity = false, 
      maximum_productivity = 1,
      main_product ="copper-sulfate-solution",
      auto_recycle = false,
      crafting_machine_tint =
      {
        primary = {r = 86, g = 110, b = 246, a = 1.000}, --rgb(86, 110, 246)
        secondary = {r = 61, g = 56, b = 211, a = 1.000}, --rgb(61, 56, 211)
        tertiary = {r = 138, g = 112, b = 208, a = 1.000}, --rgb(138, 112, 208)
        quaternary = {r = 48, g = 48, b = 239, a = 1.000}, --rgb(48, 48, 239)
      },

    },
    {
      type ="recipe",
      name ="copper-recrystalization-alt",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/copper-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="copper-cable", amount = 16},
        {type ="fluid", name ="sulfuric-acid", amount = 200},
      },

      energy_required = 4,
      results =
      {
        {type ="fluid", name ="copper-sulfate-solution", amount = 200},
      },
      allow_productivity = false, 
      maximum_productivity = 1,
      main_product ="copper-sulfate-solution",
      auto_recycle = false,
      crafting_machine_tint =
      {
        primary = {r = 86, g = 110, b = 246, a = 1.000}, --rgb(86, 110, 246)
        secondary = {r = 61, g = 56, b = 211, a = 1.000}, --rgb(61, 56, 211)
        tertiary = {r = 138, g = 112, b = 208, a = 1.000}, --rgb(138, 112, 208)
        quaternary = {r = 48, g = 48, b = 239, a = 1.000}, --rgb(48, 48, 239)
      },

    },
    {
      type ="recipe",
      name ="iron-recrystalization",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/iron-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="iron-plate", amount = 5},
        {type ="fluid", name ="sulfuric-acid", amount = 200},
      },

      energy_required = 4,
      results =
      {
        {type ="fluid", name ="iron-sulfate-solution", amount = 200},
      },
      allow_productivity = false, 
      maximum_productivity = 1,
      main_product ="iron-sulfate-solution",
      auto_recycle = false,
      crafting_machine_tint =
      {
        primary = {r = 86, g = 246, b = 230, a = 1.000}, --rgb(86, 246, 230)
        secondary = {r = 56, g = 211, b = 190, a = 1.000}, --rgb(56, 211, 190)
        tertiary = {r = 112, g = 208, b = 205, a = 1.000}, --rgb(112, 208, 205)
        quaternary = {r = 48, g = 239, b = 194, a = 1.000}, --rgb(48, 239, 194)
      },

    },
    {
      type ="recipe",
      name ="iron-recrystalization-alt",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/iron-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="iron-gear-wheel", amount = 16},
        {type ="fluid", name ="sulfuric-acid", amount = 200},
      },

      energy_required = 4,
      results =
      {
        {type ="fluid", name ="iron-sulfate-solution", amount = 200},
      },
      allow_productivity = false, 
      maximum_productivity = 1,
      main_product ="iron-sulfate-solution",
      auto_recycle = false,
      crafting_machine_tint =
      {
        primary = {r = 86, g = 246, b = 230, a = 1.000}, --rgb(86, 246, 230)
        secondary = {r = 56, g = 211, b = 190, a = 1.000}, --rgb(56, 211, 190)
        tertiary = {r = 112, g = 208, b = 205, a = 1.000}, --rgb(112, 208, 205)
        quaternary = {r = 48, g = 239, b = 194, a = 1.000}, --rgb(48, 239, 194)
      },

    },
    {
      type ="recipe",
      name ="iron-stick-recrystalization",
      category ="chemistry",
      icon ="__rubia__/graphics/icons/fluid/iron-sulfate-solution.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="iron-stick", amount = 16},
        {type ="fluid", name ="sulfuric-acid", amount = 200},
      },

      energy_required = 4,
      results =
      {
        {type ="fluid", name ="iron-sulfate-solution", amount = 200},
      },
      allow_productivity = false, 
      maximum_productivity = 1,
      main_product ="iron-sulfate-solution",
      auto_recycle = false,
      crafting_machine_tint =
      {
        primary = {r = 86, g = 246, b = 230, a = 1.000}, --rgb(86, 246, 230)
        secondary = {r = 56, g = 211, b = 190, a = 1.000}, --rgb(56, 211, 190)
        tertiary = {r = 112, g = 208, b = 205, a = 1.000}, --rgb(112, 208, 205)
        quaternary = {r = 48, g = 239, b = 194, a = 1.000}, --rgb(48, 239, 194)
      },

    },

    --Space goodies
    {
      type ="recipe",
      name ="platinum-thruster",
      category ="crafting",
      icon = "__rubia__/graphics/icons/platinum-thruster-icon.png",
      enabled = false,
      ingredients =
      {
        {type = "item", name = "steel-plate", amount = 20},
        {type = "item", name = "processing-unit", amount = 12},
        {type = "item", name = "electric-engine-unit", amount = 7},
        {type = "item", name = "platinum-plate", amount = 12},
        {type = "item", name = "tungsten-plate", amount = 10},
      },

      energy_required = 10,
      results =
      {
        {type ="item", name ="platinum-thruster", amount = 1},
      },
      allow_productivity = false, 
      allow_quality = true,
      auto_recycle = true,
      main_product ="platinum-thruster",


    },
    {
      type = "recipe",
      name = "sulfur-poison-capsule",
      icon = "__rubia__/graphics/icons/poison-capsule.png",
      category ="catalytic-chemistry",
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {type = "item", name = "plastic-bar", amount = 2},
        {type = "item", name = "steel-plate", amount = 4},
        {type = "item", name = "electronic-circuit", amount = 3},
        {type = "item", name = "sulfur", amount = 10},
        {type = "fluid", name = "sulfuric-acid", amount = 50},
      },
      results = {{type="item", name="sulfur-poison-capsule", amount=1}}
    },
    {
      type = "recipe",
      name = "sulfuric-oxidizer",
      icon = "__rubia__/graphics/icons/sulfuric-oxidizer.png",
      category ="catalytic-chemistry",
      enabled = false,
      auto_recycle = false,
      energy_required = 23,
      allow_productivity = true,
      ingredients =
      {
        {type = "item", name = "solid-fuel", amount = 2},
        {type = "fluid", name = "sulfuric-acid", amount = 100},
      },
      results = {{type="item", name="sulfuric-oxidizer", amount=2}}
    },
    {
      type = "recipe",
      name = "explosives-from-sulfuric-oxidizer",
      icon = "__base__/graphics/icons/explosives.png",
      category ="catalytic-chemistry",
      enabled = false,
      auto_recycle = false,
      energy_required = 8,
      allow_productivity = true,
      ingredients =
      {
        {type = "item", name = "carbon", amount = 6},
        {type = "item", name = "sulfuric-oxidizer", amount = 1},
      },
      results = 
      {
        {type="item", name="explosives", amount=5}
      }
    },
    {
      type = "recipe",
      name = "blue-rocket",
      icon = "__rubia__/graphics/icons/blue-rocket.png",
      category ="chemistry",
      enabled = false,
      auto_recycle = true,
      energy_required = 8,
      ingredients =
      {
        {type = "item", name = "rocket", amount = 1},
        {type = "item", name = "carbon", amount = 4},
        {type = "item", name = "sulfuric-oxidizer", amount = 1},
      },
      results = 
      {
        {type="item", name="blue-rocket", amount=1}
      }
    },
    ]]
})

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
end
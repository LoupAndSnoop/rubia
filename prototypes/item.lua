local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require("__space-age__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local item_effects = require("__space-age__.prototypes.item-effects")
local meld = require("meld")
--local simulations = require("__space-age__.prototypes.factoriopedia-simulations")
local simulations_rubia = require("__rubia__.prototypes.factoriopedia-simulations")


data:extend(
{
  --#region Science
    {
      type = "tool",
      name = "biorecycling-science-pack",
      localised_description = {"item-description.science-pack"},
      icon = "__rubia__/graphics/icons/science/sphere_spiked_clear_brown.png",
      subgroup = "science-pack",
      color_hint = { text = "Y" },
      order = "l",
      inventory_move_sound = item_sounds.science_inventory_move,
      pick_sound = item_sounds.science_inventory_pickup,
      drop_sound = item_sounds.science_inventory_move,
      stack_size = 200,
      default_import_location = "rubia",
      weight = 1*kg,
      durability = 1,
      durability_description_key = "description.science-pack-remaining-amount-key",
      factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
      durability_description_value = "description.science-pack-remaining-amount-value",
      random_tint_color = item_tints.bluish_science
    },
    {
      type = "item",
      name = "makeshift-biorecycling-science-pack",
      localised_description = {"item-description.science-pack"},
      icon = "__rubia__/graphics/icons/science/torus_clear_brown.png",
      subgroup = "science-pack",
      color_hint = { text = "Y" },
      order = "l",
      inventory_move_sound = item_sounds.science_inventory_move,
      pick_sound = item_sounds.science_inventory_pickup,
      drop_sound = item_sounds.science_inventory_move,
      stack_size = 200,
      default_import_location = "rubia",
      weight = 100000*kg,
      durability = 1,
      durability_description_key = "description.science-pack-remaining-amount-key",
      factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
      durability_description_value = "description.science-pack-remaining-amount-value",
      random_tint_color = item_tints.bluish_science,
      spoil_ticks = 3 * minute,
      spoil_result = nil,
  },
  {
    type = "item",
    name = "ghetto-biorecycling-science-pack",
    localised_description = {"item-description.science-pack"},
    icon = "__rubia__/graphics/icons/science/sphere_tubed_clear_brown.png",
    subgroup = "science-pack",
    color_hint = { text = "Y" },
    order = "l",
    inventory_move_sound = item_sounds.science_inventory_move,
    pick_sound = item_sounds.science_inventory_pickup,
    drop_sound = item_sounds.science_inventory_move,
    stack_size = 200,
    default_import_location = "rubia",
    weight = 100000*kg,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    random_tint_color = item_tints.bluish_science,
    spoil_ticks = 3 * minute,
    spoil_result = nil,
},
--Science yeeting
{
  type = "item",
  name = "yeet-makeshift-biorecycling-science-pack",
  icon = "__rubia__/graphics/icons/science/yeet_torus_clear_brown.png",
  order = "l",
  subgroup = "science-pack",
  color_hint = { text = "T" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 10000*kg,
  spoil_ticks = 2,
  spoil_result = nil,
  hidden=true,
  hidden_in_factoriopedia=true,
  auto_recycle=false,
},
{
  type = "item",
  name = "yeet-ghetto-biorecycling-science-pack",
  icon = "__rubia__/graphics/icons/science/yeet_sphere_tubed_clear_brown.png",
  order = "l",
  subgroup = "science-pack",
  color_hint = { text = "T" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 10000*kg,
  spoil_ticks = 2,
  spoil_result = nil,
  hidden=true,
  hidden_in_factoriopedia=true,
  auto_recycle=false,
},
{
  type = "item",
  name = "yeet-biorecycling-science-pack",
  icon = "__rubia__/graphics/icons/science/yeet_sphere_spiked_clear_brown.png",
  order = "l",
  subgroup = "science-pack",
  color_hint = { text = "T" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 10000*kg,
  spoil_ticks = 2,
  spoil_result = nil,
  hidden=true,
  hidden_in_factoriopedia=true,
  auto_recycle=false,
},

--#endregion
--#region Intermediates and raw resources.
    {
      type = "item",
      name = "rubia-cupric-scrap",
      icon = "__rubia__/graphics/icons/rubia-cupric-scrap.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 50,
      default_import_location = "rubia",
      weight = 1000/100*kg,
    },
    {
      type = "item",
      name = "rubia-ferric-scrap",
      icon = "__rubia__/graphics/icons/rubia-ferric-scrap.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 50,
      default_import_location = "rubia",
      weight = 1000/100*kg,
    },

    {
      type = "item",
      name = "rubia-bacteria-A",
      icon = "__rubia__/graphics/icons/bacteria-typeA.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 50,
      default_import_location = "rubia",
      weight = 1000/100*kg,
      spoil_ticks = 42 * second,
      spoil_result = nil,
    },
    {
      type = "item",
      name = "rubia-bacteria-B",
      icon = "__rubia__/graphics/icons/bacteria-typeB.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 50,
      default_import_location = "rubia",
      weight = 1000/100*kg,
      spoil_ticks = 69 * second,
      spoil_result = nil,
    },
    {
      type = "item",
      name = "craptonite-chunk",
      icon = "__rubia__/graphics/icons/craptonite-icon.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 2,
      default_import_location = "rubia",
      weight = 10*kg,
    },

    {
      type = "item",
      name = "craptonite-frame",
      icon = "__rubia__/graphics/icons/craptonite-frame.png",
      order = "z[platinum]",
      subgroup = "raw-resource",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 50,
      default_import_location = "rubia",
      weight = 1000/200*kg,
  },

  --#endregion
  --#region Fluids
  {
    type = "fluid",
    name = "rubia-bacterial-sludge",
    icon = "__rubia__/graphics/icons/bacterial-sludge.png",
    subgroup = "fluid",
    default_temperature = 21,
    max_temperature = 100,
    base_color = {0,37/255,39/255},
    flow_color = {0,41/255, 36/255},
    auto_barrel = false,
  },
  {
    type = "fluid",
    name = "rubia-froth",
    icon = "__rubia__/graphics/icons/froth.png",
    subgroup = "fluid",
    default_temperature = 21,
    max_temperature = 100,
    base_color = {47/255,33/255,28/255},
    flow_color = {30/255,20/255,18/255},
    auto_barrel = true,
  },

  --#endregion
  --#region Items related to entities (pre-clear)
    {
      type = "item",
      name = "garbo-gatherer",
      icon = "__rubia__/graphics/icons/garbo-gatherer.png",
      order = "z[platinum]",
      subgroup = "production-machine",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 10,
      default_import_location = "rubia",
      weight = 1000*kg,
      place_result = "garbo-gatherer"
  },

  {
    type = "item",
    name = "biorecycling-plant",
    icon = "__rubia__/graphics/icons/biorecycling-plant-test.png",
    order = "z[platinum]",
    subgroup = "production-machine",
    color_hint = { text = "T" },

    inventory_move_sound = item_sounds.resource_inventory_move,
    pick_sound = item_sounds.resource_inventory_pickup,
    drop_sound = item_sounds.resource_inventory_move,
    stack_size = 10,
    default_import_location = "rubia",
    weight = 20*kg,
    place_result = "biorecycling-plant"
},
{
  type = "item",
  name = "crapapult",
  icon = "__rubia__/graphics/icons/crapapult-icon.png",
  icon_size = 64,
  subgroup = "production-machine",
  order = "b[turret]-a[gun-turret]",
  place_result = "crapapult",
  stack_size = 10
},

--TODO: Armored train parts

{
  type = "item",
  name = "sniper-turret",
  icon = "__rubia__/graphics/icons/sniper-turret-icon.png",
  icon_size = 64,
  subgroup = "defensive-structure",
  order = "b[turret]-a[gun-turret]",
  place_result = "sniper-turret",
  stack_size = 10
},

--#endregion
--#region Post-clear Rewards

{
  type = "item",
  name = "long-bulk-inserter",
  icon = "__rubia__/graphics/icons/long-bulk-inserter.png",
  order = "f[bulk-inserter]",
  subgroup = "inserter",
  color_hint = { text = "T" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 20*kg,
  place_result = "long-bulk-inserter"
},
{
  type = "item",
  name = "craptonite-wall",
  icon = "__rubia__/graphics/icons/crap-wall.png",
  --order = "z-a-a",
  subgroup = "defensive-structure",
  order = "a[stone-wall]-a[stone-wall]",
  color_hint = { text = "T" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 100,
  default_import_location = "rubia",
  weight = 1000/100*kg,
  place_result = "craptonite-wall"
},

  --TODO: Reinforced wall
  --TODO: T4 mod

--#endregion
}

)
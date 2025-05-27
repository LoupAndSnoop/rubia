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
      icon = "__rubia-assets__/graphics/icons/science/sphere_spiked_clear_brown.png",
      subgroup = "science-pack",
      color_hint = { text = "Y" },
      order = "n-c",
      inventory_move_sound = item_sounds.science_inventory_move,
      pick_sound = item_sounds.science_inventory_pickup,
      drop_sound = item_sounds.science_inventory_move,
      stack_size = 200,
      default_import_location = "rubia",
      weight = 1*kg / 2,
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
      icon = "__rubia-assets__/graphics/icons/science/torus_clear_brown.png",
      subgroup = "science-pack",
      color_hint = { text = "Y" },
      order = "n-a",
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
    icon = "__rubia-assets__/graphics/icons/science/sphere_tubed_clear_brown.png",
    subgroup = "science-pack",
    color_hint = { text = "Y" },
    order = "n-b",
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
  type = "tool",
  name = "rubia-biofusion-science-pack",
  localised_description = {"item-description.science-pack"},
  icon = "__rubia-assets__/graphics/icons/science/biofusion-science-pack.png",
  subgroup = "science-pack",
  color_hint = { text = "Y" },
  order = "n-d",
  inventory_move_sound = item_sounds.science_inventory_move,
  pick_sound = item_sounds.science_inventory_pickup,
  drop_sound = item_sounds.science_inventory_move,
  stack_size = 200,
  default_import_location = "rubia",
  weight = 1*kg / 2,
  durability = 1,
  durability_description_key = "description.science-pack-remaining-amount-key",
  factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
  durability_description_value = "description.science-pack-remaining-amount-value",
  random_tint_color = item_tints.bluish_science,
  spoil_ticks = 30 * minute,
  spoil_result = nil,
},

--#endregion
--#region Intermediates and raw resources.
    {
      type = "item",
      name = "rubia-cupric-scrap",
      icon = "__rubia-assets__/graphics/icons/rubia-cupric-scrap.png",
      --subgroup = "raw-resource", order = "zr[rubia]-f",
      subgroup = "rubia-biorecycling", order = "c[rubia]-a[scrap]-d",
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
      icon = "__rubia-assets__/graphics/icons/rubia-ferric-scrap.png",
      --subgroup = "raw-resource", order = "zr[rubia]-e",
      subgroup = "rubia-biorecycling", order = "c[rubia]-a[scrap]-c",
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
      icon = "__rubia-assets__/graphics/icons/bacteria-typeA.png",
      --subgroup = "raw-resource", order = "zr[rubia]-f",
      subgroup = "rubia-biorecycling", order = "c[rubia]-b[bacteria]-d",
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
      icon = "__rubia-assets__/graphics/icons/bacteria-typeB.png",
      subgroup = "rubia-biorecycling", order = "c[rubia]-b[bacteria]-e",
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
      icon = "__rubia-assets__/graphics/icons/craptonite-icon.png",
      subgroup = "rubia-biorecycling", order = "c[rubia]-d[craptonite]-d",
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
      icon = "__rubia-assets__/graphics/icons/craptonite-frame.png",
      subgroup = "rubia-biorecycling", order = "c[rubia]-d[craptonite]-e",
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
    icon = "__rubia-assets__/graphics/icons/bacterial-sludge.png",
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
    icon = "__rubia-assets__/graphics/icons/froth.png",
    subgroup = "fluid",
    default_temperature = 21,
    max_temperature = 100,
    base_color = {47/255,33/255,28/255},
    flow_color = {30/255,20/255,18/255},
    auto_barrel = false,
  },

  --#endregion
  --#region Items related to entities (pre-clear)
    {
      type = "item",
      name = "garbo-grabber",
      icon = "__rubia-assets__/graphics/icons/garbo-grabber.png",
      subgroup = "agriculture", order = "z[biter-nest]-ag[rubia]-h",
      --order = "zf[biorecycling]-e", subgroup = "production-machine",
      color_hint = { text = "T" },

      inventory_move_sound = item_sounds.resource_inventory_move,
      pick_sound = item_sounds.resource_inventory_pickup,
      drop_sound = item_sounds.resource_inventory_move,
      stack_size = 10,
      default_import_location = "rubia",
      weight = 1000*kg,
      place_result = "garbo-grabber"
  },
  {
    type = "item",
    name = "rubia-wind-turbine",
    icon = "__rubia-assets__/graphics/entity/wind-turbine/icons/k2-wind-turbine.png",
    icon_size = 64,
    subgroup = "energy",
    stack_size = 40,
    order = "a[energy-source]-a[wind-turbine]",
    place_result = "rubia-wind-turbine",
    weight = 20*kg * 1000,
    --factoriopedia_description="Converts wind power to electricity. Power scales with quality."
  },
  {
    type = "item",
    name = "biorecycling-plant",
    icon = "__rubia-assets__/graphics/icons/biorecycling-plant.png",
    subgroup = "agriculture", order = "z[biter-nest]-ag[rubia]-f",
    --order = "zf[biorecycling]-c", subgroup = "production-machine",
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
  icon = "__rubia-assets__/graphics/icons/crapapult-icon.png",
  icon_size = 64,
  subgroup = "agriculture", order = "z[biter-nest]-ag[rubia]-g",
  --subgroup = "production-machine", order = "zf[biorecycling]-d",
  place_result = "crapapult",
  stack_size = 10
},

{
  type = "item",
  name = "rubia-sniper-turret",
  icon = "__rubia-assets__/graphics/icons/sniper-turret-icon.png",
  icon_size = 64,
  subgroup = "turret",
  order = "b[turret]-a[gun-turret]-b",
  place_result = "rubia-sniper-turret",
  stack_size = 10,
  weight = 1000/20*kg,
},

{
  type = "item-with-entity-data",
  name = "rubia-armored-locomotive",
  icon = "__rubia-assets__/graphics/icons/armored-locomotive.png",
  subgroup = "train-transport",
  order = "c[rolling-stock]-a[locomotive]-r",
  inventory_move_sound = item_sounds.locomotive_inventory_move,
  pick_sound = item_sounds.locomotive_inventory_pickup,
  drop_sound = item_sounds.locomotive_inventory_move,
  place_result = "rubia-armored-locomotive",
  stack_size = 5,
  weight = 1000/5*kg,
},
{
  type = "item-with-entity-data",
  name = "rubia-armored-cargo-wagon",
  icon = "__rubia-assets__/graphics/icons/armored-cargo-wagon.png",
  subgroup = "train-transport",
  order = "c[rolling-stock]-b[cargo-wagon]-r",
  inventory_move_sound = item_sounds.metal_large_inventory_move,
  pick_sound = item_sounds.locomotive_inventory_pickup,
  drop_sound = item_sounds.metal_large_inventory_move,
  place_result = "rubia-armored-cargo-wagon",
  stack_size = 5,
  random_tint_color = item_tints.iron_rust,
  weight = 1000/5*kg,
},
{
  type = "item-with-entity-data",
  name = "rubia-armored-fluid-wagon",
  icon = "__rubia-assets__/graphics/icons/armored-fluid-wagon.png",
  subgroup = "train-transport",
  order = "c[rolling-stock]-c[fluid-wagon]-r",
  inventory_move_sound = item_sounds.fluid_inventory_move,
  pick_sound = item_sounds.fluid_inventory_pickup,
  drop_sound = item_sounds.fluid_inventory_move,
  place_result = "rubia-armored-fluid-wagon",
  stack_size = 5,
  random_tint_color = item_tints.iron_rust,
  weight = 1000/5*kg,
},

--#endregion
--#region Post-clear Rewards

{
  type = "item",
  name = "rubia-long-bulk-inserter",
  icon = "__rubia-assets__/graphics/icons/long-bulk-inserter.png",
  order = "f[bulk-inserter]-b",
  subgroup = "inserter",
  color_hint = { text = "L" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 20*kg,
  place_result = "rubia-long-bulk-inserter"
},
{
  type = "item",
  name = "rubia-long-stack-inserter",
  icon = "__rubia-assets__/graphics/icons/long-stack-inserter.png",
  order = "h[stack-inserter]-b",
  subgroup = "inserter",
  color_hint = { text = "L" },

  inventory_move_sound = item_sounds.resource_inventory_move,
  pick_sound = item_sounds.resource_inventory_pickup,
  drop_sound = item_sounds.resource_inventory_move,
  stack_size = 50,
  default_import_location = "rubia",
  weight = 1000/50*kg,
  place_result = "rubia-long-stack-inserter"
},


{
  type = "item",
  name = "craptonite-wall",
  icon = "__rubia-assets__/graphics/icons/crap-wall.png",
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

--#endregion
})
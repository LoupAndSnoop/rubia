-- Copied from Space Age resources.lua

local resource_autoplace = require("resource-autoplace")
local sounds = require("__base__.prototypes.entity.sounds")
local simulations = require("__rubia__.prototypes.factoriopedia-simulations")


--Their resource function. Not sure how call theirs without copying it, but this should work
local function resource(resource_parameters, autoplace_parameters)
  return
  {
    type = "resource",
    name = resource_parameters.name,
    icon = "__rubia__/graphics/icons/" .. resource_parameters.name .. ".png", --changed space-age to rubia
    flags = {"placeable-neutral"},
    order="a-b-"..resource_parameters.order,
    tree_removal_probability = 0.8,
    tree_removal_max_distance = 32 * 32,
    minable = resource_parameters.minable or
    {
      mining_particle = resource_parameters.name .. "-particle", --images done. rubia/particles.lua defines animations and particles. --Hopefully don't need to do anything else.
      mining_time = resource_parameters.mining_time,
      result = resource_parameters.name
    },
    category = resource_parameters.category,
    subgroup = resource_parameters.subgroup,
    walking_sound = resource_parameters.walking_sound,
    collision_mask = resource_parameters.collision_mask,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resource_patch_search_radius = resource_parameters.resource_patch_search_radius,
    autoplace = autoplace_parameters.probability_expression ~= nil and
    {
      --control = resource_parameters.name,
      order = resource_parameters.order,
      probability_expression = autoplace_parameters.probability_expression,
      richness_expression = autoplace_parameters.richness_expression
    }
    or resource_autoplace.resource_autoplace_settings
    {
      name = resource_parameters.name,
      order = resource_parameters.order,
      autoplace_control_name = resource_parameters.autoplace_control_name,
      base_density = autoplace_parameters.base_density,
      base_spots_per_km = autoplace_parameters.base_spots_per_km2,
      regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
      candidate_spot_count = autoplace_parameters.candidate_spot_count,
      tile_restriction = autoplace_parameters.tile_restriction
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages =
    {
      sheet =
      {
        filename = "__rubia__/graphics/entity/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
        priority = "extra-high",
        size = 128,
        frame_count = 8,
        variation_count = 8,
        scale = 0.5
      }
    },
    map_color = resource_parameters.map_color,
    mining_visualisation_tint = resource_parameters.mining_visualisation_tint,
    factoriopedia_simulation = resource_parameters.factoriopedia_simulation
  }
end

data:extend({
  --THIS IS FACTORIO DEVS COMMENT, LEFT FOR NOTING QUIRKS about order -ZDK
  -- Usually earlier order takes priority, but there's some special
  -- case buried in the code about resources removing other things
  -- (though maybe there shouldn't be, and we should just place things in a different order).
  -- Trees are "a", and resources will delete trees when placed.
  -- Oil is "c" so won't be placed if another resource is already there.
  -- "d" is available for another resource, but isn't used for now.

  resource(
    {
      name = "platinum-ore",
      order = "b",
      map_color = {r = 120/256, g = 120/256, b = 120/256, a = 1.000},
      mining_time = 3,
      walking_sound = sounds.ore,
      mining_visualisation_tint = {r = 150/256, g = 150/256, b = 160/256, a = 1.000},
      --category = "hard-solid", --hard solid requires big mining drill
      factoriopedia_simulation = simulations.factoriopedia_platinum_ore,
    },
    {
      probability_expression = 0
    }
  ),

  resource(
    {
      name = "sulfur-ore",
      order = "b",
      map_color = {0.8, 0.7, 0.14},
      
      walking_sound = sounds.ore,
      mining_visualisation_tint = {r = 0.99, g = 1.0, b = 0.42, a = 1.000},
      factoriopedia_simulation = simulations.factoriopedia_sulfur_ore,
      
      minable = {
        mining_particle = "sulfur-ore-particle",
        result = 'sulfur',
        mining_time = 0.8,
      },
    },
    {
      probability_expression = 0
    }
  ),

  resource(
    {
      name = "chalcopyrite-ore",
      order = "b",
      map_color = {0.2, 0.2, 0.8},
      mining_time = 1.2,
      walking_sound = sounds.ore,
      mining_visualisation_tint = {r = 100/256, g = 100/256, b = 180/256, a = 1.000},
      factoriopedia_simulation = simulations.factoriopedia_chalcopyrite_ore,

    },
    {
      probability_expression = 0
    }
  )






})
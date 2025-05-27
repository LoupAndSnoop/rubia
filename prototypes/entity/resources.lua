-- Copied from Space Age resources.lua, some from Corrundum,
-- and thanks to DoneTax for helping iron out parameters.

local resource_autoplace = require("resource-autoplace")
local sounds = require("__base__.prototypes.entity.sounds")
local simulations = require("__rubia__.prototypes.factoriopedia-simulations")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")

--Their resource function. Not sure how call theirs without copying it, but this should work
local function resource(resource_graphic,resource_parameters, autoplace_parameters)
  return
  {
    type = "resource",
    name = resource_parameters.name,
    icon = "__rubia-assets__/graphics/icons/" .. resource_parameters.name .. ".png", --changed space-age to rubia
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
    --[[autoplace = resource_autoplace.resource_autoplace_settings
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
    },]]
    autoplace = autoplace_parameters.probability_expression ~= nil and
    {
      control = resource_parameters.name,
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
      tile_restriction = autoplace_parameters.tile_restriction,
      additional_richness = autoplace_parameters.additional_richness or 0,
      --autoplace_set_name = autoplace_parameters.autoplace_set_name or resource_parameters.name,
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages =
    {
      sheet =
      {
        filename = resource_graphic,--"__rubia-assets__/graphics/terrain/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
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
  --THIS IS FACTORIO DEVS COMMENT, LEFT FOR NOTING QUIRKS about order. Thanks ZDK
  -- Usually earlier order takes priority, but there's some special
  -- case buried in the code about resources removing other things
  -- (though maybe there shouldn't be, and we should just place things in a different order).
  -- Trees are "a", and resources will delete trees when placed.
  -- Oil is "c" so won't be placed if another resource is already there.
  -- "d" is available for another resource, but isn't used for now.

  {
    type = "resource",
    name = "rubia-bacterial-sludge",
    icon = "__rubia-assets__/graphics/icons/bacterial-sludge-well-icon.png",
    icon_size = 64,
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    subgroup = "mineable-fluids",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 60000,
    normal = 300000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 12,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "rubia-bacterial-sludge",
          amount_min = 10,
          amount_max = 10,
          probability = 1
        }
      }
    },
    walking_sound = tile_sounds.walking.oil({}),
    driving_sound = tile_sounds.driving.oil,
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace = resource_autoplace.resource_autoplace_settings{
      name = "rubia-bacterial-sludge",
      order = "c", -- Other resources are "b"; oil won't get placed if something else is already there.
      base_density = 4,
      base_spots_per_km2 = 50,
      random_probability = 1/48 * 2,
      random_spot_size_minimum = 1,
      random_spot_size_maximum = 6,
      --At 220000 additional richness, base speed seems to be about 7/s
      --At 220000*50 additional richness, base speed seems to be about 350/s
      --Empirically, 220000*25 seems about right, given moduling
      additional_richness = 220000 * 25, -- this increases the total everywhere, so base_density needs to be decreased to compensate
      has_starting_area_placement = true,
      regular_rq_factor_multiplier = 1,--1.10, --0.4
      starting_rq_factor_multiplier = 1,--1.5, --0.5
      --autoplace_set_name="rubia-bacterial_sludge",
    },
    stage_counts = {0},
    stages =
    {
      sheet = util.sprite_load("__rubia-assets__/graphics/entity/bacterial-sludge/sludge-well",--"__base__/graphics/entity/crude-oil/crude-oil",
      {
        priority = "extra-high",
        scale = 0.5,
        variation_count = 1,
        frame_count = 4,
      })
    },
    draw_stateless_visualisation_under_building = false,
    stateless_visualisation =
    {
      {
        count = 1,
        render_layer = "decorative",
        animation = util.sprite_load("__rubia-assets__/graphics/entity/bacterial-sludge/sludge-well-animation",
        {
          priority = "extra-high",
          scale = 0.5,
          frame_count = 32,
          animation_speed = 0.2,
        })
      },
      {
        count = 1,
        render_layer = "smoke",
        animation = {
          filename = "__base__/graphics/entity/crude-oil/oil-smoke-outer.png",
          frame_count = 47,
          line_length = 16,
          width = 90,
          height = 188,
          animation_speed = 0.3,
          shift = util.by_pixel(-2, 24 -152),
          scale = 1.5,
          tint = util.multiply_color({r=0.3, g=0.3, b=0.3}, 0.2)
        }
      },
      {
        count = 1,
        render_layer = "smoke",
        animation = {
          filename = "__base__/graphics/entity/crude-oil/oil-smoke-inner.png",
          frame_count = 47,
          line_length = 16,
          width = 40,
          height = 84,
          animation_speed = 0.3,
          shift = util.by_pixel(0, 24 -78),
          scale = 1.5,
          tint = util.multiply_color({r=0.4, g=0.4, b=0.4}, 0.2)
        }
      }
    },
    map_color = {0.78, 0.2, 0.77},
    map_grid = false
  },
})

data:extend({
  resource("__rubia-assets__/graphics/terrain/rubia-cupric-scrap.png",
    {
      name = "rubia-cupric-scrap",
      order = "b",
      map_color = {r = 0.60, g = 0.26, b = 0.157, a = 1.000},
      mining_time = 1,
      walking_sound = sounds.ore,
      mining_visualisation_tint = {r = 150/256, g = 150/256, b = 160/256, a = 1.000},
      factoriopedia_simulation = simulations.factoriopedia_rubia_cupric_scrap,
      autoplace_control_name = "rubia-cupric-scrap",

      minable = {
        mining_particle = "cupric-scrap-particle",
        result = "rubia-cupric-scrap",
        mining_time = 0.35,
      },
    },
    { 
      --DoneTax's aid
      base_density = 5,
      base_spots_per_km2 = 3.5,
      regular_rq_factor_multiplier = 1,--1.10,
      starting_rq_factor_multiplier = 1,--1.5,
      has_starting_area_placement = false,
      additional_richness = 20000 * 5 * 3, --20k gives ore patches in the 3-6M range
      --autoplace_set_name="rubia_cupric_scrap",
    }
  ),

  resource("__rubia-assets__/graphics/terrain/rubia-ferric-scrap.png",
    {
      name = "rubia-ferric-scrap",
      order = "b",
      map_color = {0,0.34,0.61},
      
      walking_sound = sounds.ore,
      mining_visualisation_tint = {r = 100/256, g = 100/256, b = 180/256, a = 1.000},--{r = 0.99, g = 1.0, b = 0.42, a = 1.000},
      factoriopedia_simulation = simulations.factoriopedia_rubia_ferric_scrap,
      --autoplace_control_name = "rubia-ferric-scrap",

      minable = {
        mining_particle = "ferric-scrap-particle",
        result = "rubia-ferric-scrap",
        mining_time = 0.35,
      },
    },
    {
      --DoneTax's aid
      base_density = 5,
      base_spots_per_km2 = 3.5,
      regular_rq_factor_multiplier = 1,--1.10,
      starting_rq_factor_multiplier = 1,--1.5,
      has_starting_area_placement = true,
      additional_richness = 20000 * 5 * 3,
      --autoplace_set_name="rubia_ferric_scrap",
    }
  ),
})

--Autoplace controls
local u_ore_order = table.deepcopy(data.raw["autoplace-control"]["uranium-ore"].order)
data:extend({
{
  type = "autoplace-control",
  category = "resource",
  name = "rubia-ferric-scrap",
  localised_name = {"", "[item=rubia-ferric-scrap]"," ", {"item-name.rubia-ferric-scrap"}},
  order = u_ore_order.."1",
  richness = true
},
{
  type = "autoplace-control",
  category = "resource",
  name = "rubia-cupric-scrap",
  localised_name = {"", "[item=rubia-cupric-scrap]"," ", {"item-name.rubia-cupric-scrap"}},
  order = u_ore_order.."2",
  richness = true
},
{
  type = "autoplace-control",
  category = "resource",
  name = "rubia-bacterial-sludge",
  localised_name = {"", "[fluid=rubia-bacterial-sludge]"," ", {"fluid-name.rubia-bacterial-sludge"}},
  order = u_ore_order.."3",
  richness = true
}
})


--[[Noise expressions
data:extend({
{
  type = "noise-expression",
  name = "rubia-bacterial_sludge_richness",
  expression = "250000 * max(starting, gleba_simple_spot(2000, 10 * size ^ 0.5, 180 / frequency ^ 0.5, gleba_midland_aux_1) * gleba_midland_aux_1) * richness / size",
  local_expressions =
  {
    richness = "var('control:iron-ore:richness')",
    frequency = "var('control:iron-ore:frequency')",
    size = "var('control:iron-ore:size')",
    starting = "starting_spot_at_angle{ angle = gleba_starting_angle + 180 * gleba_starting_direction,\z
                                        distance = 60 * gleba_starting_area_multiplier,\z
                                        radius = 11 * size ^ 0.5,\z
                                        x_distortion = gleba_wobble_x * 10,\z
                                        y_distortion = gleba_wobble_x * 10}"
  }
},
{
  type = "noise-expression",
  name = "rubia-bacterial_sludge_probability",
  expression = "rubia-bacterial_sludge_richness > 1"
},
})]]
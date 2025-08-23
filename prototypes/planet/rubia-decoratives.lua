local base_decorative_sprite_priority = "extra-high"

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local util = require("util")
require("__rubia__.lib.lib")

--Give resistances to items on rubia so they don't get destroyed by asteroids.
local rubia_entity_resistances = {
  {type = "impact", percent = 100},
  {type = "fire", percent = 100},
}

local render_layer = {
  "zero",
  "zero",
  "zero",
  "zero",
  "ground-layer-1", --5
  "ground-layer-2", --6
  "ground-layer-3", --7
  "ground-layer-4", --8
  "ground-layer-5"
}
--Standard tint to apply to minable items to make it more clear that they are minable!
--yellowish tint: {r=1, g=1, b=0.8, a=1};
local minable_item_tint = {r=1, g=0.88, b=0.75, a=1}--{r=0.79, g=0.75, b=0.96, a=1};

--local hit_effects = require ("__base__.prototypes.entity.hit-effects")
--local base_sounds = require ("__base__.prototypes.entity.sounds")
--local base_tile_sounds = require("__base__/prototypes/tile/tile-sounds")
--local base_tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local base_placement_density = 1
--local base_decorative_order = 10

local function spritesheet_variations(count, line_length, base) return rubia_lib.spritesheet_variations(count, line_length, base) end
local function table_concat(big_table) return rubia_lib.array_concat(big_table) end

---- Collision Masks
--collision_mask = decorative_object_cliff_collision(),
-- For decoratives that render in the object layer and should not grow on cliff edges,
-- and DOES conflict with doodads/trash
local function decorative_col_mask_cliff()
  return {layers={doodad=true, cliff=true, water_tile=true}, not_colliding_with_itself=true}
end
-- For decoratives that render in the general trash layer, which can overlay
local function decorative_col_mask_overlay()
  return {layers={cliff=true, water_tile=true}, not_colliding_with_itself=true}
end
-- For decoratives that render in the general trash layer, which can overlay with trash, but not with objects or each other
local function decorative_col_mask_repulsive()
  return {layers={cliff=true, object=true, water_tile=true}, not_colliding_with_itself=false}
end


------ Decoratives
data:extend
{
  ----- Standard decoratives
  {
    name = "rubia-space-platform-decorative-tiny",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-f[tiny]",
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    minimal_separation = 0.05,
    --walking_sound = base_tile_sounds.walking.rugged_stone,
    --target_count = 300,
    render_layer = render_layer[7],
    autoplace =
    {
      --control = "rocks",
      order = "a[doodad]-a[rock]-d[small]",
      probability_expression = "multiplier * control * (region_box + rock_factor - penalty)",
      local_expressions =
      {
        multiplier = 0.5,
        penalty = 1.3,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size",
        rock_factor = 1.2
      }
    },
    pictures = spritesheet_variations(30, 10, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-tiny.png",
      width = 37,
      height = 37,
      scale = 0.5
    })
  },

  {
    name = "rubia-space-platform-decorative-1x1",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-e[1x1]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    minimal_separation = 0.19,
    target_count = 100,
    render_layer = render_layer[7],
    autoplace = {
      placement_density = base_placement_density * 1,
      probability_expression = "-1.2 + rpi(0.6) + 0.8 * grass_noise - min(0, decorative_knockout) + region_box",
      local_expressions =
      {
        region_box = "range_select{input = moisture, from = 0.5, to = 1, slope = 0.05, min = -10, max = 1}"
      }
    },
    pictures = spritesheet_variations(51, 10, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-1x1.png",
      width = 74,
      height = 74,
      scale = 0.5
    })
  },
  {
    name = "rubia-space-platform-decorative-2x2",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-d[2x2]",
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    minimal_separation = 0.5,
    target_count = 40,
    render_layer = render_layer[6],
    autoplace =
    {
      order = "a[doodad]-g[asterisk]-c",
      probability_expression = "-1.5 + rpi(0.2) + asterisk_noise - min(0, decorative_knockout) + region_box",
      local_expressions =
      {
        region_box = "min(range_select{input = moisture, from = 0.3, to = 0.6, slope = 0.05, min = -10, max = 1},\z
                          range_select{input = temperature, from = 10, to = 15, slope = 0.5, min = -10, max = 1})"
      }
    },
    pictures = spritesheet_variations(30, 10, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-2x2.png",
      width = 150,
      height = 150,
      scale = 0.5
    })
  },

  {
    name = "rubia-space-platform-decorative-pipes-1x1",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-b[pipe-1x2]",
    collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
    minimal_separation = 0.2,
    target_count = 100,
    render_layer = render_layer[5],
    autoplace =
    {
      order = "a[doodad]-f[grass]-c",
      probability_expression = "-0.6 + rpi(0.4) + grass_noise - 0.7 * min(0, decorative_knockout) + region_box",
      local_expressions =
      {
        region_box = "range_select{input = moisture, from = 0.45, to = 1, slope = 0.05, min = -10, max = 1}"
      }
    },
    pictures =  spritesheet_variations(24, 12, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-pipes-1x1.png",
      width = 64,
      height = 64,
      scale = 0.5
    })
  },
  {
    name = "rubia-space-platform-decorative-pipes-1x2",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-b[pipe-1x2]",
    collision_box = {{-0.45, -0.9}, {0.45, 0.9}},
    minimal_separation = 0.5,
    target_count = 50,
    render_layer = render_layer[5],
    autoplace =
    {
      order = "a[doodad]-fb[grass-brown]-a",
      probability_expression = "-1.2 + rpi(0.6) + (pita_noise - min(0, decorative_knockout)) + region_box",
      local_expressions =
      {
        region_box = "max(range_select{input = moisture, from = 0.3, to = 0.6, slope = 0.1, min = -10, max = 1},\z
                          min(range_select{input = moisture, from = 0.1, to = 2, slope = 0.05, min = -10, max = 1},\z
                              range_select{input = aux, from = 0.6, to = 1, slope = 0.05, min = -10, max = 1},\z
                              range_select{input = temperature, from = 14, to = 20, slope = 0.5, min = -10, max = 1}))"
      }
    },
    pictures =  spritesheet_variations(9, 9, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-pipes-1x2.png",
      width = 64,
      height = 128,
      scale = 0.5
    })
  },
  {
    name = "rubia-space-platform-decorative-pipes-2x1",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-q[pipe-2x1]",
    collision_box = {{-0.9, -0.45}, {0.9, 0.45}},
    minimal_separation = 0.5,
    target_count = 50,
    render_layer = render_layer[6],
    autoplace =
    {
      order = "a[doodad]-fb[grass-brown]-b",
      probability_expression = "-1 + rpi(0.4) + pita_noise - 0.5 * min(0, decorative_knockout) + region_box",
      local_expressions =
      {
        region_box = "range_select{input = moisture, from = 0.35, to = 0.8, slope = 0.1, min = -10, max = 1}"
      }
    },
    pictures = spritesheet_variations(7, 7, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-pipes-2x1.png",
      width = 128,
      height = 64,
      scale = 0.5
    })
  },

  ---
  ------- Decorative entities for forage
  ---
  --[[
  {
    name = "rubia-med-rock",
    type = "simple-entity",
    flags = {"placeable-neutral", "placeable-off-grid"},
    icon = "__base__/graphics/icons/big-rock.png",
    subgroup = "grass",
    order = "b[decorative]-l[rock]-b[big]",
    collision_box = {{-1.0, -0.9}, {1.0, 1.0}},
    selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.big_rock(),
    minable =
    {
      mining_particle = "stone-particle",
      mining_time = 2,
      result = "stone",
      count = 20
    },
    map_color = {129, 105, 78},
    count_as_rock_for_filtered_deconstruction = true,
    mined_sound = sounds.deconstruct_bricks(1.0),
    impact_category = "stone",
    render_layer = "object",
    max_health = 500,
    resistances = rubia_entity_resistances,
    autoplace = -- medium rock
    {
      control = "rocks",
      order = "a[doodad]-a[rock]-c[medium]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.4,
        penalty = 1.4,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },
    pictures =
    {
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-01.png",
        width = 188,
        height = 127,
        scale = 0.5,
        shift = {-0.046875, 0.171875}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-02.png",
        width = 195,
        height = 135,
        scale = 0.5,
        shift = {0.445312, 0.125}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-03.png",
        width = 205,
        height = 132,
        scale = 0.5,
        shift = {0.484375, 0.0546875}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-04.png",
        width = 144,
        height = 142,
        scale = 0.5,
        shift = {0.210938, 0.0390625}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-05.png",
        width = 130,
        height = 107,
        scale = 0.5,
        shift = {0.0234375, 0.226562}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-06.png",
        width = 165,
        height = 109,
        scale = 0.5,
        shift = {0.15625, 0.226562}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-07.png",
        width = 150,
        height = 133,
        scale = 0.5,
        shift = {0.257812, 0.148438}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-08.png",
        width = 156,
        height = 111,
        scale = 0.5,
        shift = {0.0859375, 0.179688}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-09.png",
        width = 187,
        height = 120,
        scale = 0.5,
        shift = {0.078125, 0.0859375}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-10.png",
        width = 225,
        height = 128,
        scale = 0.5,
        shift = {-0.15625, 0.0703125}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-11.png",
        width = 183,
        height = 144,
        scale = 0.5,
        shift = {0.195312, 0.257812}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-12.png",
        width = 158,
        height = 138,
        scale = 0.5,
        shift = {0.0390625, 0.15625}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-13.png",
        width = 188,
        height = 150,
        scale = 0.5,
        shift = {0.226562, 0.21875}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-14.png",
        width = 186,
        height = 160,
        scale = 0.5,
        shift = {0.132812, 0.0625}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-15.png",
        width = 181,
        height = 174,
        scale = 0.5,
        shift = {0.304688, -0.09375}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-16.png",
        width = 212,
        height = 150,
        scale = 0.5,
        shift = {0.335938, 0.117188}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-17.png",
        width = 155,
        height = 117,
        scale = 0.5,
        shift = {0.25, 0.0390625}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-18.png",
        width = 141,
        height = 128,
        scale = 0.5,
        shift = {0.304688, 0.0390625}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-19.png",
        width = 176,
        height = 114,
        scale = 0.5,
        shift = {0.390625, 0.0234375}
      },
      {
        filename = "__base__/graphics/decorative/big-rock/big-rock-20.png",
        width = 120,
        height = 125,
        scale = 0.5,
        shift = {0.148438, 0.03125}
      }
    }
  },]]

    {
    type = "simple-entity",
    name = "rubia-spidertron-remnants",
    icons = {{icon = "__base__/graphics/icons/spidertron.png",
      icon_size = 64,
      tint = {r=0.5,g=0.5,b=0.5,a=1}}},
    flags = {"placeable-neutral", "placeable-off-grid"},
    --hidden_in_factoriopedia = true,
    subgroup = "transport-remnants",
    order = "b[decorative]-l[rock]-b[big]-999",
    selection_box = {{-2, -2}, {2, 2}},
    collision_box = {{-1, -1}, {1, 1}},
    minimal_separation = 500,
    tile_width = 2,
    tile_height = 2,
    render_layer = "object",

    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.big_rock(),
    minable =
    {
      mining_particle = "iron-ore-particle",
      mining_time = 3.5,
      results =
      {
        --Important drops
        {type = "item", name = "construction-robot", amount_min = 1, amount_max = 4},
        {type = "item", name = "steel-plate", amount_min = 3, amount_max = 7},
        {type = "item", name = "advanced-circuit", probability = 0.3, amount_min = 8, amount_max = 15},
        {type = "item", name = "gun-turret", probability=0.4, amount_min = 5, amount_max = 7},
        {type = "item", name = "electric-furnace", probability=0.4, amount_min = 1, amount_max = 3},
        --Fun/helpful drops
        {type = "item", name = "fast-inserter", probability = 0.1, amount_min = 20, amount_max = 40},
        {type = "item", name = "fast-transport-belt", probability = 0.25, amount_min = 50, amount_max = 65},
        {type = "item", name = "underground-belt", probability = 0.12, amount_min = 20, amount_max = 30},
        {type = "item", name = "express-splitter", probability = 0.2, amount_min = 8, amount_max = 12},
        {type = "item", name = "pipe-to-ground", probability = 0.1, amount_min = 16, amount_max = 32},
        {type = "item", name = "assembling-machine-2", probability = 0.1, amount_min = 7, amount_max = 12},
        {type = "item", name = "electric-mining-drill", probability = 0.07, amount_min = 10, amount_max = 20},
        {type = "item", name = "efficiency-module", probability = 0.1, amount_min = 15, amount_max = 30},
        {type = "item", name = "speed-module-2", probability = 0.1, amount_min = 15, amount_max = 25},
        {type = "item", name = "spoilage", probability = 0.03, amount_min = 1, amount_max = 1}
      },
    },
    
    max_health = 500,
    resistances = rubia_entity_resistances,
    autoplace = --Mimic huge rock
    {
      --control = "rocks",
      order = "a[doodad]-a[rock]-a[huge]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.07 * 0.4 * 4,
        penalty = 1.7,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },

    animations =
    {
      layers = {
      {
        filename = "__base__/graphics/entity/spidertron/remnants/spidertron-remnants.png",
        line_length = 1,
        width = 448,
        height = 448,
        direction_count = 1,
        shift = util.by_pixel(0, 0),
        tint = minable_item_tint,
        scale = 0.5
      },
      {
        priority = "low",
        filename = "__base__/graphics/entity/spidertron/remnants/mask/spidertron-remnants-mask.png",
        width = 366,
        height = 350,
        apply_runtime_tint = true,
        direction_count = 1,
        shift = util.by_pixel(9, 1),
        tint = minable_item_tint,
        scale = 0.5
      }
    }
    }
  },


  {
    type = "simple-entity",
    name = "rubia-pole-remnants",
    --icon = "__base__/graphics/icons/train-stop.png",
    icons = {{icon = "__base__/graphics/icons/train-stop.png",
      icon_size = 64,
      tint = {r=0.5,g=0.5,b=0.5,a=1}}},
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = false,
    subgroup = "train-transport-remnants",
    order = "b[decorative]-l[rock]-b[medium]-999",
    selection_box = {{-1, -1}, {1, 1}},
    collision_box = {{-1, -1}, {1, 1}},
    tile_width = 2,
    tile_height = 2,
    
    render_layer = "object",
    final_render_layer = "object",
    animation_overlay_final_render_layer = "object",
    remove_on_tile_placement = false,

    max_health = 500,
    resistances = rubia_entity_resistances,
    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.big_rock(),
    minable =
    {
      mining_particle = "iron-ore-particle",
      mining_time = 2.5,
      results =
      {
        {type = "item", name = "iron-stick", amount_min = 4, amount_max = 8},
        {type = "item", name = "iron-plate", probability=0.7, amount_min = 5, amount_max = 10},
        {type = "item", name = "steel-plate", probability=0.5, amount_min = 4, amount_max = 8},
        {type = "item", name = "copper-cable", probability=0.5, amount_min = 8, amount_max = 12},
        {type = "item", name = "electronic-circuit", probability=0.5, amount_min = 4, amount_max = 8}
      },
    },
    
    autoplace = -- medium rocks
    {
      --control = "rocks",
      order = "a[doodad]-a[rock]-c[medium]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.4 * 0.25,
        penalty = 1.4,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },

    lower_pictures =
        {
          filename = "__rubia-assets__/graphics/entity/remnants/train-stop-base-remnants.png",--"__base__/graphics/entity/train-stop/remnants/train-stop-base-remnants.png",
          line_length = 1,
          width = 486,
          height = 454,
          shift = util.by_pixel(4.5, 13.5),
          variation_count = 4,
          scale = 0.5,
          --tint = minable_item_tint
        },
      pictures = 
      {
        filename = "__rubia-assets__/graphics/entity/remnants/train-stop-top-remnants.png",--"__base__/graphics/entity/train-stop/remnants/train-stop-top-remnants.png",
        line_length = 1,
        width = 136,
        height = 254,
        shift = util.by_pixel(1.5, -38),
        variation_count = 4,
        scale = 0.5,
        --tint = {r=1, g=0.7, b=0.6, a=1}-- Needs a unique tint to be visible. Not just minable_item_tint
      }

    --[[animations =
    {
      layers =
      {
        {
          filename = "__rubia-assets__/graphics/entity/remnants/train-stop-base-remnants.png",--"__base__/graphics/entity/train-stop/remnants/train-stop-base-remnants.png",
          line_length = 1,
          width = 486,
          height = 454,
          shift = util.by_pixel(4.5, 13.5),
          direction_count = 4,
          scale = 0.5,
          --tint = minable_item_tint
        },
        {
          priority = "low",
          filename = "__rubia-assets__/graphics/entity/remnants/train-stop-base-remnants-mask.png",--"__base__/graphics/entity/train-stop/remnants/mask/train-stop-base-remnants-mask.png",
          width = 284,
          height = 214,
          --apply_runtime_tint = true,
          direction_count = 4,
          shift = util.by_pixel(-1, 0.5),
          scale = 0.5,
          --tint = minable_item_tint
        },
        {
          filename = "__rubia-assets__/graphics/entity/remnants/train-stop-top-remnants.png",--"__base__/graphics/entity/train-stop/remnants/train-stop-top-remnants.png",
          line_length = 1,
          width = 136,
          height = 254,
          shift = util.by_pixel(1.5, -38),
          direction_count = 4,
          scale = 0.5,
          --tint = {r=1, g=0.7, b=0.6, a=1}-- Needs a unique tint to be visible. Not just minable_item_tint
        }
      }
    }]]
  },

  {
    type = "simple-entity",
    name = "rubia-junk-pile",
    --icon = "__space-age__/graphics/icons/asteroid-collector.png",
    icons = {{icon = "__space-age__/graphics/icons/asteroid-collector.png",
      icon_size = 64,
      tint = {r=0.5,g=0.5,b=0.5,a=1}}},
    flags = {"placeable-neutral", "not-on-map"},
    --hidden_in_factoriopedia = true,
    subgroup = "space-platform-remnants",
    order = "c",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},--{{-0.45, -0.45}, {0.45, 0.45}},
    tile_width = 1,
    tile_height = 1,
    final_render_layer = "object",
    remove_on_tile_placement = false,

    max_health = 500,
    resistances = rubia_entity_resistances,
    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.big_rock(),
    minable =
    {
      mining_particle = "iron-ore-particle",
      mining_time = 2.5, --3
      results =
      {
        {type = "item", name = "iron-gear-wheel", amount_min = 2, amount_max = 4},
        {type = "item", name = "iron-gear-wheel", probability=0.2, amount_min = 35, amount_max = 50},
        {type = "item", name = "iron-plate", probability=0.4, amount_min = 30, amount_max = 50},
        {type = "item", name = "firearm-magazine", probability=0.5, amount_min = 20, amount_max = 40},
        {type = "item", name = "copper-cable", probability=0.7, amount_min = 20, amount_max = 40},
        {type = "item", name = "steel-plate", probability=0.15, amount_min = 30, amount_max = 40},
        --{type = "item", name = "pipe", probability=0.1, amount_min = 30, amount_max = 40},
        --{type = "item", name = "stone-brick", probability=0.3, amount_min = 20, amount_max = 40},
      }
    },

    --[[
    animations = util.sprite_load("__space-age__/graphics/entity/asteroid-collector/asteroid-collector-remnants",{
      scale = 0.5,
      direction_count = 4,
      line_length = 1,
      tint = minable_item_tint
    }),]]
    pictures = 
    {
        filename = "__space-age__/graphics/entity/asteroid-collector/asteroid-collector-remnants.png",
        width = 316,
        height = 324,
        shift = util.by_pixel( 0.0, 19.5),
        line_length = 1,
        variation_count = 4,
        scale = 0.5,
        tint = minable_item_tint
      },
  


    autoplace = { --Vulc chimney truncated
      order = "a[landscape]-b[chimney]-b[truncated]-d",
      probability_expression = "multiplier * (max( min(0.05, 2 * (vulcanus_mountains_biome - 0.5)\z
      - 2.1 + 1.2 * min(aux, 1 - moisture) + vulcanus_rock_noise - 0.5 * vulcanus_decorative_knockout),\z
      min(0.05, 2 * (vulcanus_ashlands_biome - 0.5)\z
      - 2.3 + 1.2 * min(aux, 1 - moisture) + vulcanus_rock_noise - 0.5 * vulcanus_decorative_knockout)))",
      local_expressions ={multiplier=0.3 * 1.3}
    },    
    
    --[[-- medium rocks
    {
      control = "rocks",
      order = "a[doodad]-a[rock]-c[medium]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.4 * 0.1,
        penalty = 1.4,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },]]
  },


  ----- Decorative remnants, no forage
  {
    type = "optimized-decorative",
    name = "rubia-construction-robot-remnants",
    icon = "__base__/graphics/icons/construction-robot.png",
    flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
    hidden_in_factoriopedia = true,
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 3,
    tile_height = 3,
    --selectable_in_game = false,
    --subgroup = "remnants",
    order="d[remnants]-a[generic]-a[small]",
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    pictures = rubia_lib.array_concat({rubia_lib.spritesheet_variations(3, 1, {
      filename = "__base__/graphics/entity/construction-robot/remnants/construction-robot-remnants.png",
      --line_length = 1,
      width = 120,
      height = 114,
      direction_count = 1,
      shift = util.by_pixel(2, 1),
      scale = 0.5
    }),
    rubia_lib.spritesheet_variations(3, 1, {
      filename = "__base__/graphics/entity/logistic-robot/remnants/logistic-robot-remnants.png",
      --line_length = 1,
      width = 116,
      height = 114,
      direction_count = 1,
      shift = util.by_pixel(1, 1),
      scale = 0.5
    }),
    rubia_lib.spritesheet_variations(3, 1, {
      filename = "__base__/graphics/entity/distractor-robot/remnants/distractor-robot-remnants.png",
      --line_length = 1,
      width = 112,
      height = 110,
      direction_count = 1,
      shift = util.by_pixel(-0.5, 0),
      scale = 0.5
    })}),
    autoplace =
    {
      --control = "rocks",
      order = "a[doodad]-a[rock]-b[big]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.17 * 3,
        penalty = 1.6,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },
  },

  {
    type = "optimized-decorative",
    name = "rubia-medium-junk-remnants",
    icon = "__base__/graphics/icons/radar.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    --subgroup = "defensive-structure-remnants",
    order = "d[remnants]-a[generic]-a[medium]",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = decorative_col_mask_repulsive(),
    minimal_separation = 0.4,
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    --expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    pictures = table_concat({spritesheet_variations(1, 1,
    { --Radar
      filename = "__base__/graphics/entity/radar/remnants/radar-remnants.png",
      --line_length = 1,
      width = 282,
      height = 212,
      direction_count = 1,
      shift = util.by_pixel(12, 4.5),
      scale = 0.5
    }),
    spritesheet_variations(4, 1,{ --Elec mining drill
      filename = "__base__/graphics/entity/electric-mining-drill/remnants/electric-mining-drill-remnants.png",
      --line_length = 1,
      width = 356,
      height = 328,
      direction_count = 1,
      shift = util.by_pixel(7, -0.5),
      scale = 0.5
    }),
    spritesheet_variations(3, 1,{ --Rocket turret
    filename = "__rubia-assets__/graphics/entity/remnants/rocket-turret-remnants.png",
    --"__space-age__/graphics/entity/rocket-turret/remnants/rocket-turret-remnants.png",
    --line_length = 1,
    width = 222,
    height = 222,
    direction_count = 1,
    shift = util.by_pixel(7, -0.5),
    scale = 0.5
    }),
    spritesheet_variations(1, 1,{ --EMP
          filename = "__space-age__/graphics/entity/electromagnetic-plant/remnants/electromagnetic-plant-remnants.png",
          width = 558, --558x434
          height = 434,
          --frame_count = 1,
          direction_count = 1,
          scale = 0.4
    }),
    spritesheet_variations(1, 1,{ --cryo plant
    filename = "__space-age__/graphics/entity/cryogenic-plant/remnants/cryogenic-plant-remnants.png",
    width = 370,
    height = 354,
    --frame_count = 1,
    direction_count = 1,
    scale = 0.5
}),
    spritesheet_variations(2,1, --Roboport
    {
      filename = "__base__/graphics/entity/roboport/remnants/roboport-remnants.png",
      line_length = 1,
      width = 364,
      height = 358,
      direction_count = 1,
      shift = util.by_pixel(2, 8),
      scale = 0.5
    }),
    {{ --burner drill
      filename = "__base__/graphics/entity/burner-mining-drill/remnants/burner-mining-drill-remnants.png",
      line_length = 1,
      width = 272,
      height = 234,
      direction_count = 1,
      shift = util.by_pixel(-0.5, -4.5),
      scale = 0.5
    }}
  }
  ),
    autoplace = 
    { -- Mimic medium rock
      --control = "rocks",
      order = "a[doodad]-a[rock]-c[medium]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.4,
        penalty = 1.4,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },
  },

  {
    type = "optimized-decorative",
    name = "rubia-medium-remnants",
    localised_name = {"entity-name.medium-remnants"},
    icon = "__base__/graphics/icons/remnants.png",
    hidden_in_factoriopedia = true,
    flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
    --subgroup = "generic-remnants",
    order = "d[remnants]-a[generic]-a[medium]",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = decorative_col_mask_overlay(),
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    --expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    pictures = spritesheet_variations(4,1,
    {
      filename = "__base__/graphics/entity/remnants/medium-remnants.png",
      --line_length = 1,
      width = 236,
      height = 246,
      direction_count = 1,
      shift = util.by_pixel(0, -4.5),
      scale = 0.5
    }),
    autoplace =
    {
      probability_expression = "0.005 + clamp(-1.5 + noise_layer_noise('sand-decal')\z
                                      + min(range_select(moisture, 0.1, 1, 0.05, -1, 1),\z
                                            range_select(aux, 0.4, 0.9, 0.05, -1, 1)),\z
                                      0, 0.01)"
    },
  },

  {
    type = "optimized-decorative",
    name = "rubia-pump-remnants",
    icon = "__base__/graphics/icons/pump.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    --subgroup = "energy-pipe-distribution-remnants",
    order = "d[remnants]-a[generic]-a[medium]",
    selection_box = {{-0.5, -1}, {0.5, 1}},
    collision_box = {{-0.5, -1}, {0.5, 1}},
    collision_mask = decorative_col_mask_repulsive(),
    tile_width = 1,
    tile_height = 2,
    selectable_in_game = false,
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    --expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    pictures = {{
      filename = "__base__/graphics/entity/pump/remnants/pump-remnants.png",
      line_length = 1,
      width = 188,
      height = 186,
      direction_count = 4,
      shift = util.by_pixel(2, 2),
      scale = 0.5
    }},
    autoplace =
    {
      probability_expression = "clamp(-1.5 + noise_layer_noise('sand-decal')\z
                                      + min(range_select(moisture, 0.1, 1, 0.05, -1, 1),\z
                                            range_select(aux, 0.4, 0.9, 0.05, -1, 1)),\z
                                      0, 0.01)"
    }
  },

  {
    type = "optimized-decorative",
    name = "rubia-heat-exchanger-remnants",
    icon = "__base__/graphics/icons/heat-boiler.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    --subgroup = "energy-remnants",
    order = "d[remnants]-a[generic]-a[big]",
    selection_box = {{-1.5, -1}, {1.5, 1}},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = decorative_col_mask_repulsive(),
    tile_width = 3,
    tile_height = 2,
    selectable_in_game = false,
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    --expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    pictures =
    {
      filename = "__base__/graphics/entity/heat-exchanger/remnants/heat-exchanger-remnants.png",
      line_length = 1,
      width = 272,
      height = 262,
      direction_count = 4,
      shift = util.by_pixel(0.5, 8),
      scale = 0.5
    },
    autoplace = -- Big rock
    {
      --control = "rocks",
      order = "a[doodad]-a[rock]-b[big]",
      probability_expression = "multiplier * control * (region_box + rock_density - penalty)",
      local_expressions =
      {
        multiplier = 0.17,
        penalty = 1.6,
        region_box = "range_select_base(moisture, 0.35, 1, 0.2, -10, 0)",
        control = "control:rocks:size"
      }
    },
  }
}

--[[
--mimic sand dune. Good for rare bundles.
autoplace = {
  probability_expression = "-0.8 - 0.4 * min(0.5, abs(grass_noise)) + 0.04 * noise_layer_noise('sand-decal')\z
                                  + min(range_select(moisture, 0, 0.15, 0.4, -10, 1),\z
                                        range_select(aux, 0.0, 0.25, 0.4, -10, 1))"
}
]]


--[[
  {
    name = "mycelium",
    type = "optimized-decorative",
    order = "XxX[decorative]-a[grass]-b[carpet]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = dec_default_collision(),
    walking_sound = base_tile_sounds.walking.plant,
    render_layer = "decals",
    tile_layer = decal_tile_layer - 1,
    trigger_effect = decorative_trigger_effects.brown_carpet_grass(),
    autoplace = {
      probability_expression = "grpi(0.5) + gleba_select(gleba_mycelium - clamp(gleba_decorative_knockout, 0, 1), 0.1, 2, 0.2, 0, 1)"
    },
    pictures = get_decal_pictures("__space-age__/graphics/decorative/mycelium/mycelium-", "",
     512,
      16)
  },
  ]]
  --[[{
    name = "space-platform-decorative-4x4",
    type = "optimized-decorative",
    order = "b[decorative]-b[space-platform-decal]-c[4x4]",
    collision_box = {{-1.9, -1.9}, {1.9, 1.9}},
    minimal_separation = 3.0,
    target_count = 4,
    render_layer = render_layer[5],
    pictures = spritesheet_variations(7, 4, {
      filename = "__space-age__/graphics/decorative/space-platform-decorative/space-platform-decorative-4x4.png",
      width = 300,
      height = 300,
      scale = 0.5
    })

  },]]

  --[[
  {
    type = "optimized-decorative",
    name = "rubia-logistic-robot-remnants",
    icon = "__base__/graphics/icons/logistic-robot.png",
    flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
    hidden_in_factoriopedia = true,
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    subgroup = "remnants",
    order="d[remnants]-a[generic]-a[small]",
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet (3,
    {
      filename = "__base__/graphics/entity/logistic-robot/remnants/logistic-robot-remnants.png",
      line_length = 1,
      width = 116,
      height = 114,
      direction_count = 1,
      shift = util.by_pixel(1, 1),
      scale = 0.5
    })
  },

  {
    type = "optimized-decorative",
    name = "rubia-distractor-remnants",
    icon = "__base__/graphics/icons/distractor.png",
    flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
    hidden_in_factoriopedia = true,
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    subgroup = "remnants",
    order="d[remnants]-a[generic]-a[small]",
    --time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet (3,
    {
      filename = "__base__/graphics/entity/distractor-robot/remnants/distractor-robot-remnants.png",
      line_length = 1,
      width = 112,
      height = 110,
      direction_count = 1,
      shift = util.by_pixel(-0.5, 0),
      scale = 0.5
    })
  },]]
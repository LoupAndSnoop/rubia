require("__rubia__.lib.lib")


local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")
local simulations = require("__base__.prototypes.factoriopedia-simulations")
local util = require("util")
--local explosion_animations = require("__space-age__/prototypes/entity/explosion-animations")

--Standard resistances
local function trashsteroid_resistances() 
    return     {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "impact",
          percent = 100,
          --decrease = 50
        },
        {
          type = "laser",
          percent = 60
        },
        {
            type = "electric",
            percent = 100
        }
      }
end


--This file defines trashsteroids.
-- __rubia__/graphics/entity/
data:extend({

{
    type = "car",
    name = "medium-trashsteroid",
    icon = "__rubia__/graphics/icons/trashsteroid-chunk-icon.png",--"__base__/graphics/icons/car.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-flammable", "get-by-unit-number"},
    --minable = {mining_time = 0.4, result = "car"},
    --mined_sound = sounds.deconstruct_medium(0.8),
    max_health = 450,
    is_military_target = true,
    deliver_category = "vehicle",
    --corpse = "car-remnants",
    dying_explosion = "carbonic-asteroid-explosion-3",--"car-explosion",
    alert_icon_shift = util.by_pixel(0, -13),
    energy_per_hit_point = 1,
    minimap_representation =     {
        filename = "__rubia__/graphics/icons/trashsteroid-minimap-representation.png",
        flags = {"icon"},
        size = {20, 20},
        scale = 0.5
    },
    --crash_trigger = crash_trigger(),
    resistances = trashsteroid_resistances(),
    collision_box = {{-0.75, -0.75}, {0.75, 0.75}},
    selection_box = {{-0.75, -0.75}, {0.75, 0.75}},
    collision_mask= {layers={}},
    damaged_trigger_effect = hit_effects.entity(),
    effectivity = 0,--0.6,
    braking_power = "200kW",
    energy_source = {type = "void"},
    consumption = "150kW",
    friction = 1e-4,--2e-3,
    render_layer = "air-object",

    animation = {layers = rubia_lib.make_rotated_animation_variations_from_sheet(6,{
        filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid.png",
        line_length = 6,
        width = 230,
        height = 230,
        direction_count = 1,
        shift = util.by_pixel(0, 3.5),
        scale = 0.3
    }), rubia_lib.make_rotated_animation_variations_from_sheet(6,{
        filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid-shadow.png",
        line_length = 6,
        width = 230,
        height = 230,
        direction_count = 1,
        shift = util.by_pixel(0+10, 3.5+10),
        scale = 0.3
    })
    },

    --[[
    {
      layers =
      {
        {
          priority = "low",
          width = 201,
          height = 172,
          frame_count = 2,
          scale = 0.5,
          direction_count = 64,
          shift = util.by_pixel(0+2, -11.5+8.5),
          animation_speed = 8,
          max_advance = 0.2,
          stripes =
          {
          {
          filename = "__base__/graphics/entity/car/car-1.png",
          width_in_frames = 2,
          height_in_frames = 11
          },
          {
          filename = "__base__/graphics/entity/car/car-2.png",
          width_in_frames = 2,
          height_in_frames = 11
          },
          {
          filename = "__base__/graphics/entity/car/car-3.png",
          width_in_frames = 2,
          height_in_frames = 11
          },
          {
          filename = "__base__/graphics/entity/car/car-4.png",
          width_in_frames = 2,
          height_in_frames = 11
          },
          {
          filename = "__base__/graphics/entity/car/car-5.png",
          width_in_frames = 2,
          height_in_frames = 11
          },
          {
          filename = "__base__/graphics/entity/car/car-6.png",
          width_in_frames = 2,
          height_in_frames = 9
          }
          }
        },
        {
          priority = "low",
          width = 199,
          height = 147,
          frame_count = 2,
          apply_runtime_tint = true,
          scale = 0.5,
          direction_count = 64,
          max_advance = 0.2,
          shift = util.by_pixel(0+2, -11+8.5),
          line_length = 1,
          stripes = util.multiplystripes(2,
          {
          {
          filename = "__base__/graphics/entity/car/car-mask-1.png",
          width_in_frames = 1,
          height_in_frames = 13
          },
          {
          filename = "__base__/graphics/entity/car/car-mask-2.png",
          width_in_frames = 1,
          height_in_frames = 13
          },
          {
          filename = "__base__/graphics/entity/car/car-mask-3.png",
          width_in_frames = 1,
          height_in_frames = 13
          },
          {
          filename = "__base__/graphics/entity/car/car-mask-4.png",
          width_in_frames = 1,
          height_in_frames = 13
          },
          {
          filename = "__base__/graphics/entity/car/car-mask-5.png",
          width_in_frames = 1,
          height_in_frames = 12
          }
          })
        },
        {
          priority = "low",
          width = 114,
          height = 76,
          frame_count = 2,
          draw_as_shadow = true,
          direction_count = 64,
          shift = {0.28125, 0.25},
          max_advance = 0.2,
          stripes = util.multiplystripes(2,
          {
            {
              filename = "__base__/graphics/entity/car/car-shadow-1.png",
              width_in_frames = 1,
              height_in_frames = 22
            },
            {
              filename = "__base__/graphics/entity/car/car-shadow-2.png",
              width_in_frames = 1,
              height_in_frames = 22
            },
            {
              filename = "__base__/graphics/entity/car/car-shadow-3.png",
              width_in_frames = 1,
              height_in_frames = 20
            }
          })
        }
      }
    },]]

    --turret_rotation_speed = 0.35 / 60,
    --sound_no_fuel = { filename = "__base__/sound/fight/car-no-fuel-1.ogg", volume = 0.6 },
    stop_trigger_speed = 0.15,
    stop_trigger =
    {
      {
        type = "play-sound",
        sound = {filename = "__base__/sound/car-breaks.ogg", volume = 0.2 }
      }
    },
    impact_category = "metal",
    impact_speed_to_volume_ratio = 4.0,
    --[[
    working_sound =
    {
      main_sounds =
      {
        {
          sound = {filename = "__base__/sound/car-engine-driving.ogg", volume = 0.67, modifiers = volume_multiplier("main-menu", 2.2)},
          match_volume_to_activity = true,
          activity_to_volume_modifiers =
          {
            multiplier = 1.8,
            offset = 0.95,
          },
          match_speed_to_activity = true,
          activity_to_speed_modifiers =
          {
            multiplier = 0.8,
            minimum = 1.0,
            maximum = 1.4,
            offset = 0.1,
          }
        },
        {
          sound = { filename = "__base__/sound/car-engine.ogg", volume = 0.67 },
          match_volume_to_activity = true,
          fade_in_ticks = 22,
          activity_to_volume_modifiers =
          {
            multiplier = 2.4,
            offset = 1.5,
            inverted = true
          }
        },
      },
      activate_sound = { filename = "__base__/sound/car-engine-start.ogg", volume = 0.67 },
      deactivate_sound = { filename = "__base__/sound/car-engine-stop.ogg", volume = 0.67 },
    },]]
    rotation_speed = 0.015,
    weight = 700,
    inventory_size = 0,
  }
})

  --[[  {
    type = "fluid-wagon",
    name = "medium-trashsteroid",
    icon = "__base__/graphics/icons/fluid-wagon.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "get-by-unit-number"},
    minable = {mining_time = 0.5, result = "fluid-wagon"},
    mined_sound = sounds.deconstruct_large(0.8),
    max_health = 600,
    capacity = 50000,
    deliver_category = "vehicle",
    corpse = "fluid-wagon-remnants",
    dying_explosion = "fluid-wagon-explosion",
    factoriopedia_simulation = simulations.factoriopedia_fluid_wagon,
    collision_box = {{-0.6, -2.4}, {0.6, 2.4}},
    selection_box = {{-1, -2.703125}, {1, 3.296875}},
    damaged_trigger_effect = hit_effects.entity(),
    vertical_selection_shift = -0.796875,
    icon_draw_specification = {scale = 1.25, shift = {0, -1}},
    weight = 1000,
    max_speed = 1.5,
    braking_force = 3,
    friction_force = 0.50,
    air_resistance = 0.01,
    connection_distance = 3,
    joint_distance = 4,
    energy_per_hit_point = 6,
    resistances =
    {
      {
        type = "fire",
        decrease = 15,
        percent = 50
      },
      {
        type = "physical",
        decrease = 15,
        percent = 30
      },
      {
        type = "impact",
        decrease = 50,
        percent = 60
      },
      {
        type = "explosion",
        decrease = 15,
        percent = 30
      },
      {
        type = "acid",
        decrease = 3,
        percent = 20
      }
    },
    --back_light = rolling_stock_back_light(),
    --stand_by_light = rolling_stock_stand_by_light(),
    color = {r = 0.43, g = 0.23, b = 0, a = 0.5},
    pictures =
    {
      rotated =
      {
        layers =
        {
          util.sprite_load("__base__/graphics/entity/fluid-wagon/fluid-wagon",
            {
              dice = 4,
              priority = "very-low",
              allow_low_quality_rotation = true,
              back_equals_front = true,
              direction_count = 128,
              scale = 0.5,
              usage = "train"
            }
          ),
          util.sprite_load("__base__/graphics/entity/fluid-wagon/fluid-wagon-shadow",
            {
              dice = 4,
              priority = "very-low",
              allow_low_quality_rotation = true,
              back_equals_front = true,
              draw_as_shadow = true,
              direction_count = 128,
              scale = 0.5,
              usage = "train"
            }
          )
        }
      }
    },
    minimap_representation =
    {
      filename = "__base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    selected_minimap_representation =
    {
      filename = "__base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-selected-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    --wheels = standard_train_wheels,
    --drive_over_tie_trigger = drive_over_tie(),
    drive_over_tie_trigger_minimal_speed = 0.5,
    tie_distance = 50,
    working_sound = sounds.train_wagon_wheels,
    --crash_trigger = crash_trigger(),
    impact_category = "metal-large",
    --water_reflection = locomotive_reflection()
  }
})
]]
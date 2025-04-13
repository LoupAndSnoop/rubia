--Basic settings brought in from ultracube for the graphics.

local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")
--require("__Ultracube__/prototypes/entities/lib/pipe")
--require("__Ultracube__/prototypes/entities/lib/module_effects")

data:extend({
  {
    type = "assembling-machine",
    name = "cube-synthesizer",
    icon = "__rubia__/icons/entities/matter-associator.png",
    icon_size = 128,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "cube-synthesizer"},
    max_health = 1000,
    damaged_trigger_effect = hit_effects.entity(),
    --corpse = "cube-big-random-pipes-remnant",
    dying_explosion = "cube-medium-matter-explosion",
    --[[fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = pipe_path,
        pipe_covers = pipecoverspictures(),
        volume = 2000,
        pipe_connections = {{flow_direction = "input", direction = defines.direction.north, position = {0, -3}}},
      },
      {
        production_type = "input",
        pipe_picture = pipe_path,
        pipe_covers = pipecoverspictures(),
        volume = 2000,
        pipe_connections = {{flow_direction = "input", direction = defines.direction.south, position = {0, 3}}},
      },
      {
        production_type = "output",
        pipe_picture = pipe_path,
        pipe_covers = pipecoverspictures(),
        volume = 2000,
        pipe_connections = {{flow_direction = "output", direction = defines.direction.west, position = {-3, 0}}},
      },
      {
        production_type = "output",
        pipe_picture = pipe_path,
        pipe_covers = pipecoverspictures(),
        volume = 2000,
        pipe_connections = {{flow_direction = "output", direction = defines.direction.east, position = {3, 0}}},
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,]]
    collision_box = {{-3.25, -3.25}, {3.25, 3.25}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator.png",
            priority = "high",
            width = 473,
            height = 489,
            frame_count = 1,
            scale = 0.5,
            shift = {0, -0.15},
          },
          {
            filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-sh.png",
            priority = "medium",
            width = 508,
            height = 446,
            frame_count = 1,
            scale = 0.5,
            shift = {0.38, 0.22},
            draw_as_shadow = true,
          },
        },
      },
      working_visualisations = {
        {
          animation = {
            filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-working-glow-light.png",
            priority = "high",
            draw_as_light = true,
            width = 144,
            height = 110,
            frame_count = 30,
            line_length = 6,
            scale = 0.5,
            animation_speed = 1,
            shift = {0, -0.23},
          },
        },
        {
          synced_fadeout = true,
          animation = {
            filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-working-glow.png",
            priority = "high",
            draw_as_glow = true,
            blend_mode = "additive",
            width = 144,
            height = 110,
            frame_count = 30,
            line_length = 6,
            scale = 0.5,
            animation_speed = 1,
            shift = {0, -0.23},
          },
        },
        {
          animation = {
            layers = {
              {
                filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-working-light.png",
                priority = "high",
                width = 473,
                height = 489,
                frame_count = 30,
                line_length = 6,
                scale = 0.5,
                animation_speed = 1,
                shift = {0, -0.15},
                draw_as_light = true,
              },
              {
                filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-working.png",
                priority = "high",
                width = 473,
                height = 489,
                frame_count = 30,
                line_length = 6,
                scale = 0.5,
                animation_speed = 1,
                shift = {0, -0.15},
              },
            },
          },
          light = {
            intensity = 0.80,
            size = 6,
            shift = {0, -0.15},
            color = {r = 0.35, g = 0.5, b = 1},
          },
        },
      },
    },
    crafting_categories = {"cube-synthesizer", "cube-synthesizer-handcraft"},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
      sound = {
        filename = "__krastorio2-assets-ultracube__/sounds/buildings/matter-associator.ogg",
        volume = 0.60,
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg" },
      apparent_volume = 0.75,
    },
    crafting_speed = 1.0,
    energy_usage = "50MW",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {},
      drain = "50kW",
    },

    water_reflection = {
      pictures = {
        filename = "__rubia__/graphics/entity/garbo-gatherer/matter-associator-reflection.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = util.by_pixel(0, 40),
        variation_count = 1,
        scale = 5,
      },
      rotate = false,
      orientation_to_variation = false,
    },

    ingredient_count = 4,
    module_slots = 2,
    icon_draw_specification = {scale = 2, shift = {0, -0.3}},
    icons_positioning = {{
      inventory_index = defines.inventory.assembling_machine_modules,
      shift = {0, 1.7},
      scale = 1,
    }},
    allowed_effects = module_effects.speed_efficiency,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
  },
})
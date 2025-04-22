require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

--local path = "__rubia__/graphics/entity/wall/"
--local wall_prototype = util.table.deepcopy(data.raw.wall["stone-wall"])
--wall_prototype.name = "craptonite-wall"
--data:extend({wall_prototype})

data:extend({
{
    type = "wall",
    name = "craptonite-wall",
    icon = "__rubia__/graphics/icons/crap-wall.png",
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    damaged_trigger_effect = hit_effects.wall(),
    minable = {mining_time = 0.2, result = "craptonite-wall"},
    fast_replaceable_group = "wall",
    max_health = 800,
    repair_speed_modifier = 2,
    corpse = "wall-remnants",
    dying_explosion = "wall-explosion",
    repair_sound = sounds.manual_repair,
    mined_sound = sounds.deconstruct_bricks(0.8),
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    impact_category = "stone",

    connected_gate_visualization =
    {
      filename = "__core__/graphics/arrows/underground-lines.png",
      priority = "high",
      width = 64,
      height = 64,
      scale = 0.5
    },
    resistances =
    {
      {
        type = "physical",
        decrease = 30,
        percent = 60
      },
      {
        type = "impact",
        decrease = 50,
        percent = 85,
      },
      {
        type = "explosion",
        decrease = 50,
        percent = 60
      },
      {
        type = "fire",
        percent = 100
      },
      {
        type = "acid",
        percent = 90
      },
      {
        type = "laser",
        percent = 85
      }
    },
    visual_merge_group = 0, -- different walls will visually connect to each other if their merge group is same (defaults to 0)
    pictures =
    {
      single =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-single.png",
            priority = "extra-high",
            width = 64,
            height = 86,
            variation_count = 2,
            line_length = 2,
            shift = util.by_pixel(0, -5),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-single-shadow.png",
            priority = "extra-high",
            width = 98,
            height = 60,
            repeat_count = 2,
            shift = util.by_pixel(10, 17),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      straight_vertical =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-vertical.png",
            priority = "extra-high",
            width = 64,
            height = 134,
            variation_count = 5,
            line_length = 5,
            shift = util.by_pixel(0, 8),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-vertical-shadow.png",
            priority = "extra-high",
            width = 98,
            height = 110,
            repeat_count = 5,
            shift = util.by_pixel(10, 29),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      straight_horizontal =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-horizontal.png",
            priority = "extra-high",
            width = 64,
            height = 92,
            variation_count = 6,
            line_length = 6,
            shift = util.by_pixel(0, -2),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-horizontal-shadow.png",
            priority = "extra-high",
            width = 124,
            height = 68,
            repeat_count = 6,
            shift = util.by_pixel(14, 15),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      corner_right_down =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-corner-right.png",
            priority = "extra-high",
            width = 64,
            height = 128,
            variation_count = 2,
            line_length = 2,
            shift = util.by_pixel(0, 7),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-corner-right-shadow.png",
            priority = "extra-high",
            width = 124,
            height = 120,
            repeat_count = 2,
            shift = util.by_pixel(17, 28),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      corner_left_down =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-corner-left.png",
            priority = "extra-high",
            width = 64,
            height = 134,
            variation_count = 2,
            line_length = 2,
            shift = util.by_pixel(0, 7),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-corner-left-shadow.png",
            priority = "extra-high",
            width = 102,
            height = 120,
            repeat_count = 2,
            shift = util.by_pixel(9, 28),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      t_up =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-t.png",
            priority = "extra-high",
            width = 64,
            height = 134,
            variation_count = 4,
            line_length = 4,
            shift = util.by_pixel(0, 7),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-t-shadow.png",
            priority = "extra-high",
            width = 124,
            height = 120,
            repeat_count = 4,
            shift = util.by_pixel(14, 28),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      ending_right =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-ending-right.png",
            priority = "extra-high",
            width = 64,
            height = 92,
            variation_count = 2,
            line_length = 2,
            shift = util.by_pixel(0, -3),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-ending-right-shadow.png",
            priority = "extra-high",
            width = 124,
            height = 68,
            repeat_count = 2,
            shift = util.by_pixel(17, 15),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      ending_left =
      {
        layers =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-ending-left.png",
            priority = "extra-high",
            width = 64,
            height = 92,
            variation_count = 2,
            line_length = 2,
            shift = util.by_pixel(0, -3),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-ending-left-shadow.png",
            priority = "extra-high",
            width = 102,
            height = 68,
            repeat_count = 2,
            shift = util.by_pixel(9, 15),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      filling =
      {
        filename = "__rubia__/graphics/entity/wall/wall-filling.png",
        priority = "extra-high",
        width = 48,
        height = 56,
        variation_count = 8,
        line_length = 8,
        shift = util.by_pixel(0, -1),
        scale = 0.5
      },
      water_connection_patch =
      {
        sheets =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-patch.png",
            priority = "extra-high",
            width = 116,
            height = 128,
            shift = util.by_pixel(0, -2),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-patch-shadow.png",
            priority = "extra-high",
            width = 144,
            height = 100,
            shift = util.by_pixel(9, 15),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      gate_connection_patch =
      {
        sheets =
        {
          {
            filename = "__rubia__/graphics/entity/wall/wall-gate.png",
            priority = "extra-high",
            width = 82,
            height = 108,
            shift = util.by_pixel(0, -7),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wall/wall-gate-shadow.png",
            priority = "extra-high",
            width = 130,
            height = 78,
            shift = util.by_pixel(14, 18),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },

    wall_diode_green =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/wall/wall-diode-green.png",
        priority = "extra-high",
        width = 72,
        height = 44,
        draw_as_glow = true,
        --frames = 4,
        shift = util.by_pixel(-1, -23),
        scale = 0.5
      }
    },
    wall_diode_green_light_top =
    {
      minimum_darkness = 0.3,
      color = {g=1},
      shift = util.by_pixel(0, -30),
      size = 1,
      intensity = 0.2
    },
    wall_diode_green_light_right =
    {
      minimum_darkness = 0.3,
      color = {g=1},
      shift = util.by_pixel(12, -23),
      size = 1,
      intensity = 0.2
    },
    wall_diode_green_light_bottom =
    {
      minimum_darkness = 0.3,
      color = {g=1},
      shift = util.by_pixel(0, -17),
      size = 1,
      intensity = 0.2
    },
    wall_diode_green_light_left =
    {
      minimum_darkness = 0.3,
      color = {g=1},
      shift = util.by_pixel(-12, -23),
      size = 1,
      intensity = 0.2
    },

    wall_diode_red =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/wall/wall-diode-red.png",
        priority = "extra-high",
        width = 72,
        height = 44,
        draw_as_glow = true,
        --frames = 4,
        shift = util.by_pixel(-1, -23),
        scale = 0.5
      }
    },
    wall_diode_red_light_top =
    {
      minimum_darkness = 0.3,
      color = {r=1},
      shift = util.by_pixel(0, -30),
      size = 1,
      intensity = 0.2
    },
    wall_diode_red_light_right =
    {
      minimum_darkness = 0.3,
      color = {r=1},
      shift = util.by_pixel(12, -23),
      size = 1,
      intensity = 0.2
    },
    wall_diode_red_light_bottom =
    {
      minimum_darkness = 0.3,
      color = {r=1},
      shift = util.by_pixel(0, -17),
      size = 1,
      intensity = 0.2
    },
    wall_diode_red_light_left =
    {
      minimum_darkness = 0.3,
      color = {r=1},
      shift = util.by_pixel(-12, -23),
      size = 1,
      intensity = 0.2
    },

    circuit_connector = circuit_connector_definitions["wall"],
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    default_output_signal = {type = "virtual", name = "signal-G"}
  },
})
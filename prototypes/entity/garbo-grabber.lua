--Basic settings brought in from ultracube for the graphics.

require("__rubia__.lib.lib")
local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")
--require("__Ultracube__/prototypes/entities/lib/pipe")
--require("__Ultracube__/prototypes/entities/lib/module_effects")
local dim = 4 --Size of this entity is dim x dim
local gather_radius = 20


data:extend({
  {
    type = "container",
    name = "garbo-grabber",
    icon = "__rubia-assets__/graphics/icons/garbo-grabber.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation", "not-rotatable", "no-automated-item-insertion"},
    minable = {mining_time = 1, result = "garbo-grabber"},
    max_health = 600,
    damaged_trigger_effect = hit_effects.entity(),
    corpse = "medium-remnants",
    dying_explosion = "assembling-machine-3-explosion",
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["chest"],
    surface_conditions = rubia.surface_conditions(), -- Lock to rubia

    radius_visualisation_specification ={
      sprite = {
        filename = "__rubia-assets__/graphics/entity/garbo-grabber/garbo-grabber-radius-visualization.png",
        width = 256,--gather_radius,
        height = 256,--gather_radius,
        scale = 0.5
      },
      distance = gather_radius
    },
    monitor_visualization_tint = {78, 173, 255},

    --[[connection_points =
    {
      {
        shadow =
        {
          copper = util.by_pixel(98.5, 2.5),
          red = util.by_pixel(111.0, 4.5),
          green = util.by_pixel(85.5, 4.0)
        },
        wire =
        {
          copper = util.by_pixel(0.0, -82.5),
          red = util.by_pixel(13.0, -81.0),
          green = util.by_pixel(-12.5, -81.0)
        }
      },]]

    --Container fields
    inventory_size = 8,
    quality_affects_inventory_size = false,
    --default_status = "working",

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
    collision_box = {{-dim/2 +0.1, -dim/2 +0.1}, {dim/2 -0.1, dim/2 -0.1}},
    selection_box = {{-dim/2 +0.1, -dim/2 +0.1}, {dim/2 -0.1, dim/2 -0.1}},--from +/-3.5

    picture = {layers = {
      {
        filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator.png",
        priority = "high",
        width = 473,
        height = 489,
        frame_count = 1,
        scale = 0.5 * dim/7,
        shift = {0, -0.15},
      },
      {
        filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-sh.png",
        priority = "medium",
        width = 508,
        height = 446,
        frame_count = 1,
        scale = 0.5 * dim/7,
        shift = {0.38, 0.22},
        draw_as_shadow = true,
      },
    }},
    
    
    --[[{
      filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator.png",
      priority = "high",
      width = 473,
      height = 489,
      frame_count = 1,
      scale = 0.5,
      shift = {0, -0.15},
    },]]

    --[[
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator.png",
            priority = "high",
            width = 473,
            height = 489,
            frame_count = 1,
            scale = 0.5,
            shift = {0, -0.15},
          },
          {
            filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-sh.png",
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
            filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-working-glow-light.png",
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
            filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-working-glow.png",
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
                filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-working-light.png",
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
                filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-working.png",
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
    },]]
    --crafting_categories = {"cube-synthesizer", "cube-synthesizer-handcraft"},
    vehicle_impact_sound = sounds.generic_impact,
    --[[working_sound = {
      sound = {
        filename = "__krastorio2-assets-ultracube__/sounds/buildings/matter-associator.ogg",
        volume = 0.60,
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg" },
      apparent_volume = 0.75,
    },
    crafting_speed = 1.0,]]
    energy_usage = "50MW",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {},
      drain = "50kW",
    },

    water_reflection = {
      pictures = {
        filename = "__rubia-assets__/graphics/entity/garbo-grabber/matter-associator-reflection.png",
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

    --[[
    ingredient_count = 4,
    module_slots = 2,
    icon_draw_specification = {scale = 2, shift = {0, -0.3}},
    icons_positioning = {{
      inventory_index = defines.inventory.assembling_machine_modules,
      shift = {0, 1.7},
      scale = 1,
    }},
    allowed_effects = module_effects.speed_efficiency,]]
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
  },
})


--Grandseiken's way of connecting wires
--[[local function check_circuit_connectors(machine, is_cube_machine)
  if not settings.startup["cube-circuit-machines"].value then
    machine.enable_logistic_control_behavior = false
    machine.circuit_wire_max_distance = 0
    machine.circuit_connector = nil
  end
end
local function add_circuit_connectors(machine, is_cube_machine, distance, connectors)
  machine.enable_logistic_control_behavior = true
  machine.circuit_wire_max_distance = distance
  machine.circuit_connector = connectors
  --check_circuit_connectors(machine, is_cube_machine)
end
local function add_rotated_circuit_connectors(machine, is_cube_machine, distance, connectors)
  add_circuit_connectors(machine, is_cube_machine, distance, circuit_connector_definitions.create_vector(universal_connector_template, connectors))
end
local function add_vector_circuit_connectors(machine, is_cube_machine, distance, variation, offset, shadow_offset, show_shadow)
  add_rotated_circuit_connectors(machine, is_cube_machine, distance, {
    {variation = variation, main_offset = offset, shadow_offset = shadow_offset, show_shadow = show_shadow},
    {variation = variation, main_offset = offset, shadow_offset = shadow_offset, show_shadow = show_shadow},
    {variation = variation, main_offset = offset, shadow_offset = shadow_offset, show_shadow = show_shadow},
    {variation = variation, main_offset = offset, shadow_offset = shadow_offset, show_shadow = show_shadow},
  })
end
data.raw["assembling-machine"]["cube-synthesizer"], true,
    assembling_machine_circuit_wire_max_distance, 26, util.by_pixel(48, -82), util.by_pixel(64, -64), false)
]]
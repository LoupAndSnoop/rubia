require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")
require("__rubia__.lib.lib")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local meld = require("__core__.lualib.meld")
local surface_conditions = function() return {{property="gravity", min=0.1}} end

--#region Helper functions used in initially defining the locomotive.
local drive_over_tie = function()
    return
    {
      type = "play-sound",
      sound =
      {
        category = "environment",
        variations = sound_variations("__base__/sound/train-tie",
                                      6,
                                      0.4,
                                      {
                                        volume_multiplier("main-menu", 2.4),
                                        volume_multiplier("driving", 1.3)
                                      })
      }
    }
  end

local rolling_stock_back_light = function()
    return
    {
      {
        minimum_darkness = 0.3,
        color = {1, 0.1, 0.05, 0},
        shift = {-0.6, 3.5},
        size = 2,
        intensity = 0.6,
        add_perspective = true
      },
      {
        minimum_darkness = 0.3,
        color = {1, 0.1, 0.05, 0},
        shift = {0.6, 3.5},
        size = 2,
        intensity = 0.6,
        add_perspective = true
      }
    }
  end
  
local rolling_stock_stand_by_light = function()
return
{
    {
    minimum_darkness = 0.3,
    color = {0.05, 0.2, 1, 0},
    shift = {-0.6, -3.5},
    size = 2,
    intensity = 0.5,
    add_perspective = true
    },
    {
    minimum_darkness = 0.3,
    color = {0.05, 0.2, 1, 0},
    shift = {0.6, -3.5},
    size = 2,
    intensity = 0.5,
    add_perspective = true
    }
}
end

local standard_train_wheels =
{
  rotated = util.sprite_load("__base__/graphics/entity/train-wheel/train-wheel",
    {
      priority = "very-low",
      direction_count = 256,
      scale = 0.5,
      shift = util.by_pixel(0, 8),
      usage = "train"
    }
  )
}

local locomotive_reflection = function()
  return
  {
    pictures =
    {
      filename = "__base__/graphics/entity/locomotive/reflection/locomotive-reflection.png",
      priority = "extra-high",
      width = 20,
      height = 52,
      shift = util.by_pixel(0, 40),
      variation_count = 1,
      scale = 5
    },
    rotate = true,
    orientation_to_variation = false
  }
end

--Factoriopedia simulations
local simulations = {}
simulations.factoriopedia_locomotive =
{
  init =
  [[
    game.simulation.camera_position = {1, 0.5}
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNqNk/GKgzAMxt8lf9cxnW6nr3IMqZq5cLUdbfVuDN/9ot3dBruDQqEk5vsF8zU3aNSIF0vaQ3UDao12UL3fwFGvpVpyWg4IFVhJCmYBpDv8giqdjwJQe/KEQbEG11qPQ4OWC8SP0nnW9mefrAgBF+NYZfQCZ1KSlgKuy830jiy24WM+ixdoFg89REN38dAiGpr/Qu3YkEykHYzFLlGmNYPxNOFf/GxzeGqBWjYKa2V6cp5aV3+eiePBTKR7qE5SORRgLHFvGTjbTcYA8jgEU6h7ttC0H+iT04jByVDFRbomPTHE2GtQPSK20XnZfqyOz3xef7WIn98uen77eGgaDT1EQ+Of5Fs0878XeVxGzNbUvHw6pO87uGTvFYtZ3OOxrQImtG5FFPuszMuy2BfbtNjm8/wN8mdH0g==",
      position = {0, 0}
    }
  ]]
}

simulations.factoriopedia_cargo_wagon =
{
  init =
  [[
    game.simulation.camera_position = {1, 0.5}
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNqN01FvgyAQB/Dvcs+41Cp2+lWWxaC90csQGkC7xvjdd9aue1iX8MjJ/wfEuxk6M+LZk43QzEC9swGatxkCaavMWrNqQGjAKzKwCCB7xC9o8uVdANpIkXBL3BbX1o5Dh543iJ9kiJzVp5jdCAFnFzjl7IqzlOW1gCs0kvEjeey3b+Ui/pj7dPOQahbppkw1y4fpx45UpvzgPB6zXnntsovSHHziFw8freoMtsZpCpH60F5OxOvBTWQ1NB/KBBTgPPHBajN2L3u5/p2JS86zY0djntxNpr+3SH1vlW7mqeYh2Uxun9dk8p/u4ZYP0fWfLY+J3cr3aVmr9x0UceAjfudKwIQ+3AhZ7euyrmUld7nclcvyDRkYLDE=",
      position = {0, 0}
    }
  ]]
}

simulations.factoriopedia_fluid_wagon =
{
  init =
  [[
    game.simulation.camera_position = {1, 0.5}
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNqV1c2OgjAQAOB3mTOatlAQXmWzIVUrThYKaUHXGN59i6zrQXS6R6DzQen8XGFbD7qzaHooroC71jgoPq7gsDKqnu4Z1WgowCqsYYwAzV5/Q8HHzwi06bFHPUfcLi6lGZqttn5BdI/ssNMQQdc6v7g1kzkBci0juEAh4rUcx+gJEBSQEUBMASkBJBSQE4CkgA0BpAQgGAFkD2BounensBi++Qt3vU+A6tivbnnw5OQzkvkE2aPVu/lRskDmoSTnwSZnwWgcjj4y2A5bVCtlm9bq/epQD7hfnVXlI5d+KIu5kI/XaKO2tS7rtkLX486V5yP666Y9oamgOKja6Qhai/79apbY2h/HwheJ4G3K8G3GwWgWjibBaHjmcBmKin+kTkpViLhXSL5UIZyssOx9/IYo8XuPidlyhfOcajKMEASjBE4JZLOPKYHs9oISyHafUEISOrJeCjJ05LwU0tCpNwt+CLu+3X2VfnCbOc9/5/d0dzq6aQn2uvHiY9RHcNLW3VSZijzJc5lKxiVLxvEHQLWYGg==",
      position = {5, 0}
    }
  ]]
}
--#endregion




--[[Differences between a standard locomotive and an armored one.
local armored_locomotive_edits = {
    name = "armored-locomotive",
    icon = "__base__/graphics/icons/locomotive.png",
    minable = {mining_time = 0.5, result = "armored-locomotive"},
    max_health = 1000 * 2,
    weight = 2000 * 2,
    max_speed = 1.2,
    max_power = "6000kW",--"600kW",
    reversing_power_modifier = 0.6,
    braking_force = 10 * 3,
    friction_force = 0.50,

    resistances = {
      {type = "fire", decrease = 15, percent = 50},
      {type = "physical", decrease = 50, percent = 50 },--15/30
      {type = "impact", decrease = 100, percent = 90,},--60/50
      {type = "explosion", decrease = 60, percent = 60}, --15/30
      {type = "acid",decrease = 3,percent = 20}
    },
}]]

local max_speed_mult = 1.25 + 0.25
local weight_mult = 5
local health_mult = 2.5
local braking_force_mult = 20 + 5

data:extend({
{
    type = "locomotive",
    name = "rubia-armored-locomotive",
    icon = "__rubia-assets__/graphics/icons/armored-locomotive.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    minable = {mining_time = 0.5, result = "rubia-armored-locomotive"},
    mined_sound = sounds.deconstruct_large(0.8),
    surface_conditions = surface_conditions(),

    max_health = 1000 * health_mult,
    deliver_category = "vehicle",
    corpse = "locomotive-remnants",
    dying_explosion = "locomotive-explosion",
    factoriopedia_simulation = simulations.factoriopedia_locomotive,
    collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
    selection_box = {{-1, -3}, {1, 3}},
    damaged_trigger_effect = hit_effects.entity(),
    drawing_box_vertical_extension = 1,
    alert_icon_shift = util.by_pixel(0, -24),
    weight = 2000 * weight_mult,
    max_speed = 1.2 * max_speed_mult,
    max_power = "12MW",--"600kW",
    reversing_power_modifier = 0.6 / 20,--0.6,
    braking_force = 10 * braking_force_mult,
    friction_force = 0.50,
    vertical_selection_shift = -0.5,
    air_resistance = 0.0075, -- this is a percentage of current speed that will be subtracted
    connection_distance = 3,
    joint_distance = 4,
    energy_per_hit_point = 5,
    icons_positioning =
    {
      {inventory_index = defines.inventory.fuel, shift = {0, 0.3}, max_icons_per_row = 3},
    },
    resistances = {
        {type = "fire", decrease = 15, percent = 50},
        {type = "physical", decrease = 50, percent = 50 },--15/30
        {type = "impact", decrease = 100, percent = 90,},--60/50
        {type = "explosion", decrease = 60, percent = 60}, --15/30
        {type = "acid",decrease = 3,percent = 20},
      },
    energy_source =
    {
      type = "burner",
      fuel_categories = {"chemical"},
      effectivity = 0.2,--1.5,--1,
      fuel_inventory_size = 5,--3,
      smoke =
      {
        {
          name = "train-smoke",
          deviation = {0.3, 0.3},
          frequency = 200,--100,
          position = {0, 0},
          starting_frame = 0,
          starting_frame_deviation = 60,
          height = 2,
          height_deviation = 0.5,
          starting_vertical_speed = 0.2,
          starting_vertical_speed_deviation = 0.1
        }
      }
    },
    front_light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.6, -16},
        size = 2,
        intensity = 0.6,
        color = {r = 1.0, g = 0.9, b = 0.9}
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0.6, -16},
        size = 2,
        intensity = 0.6,
        color = {r = 1.0, g = 0.9, b = 0.9}
      }
    },
    back_light = rolling_stock_back_light(),
    stand_by_light = rolling_stock_stand_by_light(),
    color = {r=55/255, g=17/255, b=0, a=1},--color = {r = 0.92, g = 0.07, b = 0, a = 1},
    default_copy_color_from_train_stop = true,
    pictures =
    {
      rotated =
      {
        layers =
        {
            {
                priority = "very-low",
                width = 512, 
                height = 512,
                direction_count = 256,
                allow_low_quality_rotation = true,
                line_length = 8,
                lines_per_file = 8,
                shift = util.by_pixel(0, -10),
                scale = 0.6,
                filenames =
                {
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-1.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-2.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-3.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-4.png"
                }
            },
            {
                priority = "very-low",
                flags = { "mask" },
                width = 512, 
                height = 512,
                direction_count = 256,
                allow_low_quality_rotation = true,
                line_length = 8,
                lines_per_file = 8,
                shift = util.by_pixel(0, -10),
                apply_runtime_tint = true,
                scale = 0.6,
                -- Somehow it is different from turret masks (use transparency 192)
                filenames =
                {
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mask-1.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mask-2.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mask-3.png",
                    "__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mask-4.png"
                }
            },
        --[[
          util.sprite_load("__base__/graphics/entity/locomotive/locomotive",
            {
              dice = 4,
              priority = "very-low",
              allow_low_quality_rotation = true,
              direction_count = 256,
              scale = 0.5,
              usage = "train"
            }
          ),
          util.sprite_load("__base__/graphics/entity/locomotive/locomotive-mask",
            {
              dice = 4,
              priority = "very-low",
              flags = { "mask" },
              apply_runtime_tint = true,
              tint_as_overlay = true,
              allow_low_quality_rotation = true,
              direction_count = 256,
              scale = 0.5,
              usage = "train"
            }
          ),
          util.sprite_load("__base__/graphics/entity/locomotive/locomotive-shadow",
            {
              dice = 4,
              priority = "very-low",
              flags = { "shadow" },
              draw_as_shadow = true,
              allow_low_quality_rotation = true,
              direction_count = 256,
              scale = 0.5,
              usage = "train"
            }
          )]]
        }
      },
    },
    front_light_pictures =
    {
      rotated =
      {
        layers =
        {
          util.sprite_load("__base__/graphics/entity/locomotive/locomotive-lights",
            {
              dice = 4,
              priority = "very-low",
              blend_mode = "additive",
              draw_as_light = true,
              allow_low_quality_rotation = true,
              direction_count = 256,
              scale = 0.5
            }
          )
        }
      },
    },
    minimap_representation =
    {
      filename = "__rubia-assets__/graphics/icons/armored-locomotive-minimap-representation.png",--"__base__/graphics/entity/locomotive/minimap-representation/locomotive-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    selected_minimap_representation =
    {
      filename = "__rubia-assets__/graphics/icons/armored-locomotive-selected-minimap-representation.png",--"__base__/graphics/entity/locomotive/minimap-representation/locomotive-selected-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    wheels = standard_train_wheels,
    stop_trigger =
    {
      -- left side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the left
        speed = {-0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
      },
      -- right side
      {
        type = "create-trivial-smoke",
        repeat_count = 125,
        smoke_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the right
        speed = {0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
      },
      {
        type = "play-sound",
        sound = sounds.train_brakes
      },
      {
        type = "play-sound",
        sound = sounds.train_brake_screech
      }
    },
    drive_over_tie_trigger = drive_over_tie(),
    drive_over_tie_trigger_minimal_speed = 0.5,
    tie_distance = 50,
    impact_category = "metal-large",
    working_sound =
    {
      main_sounds =
      {
        {
          sound =
          {
            filename = "__base__/sound/train-engine-driving.ogg",
            volume = 0.7,
            modifiers =
            {
              volume_multiplier("main-menu", 1.8),
              volume_multiplier("driving", 0.7),
              volume_multiplier("tips-and-tricks", 0.8),
              volume_multiplier("elevation", 0.5)
            },
          },
          match_volume_to_activity = true,
          activity_to_volume_modifiers =
          {
            multiplier = 1.5,
            offset = 1.0,
          },
          match_speed_to_activity = true,
          activity_to_speed_modifiers =
          {
            multiplier = 0.6,
            minimum = 1.0,
            maximum = 1.15,
            offset = 0.2,
          }
        },
        {
          sound =
          {
            filename = "__base__/sound/train-engine.ogg",
            volume = 0.35,
            modifiers =
            {
              volume_multiplier("main-menu", 1.8),
              volume_multiplier("driving", 0.9),
              volume_multiplier("tips-and-tricks", 0.8)
            },
          },
          match_volume_to_activity = true,
          activity_to_volume_modifiers =
          {
            multiplier = 1.75,
            offset = 1.7,
            inverted = true
          },
        },
        {
          sound =
          {
            filename = "__base__/sound/train-wheels.ogg",
            volume = 1.0,
            modifiers =
            {
              volume_multiplier("main-menu", 2.0),
              volume_multiplier("driving", 0.35),
              volume_multiplier("elevation", 0.5)
            },
          },
          match_volume_to_activity = true,
          activity_to_volume_modifiers =
          {
            multiplier = 1.5,
            maximum = 1.0,
            offset = 1.1,
          },
          match_speed_to_activity = true,
          activity_to_speed_modifiers =
          {
            multiplier = 0.6,
            minimum = 1.0,
            maximum = 1.2,
            offset = 0.2,
          },
        },
      },
      max_sounds_per_prototype = 2,
      activate_sound = { filename = "__base__/sound/train-engine-start.ogg", volume = 0.35 },
      deactivate_sound = { filename = "__base__/sound/train-engine-stop.ogg", volume = 0.35 },
    },
    open_sound = { filename = "__base__/sound/train-door-open.ogg", volume=0.5 },
    close_sound = { filename = "__base__/sound/train-door-close.ogg", volume = 0.4 },
    water_reflection = locomotive_reflection(),
    allow_remote_driving = true
  },

  {
    type = "cargo-wagon",
    name = "rubia-armored-cargo-wagon",
    icon = "__rubia-assets__/graphics/icons/armored-cargo-wagon.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    inventory_size = 100,--40,
    minable = {mining_time = 0.5, result = "rubia-armored-cargo-wagon"},
    mined_sound = sounds.deconstruct_large(0.8),
    surface_conditions = surface_conditions(),
    max_health = 600 * health_mult,
    deliver_category = "vehicle",
    corpse = "cargo-wagon-remnants",
    dying_explosion = "cargo-wagon-explosion",
    factoriopedia_simulation = simulations.factoriopedia_cargo_wagon,
    --Collision hitbox is slightly smaller to prevent cheese.
    --Original: {{-0.6, -2.4}, {0.6, 2.4}},
    --Biggest with no width changes: {{-0.6, -2.3}, {0.6, 2.3}}, --Note 2.305 is too big!
    collision_box = {{-0.6, -2.3}, {0.6, 2.3}},
    selection_box = {{-1, -2.703125}, {1, 3.296875}},
    damaged_trigger_effect = hit_effects.entity(),
    vertical_selection_shift = -0.796875,
    weight = 1000 * weight_mult,
    max_speed = 1.5 * max_speed_mult,
    braking_force = 3 * braking_force_mult,
    friction_force = 0.50,
    air_resistance = 0.01,
    connection_distance = 3,
    joint_distance = 4,
    energy_per_hit_point = 5,
    resistances = {
        {type = "fire", decrease = 15, percent = 50},
        {type = "physical", decrease = 50, percent = 50 },--15/30
        {type = "impact", decrease = 100, percent = 90,},--60/50
        {type = "explosion", decrease = 60, percent = 60}, --15/30
        {type = "acid",decrease = 3,percent = 20}
      },
    back_light = rolling_stock_back_light(),
    stand_by_light = rolling_stock_stand_by_light(),
    color = {r = 0.43, g = 0.23, b = 0, a = 1},

    pictures =
    {
        rotated = {
            layers ={
                {
                priority = "very-low",
                width = 256,
                height = 256,
                back_equals_front = true,
                direction_count = 64,
                filename = "__rubia-assets__/graphics/entity/armored-cargo-wagon/armored-cargo-wagon.png",      
                line_length = 8,
                lines_per_file = 8,
                shift = {0.42, -1.125}
                },
            
            --[[util.sprite_load("__base__/graphics/entity/cargo-wagon/cargo-wagon-shadow",
                {
                dice = 4,
                priority = "very-low",
                allow_low_quality_rotation = true,
                back_equals_front = true,
                draw_as_shadow = true,
                direction_count = 64,-- 128,
                scale = 0.5,
                usage = "train"
                })]]
            }
        }
    },

    --[[
    horizontal_doors =
    {
      layers =
      {
        util.sprite_load("__base__/graphics/entity/cargo-wagon/cargo-wagon-door-horizontal",
          {
            frame_count = 8,
            scale = 0.5,
            usage = "train"
          }
        ),
        util.sprite_load("__base__/graphics/entity/cargo-wagon/cargo-wagon-door-horizontal-mask",
          {
            apply_runtime_tint = true,
            tint_as_overlay = true,
            flags = { "mask" },
            frame_count = 8,
            scale = 0.5,
            usage = "train"
          }
        )
      }
    },
    vertical_doors =
    {
      layers =
      {
        util.sprite_load("__base__/graphics/entity/cargo-wagon/cargo-wagon-door-vertical",
          {
            frame_count = 8,
            scale = 0.5,
            usage = "train"
          }
        ),
        util.sprite_load("__base__/graphics/entity/cargo-wagon/cargo-wagon-door-vertical-mask",
          {
            apply_runtime_tint = true,
            tint_as_overlay = true,
            flags = { "mask" },
            frame_count = 8,
            scale = 0.5,
            usage = "train"
          }
        )
      }
    },]]
    minimap_representation =
    {
      filename = "__base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    selected_minimap_representation =
    {
      filename = "__base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-selected-minimap-representation.png",
      flags = {"icon"},
      size = {20, 40},
      scale = 0.5
    },
    wheels = standard_train_wheels,
    drive_over_tie_trigger = drive_over_tie(),
    drive_over_tie_trigger_minimal_speed = 0.5,
    tie_distance = 50,
    working_sound = sounds.train_wagon_wheels,
    crash_trigger = crash_trigger(),
    open_sound = sounds.cargo_wagon_open,
    close_sound = sounds.cargo_wagon_close,
    impact_category = "metal-large",
    water_reflection = locomotive_reflection(),
    door_opening_sound =
    {
      sound =
      {
        filename = "__base__/sound/cargo-wagon/cargo-wagon-opening-loop.ogg",
        volume = 0.3,
        aggregation = {max_count = 1, remove = true, count_already_playing = true}
      },
      stopped_sound =
      {
        filename = "__base__/sound/cargo-wagon/cargo-wagon-opened.ogg",
        volume = 0.25,
        aggregation = {max_count = 1, remove = true, count_already_playing = true}
      }
    },
    door_closing_sound =
    {
      sound =
      {
        filename = "__base__/sound/cargo-wagon/cargo-wagon-closing-loop.ogg",
        volume = 0.3,
        aggregation = {max_count = 1, remove = true, count_already_playing = true}
      },
      stopped_sound =
      {
        filename = "__base__/sound/cargo-wagon/cargo-wagon-closed.ogg",
        volume = 0.3,
        aggregation = {max_count = 1, remove = true, count_already_playing = true}
      }
    }
  },

  {
    type = "fluid-wagon",
    name = "rubia-armored-fluid-wagon",
    icon = "__rubia-assets__/graphics/icons/armored-fluid-wagon.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    minable = {mining_time = 0.5, result = "rubia-armored-fluid-wagon"},
    mined_sound = sounds.deconstruct_large(0.8),
    surface_conditions = surface_conditions(),
    max_health = 600 * health_mult,
    capacity = 50000 * 4,
    deliver_category = "vehicle",
    corpse = "fluid-wagon-remnants",
    dying_explosion = "fluid-wagon-explosion",
    factoriopedia_simulation = simulations.factoriopedia_fluid_wagon,
    collision_box = {{-0.6, -2.4}, {0.6, 2.4}},
    selection_box = {{-1, -2.703125}, {1, 3.296875}},
    damaged_trigger_effect = hit_effects.entity(),
    vertical_selection_shift = -0.796875,
    icon_draw_specification = {scale = 1.25, shift = {0, -1}},
    weight = 1000 * weight_mult,
    max_speed = 1.5 * max_speed_mult,
    braking_force = 3 * braking_force_mult,
    friction_force = 0.50,
    air_resistance = 0.01,
    connection_distance = 3,
    joint_distance = 4,
    energy_per_hit_point = 6,
    resistances = {
        {type = "fire", decrease = 15, percent = 50},
        {type = "physical", decrease = 50, percent = 50 },--15/30
        {type = "impact", decrease = 100, percent = 90,},--60/50
        {type = "explosion", decrease = 60, percent = 60}, --15/30
        {type = "acid",decrease = 3,percent = 20}
      },
    back_light = rolling_stock_back_light(),
    stand_by_light = rolling_stock_stand_by_light(),
    color = {r = 0.43, g = 0.23, b = 0, a = 0.5},
    pictures =
		{
			rotated = {
			priority = "very-low",
			width = 512, height = 512, scale = 0.5,
			back_equals_front = true,
			direction_count = 64,
			filenames = {
				"__rubia-assets__/graphics/entity/armored-fluid-wagon/4aw_fw_vc_sheet-0.png",      
				"__rubia-assets__/graphics/entity/armored-fluid-wagon/4aw_fw_vc_sheet-1.png",      
				"__rubia-assets__/graphics/entity/armored-fluid-wagon/4aw_fw_vc_sheet-2.png",      
				"__rubia-assets__/graphics/entity/armored-fluid-wagon/4aw_fw_vc_sheet-3.png",      				
			},
			line_length = 4,
			lines_per_file = 4,
			shift = {0.42, -0.875}
		},
    },
    --[[pictures =
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
    },]]
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
    wheels = standard_train_wheels,
    drive_over_tie_trigger = drive_over_tie(),
    drive_over_tie_trigger_minimal_speed = 0.5,
    tie_distance = 50,
    working_sound = sounds.train_wagon_wheels,
    crash_trigger = crash_trigger(),
    impact_category = "metal-large",
    water_reflection = locomotive_reflection()
  },
})


if mods["elevated-rails"] then
    local armored_loc_update =
    {
	wheels = {
        sloped = util.sprite_load("__elevated-rails__/graphics/entity/train-wheel/train-wheel-sloped",
            {
                priority = "very-low",
                direction_count = 160,
                scale = 0.5,
                shift = util.by_pixel(0, 8),
                usage = "train"
            }),
        slope_angle_between_frames = 1.25
    },
	pictures =
	{
		slope_angle_between_frames = 1.25,
		sloped =
		{
			layers =
			{
				util.sprite_load("__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mk1-sloped",
				{
					dice = 4,
					priority = "very-low",
					direction_count = 160,
					scale = 0.6,
					usage = "train"
				}),
				-- Somehow it is different from turret masks (use transparency 192)
				-- Some how it is different 20250219 again lol and everything is broken (looks liek dev patched this)
				util.sprite_load("__rubia-assets__/graphics/entity/armored-locomotive/armored-locomotive-mk1-sloped-mask",
				{
					dice = 4,
					priority = "very-low",
					flags = { "mask" },
					apply_runtime_tint = true,
					--tint_as_overlay = true,
					direction_count = 160,
					scale = 0.6,
					usage = "train"
				})
			}
		}
	},
	elevated_rail_sound =
	{
		sound =
		{
			filename = "__elevated-rails__/sound/elevated-train-driving.ogg",
			volume = 1.0,
			modifiers = {volume_multiplier("elevation", 1.0)}
		},
		match_volume_to_activity = true,
		activity_to_volume_modifiers =
		{
			multiplier = 1.5,
			offset = 1.0,
		},
		match_speed_to_activity = true,
		activity_to_speed_modifiers =
		{
			multiplier = 0.6,
			minimum = 1.0,
			maximum = 1.15,
			offset = 0.2,
		}
	},
	drive_over_elevated_tie_trigger = {
        type = "play-sound",
        sound = sound_variations("__elevated-rails__/sound/elevated-train-tie", 6, 0.8, {volume_multiplier("main-menu", 2.4), volume_multiplier("driving", 0.65)})
      }
    }
    meld(data.raw["locomotive"]["rubia-armored-locomotive"], armored_loc_update)
end
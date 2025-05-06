require ("util")
require ("__base__.prototypes.entity.pipecovers")
require ("circuit-connector-sprites")
require ("__base__.prototypes.entity.assemblerpipes")


--Control lua handles p lab rejecting items of normal, "", nil, or common quality
local simulations = require("__base__.prototypes.factoriopedia-simulations")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local smoke_fast_animation = smoke_animations.trivial_smoke_fast
local trivial_smoke = smoke_animations.trivial_smoke

function make_4way_animation_from_spritesheet(animation)
    local function make_animation_layer(idx, anim)
      local frame_count = anim.frame_count or 1
      local start_frame = frame_count * idx
      local x = 0
      local y = 0
      if anim.line_length then
        y = anim.height * math.floor(start_frame / (anim.line_length or 1))
        if anim.line_length > frame_count then
          error("single line must not contain animations for multiple directions when line_lenght is specified: " .. anim.filename)
        end
      else
        x = idx * anim.width
        
      end
      return
      {
        filename = anim.filename,
        priority = anim.priority or "high",
        flags = anim.flags,
        x = x,
        y = y,
        width = anim.width,
        height = anim.height,
        frame_count = anim.frame_count,
        line_length = anim.line_length,
        repeat_count = anim.repeat_count,
        shift = anim.shift,
        draw_as_shadow = anim.draw_as_shadow,
        draw_as_glow = anim.draw_as_glow,
        draw_as_light = anim.draw_as_light,
        apply_runtime_tint = anim.apply_runtime_tint,
        tint_as_overlay = anim.tint_as_overlay or false,
        animation_speed = anim.animation_speed,
        scale = anim.scale or 1,
        tint = anim.tint,
        blend_mode = anim.blend_mode,
        load_in_minimal_mode = anim.load_in_minimal_mode,
        premul_alpha = anim.premul_alpha,
        generate_sdf = anim.generate_sdf
      }
    end
  
    local function make_animation(idx)
      if animation.layers then
        local tab = { layers = {} }
        for k,v in ipairs(animation.layers) do
          table.insert(tab.layers, make_animation_layer(idx, v))
        end
        return tab
      else
        return make_animation_layer(idx, animation)
      end
    end
  
    return
    {
      north = make_animation(0),
      east = make_animation(1),
      south = make_animation(2),
      west = make_animation(3)
    }
end

--[[function boiler_reflection()
  return
  {
    pictures =
    {
      filename = "__base__/graphics/entity/boiler/boiler-reflection.png",
      priority = "extra-high",
      width = 28,
      height = 32,
      shift = util.by_pixel(5, 30),
      variation_count = 4,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = true
  }
end]]


--data:extend({
  --[[
    {
        type = "assembling-machine",
        name = "catalytic-chemical-plant",
        icon = "__rubia-assets__/graphics/icons/catalytic-chemical-plant.png",
        flags = {"placeable-neutral","placeable-player", "player-creation"},
        minable = {mining_time = 0.1, result = "catalytic-chemical-plant"},
        fast_replaceable_group = "chemical-plant",
        max_health = 300,
        corpse = "catalytic-chemical-plant-remnants",
        dying_explosion = "chemical-plant-explosion", --Not changing.
        icon_draw_specification = {shift = {0, -0.3}},
        circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
        circuit_connector = circuit_connector_definitions["chemical-plant"],
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        damaged_trigger_effect = hit_effects.entity(),
        drawing_box_vertical_extension = 0.4,
        module_slots = 4,
        allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
        heating_energy = "100kW",

        graphics_set =
        {
            animation = make_4way_animation_from_spritesheet({ layers =
            {
            {
                filename = "__rubia-assets__/graphics/entity/catalytic-chemical-plant.png",
                width = 220,
                height = 292,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(0.5, -9),
                scale = 0.5
            },
            {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
                width = 312,
                height = 222,
                repeat_count = 24,
                shift = util.by_pixel(27, 6),
                draw_as_shadow = true,
                scale = 0.5
            }
            }}),
            working_visualisations =
            {
            {
                apply_recipe_tint = "primary",
                north_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-north.png",
                frame_count = 24,
                line_length = 6,
                width = 66,
                height = 44,
                shift = util.by_pixel(23, 15),
                scale = 0.5
                },
                east_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-east.png",
                frame_count = 24,
                line_length = 6,
                width = 70,
                height = 36,
                shift = util.by_pixel(0, 22),
                scale = 0.5
                },
                south_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-south.png",
                frame_count = 24,
                line_length = 6,
                width = 66,
                height = 42,
                shift = util.by_pixel(0, 17),
                scale = 0.5
                },
                west_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-west.png",
                frame_count = 24,
                line_length = 6,
                width = 74,
                height = 36,
                shift = util.by_pixel(-10, 13),
                scale = 0.5
                }
            },
            {
                apply_recipe_tint = "secondary",
                north_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-north.png",
                frame_count = 24,
                line_length = 6,
                width = 62,
                height = 42,
                shift = util.by_pixel(24, 15),
                scale = 0.5
                },
                east_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-east.png",
                frame_count = 24,
                line_length = 6,
                width = 68,
                height = 36,
                shift = util.by_pixel(0, 22),
                scale = 0.5
                },
                south_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-south.png",
                frame_count = 24,
                line_length = 6,
                width = 60,
                height = 40,
                shift = util.by_pixel(1, 17),
                scale = 0.5
                },
                west_animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-west.png",
                frame_count = 24,
                line_length = 6,
                width = 68,
                height = 28,
                shift = util.by_pixel(-9, 15),
                scale = 0.5
                }
            },
            {
                apply_recipe_tint = "tertiary",
                fadeout = true,
                constant_speed = true,
                north_position = util.by_pixel_hr(-30, -161),
                east_position = util.by_pixel_hr(29, -150),
                south_position = util.by_pixel_hr(12, -134),
                west_position = util.by_pixel_hr(-32, -130),
                render_layer = "wires",
                animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-outer.png",
                frame_count = 47,
                line_length = 16,
                width = 90,
                height = 188,
                animation_speed = 0.5,
                shift = util.by_pixel(-2, -40),
                scale = 0.5
                }
            },
            {
                apply_recipe_tint = "quaternary",
                fadeout = true,
                constant_speed = true,
                north_position = util.by_pixel_hr(-30, -161),
                east_position = util.by_pixel_hr(29, -150),
                south_position = util.by_pixel_hr(12, -134),
                west_position = util.by_pixel_hr(-32, -130),
                render_layer = "wires",
                animation =
                {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-inner.png",
                frame_count = 47,
                line_length = 16,
                width = 40,
                height = 84,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -14),
                scale = 0.5
                }
            }
            }
        },
        impact_category = "metal-large",
        open_sound = {filename = "__base__/sound/open-close/fluid-open.ogg", volume = 0.55},
        close_sound = {filename = "__base__/sound/open-close/fluid-close.ogg", volume = 0.54},
        working_sound =
        {
            sound = sound_variations("__base__/sound/chemical-plant", 3, 0.5),
            apparent_volume = 1.5,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        crafting_speed = 2,
        energy_source =
        {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = { pollution = 4 }
        },
        energy_usage = "200kW",
        crafting_categories = {"chemistry","catalytic-chemistry","chemistry-or-cryogenics","organic-or-chemistry"},
        fluid_boxes =
        {
            {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            volume = 1000,
            pipe_connections =
            {
                {
                flow_direction="input",
                direction = defines.direction.north,
                position = {-1, -1}
                }
            }
            },
            {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            volume = 1000,
            pipe_connections =
            {
                {
                flow_direction="input",
                direction = defines.direction.north,
                position = {1, -1}
                }
            }
            },
            {
              production_type = "input",
              pipe_covers = pipecoverspictures(),
              volume = 1000,
              pipe_connections =
              {
                  {
                  flow_direction="input",
                  direction = defines.direction.north,
                  position = {0, -1}
                  }
              }
            },




            {
            production_type = "output", 
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections =
            {
                {
                flow_direction = "output",
                direction = defines.direction.south,
                position = {-1, 1}
                }
            }
            },
            {
            production_type = "output",
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections =
            {
                {
                flow_direction = "output",
                direction = defines.direction.south,
                position = {1, 1}
                }
            }
            }
        },
        water_reflection =
        {
            pictures =
            {
            filename = "__base__/graphics/entity/chemical-plant/chemical-plant-reflection.png", --File is just a red mask, not sure how its actually done....
            priority = "extra-high",
            width = 28,
            height = 36,
            shift = util.by_pixel(5, 60),
            variation_count = 4,
            scale = 5
            },
            rotate = false,
            orientation_to_variation = true
        }
    },]]
    --[[
    {
      type = "lab",
      name = "pressure-lab",
      icon = "__rubia-assets__/graphics/icons/pressure-lab.png", --TODO make icon
      minable = {mining_time = 0.5, result = "pressure-lab"},
      subgroup = "production-machine",
      order = "z-z[z-plab]",
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      max_health = 350,
      impact_category = "metal-large",
      corpse = "chemical-plant-remnants",
      dying_explosion = "chemical-plant-explosion",
      damaged_trigger_effect = hit_effects.entity(),
      include_all_base_lab_science = true, --planets lib
      heating_energy = "0W",
      --frozen_patch = "__space-age__/graphics/entity/frozen/lab/lab.png", --need to see how it looks FAILS
      
      
      --I cheat and inefficiently render an image on another rendered image that has alpha = 0 where I want to keep the background animation.
      --And instead of using my off animation mixed image, I use the double render to make sure the
      --switch from on to off is seamless. Hate this, but I don't to have the skill to perfectly align and tile a bunch of copies to to build
      --a proper layer mask.
      on_animation = 
      {
        layers =
        {
          {
            filename = "__rubia-assets__/graphics/entity/lab-3-x-frame.png",
            width = 194,
            height = 174,
            frame_count = 47,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
          },
          {
            width = 220, 
            height = 292,
            filename = "__rubia-assets__/graphics/entity/chem-lab-on-mask.png", --On picture has wrong colors and is shifted weirdly by a pixel.
            scale = 0.5,
            animation_speed = 1 / 5,
            frame_count = 1,
            line_length = 1,
            repeat_count = 47,
            shift = util.by_pixel(0.5, -9),
            blend_mode = "normal",
          },
          {
            --fadeout = true,
            --constant_speed = true,
            shift= util.by_pixel_hr(-30, -228),
            filename = "__rubia-assets__/graphics/entity/chemical-plant-smoke-outer-blue.png",
            width = 90,
            height = 188,
            frame_count = 47, --Just cutting the animation to 5 frames looks bad. Was 47
            line_length = 16,
            repeat_count = 1, --Framexrepeat counts have to be the same.
            --shift = util.by_pixel(-2, -40),
            animation_speed = 0.5,
            scale = 0.5,
            --run_mode = "forward-then-backward" --MEDIORCE, but otherwise I'd need 47 frames of the base animation just to loop properply 
          },
          {
            --fadeout = true,
            --constant_speed = true,
            shift= util.by_pixel_hr(-30, -228),
            filename = "__rubia-assets__/graphics/entity/chemical-plant-smoke-inner-blue.png",
            frame_count = 47,
            line_length = 16,
            repeat_count = 1,
            width = 40,
            height = 84,
            --shift = util.by_pixel(-2, -40),
            animation_speed = 0.5,
            scale = 0.5,
          },
          {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            line_length = 1,
            repeat_count = 47,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
          },
          {
            filename = "__rubia-assets__/graphics/entity/lab-light-three-times-frames-no-change.png",
            blend_mode = "additive",
            draw_as_light = true,
            width = 216,
            height = 194,
            frame_count = 47, --only way I could get the frames I needed...
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          },

          {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            line_length = 1,
            repeat_count = 47,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
          }
        },
      },


      
      off_animation = 
      {
        layers = 
        {
          { 
            filename = "__rubia-assets__/graphics/entity/lab-3-x-frame.png",
            width = 194,
            height = 174,
            frame_count = 1,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
          },
          {
            width = 220, 
            height = 292,
            filename = "__rubia-assets__/graphics/entity/chem-lab-on-mask.png", 
            scale = 0.5,
            animation_speed = 1 / 5,
            frame_count = 1,
            line_length = 1,
            repeat_count = 1,
            shift = util.by_pixel(0.5, -9),
            blend_mode = "normal",
          },
          {
            filename = "__rubia-assets__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            line_length = 1,
            repeat_count = 1,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
          }
        }
      }, 

      
      
      open_sound = {filename = "__base__/sound/open-close/fluid-open.ogg", volume = 0.55},
      close_sound = {filename = "__base__/sound/open-close/fluid-close.ogg", volume = 0.54},
      working_sound =
      {
        sound = {filename = "__base__/sound/steam-turbine.ogg", volume = 0.7},
      },
      researching_speed = 3.5,
      inputs =
      {
        
        "automation-science-pack",
        "logistic-science-pack",
        "military-science-pack",
        "chemical-science-pack",
        "production-science-pack",
        "utility-science-pack",
        "space-science-pack",
        "metallurgic-science-pack",
        "agricultural-science-pack",
        "electromagnetic-science-pack",
        "cryogenic-science-pack",
        "promethium-science-pack",
        --"electrochemical-science-pack"
      },
      science_pack_drain_rate_percent = 30,
      energy_source =
      {
        type = "fluid",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 8 },
        burns_fluid = false,
        fluid_box = 
        {
          production_type = "input",
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections =
          {
              {
              flow_direction="output", 
              direction = defines.direction.north,
              position = {0, -1},
              },
              {
              flow_direction="input", 
              direction = defines.direction.north,
              position = {-1, -1},
              },
              {
                flow_direction="input",
                direction = defines.direction.north,
                position = {1, -1},
              },
              {
                flow_direction = "output",
                direction = defines.direction.south,
                position = {-1, 1}
              },
              {
                flow_direction = "output",
                direction = defines.direction.south,
                position = {1, 1}
              },
              {
                flow_direction = "input",
                direction = defines.direction.south,
                position = {0, 1}
              },
          },
        },
        scale_fluid_usage = true

      },
      energy_usage = "600kW",
      module_slots = 5,
      allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
      icons_positioning =
      {
        {inventory_index = defines.inventory.lab_modules, shift = {0, 1.6}},
        {inventory_index = defines.inventory.lab_input, shift = {0, 0.4}, max_icons_per_row = 6, separation_multiplier = 1/1.1}
      }
    },
    ]]

    --[[
    {
      type = "boiler",
      name = "red-boiler",
      icon = "__rubia-assets__/graphics/icons/red-boiler.png",
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.2, result = "red-boiler"},
      fast_replaceable_group = "boiler",
      max_health = 200,
      corpse = "red-boiler-remnants",
      dying_explosion = "boiler-explosion",
      impact_category = "metal-large",
      mode = "output-to-separate-pipe",
      resistances =
      {
        {
          type = "fire",
          percent = 90
        },
        {
          type = "explosion",
          percent = 30
        },
        {
          type = "impact",
          percent = 30
        }
      },
      collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
      selection_box = {{-1.5, -1}, {1.5, 1}},
      damaged_trigger_effect = hit_effects.entity(),
      target_temperature = 1000,
      burns_fluid = true,
      fluid_box =
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0.5}},
          {flow_direction = "input-output", direction = defines.direction.east, position = {1, 0.5}}
        },
        production_type = "input",
        filter = "petroleum-gas"
      },
      output_fluid_box =
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections =
        {
          {flow_direction = "output", direction = defines.direction.north, position = {0, -0.5}}
        },
        production_type = "output",
        filter = "carbon-dioxide" 
      },
      energy_consumption = "0.9MW",
      energy_source = 
      {
        type = "void", --Ideally we would have a fluidbox to use a fuel..But this is fine the way it is. TODO consider swaping input and output pipes, then have one be input for boiler fluid transmutation, and the other as fuel.
        --effectivity = 1,
        emissions_per_minute = { pollution = 1 },
        --scale_fluid_usage = true,
        --[[
        light_flicker =
        {
          color = {0,0,0},
          minimum_intensity = 0.6,
          maximum_intensity = 0.95
        },
        smoke =
        {
          {
            name = "smoke",
            north_position = util.by_pixel(-38, -47.5),
            south_position = util.by_pixel(38.5, -32),
            east_position = util.by_pixel(20, -70),
            west_position = util.by_pixel(-19, -8.5),
            frequency = 15,
            starting_vertical_speed = 0.0,
            starting_frame_deviation = 60
          }
        }
      },
      working_sound =
      {
        sound = { filename = "__base__/sound/boiler.ogg", volume = 0.7 },
        audible_distance_modifier = 0.3,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      open_sound = sounds.steam_open,
      close_sound = sounds.steam_close,
  
      pictures =
      {
        north =
        {
          structure =
          {
            layers =
            {
              {
                filename = "__rubia-assets__/graphics/entity/red-boiler-N-idle.png",
                priority = "extra-high",
                width = 269,
                height = 221,
                shift = util.by_pixel(-1.25, 5.25),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
                priority = "extra-high",
                width = 274,
                height = 164,
                scale = 0.5,
                shift = util.by_pixel(20.5, 9),
                draw_as_shadow = true
              }
            }
          },
          fire =
          {
            filename = "__base__/graphics/entity/boiler/boiler-N-fire.png",
            draw_as_glow = true,
            priority = "extra-high",
            frame_count = 64,
            line_length = 8,
            width = 26,
            height = 26,
            animation_speed = 0.5,
            shift = util.by_pixel(0, -8.5),
            scale = 0.5
          },
          fire_glow =
          {
            filename = "__base__/graphics/entity/boiler/boiler-N-light.png",
            draw_as_glow = true,
            priority = "extra-high",
            width = 200,
            height = 173,
            shift = util.by_pixel(-1, -6.75),
            blend_mode = "additive",
            scale = 0.5
          },
        },
        east =
        {
          structure =
          {
            layers =
            {
              {
                filename = "__rubia-assets__/graphics/entity/red-boiler-E-idle.png",
                priority = "extra-high",
                width = 216,
                height = 301,
                shift = util.by_pixel(-3, 1.25),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
                priority = "extra-high",
                width = 184,
                height = 194,
                scale = 0.5,
                shift = util.by_pixel(30, 9.5),
                draw_as_shadow = true
              }
            }
          },
          patch =
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-patch.png",
            width = 6,
            height = 36,
            shift = util.by_pixel(33.5, -13.5),
            scale = 0.5
          },
          fire =
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-fire.png",
            draw_as_glow = true,
            priority = "extra-high",
            frame_count = 64,
            line_length = 8,
            width = 28,
            height = 28,
            animation_speed = 0.5,
            shift = util.by_pixel(-9.5, -22),
            scale = 0.5
          },
          fire_glow =
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-light.png",
            draw_as_glow = true,
            priority = "extra-high",
            width = 139,
            height = 244,
            shift = util.by_pixel(0.25, -13),
            blend_mode = "additive",
            scale = 0.5
          },
        },
        south =
        {
          structure =
          {
            layers =
            {
              {
                filename = "__rubia-assets__/graphics/entity/red-boiler-S-idle.png",
                priority = "extra-high",
                width = 260,
                height = 192,
                shift = util.by_pixel(4, 13),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
                priority = "extra-high",
                width = 311,
                height = 131,
                scale = 0.5,
                shift = util.by_pixel(29.75, 15.75),
                draw_as_shadow = true
              }
            },
          },
          fire =
          {
            filename = "__base__/graphics/entity/boiler/boiler-S-fire.png",
            draw_as_glow = true,
            priority = "extra-high",
            frame_count = 64,
            line_length = 8,
            width = 26,
            height = 16,
            animation_speed = 0.5,
            shift = util.by_pixel(-1, -26.5),
            scale = 0.5
          },
          fire_glow =
          {
            filename = "__base__/graphics/entity/boiler/boiler-S-light.png",
            draw_as_glow = true,
            priority = "extra-high",
            width = 200,
            height = 162,
            shift = util.by_pixel(1, 5.5),
            blend_mode = "additive",
            scale = 0.5
          },
        },
        west =
        {
          structure =
          {
            layers =
            {
              {
                filename = "__rubia-assets__/graphics/entity/red-boiler-W-idle.png",
                priority = "extra-high",
                width = 196,
                height = 273,
                shift = util.by_pixel(1.5, 7.75),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
                priority = "extra-high",
                width = 206,
                height = 218,
                scale = 0.5,
                shift = util.by_pixel(19.5, 6.5),
                draw_as_shadow = true
              }
            },
          },
          fire =
          {
            filename = "__base__/graphics/entity/boiler/boiler-W-fire.png",
            draw_as_glow = true,
            priority = "extra-high",
            frame_count = 64,
            line_length = 8,
            width = 30,
            height = 29,
            animation_speed = 0.5,
            shift = util.by_pixel(13, -23.25),
            scale = 0.5
          },
          fire_glow =
          {
            filename = "__base__/graphics/entity/boiler/boiler-W-light.png",
            draw_as_glow = true,
            priority = "extra-high",
            width = 136,
            height = 217,
            shift = util.by_pixel(2, -6.25),
            blend_mode = "additive",
            scale = 0.5
          },
        }
      },
  
      fire_flicker_enabled = true,
      fire_glow_flicker_enabled = true,
      burning_cooldown = 20,
      water_reflection = boiler_reflection(),
      surface_conditions = 
      {
        {
        property = "pressure",
        min = 10,
        },
      },
    },]]


    --[[{
      type = "generator",
      name = "red-steam-engine",
      icon = "__rubia-assets__/graphics/icons/red-steam-engine.png",
      flags = {"placeable-neutral","player-creation"},
      minable = {mining_time = 0.3, result = "red-steam-engine"},
      max_health = 400,
      corpse = "red-steam-engine-remnants",
      dying_explosion = "steam-engine-explosion",
      alert_icon_shift = util.by_pixel(0, -12),
      effectivity = 0.2,
      fluid_usage_per_tick = 0.5, --Might have to adjust
      maximum_temperature = 1500,
      heating_energy = "50kW",
      max_power_output = "300kW",
      resistances =
      {
        {
          type = "fire",
          percent = 70
        },
        {
          type = "impact",
          percent = 30
        }
      },
      fast_replaceable_group = "steam-engine",
      collision_box = {{-1.25, -2.35}, {1.25, 2.35}},
      selection_box = {{-1.5, -2.5}, {1.5, 2.5}},
      damaged_trigger_effect = hit_effects.entity(),
      fluid_box =
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections =
        {
          { flow_direction = "input-output", direction = defines.direction.south, position = {0, 2} },
          { flow_direction = "input-output", direction = defines.direction.north, position = {0, -2} }
        },
        production_type = "input",
        filter = "carbon-dioxide", --TODO change
        minimum_temperature = 100.0
      },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-output",
        emissions_per_minute = { pollution = 10 }
      },
      horizontal_animation =
      {
        layers =
        {
          {
            filename = "__rubia-assets__/graphics/entity/red-steam-engine-H.png",
            width = 352,
            height = 257,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(1, -4.75),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
            width = 508,
            height = 160,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 24),
            scale = 0.5
          }
        }
      },
      vertical_animation =
      {
        layers =
        {
          {
            filename = "__rubia-assets__/graphics/entity/red-steam-engine-V.png",
            width = 225,
            height = 391,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(4.75, -6.25),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
            width = 330,
            height = 307,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(40.5, 9.25),
            scale = 0.5
          }
        }
      },
      smoke =
      {
        {
          name = "light-smoke",
          north_position = {0.9, 0.0},
          east_position = {-2.0, -2.0},
          frequency = 10 / 32,
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      },
      impact_category = "metal-large",
      open_sound = sounds.machine_open,
      close_sound = sounds.machine_close,
      working_sound =
      {
        sound =
        {
          filename = "__base__/sound/steam-engine-90bpm.ogg",
          volume = 0.55,
          speed_smoothing_window_size = 60,
          modifiers = volume_multiplier("tips-and-tricks", 1.1)
        },
        match_speed_to_activity = true,
        audible_distance_modifier = 0.8,
        max_sounds_per_type = 3,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      perceived_performance = { minimum = 0.25, performance_to_activity_rate = 2.0 },
      water_reflection =
      {
        pictures =
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-reflection.png",
          priority = "extra-high",
          width = 40,
          height = 44,
          shift = util.by_pixel(0, 55),
          variation_count = 2,
          repeat_count = 2,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = true
      },
      surface_conditions = 
      {
        {
        property = "pressure",
        min = 10,
        }
      },
    },]]
    --[[
    {
      type = "container",
      name = "ice-box",
      icon = "__rubia-assets__/graphics/icons/ice-box.png",
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.1, result = "ice-box"},
      max_health = 100,
      corpse = "ice-box-remnants",
      dying_explosion = "wooden-chest-explosion",
      collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
      fast_replaceable_group = "container",
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      damaged_trigger_effect = hit_effects.entity(),
      inventory_size = 16,
      open_sound = { filename = "__base__/sound/wooden-chest-open.ogg", volume = 0.6 },
      close_sound = { filename = "__base__/sound/wooden-chest-close.ogg", volume = 0.6 },
      impact_category = "wood",
      icon_draw_specification = {scale = 0.7},
      picture =
      {
        layers =
        {
          {
            filename = "__rubia-assets__/graphics/entity/ice-box.png",
            priority = "extra-high",
            width = 62,
            height = 72,
            shift = util.by_pixel(0.5, -2),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
            priority = "extra-high",
            width = 104,
            height = 40,
            shift = util.by_pixel(10, 6.5),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      },
      circuit_connector = circuit_connector_definitions["chest"],
      circuit_wire_max_distance = default_circuit_wire_max_distance,
      surface_conditions =
      {
        {
          property = "gravity",
          min = 0.1
        }
      },
    },

    {
      type = "thruster",
      name = "platinum-thruster",
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      icon = "__corrundum__/graphics/icons/platinum-thruster-icon.png",
      collision_box = {{-1.7, -2.2}, {1.7, 2.2}},
      collision_mask = {layers={item=true, object=true, train=true, is_lower_object = true, is_object = true}},
      selection_box = {{-2, -2.5}, {2, 5.5}},
      tile_buildability_rules =
      {
        {area = {{-1.8, -2.3}, {1.8, 2.3}}, required_tiles = {layers={ground_tile=true}}, colliding_tiles = {layers={empty_space=true}}, remove_on_collision = true},
        {area = {{-1.8, 2.7}, {1.8, 90.3}}, required_tiles = {layers={empty_space=true}}, remove_on_collision = true},
      },
      max_health = 300,
      minable = {mining_time = 0.1, result = "platinum-thruster"},
      fast_replaceable_group = "thruster",
      impact_category = "metal",
      surface_conditions =
      {
        {
          property = "pressure",
          min = 0,
          max = 0
        }
      },
      min_performance = {fluid_volume = 0.1, fluid_usage = 0.4, effectivity = 0.2},
      max_performance = {fluid_volume = 0.90, fluid_usage = 3.5, effectivity = 0.65},
      fuel_fluid_box =
      {
        filter = "thruster-fuel",
        production_type = "input",
        -- pipe_covers = pipecoverspictures(),
        draw_only_when_connected = true,
        volume = 2000,
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.west, position = {-1.5, -2}, enable_working_visualisations = { "pipe-4" } },
          {flow_direction = "input-output", direction = defines.direction.east, position = { 1.5,  0}, enable_working_visualisations = { "pipe-2" } },
        }
      },
      oxidizer_fluid_box =
      {
        filter = "thruster-oxidizer",
        production_type = "input",
        -- pipe_covers = pipecoverspictures(),
        draw_only_when_connected = true,
        volume = 2000,
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.east, position = { 1.5, -2}, enable_working_visualisations = { "pipe-1" }},
          {flow_direction = "input-output", direction = defines.direction.west, position = {-1.5,  0}, enable_working_visualisations = { "pipe-3" }},
        }
      },
      placeable_position_visualization =
      {
        filename = "__core__/graphics/cursor-boxes-32x32.png",
        priority = "extra-high-no-scale",
        size = 64,
        scale = 0.5,
        x = 3 * 64
      },
  
      graphics_set =
      {
        animation = util.sprite_load("__corrundum__/graphics/entity/thruster/thruster",
                    {
                      animation_speed = 0.5,
                      frame_count = 64,
                      scale = 0.5,
                      shift = {0,3}
                    }),
  
        integration_patch_render_layer = "floor",
        integration_patch = util.sprite_load("__space-age__/graphics/entity/thruster/thruster-bckg",
                            {
                              scale = 0.5,
                              shift = {0,3}
                            }),
  
        working_visualisations =
        {
          {
            always_draw = true,
            name = "pipe-1",
            enabled_by_name = true,
            animation =
            {
              filename = "__space-age__/graphics/entity/thruster/thruster-pipe-connection-1.png",
              width = 384,
              height = 832,
              shift = util.by_pixel(0, 95),
              scale = 0.5
            }
          },
          {
            always_draw = true,
            name = "pipe-2",
            enabled_by_name = true,
            animation =
            {
              filename = "__space-age__/graphics/entity/thruster/thruster-pipe-connection-2.png",
              width = 384,
              height = 832,
              shift = util.by_pixel(0, 96),
              scale = 0.5
            }
          },
          {
            always_draw = true,
            name = "pipe-3",
            enabled_by_name = true,
            animation =
            {
              filename = "__space-age__/graphics/entity/thruster/thruster-pipe-connection-3.png",
              width = 384,
              height = 832,
              shift = util.by_pixel(0, 96),
              scale = 0.5
            }
          },
          {
            always_draw = true,
            name = "pipe-4",
            enabled_by_name = true,
            animation =
            {
              filename = "__space-age__/graphics/entity/thruster/thruster-pipe-connection-4.png",
              width = 384,
              height = 832,
              shift = util.by_pixel(0, 95),
              scale = 0.5
            }
          },
  
          {
            -- effect = "flicker",
            fadeout = true,
            animation = util.sprite_load("__space-age__/graphics/entity/thruster/thruster-light",
                        {
                          animation_speed = 0.5,
                          frame_count = 64,
                          blend_mode = "additive",
                          draw_as_glow = true,
                          scale = 0.5,
                          shift = {0,3}
                        }),
          },
        },
        flame_effect =
        {
          filename = "__corrundum__/graphics/entity/thruster/thruster-flame.png",
          width = 384,
          height = 832
        },
        flame_position = {0, 5.5},
        flame_half_height = 0,
        flame_effect_height = 1000 / 32,
        flame_effect_width = 384 / 64,
        flame_effect_offset = 50 / 32,
      },
  
      plumes =
      {
        min_probability = 0.08,
        max_probability = 1,
        min_y_offset = -4,
        max_y_offset = 0,
        stateless_visualisations =
        {
          {
            offset_x = { -0.1, 0.1 },
            offset_y = { 10.5, 10.5 },
            offset_z = { 0.0 , 0.0 },
  
            speed_x = { -0.014, 0.014 },
            speed_y = { 0.5, 0.7 },
            speed_z = { -0.014, 0.014 },
  
            probability = 0.3,
            count = 3,
            age_discrimination = -10,
            period = 200,
            fade_in_progress_duration = 0.25,
            fade_out_progress_duration = 0.6,
            spread_progress_duration = 0.375,
            begin_scale = 0.25,
            end_scale = 1.25,
            affected_by_wind = false,
            render_layer = "smoke",
            can_lay_on_the_ground = false,
            animation =
            {
              width = 253,
              height = 210,
              scale = 0.5,
              line_length = 8,
              frame_count = 60,
              shift = {0, 0},
              priority = "high",
              animation_speed = 0.25,
              tint = {r = 1, b = 0.95, g = 0.97, a = 0.5},
              filename = "__space-age__/graphics/entity/thruster/thruster-smoke.png",
              flags = { "smoke" }
            }
          },
          {
            offset_x = { -0.2, 0.2 },
            offset_y = { 14.5, 14.5 },
            offset_z = { 0.0 , 0.0 },
  
            speed_x = { -0.014, 0.014 },
            speed_y = { 0.55, 0.65 },
            speed_z = { -0.014, 0.014 },
  
            probability = 0.5,
            period = 60,
            age_discrimination = -6,
            fade_in_progress_duration = 0.5,
            fade_out_progress_duration = 0.5,
            begin_scale = 0.5,
            end_scale = 1.25,
            affected_by_wind = false,
            render_layer = "smoke",
            can_lay_on_the_ground = false,
            animation =
            {
              width = 2024/8,
              height = 1216/8,
              line_length = 8,
              frame_count = 60,
              shift = {0, 0},
              priority = "high",
              animation_speed = 0.25,
              tint = {r = 0.75, b = 0.75, g = 0.75, a = 1},
              filename = "__space-age__/graphics/entity/thruster/thruster-smoke-glow.png",
              flags = { "smoke" },
              draw_as_glow = true
            }
          },
          {
            offset_x = { -0.25, 0.25 },
            offset_y = { 13.0, 13.0 },
            offset_z = { 0.0 , 0.0 },
  
            speed_x = { -0.014, 0.014 },
            speed_y = { 0.5, 0.7 },
            speed_z = { -0.014, 0.014 },
  
            probability = 0.2,
            count = 2,
            period = 200,
            --age_discrimination = 0,
            fade_in_progress_duration = 0.3,
            fade_out_progress_duration = 0.7,
            begin_scale = 0.5,
            end_scale = 3.0,
            affected_by_wind = false,
            render_layer = "smoke",
            can_lay_on_the_ground = false,
            animation =
            {
              width = 253,
              height = 210,
              line_length = 8,
              frame_count = 60,
              shift = {0, 0},
              priority = "high",
              animation_speed = 0.1,
              tint = {r = 1, b = 0.95, g = 0.97, a = 1.0},
              filename = "__space-age__/graphics/entity/thruster/thruster-smoke.png",
              flags = { "smoke" }
            }
          }
        }
      },
      damaged_trigger_effect = hit_effects.entity(),
      open_sound = {filename = "__base__/sound/open-close/fluid-open.ogg", volume = 0.55},
      close_sound = {filename = "__base__/sound/open-close/fluid-close.ogg", volume = 0.54},
      working_sound =
      {
        main_sounds =
        {
          {
            sound =
            {
              filename = "__space-age__/sound/entity/platform-thruster/thruster-burner.ogg",
              volume = 0.3,
              speed_smoothing_window_size = 60,
              advanced_volume_control = {attenuation = "exponential"},
            },
            match_volume_to_activity = true,
            activity_to_volume_modifiers = {multiplier = 2.0},
            match_speed_to_activity = true,
            activity_to_speed_modifiers = {multiplier = 1.2},
            audible_distance_modifier = 0.8
          },
        },
        sound_accents =
        {
          {
            sound =
            {
              variations = sound_variations("__space-age__/sound/entity/platform-thruster/thruster-mechanic-stop", 5, 0.5),
              advanced_volume_control =
              {
                fades = { fade_in = { curve_type = "S-curve", from = { control = 0.5, volume_percentage = 0.0 }, to = { 3, 100.0 } } },
              }
            },
            frame = 25,
            audible_distance_modifier = 0.3,
          },
          {
            sound =
            {
              variations = sound_variations("__space-age__/sound/entity/platform-thruster/thruster-mechanic-move", 5, 0.3),
              advanced_volume_control =
              {
                fades = { fade_in = { curve_type = "S-curve", from = { control = 0.5, volume_percentage = 0.0 }, to = { 3, 100.0 } } },
              }
            },
            frame = 52,
            audible_distance_modifier = 0.3,
          },
        },
        max_sounds_per_type = 2,
        use_doppler_shift = false,
        extra_sounds_ignore_limit = true,
        activate_sound = { variations = sound_variations("__space-age__/sound/entity/platform-thruster/thruster-engine-activate", 3, 0.3) },
        deactivate_sound = { variations = sound_variations("__space-age__/sound/entity/platform-thruster/thruster-engine-deactivate", 3, 0.3) },
      },
    },

    {
      type = "smoke-with-trigger",
      name = "sulfur-poison-cloud-visual-dummy",
      flags = {"not-on-map"},
      hidden = true,
      show_when_smoke_off = true,
      particle_count = 24,
      particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
      particle_distance_scale_factor = 0.5,
      particle_scale_factor = { 1, 0.707 },
      particle_duration_variation = 60 * 3,
      wave_speed = { 0.5 / 80, 0.5 / 60 },
      wave_distance = { 1, 0.5 },
      spread_duration_variation = 300 - 20,
  
      render_layer = "object",
  
      affected_by_wind = false,
      cyclic = true,
      duration = 60 * 20 + 4 * 60,
      fade_away_duration = 3 * 60,
      spread_duration = (300 - 20) / 2 ,
      color = {r = 76, g = 100, b = 3, a = 0.32}, --rgba(76, 100, 3, 0.32)
  
      animation =
      {
        width = 152,
        height = 120,
        line_length = 5,
        frame_count = 60,
        shift = {-0.53125, -0.4375},
        priority = "high",
        animation_speed = 0.25,
        filename = "__base__/graphics/entity/smoke/smoke.png",
        flags = { "smoke" }
      },
      working_sound =
      {
        sound = { filename = "__base__/sound/fight/poison-cloud.ogg", volume = 0.5 },
        max_sounds_per_type = 1,
        audible_distance_modifier = 0.8,
        match_volume_to_activity = true
      }
    },

    {
      type = "trivial-smoke",
      name = "sulfur-poison-capsule-smoke",
      animation = smoke_fast_animation(
        {
          scale = 0.5
        }
      ),
      duration = 60,
      fade_away_duration = 60,
      render_layer = "higher-object-above",
      color = {r = 240, g = 253, b = 61, a = 0.69}, --rgba(240, 253, 61, 0.69),
    },
  
    {
      type = "trivial-smoke",
      name = "sulfur-poison-capsule-particle-smoke",
      animation = smoke_fast_animation(
        {
          scale = 0.2
        }
      ),
      duration = 60,
      fade_away_duration = 60,
      render_layer = "higher-object-above",
      color = {r = 240, g = 253, b = 61, a = 0.69}, --rgba(240, 253, 61, 0.69),
    },

    {
      name = "sulfur-poison-cloud",
      type = "smoke-with-trigger",
      flags = {"not-on-map"},
      hidden = true,
      show_when_smoke_off = true,
      particle_count = 16,
      particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
      particle_distance_scale_factor = 0.5,
      particle_scale_factor = { 1, 0.707 },
      wave_speed = { 1/80, 1/60 },
      wave_distance = { 0.3, 0.2 },
      spread_duration_variation = 20,
      particle_duration_variation = 60 * 3,
      render_layer = "object",
  
      affected_by_wind = false,
      cyclic = true,
      duration = 60 * 20,
      fade_away_duration = 2 * 60,
      spread_duration = 20,
      color = {r = 240, g = 253, b = 61, a = 0.69}, --rgba(240, 253, 61, 0.69),
  
      animation =
      {
        width = 152,
        height = 120,
        line_length = 5,
        frame_count = 60,
        shift = {-0.53125, -0.4375},
        priority = "high",
        animation_speed = 0.25,
        filename = "__base__/graphics/entity/smoke/smoke.png",
        flags = { "smoke" }
      },
  
      created_effect =
      {
        {
          type = "cluster",
          cluster_count = 10,
          distance = 4,
          distance_deviation = 5,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-smoke",
                show_in_tooltip = false,
                entity_name = "sulfur-poison-cloud-visual-dummy",
                initial_height = 0
              },
              {
                type = "play-sound",
                sound = sounds.poison_capsule_explosion
              }
            }
          }
        },
        {
          type = "cluster",
          cluster_count = 11,
          distance = 8 * 1.1,
          distance_deviation = 2,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-smoke",
                show_in_tooltip = false,
                entity_name = "sulfur-poison-cloud-visual-dummy",
                initial_height = 0
              }
            }
          }
        }
      },
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 11,
              entity_flags = {"breaths-air"},
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  type = "damage",
                  damage = { amount = 16, type = "poison"} --Double damage
                }
              }
            }
          }
        }
      },
      action_cooldown = 30
    },

    {
      type = "projectile",
      name = "sulfur-poison-capsule",
      flags = {"not-on-map"},
      hidden = true,
      acceleration = 0.005,
      action =
      {
        {
          type = "direct",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-smoke",
                show_in_tooltip = true,
                entity_name = "sulfur-poison-cloud",
                initial_height = 0
              },
              {
                type = "create-particle",
                particle_name = "sulfur-poison-capsule-metal-particle",
                repeat_count = 8,
                initial_height = 1,
                initial_vertical_speed = 0.1,
                initial_vertical_speed_deviation = 0.05,
                offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
                speed_from_center = 0.05,
                speed_from_center_deviation = 0.01
              }
            }
          }
        }
      },
      --light = {intensity = 0.5, size = 4},
      animation =
      {
        filename = "__corrundum__/graphics/entity/poison-capsule/poison-capsule.png",
        draw_as_glow = true,
        frame_count = 16,
        line_length = 8,
        animation_speed = 0.250,
        width = 58,
        height = 59,
        shift = util.by_pixel(1, 0.5),
        priority = "high",
        scale = 0.5
      },
      shadow =
      {
        filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
        frame_count = 16,
        line_length = 8,
        animation_speed = 0.250,
        width = 54,
        height = 42,
        shift = util.by_pixel(1, 2),
        priority = "high",
        draw_as_shadow = true,
        scale = 0.5
      },
      smoke =
      {
        {
          name = "sulfur-poison-capsule-smoke", --yellow
          deviation = {0.15, 0.15},
          frequency = 1,
          position = {0, 0},
          starting_frame = 3,
          starting_frame_deviation = 5,
        }
      }
    },

    {
      type = "projectile",
      name = "blue-rocket",
      flags = {"not-on-map"},
      hidden = true,
      acceleration = 0.015,
      turn_speed = 0.0035,
      turning_speed_increases_exponentially_with_projectile_speed = true,
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "big-explosion"
            },
            {
              type = "damage",
              damage = {amount = 100, type = "explosion"}
            },
            {
              type = "create-entity",
              entity_name = "medium-scorchmark-tintable",
              check_buildability = true
            },
            {
              type = "invoke-tile-trigger",
              repeat_count = 1
            },
            {
              type = "destroy-decoratives",
              from_render_layer = "decorative",
              to_render_layer = "object",
              include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
              include_decals = false,
              invoke_decorative_trigger = true,
              decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
              radius = 4, -- large radius for demostrative purposes
            },
            {
              type = "nested-result",
              action =
              {
                type = "area",
                radius = 8,
                action_delivery =
                {
                  type = "instant",
                  target_effects =
                  {
                    {
                      type = "damage",
                      damage = {amount = 150, type = "explosion"}
                    },
                    {
                      type = "create-entity",
                      entity_name = "explosion"
                    }
                  }
                }
              }
            }
          }
        }
      },
      animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.2, 0.2, 1}),
      shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
      smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
    },
    ]]
--})
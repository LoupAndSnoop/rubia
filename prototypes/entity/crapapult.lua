require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")
require("lib.lib")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local size = 4 --Dimension of the crapapult in tiles
local inset = 0.2

--#region Crapapult recipes in early data stage
-- Declare a namespace to have the crapapult blacklist.
_G.crapapult = {}
--Crapapult blacklist. This is where other mods could potentially blacklist things.
--This should be a list of all the names of items to NOT be able to yeet normally.
crapapult.external_blacklist = {}
data:extend({
    {
        type = "item-subgroup",
        name = "yeeting-items",
        group = "yeeting-items",
        order = "a",
      },
      {
        type = "item-group",
        name = "yeeting-items",
        group = "yeeting-items",
        icon = "__rubia__/graphics/icons/crapapult-icon.png",
        order = "a",
      },
})
--#endregion


local crapapult_base_animation ={layers={
    {
        filename = "__rubia__/graphics/entity/crapapult/crapapult-base.png",
        frame_count = 1,
        height = 168,
        line_length = 1,
        priority = "high",
        scale = 0.5 * size/3,
        shift = { -0.015625, 0.140625},
        width = 202
        },
    {
    filename = "__rubia__/graphics/entity/crapapult/crapapult-head.png",
    priority = "high",
    width = 220,
    height = 180,
    frame_count = 1,
    animation_speed = 0.5,
    shift = util.by_pixel(20, -40),--util.by_pixel(-27, -60),
    scale = 0.5 * size/3,
    },
    {
    filename = "__rubia__/graphics/entity/crapapult/crapapult-base-shadow.png",
    frame_count = 1,
    height = 148,
    line_length = 1,
    scale = 0.5 * size/3,
    shift = { 0.234375, 0.203125 },
    width = 204,
    draw_as_shadow = true,
    }
}}

local circuit_x, circuit_y = -21-15, 1+10
local circuit_sx, circuit_sy = -12-15, 10+10
circuit_connector_definitions["crapapult"] = circuit_connector_definitions.create_vector(
  universal_connector_template,
  {
    { variation = 17, main_offset = util.by_pixel(circuit_x, circuit_y), 
        shadow_offset = util.by_pixel(circuit_sx, circuit_sy), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel(circuit_x, circuit_y), 
        shadow_offset = util.by_pixel(circuit_sx, circuit_sy), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel(circuit_x, circuit_y), 
        shadow_offset = util.by_pixel(circuit_sx, circuit_sy), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel(circuit_x, circuit_y), 
        shadow_offset = util.by_pixel(circuit_sx, circuit_sy), show_shadow = true },
  }
)

data:extend({
    {
        name ="crapapult-remnants",
        animation = {
        layers = {
            {
            direction_count = 1,
            filename = "__rubia__/graphics/entity/crapapult/crapapult-remnants.png",
            height = 192,
            line_length = 1,
            scale = 0.5 * size/3,
            shift = { 0.265625, 0.578125 },
            width = 222,
            y = 0
            },
        }
        },
        expires = false,
        final_render_layer = "remnants",
        flags = { "placeable-neutral", "not-on-map" },
        hidden_in_factoriopedia = true,
        icon = "__rubia__/graphics/icons/crapapult-icon.png",
        --icon_size = 128,
        order = "a-c-a",
        remove_on_tile_placement = false,
        selectable_in_game = false,
        selection_box = {{-size/2,-size/2},{size/2,size/2}},--{-1.5, -1.5}, {1.5, 1.5}},
        subgroup = "defensive-structure-remnants",
        tile_height = 3,
        tile_width = 3,
        time_before_removed = 54000,
        type = "corpse"
    },

    {
        type = "furnace",
        name = "crapapult",
        icon = "__rubia__/graphics/icons/crapapult-icon.png",
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = "crapapult"},
        fast_replaceable_group = "furnace",
        circuit_wire_max_distance = furnace_circuit_wire_max_distance,
        circuit_connector = circuit_connector_definitions["crapapult"],
        max_health = 400,
        corpse = "crapapult-remnants",
        dying_explosion = "electromagnetic-plant-explosion",
        surface_conditions = rubia.surface_conditions(),

        resistances =
        {
          {
            type = "fire",
            percent = 80
          },
          {
            type = "impact",
            percent = 50
          }
        },
        collision_box = {{-size/2 + inset,-size/2 + inset},{size/2 - inset,size/2 - inset}},
        selection_box = {{-size/2,-size/2},{size/2,size/2}},
        damaged_trigger_effect = hit_effects.entity(),
        module_slots = 0,
        --icon_draw_specification = {shift = {0, -0.1}},
        --icons_positioning = {{inventory_index = defines.inventory.furnace_modules, shift = {0, 0.8}} },
        allowed_effects = {},--"consumption", "speed", "productivity", "pollution", "quality"},
        crafting_categories = {"crapapult"},
        result_inventory_size = 1,
        crafting_speed = 5,
        energy_usage = "180kW",
        source_inventory_size = 1,
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          --emissions_per_minute = { pollution = 1 }
        },
        impact_category = "metal",
        open_sound = sounds.electric_large_open,
        close_sound = sounds.electric_large_close,
        working_sound =
        {
          sound =
          {
            filename = "__base__/sound/electric-furnace.ogg",
            volume = 0.85,
            modifiers = volume_multiplier("main-menu", 4.2),
            advanced_volume_control = {attenuation = "exponential"},
            audible_distance_modifier = 0.7,
          },
          max_sounds_per_prototype = 4,
          fade_in_ticks = 4,
          fade_out_ticks = 20
        },
        graphics_set =
        {
          animation = crapapult_base_animation,
          --[[
          working_visualisations =
          {
            {
              fadeout = true,
              animation =
              {
                layers =
                {
                  {
                    filename = "__base__/graphics/entity/electric-furnace/electric-furnace-heater.png",
                    priority = "high",
                    width = 60,
                    height = 56,
                    frame_count = 12,
                    animation_speed = 0.5,
                    draw_as_glow = true,
                    shift = util.by_pixel(1.75, 32.75),
                    scale = 0.5
                  },
                  {
                    filename = "__base__/graphics/entity/electric-furnace/electric-furnace-light.png",
                    blend_mode = "additive",
                    width = 202,
                    height = 202,
                    repeat_count = 12,
                    draw_as_glow = true,
                    shift = util.by_pixel(1, 0),
                    scale = 0.5,
                  },
                }
              },
            },
            {
              fadeout = true,
              animation =
              {
                filename = "__base__/graphics/entity/electric-furnace/electric-furnace-ground-light.png",
                blend_mode = "additive",
                width = 166,
                height = 124,
                draw_as_light = true,
                shift = util.by_pixel(3, 69),
                scale = 0.5,
              },
            },
            {
              animation =
              {
                filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png",
                priority = "high",
                width = 37,
                height = 25,
                frame_count = 4,
                animation_speed = 0.5,
                shift = util.by_pixel(-20.5, -18.5),
                scale = 0.5
              }
            },
            {
              animation =
              {
                filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png",
                priority = "high",
                width = 23,
                height = 15,
                frame_count = 4,
                animation_speed = 0.5,
                shift = util.by_pixel(3.5, -38),
                scale = 0.5
              }
            }
          },]]
          --[[
          water_reflection =
          {
            pictures =
            {
              filename = "__base__/graphics/entity/electric-furnace/electric-furnace-reflection.png",
              priority = "extra-high",
              width = 24,
              height = 24,
              shift = util.by_pixel(5, 40),
              variation_count = 1,
              scale = 5
            },
            rotate = false,
            orientation_to_variation = false
          }]]
        }
      },

})
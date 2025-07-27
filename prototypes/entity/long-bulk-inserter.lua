require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
{
    type = "corpse",
    name = "rubia-long-bulk-inserter-remnants",
    icon = "__rubia-assets__/graphics/icons/long-bulk-inserter.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "inserter-remnants",
    order = "a-f-a",
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 1,
    tile_height = 1,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = rubia_lib.make_rotated_animation_variations_from_sheet (4,
    {
      filename = "__rubia-assets__/graphics/entity/long-bulk-inserter/remnants/long-bulk-inserter-remnants.png",
      line_length = 1,
      width = 132,
      height = 96,
      direction_count = 1,
      shift = util.by_pixel(3, -1.5),
      scale = 0.5
    })
  },
{
    type = "inserter",
    name = "rubia-long-bulk-inserter",
    icon = "__rubia-assets__/graphics/icons/long-bulk-inserter.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    bulk = true,
    minable = { mining_time = 0.1, result = "rubia-long-bulk-inserter" },
    max_health = 350, --Normal = 160
    corpse = "rubia-long-bulk-inserter-remnants",
    dying_explosion = "bulk-inserter-explosion",
    resistances = {
      {type = "fire", percent = 90},
      {type = "impact", percent = 50}
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    damaged_trigger_effect = hit_effects.entity(),
    starting_distance = 1.7,
    pickup_position = {0, -2},
    insert_position = {0, 2.2},
    energy_per_movement = "20kJ", --Bulk = 20 kJ. Long = 5 kJ
    energy_per_rotation = "20kJ",
    heating_energy = "50kW",
    
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1kW"
    },
    --Bulk inserter: extension_speed = 0.1, rotation_speed = 0.04,
    --Long inserter: extension_speed = 0.05,rotation_speed = 0.02,
    extension_speed = 0.1,
    rotation_speed = 0.04,
    filter_count = 5,
    icon_draw_specification = {scale = 0.5},
    fast_replaceable_group = "long-handed-inserter",
    open_sound = sounds.inserter_open,
    close_sound = sounds.inserter_close,
    working_sound = sounds.inserter_fast,
    hand_base_picture =
    {
      filename = "__rubia-assets__/graphics/entity/long-bulk-inserter/long-bulk-inserter-hand-base.png",
      priority = "extra-high",
      width = 32,
      height = 136,
      scale = 0.25
    },
    hand_closed_picture =
    {
      filename = "__rubia-assets__/graphics/entity/long-bulk-inserter/long-bulk-inserter-hand-closed.png",
      priority = "extra-high",
      width = 100,
      height = 164,
      scale = 0.25
    },
    hand_open_picture =
    {
      filename = "__rubia-assets__/graphics/entity/long-bulk-inserter/long-bulk-inserter-hand-open.png",
      priority = "extra-high",
      width = 130,
      height = 164,
      scale = 0.25
    },
    hand_base_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 32,
      height = 132,
      scale = 0.25
    },
    hand_closed_shadow =
    {
      filename = "__base__/graphics/entity/bulk-inserter/bulk-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 100,
      height = 164,
      scale = 0.25
    },
    hand_open_shadow =
    {
      filename = "__base__/graphics/entity/bulk-inserter/bulk-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 130,
      height = 164,
      scale = 0.25
    },
    platform_picture =
    {
      sheet =
      {
        filename = "__rubia-assets__/graphics/entity/long-bulk-inserter/long-bulk-inserter-platform.png",
        priority = "extra-high",
        width = 105,
        height = 79,
        shift = util.by_pixel(1.5, 7.5-1),
        scale = 0.5
      }
    },
    circuit_connector = circuit_connector_definitions["inserter"],
    circuit_wire_max_distance = inserter_circuit_wire_max_distance,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal
  },
})

--[[
{
    type = "inserter",
    name = "long-handed-inserter",
    icon = "__base__/graphics/icons/long-handed-inserter.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "long-handed-inserter"},
    max_health = 160,
    corpse = "long-handed-inserter-remnants",
    dying_explosion = "long-handed-inserter-explosion",
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    damaged_trigger_effect = hit_effects.entity(),
    starting_distance = 1.7,
    pickup_position = {0, -2},
    insert_position = {0, 2.2},
    energy_per_movement = "5kJ",
    energy_per_rotation = "5kJ",
    extension_speed = 0.05,
    rotation_speed = 0.02,
    filter_count = 5,
    icon_draw_specification = {scale = 0.5},
    hand_size = 1.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.4kW"
    },
    fast_replaceable_group = "long-handed-inserter",
    impact_category = "metal",
    open_sound = sounds.inserter_open,
    close_sound = sounds.inserter_close,
    working_sound = sounds.inserter_long_handed,
    hand_base_picture =
    {
      filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png",
      priority = "extra-high",
      width = 32,
      height = 136,
      scale = 0.25
    },
    hand_closed_picture =
    {
      filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-closed.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    },
    hand_open_picture =
    {
      filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-open.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    },
    hand_base_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 32,
      height = 132,
      scale = 0.25
    },
    hand_closed_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    },
    hand_open_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    },
    platform_picture =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-platform.png",
        priority = "extra-high",
        width = 105,
        height = 79,
        shift = util.by_pixel(1.5, 7.5-1),
        scale = 0.5
      }
    },
    circuit_connector = circuit_connector_definitions["inserter"],
    circuit_wire_max_distance = inserter_circuit_wire_max_distance,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal
  },]]
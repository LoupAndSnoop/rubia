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
        name = "rubia-long-stack-inserter-remnants",
        icon = "__rubia-assets__/graphics/icons/long-stack-inserter.png",
        flags = {"placeable-neutral", "not-on-map"},
        hidden_in_factoriopedia = true,
        subgroup = "inserter-remnants",
        order = "a-f-a-c",
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
          filename = "__rubia-assets__/graphics/entity/long-stack-inserter/remnants/long-stack-inserter-remnants.png",
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
      name = "rubia-long-stack-inserter",
      icon = "__rubia-assets__/graphics/icons/long-stack-inserter.png",
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      stack_size_bonus = 4,
      bulk = true,
      grab_less_to_match_belt_stack = true,
      wait_for_full_hand = true,
      enter_drop_mode_if_held_stack_spoiled = true,
      max_belt_stack_size = 4,
      minable = { mining_time = 0.1, result = "rubia-long-stack-inserter" },
      max_health = 160,
      corpse = "rubia-long-stack-inserter-remnants",
      dying_explosion = "stack-inserter-explosion",
      resistances =
      {
        {type = "fire", percent = 90},
        {type = "impact", percent = 50}
      },
      collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
      selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
      damaged_trigger_effect = hit_effects.entity(),
      starting_distance = 0.85 + 1,
      pickup_position = {0, -2},
      insert_position = {0, 2.2},
      energy_per_movement = "100kJ", --Stack = 40kJ, bulk = 20kJ
      energy_per_rotation = "100kJ",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        drain = "1kW"
      },
      heating_energy = "50kW",
      --Bulk inserter: extension_speed = 0.1, rotation_speed = 0.04,
      --Long inserter: extension_speed = 0.05,rotation_speed = 0.02,
      extension_speed = 0.1 * 0.75,
      rotation_speed = 0.04 * 0.5,
      filter_count = 5,
      icon_draw_specification = {scale = 0.5},
      fast_replaceable_group = "long-handed-inserter",
      open_sound = sounds.inserter_open,
      close_sound = sounds.inserter_close,
      working_sound = sounds.inserter_fast,
      hand_base_picture =
      {
        filename = "__rubia-assets__/graphics/entity/long-stack-inserter/long-stack-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      },
      hand_closed_picture =
      {
        filename = "__rubia-assets__/graphics/entity/long-stack-inserter/long-stack-inserter-hand-closed.png",
        priority = "extra-high",
        width = 112,
        height = 164,
        scale = 0.25
      },
      hand_open_picture =
      {
        filename = "__rubia-assets__/graphics/entity/long-stack-inserter/long-stack-inserter-hand-open.png",
        priority = "extra-high",
        width = 134,
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
        filename = "__space-age__/graphics/entity/stack-inserter/stack-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 112,
        height = 164,
        scale = 0.25
      },
      hand_open_shadow =
      {
        filename = "__space-age__/graphics/entity/stack-inserter/stack-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 134,
        height = 164,
        scale = 0.25
      },
      platform_picture =
      {
        sheet =
        {
          filename = "__rubia-assets__/graphics/entity/long-stack-inserter/long-stack-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      },
      platform_frozen =
      {
        sheet =
        {
          filename = "__space-age__/graphics/entity/frozen/inserter/inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      },
      hand_base_frozen =
      {
        filename = "__space-age__/graphics/entity/stack-inserter/stack-inserter-arm-frozen.png",
        priority = "extra-high",
        x = 134 * 2,
        width = 134,
        height = 136,
        scale = 0.25
      },
      hand_closed_frozen =
      {
        filename = "__space-age__/graphics/entity/stack-inserter/stack-inserter-arm-frozen.png",
        priority = "extra-high",
        x = 134,
        width = 134,
        height = 164,
        scale = 0.25
      },
      hand_open_frozen =
      {
        filename = "__space-age__/graphics/entity/stack-inserter/stack-inserter-arm-frozen.png",
        priority = "extra-high",
        width = 134,
        height = 164,
        scale = 0.25
      },
      circuit_connector = circuit_connector_definitions["inserter"],
      circuit_wire_max_distance = inserter_circuit_wire_max_distance,
      default_stack_control_input_signal = inserter_default_stack_control_input_signal
    },
})
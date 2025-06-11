local sounds = require("__base__/prototypes/entity/sounds")
local range_mult = 2 --Multiplier for how big the range is relative to a gun turret
local damage_modifier = 20 --Multiplier for how much damage it does per bullet, relative to a gun turret

--Credit: Thanks to xX_Reckless_Xx for the base. I changed numbers to transform.

local function sniper_turret_sheet(inputs)
    return {
        layers = {{
            filename = "__rubia-assets__/graphics/entity/sniper-turret/sniper-turret-sheet.png",
            priority = "medium",
            scale = 0.75,
            width = 128,
            height = 128,
            direction_count = inputs.direction_count and inputs.direction_count or 64,
            frame_count = 1,
            line_length = inputs.line_length and inputs.line_length or 8,
            axially_symmetrical = false,
            run_mode = inputs.run_mode and inputs.run_mode or "forward",
            shift = {0.35, -0.5}
        }}
    }
end

-- TurretPrototype takes table
circuit_connector_definitions["rubia-sniper-turret"] = circuit_connector_definitions.create_vector(
  universal_connector_template,
  {
    { variation = 17, main_offset = util.by_pixel( -21, 1), shadow_offset = util.by_pixel( -12, 10), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel( -21, 1), shadow_offset = util.by_pixel( -12, 10), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel( -21, 1), shadow_offset = util.by_pixel( -12, 10), show_shadow = true },
    { variation = 17, main_offset = util.by_pixel( -21, 1), shadow_offset = util.by_pixel( -12, 10), show_shadow = true },
  }
)


data:extend({{
    type = "ammo-turret",
    name = "rubia-sniper-turret",
    icon = "__rubia-assets__/graphics/icons/sniper-turret-icon.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {
        mining_time = 0.5,
        result = "rubia-sniper-turret"
    },
    order =(data.raw["ammo-turret"]["gun-turret"].order or "z-b-a-") .. "-b",
    max_health = 600,
    resistances = {{type = "impact", percent = 30}},
    corpse = "medium-remnants",
    fast_replaceable_group = "ammo-turret",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    rotation_speed = 0.01 * 1.5,
    preparing_speed = 0.08,
    folding_speed = 0.08,
    dying_explosion = "medium-explosion",
    inventory_size = 1,
    automated_ammo_count = 10,
    attacking_speed = 0.5,
    --prepare_range = 27,
    preparing_sound = sounds.gun_turret_activate,
    folding_sound = sounds.gun_turret_deactivate,
    alert_when_attacking = true,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    turret_base_has_direction = true,
    circuit_connector = circuit_connector_definitions["rubia-sniper-turret"],--circuit_connector_definitions["gun-turret"],
    circuit_wire_max_distance = default_circuit_wire_max_distance,

    graphics_set = {},
    folded_animation = sniper_turret_sheet {
        direction_count = 8,
        line_length = 1
    },
    preparing_animation = sniper_turret_sheet {
        direction_count = 8,
        line_length = 1
    },
    prepared_animation = sniper_turret_sheet {},
    attacking_animation = sniper_turret_sheet {},
    folding_animation = sniper_turret_sheet {
        direction_count = 8,
        line_length = 1,
        run_mode = "backward"
    },

    vehicle_impact_sound = sounds.generic_impact,
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      health_penalty = -3,
      cooldown = 180,--6,
      projectile_creation_distance = 1.39375,
      projectile_center = {0, -0.0875}, -- same as gun_turret_attack shift
      damage_modifier = damage_modifier,
      ammo_consumption_modifier = damage_modifier * 1.5,
      shell_particle =
      {
        name = "shell-particle",
        direction_deviation = 0.1,
        speed = 0.1,
        speed_deviation = 0.03,
        center = {-0.0625, 0},
        creation_distance = -1.925,
        starting_frame_speed = 0.2,
        starting_frame_speed_deviation = 0.1
      },
      range = 18 * range_mult,
      sound = sounds.gun_turret_gunshot
    },
    call_for_help_radius = 46 * range_mult,
    rotate = false,
    --orientation_to_variation = false
}})
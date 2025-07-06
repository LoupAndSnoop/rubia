
--This file has prototypes associated with traps on Rubia.
local sounds = require("__base__.prototypes.entity.sounds")
--local item_sounds = require("__base__.prototypes.item_sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

--Mostly a direct copy of vanilla prototypes. Some parts are modified to make them slower, or change damage,
--but they are mostly copies to prevent other mods from messing with our stuff

local capsule_smoke =
{
  {
    name = "smoke-fast",
    deviation = {0.15, 0.15},
    frequency = 1,
    position = {0, 0},
    starting_frame = 3,
    starting_frame_deviation = 5,
  }
}

data:extend({

--#region Grenade
    {
    type = "projectile",
    name = "rubia-cluster-grenade-trap",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.002,--0.005,
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
              type = "create-entity",
              entity_name = "grenade-explosion"
            },
            {
              type = "create-entity",
              entity_name = "small-scorchmark-tintable",
              check_buildability = true
            }
          }
        }
      },
      {
        type = "cluster",
        cluster_count = 7,
        distance = 4,
        distance_deviation = 3,
        action_delivery =
        {
          type = "projectile",
          projectile = "rubia-grenade-trap",
          direction_deviation = 0.6,
          starting_speed = 0.1,--0.25,
          starting_speed_deviation = 0.1,--0.3
        }
      }
    },
    --light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__base__/graphics/entity/cluster-grenade/cluster-grenade.png",
      draw_as_glow = true,
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 48,
      height = 54,
      shift = util.by_pixel(0.5, 0.5),
      priority = "high",
      scale = 0.5
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 50,
      height = 40,
      shift = util.by_pixel(2, 6),
      priority = "high",
      draw_as_shadow = true,
      scale = 0.5
    }
  },
  
  {
    type = "projectile",
    name = "rubia-grenade-trap",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.002,--0.005,
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
              type = "create-entity",
              entity_name = "grenade-explosion"
            },
            {
              type = "create-entity",
              entity_name = "small-scorchmark-tintable",
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
              radius = 2.25 -- large radius for demostrative purposes
            }
          }
        }
      },
      {
        type = "area",
        radius = 6.5,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "damage",
              damage = {amount = 35, type = "explosion"}--Base = 35
            },
            {
              type = "damage",
              damage = {amount = 50, type = "physical"}
            },
            {
              type = "create-entity",
              entity_name = "explosion"
            }
          }
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__base__/graphics/entity/grenade/grenade.png",
      draw_as_glow = true,
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 48,
      height = 54,
      shift = util.by_pixel(0.5, 0.5),
      priority = "high",
      scale = 0.5
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 50,
      height = 40,
      shift = util.by_pixel(2, 6),
      priority = "high",
      draw_as_shadow = true,
      scale = 0.5
    }
  },
  {
    type = "sound",
    name = "rubia-grenade-throw",
    variations = sound_variations("__base__/sound/fight/throw-grenade", 5, 0.4),
    priority = 64
  },
--#endregion

--#region destroyer
    {
    type = "projectile",
    name = "rubia-destroyer-capsule-trap",
    flags = {"not-on-map"},
    hidden = true, hidden_in_factoriopedia = true,
    acceleration = 0.001,--0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "create-entity",
          show_in_tooltip = true,
          entity_name = "rubia-destroyer",
          offsets = {{0,0}},
          --offsets = {{-0.7, -0.7},{-0.7, 0.7},{0.7, -0.7},{0.7, 0.7},{0, 0}}
        }
      }
    },
    --light = {intensity = 0.5, size = 4},
    enable_drawing_with_mask = true,
    animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule.png",
          flags = { "no-crop" },
          width = 42,
          height = 34,
          priority = "high"
        },
        {
          filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-mask.png",
          flags = { "no-crop" },
          width = 42,
          height = 34,
          priority = "high",
          apply_runtime_tint = true
        }
      }
    },
    shadow =
    {
      filename = "__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-shadow.png",
      flags = { "no-crop" },
      width = 48,
      height = 32,
      priority = "high"
    },
    smoke = capsule_smoke
  },
})

local destroyer = util.table.deepcopy(data.raw["combat-robot"]["destroyer"])
destroyer.name = "rubia-destroyer"
destroyer.localised_name = {"",{"entity-name.destroyer"}, " (", {"space-location-name.rubia"}, ")"}
table.insert(destroyer.resistances, {type = "impact", percent = 70})
destroyer.max_health = 300
destroyer.time_to_live = 60 * 60 * 4
destroyer.hidden = true
destroyer.hidden_in_factoriopedia = true
data:extend({destroyer})

--#endregion

--Gun turret trap
local gun_turret = util.table.deepcopy(data.raw["ammo-turret"]["gun-turret"])
gun_turret.name = "rubia-gun-turret-trap"
gun_turret.localised_name = {"", {"entity-name.gun-turret"}, " (", {"space-location-name.rubia"}, ")"}
gun_turret.resistances = gun_turret.resistances or {}
table.insert(gun_turret.resistances, {type = "impact", percent = 50})
gun_turret.max_health = 800
gun_turret.attacking_speed = 3--0.5
gun_turret.preparing_speed = 0.02--0.08,
gun_turret.folding_speed = 0.02--0.08

gun_turret.attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      health_penalty = -3,
      cooldown = 6,--6,
      projectile_creation_distance = 1.39375,
      projectile_center = {0, -0.0875}, -- same as gun_turret_attack shift
      damage_modifier = 12,
      ammo_consumption_modifier = 0.5,
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
      range = 18,
      sound = sounds.gun_turret_gunshot
    }
gun_turret.hidden = true
gun_turret.hidden_in_factoriopedia = true
data:extend({gun_turret})

data:extend({
  {
    type = "sound",
    name = "rubia-gun-turret-trap-armed",
    filename = "__base__/sound/spidertron/spidertron-activate.ogg",
    priority = 64
  },
})
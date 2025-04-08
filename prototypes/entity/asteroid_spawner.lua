--Defining the asteroid spawner, which is a biter spawner in disguise.

require ("__base__.prototypes.entity.enemy-constants")
require ("__base__.prototypes.entity.biter-animations")
require ("__base__.prototypes.entity.spitter-animations")
require ("__base__.prototypes.entity.spawner-animation")

local biter_ai_settings = require ("__base__.prototypes.entity.biter-ai-settings")
local enemy_autoplace = require ("__base__.prototypes.entity.enemy-autoplace-utils")
local sounds = require ("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local simulations = require("__base__.prototypes.factoriopedia-simulations")

------Asteroids
local make_unit_melee_ammo_type = function(damage_value)
    return
    {
      target_type = "entity",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            type = "damage",
            damage = { amount = damage_value , type = "physical"}
          }
        }
      }
    }
  end

data:extend({
    {
    type = "unit",
    name = "medium-trashsteroid",
    icon = "__base__/graphics/icons/small-biter.png",
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 15,
    order = "b-a-a",
    subgroup = "enemies",
    --factoriopedia_simulation = simulations.factoriopedia_small_biter,
    resistances = {},
    healing_per_tick = 0.01,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    collision_mask= {layers={}},
    selection_box = {{-0.4, -0.7}, {0.4, 0.4}},
    damaged_trigger_effect = hit_effects.biter(),
    attack_parameters = --mandatory
    {
      type = "projectile",
      range = 0.5,
      cooldown = 35,
      cooldown_deviation = 0.15,
      ammo_category = "melee",
      ammo_type = make_unit_melee_ammo_type(7),
      sound = sounds.biter_roars(0.35),
      animation = biterattackanimation(small_biter_scale, small_biter_tint1, small_biter_tint2),
      range_mode = "bounding-box-to-bounding-box"
    },
    impact_category = "organic",
    vision_distance = 0,
    movement_speed = 0.1,
    distance_per_frame = 0.125,
    absorptions_to_join_attack = { pollution = 100 },
    distraction_cooldown = 90000,
    min_pursue_time = 10 * 60,
    max_pursue_distance = 0,
    corpse = "small-biter-corpse",
    dying_explosion = "small-biter-die",
    dying_sound = sounds.biter_dying(0.5),
    working_sound = sounds.biter_calls(0.4, 0.75),
    run_animation = biterrunanimation(small_biter_scale, small_biter_tint1, small_biter_tint2),
    running_sound_animation_positions = {2,},
    walking_sound = sounds.biter_walk(0, 0.3),
    --join attacks false makes them not spawn
    ai_settings = {destroy_when_commands_fail = true, allow_try_return_to_spawner = false }
    --water_reflection = biter_water_reflection(small_biter_scale)
  },
})


------- Asteroid spawner
data:extend({{
    type = "unit-spawner",
    name = "rubia-asteroid-spawner",
    icon = "__base__/graphics/icons/biter-spawner.png",--data.raw["huge-carbonic-asteroid"].icon
    flags = {"placeable-player", "placeable-enemy", "not-repairable"},
    max_health = 100000000,
    order="b-d-a",
    subgroup="enemies",
    resistances =
    {
      {
        type = "impact",
        decrease = 100000,
        percent = 100
      }
    },
    --[[working_sound =
    {
      sound = {category = "enemy", filename = "__base__/sound/creatures/spawner.ogg", volume = 0.6, modifiers = volume_multiplier("main-menu", 0.7) },
      max_sounds_per_prototype = 3
    },]]
    --[[dying_sound =
    {
      variations = sound_variations("__base__/sound/creatures/spawner-death", 5, 0.7, volume_multiplier("main-menu", 0.55) ),
      aggregation = { max_count = 2, remove = true, count_already_playing = true }
    },]]
    healing_per_tick = 1000,
    --collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    map_generator_bounding_box = {{-3.7, -3.2}, {3.7, 3.2}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    --damaged_trigger_effect = hit_effects.biter(),
    --impact_category = "organic",
    -- in ticks per 1 pu
    absorptions_per_second = { pollution = { absolute = 20, proportional = 0.01 } },
    --corpse = "biter-spawner-corpse",
    --dying_explosion = "biter-spawner-die",
    max_count_of_owned_units = 7,
    max_friends_around_to_spawn = 5,
    graphics_set =
    {
      animations =
      {
        spawner_idle_animation(0, biter_spawner_tint),
        spawner_idle_animation(1, biter_spawner_tint),
        spawner_idle_animation(2, biter_spawner_tint),
        spawner_idle_animation(3, biter_spawner_tint)
      }
    },
    result_units = (function() -- TODO: Spawn different asteroids based on distance
            local res = {}
            res[1] = {"medium-trashsteroid", {{0.0, 0.3}}} -- small-biter
            --res[1] = {"defender", {{0.0, 0.3}, {0.6, 0.0}}} 
            --res[1] = {"small-biter", {{0.0, 0.3}, {0.6, 0.0}}}
            --[[if not data.is_demo then
            -- from evolution_factor 0.3 the weight for medium-biter is linearly rising from 0 to 0.3
            -- this means for example that when the evolution_factor is 0.45 the probability of spawning
            -- a small biter is 66% while probability for medium biter is 33%.
            res[2] = {"medium-trashsteroid", {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}}
            -- for evolution factor of 1 the spawning probabilities are: small-biter 0%, medium-biter 1/8, big-biter 4/8, behemoth biter 3/8
            res[3] = {"medium-trashsteroid", {{0.5, 0.0}, {1.0, 0.4}}}
            res[4] = {"medium-trashsteroid", {{0.9, 0.0}, {1.0, 0.3}}}
            end]]
            return res
        end)(),
    -- With zero evolution the spawn rate is 6 seconds, with max evolution it is 2.5 seconds
    spawning_cooldown = {360, 150},
    spawning_radius = 10,
    spawning_spacing = 3,
    max_spawn_shift = 0,
    max_richness_for_spawn_shift = 100,
    autoplace = enemy_autoplace.enemy_spawner_autoplace("enemy_autoplace_base(0, 6)"),
    call_for_help_radius = 50,
    time_to_capture = 60 * 20,
    spawn_decorations_on_expansion = true,
    spawn_decoration =
    {
      {
        decorative = "light-mud-decal",
        spawn_min = 0,
        spawn_max = 2,
        spawn_min_radius = 2,
        spawn_max_radius = 5
      },
      {
        decorative = "dark-mud-decal",
        spawn_min = 0,
        spawn_max = 3,
        spawn_min_radius = 2,
        spawn_max_radius = 6
      },
      {
        decorative = "enemy-decal",
        spawn_min = 3,
        spawn_max = 5,
        spawn_min_radius = 2,
        spawn_max_radius = 7
      },
      {
        decorative = "enemy-decal-transparent",
        spawn_min = 4,
        spawn_max = 20,
        spawn_min_radius = 2,
        spawn_max_radius = 14,
        radius_curve = 0.9
      },
      {
        decorative = "muddy-stump",
        spawn_min = 2,
        spawn_max = 5,
        spawn_min_radius = 3,
        spawn_max_radius = 6
      },
      {
        decorative = "red-croton",
        spawn_min = 2,
        spawn_max = 8,
        spawn_min_radius = 3,
        spawn_max_radius = 6
      },
      {
        decorative = "red-pita",
        spawn_min = 1,
        spawn_max = 5,
        spawn_min_radius = 3,
        spawn_max_radius = 6
      }
    }
  }}
)
require("__rubia__.lib.lib")

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")
local simulations = require("__base__.prototypes.factoriopedia-simulations")
local util = require("util")
--require("__base__.prototypes.entity.explosions")

--Standard resistances
local function trashsteroid_resistances() 
    return     {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "impact",
          percent = 100,
          --decrease = 50
        },
        {
          type = "laser",
          percent = 60
        },
        {
            type = "electric",
            percent = 100
        }
      }
end

---
-----Rendering
---
--Give a color that tints something just to transparency.
local function transparency(value) return {r = value, g = value, b = value, a = value} end
--Get ready an array of animations so they can be rendered
local med_trash_anim_solid = rubia_lib.make_rotated_animation_variations_from_sheet(6,{
    filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid.png",
    line_length = 1,
    width = 230,
    height = 230,
    direction_count = 1,
    shift = util.by_pixel(0, 3.5),
    scale = 0.25,
    tint = transparency(0.8)
})
local med_trash_anim_shadow = rubia_lib.make_rotated_animation_variations_from_sheet(6,{
    filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid-shadow.png",
    line_length = 1,
    width = 230,
    height = 230,
    direction_count = 1,
    shift = util.by_pixel(0, 3.5),
    scale = 0.25,
    tint = transparency(0.9),
    draw_as_shadow = true
})
local med_trash_animations = {}
for i = 1,6 do
    data:extend({{
        type = "animation",
        name = "medium-trashsteroid-animation" .. tostring(i),
        layers = {med_trash_anim_solid[i]}
    }})
    data:extend({{
        type = "animation",
        name = "medium-trashsteroid-shadow" .. tostring(i),
        layers = {med_trash_anim_shadow[i]}
    }})
end

--Invisible smoke so we don't get smoke upon spawning trashsteroids
data:extend {{
    type = "trivial-smoke",
    name = "rubia-invisible-smoke",
    duration = 1,
    fade_away_duration = 1,
    spread_duration = 1,
    animation = {
        filename = "__core__/graphics/empty.png",
        priority = "high",
        width = 1,
        height = 1,
        flags = {"smoke"},
        frame_count = 1,
    },
    cyclic = true
}}

--------Defining the trashsteroid prototype(s)
data:extend({
{
    type = "car",
    name = "medium-trashsteroid",
    icon = "__rubia__/graphics/icons/trashsteroid-chunk-icon.png",--"__base__/graphics/icons/car.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-flammable", "get-by-unit-number"},--get-by-unit-number is a very important flag
    --minable = {mining_time = 0.4, result = "car"},
    --mined_sound = sounds.deconstruct_medium(0.8),
    max_health = 400,
    is_military_target = true,
    deliver_category = "vehicle",
    --corpse = "car-remnants",
    dying_explosion = "carbonic-asteroid-explosion-3",
    alert_icon_shift = util.by_pixel(0, -13),
    energy_per_hit_point = 1,
    minimap_representation =     {
        filename = "__rubia__/graphics/icons/trashsteroid-minimap-representation.png",
        flags = {"icon"},
        size = {20, 20},
        scale = 0.5
    },
    --crash_trigger = crash_trigger(),
    resistances = trashsteroid_resistances(),
    collision_box = {{-0.75, -0.75}, {0.75, 0.75}},
    selection_box = {{-0.75, -0.75}, {0.75, 0.75}},
    collision_mask= {layers={}},
    damaged_trigger_effect = hit_effects.entity(),
    effectivity = 0,--0.6,
    braking_power = "200kW",
    energy_source = {type = "void"},
    consumption = "150kW",
    friction = 1e-4,--2e-3,
    render_layer = "air-object",
    created_smoke = {
        type = "create-trivial-smoke",
        smoke_name = "rubia-invisible-smoke",
    },

    --Blank animation
    animation = {layers = {{filename = "__base__/graphics/decorative/brown-asterisk/brown-asterisk-00.png",
        width = 119, height = 74, scale = 0, tint = {r=0,g=0,b=0,a=0}}}},
    --This contains an array of animation objects to be used for rendering.
    luarender_animation = med_trash_animations,--[[{layers = rubia_lib.make_rotated_animation_variations_from_sheet(6,{
        filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid.png",
        line_length = 6,
        width = 230,
        height = 230,
        direction_count = 1,
        shift = util.by_pixel(0, 3.5),
        scale = 0.25,
        tint = transparency(0.5)
    }), rubia_lib.make_rotated_animation_variations_from_sheet(6,{
        filename = "__rubia__/graphics/entity/trashsteroids/medium-trashsteroid-shadow.png",
        line_length = 6,
        width = 230,
        height = 230,
        direction_count = 1,
        shift = util.by_pixel(0+50, 3.5+50),
        scale = 0.25,
        tint = transparency(0.5)
})}]]
    stop_trigger_speed = 0.15,
    --[[stop_trigger =
    {
      {
        type = "play-sound",
        sound = {filename = "__base__/sound/car-breaks.ogg", volume = 0.1 }
      }
    },]]
    impact_category = "metal",
    impact_speed_to_volume_ratio = 4.0,
    --[[
    working_sound =
    {
      main_sounds =
      {
        {
          sound = {filename = "__base__/sound/car-engine-driving.ogg", volume = 0.67, modifiers = volume_multiplier("main-menu", 2.2)},
          match_volume_to_activity = true,
          activity_to_volume_modifiers =
          {
            multiplier = 1.8,
            offset = 0.95,
          },
          match_speed_to_activity = true,
          activity_to_speed_modifiers =
          {
            multiplier = 0.8,
            minimum = 1.0,
            maximum = 1.4,
            offset = 0.1,
          }
        },
        {
          sound = { filename = "__base__/sound/car-engine.ogg", volume = 0.67 },
          match_volume_to_activity = true,
          fade_in_ticks = 22,
          activity_to_volume_modifiers =
          {
            multiplier = 2.4,
            offset = 1.5,
            inverted = true
          }
        },
      },
      activate_sound = { filename = "__base__/sound/car-engine-start.ogg", volume = 0.67 },
      deactivate_sound = { filename = "__base__/sound/car-engine-stop.ogg", volume = 0.67 },
    },]]
    rotation_speed = 0.015,
    weight = 700,
    inventory_size = 0,
  }
})

----- Explosions
--_G.trashsteroid_lib = _G.trashsteroid_lib or {}
local explosions_medium = {
    table.deepcopy(data.raw["explosion"]["steel-chest-explosion"]),
    table.deepcopy(data.raw["explosion"]["pipe-explosion"]),
    table.deepcopy(data.raw["explosion"]["turbo-transport-belt-explosion"]),
    table.deepcopy(data.raw["explosion"]["pipe-to-ground-explosion"]),
    table.deepcopy(data.raw["explosion"]["fast-transport-belt-explosion"]),
    table.deepcopy(data.raw["explosion"]["transport-belt-explosion"]),
    table.deepcopy(data.raw["explosion"]["solar-panel-explosion"]),
    table.deepcopy(data.raw["explosion"]["space-platform-foundation-explosion"]),
    table.deepcopy(data.raw["explosion"]["iron-chest-explosion"])
}
--Names of all trashsteroid explosion prototypes
--trashsteroid_lib.trashsteroid_explosions = {}
for i,explosion in pairs(explosions_medium) do
    --explosions_medium[i]
    explosion.name = "medium-trashsteroid-explosion" .. tostring(i)
    explosion.sound = sounds.large_explosion(0.1,0.2) --Min/max volume edit here
    --table.insert(trashsteroid_lib.trashsteroid_explosions, explosion.name)
end
data:extend(explosions_medium)



-----This describes a small trashsteroid chunk that is a projectile.
-----It is used as an intermediate to connect a medium trashsteroid to a gatherer.

--Save each separate trashsteroid chunk variant as a separate animation prototype
local trash_chunk_anim_solid = rubia_lib.make_rotated_animation_variations_from_sheet(7,{
    filename = "__rubia__/graphics/entity/trashsteroids/trashsteroid-chunk.png", --50x350
    line_length = 1,
    width = 50,
    height = 50,
    direction_count = 1,
    shift = util.by_pixel(0, 3.5),
    scale = 0.25,
    tint = transparency(0.8)
})
local trash_chunk_anim_shadow = rubia_lib.make_rotated_animation_variations_from_sheet(7,{
    filename = "__rubia__/graphics/entity/trashsteroids/trashsteroid-chunk-shadow.png",
    line_length = 1,
    width = 50,
    height = 50,
    direction_count = 1,
    shift = util.by_pixel(0, 3.5),
    scale = 0.25,
    tint = transparency(0.9),
    draw_as_shadow = true
})
--local trash_chunk_anim_full = {} --Keep a table of each variation's individual 
for i = 1,7 do
    data:extend({{
        type = "animation",
        name = "trashsteroid-chunk-animation" .. tostring(i),
        layers = {trash_chunk_anim_solid[i], trash_chunk_anim_shadow[i]}
    }})
    --table.insert(trash_chunk_anim_full, {layers = {trash_chunk_anim_solid[i], trash_chunk_anim_shadow[i]}})
end

--The actual chunk projectile prototype
data:extend({
    {
        type = "projectile",
        name = "trashsteroid-chunk",
        flags = {"not-on-map"},
        hidden = true,
        acceleration = 0.01,
        turn_speed = 0.003,
        turning_speed_increases_exponentially_with_projectile_speed = true,
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "instant",
            target_effects = {
                --[[{
                    type = "create-entity",
                    entity_name = "laser-bubble",
                    tint = {r=0,g=0,b=1,a=1}
                },]]
                {
                    type = "insert-item",
                    item = "craptonite-chunk",
                    count = 1
                },
                {
                    type = "play-sound",
                    sound = {filename = "__base__/sound/open-close/mechanical-large-close.ogg",
                    volume = 0.5},
                    max_distance = 30,
                },
            }
          }
        },
        --light = {intensity = 0.5, size = 4},
        --animation = {layers = {trash_chunk_anim_solid[1], trash_chunk_anim_shadow[1]}},
        animation = trash_chunk_anim_solid,
        shadow = trash_chunk_anim_shadow,
        --require("__base__.prototypes.entity.rocket-projectile-pictures").animation({1, 0.8, 0.3}),
        --shadow = {layers = trash_chunk_anim_shadow[1]},--require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
        --smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
      },
    })
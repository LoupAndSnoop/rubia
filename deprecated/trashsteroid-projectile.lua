--This file describes a small trashsteroid chunk that is a projectile.
--It is used as an intermediate to connect a medium trashsteroid to a gatherer.


require("__rubia__.lib.lib")

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")
local simulations = require("__base__.prototypes.factoriopedia-simulations")
local util = require("util")

data:extend({
    {
        type = "projectile",
        name = "trashsteroid-small-projectile",
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
            target_effects =
            {
              {
                type = "create-entity",
                entity_name = "explosion"
              },
              {
                type = "damage",
                damage = {amount = 200, type = "explosion"}
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
                radius = 1.5 -- large radius for demostrative purposes
              }
            }
          }
        },
        --light = {intensity = 0.5, size = 4},
        animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({1, 0.8, 0.3}),
        shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
        smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
      },
    --[[
    {
        type = "projectile",
        name = "rocket",
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
            target_effects =
            {
              {
                type = "create-entity",
                entity_name = "explosion"
              },
              {
                type = "damage",
                damage = {amount = 200, type = "explosion"}
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
                radius = 1.5 -- large radius for demostrative purposes
              }
            }
          }
        },
        --light = {intensity = 0.5, size = 4},
        animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({1, 0.8, 0.3}),
        shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
        smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
      },
]]






})
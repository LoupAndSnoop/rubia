require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")

local height = 4--2
local width = 2--4
local inset = 0.15 --How much to sink in the collision boxes

--Intended for if I get a working graphics set in future?
--[[graphics_set = {
            animation= rubia_lib.make_rotated_animation_variations_from_sheet(1,{
               filename = 
                line_length = 1,
                width = 128,
                height = 64,
                direction_count = 1,
                shift = util.by_pixel(0, 3.5),
                scale = 1
          })]]

data:extend({

    {
        type = "assembling-machine",
        name = "biorecycling-plant",
        icon = "__rubia-assets__/graphics/icons/biorecycling-plant.png",
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.1, result = "biorecycling-plant"},
        fast_replaceable_group = "biorecycling-plant",
        max_health = 400,
        corpse = "medium-remnants",
        dying_explosion = "biochamber-explosion",
        icon_draw_specification = {shift = {0, -0.25 -0.25}},
        icons_positioning = {{inventory_index = defines.inventory.crafter_modules,
          shift = {0, 0.25 + 0.2}, max_icons_per_row = 4}},
        circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
        circuit_connector = circuit_connector_definitions["recycler"],
        heating_energy = "100kW",
        --effect_receiver = { base_effect = { productivity = 0.5 }},

        collision_box = {{-width/2 +inset, -height/2 +inset}, {width/2 - inset, height/2 - inset}},
        selection_box = {{-width/2, -height/2}, {width/2, height/2}},
        
        damaged_trigger_effect = hit_effects.entity(),
        drawing_box_vertical_extension = 0.7,

        --positions for EMP are (-1.5,0.5), (1.5,-0.5),(0.5,1.5),(0.5,-1.5)
        fluid_boxes =
        {
          {
            production_type = "output",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 200,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="output", direction = defines.direction.east, --south with horiz sprite
                position = {width/2 - 0.5, height/2 - 0.5} }},
          },
          {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 200,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="input", direction = defines.direction.west, --south with horiz sprite
                position = {-width/2 + 0.5, height/2 - 0.5} }}
          },
          {
            production_type = "output",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="output", direction = defines.direction.west, --north when horiz sprite
                position = {-width/2 + 0.5, -height/2 + 0.5}}} 
          },
          {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="input", direction = defines.direction.east,--north when horiz sprite
                position = {width/2 - 0.5, -height/2 + 0.5} }}
          }
        },
        fluid_boxes_off_when_no_fluid_recipe = true,
        forced_symmetry = "diagonal-pos",--"horizontal",
        perceived_performance = {minimum = 0.25, maximum = 10},

        graphics_set          = require("__rubia-assets__/graphics/entity/biorecycling-plant/biorecycler-pictures").graphics_set,--"__quality__.prototypes.entity.recycler-pictures").graphics_set,
        graphics_set_flipped  = require("__rubia-assets__/graphics/entity/biorecycling-plant/biorecycler-pictures").graphics_set_flipped,

        --require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").graphics_set,
        open_sound = sounds.metal_large_open,
        close_sound = sounds.metal_large_close,
        working_sound = {
            sound = {filename = "__space-age__/sound/entity/biochamber/biochamber-loop.ogg", volume = 0.4},
            max_sounds_per_prototype = 3,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        resistances =
        {
            {
                type = "impact",
                percent = 50
            }
        },

        crafting_speed = 3,
        crafting_categories = {"biorecycling"},
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          emissions_per_minute = { pollution = 1 }
        },
        energy_usage = "500kW",
        module_slots = 4,
        allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
        water_reflection = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").water_reflection,
      },   

})

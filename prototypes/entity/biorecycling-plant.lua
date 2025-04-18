require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")
--local meld = require("meld")
--local simulations = require("__space-age__.prototypes.factoriopedia-simulations")
--local procession_graphic_catalogue_types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")

local height = 2
local width = 4
local inset = 0.15 --How much to sink in the collision boxes

data:extend({

    {
        type = "assembling-machine",
        name = "biorecycling-plant",
        icon = "__rubia__/graphics/entity/biorecycling-plant/biorecycling-plant-test.png",
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.1, result = "biorecycling-plant"},
        fast_replaceable_group = "biorecycling-plant",
        max_health = 400,
        corpse = "medium-remnants",
        dying_explosion = "biochamber-explosion",
        icon_draw_specification = {shift = {0, -0.25}},
        circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
        circuit_connector = circuit_connector_definitions["electromagnetic-plant"],
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
            pipe_connections = {{ flow_direction="output", direction = defines.direction.south, 
                position = {width/2 - 0.5, height/2 - 0.5} }} --position = {-1.5, 0.5} }}, 
          },
          {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 200,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="input", direction = defines.direction.south,
                position = {-width/2 + 0.5, height/2 - 0.5} }}
          },
          {
            production_type = "output",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="output", direction = defines.direction.north,
                position = {-width/2 + 0.5, -height/2 + 0.5}}}  --position = {-1, -height/2 + inset} }}
          },
          {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            secondary_draw_orders = { north = -1 },
            pipe_connections = {{ flow_direction="input", direction = defines.direction.north,
                position = {width/2 - 0.5, -height/2 + 0.5} }}
          }
        },
        fluid_boxes_off_when_no_fluid_recipe = true,
        forced_symmetry = "horizontal",
        perceived_performance = {minimum = 0.25, maximum = 10},

        --[[graphics_set = {
            animation= rubia_lib.make_rotated_animation_variations_from_sheet(1,{
               filename = "__rubia__/graphics/entity/biorecycling-plant/biorecycling-plant-test.png",
                line_length = 1,
                width = 128,
                height = 64,
                direction_count = 1,
                shift = util.by_pixel(0, 3.5),
                scale = 1
          })]]
        graphics_set = {
            animation=
                {north=
                    {layers = {
                        {filename = "__rubia__/graphics/entity/biorecycling-plant/biorecycling-plant-test.png",
                        width = 128, height = 64, scale = 1, shift = util.by_pixel(0, 3.5),} --tint = {r=0,g=0,b=0,a=0}}
                    }},
                east=
                    {layers = {
                        {filename = "__rubia__/graphics/entity/biorecycling-plant/biorecycling-plant-test.png",
                        width = 128, height = 64, scale = 1, shift = util.by_pixel(0, 3.5),} --tint = {r=0,g=0,b=0,a=0}}
                    }},
            }
        },
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
                percent = 30
            }
        },

        crafting_speed = 2,
        crafting_categories = {"biorecycling"},
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          emissions_per_minute = { pollution = 1 }
        },
        energy_usage = "2000kW",
        module_slots = 4,
        icons_positioning =
        {
          {inventory_index = defines.inventory.furnace_modules, shift = {0, 1}}
        },
        allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
        water_reflection = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").water_reflection,
      }
    

})

--[[
--EMPlant base
{
    type = "assembling-machine",
    name = "electromagnetic-plant",
    icon = "__space-age__/graphics/icons/electromagnetic-plant.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "electromagnetic-plant"},
    fast_replaceable_group = "electromagnetic-plant",
    max_health = 350,
    corpse = "electromagnetic-plant-remnants",
    dying_explosion = "electromagnetic-plant-explosion",
    icon_draw_specification = {shift = {0, -0.25}},
    circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["electromagnetic-plant"],
    heating_energy = "100kW",
    effect_receiver = { base_effect = { productivity = 0.5 }},
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2, -2}, {2, 2}},
    damaged_trigger_effect = hit_effects.entity(),
    drawing_box_vertical_extension = 0.7,
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        volume = 200,
        secondary_draw_orders = { north = -1 },
        pipe_connections = {{ flow_direction="input-output", direction = defines.direction.west, position = {-1.5, 0.5} }}
      },
      {
        production_type = "input",
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        volume = 200,
        secondary_draw_orders = { north = -1 },
        pipe_connections = {{ flow_direction="input-output", direction = defines.direction.east, position = {1.5, -0.5} }}
      },
      {
        production_type = "output",
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        volume = 100,
        secondary_draw_orders = { north = -1 },
        pipe_connections = {{ flow_direction="input-output", direction = defines.direction.south, position = {0.5, 1.5} }}
      },
      {
        production_type = "output",
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        volume = 100,
        secondary_draw_orders = { north = -1 },
        pipe_connections = {{ flow_direction="input-output", direction = defines.direction.north, position = {-0.5, -1.5} }}
      }
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    forced_symmetry = "horizontal",
    perceived_performance = {minimum = 0.25, maximum = 10},
    graphics_set = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").graphics_set,
    open_sound = sounds.electric_large_open,
    close_sound = sounds.electric_large_close,
    working_sound = space_age_sounds.electromagnetic_plant,
    crafting_speed = 2,
    crafting_categories = {"electromagnetics", "electronics", "electronics-with-fluid", "electronics-or-assembling"},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 }
    },
    energy_usage = "2000kW",
    module_slots = 5,
    icons_positioning =
    {
      {inventory_index = defines.inventory.furnace_modules, shift = {0, 1}}
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
    water_reflection = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").water_reflection,
  },


--Recycler base
{
    type = "furnace",
    name = "recycler",
    icon = "__quality__/graphics/icons/recycler.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    fast_transfer_modules_into_module_slots_only = true,
    minable = {mining_time = 0.2, result = "recycler"},
    circuit_wire_max_distance = furnace_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["recycler"],
    circuit_connector_flipped = circuit_connector_definitions["recycler-flipped"],
    max_health = 300,
    fast_replaceable_group = "recycler",
    vector_to_place_result = {-0.5, -2.3},
    dying_explosion = "recycler-explosion",
    corpse = "recycler-remnants",
    impact_category = "metal",
    working_sound =
    {
      sound = {filename = "__quality__/sound/recycler/recycler-loop.ogg", volume = 0.7},
      sound_accents =
      {
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-move", 5, 0.45), audible_distance_modifier = 0.2}, frame = 14},
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-vox", 5, 0.2), audible_distance_modifier = 0.3}, frame = 20},
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-mechanic", 3, 0.3), audible_distance_modifier = 0.3}, frame = 45},
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-move", 5, 0.45), audible_distance_modifier = 0.2}, frame = 60},
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-trash", 5, 0.6), audible_distance_modifier = 0.3}, frame = 61},
        {sound = {variations = sound_variations("__quality__/sound/recycler/recycler-jaw-shut", 6, 0.3), audible_distance_modifier = 0.6}, frame = 63},
      },
      max_sounds_per_prototype = 2,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    resistances =
    {
      {
        type = "fire",
        percent = 80
      }
    },
    collision_box = {{-0.7, -1.7}, {0.7, 1.7}},
    selection_box = {{-0.9, -1.85}, {0.9, 1.85}},
    crafting_categories = {"recycling", "recycling-or-hand-crafting"},
    result_inventory_size = 12,
    energy_usage = "180kW",
    crafting_speed = 0.5,
    source_inventory_size = 1,
    custom_input_slot_tooltip_key = "recycler-input-slot-tooltip",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 2 }
    },
    module_slots = 4,
    icon_draw_specification = {shift = {0, -0.55}},
    icons_positioning =
    {
      {inventory_index = defines.inventory.furnace_modules, shift = {0, 0.2}}
    },
    allowed_effects = {"consumption", "speed", "pollution", "quality"},
    perceived_performance = {maximum = 4},
    graphics_set          = require("__quality__.prototypes.entity.recycler-pictures").graphics_set,
    graphics_set_flipped  = require("__quality__.prototypes.entity.recycler-pictures").graphics_set_flipped,
    cant_insert_at_source_message_key = "inventory-restriction.cant-be-recycled"
  }
}
  ]]
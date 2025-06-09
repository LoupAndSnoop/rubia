--local wind_turbine = data.raw["item"]["k2-wind-turbine"].deepcopy();

---Credit to ZarSahsa. I just modified this code
--- https://mods.factorio.com/mod/k2-wind-turbine-zars-fork

---------------------------------------------------------------------------------------------------
--  ┏┓┓┏┏┓┳┓┏┓┳┓
--  ┗┓┣┫┣┫┣┫┣ ┃┃
--  ┗┛┛┗┛┗┛┗┗┛┻┛
---------------------------------------------------------------------------------------------------
-- Variables used across several lua documents. (Not everything can be put here, since conflict
-- between the settings, prototype and runtime stages may arise.)
---------------------------------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------------------------------
local MOD_NAME      = "rubia"
--local MOD_TITLE     = "Krastorio 2 Wind Turbine (ZarSasha's Fork)"
local TURBINE_NAME  = "rubia-wind-turbine"
local GRAPHICS_PATH = "__rubia-assets__/graphics/entity/wind-turbine/"
local SOUNDS_PATH   = "__rubia-assets__/sounds/"

---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------
local SETTING = {
    POWER_OUTPUT_kW    = 250,--settings.startup["k2-wind-turbine-output-kW"].value,
    --EXQUISITE          = settings.startup["k2-wind-turbine-exquisite"].value
}

---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┓┏
--  ┣ ┃┃ ┃ ┃ ┃ ┗┫
--  ┗┛┛┗ ┻ ┻ ┻ ┗┛
---------------------------------------------------------------------------------------------------
local HIT_EFFECTS   = require("__base__/prototypes/entity/hit-effects")
---------------------------------------------------------------------------------------------------
-- WIND TURBINE
---------------------------------------------------------------------------------------------------

-- Graphics -- 
local graphics_scale = 0.86
local graphics_reflections = {
    filename = GRAPHICS_PATH .. "entities/wind-turbine-reflection.png",
    priority = "extra-high",
    width = 20,
    height = 25,
    shift = util.by_pixel(0, 40+3),
    variation_count = 1,
    scale = 5 *graphics_scale,
}
local graphics_entity = {
    filename = GRAPHICS_PATH .. "entities/hr-wind-turbine.png",
    priority = "extra-high",
    width = 196,
    height = 286,
    scale = 0.5*graphics_scale,
    frame_count = 30,
    line_length = 6,
    animation_speed = 0.8,
    shift = {0, -1.2+0.1}
}
local graphics_entity_sh = {
    filename = GRAPHICS_PATH .. "entities/hr-wind-turbine-shadow.png",
    priority = "extra-high",
    width = 242,
    height = 100,
    scale = 0.65*graphics_scale,
    frame_count = 30,
    line_length = 6,
    animation_speed = 0.5,
    draw_as_shadow = true,
    shift = {1.15, 0.05+0.1}
}

-- Sounds --
local sounds = { wind_turbine = {
    filename = SOUNDS_PATH .. "wind-turbine-rotating.ogg",
    volume = 0.27,
    audible_distance_modifier = 0.7,
    max_sounds_per_prototype = 3
}}

-- Properties -- 
local entity = {
    type = "electric-energy-interface", -- special "cheat" prototype
    name = TURBINE_NAME,
    --factoriopedia_description = "Converts wind power to electricity. Power scales with quality.",--{"factoriopedia-description."..TURBINE_NAME},
    --gui_mode = "admins", -- gui contains sliders for energy parameters
    icon = GRAPHICS_PATH .. "icons/k2-wind-turbine.png",
    icon_size = 64,
    drawing_box_vertical_extension = 1.8,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.15, result = TURBINE_NAME},
    max_health = 200,
    resistances = {{type = "fire", percent = 50}, {type = "impact", percent = 30}},

    corpse = "medium-small-remnants",
    dying_explosion = "assembling-machine-1-explosion",
    damaged_trigger_effect = HIT_EFFECTS.entity(),
    impact_category = "metal",
    collision_box = {{-0.95, -0.95}, {0.95, 0.95}}, -- modified to a 2x2
    selection_box = {{-0.95, -0.95}, {0.95, 0.95}},
    energy_production = SETTING.POWER_OUTPUT_kW .. "kW",
    --energy_usage = "0kW",
    energy_source = {
        type = "electric",
        usage_priority = "primary-output",
        buffer_capacity = SETTING.POWER_OUTPUT_kW .. "kW", -- "kW" makes math easier
        input_flow_limit = "0kW",
        output_flow_limit = (6*SETTING.POWER_OUTPUT_kW) .. "kW", -- Give x6 to give enough output for leg quality
        render_no_power_icon = false
    },
    water_reflection = {
        pictures = graphics_reflections,
        rotate = false,
        orientation_to_variation = false
    },
    animation = { layers = { graphics_entity, graphics_entity_sh } },
    continuous_animation = true,
    working_sound = {
        sound = sounds.wind_turbine,
        idle_sound = sounds.wind_turbine,
    }
}
-- Compatibility: Space Age DLC --

entity.surface_conditions = rubia.surface_conditions()
entity.heating_energy = "30kW"--SETTING.EXQUISITE and "0kW" or "30kW"

-- Note: Turbine cannot be build on Aquilo, unless this is allowed in the startup settings.

--|FINAL DATA WRITE|-------------------------------------------------------------------------------
data:extend({entity})
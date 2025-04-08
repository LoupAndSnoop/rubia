--Copied from rubia decoratives.
--vulcanus name changed to rubia

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require ("__base__.prototypes.entity.sounds")
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local simulations = require("__space-age__.prototypes.factoriopedia-simulations")

local base_decorative_sprite_priority = "extra-high"
local decal_tile_layer = 255

local function combine_tint(table_1, table_2)
  local t1 = table_1[1]-(1-table_2[1])
  local t2 = table_1[2]-(1-table_2[2])
  local t3 = table_1[3]-(1-table_2[3])
  return {t1,t2,t3}
end

local rubia_base_tint = {1,1,1}

local green_hairy_tint = {.85,.6,.7}
local brown_hairy_tint = {.7,.7,.7}
local brown_carpet_tint = {1,.9,1}
local red_pita_tint = {.8,.75,.75}
local tintable_rock_tint = {0.2588, 0.2588, 0.2588}
local sulfur_rock_tint = {0.788, 0.627, 0.167} --{0.968, 0.807, 0.247}
local platinum_rock_tint = {.7,.7,.7}

green_hairy_tint = combine_tint(rubia_base_tint, green_hairy_tint)
brown_hairy_tint = combine_tint(rubia_base_tint, brown_hairy_tint)
brown_carpet_tint = combine_tint(rubia_base_tint, brown_carpet_tint)
red_pita_tint =  combine_tint(rubia_base_tint, red_pita_tint)
tintable_rock_tint = combine_tint(rubia_base_tint, tintable_rock_tint)
platinum_rock_tint = combine_tint(rubia_base_tint, platinum_rock_tint)



data:extend{
{
    type = "noise-expression",
    name = "rubia_rock_huge",
    expression = "min(0.2 * (1 - 0.75 * rubia_petrol_lands_biome), - 1.2 + 1.09 * min(aux, -0.1 + 1.1 * moisture) + rubia_rock_noise + 0.45 * rubia_decorative_knockout)"

}
}


--- TINTABLE ROCKS
--- BIG ROCKS
data:extend{
{
    name = "huge-rubia-rock",
    type = "simple-entity",

    flags = {"placeable-neutral", "placeable-off-grid"},
    icon = "__space-age__/graphics/icons/huge-volcanic-rock.png",
    subgroup = "grass",
    order = "b[decorative]-l[rock]-f[huge-volcanic-rock]",
    collision_box = {{-1.5, -1.1}, {1.5, 1.1}},
    selection_box = {{-1.7, -1.3}, {1.7, 1.3}},
    damaged_trigger_effect = hit_effects.rock(),
    dying_trigger_effect = decorative_trigger_effects.huge_rock(),
    minable =
    {
        mining_particle = "stone-particle",
        mining_time = 3,
        results =
        {
        {type = "item", name = "stone", amount_min = 20, amount_max = 50},
        {type = "item", name = "iron-ore", amount_min = 12, amount_max = 35},
        {type = "item", name = "copper-ore", amount_min = 10, amount_max = 24},
        {type = "item", name = "platinum-ore", amount_min = 3, amount_max = 15},
        {type = "item", name = "solid-fuel", amount_min = 10, amount_max = 25},
        },
    },
    map_color = {129, 105, 78},
    count_as_rock_for_filtered_deconstruction = true,
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    impact_category = "stone",
    render_layer = "object",
    max_health = 2000,
    localised_name = {"entity-name.huge-rock"}, 
    resistances =
    {
        {
        type = "fire",
        percent = 100
        }
    },
    autoplace = {
        order = "a[landscape]-c[rock]-a[huge]",
        probability_expression = "rubia_rock_huge"
    },
    pictures =
    {
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-05.png",
        width = 201,
        height = 179,
        scale = 0.5,
        shift = {0.25, 0.0625},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-06.png",
        width = 233,
        height = 171,
        scale = 0.5,
        shift = {0.429688, 0.046875},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-07.png",
        width = 240,
        height = 192,
        scale = 0.5,
        shift = {0.398438, 0.03125},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-08.png",
        width = 219,
        height = 175,
        scale = 0.5,
        shift = {0.148438, 0.132812},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-09.png",
        width = 240,
        height = 208,
        scale = 0.5,
        shift = {0.3125, 0.0625},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-10.png",
        width = 243,
        height = 190,
        scale = 0.5,
        shift = {0.1875, 0.046875},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-11.png",
        width = 249,
        height = 185,
        scale = 0.5,
        shift = {0.398438, 0.0546875},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-12.png",
        width = 273,
        height = 163,
        scale = 0.5,
        shift = {0.34375, 0.0390625},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-13.png",
        width = 275,
        height = 175,
        scale = 0.5,
        shift = {0.273438, 0.0234375},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-14.png",
        width = 241,
        height = 215,
        scale = 0.5,
        shift = {0.195312, 0.0390625},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-15.png",
        width = 318,
        height = 181,
        scale = 0.5,
        shift = {0.523438, 0.03125},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-16.png",
        width = 217,
        height = 224,
        scale = 0.5,
        shift = {0.0546875, 0.0234375},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-17.png",
        width = 332,
        height = 228,
        scale = 0.5,
        shift = {0.226562, 0.046875},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-18.png",
        width = 290,
        height = 243,
        scale = 0.5,
        shift = {0.195312, 0.0390625},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-19.png",
        width = 349,
        height = 225,
        scale = 0.5,
        shift = {0.609375, 0.0234375},
        tint = platinum_rock_tint
        },
        {
        filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-20.png",
        width = 287,
        height = 250,
        scale = 0.5,
        shift = {0.132812, 0.03125},
        tint = platinum_rock_tint
        }
    }
}
}

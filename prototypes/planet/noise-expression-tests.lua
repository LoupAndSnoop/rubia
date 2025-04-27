--This file is designed to be used with earandel's noise tools.
local function make_noise_expression_from(prototype_name, multiplier)
    local prototype = data.raw["optimized-decorative"][prototype_name]
        or data.raw["simple-entity"][prototype_name]
        or data.raw["entity"][prototype_name]
        or data.raw["tile"][prototype_name]
    assert(prototype, "No prototype found under " .. prototype_name)
    --log(serpent.block(prototype))
    noise_debug.add_visualisation_target(prototype.name, prototype.autoplace.probability_expression, multiplier)
end


noise_debug.hide_map_cliffs()
--noise_debug.remove_non_tile_autoplace()
--noise_debug.tiles_to_visualisation("visualisation", -50, 100, "3-band")
noise_debug.tiles_to_visualisation("visualisation", -1, 2, "3-band")
--noise_debug.tiles_to_visualisation("visualisation", 0, 1, "greyscale")

make_noise_expression_from("rubia-spidertron-remnants", 1)
--noise_debug.add_visualisation_target("debug_rubia_spidertron_remnants", nil, 1)
noise_debug.add_visualisation_target("debug_rubia_pole_remnants", nil, 1)

noise_debug.add_visualisation_target("rubia-cupric-scrap-patches", nil, 1)

noise_debug.add_visualisation_target("rubia_elevation", "(rubia_elevation)", 1/100)
data.raw["noise-expression"].visualisation.expression = "debug_".."rubia_elevation"
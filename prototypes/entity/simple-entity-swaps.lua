--These are rubia-specific entity versions 
-- that are supposed to look identical, but secretly aren't


---Rocket swapping
local rocket = util.table.deepcopy(data.raw["rocket-silo-rocket"]["rocket-silo-rocket"])
rocket.name = "rubia-rocket-silo-rocket"
rocket.localised_name = {"entity-name.rocket-silo-rocket"}
rocket.localised_description = {"entity-description.rocket-silo-rocket"}
rocket.rocket_sprite = {
    layers =
      {
        util.sprite_load("__rubia__/graphics/entity/rocket/rubia-rocket",
      {
        dice_y = 4,
        shift = util.by_pixel( 0, 17.0+48),
        scale = 0.5
      }),
      util.sprite_load("__base__/graphics/entity/rocket-silo/rocket-static-emission",
      {
        dice_y = 4,
        shift = util.by_pixel( 0, 17+48),
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.5
      })
    }
}

local silo = util.table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
silo.name = "rubia-rocket-silo"
--silo.localised_name = {"entity-name.rocket-silo"}
silo.localised_description = {"entity-description.rocket-silo"}
silo.rocket_entity = "rubia-rocket-silo-rocket"
--silo.render_not_in_network_icon=false
silo.fixed_recipe = "rocket-part-rubia"
silo.hidden_in_factoriopedia = true
silo.disabled_when_recipe_not_researched = true
silo.placeable_by = {{item = "rocket-silo", count = 1}}
silo.flags = {"placeable-player", "player-creation", "not-in-made-in"}
silo.logistic_trash_inventory_size = 1

data:extend({rocket, silo})
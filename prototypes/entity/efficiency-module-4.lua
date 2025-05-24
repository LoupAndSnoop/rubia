local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
    {
        type = "module",
        name = "rubia-efficiency-module4", --idk why but -4 makes it not localize correctly
        localised_description = {"item-description.efficiency-module"},
        icon = "__rubia-assets__/graphics/icons/efficiency-module-4.png",
        subgroup = "module",
        color_hint = { text = "E" },
        category = "efficiency",
        tier = 4,
        order = "c[efficiency]-c[efficiency-module-4]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 20 * kg,
        effect =  {consumption = -1, speed=-0.02},--{consumption = -0.5},
        beacon_tint =
        {
          primary = {0, 1, 0},
          secondary = {0.370, 1.000, 0.370, 1.000}, -- #5eff5eff
        },
        art_style = "vanilla",
        requires_beacon_alt_mode = false
      },
})

--[[
{
    type = "produce-achievement",
    name = "crafting-with-efficiency",
    order = "a[progress]-h[crafting-tier-3-module]-b[efficiency]",
    item_product = "efficiency-module-3",
    amount = 1,
    limited_to_one_game = false,
    icon = "__base__/graphics/achievement/crafting-with-efficiency.png",
    icon_size = 128
  },]]

--Bank of common compatibility recipes.
--local common_compat_recipes = require("__rubia__.compat.common-compat-prototypes")
local common_compat_prototypes = {}

local subicon_scale = 0.7--0.5--0.8
local base_icon_size = 64

common_compat_prototypes["electronic-circuit-recipe"] = {
        type = "recipe",
        name = "rubia-compat-electronic-circuit",
        localised_name = {"item-name.electronic-circuit"},
        category = "electronics",
        icons = {
            {icon = "__base__/graphics/icons/electronic-circuit.png",},
            {
                icon = "__rubia-assets__/graphics/planet/rubia-icon.png",
                icon_size = 64,
                scale = (0.5 * defines.default_icon_size / (64 or defines.default_icon_size)) * subicon_scale,
                shift = {x=base_icon_size * subicon_scale/4, y =-base_icon_size * subicon_scale/4},
            },
        },
        surface_conditions = rubia.surface_conditions(),
        ingredients =
        {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "item", name = "copper-cable", amount = 3}
        },
        results = {{type="item", name="electronic-circuit", amount=1}},
        enabled = false,
        allow_productivity = true,
        auto_recycle = false,
    }


return common_compat_prototypes
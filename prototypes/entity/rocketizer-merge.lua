--This file focuses on merging the rocketizer's needs between this mod and RocketCargoInsertion.

local rubia_rocketizer_recipe = data.raw.recipe["rubia-rci-rocketizer"]
local original_rocketizer_recipe = data.raw.recipe["rci-rocketizer"]
local rocketizer_description = rubia_rocketizer_recipe.localised_description
original_rocketizer_recipe.localised_description = rocketizer_description
data.raw["proxy-container"]["rci-rocketizer"].localised_description = rocketizer_description
data.raw["item"]["rci-rocketizer"].localised_description = rocketizer_description

--We DO want to auto-unlock it
if settings.startup["rubia-rocketizer-early-unlock"].value then
    rubia_rocketizer_recipe.auto_recycle = false


else --We DON'T want to auto-unlock it
    local silo_effects = data.raw.technology["rocket-silo"].effects
    for index, effect in pairs(silo_effects) do
        if (effect.type == "unlock-recipe" and effect.recipe == original_rocketizer_recipe.name) then 
            table.remove(silo_effects, index)
            break
        end
    end

    original_rocketizer_recipe.auto_recycle = false
end

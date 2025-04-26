--This file focuses on making edits to technologies in a later stage,
--primarily for productivity techs.


if data.raw.technology["rocket-part-productivity"] then
    table.insert(data.raw.technology["rocket-part-productivity"].effects, {
        type = "change-recipe-productivity",
        recipe = "rocket-part-rubia",
        change = 0.1,
        hidden = true
    })
end


--Sniper turret
for _, index in pairs({1,2,3,4,5,6,7,8,9}) do
    if data.raw.technology["physical-projectile-damage-" .. tostring(index)] then
        table.insert(data.raw.technology["physical-projectile-damage-" .. tostring(index)].effects, {
            type = "turret-attack",
            turret_id = "rubia-sniper-turret",
            modifier = 0.1
          })
    end
end

--[[Cerys
if data.raw.technology["holmium-plate-productivity-1"] then
    table.insert(data.raw.technology["holmium-plate-productivity-1"].effects, {
        type = "change-recipe-productivity",
        recipe = "holmium-craptalysis",
        change = 0.1,
        hidden = true
    })
end
if data.raw.technology["holmium-plate-productivity-2"] then
    table.insert(data.raw.technology["holmium-plate-productivity-2"].effects, {
        type = "change-recipe-productivity",
        recipe = "holmium-craptalysis",
        change = 0.1,
        hidden = true
    })
end]]
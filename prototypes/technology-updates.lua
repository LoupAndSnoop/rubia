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
            modifier = 0.30, --Should be stronger than gun turrets
            icon = "__rubia-assets__/graphics/icons/sniper-turret-icon.png",
            icon_size = 64,
          })
    end
end


--Cerys
if mods["Cerys-Moon-of-Fulgora"] then
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
    end
end





--#region Promethium sci updating


--Remove that science pack from the cost of the given technology (if the tech exists, and if it is there.
local function remove_science_pack_from_tech(science_pack_name, technology_name)
    local tech = data.raw["technology"][technology_name]
    assert(data.raw.tool[science_pack_name],"No valid science pack found with the name: " .. science_pack_name)
    --assert(tech, "Technology not found: " .. technology_name)
    if (not tech) then return end --Tech not found

    for i,entry in pairs(tech.unit.ingredients) do
        if (entry and entry[1] == science_pack_name) then
            table.remove(tech.unit.ingredients,i)
            break
        end
    end
end
--Remove that science pack from the cost of the given technology (if the tech exists, and if it is there.
local function try_add_science_pack_to_tech(science_pack_name, technology_name)
    local tech = data.raw["technology"][technology_name]
    assert(data.raw.tool[science_pack_name],"No valid science pack found with the name: " .. science_pack_name)
    --assert(tech and tech.unit, "Technology not found: " .. technology_name)
    if (not tech or not tech.unit) then return end --Tech not found

    for _,entry in pairs(tech.unit.ingredients) do
        if (entry and entry[1] == science_pack_name) then return end
    end
    table.insert(tech.unit.ingredients, {science_pack_name, 1 })
end

--Conditionally add/remove rubia science from promethium science costs
if settings.startup["remove-rubia-from-promethium_sci"].value then
    remove_science_pack_from_tech("biorecycling-science-pack", "research-productivity")
else 
    try_add_science_pack_to_tech("biorecycling-science-pack", "research-productivity")
    local promethium_tech = data.raw["technology"]["promethium-science-pack"]
    if promethium_tech then 
        table.insert(promethium_tech.prerequisites, "planetslib-rubia-cargo-drops")
        try_add_science_pack_to_tech("biorecycling-science-pack","promethium-science-pack")
    end

    --Corrundum speed tech
    if mods["corrundum"] then
        try_add_science_pack_to_tech("biorecycling-science-pack","research-speed-infinite")
    end
end

--Remove biofusion from anywhere it accidentally got into.
remove_science_pack_from_tech("rubia-biofusion-science-pack", "research-productivity")


--[[
local promethium_tech = data.raw["technology"]["research-productivity"]
if (settings.startup["remove-rubia-from-promethium_sci"].value
    and promethium_tech) then
      for i,entry in pairs(promethium_tech.unit.ingredients) do
        if (entry and entry[1] == "biorecycling-science-pack") then
          table.remove(promethium_tech.unit.ingredients,i)
          break
        end
      end
end]]

--#endregion
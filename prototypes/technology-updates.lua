--This file focuses on making edits to technologies in a later stage,
--primarily for productivity techs.

--#region Helper functions

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

--Add this prerequisite to the given technology (if the tech exists, and if it is there). If it is already there, don't bother.
local function try_add_prerequisite(technology_name, prerequisite)
    local tech = data.raw["technology"][technology_name]
    if not tech then return end
    
    if not tech.prerequisites then tech.prerequisites = {prerequisite}
    else --There already exist prerequisites
        for _, entry in pairs(tech.prerequisites) do
            if entry == prerequisite then return end --It is already there            
        end
        --Not already in the list
        table.insert(tech.prerequisites, prerequisite)
    end
end



--#endregion


--K2SO for some reason nukes this, but it needs to also be done at 
--data stage to capture for maraxsis.
rubia.try_add_science_packs_to_labs() 

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
    if data.raw.technology["cerys-holmium-plate-productivity-1"] then
        table.insert(data.raw.technology["cerys-holmium-plate-productivity-1"].effects, {
            type = "change-recipe-productivity",
            recipe = "rubia-holmium-craptalysis",
            change = 0.1,
        })
    end
    if data.raw.technology["cerys-holmium-plate-productivity-2"] then
        table.insert(data.raw.technology["cerys-holmium-plate-productivity-2"].effects, {
            type = "change-recipe-productivity",
            recipe = "rubia-holmium-craptalysis",
            change = 0.1,
        })
    end
end





--#region Promethium sci updating


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


--#region Lab and biofusion-related

--Biofusion science pack
---If something deleted gleba or messed with gleba content, then remove all biofusion technologies
local biofusion_blocking_mods = {"delete-gleba", "FarmingInAnotherWorld",
    "NoCraftingSurfaceCondition", "no-cond", "no_placement_restriction", 
    "surface_restriction_removal_rubia_compat"}
local blocking_mods_string = ""
for _, entry in pairs(biofusion_blocking_mods) do
    if mods[entry] then
        blocking_mods_string = blocking_mods_string .. entry .. ", "
    end
end
if not data.raw.planet["gleba"] then blocking_mods_string = blocking_mods_string .. "Planet Gleba not found." end
if blocking_mods_string ~= "" then
  local biofusion_tech = data.raw.technology["rubia-biofusion-science-pack"]
  biofusion_tech.icon = "__rubia-assets__/graphics/technology/biofusion-science-pack-removed.png"
  biofusion_tech.localised_description = {"technology-description.rubia-biofusion-science-pack-removed", blocking_mods_string}
  biofusion_tech.effects = {}
end


--Maraxsis promethium-science prod applies to biofusion research
if mods["maraxsis"] and data.raw["technology"]["maraxsis-promethium-productivity"] then
    local maraxsis_effects = data.raw["technology"]["maraxsis-promethium-productivity"].effects
    table.insert(maraxsis_effects,
        {type = "change-recipe-productivity",
        recipe = "rubia-biofusion-promethium-science-pack",
        change = 0.1})
end


--Set Nutrient productivity recipes
local nutrient_prod_effects = {}
local nutrient_prod_magnitude = 0.1
--Manual blacklist for names of recipes to not ever get nutrient prod.
local nutrient_prod_blacklist = rubia_lib.array_to_hashset({
})
for _, recipe in pairs(data.raw.recipe) do
  --Looking for recipes that only make 1 product, and that product is nutrients
  if recipe.results and #recipe.results == 1
  and recipe.results[1].name and recipe.results[1].name == "nutrients" 
  and recipe.category ~= "recycling" --Don't give me recycling nonsense
  and not nutrient_prod_blacklist[recipe.name] then
    table.insert(nutrient_prod_effects, 
      {type = "change-recipe-productivity",
      recipe = recipe.name,
      change = nutrient_prod_magnitude})
  end
end
data.raw.technology["rubia-nutrient-productivity"].effects = nutrient_prod_effects

--#endregion

--Make rubia a prerequisite for this technology. If add_sci_cost, then also make the tech require rubia science.
local function require_rubia_clear_for_tech(technology_name, add_sci_cost)
  local technology = data.raw["technology"][technology_name]
  if technology then 
    table.insert(technology.prerequisites, "planetslib-rubia-cargo-drops")
    if (technology.unit and add_sci_cost) then 
      table.insert(technology.unit.ingredients, {"biorecycling-science-pack",1})
    end
  end
end
--Make project trashdragon a prerequisite for endgame planets, like aquilo
if (settings.startup["require-rubia-for-endgame-planets"].value) then 
    require_rubia_clear_for_tech("planet-discovery-aquilo", true)

    --All the mod planets that get locked behind rubia
    local locked_mod_planets = {
        ["maraxsis"] = "planet-discovery-maraxsis",
        ["Paracelsin"] = "planet-discovery-paracelsin",
        ["tenebris-prime"] = "planet-discovery-tenebris",
        ["tenebris"] = "planet-discovery-tenebris",
    }
    for mod_name, planet_tech in pairs(locked_mod_planets) do
        if mods[mod_name] then require_rubia_clear_for_tech(planet_tech, true) end
    end
end



--#region Merging techs with other mods

--Making sure braking force is properly merged with other mods.
local braking_force = data.raw.technology["braking-force-8"]
try_add_science_pack_to_tech("automation-science-pack", "braking-force-8")
try_add_science_pack_to_tech("logistic-science-pack", "braking-force-8")
--try_add_science_pack_to_tech("chemical-science-pack", "braking-force-8")
--try_add_science_pack_to_tech("production-science-pack", "braking-force-8")
try_add_science_pack_to_tech("military-science-pack", "braking-force-8")
try_add_science_pack_to_tech("biorecycling-science-pack", "braking-force-8")

try_add_prerequisite("braking-force-8",  "braking-force-7")
try_add_prerequisite("braking-force-8",  "planetslib-rubia-cargo-drops")
--Make sure the potency is at least as good as Rubia's
for _, entry in pairs(braking_force.effects) do
    if entry.type == "train-braking-force-bonus" then
        entry.modifier = math.max(0.2, entry.modifier)
    end
end
data.raw.technology["braking-force-7"].max_level = nil

--In case other mods fucked with braking force
for i = 9, 50 do
    local other_braking_tech = data.raw["technology"]["braking-force-" .. tostring(i)]
    if other_braking_tech then 
        log("Warning: Rubia is deleting a technology from another mod: " .. other_braking_tech.name)
        data.raw["technology"][other_braking_tech.name] = nil
    end
end

--#endregion




-----Adding my techs as prereqs for other mod things.

if mods["Paracelsin"] and data.raw.technology["axe-mining-speed"] then
    table.insert(data.raw.technology["axe-mining-speed"].prerequisites, "craptonite-axe")
    try_add_science_pack_to_tech("biorecycling-science-pack", "axe-mining-speed")
end

require("__rubia__.lib.lib")
require("util")
require("__rubia__.prototypes.technology-updates")
local entity_swaps = require("__rubia__.prototypes.entity.simple-entity-swaps")
entity_swaps.make_auto_generated_prototypes()


--Add quality information to factoriopedia.
local function add_quality_factoriopedia_info(entity, factoriopedia_info)
  local factoriopedia_description

  for _, factoriopedia_info in pairs(factoriopedia_info or {}) do
      local header, factoriopedia_function = unpack(factoriopedia_info)
      local localised_string = {"", "[font=default-semibold]", header, "[/font]"}

      for _, quality in pairs(data.raw.quality) do
          if quality.hidden then goto continue end

          local quality_buff = factoriopedia_function(entity, quality)
          if type(quality_buff) ~= "table" then quality_buff = tostring(quality_buff) end
          table.insert(localised_string, {"", "\n[img=quality." .. quality.name .. "] ", {"quality-name." .. quality.name}, ": [font=default-semibold]", quality_buff, "[/font]"})
          ::continue::
      end

      if factoriopedia_description then
          factoriopedia_description[#factoriopedia_description + 1] = "\n\n"
          factoriopedia_description[#factoriopedia_description + 1] = rubia.shorten_localised_string(localised_string)
      else
          factoriopedia_description = localised_string
      end
  end
  entity.factoriopedia_description = rubia.shorten_localised_string(factoriopedia_description)
end

--Add quality info for the wind turbine. Janky but functional.
local turbine_prototype = data.raw["electric-energy-interface"]["rubia-wind-turbine"]
add_quality_factoriopedia_info(turbine_prototype, {
  {{"entity-description.rubia-wind-turbine"}, function(entity, quality_level)
      local base_wind_turbine_power = util.parse_energy(data.raw["electric-energy-interface"]["rubia-wind-turbine"].energy_production)
      local quality_mult = 1 + 0.3 * quality_level.level
      local power_kW_per_nondim = 100/ util.parse_energy("100 kW") --constant to convert between kW and nondimensional power
      return tostring(base_wind_turbine_power * power_kW_per_nondim * quality_mult) .. "kW" --empirically, 50/3 nondimensional power = 1 kW
  end}
})
turbine_prototype.localised_description = turbine_prototype.factoriopedia_description

--#region Science/tech related updates
--Science pack management
--Add my science pack to all labs
local all_lab_types = data.raw['lab']
for _,lab in pairs(all_lab_types) do
  table.insert(lab.inputs,"biorecycling-science-pack")
end


--Biofusion science pack
---If something deleted gleba, then remove all biofusion technologies
if not data.raw.planet["gleba"] or mods["delete-gleba"] then
  local biofusion_tech = data.raw.technology["rubia-biofusion-science-pack"]
  biofusion_tech.icon = "__rubia-assets__/graphics/technology/biofusion-science-pack-removed.png"
  biofusion_tech.localised_description = {"technology-description.rubia-biofusion-science-pack-removed"}
  biofusion_tech.effects = {}
  --biofusion_tech.research_trigger = {type = "craft-item", item = "rubia-biofusion-science-pack", count = 10^50}
end
--Add biofusion science only to biolab
if data.raw.lab.biolab then 
  table.insert(data.raw.lab.biolab.inputs,"rubia-biofusion-science-pack")
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
  if mods["maraxsis"] then require_rubia_clear_for_tech("planet-discovery-maraxsis", true) end
end
--#endregion


--Edits to vanilla recipes

--Make biofusion science possible
local bacteria_recipe = data.raw.recipe["iron-bacteria-cultivation"]
if bacteria_recipe then bacteria_recipe.surface_conditions = nil end


--------
---Other mods add surface properties

if data.raw["surface-property"].temperature then
  data.raw.planet.rubia.surface_properties["temperature"] = 324
end
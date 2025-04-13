
require("__rubia__.lib.lib")
require("util")

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
add_quality_factoriopedia_info(data.raw["electric-energy-interface"]["rubia-wind-turbine"], {
  {{"quality-tooltip.atmosphere-consumption"}, function(entity, quality_level)
      local base_wind_turbine_power = util.parse_energy(data.raw["electric-energy-interface"]["rubia-wind-turbine"].energy_production)
      local quality_mult = 1 + 0.3 * quality_level.level
      local power_kW_per_nondim = 100/ util.parse_energy("100 kW") --constant to convert between kW and nondimensional power
      return tostring(base_wind_turbine_power * power_kW_per_nondim * quality_mult) .. "kW" --empirically, 50/3 nondimensional power = 1 kW
  end}
})


--table.insert(data.raw.lab["lab"].inputs, "biorecycling-science-pack")
--data.raw["fluid"]["petroleum-gas"].fuel_value = "0.6MJ"

--[[
local all_lab_types = data.raw['lab']
local handle_science_populate = true
if (settings.startup["automatically-populate-labs-with-biorecycling-science"].value == false) then handle_science_populate = false end

if(handle_science_populate == true) then
  for k,v in pairs(all_lab_types) do
      table.insert(v.inputs,"biorecycling-science-pack") --add my science pack to all labs
  end
end

if not handle_science_populate then
  table.insert(data.raw["lab"]["pressure-lab"].inputs,"biorecycling-science-pack") --I don't add biorecycling-science-pack to my own prototype. This ensures that I still add it somewhere.
end]]


--[[
data.raw["assembling-machine"]["catalytic-chemical-plant"].graphics_set.frozen_patch =
{
  north =
  {
    filename = "__space-age__/graphics/entity/frozen/chemical-plant/chemical-plant-frozen.png",
    priority = "high",
    width = 220,
    height = 292,
    shift = util.by_pixel(0.5, -9),
    scale = 0.5
  },
  east =
  {
    filename = "__space-age__/graphics/entity/frozen/chemical-plant/chemical-plant-frozen.png",
    priority = "high",
    x = 220,
    width = 220,
    height = 292,
    shift = util.by_pixel(0.5, -9),
    scale = 0.5
  },
  south =
  {
    filename = "__space-age__/graphics/entity/frozen/chemical-plant/chemical-plant-frozen.png",
    priority = "high",
    x = 220 * 2,
    width = 220,
    height = 292,
    shift = util.by_pixel(0.5, -9),
    scale = 0.5
  },
  west =
  {
    filename = "__space-age__/graphics/entity/frozen/chemical-plant/chemical-plant-frozen.png",
    priority = "high",
    x = 220 * 3,
    width = 220,
    height = 292,
    shift = util.by_pixel(0.5, -9),
    scale = 0.5
  }
}]]

--Recipe prod
--[[
local recipe_patch = 
{
  type = "change-recipe-productivity",
  recipe = "sulfonated-plastic",
  change = 0.1
}

local recipe_patch_2 = 
{
  type = "change-recipe-productivity",
  recipe = "sulfonated-plastic-production-alt",
  change = 0.1
}

local recipe_patch_3 = 
{
  type = "change-recipe-productivity",
  recipe = "rocket-fuel-catalytic-chemistry",
  change = 0.1
}

table.insert(data.raw.technology["plastic-bar-productivity"].effects,recipe_patch)
table.insert(data.raw.technology["plastic-bar-productivity"].effects,recipe_patch_2)
]]

--[[
local brute_force = settings.startup["ignore-everything-brute-force-science-into-pressure-lab"].value
local all_packs = data.raw['tool']
if(brute_force == true) then
  if(mods["PlanetsLib"] ~= nil) then
    data.raw["lab"]["pressure-lab"].include_all_base_lab_science = false --Disable what they want to do.
  end

  data.raw["lab"]["pressure-lab"].inputs = {}
  for k,v in pairs(all_packs) do
    if(v.subgroup == "science-pack") then
      table.insert(data.raw["lab"]["pressure-lab"].inputs,v.name .. ",")
    end
  end
end]]

--[[
local update_discovery = settings.startup["require-vulcanus-before-rubia"].value --TODO
if(update_discovery == true) then
  data.raw["technology"]["planet-discovery-rubia"].unit = 
  {
      count = 1000,
      ingredients =
      {
          { "automation-science-pack",      1 },
          { "logistic-science-pack",        1 },
          { "chemical-science-pack",        1 },
          { "space-science-pack",           1 },
      },
      time = 60
  }
  data.raw["technology"]["planet-discovery-rubia"].prerequisites = { "space-platform-thruster","metallurgic-science-pack"}
end]]


--[[
local update_reduction_recipes = settings.startup["force-reduction-requires-plates"].value
if(update_reduction_recipes == true) then
  data.raw["recipe"]["force-reduction-iron"].ingredients = 
  {
    {type ="item", name ="iron-plate", amount = 1},
    {type ="fluid", name ="iron-sulfate-solution", amount = 200},
    {type ="fluid", name ="water", amount = 100},
  }

  data.raw["recipe"]["force-reduction-copper"].ingredients = 
  {
    {type ="item", name ="copper-plate", amount = 1},
    {type ="fluid", name ="copper-sulfate-solution", amount = 200},
    {type ="fluid", name ="water", amount = 100},
  }

end]]

--[[
---Other mod compatibility
if(mods["castra"]) then
  table.insert(data.raw["technology"]["special-ammo-productivity"].effects,
  {       
    type = "change-recipe-productivity",
    recipe = "sulfur-poison-capsule",
    change = 0.1
  }
  )

  table.insert(data.raw["technology"]["explosive-ammo-productivity"].effects,
  {       
    type = "change-recipe-productivity",
    recipe = "blue-rocket",
    change = 0.1
  }
  )

end

if(mods["cubium"]) then
  data:extend(
    {        
        {
            type ="recipe",
            name ="biorecycling-science-pack-cubic",
            category ="catalytic-chemistry",
            subgroup = "cubic",
            icons = 
            {
              {
                icon = "__cubium__/graphics/icons/matter-cube-yellow.png",
                scale = 0.9
              },
              {
                icon = "__corrundum__/graphics/icons/biorecycling-science-pack.png",
                scale = 0.6,
              }
            },
            enabled = false,
            ingredients = --TODO rebalence based on what is available. Let me put all the recipes in...
            {
              {type ="item", name ="sulfur", amount = 2},
              {type ="item", name ="platinum-plate", amount = 1},
              {type ="fluid", name ="sulfuric-acid", amount = 100}, 
              {type = "item", name = "inverted-microcube", amount = 1},
              {type = "fluid", name = "dream-concentrate", amount = 50},
            },
            surface_conditions =
            {
                {
                    property ="pressure",
                    min = 6000,
                    max = 6000
                },
                {
                    property ="magnetic-field",
                    min = 99,
                    max = 99
                }
            },
            energy_required = 15,
            results =
            {
              {type ="item", name ="biorecycling-science-pack", amount = 2},
              {type = "item", name = "inverted-dormant-microcube", amount = 1, ignored_by_productivity = 9999}
            },
            allow_productivity = true,
            main_product ="biorecycling-science-pack",
            factoriopedia_description ="Sulfur based science only made on corrundum.",
            crafting_machine_tint =
            {
              primary = {r = 1.000, g = 0.912, b = 0.036, a = 1.000}, --rgb(255, 132, 9)
              secondary = {r = 0.707, g = 0.797, b = 0.335, a = 1.000}, --rgb(203, 160, 85)
              tertiary = {r = 0.681, g = 0.635, b = 0.486, a = 1.000}, --rgb(190, 147, 97)
              quaternary = {r = 1.000, g = 0.804, b = 0.000, a = 1.000}, --rgb(255, 136, 0)
            },
        },
    }
  )

  table.insert(data.raw["technology"]["cube-mastery-4"].effects,
  {       
    type = "unlock-recipe",
    recipe = "biorecycling-science-pack-cubic",
  }
  )
end
]]
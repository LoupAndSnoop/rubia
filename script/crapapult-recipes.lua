--Thanks to GotLag for the base for this file, from his Flare Stack mod!
local item_sounds = require("__base__.prototypes.item_sounds")

_G.crapapult = _G.crapapult or {}

local crapapult_recipe_base_energy = 0.02

--Crapapult blacklist for this mod. The external blacklist is declared earlier, and can be messed with by other mods.
--This should be a list of all the names of items to NOT be able to yeet normally.
local internal_blacklist = {
    "biorecycling-science-pack",
    "ghetto-biorecycling-science-pack",
    "makeshift-biorecycling-science-pack",
    "spoilage",
    "gun-turret",
}
--Make the yeet- variants
local yeet_variants = {}
for _, entry in pairs(internal_blacklist) do table.insert(yeet_variants, "yeet-" .. entry) end
rubia_lib.merge(internal_blacklist,yeet_variants)


local total_blacklist = rubia_lib.merge(internal_blacklist, crapapult.external_blacklist)
--Make this a dictionary, like a hashset to quickly check.
crapapult.blacklist = {}
if (total_blacklist) then 
    for _, v in pairs(total_blacklist) do crapapult.blacklist[v] = 1 end
end


--#region Generic crapapult recipes
-- returns icon/icons always in the form of a table of icons
function crapapult.get_icons(prototype)
  if prototype.icons then
    return table.deepcopy(prototype.icons)
  else
    return { {
      icon = prototype.icon,
      icon_size = prototype.icon_size,
      icon_mipmaps = prototype.icon_mipmaps
    } }
  end
end

local no_icon = {icon="__core__/graphics/empty.png"}
-- generates a recipe to incinerate the specified non-fluid prototype
function crapapult.yeet_recipe(item, category, craft_category)
  local newicons = crapapult.get_icons(item)
  table.insert(newicons, no_icon)
  local local_item_name = rubia.get_item_localised_name(item.name)
  data:extend({
    {
      type = "recipe",
      name = "yeet-" .. category .. "-" .. item.name,
      --localised_name = "yeet-" .. "(" .. category .. ") " .. item.name,
      localised_name = {"rubia-crapapult.yeet-recipe", local_item_name},
      localised_description = {"rubia-crapapult.yeet-recipe-description", local_item_name},

      category = craft_category,
      enabled = true,
      hidden_in_factoriopedia = true,
      hide_from_player_crafting = true,
      hide_from_signal_gui = true,
      hidden = true,
      energy_required = crapapult_recipe_base_energy,--1,
      ingredients =
      {
        { type = "item", name = item.name, amount = 1 }
      },
      results = {},
      icons = newicons,
      icon_size = 64,
      subgroup = "yeeting-items",
      order = "zz[yeet]"
    }
  })
end

-- create Yeet recipe for any item that is not blacklisted
for _, vi in pairs(data.raw.item) do
    if (not crapapult.blacklist[vi.name]) then
        crapapult.yeet_recipe(vi, "item", "crapapult")
    end
end

-- non-item categories to yeet too
crapapult.category_list =
{
  "capsule",
  "ammo",
  "gun",
  "module",
  "armor",
  "mining-tool",
  "repair-tool",
  "rail-planner",
}
for _, c in pairs(crapapult.category_list) do
  if data.raw[c] then
    for _, i in pairs(data.raw[c]) do
      crapapult.yeet_recipe(i, c, "crapapult")
    end
  end
end
--#endregion

--#region Special crapapult recipes

--Special yeeting recipes. Make a special item/recipe automatically for items
--specially marked to be yoten
local function special_yeet_recipe(item_name, icon, icon_size)
  icon_size = icon_size or 64
  local local_item_name = rubia.get_item_localised_name(item_name)
  return
  {{
    type = "recipe",
    name = "yeet-" .. item_name,
    icon = icon,
    icon_size = icon_size,
    category = "crapapult",
    enabled = true,

    localised_name = {"rubia-crapapult.yeet-recipe", local_item_name},
    localised_description = {"rubia-crapapult.yeet-recipe-description", local_item_name},

    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    hide_from_signal_gui = true,
    hidden = true,
    energy_required = 0.1,
    ingredients = {{ type = "item", name = item_name, amount = 1 }},
    results = {{ type = "item", name = "yeet-" .. item_name, amount = 1 }},
    subgroup = "yeeting-items",
    order = "zz[yeet]",
    auto_recycle=false,
    allow_productivity=false,
  },
  {
    type = "item",
    name = "yeet-" .. item_name,
    icon = icon,
    icon_size = icon_size,
    order = "l",
    subgroup = "science-pack",
    color_hint = { text = "T" },

    localised_name = {"rubia-crapapult.yeet-item", local_item_name},
    localised_description = {"rubia-crapapult.yeet-item-description", local_item_name},

    inventory_move_sound = item_sounds.resource_inventory_move,
    pick_sound = item_sounds.resource_inventory_pickup,
    drop_sound = item_sounds.resource_inventory_move,
    stack_size = 50,
    default_import_location = "rubia",
    weight = 10000*kg,
    spoil_ticks = 2,
    spoil_result = nil,
    hidden=true,
    hidden_in_factoriopedia=true,
    auto_recycle=false,
  },
}
end

data.extend(special_yeet_recipe("makeshift-biorecycling-science-pack","__rubia-assets__/graphics/icons/science/yeet_torus_clear_brown.png"))
data.extend(special_yeet_recipe("ghetto-biorecycling-science-pack","__rubia-assets__/graphics/icons/science/yeet_sphere_tubed_clear_brown.png"))
data.extend(special_yeet_recipe("biorecycling-science-pack","__rubia-assets__/graphics/icons/science/yeet_sphere_spiked_clear_brown.png"))
data.extend(special_yeet_recipe("spoilage","__rubia-assets__/graphics/icons/science/yeet-spoilage.png"))
data.extend(special_yeet_recipe("gun-turret","__rubia-assets__/graphics/icons/science/yeet-gun-turret.png"))
--#endregion
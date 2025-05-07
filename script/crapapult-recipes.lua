--Thanks to GotLag for the base for this file, from his Flare Stack mod!
local item_sounds = require("__base__.prototypes.item_sounds")

_G.crapapult = _G.crapapult or {}

local crapapult_recipe_base_energy = 0.02




--Crapapult blacklist for this mod. The external blacklist is declared earlier, and can be messed with by other mods.
--This should be a list of all the names of items to NOT be able to yeet normally.
local internal_blacklist = {}
--[[
    "biorecycling-science-pack", "ghetto-biorecycling-science-pack", "makeshift-biorecycling-science-pack", "spoilage", "gun-turret",
    "metallurgic-science-pack",
}]]

--Check all technologies for yeeting triggers, to set them aside for blacklisting
local yeet_trigger_tech_items = {}
for _, tech in pairs(data.raw["technology"]) do
  local trigger = tech.research_trigger
  --Do I need a more stringent search?
  if trigger and trigger.type == "craft-item" and trigger.item
    and (type(trigger.item) == type("a")) and string.find(trigger.item, "yeet-") --Yeet trigger
    and rubia.technology_is_prerequisite("planet-discovery-rubia", tech.name) then --And the tech depends on rubia
    table.insert(yeet_trigger_tech_items, string.sub(trigger.item,6,-1))
  end
end
rubia_lib.merge(internal_blacklist,yeet_trigger_tech_items)


--Make the yeet- variants of everything in the blacklist
local yeet_variants = {}
for _, entry in pairs(internal_blacklist) do table.insert(yeet_variants, "yeet-" .. entry) end
rubia_lib.merge(internal_blacklist,yeet_variants)


local total_blacklist = rubia_lib.merge(internal_blacklist, crapapult.external_blacklist)
--Make this a dictionary, like a hashset to quickly check.
local crapapult_blacklist = {}
if (total_blacklist) then 
    for _, v in pairs(total_blacklist) do crapapult_blacklist[v] = 1 end
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

local subicon_scale = 0.7--0.5--0.8
local base_icon_size = 64
--Make a generic yeet recipe icon
local function generate_crapapult_recipe_icons_from_item(item)
  local icons = {}
  if item.icons == nil then
    icons = {
      {icon = "__rubia-assets__/graphics/icons/yeet-base.png"},--"__quality__/graphics/icons/recycling.png"},
      {
        icon = item.icon,
        icon_size = item.icon_size,
        scale = (0.5 * defines.default_icon_size / (item.icon_size or defines.default_icon_size)) * subicon_scale,
        shift = {x=base_icon_size * subicon_scale/4, y =-base_icon_size * subicon_scale/4},
      },
      {icon = "__rubia-assets__/graphics/icons/yeet-base-foreground.png"},--"__quality__/graphics/icons/recycling-top.png"},
    }
  else
    icons = {{icon = "__rubia-assets__/graphics/icons/yeet-base.png",}}--"__quality__/graphics/icons/recycling.png"}}
    for i = 1, #item.icons do
      local icon = table.deepcopy(item.icons[i]) -- we are gonna change the scale, so must copy the table
      icon.scale = ((icon.scale == nil) and (0.5 * defines.default_icon_size / (icon.icon_size or defines.default_icon_size)) or icon.scale) * subicon_scale
      icon.shift = util.mul_shift(icon.shift, subicon_scale) or {0,0}
      icon.shift = {(icon.shift[1] or 0) + base_icon_size * subicon_scale/4,
                    (icon.shift[2] or 0) - base_icon_size * subicon_scale/4}
      --icon = scale_icon(icon)
      icons[#icons + 1] = icon
    end
    icons[#icons + 1] = {icon = "__rubia-assets__/graphics/icons/yeet-base-foreground.png"}--"__quality__/graphics/icons/recycling-top.png"
  end
  return icons
end



local no_icon = {icon="__core__/graphics/empty.png"}
-- generates a recipe to incinerate the specified non-fluid prototype
function crapapult.yeet_recipe(item, category, craft_category)
  local newicons = generate_crapapult_recipe_icons_from_item(item)
  --local newicons = crapapult.get_icons(item)
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
    if (not crapapult_blacklist[vi.name]) then
        crapapult.yeet_recipe(vi, "item", "crapapult")
    end
end

-- non-item categories to yeet too
local crapapult_category_list =
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
for _, c in pairs(crapapult_category_list) do
  if data.raw[c] then
    for _, i in pairs(data.raw[c]) do
      crapapult.yeet_recipe(i, c, "crapapult")
    end
  end
end
--#endregion

--#region Special crapapult recipes

--Special yeeting recipes. Make a special item/recipe automatically for items
--specially marked to be yoten. If no custom icon is given, use an auto-generated one.
local function special_yeet_recipe(item_name, icon, icon_size)
  icon_size = icon_size or 64
  local local_item_name = rubia.get_item_localised_name(item_name)

  local item = data.raw.item[item_name] or data.raw.tool[item_name]
  --If item doesn't exist, just skip it. Mostly for external mods/planets
  if not item then log("No item found for " .. item_name); return end

  local icons = (icon and {{icon=icon, icon_size = icon_size}}) 
    or generate_crapapult_recipe_icons_from_item(item)

  return
  {{
    type = "recipe",
    name = "yeet-" .. item_name,
    --icon = icon,    
    icons = icons,
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
    flags = {"ignore-spoil-time-modifier"},
    --icon = icon,
    icons = icons,
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

--Actually make the items and recipes
for _, item in pairs(yeet_trigger_tech_items) do
  data.extend(special_yeet_recipe(item))
end


--[[
data.extend(special_yeet_recipe("makeshift-biorecycling-science-pack"))--,"__rubia-assets__/graphics/icons/science/yeet_torus_clear_brown.png"))
data.extend(special_yeet_recipe("ghetto-biorecycling-science-pack"))--,"__rubia-assets__/graphics/icons/science/yeet_sphere_tubed_clear_brown.png"))
data.extend(special_yeet_recipe("biorecycling-science-pack"))--,"__rubia-assets__/graphics/icons/science/yeet_sphere_spiked_clear_brown.png"))
data.extend(special_yeet_recipe("spoilage"))--,"__rubia-assets__/graphics/icons/science/yeet-spoilage.png"))
data.extend(special_yeet_recipe("gun-turret"))--,"__rubia-assets__/graphics/icons/science/yeet-gun-turret.png"))

data.extend(special_yeet_recipe("metallurgic-science-pack"))
]]
--#endregion
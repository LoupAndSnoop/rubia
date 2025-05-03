--Thanks to GotLag for the base for this file, from his Flare Stack mod!

_G.crapapult = _G.crapapult or {}

local crapapult_recipe_base_energy = 0.02

--Crapapult blacklist for this mod. The external blacklist is declared earlier, and can be messed with by other mods.
--This should be a list of all the names of items to NOT be able to yeet normally.
local internal_blacklist = {
    "biorecycling-science-pack",
    "ghetto-biorecycling-science-pack",
    "makeshift-biorecycling-science-pack",
    "spoilage",
    "yeet-biorecycling-science-pack",
    "yeet-ghetto-biorecycling-science-pack",
    "yeet-makeshift-biorecycling-science-pack",
    "yeet-spoilage",
}
local total_blacklist = rubia_lib.merge(internal_blacklist, crapapult.external_blacklist)
--Make this a dictionary, like a hashset to quickly check.
crapapult.blacklist = {}
if (total_blacklist) then 
    for _, v in pairs(total_blacklist) do crapapult.blacklist[v] = 1 end
end



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
  data:extend({
    {
      type = "recipe",
      name = "yeet-" .. category .. "-" .. item.name,
      localised_name = "yeet-" .. "(" .. category .. ") " .. item.name,
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

-- non-item categories to incinerate too
crapapult.category_list =
{
  "capsule",
  "ammo",
  "gun",
  "module",
  "armor",
  "mining-tool",
  "repair-tool"
}
for _, c in pairs(crapapult.category_list) do
  if data.raw[c] then
    for _, i in pairs(data.raw[c]) do
      crapapult.yeet_recipe(i, c, "crapapult")
    end
  end
end
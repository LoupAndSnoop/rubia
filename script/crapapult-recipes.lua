local icons = "__Flare Stack__/graphics/icon/"

-- Declare a namespace
flarestack = {}

-- returns icon/icons always in the form of a table of icons
function flarestack.get_icons(prototype)
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

local no_icon = {
  icon = icons .. "no.png",
  icon_size = 64
}

local function fluid_name_is_flarable(name)
	if string.sub(name, 1, 10) == "parameter-" then
		return false
	end

	if name == "fluid-unknown" then
		return false
	end

	if name == "lava" then
		return false
	end

	return true
end

-- generate flare recipe for every fluid
for ki, vi in pairs(data.raw.fluid) do
	if fluid_name_is_flarable(vi.name) then
    local newicons = flarestack.get_icons(vi)
    table.insert(newicons, no_icon)
    data:extend({
      {
        type = "recipe",
        name = vi.name .. "-flaring",
        localised_name = vi.name .. " flaring",
        category = "flaring",
        enabled = true,
        hidden_in_factoriopedia = true,
        hide_from_player_crafting = true,
        hide_from_signal_gui = true,
        --hidden = true,
        energy_required = 1,
        ingredients =
        {
          { type = "fluid", name = vi.name, amount = settings.startup["flare-stack-fluid-rate"].value }
        },
        results = {},
        icons = newicons,
        icon_size = 64,
        subgroup = "flare-incineration-fluid",
        order = "z[incineration]"
      }
    })
  end
end

-- generates a recipe to incinerate the specified non-fluid prototype
function flarestack.incinerateRecipe(item, category, craft_category)
  local newicons = flarestack.get_icons(item)
  table.insert(newicons, no_icon)
  data:extend({
    {
      type = "recipe",
      name = category .. "-" .. item.name .. "-incineration",
      localised_name = "(" .. category .. ") " .. item.name .. " incineration",
      category = craft_category,
      enabled = true,
      hidden_in_factoriopedia = true,
      hide_from_player_crafting = true,
      hide_from_signal_gui = true,
      --hidden = true,
      -- this is now done through incinerator crafting speed
      -- energy_required = 1.0 / settings.startup["flare-stack-item-rate"].value,
      energy_required = 1,
      ingredients =
      {
        { type = "item", name = item.name, amount = 1 }
      },
      results = {},
      icons = newicons,
      icon_size = 64,
      subgroup = "flare-incineration-items",
      order = "zz[incineration]"
    }
  })
end

-- create incineration recipe for any item that isn't chemical fuel, and also wood
for ki, vi in pairs(data.raw.item) do
  if not (vi.fuel_value and vi.fuel_category and vi.fuel_category == "chemical") then
    flarestack.incinerateRecipe(vi, "item", "incineration")
  elseif vi.name ~= "wood" then
    flarestack.incinerateRecipe(vi, "item", "fuel-incineration")
  end
end
-- wood is a chemical fuel but we want to incinerate it anyway
flarestack.incinerateRecipe(data.raw["item"]["wood"], "item", "incineration")

-- non-item categories to incinerate too
flarestack.category_list =
{
  "capsule",
  "ammo",
  "gun",
  "module",
  "armor",
  "mining-tool",
  "repair-tool"
}
for _, c in pairs(flarestack.category_list) do
  if data.raw[c] then
    for _, i in pairs(data.raw[c]) do
      flarestack.incinerateRecipe(i, c, "incineration")
    end
  end
end
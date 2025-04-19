--This file fixes issues with auto-generated recycler recipes at the end of 
--the data stage, before data-updates.

--All recipes in the biorecycling category should have auto_recycle set false, unless
--explicitly stated
local function recipe_has_category(recipe, category) 
    if recipe.category == category then return true end
    if (type(recipe.category) == "table") then
      for _, cat in pairs(recipe.category) do 
        if cat == category then return true end
      end
    end
    return false
  end
  for _, recipe in pairs(data.raw["recipe"]) do
    if recipe_has_category(recipe,"biorecycling") 
      and (not recipe.auto_recycle) then
      recipe.auto_recycle = false
    end
  end
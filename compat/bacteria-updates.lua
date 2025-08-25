--This file manages changing the iron bacteria recipe,
-- and other recipes associated with iron bacteria.

--Make biofusion science possible
local bacteria_recipe = data.raw.recipe["iron-bacteria-cultivation"]
if bacteria_recipe then bacteria_recipe.surface_conditions = nil end

--Go ban any recipe that makes iron bacteria from Rubia, except for the desired one recipe.
for name, recipe in pairs(data.raw["recipe"]) do
    local results = recipe.results
    if results and type(results) == "table" --In case someone pulls another RJdunlap on us
        and name ~= "iron-bacteria-cultivation" then

        --Check if any result is iron bacteria. If so, ban it
        for _, entry in pairs(results or {}) do
            if entry.name == "iron-bacteria" then
                rubia.ban_from_rubia(recipe)
                log("Iron bacteria recipe is being auto-banned from Rubia: " .. name)
                break
            end
        end
    end
end
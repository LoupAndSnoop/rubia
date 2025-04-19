
--Shamelessly taken from Muluna, who shamelessly took this from Maraxsis.

local Public = {}
function Public.on_built_rocket_silo(event)
    local entity = event.entity
    if not entity.valid then return end
    
    local prototype = entity.name == "entity-ghost" and entity.ghost_prototype or entity.prototype
    
    if prototype.type ~= "rocket-silo" 
        or entity.get_recipe()
        or entity.surface.name ~= "rubia"
        or not prototype.crafting_categories["rocket-building"] then return end

    --We need to set the rocket part recipe for rubia.
    entity.recipe_locked = false
    entity.set_recipe("rocket-part-rubia")
    entity.recipe_locked = true
end

return Public
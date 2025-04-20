
--Shamelessly taken from Muluna, who shamelessly took this from Maraxsis.

local Public = {}
function Public.on_built_rocket_silo(event)
    local entity = event.entity
    if not entity.valid then return end
    
    local prototype = entity.name == "entity-ghost" and entity.ghost_prototype or entity.prototype

    if prototype.type ~= "rocket-silo" 
        --if another mod set the recipe already (on a different surface), don't change it
        or (entity.get_recipe() and entity.surface.name ~= "rubia")
        or not prototype.crafting_categories["rocket-building"] then return end



    --We need to set the rocket part recipe for rubia, but also put it back for every other surface.
    if (entity.surface.name == "rubia") then
        entity.recipe_locked = false
        entity.set_recipe("rocket-part-rubia")
        entity.recipe_locked = true
    else
        entity.recipe_locked = false
        entity.set_recipe("rocket-part")
        entity.recipe_locked = true
    end
end


--[[script.on_event(defines.events.on_built_entity, function(event)
    Public.on_built_rocket_silo(event)
end)]]


return Public
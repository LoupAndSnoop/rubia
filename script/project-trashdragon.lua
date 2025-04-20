
--Shamelessly taken from Muluna, who shamelessly took this from Maraxsis.

--enforce that the entity passed in will have its recipe changed to the rubia-specific rocket part recipe.
rubia.timing_manager.register("project-trashdragon-recheck", function(entity)
    if (entity.valid and entity.get_recipe()
        and entity.get_recipe().name ~= "rocket-part-rubia") then
            entity.recipe_locked = false
            entity.set_recipe("rocket-part-rubia")
            entity.recipe_locked = true
    end
end)



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

        --Queue up for next frame to re-correct the rocket recipe in case someone fucked with it
        rubia.timing_manager.wait_then_do(1,"project-trashdragon-recheck",{entity})
        --[[
        rubia.timing_manager.wait_then_do(1,function()
            if (entity.valid and entity.get_recipe()
                and entity.get_recipe().name ~= "rocket-part-rubia") then
                    entity.recipe_locked = false
                    entity.set_recipe("rocket-part-rubia")
                    entity.recipe_locked = true
                end
            end)]]
    else
        entity.recipe_locked = false
        entity.set_recipe("rocket-part")
        entity.recipe_locked = true
    end
end

return Public
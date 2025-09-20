require("__rubia__.lib.timing-manager")

--[[In control stage, determine if the given tech originated on Rubia.
rubia_lib.is_rubia_tech = function(technology_name)
    prototypes.get_history("technology", technology_name).created
prototypes.get_history("technology", technology_name).created == "rubia"
end]]

--Output a map of "surface-name" = {array of entities with that name on that surface}
function rubia_lib.find_all_entity_of_name(input_name)
  local out_entity_table = {}
  local surface_array = game.surfaces
  for key, _ in pairs(surface_array or {}) do --names of surfaces are in keys
      local current_surface = game.get_surface(key)
      local entity_array = current_surface.find_entities_filtered{name = input_name} --input_name

      if(table_size(entity_array) == 0) then -- That entity is not on this surface
        out_entity_table[current_surface.name] = {}
      else  out_entity_table[current_surface.name] = entity_array
      end
  end
  return out_entity_table
end

---Return an array of all LuaRenderingObjects that target a specific entity_name.
---@param entity_name string name of the entity prototype to search for
---@param include_invalid boolean True => Include any renders that target an entity that is currently invalid. False/nil => exclude those.
---@return LuaRenderObject[] found_renderings array of all the found renderings
function rubia_lib.find_entity_renderings(entity_name, include_invalid)
    local all_renderings = rendering.get_all_objects("rubia")
    local found_renderings = {}
    for _, entry in pairs(all_renderings) do
        local target = entry.target.entity
        if target then
            if not target.valid then
              if include_invalid then table.insert(found_renderings, entry) end
            else
              local true_name = target.name == "entity-ghost" and target.ghost_name or target.name
              if true_name == entity_name then table.insert(found_renderings, entry) end
            end
        end
    end
    return found_renderings
end

--[[
---Remove all renderings that target a specific entity name
---@param entity_name string name of the entity prototype to search for
function rubia_lib.remove_entity_renderings(entity_name)
    local to_remove = rubia_lib.find_entity_renderings(entity_name, true)
    for _, entry in pairs(to_remove) do entry.destroy() end
end
]]

---Assert that the given mod data was not deleted or modified by any other mods.
---@param mod_data_name string name of the mod-data
function rubia_lib.assert_protected_mod_data(mod_data_name)
    assert(prototypes.mod_data[mod_data_name], "A mod destroyed critical mod data required for Rubia to function.")
    local THIS_MOD = "rubia"

    local history = prototypes.get_history("mod-data", mod_data_name)
    assert(history.created == THIS_MOD, "A mod overwrote critical mod data required for Rubia to function."
        .. "Please disable this mod: " .. history.created)
    
    assert(table_size(history.changed) == 0, "A mod(s) tampered with critical mod data required for Rubia to function."
        .. "Please disable this mod(s): " .. serpent.line(history.changed))
end
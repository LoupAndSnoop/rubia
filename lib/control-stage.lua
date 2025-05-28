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
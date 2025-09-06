--Correct all wind turbines.
if not storage.rubia_surface then return end --Rubia has no surface yet.

--With the wind turbine update, make all wind turbines operable.
local all_entity = rubia_lib.find_all_entity_of_name("rubia-wind-turbine")
for _, entity_list in pairs(all_entity or {}) do
    for _, entity in pairs(entity_list or {}) do
        if not entity.valid then goto continue end
        local true_name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
        if true_name ~= "rubia-wind-turbine" then goto continue end
        entity.operable = true
        ::continue::
    end
end
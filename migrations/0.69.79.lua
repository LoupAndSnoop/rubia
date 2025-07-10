
if storage.rubia_surface then storage.rubia_surface.peaceful_mode = false end


--Factorissimo
if game.surfaces["rubia-factory-floor"] 
    and (script.active_mods["Factorissimo2"] or script.active_mods["factorissimo-2-notnotmelon"]) then
    local factory_floor = game.surfaces["rubia-factory-floor"]
    if factory_floor then
        factory_floor.ignore_surface_conditions = false
        factory_floor.set_property("rubia-asteroid-density", 0)
        factory_floor.set_property("rubia-wind-speed", 300)
    end

    --[[
    local to_delete = factory_floor.find_entities_filtered{type = "linked-belt"}
    local entity_names_to_break = {"factory-inside-pump-input", "factory-power-pole"}
    for _, name in pairs(entity_names_to_break) do
        to_delete = rubia_lib.merge(to_delete, factory_floor.find_entities_filtered{name = name})
    end

    for _, entry in pairs(to_delete) do
        if entry and entry.valid then entry.destroy() end
    end

    --Prevent future building
    local all_tiles = {}
    for name in pairs(prototypes.tile) do
        if name ~= "out-of-map" then table.insert(all_tiles, name) end
    end

    --factory_floor.find_tiles_filtered{}
    ]]
end

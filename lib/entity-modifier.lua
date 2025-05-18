--This file controls the runtime modification of entities in a generic way.

local entity_modifier = {}

--Maintain a global cache stored of that specific entity
--string that corresponds to a handle of a specific sort of entity to store => array of that LuaEntity.
storage.modified_entity_registry = storage.modified_entity_registry or {}

---Find ALL entities across ALL surfaces that satisfy a specific filter.
---This function can be used to either create a new cache from scratch OR
---for hard refreshing a given cache.
---@param entity_handler string string that represents the ID associated with that entity category.
---@param entity_filter EntitySearchFilters filter of what entities should count.
entity_modifier.create_entity_cache = function(entity_handler, entity_filter)
    --[[local each_surface_entities = {}
    for i, surface in pairs(game.surfaces) do
        table.insert(each_surface_entities, 
            surface.find_entities_filtered(entity_filter))
    end ----entity_list = rubia_lib.array_concat(each_surface_entities),]]

    --Make a hashset
    local entity_hashset = {}
    for i, surface in pairs(game.surfaces) do
        local surface_entities = surface.find_entities_filtered(entity_filter)
        for _, entity in surface_entities do
            entity_hashset[entity] = true
        end
    end

    storage.modified_entity_registry = storage.modified_entity_registry or {}
    storage.modified_entity_registry[entity_handler] = {
        entity_hashset = entity_hashset,
        entity_filter = entity_filter,
    }
end

---Return true if the LuaEntity satisfies the given EntitySearchFilters.
---Don't check every possible part of the filter--just key parts.
---@param entity LuaEntity
---@param filter EntitySearchFilters
local function entity_satisfies_filter(entity, filter)
    if not entity.valid then return false end

    local reject = false

    --Reject by entity type. (most common case)
    if filter.name and (entity.name ~= (filter.name.name or filter.name)) 
        and not rubia_lib.array_find_condition(filter.name, function(entityID)
            return entity.name == (entityID.name or entityID) end) then
        return false
    end
    --[[if filter.name and (entity.name ~= (filter.name.name or filter.name)) then
        --Need to check by array
        reject = true
        for _, entityID in filter.name do
            reject = entity.name == (entityID.name or entityID)
        end
        if reject then return false end
    end]]
    
    --Reject by ghost type
    if filter.ghost_name and (entity.ghost_name ~= (filter.ghost_name.name or filter.ghost_name)) then
        --Need to check by array
        reject = true
        for _, entityID in filter.ghost_name do
            reject = entity.ghost_name == (entityID.ghost_name or entityID)
        end
        if reject then return false end
    end


    --[[Reject by wrong prototype, as true name
    local prototype = (entity.type ~= "entity-ghost") and entity.type or entity.ghost_type
    if filter.type and (prototype ~= filter.type)
        and not rubia_lib.array_find(filter.type, prototype) then
        return false
    end]]
    --Prototype rejection. Filters has separation for ghost types
    if filter.type and (entity.type ~= filter.type)
        and not rubia_lib.array_find(filter.type, entity.type) then
        return false
    end
    if filter.ghost_type and (entity.ghost_type ~= filter.ghost_type)
        and not rubia_lib.array_find(filter.ghost_type, entity.ghost_type) then
        return false
    end

    --Reject by wrong force
    if filter.force and (entity.force ~= (game.forces[filter.force] or filter.force)) then
        --Need to check by array
        reject = true
        for _, forceID in filter.force do
            reject = entity.force == (game.forces[forceID] or forceID)
        end
        if reject then return false end
    end
    
    return true
end


---LuaEntity was just built. Add it to the cache.
---@param entity LuaEntity add this entity to the cache.
entity_modifier.on_build_update_cache = function(entity)
    if not entity.valid then return end
    local to_deregister = false
    for _, entry in pairs(storage.modified_entity_registry) do
        if entity_satisfies_filter(entity, entry.entity_filter) then
            entry.entity_hashset[entity] = true
            to_deregister = true
        end
    end

    --Make sure we deregister
    if to_deregister then
        local delist_ID = script.register_on_object_destroyed(entity)
        storage.modified_entity_deregistry = storage.modified_entity_deregistry or {}
        storage.modified_entity_deregistry[delist_ID] = entity
    end
end

---LuaEntity was just destroyed. Delist it.
---@param entity_reg_ID uint Entity registration ID
entity_modifier.on_destroy_update_cache = function(entity_reg_ID)
    local entity = storage.modified_entity_deregistry 
        and storage.modified_entity_deregistry[entity_reg_ID]

    if not entity then return end --Was never registered
    --Then go delist
    for _, entry in pairs(storage.modified_entity_registry) do
        entry.entity_hashset[entity] = nil
    end
end


---Call this function on each LuaEntity
---@param entity_handler string string that represents the ID associated with that entity category.
---@param execute function function of LuaEntity to invoke on LuaEntity connected to that entity handler.
entity_modifier.apply_to_all_entities = function(entity_handler, execute)
    local registry = storage.modified_entity_registry[entity_handler]
    assert(registry, "We can't invoke a function tied to that entity handler if its cache has not been made yet! Handler = " .. entity_handler)
    for _, entity in pairs(registry.entity_hashset) do
        if entity.valid then execute(entity) end
    end
end


return entity_modifier
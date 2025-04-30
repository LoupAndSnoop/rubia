--The scripts on this file exist to monitor which chunks have player activity on them.
--This file assume the surface is locked to rubia, and will not ask 
--questions about whether or not the surface is relevant.

_G.chunk_checker = {}

local chunk_key_scale = 2^24
--Take in the x and Y coord of a chunk, and output a key for tables
chunk_checker.chunk_position_to_key = function(x, y) return x * chunk_key_scale + y end
--[[
--chunk_checker.chunk_position_to_key = function(x, y) return x * chunk_key_scale + y end
--Invert the keying function to et from chunk key to x,y in chunk space
chunk_checker.chunk_key_to_position = function(key) return {x = math.floor(key/chunk_key_scale),
    y=math.fmod(key, chunk_key_scale)} end
--Invert keying function to get full chunk data with pos and area
chunk_checker.chunk_key_to_chunk = function(key) 
    local result =  chunk_checker.chunk_key_to_position(key)
    result.area = {left_top = {x=result.x * 32, y = result.y * 32}, 
                right_bottom = {x=result.x * 32 + 32, y = result.y * 32 + 32}}
    return result
end]]
--Chunk x/y in chunk space goes in. out comes the bounding box for the chunk
chunk_checker.chunk_pos_to_area = function(x,y)
    return {left_top = {x=x * 32, y = y * 32}, right_bottom = {x=x * 32 + 32, y = y * 32 + 32}} end
--Real position to chunk position
chunk_checker.map_pos_to_chunk_pos = function(x,y) return {x = math.floor(x/32), y = math.floor(y/32)} end


--Number of chunks around an entity position to consider developed.
local develop_range = 1

--Chunk development data: {entities = number of entities "developed" affecting the chunk, 
--  players[] = hashset of player indices viewing the chunk, chunk = chunk pos and area}
chunk_checker.init = function()
    --Dictionary of (chunk key) => number of relevant entities that are activating this chunk for doing our scripts
    storage.developed_chunks = storage.developed_chunks or {}
    --Hashset of all entities which are currently included. This hashset is a safeguard against multiple register calls.
    storage.developed_chunk_entities = storage.developed_chunk_entities or {}
    --Dictionary to connect on_object_destroyed unique registration ID back to a specific entity.
    storage.developed_chunk_entity_id = storage.developed_chunk_entity_id or {}
    --Dictionary of player_index to player's last chunk position ON this surface as {key,position={x,y}}
    --dic[player_index] = nil if no player, or player not looking here.
    storage.last_player_chunk = storage.last_player_chunk or {}
end

--#region Tracking Development by buildable entities

--First make a pre-blacklist of untrackable entities. Mostly from entities that move after being placed.
--The blacklist will be made of prototype types that move
local prototype_type_preblacklist = {"artillery-projectile", "artillery-wagon", "car",
    "cargo-wagon", "locomotive", "fluid-wagon", "capture-robot", "combat-robot", "character-corpse",
    "cliff","construction-robot", "corpse", "unit-spawner", "entity-ghost", "explosion", "fire",
    "fish", "infinity-cargo-wagon", "logistic-robot", "smoke-with-trigger", "spider-leg", "spider-unit",
    "spider-vehicle", "unit", 
    --"capsule", "spidertron-remote", "tile","surface",
    "curved-rail-a", "curved-rail-b", "elevated-curved-rail-a", "elevated-curved-rail-b",
    "elevated-half-diagonal-rail","elevated-straight-rail","rail-ramp","rail-support", "rail-remnants",
    "straight-rail", --"train-stop"
}

--Make a real blacklist as a hashset of all prototypes of those types
local prototype_blacklist = {}
for _, type in pairs(prototype_type_preblacklist) do
    local type_check = false --Make sure all data was entered properly
    for _, prototype in pairs(prototypes.get_entity_filtered({{filter="type",type=type}})) do
        prototype_blacklist[tostring(prototype.name)] = 1
        type_check = true
    end
    if not type_check then error("Type had no prototypes when constructing chunk blacklist: " .. type) end
end
--log(serpent.block(prototype_blacklist))


--When a new entity is added at the given map position, register it to the developed chunk dic.
chunk_checker.register_new_entity = function(entity)
    if not entity or not entity.valid then return end
    chunk_checker.init()

    if (storage.developed_chunk_entities[entity]) then return end --Entity is already registered
    if not entity.is_entity_with_health then return end --Entity can't even be damaged by trashsteroids!
    if (prototype_blacklist[entity.prototype.name]) then return end --Entity is blacklisted!
    if trashsteroid_lib.entity_is_immune_to_impact(entity) then return end --Don't need to spawn around immune entities.

    storage.developed_chunk_entities[entity] = 1
     --Register so we can do the delisting later.
    storage.developed_chunk_entity_id[script.register_on_object_destroyed(entity)] =
     {entity = entity, position = entity.position}

    local key
    local entity_position = {x=math.floor(entity.position.x/32), y =math.floor(entity.position.y/32)}
    --game.print("registering " .. entity.name .. " at " .. serpent.block(entity.position) .. ", to chunk position: " .. serpent.block(entity_position))
    for x = (entity_position.x - develop_range), (entity_position.x + develop_range), 1 do
        for y = (entity_position.y - develop_range), (entity_position.y + develop_range), 1 do
            key = chunk_checker.chunk_position_to_key(x,y)
            --storage.developed_chunks[key] = (storage.developed_chunks[key] or 0) + 1

            if (storage.developed_chunks[key]) then 
                storage.developed_chunks[key].entities = storage.developed_chunks[key].entities + 1
            else storage.developed_chunks[key] = {chunk={x=x, y=y, area=chunk_checker.chunk_pos_to_area(x,y)}, 
                players={}, entities = 1} --whole new chunk
            end
            --game.print("x.y = " .. tostring(x) .. "," .. tostring(y) .. ". Key = " .. tostring(key)
        --.. ". Key back to x,y = " .. tostring(chunk_checker.chunk_key_to_position(key).x) .. "," .. tostring(chunk_checker.chunk_key_to_position(key).y))
        end
    end
end

--When an entity is removed from the game, delist it from the developed chunk dic.
chunk_checker.delist_entity = function(entity_reg_ID)
    if (not storage.developed_chunk_entity_id[entity_reg_ID]) then return end --Entity is already unregistered
    local entity = storage.developed_chunk_entity_id[entity_reg_ID].entity
    local entity_position = storage.developed_chunk_entity_id[entity_reg_ID].position
    entity_position = {x=math.floor(entity_position.x/32), y =math.floor(entity_position.y/32)}
    --if (not storage.developed_chunk_entities[entity]) then return end --Entity is already unregistered
    storage.developed_chunk_entities[entity] = nil
    storage.developed_chunk_entity_id[entity_reg_ID] = nil

    local key
    for x = (entity_position.x - develop_range), (entity_position.x + develop_range), 1 do
        for y = (entity_position.y - develop_range), (entity_position.y + develop_range), 1 do
            key = chunk_checker.chunk_position_to_key(x,y)

            storage.developed_chunks[key].entities = storage.developed_chunks[key].entities - 1
            --check for chunk became blank
            --if (storage.developed_chunks[key] == 0) then storage.developed_chunks[key] = nil end
            if (storage.developed_chunks[key].entities==0 and _ENV.table_size(storage.developed_chunks[key].players)==0) then 
                storage.developed_chunks[key] = nil
            end

        end
    end
end

--Manually iterate over a whole surface to generate a completely freshly updated chunk listing.
--This is a last resort or reserved for single migrations...
chunk_checker.hard_refresh_developed_chunks = function(surface, entity_filter)
    storage.developed_chunks = {} -- blank it
    local entity_array = surface.find_entities_filtered(entity_filter)
    for _, entity in entity_array do
        if (entity.valid) then chunk_checker.register_new_entity(entity.position) end
    end
end

--Do the actual quick check: chunk position in chunk space goes in. Out goes a bool that is TRUE
--if the chunk should count as developped
chunk_checker.is_chunk_developed = function(chunk)
    return (storage.developed_chunks) and (storage.developed_chunks[
        chunk_checker.chunk_position_to_key(chunk.x,chunk.y)])
end
--Do the actual quick check: chunk position in chunk space goes in. Out goes a bool that is TRUE
--if the chunk should count as developped. Input the key
chunk_checker.is_chunk_developed_by_key = function(key)
    return (storage.developed_chunks) and (storage.developed_chunks[key])
end

--------

--#endregion

--Print developed chunks to log for debug purposes
chunk_checker.print_developed_chunks = function(full_mode)
    local string = "Total developed  = " .. tostring(_ENV.table_size(storage.developed_chunks) .. ". ")
    for key, data in pairs(storage.developed_chunks) do
        if full_mode then
            string = string .. ". key = " .. tostring(key) .. ": (" .. tostring(data.chunk.x) .. "," .. tostring(data.chunk.y)
            .. ") players = " .. tostring(_ENV.table_size(data.players)) .. ", entities = " .. tostring(data.entities) ..".  "
        else string = string .. "(" .. tostring(data.chunk.x) .. "," .. tostring(data.chunk.y) .. ") "
        end
    end
    game.print(string)
end

---------
---
--#region Checking chunks by player current visibility

-- How many chunks around the current viewing spot to count as "viewed"
--Empirically, when fully zoomed out, the range seems to be a 7 wide, 5 tall chunk region.
local viewing_range = {x = 4, y = 3} 

--Return an iterator to iterate through all chunk keys viewable from the given position.
--Return arguments 2/3 are the x/y in chunk space of the chunk. Input position in chunk space
local function iterate_visible_chunk_keys_from(centered_chunk_pos)
    local x,ymin = centered_chunk_pos.x - viewing_range.x, centered_chunk_pos.y - viewing_range.y
    local xmax,ymax = centered_chunk_pos.x + viewing_range.x, centered_chunk_pos.y + viewing_range.y
    local y = ymin
    --game.print("xmin=" .. xmin .. ", xmax = " .. xmax .. ", ymin = " .. ymin .. ", ymax = " .. ymax)
    return function()
        --game.print("x= " .. x .. ", y = " .. y .. ", xmax = " .. xmax .. ", ymin = " .. ymin .. ", ymax = " .. ymax)
        if (y > ymax) then y = ymin; x = x + 1 
            if (x > xmax) then return nil end
        end
        y = y + 1
        return chunk_checker.chunk_position_to_key(x,y-1), x, y-1
    end
end

--[[Output the bounds of iteration for chunk coordinates in the viewable range around a given map position.
--Return in order xmin, ymin, xmax, ymax
local function visible_chunk_range(position)
    local centered_chunk_pos = {x = math.floor(position.x/32), y = math.floor(position.y/32)}
    return centered_chunk_pos.x - viewing_range.x, centered_chunk_pos.y - viewing_range.y,
        centered_chunk_pos.x + viewing_range.x, centered_chunk_pos.y + viewing_range.y
end]]

--Return a hashset of all chunk position keys that are currently visible for that specific surface.
---@param surface LuaSurface
chunk_checker.currently_viewed_chunks = function(surface)
    if not surface then return {} end

    viewed_chunks = {}
    for _, player in pairs(game.players) do
        if player.surface.name == surface.name then 
            for key in iterate_visible_chunk_keys_from(chunk_checker.map_pos_to_chunk_pos(player.position.x,player.position.y)) do
                viewed_chunks[key]=1
            end

            --[[Chunk coordinate for the center of the viewing window for that player
            local centered_chunk_pos = {x = math.floor(player.position.x/32),
                y = math.floor(player.position.y/32)}
            for x = centered_chunk_pos.x - viewing_range.x, centered_chunk_pos.x + viewing_range.x, 1 do
                for y = centered_chunk_pos.y - viewing_range.y, centered_chunk_pos.y + viewing_range.y, 1 do
                    viewed_chunks[chunk_checker.chunk_position_to_key(x,y)]=1
                end
            end]]
        end
    end
    return viewed_chunks
end

---Try to update our tracking of the current player's position, and update tables if needed.
---@param player LuaPlayer
---@param surface LuaSurface surface that we are tracking
chunk_checker.try_update_player_pos = function(player, surface)
    if not surface then return end --No surface (yet?)
    chunk_checker.init()
    local track_needed, delist_needed = false, false --Check if we need to (un)register
    --Player's current chunk coordinate
    local new_chunk_pos = chunk_checker.map_pos_to_chunk_pos(player.position.x, player.position.y)
    local new_key = chunk_checker.chunk_position_to_key(new_chunk_pos.x, new_chunk_pos.y)

    --Player is NOT on the surface now
    if (player.surface.name ~= surface.name) then
        --But they were also not on the surface before = no update
        if (not storage.last_player_chunk[player.index]) then return end
        --And trhey WERE on the surface before => delist, but no track
        delist_needed = true
    else --Player is on the surface now
        --They were also not on the surface before = list, but no delist
        if (not storage.last_player_chunk[player.index]) then 
            track_needed = true
        --They were on the surface before, but the chunk didn't change => no update
        elseif new_key == storage.last_player_chunk[player.index].key then return
        --They were on the surface AND the chunk changed! We need to both track and delist
        else track_needed, delist_needed = true, true
        end
    end

    --Delist
    if delist_needed then
        for key in iterate_visible_chunk_keys_from(storage.last_player_chunk[player.index].position) do
            storage.developed_chunks[key].players[player.index] = nil
            --There is neither vision nor development on that chunk
            if (_ENV.table_size(storage.developed_chunks[key].players) == 0
                and storage.developed_chunks[key].entities == 0) then
                storage.developed_chunks[key] = nil
            end
        end
        storage.last_player_chunk[player.index] = nil
    end

    --Tracking to add vision
    if track_needed then
        --visible_chunk_range(new_chunk_pos)
        for key, x, y in iterate_visible_chunk_keys_from(new_chunk_pos) do
            --Chunk is already developed
            if storage.developed_chunks[key] then 
                storage.developed_chunks[key].players[player.index] = 1
            else --Chunk is currently only developped by vision
                storage.developed_chunks[key] = {
                    chunk={x=x, y=y, area=chunk_checker.chunk_pos_to_area(x,y)}, 
                    players={[player.index]=1}, entities = 0}
            end
        end
        
        --game.print("new pos = " .. new_chunk_pos.x .. "," .. new_chunk_pos.y .. "")
        storage.last_player_chunk[player.index] = {key=new_key, position=new_chunk_pos}
    end
end




--#endregion
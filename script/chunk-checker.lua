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
    


--Number of chunks around an entity position to consider developed.
local develop_range = 1

chunk_checker.init = function()
    --Dictionary of (chunk key) => number of relevant entities that are activating this chunk for doing our scripts
    storage.developed_chunks = storage.developed_chunks or {}
    --Hashset of all entities which are currently included. This hashset is a safeguard against multiple register calls.
    storage.developed_chunk_entities = storage.developed_chunk_entities or {}
    --Dictionary to connect on_object_destroyed unique registration ID back to a specific entity.
    storage.developed_chunk_entity_id = storage.developed_chunk_entity_id or {}
end

--Chunk development data: {entities = number of entities "developed" affecting the chunk, 
--  players[] = player indices viewing the chunk, chunk = chunk pos and area}

--When a new entity is added at the given map position, register it to the developed chunk dic.
--Do not check validity
chunk_checker.register_new_entity = function(entity)
    chunk_checker.init()

    if (storage.developed_chunk_entities[entity]) then return end --Entity is already registered
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

            storage.developed_chunks[key] = storage.developed_chunks[key] - 1
            --check for chunk became blank
            --if (storage.developed_chunks[key] == 0) then storage.developed_chunks[key] = nil end
            if (storage.developed_chunks[key].entities==0 and #storage.developed_chunks[key].players==0) then 
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


--Return an iterator that partially iterates over the array of developed chunks.
--chunk_checker.iterate_dev_chunks = function(start_index, total_to_iterate)
---------TODO

--end

--Print developed chunks to log for debug purposes
chunk_checker.print_developed_chunks = function()
    local string = ""
    for key, _ in pairs(storage.developed_chunks) do
        string = string .. ", (" .. tostring(chunk_checker.chunk_key_to_position(key).x) .. ","
        .. tostring(chunk_checker.chunk_key_to_position(key).y) .. ")"
    end
    game.print(string)
end

---------
---
--#region Checking chunks by player current visibility
-- How many chunks around the current viewing spot to count as "viewed"
--Empirically, when fully zoomed out, the range seems to be a 7 wide, 5 tall chunk region.
local viewing_range = {x = 4, y = 3} 
--Return a hashset of all chunk position keys that are currently visible for that specific surface.
---@param surface LuaSurface
chunk_checker.currently_viewed_chunks = function(surface)
    if not surface then return {} end

    viewed_chunks = {}
    for _, player in pairs(game.players) do
        if player.surface.name ~= surface.name then goto continue end

        --Chunk coordinate for the center of the viewing window for that player
        local centered_chunk_pos = {x = math.floor(player.position.x/32),
            y = math.floor(player.position.y/32)}
        for x = centered_chunk_pos.x - viewing_range.x, centered_chunk_pos.x + viewing_range.x, 1 do
            for y = centered_chunk_pos.y - viewing_range.y, centered_chunk_pos.y + viewing_range.y, 1 do
                viewed_chunks[chunk_checker.chunk_position_to_key(x,y)]=1
            end
        end

        ::continue::
    end
    return viewed_chunks
end

--#endregion
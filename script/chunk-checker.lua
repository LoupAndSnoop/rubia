--The scripts on this file exist to monitor which chunks have player activity on them.
--This file assume the surface is locked to rubia, and will not ask 
--questions about whether or not the surface is relevant.

_G.chunk_checker = {}

local chunk_key_scale = 2^24
--Take in the x and Y coord of a chunk, and output a key for tables
chunk_checker.chunk_position_to_key = function(x, y) return x * chunk_key_scale + y end

--Number of chunks around an entity position to consider developed.
local develop_range = 1

--Dictionary of (chunk key) => number of relevant entities that are activating this chunk
--for doing our scripts
storage.developed_chunks = storage.developed_chunks or {}

--When a new entity is added at the given map position, register it to the developed chunk dic.
chunk_checker.register_new_entity = function(entity_position)
    local key
    for x = (entity_position.x/32 - develop_range), (entity_position.x/32 + develop_range), 1 do
        for y = (entity_position.y/32 - develop_range), (entity_position.y/32 + develop_range), 1 do
            key = chunk_checker.chunk_position_to_key(x,y)
            storage.developed_chunks[key] = (storage.developed_chunks[key] or 0) + 1
        end
    end
end

--When an entity is removed from the game, delist it from the developed chunk dic.
chunk_checker.delist_entity = function(entity_position)
    local key
    for x = (entity_position.x/32 - develop_range), (entity_position.x/32 + develop_range), 1 do
        for y = (entity_position.y/32 - develop_range), (entity_position.y/32 + develop_range), 1 do
            key = chunk_checker.chunk_position_to_key(x,y)
            storage.developed_chunks[key] = storage.developed_chunks[key] - 1
            --check for chunk blank
            if (storage.developed_chunks[key] == 0) then storage.developed_chunks[key] = nil end
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

    local viewed_chunks = {}
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
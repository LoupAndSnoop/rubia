--This file has the base functions and parameters for spawning and maintaining trashsteroids.

--Functions will be stored onto this global variable:
_G.trashsteroid_lib = _G.trashsteroid_lib or {}

--- Asteroid Management
local max_trashsteroids = 200 --Max # of managed trashsteroids active at once
local trashsteroid_cooldown_min = 60 --Min cooldown time between trashsteroids in one chunk
local trashsteroid_cooldown_max = 300 --Max cooldown time between trashsteroids in one chunk
local trashsteroid_lifetime = 300 --Number of ticks that a trashsteroid can live
local trashsteroid_AOE_radius = 10 -- damage radius for a trashsteroid impact
local trashsteroid_impact_damage = 200 --Damage done by a trashsteroid.

local trashsteroid_names = {"medium-trashsteroid"}

--Trashsteroid movement data
local trashsteroid_speed = 0.01 --Speed given to trashsteroids upon spawning. 1 is too fast
local trashsteroid_speed_var = 40 --Speed is randomly up to this % faster
local trashsteroid_color = {r = 1, g = 1, b = 1, a = 0.2}

local trashsteroid_impact_damage = 200 --Raw damage done
local trashsteroid_impact_radius = 3

--Trashteroid data
--storage.active_trashsteroids = {} --active_trashsteroids[tostring(unit_number)] = {unit_number=resulting_entity.unit_number, death_tick=tick, name=trashsteroid_name, chunk_data=chunk}
storage.active_trashsteroids = storage.active_trashsteroids or {}
storage.active_trashsteroid_count = storage.active_trashsteroid_count or 0
--Trashsteroid queue for chunks that currently don't have an active trashsteroid
--storage.pending_trashsteroid_data = {}--[chunk_data=chunk] = (next_spawn_tick=tick) --has the next tick where we expect a trashsteroid spawn
storage.pending_trashsteroid_data = storage.pending_trashsteroid_data or {}

--Try to initialize RNG if it isn't already. Very important random seed. Do NOT change!
local function try_initialize_RNG() if not storage.rubia_asteroid_rng then storage.rubia_asteroid_rng = game.create_random_generator(42069) end end
local chunk_key_scale = 2^24
--Take in the x and Y coord of a chunk, and output a key for tables
local function chunk_position_to_key(x, y) return x * chunk_key_scale + y end

------ Impact Logic

--Return true if the given entity is immune to impacts
local function entity_is_immune_to_impact(entity)
  --First, blacklist anything with either immunity to damage or impact damage
  if (not entity.is_entity_with_health) then return true end 
  if (entity.prototype.resistances and entity.prototype.resistances.impact and entity.prototype.resistances.impact.percent and entity.prototype.resistances.impact.percent >= 99) then return true end

  --TODO Blacklist

  --Passed all checks
  return false
end

--Return an array of all entities that are in the impact range, which are relevant to impact.
local function find_impact_targets(position, radius)
  local impacted_raw = storage.rubia_surface.find_entities_filtered({
    position = position,
    radius = radius,
    force = game.forces["player"]
  })
  local impacted = {} --Actual list of entities that should be impacted
  for i,entity in pairs(impacted_raw) do
    if not entity_is_immune_to_impact(entity) then table.insert(impacted, entity) end
  end

  return impacted
end


------------

-- Add entity to the working cache of that item to manage.
---@param entity LuaEntity
local function add_to_cache(entity,cache)--,current_tick)
  --log(serpent.block(entity.name))
  if(entity.valid == true) then
    cache[entity["unit_number"]] = {entity = entity, timestamp = game.tick}--current_tick}
  end
end
local function remove_from_cache(unit_number,cache)
  cache[unit_number] = nil
end

--Output a map of "surface-name" = {array of entities with that name on that surface}
local function find_all_entity_of_name(input_name)
  local out_entity_table = {}
  local surface_array = game.surfaces
  for k,q in pairs(surface_array) do --names of surfaces are in keys
      local current_surface = game.get_surface(k)
      local entity_array = current_surface.find_entities_filtered{name = input_name} --input_name

      if(table_size(entity_array) == 0) then -- That entity is not on this surface
        out_entity_table[current_surface.name] = {}
      else  out_entity_table[current_surface.name] = entity_array
      end
  end
  return out_entity_table
end


--On game startup, clear anything already existing.
local function clear_all_trashsteroids()
  -- Clear all existing trashsteroids
  for index, tname in pairs(trashsteroid_names) do
    local trashsteroids = find_all_entity_of_name(tname)
    for surface, entity in pairs(trashsteroids) do
      entity.destroy()
    end
  end
end

--Log and update chunk data
storage.rubia_chunks = storage.rubia_chunks or {}
--When a new chunk has to be added, log everything we need to start spawning entities there.
trashsteroid_lib.log_chunk_for_trashsteroids = function(surface, position, area)
  if surface and (surface.name == "rubia") then 
    storage.rubia_surface = surface
    table.insert(storage.rubia_chunks,{x = position.x, y = position.y, area = area})

    --Queue up this chunk's next trashsteroid.
    try_initialize_RNG()
    storage.pending_trashsteroid_data[chunk_position_to_key(position.x,position.y)] = game.tick + 1 + storage.rubia_asteroid_rng(trashsteroid_cooldown_min, trashsteroid_cooldown_max)
  end
end

--Make trashsteroid in that chunk. Assume everything is initialized.
local function generate_trashsteroid(trashsteroid_name, chunk)
  if storage.active_trashsteroid_count > max_trashsteroids then return end --We are above the limit of trashsteroids

  --First get a random coord in the chunk
  local x = storage.rubia_asteroid_rng(chunk.area.left_top.x, chunk.area.right_bottom.x)
  local y = storage.rubia_asteroid_rng(chunk.area.left_top.y, chunk.area.right_bottom.y)

  --Make it
  local resulting_entity = storage.rubia_surface.create_entity({
    name = trashsteroid_name,
    position = {x = x, y = y},
    direction = defines.direction.east,
    snap_to_grid = false
  })

  --Set it up
  resulting_entity.force = game.forces["enemy"]
  resulting_entity.color = trashsteroid_color
  resulting_entity.speed = trashsteroid_speed * (1 + storage.rubia_asteroid_rng(0,trashsteroid_speed_var)/100)
  resulting_entity.orientation = storage.rubia_asteroid_rng(15,35) / 100
  --resulting_entity.variation = storage.rubia_asteroid_rng(1,6)


  --Log its status
  --Next tick where this chunk is going to expect a trashsteroid.
  local next_trashsteroid_tick = game.tick + 1 + storage.rubia_asteroid_rng(trashsteroid_cooldown_min, trashsteroid_cooldown_max)--+ trashsteroid_lifetime?
  storage.pending_trashsteroid_data[chunk_position_to_key(chunk.x,chunk.y)] = next_trashsteroid_tick -- queue up next trashsteroid
  storage.active_trashsteroids[tostring(resulting_entity.unit_number)] = {unit_number=resulting_entity.unit_number, death_tick=game.tick + trashsteroid_lifetime, name=trashsteroid_name, chunk_data=chunk}
  storage.active_trashsteroid_count = storage.active_trashsteroid_count + 1
  --table.insert(storage.active_trashsteroids,{unit_number=resulting_entity.unit_number, death_tick=game.tick + trashsteroid_lifetime, name=trashsteroid_name, chunk_data=chunk})
  return resulting_entity
end

--Go through one round of going through all chunks and trying to spawn trashsteroids
trashsteroid_lib.try_spawn_trashsteroids = function()
    --game.print("Chunk iterator: " + serpent.block(storage.rubia_chunk_iterator))
    try_initialize_RNG()
    if not storage.rubia_chunks then return end --No chunks to worry about
    for i,chunk in pairs(storage.rubia_chunks) do --_iterator do
      --Check chunk exists and its cooldown time is done.
      if (storage.rubia_surface.is_chunk_generated(chunk) --game.player and game.player.force.is_chunk_charted(storage.rubia_surface, chunk)
        and (storage.pending_trashsteroid_data[chunk_position_to_key(chunk.x,chunk.y)] < game.tick)) then
        generate_trashsteroid("medium-trashsteroid", chunk)
      end
    end
end

--Spawn trashsteroids
--script.on_nth_tick(45, try_spawn_trashsteroids)

--Trashsteroid Impact checks
--{unit_number=resulting_entity.unit_number, death_tick=game.tick, name=trashsteroid_name, chunk_data=chunk}
--Go check all trashsteroids to see if any of them are so old that they need to do an impact check, and go do so for trashsteroids at the end of their life cycle.
trashsteroid_lib.trashsteroid_impact_update = function()
  if not storage.active_trashsteroids then return end
  --game.print(serpent.block(storage.active_trashsteroids))

  --Make a temporary array of all trashsteroid entities that need to go through their impact, so we can delete them without changing our iteration.
  local trashsteroids_impacting = {}
  for i, trashsteroid in pairs(storage.active_trashsteroids) do
    if (trashsteroid.death_tick < game.tick) then
      local entity = game.get_entity_by_unit_number(trashsteroid.unit_number)
      --If valid, log it to delete
      if entity and entity.valid then table.insert(trashsteroids_impacting, entity) end
    end
  end

  --Now we go through and actually DO the impacts
    for i,entity in pairs(trashsteroids_impacting) do
        --Deal damage
        local impacted_entities = find_impact_targets(entity.position, trashsteroid_impact_radius)
        for i,hit_entity in pairs(impacted_entities) do
          hit_entity.damage(trashsteroid_impact_damage, game.forces["enemy"])
        end

        local explosion_name = "medium-trashsteroid-explosion" .. tostring(storage.rubia_asteroid_rng(1,2))
        --trashsteroid_lib.trashsteroid_explosions[storage.rubia_asteroid_rng(1,#trashsteroid_lib.trashsteroid_explosions)]
        storage.rubia_surface.create_entity({
          name = explosion_name,
          position = entity.position
        })

        --[[storage.rubia_surface.create_entity({
          name = trashsteroid_name,
          position = {x = x, y = y},
          direction = defines.direction.east,
          snap_to_grid = false
        })]]

        --Delist before destruction.
        table.remove(storage.active_trashsteroids, tostring(entity.unit_number))
        storage.active_trashsteroid_count = storage.active_trashsteroid_count - 1
        entity.destroy()
    end  
end





--[[find_entities_filtered(filter)

area 	:: BoundingBox?	
position 	:: MapPosition?	

Has precedence over area field.
radius 	:: double?	

If given with position, will return all entities within the radius of the position.
name 	:: EntityID or array[EntityID]?	

An empty array means nothing matches the name filter.
type 	:: string or array[string]?	

An empty array means nothing matches the type filter.
ghost_name 	:: EntityID or array[EntityID]?	

An empty array means nothing matches the ghost_name filter.
ghost_type 	:: string or array[string]?	

An empty array means nothing matches the ghost_type filter.
direction 	:: defines.direction or array[defines.direction]?	
collision_mask 	:: CollisionLayerID or array[CollisionLayerID] or dictionary[CollisionLayerID → true]?	
force 	:: ForceSet?	
to_be_deconstructed 	:: boolean?	
to_be_upgraded 	:: boolean?	
limit 	:: uint?	
is_military_target 	:: boolean?	
has_item_inside 

]]
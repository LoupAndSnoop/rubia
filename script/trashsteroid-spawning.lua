--This file has the base functions and parameters for spawning and maintaining trashsteroids.

--Functions will be stored onto this global variable:
_G.trashsteroid_lib = _G.trashsteroid_lib or {}

--- Asteroid Management
local max_trashsteroids = 500 --Max # of managed trashsteroids active at once
local max_trashsteroids_per_update = 20 --Max # of trashsteroids to attempt to spawn in one tick.
local trashsteroid_cooldown_min = 60 --Min cooldown time between trashsteroids in one chunk
local trashsteroid_cooldown_max = 300 --Max cooldown time between trashsteroids in one chunk
local trashsteroid_lifetime = 200 --Number of ticks that a trashsteroid can live
local trashsteroid_AOE_radius = 10 -- damage radius for a trashsteroid impact
local trashsteroid_impact_damage = 200 --Damage done by a trashsteroid.

local trashsteroid_names = {"medium-trashsteroid"}

--Medium Trashsteroid movement and rendering data
local trashsteroid_speed = 0.04 --Speed given to trashsteroids upon spawning. 1 is too fast
local trashsteroid_speed_var = 40 --Speed is randomly up/down to this % faster
--local trashsteroid_color = {r = 1, g = 1, b = 1, a = 0.2}
local trashsteroid_rotation_max = 2 -- How much a trashsteroid can rotate (max) over its lifetime.
local trashsteroid_min_size = 0.3 -- Initial scale of trashsteroid render, which grows linearly until it makes impact.
local temp_shadow_dist_min = 0.5 --Shift in map space, min
local temp_shadow_dist_max = 6 --Shift in map space, max
local temp_shadow_unit_vec = {x=0.707, y=0.707} --unit vector for the direction the shadow should go, relative to the object
--Premultiply min and max offset of the shadows
local trashsteroid_shadow_min_vec = {x=temp_shadow_unit_vec.x * temp_shadow_dist_min, y = temp_shadow_unit_vec.y * temp_shadow_dist_min}
local trashsteroid_shadow_max_vec = {x=temp_shadow_unit_vec.x * temp_shadow_dist_max, y = temp_shadow_unit_vec.y * temp_shadow_dist_max}
--Give a color that tints something just to transparency.
local function transparency(value) return {r = value, g = value, b = value, a = value} end
local trashsteroid_max_opacity = 0.8 --As opaque as it will get.
local trashsteroid_shadow_max_opacity = 0.9 --As opaque as it will get.

--Trashsteroid ranges, damages, etc
local trashsteroid_impact_damage = 200 --Raw damage done
local trashsteroid_impact_radius = 3
local trashsteroid_chunk_reach = prototypes.entity["garbo-gatherer"].radius_visualisation_specification.distance --Max collector-chunk distance to allow starting collection
local trashsteroid_chunk_reach_quit = 100 -- Max range chunk projectile will go before giving up
local trashsteroid_chunk_speed = 0.01 -- Initial speed of the trash chunk (avg)

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
---
--Return true if the given entity is immune to impacts
local function entity_is_immune_to_impact(entity)
  --First, blacklist anything with either immunity to damage or impact damage
  if (not entity.is_entity_with_health) then return true end 
  if (entity.prototype.resistances and entity.prototype.resistances.impact and entity.prototype.resistances.impact.percent and entity.prototype.resistances.impact.percent >= 99) then return true end
  
  --Check manual blacklist.
  if (rubia.trashsteroid_blacklist.entity[entity.name]) then return true end

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

--Return the closerst garbo collector in range (LuaEntity) that is in range of an impact to make a chunk projectiles, and is valid to collect.
--If no valid collector found, return nil.
local function find_closest_collector(trashsteroid)
  local start = trashsteroid.entity.position
  local collectors = storage.rubia_surface.find_entities_filtered({
    position = start,
    radius = trashsteroid_chunk_reach,
    name = "garbo-gatherer"
  })
  if not collectors then return nil end --Nothing found. Most common case.

  local best_collector = nil--Closest one that is valid
  --Compare closest square range to avoid unnecessary sqrt
  local closest_range = (trashsteroid_chunk_reach + 1)^2
  for i,entity in pairs(collectors) do
    if (not entity or not entity.valid) then goto continue end --It just isn't valid
    --Check that there is enough space for at least one item.
    if (entity.get_inventory(defines.inventory.chest).can_insert({name="craptonite-chunk",count=1})) then
      local current_range = (entity.position.x - start.x)^2 + (entity.position.y - start.y)^2
      if (current_range < closest_range) then --TODO: Electricity check?
        best_collector = entity
        closest_range = current_range
      end
    end
    ::continue::
  end

  return best_collector
end


-----------------
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
  if storage.active_trashsteroid_count > max_trashsteroids then return end --We are above the limit of trashsteroid

  --First get a random coord in the chunk
  local x = storage.rubia_asteroid_rng(chunk.area.left_top.x, chunk.area.right_bottom.x)
  local y = storage.rubia_asteroid_rng(chunk.area.left_top.y, chunk.area.right_bottom.y)

  --Make it
  local resulting_entity = storage.rubia_surface.create_entity({
    name = trashsteroid_name,
    position = {x = x, y = y},
    direction = defines.direction.east,
    snap_to_grid = false,
    create_build_effect_smoke = false
  })

  --Add a rendering to be able to see it, as it moves somewhat independently
  local render = rendering.draw_animation({
    animation = "medium-trashsteroid-animation" .. tostring(storage.rubia_asteroid_rng(1,6)),
    orientation=storage.rubia_asteroid_rng(1,100) / 100,
    render_layer="air-object",
    xscale = trashsteroid_min_size, yscale = trashsteroid_min_size,
    target=resulting_entity, surface=storage.rubia_surface,
    tint = transparency(0)
  })
  --Draw shadow, matching orientation, but it needs a custom offset
  local render_shadow = rendering.draw_animation({
    animation = "medium-trashsteroid-shadow" .. tostring(storage.rubia_asteroid_rng(1,6)),
    oriention= render.orientation,
    render_layer="object",
    xscale = trashsteroid_min_size, yscale = trashsteroid_min_size,
    target={
      x = resulting_entity.position.x + trashsteroid_shadow_max_vec.x,
      y = resulting_entity.position.y + trashsteroid_shadow_max_vec.y},
    surface=storage.rubia_surface,
    tint = transparency(0)
  })
  
  --Set it up
  resulting_entity.force = game.forces["enemy"]
  resulting_entity.speed = trashsteroid_speed * (1 + storage.rubia_asteroid_rng(trashsteroid_speed_var,trashsteroid_speed_var)/100)
  resulting_entity.orientation = storage.rubia_asteroid_rng(20,30) / 100

  --Log its status
  --Next tick where this chunk is going to expect a trashsteroid.
  local next_trashsteroid_tick = game.tick + 1 + storage.rubia_asteroid_rng(trashsteroid_cooldown_min, trashsteroid_cooldown_max)--+ trashsteroid_lifetime?
  storage.pending_trashsteroid_data[chunk_position_to_key(chunk.x,chunk.y)] = next_trashsteroid_tick -- queue up next trashsteroid

  storage.active_trashsteroids[tostring(resulting_entity.unit_number)] = {
    unit_number = resulting_entity.unit_number,
    entity = resulting_entity,
    death_tick = game.tick + trashsteroid_lifetime,
    name = trashsteroid_name,
    chunk_data = chunk,
    --chunk_position = {x=chunk.x, y = chunk.y}, --Do we need both?
    render_solid = render,
    render_shadow = render_shadow,
    orient_initial = render.orientation, --Starting orientation for render
    orient_final = render.orientation * trashsteroid_rotation_max * storage.rubia_asteroid_rng(-20,20)/20 -- ending orientation, not locked to 0-1
  }
  storage.active_trashsteroid_count = storage.active_trashsteroid_count + 1
  return resulting_entity
end

--[[Take 2 chunk data, and see which one should come first in the list.
local function chunk_spawn_order(chunk1, chunk2)
  return storage.pending_trashsteroid_data[chunk_position_to_key(chunk1.x,chunk1.y)]
   <  storage.pending_trashsteroid_data[chunk_position_to_key(chunk2.x,chunk2.y)]
end]]


--Go through one round of going through all chunks and trying to spawn trashsteroids
trashsteroid_lib.try_spawn_trashsteroids = function()
    --game.print("Chunk iterator: " + serpent.block(stage.rubia_chunk_iterator))
    try_initialize_RNG()
    if not storage.rubia_chunks then return end --No chunks to worry about

    --Index of the last chunk where we ended iteration
    storage.trash_gen_index = (storage.trash_gen_index) or 1

    local visible_chunks = chunk_checker.currently_viewed_chunks(storage.rubia_surface)
    local spawned_trashsteroids = 0 --Total spawned this cycle
    local key = 0
    for i = storage.trash_gen_index, #storage.rubia_chunks, 1 do
      local chunk = storage.rubia_chunks[i]
      storage.trash_gen_index = i

    --for i,chunk in pairs(storage.rubia_chunks) do --_iterator do
      --Check chunk exists and its cooldown time is done.
      key = chunk_position_to_key(chunk.x,chunk.y)
      if (storage.pending_trashsteroid_data[key] < game.tick)
        and (chunk_checker.is_chunk_developed_by_key(key) or (visible_chunks and visible_chunks[key])) then
      --and (storage.rubia_surface.is_chunk_generated(chunk)) then --game.player and game.player.force.is_chunk_charted(storage.rubia_surface, chunk)
      --and (storage.rubia_surface.count_entities_filtered{area = chunk.area, force = "player"} > 0)  --testing: and there is player stuff there
        
        generate_trashsteroid("medium-trashsteroid", chunk)

        spawned_trashsteroids = spawned_trashsteroids + 1
        if spawned_trashsteroids >= max_trashsteroids_per_update then break end

      --Otherwise put that chunk on cooldown
      --else storage.pending_trashsteroid_data[chunk_position_to_key(chunk.x,chunk.y)] = 
      --    game.tick + trashsteroid_cooldown_max
      end
    end
    --Loop the partial iteration index if applicable
    if storage.trash_gen_index >=  #storage.rubia_chunks then storage.trash_gen_index = 1 end

    --if spawned_trashsteroids > 0 then --If we did spawn, then let's sort the list so we have the most stale chunks at the start
    --  table.sort(storage.rubia_chunks, chunk_spawn_order)
    --end
  end

--[[
--This version checks through ALL visible area
  local force = game.forces["player"]
  for _, trashsteroid in pairs(storage.active_trashsteroids) do
    if (force.is_chunk_visible(storage.rubia_surface, {x=trashsteroid.chunk_data.x, y = trashsteroid.chunk_data.y})
      

]]


--Go through all trashsteroids, and update their rendering.
trashsteroid_lib.update_trashsteroid_rendering = function()
  if not storage.active_trashsteroids then return end

  local viewed_chunks = chunk_checker.currently_viewed_chunks(storage.rubia_surface)
  if not viewed_chunks then return end

  for _, trashsteroid in pairs(storage.active_trashsteroids) do
    if (viewed_chunks[chunk_checker.chunk_position_to_key(trashsteroid.chunk_data.x,trashsteroid.chunk_data.y)]
      and trashsteroid.render_solid and trashsteroid.render_solid.valid
      and trashsteroid.render_shadow and trashsteroid.render_shadow.valid) then
      local fractional_age = 1 - (trashsteroid.death_tick - game.tick)/trashsteroid_lifetime

      local scale = 2*fractional_age + (1 - fractional_age) * trashsteroid_min_size
      trashsteroid.render_solid.x_scale = scale--fractional_age + (1 - fractional_age) * trashsteroid_min_size
      trashsteroid.render_solid.y_scale = scale--trashsteroid.render_solid.x_scale
      trashsteroid.render_shadow.x_scale = scale--trashsteroid.render_solid.x_scale
      trashsteroid.render_shadow.y_scale = scale--trashsteroid.render_solid.x_scale

      local orient = math.fmod(fractional_age * trashsteroid.orient_initial + (1 - fractional_age) * trashsteroid.orient_final,1)
      trashsteroid.render_solid.orientation = orient
      trashsteroid.render_shadow.orientation = orient
      
      --Transparency comes in quickly with fractional age.
      local transparency_scale = math.min(1, 1-(1-fractional_age)^6)--3)
      trashsteroid.render_solid.color = transparency(trashsteroid_max_opacity * transparency_scale)
      trashsteroid.render_shadow.color = transparency(trashsteroid_shadow_max_opacity * transparency_scale)
      
      --Now get shift between shadow and solid
      --game.print(serpent.block(trashsteroid.render_solid.target.entity.position))
      local pos = trashsteroid.entity.position
      trashsteroid.render_shadow.target = {
        x = fractional_age * trashsteroid_shadow_min_vec.x + (1-fractional_age) * trashsteroid_shadow_max_vec.x + pos.x,
        y = fractional_age * trashsteroid_shadow_min_vec.y + (1-fractional_age) * trashsteroid_shadow_max_vec.y + pos.y
      }
      
      --[[Make it vulnetable if it is big enough
      if (trashsteroid.entity and trashsteroid.entity.valid and fractional_age > 0.2) then
        trashsteroid.entity.is_military_target = false
      end]]
    end
  end
end


--[[function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end]]

--What to do when this trashsteroid is removed. Takes care of maintaining caches.
--Includes cleanup common to any mode of death (impact/shot/etc).
local function on_trashsteroid_removed(trashsteroid)
    --Destroy the renders
    trashsteroid.render_solid.destroy()
    trashsteroid.render_shadow.destroy()

    --Delist before destruction.
    storage.active_trashsteroids[tostring(trashsteroid.unit_number)] = nil
    storage.active_trashsteroid_count = storage.active_trashsteroid_count - 1
end

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
      if entity and entity.valid then 
        table.insert(trashsteroids_impacting, trashsteroid)

      end
    end
  end

  --Now we go through and actually DO the impacts
  for _,trashsteroid in pairs(trashsteroids_impacting) do
      local entity = trashsteroid.entity
      --Deal damage
      local impacted_entities = find_impact_targets(entity.position, trashsteroid_impact_radius)
      for _,hit_entity in pairs(impacted_entities) do
        hit_entity.damage(trashsteroid_impact_damage, game.forces["enemy"])
      end

      local explosion_name = "medium-trashsteroid-explosion" .. tostring(storage.rubia_asteroid_rng(1,9)) --Number of unique explosions go here
      --trashsteroid_lib.trashsteroid_explosions[storage.rubia_asteroid_rng(1,#trashsteroid_lib.trashsteroid_explosions)]
      storage.rubia_surface.create_entity({
        name = explosion_name,
        position = {x = entity.position.x + 0.5,y = entity.position.y} --Shift explosion a little bit to lead it.
      })

      on_trashsteroid_removed(trashsteroid) --Perform common cleanup
      --[[Destroy the renders
      trashsteroid.render_solid.destroy()
      trashsteroid.render_shadow.destroy()

      --Delist before destruction.
      storage.active_trashsteroids[tostring(trashsteroid.unit_number)] = nil
      storage.active_trashsteroid_count = storage.active_trashsteroid_count - 1]]
      entity.destroy()
  end  
end



--What to do when a medium trashsteroid is killed. Assume it is valid, and the right type.
trashsteroid_lib.on_med_trashsteroid_killed = function(entity)
  local trashsteroid = storage.active_trashsteroids[tostring(entity.unit_number)]

  --Make a smalll chunk projectile, if it makes sense. First: search for a valid collector
  local collector = find_closest_collector(trashsteroid)
  if (collector) then --We have a valid collector. Spawn a chunk.
    --local chunk_entity = 
    storage.rubia_surface.create_entity({
      name = "trashsteroid-chunk",
      position = entity.position,
      direction = entity.orientation,
      create_build_effect_smoke = false,
      speed = trashsteroid_chunk_speed * storage.rubia_asteroid_rng(50,150)/100,
      max_range = trashsteroid_chunk_reach_quit,
      target = collector
    })
  end


  --TODO
  
  on_trashsteroid_removed(trashsteroid) --Common cleanup
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
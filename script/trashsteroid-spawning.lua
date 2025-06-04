--This file has the base functions and parameters for spawning and maintaining trashsteroids.

local difficulty_scaling = require("__rubia__.script.trashsteroid-difficulty-scaling")
local chunk_checker = require("__rubia__.script.chunk-checker")

--Functions will be stored onto this global variable:
_G.trashsteroid_lib = _G.trashsteroid_lib or {}

--- Asteroid Management
local max_trashsteroids = 500 --Max # of managed trashsteroids active at once
local max_trashsteroids_per_update = 10 --Max # of trashsteroids to attempt to spawn in one tick.
local max_gen_checks_per_update = 30 --Max # of chunks to try to generate a trashsteroid on, in one tick
local trashsteroid_cooldown_min = 100 --Min cooldown time between trashsteroids in one chunk
local trashsteroid_cooldown_max = 600 --Max cooldown time between trashsteroids in one chunk
local trashsteroid_lifetime = 200 + 40 --Number of ticks that a trashsteroid can live

local max_render_checks_per_update = 60 --Max # of trashsteroids to sift through when finding ones to render
local max_renders_per_update = 30 --Max # of trashsteroid renderings to actually update per tick
local transparency_delta = 0.05 --If transparency change is less than this much, don't update it.

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
local function transparency(value) return {value, value, value, value} end --{r = value, g = value, b = value, a = value} 
local trashsteroid_max_opacity = 0.8 --As opaque as it will get.
local trashsteroid_shadow_max_opacity = 0.9 --As opaque as it will get.

--Trashsteroid ranges, damages, etc
local impact_base_damage = 75 --Raw damage done
local impact_crit_damage = 300
local impact_crit_chance = 10 --As a %
local trashsteroid_impact_radius = 4
local trashsteroid_chunk_reach = prototypes.entity["garbo-grabber"].radius_visualisation_specification.distance --Max collector-chunk distance to allow starting collection
local trashsteroid_chunk_reach_quit = 100 -- Max range chunk projectile will go before giving up
local trashsteroid_chunk_speed = 0.01 -- Initial speed of the trash chunk (avg)
local impact_damage_special = {--Dictionary of entity=>impact damage for special cases
  ["character"] = 280
}

--Try to initialize RNG if it isn't already. Very important random seed. Do NOT change!
local function try_initialize_RNG() if not storage.rubia_asteroid_rng then storage.rubia_asteroid_rng = game.create_random_generator(42069) end end
--local chunk_key_scale = 2^24
--Take in the x and Y coord of a chunk, and output a key for tables
--local function chunk_position_to_key(x, y) return x * chunk_key_scale + y end

------ Impact Logic
---
--Return true if the given entity is immune to impacts
trashsteroid_lib.entity_is_immune_to_impact = function(entity)
  --First, blacklist anything with either immunity to damage or impact damage
  if (not entity.is_entity_with_health) then return true end 
  if (entity.prototype.resistances and entity.prototype.resistances.impact and entity.prototype.resistances.impact.percent 
      and entity.prototype.resistances.impact.percent >= 99) then return true end
  
  --Check manual blacklist.
  if (rubia.trashsteroid_blacklist[entity.name]) then return true end

  --Passed all checks
  return false
end

--Return an array of all entities that are in the impact range, which are relevant to impact.
local function find_impact_targets(position, radius) --TODO: Iterator
  local impacted_raw = storage.rubia_surface.find_entities_filtered({
    position = position,
    radius = radius,
    force = game.forces["player"]
  })
  local impacted = {} --Actual list of entities that should be impacted
  for _,entity in pairs(impacted_raw) do
    if not trashsteroid_lib.entity_is_immune_to_impact(entity) then
      table.insert(impacted, entity) end
  end

  return impacted
end

---Return the closerst garbo collector in range (LuaEntity) that is in range of an impact to make a chunk projectiles, and is valid to collect.
---If no valid collector found, return nil.
---@param search_start_point MapPosition
---@return LuaEntity | nil
local function find_closest_collector(search_start_point)
  local collectors = storage.rubia_surface.find_entities_filtered({
    position = search_start_point,
    radius = trashsteroid_chunk_reach,
    name = "garbo-grabber"
  })
  if not collectors then return nil end --Nothing found. Most common case.

  local best_collector = nil--Closest one that is valid
  --Compare closest square range to avoid unnecessary sqrt
  local closest_range = (trashsteroid_chunk_reach + 1)^2
  for _,entity in pairs(collectors) do
    if (not entity or not entity.valid) then goto continue end --It just isn't valid
    --Check that there is enough space for at least one item.
    if (entity.get_inventory(defines.inventory.chest).can_insert({name="craptonite-chunk",count=1})) then
      local current_range = (entity.position.x - search_start_point.x)^2 + (entity.position.y - search_start_point.y)^2
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

--[[Output a map of "surface-name" = {array of entities with that name on that surface}
local function find_all_entity_of_name(input_name)
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
end]]

--Function to call to clean up trashsteroid data
local on_trashsteroid_removed
--On game startup, clear anything already existing.
local function clear_all_trashsteroids()
  storage.active_trashsteroids = storage.active_trashsteroids or {}
  -- Clear all existing trashsteroids
  for _, tname in pairs(trashsteroid_names) do
    local trashsteroids = rubia_lib.find_all_entity_of_name(tname)
    for _, entity_list in pairs(trashsteroids) do
      for _, entity in pairs(entity_list) do
        if not entity.unit_number then log(serpent.block(entity)) end
        storage.active_trashsteroids[(entity.unit_number)] = nil
        if entity.valid then entity.destroy() end 
      end
    end
  end

  --We may have gotten rid of all the actual rocks, but we still need to clear the data fully.
  local old_trash_data_to_clear = util.table.deepcopy(storage.active_trashsteroids or {})
  for _, trashsteroid in pairs(old_trash_data_to_clear) do
    on_trashsteroid_removed(trashsteroid)
    if trashsteroid.entity.valid then trashsteroid.entity.destroy() end
  end

  assert(table_size(storage.active_trashsteroids) == 0, 
    "There are still some active trashsteroids! Report to the mod author.")
  storage.active_trashsteroids = {}
  storage.active_trashsteroid_count = 0
end




--When a new chunk has to be added, log everything we need to start spawning entities there.
trashsteroid_lib.log_chunk_for_trashsteroids = function(surface, position, area)
  if surface and (surface.name == "rubia") then 
    storage.rubia_surface = surface
    table.insert(storage.rubia_chunks,{x = position.x, y = position.y, area = area})

    --Queue up this chunk's next trashsteroid.
    try_initialize_RNG()
    storage.pending_trashsteroid_data[chunk_checker.chunk_position_to_key(position.x,position.y)] 
      = game.tick + 1 + storage.rubia_asteroid_rng(trashsteroid_cooldown_min, trashsteroid_cooldown_max)
  end
end

--Pass along info to update difficulty scaling information.
local update_difficulty_scaling = function()
  difficulty_scaling.update_difficulty_scaling()
  --local shield_val, shield_name = difficulty_scaling.get_current_shield()
  --game.print("New shield value = " .. tostring(shield_val) .. ", shield name = " .. shield_name)

  local settings = difficulty_scaling.settings()
  impact_base_damage = settings.impact_base_damage
  impact_crit_damage = settings.impact_crit_damage
  impact_crit_chance = settings.impact_crit_chance
  trashsteroid_impact_radius = settings.trashsteroid_impact_radius
  impact_damage_special["character"] = settings.character_damage
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
  assert(resulting_entity, "Null trashsteroid was made! How!?")

  --Difficulty scaling
  local shield_val, shield_name = difficulty_scaling.get_current_shield()
  local shield = resulting_entity.grid.put{name=shield_name}
  shield.shield = shield_val
  --local shield = resulting_entity.grid.put{name="trashsteroid-shield"}
  --shield.shield = 100

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
  local next_trashsteroid_tick = game.tick + 1 + storage.rubia_asteroid_rng(trashsteroid_cooldown_min, trashsteroid_cooldown_max)-- + trashsteroid_lifetime
  storage.pending_trashsteroid_data[chunk_checker.chunk_position_to_key(chunk.x,chunk.y)] = next_trashsteroid_tick -- queue up next trashsteroid

  storage.active_trashsteroids[(resulting_entity.unit_number)] = {
    unit_number = resulting_entity.unit_number,
    entity = resulting_entity,
    death_tick = game.tick + trashsteroid_lifetime,
    name = trashsteroid_name,
    chunk_data = chunk,
    chunk_key = chunk_checker.chunk_position_to_key(chunk.x, chunk.y),
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


---This version uses flib iteration
--Go through one round of going through all chunks and trying to spawn trashsteroids
trashsteroid_lib.try_spawn_trashsteroids = function()
  --game.print("Chunk iterator: " + serpent.block(stage.rubia_chunk_iterator))
  try_initialize_RNG()
  if not storage.developed_chunks then return end --No chunks to worry about
  local spawned_trashsteroids = 0 --Total spawned this cycle

  --game.print(serpent.block(storage.pending_trashsteroid_data))

  local key = 0
  --Function of what to do on a valid chunk
  local function do_on_valid_chunk(value, _)
    key = chunk_checker.chunk_position_to_key(value.chunk.x,value.chunk.y)
    local next_tick = storage.pending_trashsteroid_data[key] --The key might not be in the dic,
    
    --We may have a developed chunk that isn't charted yet because of the ranges.
    if not next_tick then
      --game.print("unlogged chunk at: (" .. value.chunk.x .. "," .. value.chunk.y)
      --trashsteroid_lib.log_chunk_for_trashsteroids(storage.rubia_surface, 
      --  {x=value.chunk.x,y=value.chunk.y}, chunk_checker.chunk_pos_to_area(value.chunk.x, value.chunk.y))
      return
    end 
    if next_tick > game.tick then return end --Still on cooldown

    --[[if(value.chunk.x == 0 and value.chunk.y == 1) then
      game.print("key = " .. key .. ", tick = " .. game.tick .. ", next tick = " ..  storage.pending_trashsteroid_data[key] ..
      ", next calc key = " .. chunk_checker.chunk_position_to_key(value.chunk.x, value.chunk.y))
    end]]
    generate_trashsteroid("medium-trashsteroid", value.chunk)
    spawned_trashsteroids = spawned_trashsteroids + 1
    --If we reached the max, then abort the loop
    if spawned_trashsteroids >= max_trashsteroids_per_update then return nil, nil, true end
  end

  --if math.fmod(game.tick,30) == 0 then log(serpent.block(storage.pending_trashsteroid_data)) end

  --Index of the last chunk where we ended iteration
  storage.trash_gen_index = rubia.flib.for_n_of(storage.developed_chunks, storage.trash_gen_index,
    max_gen_checks_per_update, do_on_valid_chunk)
  --game.print(check_string)
end


--Force intialize all variables and a hard refresh
trashsteroid_lib.hard_refresh = function()
  clear_all_trashsteroids()
  storage.rubia_chunks = {}
  storage.pending_trashsteroid_data = {}
  storage.rubia_surface = game.get_surface("rubia")
  if storage.rubia_surface then 
    for chunk in storage.rubia_surface.get_chunks() do
      trashsteroid_lib.log_chunk_for_trashsteroids(storage.rubia_surface,{x=chunk.x,y=chunk.y}, chunk.area)
    end
  end
  try_initialize_RNG()
  --difficulty_scaling.initialize()
  --local trashsteroids = storage.rubia_surface.find_entities_filtered({filter="name",name="medium-trashsteroid"})
end


--[[Trashsteroid scaling: allow it to be flipped
local trashsteroid_scale = function(fractional_age) return 2*fractional_age + (1 - fractional_age) * trashsteroid_min_size end
local function update_trashsteroid_size_scaling()
  trashsteroid_scale = function(fractional_age) return 2*fractional_age + (1 - fractional_age) * trashsteroid_min_size end
  if settings.global["invert-trashsteroid-scaling"].value then
    trashsteroid_min_size = 0.5
    trashsteroid_scale = function(fractional_age) return (1 - fractional_age) + (fractional_age) * trashsteroid_min_size end
  end
end
update_trashsteroid_size_scaling()]]

local function trashsteroid_size_scaling(fractional_age)
  if settings.global["invert-trashsteroid-scaling"].value then
    return (1 - fractional_age) + (fractional_age) * 0.5
  else return 2*fractional_age + (1 - fractional_age) * trashsteroid_min_size
  end
end

local mathfmod, mathmin = math.fmod, math.min
--Update the rendering for this one trashsteroid.
local function update_trashsteroid_rendering(trashsteroid)
  local fractional_age = 1 - (trashsteroid.death_tick - game.tick)/trashsteroid_lifetime
  local render_solid = trashsteroid.render_solid
  local render_shadow = trashsteroid.render_shadow

  local scale = trashsteroid_size_scaling(fractional_age)--trashsteroid_scale(fractional_age)
  --local scale = 2*fractional_age + (1 - fractional_age) * trashsteroid_min_size
  render_solid.x_scale = scale--fractional_age + (1 - fractional_age) * trashsteroid_min_size
  render_solid.y_scale = scale--trashsteroid.render_solid.x_scale
  render_shadow.x_scale = scale--trashsteroid.render_solid.x_scale
  render_shadow.y_scale = scale--trashsteroid.render_solid.x_scale

  local orient = mathfmod(fractional_age * trashsteroid.orient_initial + (1 - fractional_age) * trashsteroid.orient_final,1)
  render_solid.orientation = orient
  render_shadow.orientation = orient
  
  --Transparency comes in quickly with fractional age.
  local transparency_scale = mathmin(1, 1-(1-fractional_age)^6)--3)
  local solid_tranparency = trashsteroid_max_opacity * transparency_scale
  --Transparency update is weirdly expensive. Update this less frequently.
  if (solid_tranparency - render_solid.color.r >= transparency_delta) then
    render_solid.color = transparency(solid_tranparency)
    render_shadow.color = transparency(trashsteroid_shadow_max_opacity * transparency_scale)
  end

  --Now get shift between shadow and solid
  --game.print(serpent.block(trashsteroid.render_solid.target.entity.position))
  local pos = trashsteroid.entity.position
  render_shadow.target = {
    x = fractional_age * trashsteroid_shadow_min_vec.x + (1-fractional_age) * trashsteroid_shadow_max_vec.x + pos.x,
    y = fractional_age * trashsteroid_shadow_min_vec.y + (1-fractional_age) * trashsteroid_shadow_max_vec.y + pos.y
  }
  
  --[[Make it vulnetable if it is big enough
  if (trashsteroid.entity and trashsteroid.entity.valid and fractional_age > 0.2) then
    trashsteroid.entity.is_military_target = false
  end]]
end


--[[Go through all trashsteroids, and update their rendering.
trashsteroid_lib.rendering_update = function()
  if not storage.active_trashsteroids then return end

  local viewed_chunks = chunk_checker.currently_viewed_chunks(storage.rubia_surface)
  if not viewed_chunks then return end

  for _, trashsteroid in pairs(storage.active_trashsteroids) do
    --if (chunk_checker.chunk_is_visible(trashsteroid.chunk_key)
    if (viewed_chunks[trashsteroid.chunk_key]--[chunk_checker.chunk_position_to_key(trashsteroid.chunk_data.x,trashsteroid.chunk_data.y)]
      and trashsteroid.render_solid and trashsteroid.render_solid.valid
      and trashsteroid.render_shadow and trashsteroid.render_shadow.valid) then
        update_trashsteroid_rendering(trashsteroid)
    end
  end
end]]



--Go through all trashsteroids, and update their rendering.
local rendering_update = function()
  if not storage.active_trashsteroids then return end

  local viewed_chunks = chunk_checker.get_currently_viewed_chunks(storage.rubia_surface)
  --chunk_checker.currently_viewed_chunks(storage.rubia_surface)
  if not viewed_chunks or table_size(viewed_chunks) == 0 then return end

  local total_renders = 0
  local function single_render_update(trashsteroid)
    if (viewed_chunks[trashsteroid.chunk_key]--[chunk_checker.chunk_position_to_key(trashsteroid.chunk_data.x,trashsteroid.chunk_data.y)]
      and trashsteroid.render_solid and trashsteroid.render_solid.valid
      and trashsteroid.render_shadow and trashsteroid.render_shadow.valid) then
        update_trashsteroid_rendering(trashsteroid)
        total_renders = total_renders + 1
        return nil, nil, (total_renders >= max_renders_per_update)
    end
  end

  storage.trash_render_index = rubia.flib.for_n_of(storage.active_trashsteroids,
    storage.trash_render_index, max_render_checks_per_update, single_render_update)
end


--What to do when this trashsteroid is removed. Takes care of maintaining caches.
--Includes cleanup common to any mode of death (impact/shot/etc).
function on_trashsteroid_removed(trashsteroid)
    if not trashsteroid then return end
    --Destroy the renders
    trashsteroid.render_solid.destroy()
    trashsteroid.render_shadow.destroy()

    --Delist before destruction.
    --assert(storage.active_trashsteroids[(trashsteroid.unit_number)] , "Trashsteroid not found!")
    storage.active_trashsteroids[(trashsteroid.unit_number)] = nil
    storage.active_trashsteroid_count = storage.active_trashsteroid_count - 1
end

--On game startup, clear anything already existing.
local function clear_logged_trashsteroids()
  -- Clear all existing trashsteroids
  for _, trashsteroid in pairs(storage.active_trashsteroids or {}) do
    on_trashsteroid_removed(trashsteroid)
    if trashsteroid.entity.valid then trashsteroid.entity.destroy() end
  end
  storage.active_trashsteroids = {}
  storage.active_trashsteroid_count = 0
end


--Trashsteroid Impact checks
--{unit_number=resulting_entity.unit_number, death_tick=game.tick, name=trashsteroid_name, chunk_data=chunk}
--Go check all trashsteroids to see if any of them are so old that they need to do an impact check, and go do so for trashsteroids at the end of their life cycle.
trashsteroid_lib.trashsteroid_impact_update = function()
  if not storage.active_trashsteroids then return end
  --game.print(serpent.block(storage.active_trashsteroids))

  --Make a temporary array of all trashsteroid entities that need to go through their impact, so we can delete them without changing our iteration.
  local trashsteroids_impacting = {}
  for _, trashsteroid in pairs(storage.active_trashsteroids) do
    if (trashsteroid.death_tick < game.tick) then
      table.insert(trashsteroids_impacting, trashsteroid)
      --If valid, log it to delete
      --local entity = trashsteroid.entity--game.get_entity_by_unit_number(trashsteroid.unit_number)
      --if entity and entity.valid then 
      --  table.insert(trashsteroids_impacting, trashsteroid)
      --end
    end
  end

  --Now we go through and actually DO the impacts
  for _,trashsteroid in pairs(trashsteroids_impacting) do
      local entity = trashsteroid.entity

      --Stale reference. Just delist it
      if not entity.valid then 
        on_trashsteroid_removed(trashsteroid)
        goto continue
      end

      --Real roid. Deal damage
      local impacted_entities = find_impact_targets(entity.position, trashsteroid_impact_radius)
      local default_damage = (storage.rubia_asteroid_rng(0,100) <= impact_crit_chance) and impact_crit_damage or impact_base_damage
      for _,hit_entity in pairs(impacted_entities) do
        local damage = impact_damage_special[hit_entity.name] or default_damage
        --This version calculates crit chance separately on each thing hit of 1 trashsteroid.
        --if not damage then --Not special case
        --  damage = (storage.rubia_asteroid_rng(0,100) <= impact_crit_chance) and impact_crit_damage or impact_base_damage
        --end
        hit_entity.damage(damage, game.forces["enemy"])
      end

      local explosion_name = "medium-trashsteroid-explosion" .. tostring(storage.rubia_asteroid_rng(1,9)) --Number of unique explosions go here
      --trashsteroid_lib.trashsteroid_explosions[storage.rubia_asteroid_rng(1,#trashsteroid_lib.trashsteroid_explosions)]
      storage.rubia_surface.create_entity({
        name = explosion_name,
        position = {x = entity.position.x + 0.5,y = entity.position.y} --Shift explosion a little bit to lead it.
      })

      on_trashsteroid_removed(trashsteroid) --Perform common cleanup
      entity.destroy()

      ::continue::
  end  
end

--These damage types will lead to spawning a trashsteroid chunk, if possible. Hashset
local trash_spawn_dmg_types = {["physical"] = true, ["explosion"] = true}

--What to do when a medium trashsteroid is killed. Assume it is valid, and the right type.
trashsteroid_lib.on_med_trashsteroid_killed = function(entity, damage_type)
  --If invalid entity, or the damage type that killed isn't supposed to make chunks, then escape
  if (not entity.valid or not damage_type
    or not trash_spawn_dmg_types[damage_type.name]) then return end

  --Make a smalll chunk projectile, if it makes sense. First: search for a valid collector
  local collector = find_closest_collector(entity.position)
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

  local trashsteroid = storage.active_trashsteroids[(entity.unit_number)]
  if trashsteroid then on_trashsteroid_removed(trashsteroid) end --Common cleanup
end


--Debugging function
trashsteroid_lib.print_pending_trashsteroid_data = function()
  local string = "Total pending trashsteroids = " .. tostring(storage.pending_trashsteroid_data and #storage.pending_trashsteroid_data or 0) 
  string = string .. ". Tick = " .. game.tick .. ":\n"
  for key, tick in pairs(storage.pending_trashsteroid_data) do
    string = string .. key .. ":" .. tick .. ", "
  end
  game.print(string)
  log(string)
end
trashsteroid_lib.print_active_trashsteroid_data = function()
  local string = "Total active trashsteroids = " .. tostring(storage.active_trashsteroid_count or 0)
  string = string .. ". Tick = " .. game.tick .. ". Key-death ticks:\n"
  for key, roid in pairs(storage.active_trashsteroids) do
    string = string .. key .. ":" .. roid.death_tick .. ", "
  end
  game.print(string)
  log(string)
end

--If trashsteroids are extremely old, then reset!
trashsteroid_lib.reset_failsafe = function ()
  if not storage.active_trashsteroids then return end
  local trashsteroid = nil
  for _, trashsteroid_iter in pairs(storage.active_trashsteroids or {}) do
    trashsteroid = trashsteroid_iter; break
  end
  --If the first trashstroid we find is very stale, then RESET!
  if trashsteroid and (trashsteroid.death_tick + 60*60 < game.tick) then
    log("Activating trashsteroid reset failsafe. If this happens repeatedly, report to the mod creator."
    .. " Resetting with Death tick = " .. trashsteroid.death_tick .. ", game.tick = " 
    .. game.tick .. ", Valid = " .. tostring(trashsteroid.entity.valid))
    trashsteroid_lib.hard_refresh()
    trashsteroid_lib.print_active_trashsteroid_data()
  end
end

--#region Event management

--Trashteroid data
local function initialize()
  --storage.active_trashsteroids = {} --active_trashsteroids[(unit_number)] = {unit_number=resulting_entity.unit_number, death_tick=tick, name=trashsteroid_name, chunk_data=chunk}
  storage.active_trashsteroids = storage.active_trashsteroids or {}
  storage.active_trashsteroid_count = storage.active_trashsteroid_count or 0
  --Trashsteroid queue for chunks that currently don't have an active trashsteroid
  --storage.pending_trashsteroid_data = {}--[chunk_data=chunk] = (next_spawn_tick=tick) --has the next tick where we expect a trashsteroid spawn
  ----@type table<ChunkData, uint>
  storage.pending_trashsteroid_data = storage.pending_trashsteroid_data or {}
  --Log and update chunk data
  storage.rubia_chunks = storage.rubia_chunks or {}
  storage.trash_render_index = storage.trash_render_index or 0
end

local event_lib = require("__rubia__.lib.event-lib")



event_lib.on_event(defines.events.on_chunk_charted, "trashsteroid-chunk-log",
  function(event)
    local surface = game.get_surface(event.surface_index)
    trashsteroid_lib.log_chunk_for_trashsteroids(surface, event.position, event.area)
end)

event_lib.on_nth_tick(1, "trashsteroid-spawn", trashsteroid_lib.try_spawn_trashsteroids)
event_lib.on_nth_tick(1, "trashsteroid-render-update", rendering_update)
event_lib.on_nth_tick(4, "trashsteroid-impact-update", trashsteroid_lib.trashsteroid_impact_update)
event_lib.on_nth_tick(60 * 10, "trashsteroid-reset-failsafe", trashsteroid_lib.reset_failsafe)

event_lib.on_init("trashsteroid-spawn-initialize", initialize)
event_lib.on_configuration_changed("trashsteroid-spawn-initialize", initialize)

script.on_event(defines.events.on_entity_died, function(event)
  trashsteroid_lib.on_med_trashsteroid_killed(event.entity, event.damage_type)
end, {{filter = "name", name = "medium-trashsteroid"}})

--Settings
--[[
event_lib.on_init("trashsteroid-difficulty", update_difficulty_scaling)
event_lib.on_configuration_changed("trashsteroid-difficulty", update_difficulty_scaling)
event_lib.on_event(defines.events.on_runtime_mod_setting_changed, "trashsteroid-size-scaling", function(event)
  if event.setting == "invert-trashsteroid-scaling" then update_trashsteroid_size_scaling() end
end)]]
event_lib.on_event({defines.events.on_research_finished, defines.events.on_technology_effects_reset,
  defines.events.on_player_joined_game},
  "trashsteroid-difficulty-update", update_difficulty_scaling)
event_lib.on_init("trashsteroid-difficulty-update", update_difficulty_scaling)
event_lib.on_configuration_changed("trashsteroid-difficulty-update", update_difficulty_scaling)
event_lib.on_event(defines.events.on_runtime_mod_setting_changed, "trashsteroid-difficulty-scaling", function(event)
  if event.setting == "rubia-difficulty-setting" then update_difficulty_scaling() end
end)


--#endregion












--[[
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
]]

--[[
--This version checks through ALL visible area
  local force = game.forces["player"]
  for _, trashsteroid in pairs(storage.active_trashsteroids) do
    if (force.is_chunk_visible(storage.rubia_surface, {x=trashsteroid.chunk_data.x, y = trashsteroid.chunk_data.y})
      

]]
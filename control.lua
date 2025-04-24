--Global var declaration
_G.rubia = require "__rubia__.lib.constants"
require("__rubia__.lib.lib")
require("__rubia__.script.chunk-checker")
--require("__rubia__.lib.function-serializer")
require("__rubia__.script.trashsteroid-blacklist")
require("__rubia__.script.trashsteroid-spawning")
local landing_cutscene = require("__rubia__.script.landing-cutscene")
require("__rubia__.script.wind-correction")
require("__rubia__.script.init")
local trashdragon = require("__rubia__.script.project-trashdragon")
local lore_mining = require("__rubia__.script.lore-mining")

--#region Technology/Sci related
--[[
local trashdragon = require("__rubia__.script.project-trashdragon")
script.on_event(defines.events.on_built_entity, function(event)
    trashdragon.on_built_rocket_silo(event)
end)]]

--Disable makeshift/ghetto sci if the progression techs for which they are required are done.
rubia.check_disable_temporary_science_recipes = function()
  for _, force in pairs(game.forces) do
    if force.technologies["rubia-progression-stage2"].researched then
      force.recipes["makeshift-biorecycling-science-pack"].enabled = false
    end
    if force.technologies["rubia-progression-stage3"].researched then
      force.recipes["ghetto-biorecycling-science-pack"].enabled = false
    end
  end
end

--check_disable_temporary_science_recipes() --One check at startup
script.on_event(defines.events.on_research_finished, function(event)
  --Do a correction based on the current state, not on the research which has completed.
  rubia.check_disable_temporary_science_recipes()
end)
--#endregion


--#region Faux quality scaling


---Fake quality scaling onto the wind turbine.
local function quality_correct_wind_turbine(entity)
  --For some reason, 5000 = 300 kW
  if entity.valid and entity.name == "rubia-wind-turbine" then
      local quality_mult = 1 + 0.3 * entity.quality.level
      entity.power_production = entity.power_production * quality_mult
      entity.electric_buffer_size = entity.electric_buffer_size * quality_mult
   end
end

--#endregion

--Cutscene

script.on_event(defines.events.on_player_changed_surface, function(event)
  landing_cutscene.try_start_cutscene(event)
  if game.get_surface("rubia") then
    chunk_checker.try_update_player_pos(game.get_player(event.player_index), game.get_surface("rubia"))
  end
end)

script.on_event(defines.events.on_player_died, function(event)
  landing_cutscene.cancel_on_player_death(event)
end)






-------Scripts to subscribe functions to events tied to building/modifying

-- Scripts to execute rotation-corrections
script.on_event(defines.events.on_player_rotated_entity, function(event)
    rubia.wind_rotation(event.entity, event)
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
    rubia.wind_rotation(event.entity, event)
end)

local function do_on_built_changes(event)
    if event.entity.surface.name ~= "rubia" or not event.entity.valid then return end

    rubia.wind_rotation(event.entity, event)
    trashdragon.on_built_rocket_silo(event)
    quality_correct_wind_turbine(event.entity)
    chunk_checker.register_new_entity(event.entity)
end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity,
  defines.events.script_raised_built, defines.events.script_raised_revive}, function(event)
  do_on_built_changes(event)
end)


script.on_event(defines.events.on_object_destroyed, function(event)
  chunk_checker.delist_entity(event.registration_number)

end)
--------------------
--------------------
--------------------

--- Asteroid and on-tick Management

script.on_event(defines.events.on_chunk_charted, function(event)
  local surface = game.get_surface(event.surface_index) -- convert surface ID to surface.
  trashsteroid_lib.log_chunk_for_trashsteroids(surface, event.position, event.area)
end)

script.on_event(defines.events.on_player_changed_position, function(event)
  chunk_checker.try_update_player_pos(game.get_player(event.player_index), storage.rubia_surface)
end)


script.on_nth_tick(1,function()
  rubia.timing_manager.update()
  trashsteroid_lib.try_spawn_trashsteroids()
end)


script.on_nth_tick(2, function()

end)

script.on_nth_tick(3, function()
  trashsteroid_lib.update_trashsteroid_rendering()

  --trashsteroid_lib.try_spawn_trashsteroids()
end)

--Trashsteroid Impact checks
--{unit_number=resulting_entity.unit_number, death_tick=game.tick, name=trashsteroid_name, chunk_data=chunk}
script.on_nth_tick(4, function()
  trashsteroid_lib.trashsteroid_impact_update()
end)

script.on_event(defines.events.on_entity_died, function(event)
  trashsteroid_lib.on_med_trashsteroid_killed(event.entity)
end, {{filter = "name", name = "medium-trashsteroid"}})


----Mining item checks

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined}, function(event)
  lore_mining.try_lore_when_mined(event.entity)

end)

--on_player_mined_entity
--on_robot_mined
--on_entity_died


--[[Protect collectors from having items added to them
script.on_event(defines.events.on_player_fast_transferred, function(event)
  --If adding things in to a garbo gatherer, undo it.
  if (event.from_player --Adding things in
  and event.entity and event.entity.valid
  and event.entity.name == "garbo-gatherer") then
    local player_inv = game.get_player(event.player_index).get_inventory(defines.inventory.character_main)
    local collector_inv = event.entity.get_inventory(defines.inventory.chest)
    
    --TODO: Transfer everything back

  end
end)]]


-------













--------------------------------
--[[
  local local_chunk_iterator
  if rubia_surface == nil then rubia_surface = game.get_surface("rubia") end
  if rubia_surface then local_chunk_iterator = rubia_surface.get_chunks()
  else do return end
  end]]



  --[[for chunk in local_chunk_iterator do
    --log(serpent.block(chunk))
    if (rubia_surface.is_chunk_generated(chunk)) then
      generate_trashsteroid("medium-trashsteroid", chunk)
    end
  end

--Initialize variables
local rubia_surface
local asteroid_rng
local active_chunks = {}

local initialized = false
--Initialize variables on game start
local function initialize() 
  --Very important random seed. Do NOT change!
  if asteroid_rng == nil then asteroid_rng = game.create_random_generator(42069) end

  local local_chunk_iterator
  if rubia_surface == nil then rubia_surface = game.get_surface("rubia") end
  if rubia_surface then local_chunk_iterator = rubia_surface.get_chunks()
  --else do return end
  end

  if (local_chunk_iterator) then
    for chunk in local_chunk_iterator do
      if (rubia_surface.is_chunk_generated(chunk)) then active_chunks[chunk] = chunk end
    end
    --We have a surface, but no chunks. Force generate spawn.
    if (active_chunks == nil) then rubia_surface.request_to_generate_chunks({0,0}) end
    initialized = true
  end

  --Only fully declare intialization complete when everything is not nil
  --if (asteroid_rng and active_chunks and rubia_surface) then initialized = true end
end



--Get a list of active chunks. Generate the cache if it is empty. 
local function get_active_chunks(surface)
  if active_chunks then return active_chunks
  elseif surface then surface.request_to_generate_chunks({0,0}) end -- generate spawn
  --If there is no surface, then don't worry about it.
end
--Update active chunks

script.on_event(defines.events.on_chunk_generated, function(area, position, surface, name, tick)
  if surface and (surface.name == "rubia") then 
    local chunk = {x = position.x, y = position.y, area = area}
    active_chunks[chunk] = chunk
  end
end)]]



  --[[
  if (initialized == false) then initialize() 
  else 
    log("not initialized")
    if (asteroid_rng == nil) then log("no rng") end
    if (active_chunks == nil) then log("no chunks") end
    if (rubia_surface == nil) then log("no surface") end
    return --Come back around when fully initialized
  end]]
  
  --[[log("start")
  log(serpent.block(active_chunks))
  --if (active_chunks == nil) then return end
  for i,chunk in pairs(active_chunks) do
    --log(serpent.block(chunk))
    generate_trashsteroid("medium-trashsteroid", chunk)
  end]]

--[[
function grow.on_tick(tick)
  if global.grow_settings.enabled and #global.active_forestries > 0 then
    for surface_index,_ in pairs(global.active_forestries) do
      grow.update_forestries(surface_index, tick)
    end
  end
end
function grow.update_forestries(surface_index, tick)
  -- calculate how many updates we should do this tick
  local active_forestries = global.active_forestries[surface_index]
  local num_active = #active_forestries
  if num_active == 0 then return end
  local num_updates = math.ceil(num_active / global.grow_settings.ticks)
  local update_ticks = math.max(math.floor(global.grow_settings.ticks / num_active), 1)
  if tick % update_ticks ~= 0 then return end

  -- set up for round robin
  local roundrobin_offset = global.update_data[surface_index].roundrobin_offset or 0

  -- update active forestries
  local surface = game.get_surface(surface_index)
  local forestry_data = global.forestry_data[surface_index]
  for i=0,num_updates-1 do
    local number = active_forestries[(i + roundrobin_offset) % num_active + 1]
    log("Updating Forestry #"..number)
    local data = forestry_data[number]
    local forestry = data and surface.find_entity("forestry", data.position)
    if forestry then
      if grow.update_forestry(forestry, data, tick) then
        -- if the forestry was deactivated, then subtract num_updates to match
        if not data.is_active then
          num_updates = num_updates - 1
          i = i - 1
        end
      else
        -- if the forestry is waiting for update, stop roundrobin so we don't skip it
        if forestry.is_crafting() then
          num_updates = i + 1
          break
        end
      end
    end -- TODO: else unregister??
  end

  -- update the roundrobin offset
  global.update_data[surface_index].roundrobin_offset = (roundrobin_offset + num_updates) % num_active
end
]]

--[[

local iceable_products = {"bioflux","agricultural-science-pack","biter-egg","pentapod-egg","raw-fish"}
local last_tick = -1 --Last time we queried ice-box
--local iceable_array_length = table.getn(iceable_products) Need to use table_size() 

local lab_cache = {}
local ice_box_cache = {}
local initialized_cache = false
local skip_process_lab = false --When we want to make sure we reset the cache properly
local skip_process_ice = false

local function calculate_stack_count(item_count,stack_size)
  local out = 1
  if(item_count <= stack_size) then
    out = 1
  else 
    local complete_stacks = math.floor(item_count / stack_size) -- // is 5.3 only feature
    out = complete_stacks
    if(item_count % stack_size ~= 0) then --if we have any remainder, we have another incomplete stacks
      out = complete_stacks + 1
    end
  end
  return out
end

local function find_all_entity_of_name(input_name)
  local out_entity_table = {}
  local surface_array = game.surfaces
    for k,q in pairs(surface_array) do --names of surfaces are in keys
        local current_surface = game.get_surface(k)
        --pressure-lab

        local entity_array = current_surface.find_entities_filtered{name = input_name} --input_name
        if(table_size(entity_array) == 0) then
          out_entity_table[current_surface.name] = {}
          goto continue_loop
        end
        local entity_map = {} --need a map that I can easily find and remove entities from
        for i,e in pairs(entity_array ) do 
          --log("e=")
          --log(serpent.block(e))
          entity_map[e.name..e.gps_tag] = e
        end 
        out_entity_table[current_surface.name] = entity_map
        ::continue_loop::
    end
  
  --log(serpent.block(out_entity_table))

  

  return out_entity_table
end 


---@param entity LuaEntity
local function add_to_cache(entity,cache)
  if(entity.valid == true) then
    local surface_name = entity.surface.name
    local key = entity.name .. entity.gps_tag
    --log(serpent.block(entity.name))
    --log(serpent.block(entity.gps_tag))
    --log(serpent.block(entity.surface.name))
    if(cache[surface_name] == nil) then cache[surface_name] = {} end
    cache[surface_name][key] = entity
  end
end

---@param entity LuaEntity
local function remove_from_cache(entity,cache)
  if(entity.valid == true) then
    local surface_name = entity.surface.name
    local key = entity.name .. entity.gps_tag
    if(cache[surface_name] ~= nil) then
      cache[surface_name][key] = nil
    end
  end
end

local function process_labs(pressure_labs)
  local nil_ent = nil
  ---@cast nil_ent LuaEntity
  --log("PROCESS BEGIN")
  for i,v in pairs(pressure_labs) do
    --log("i="..i)
    --log("v=")
    --log(serpent.block(v))

    if(v == nil or v.valid == false or v == nil_ent ) then --If we messed up with the cache somehow.
      lab_cache = find_all_entity_of_name("pressure-lab")
      return
      --goto continue_loop
    end
    --log("v.status=")
    --log(serpent.block(v.status))

    if(v.valid == false or v.status ~= defines.entity_status_diode.red ) then --Either the brackets around the defines or adding these numbers made it work. Don't like using the numbers as this could break things in the future
      goto continue_loop 

    end
    local inventory = v.get_inventory(defines.inventory.lab_input)
    local contents = inventory.get_contents()
    for j,c in ipairs(contents) do
        if (c.quality == "normal" ) then
          inventory.remove({name = c.name, count = c.count})
          local out_inventory = v.get_inventory(defines.inventory.lab_input)
          if (c.count > 1 ) then
            out_inventory.insert({name = c.name, count = c.count -1})
          end
        end
    end
  
  

  --log("PROCESS END")
  
    ::continue_loop::

  end
end


script.on_nth_tick(10, --closest we get to begin play
  function(NthTickEventData)
    if(initialized_cache == false) then
      lab_cache = find_all_entity_of_name("pressure-lab")
      ice_box_cache = find_all_entity_of_name("ice-box")
      initialized_cache = true
    end
    
  end
)

--Can't have multiple of the same event. New event will override the old one. This isn't what I want.

--Thanks StephenB
for _, eventType in pairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
}) do
	script.on_event(eventType,
		function(event)
			---@cast event EventData.on_built_entity | EventData.on_player_mined_entity | EventData.on_robot_built_entity | EventData.on_robot_mined_entity | EventData.on_entity_died
			local entity = event.entity
			---@cast entity LuaEntity -- Guaranteed to be LuaEntity when read.
      if (entity.name == "pressure-lab") then
        add_to_cache(entity,lab_cache)
      end
      
      if(entity.name == "ice-box") then
        add_to_cache(entity,ice_box_cache)
      end

		end)
		--{{ filter = "name", name ="pressure-lab"}})
end

for _, eventType in pairs({
	defines.events.on_player_mined_entity,
	defines.events.on_robot_mined_entity,
	defines.events.on_entity_died,
}) do
	script.on_event(eventType,
		function(event)
			---@cast event EventData.on_built_entity | EventData.on_player_mined_entity | EventData.on_robot_built_entity | EventData.on_robot_mined_entity | EventData.on_entity_died
			local entity = event.entity
			---@cast entity LuaEntity -- Guaranteed to be LuaEntity when read.

      if (entity.name == "pressure-lab") then
        remove_from_cache(entity,lab_cache)
      end

      if(entity.name == "ice-box") then
        remove_from_cache(entity,ice_box_cache)
      end
      ---skip_process_lab = true
      --lab_cache = nil
      --lab_cache = find_all_entity_of_name("pressure-lab")
      --lab_cache = find_all_entity_of_name("pressure-lab")
		end)
		--{{ filter = "name", name = "pressure-lab" }})
end





script.on_nth_tick(45,
  function(NthTickEventData)
    if(skip_process_lab == true) then
      skip_process_lab = false
      return
    end
    
    for s,labArray in pairs(lab_cache) do
      process_labs(labArray)
    end
  end
)

script.on_nth_tick(53,
  function(NthTickEventData)
    --log("---TICK START---")
    --log(last_tick)
    if(skip_process_ice) then
      skip_process_ice = false
      return
    end

    local current_tick = NthTickEventData.tick
    local delta_time = 53
    if(last_tick == -1 ) then --Only works if are on tick > 53. last_tick is -1 on start up
      last_tick = NthTickEventData.tick - 53
    end

    if(NthTickEventData.tick < 54 or NthTickEventData.tick % 45 == 0 ) then --If we either just started or N45th tick. I already do a lot of query on the 45th tick, so I don't want to lag the game every 45*53 ticks 
      goto end_function --fail safe
    end

    local surface_array = game.surfaces
    for k,q in pairs(surface_array) do --names of surfaces are in keys
        local current_surface = game.get_surface(k)
        local ice_boxes = ice_box_cache[current_surface.name]
        --log("Ice-Boxes")
        --log(serpent.block(ice_boxes))


        if(ice_boxes == nil) then 
          goto continue_surface_loop
        end 

        for i,v in pairs(ice_boxes) do
          if(v == nil or v.valid == false) then --If we messed up with the cache somehow.
            ice_box_cache = find_all_entity_of_name("ice-box")
            goto end_function
          end

          local inventory = v.get_inventory(defines.inventory.chest)
          local iceable_stacks = {}
          local contents = inventory.get_contents() --We have to dump the contents of the array to figure out how many item stacks we have to query
          local dry_ice_total = 0
          local first_available_dry_ice_key = "" --no longer necessary but I'll leave it in case I want to expand on it.
          local total_spoilable_stacks = 0
          local dry_ice_stacks = {}
          for j,c in pairs(contents) do --can't cut it short if we reach ice_able_array_length, items of different quality have the same stack name
            if(c.name == "dry-ice" ) then --can't check for values in an array -  at least efficiently. So I'll hardcode the items and stack size that I care about
              dry_ice_stacks["dry-ice" .. c.quality] = {item_count = c.count, stack_count = calculate_stack_count(c.count,500), base_name = "dry-ice", quality_name = c.quality}
              dry_ice_total = dry_ice_total + c.count

              iceable_stacks["dry-ice" .. c.quality] = {item_count = c.count, stack_count = calculate_stack_count(c.count,500), base_name = "dry-ice", quality_name = c.quality}
              --Need to remember it here too to rebuild the inventory properly
              if(first_available_dry_ice_key == "") then first_available_dry_ice_key="dry-ice" .. c.quality end
              
            elseif (c.name == "bioflux") then
              local sc = calculate_stack_count(c.count,100)
              iceable_stacks["bioflux" .. c.quality] = {item_count = c.count, stack_count = sc,base_name = "bioflux", quality_name = c.quality}
              total_spoilable_stacks = total_spoilable_stacks + sc
            elseif(c.name == "agricultural-science-pack") then
              local sc = calculate_stack_count(c.count,200)
              iceable_stacks["agricultural-science-pack" .. c.quality] = {item_count = c.count, stack_count = sc,base_name = "agricultural-science-pack", quality_name = c.quality}
              total_spoilable_stacks = total_spoilable_stacks + sc
            elseif(c.name == "biter-egg") then
              local sc = calculate_stack_count(c.count,100)
              iceable_stacks["biter-egg" .. c.quality] = {item_count = c.count, stack_count = sc,base_name = "biter-egg", quality_name = c.quality}
              total_spoilable_stacks = total_spoilable_stacks + sc
            elseif(c.name == "pentapod-egg") then
              local sc = calculate_stack_count(c.count,20)
              iceable_stacks["pentapod-egg" .. c.quality] = {item_count = c.count, stack_count = sc,base_name = "pentapod-egg", quality_name = c.quality}
              total_spoilable_stacks = total_spoilable_stacks + sc
            elseif(c.name == "raw-fish") then
              local sc = calculate_stack_count(c.count,100) --if this is incorrect, we will actually crash 
              iceable_stacks["raw-fish" .. c.quality] = {item_count = c.count, stack_count = sc,base_name = "raw-fish", quality_name = c.quality}
              total_spoilable_stacks = total_spoilable_stacks + sc

            else
              --local a = 1 --Do a dummy operation, not sure if else statement is required. Just having nil threw an error. I'll leave this empty for now and hope I don't need a pass statement like in Python
            end
          end

          --log("dry-ice total="..dry_ice_total)

          --log("iceable_stacks:")  
          --log(serpent.block(iceable_stacks))
          
          if( dry_ice_total == 0 or table_size(dry_ice_stacks) == 0 or table_size(iceable_stacks) == 0) then
            goto end_function --No cooling power or things to cool, we done.
          else
             --Substract total_spoilable_stacks from dry ice durability or count, Lets go with item count
            
            --local first_dry_ice_item_count = dry_ice_stacks[first_available_dry_ice_key]["item_count"]
            --local new_dry_ice_count = first_dry_ice_item_count - total_spoilable_stacks
            --log("first_dry_ice_item_count="..first_dry_ice_item_count)
            --log("new_dry_ice_count="..new_dry_ice_count)
            --log("total_spoilable_stacks="..total_spoilable_stacks)

            --TODO consider goto statement if surface = aquillo
            --if(new_dry_ice_count > 0 ) then
              --dry_ice_stacks[first_available_dry_ice_key]["item_count"] = new_dry_ice_count
              --iceable_stacks[first_available_dry_ice_key]["item_count"] = new_dry_ice_count --to properly rebuild the inventory
            --else
              --dry_ice_stacks[first_available_dry_ice_key] = nil --remove the item from this array.
              --iceable_stacks[first_available_dry_ice_key]["item_count"] = nil 
            --end
          end
          --log("dry_ice_stacks")
          --log(serpent.block(dry_ice_stacks))
          local rebuilt_inventory = {} 

          --for each item stack in the inventory
          --grab it, adjust spoilable as needed, save it, then remove it.

          local handled_dry_ice_count = false  
          for h,iceable in pairs(iceable_stacks) do --We put the dry ice in here so we can remember its
            local times_to_iterate = iceable_stacks[h]["stack_count"]
            --log("h="..h)
            --log("iceable=")
            --log(serpent.block(iceable))
            local iter = 0
            while (iter < times_to_iterate) do
              local item_stack = inventory.find_item_stack({name = iceable_stacks[h]["base_name"] , quality = iceable_stacks[h]["quality_name"] })
              --log("-----")
              --log("iter="..iter)
              --log("item_stack")
              --log(serpent.block(item_stack))
              --log("-----")
              --
              --log("OLD_spoil_tick_time="..spoil_tick_time)
              local count_offset = 0; --handle using dry ise for cooling power

              local spoil_percent= item_stack.spoil_percent
              if(item_stack.spoil_percent >= 0.5 and iceable_stacks[h]["base_name"] ~= "dry-ice") then
                spoil_percent = spoil_percent - 0.002 --Can't seem to get spoilage percentage with tick calculations correct. So I'll slowlly decrease the spoil percentage to 0.5
              end

              if(handled_dry_ice_count == false and iceable_stacks[h]["base_name"] == "dry-ice" and current_surface.name ~= "aquilo" ) then
                count_offset = math.floor(total_spoilable_stacks/4) + 1
                handled_dry_ice_count = true
              elseif(handled_dry_ice_count == false and current_surface.name == "aquilo" ) then
                handled_dry_ice_count = true
              elseif(handled_dry_ice_count == false and current_surface.name == "frozeta" ) then
                handled_dry_ice_count = true
              end

              
              if(spoil_percent < 0) then
                spoil_percent = 0.01
              end


              rebuilt_inventory[h..iter]= {name = item_stack.name, quality = item_stack.quality, count = item_stack.count - count_offset, spoil_percent = spoil_percent}
              inventory.remove(item_stack)
              iter = iter + 1
              
            end
          end
          
          --inventory.clear() --Ready to rebuild! --DOn't need to clear out everything
          --We put dry ice in iceable so we can get the spoil percentages.
          
          --for m, dry_ice in pairs(dry_ice_stacks) do
          --inventory.insert({name = dry_ice_stacks[m]["base_name"], count = dry_ice_stacks[m]["item_count"], quality = dry_ice_stacks[m]["quality_name"]})
          --end
          
          for r, refreshed_item in pairs(rebuilt_inventory) do
            --log("r="..r)
            --log("refreshed_item=")
            --log(serpent.block(refreshed_item))
            if refreshed_item["count"] > 0 then
              inventory.insert({ name= refreshed_item["name"],quality = refreshed_item["quality"], count =refreshed_item["count"], spoil_percent=refreshed_item["spoil_percent"] } ) 
            end 
          end
        end

        ::continue_surface_loop::
    end
    
    last_tick = current_tick --We are done, cache the last tick
    --log("--TICK END--")
    ::end_function::

    

  end

)

]]
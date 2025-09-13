--Code was originally spun off and greatly expanded from Nancy B + Exfret the wise, providing the original structure.
--Thanks CodeGreen for help sorting out horizontal splitters

local rubia_wind = {}

--#region Notifications
--Give a notice that an entity's config was changed. Input player index
local function wind_correction_notification(entity, player_index)
    if not player_index then return end --No player, no notice.
    local player = game.get_player(player_index)
    if not player then return end --No player, no notice.
    player.create_local_flying_text({text = {"alert.wind_correction_notification"}, position= entity.position, surface=player.surface})
    player.play_sound{path="utility/rotated_large", position=player.position, volume_modifier=1}
    player.play_sound{path="rubia-wind-short1", position=player.position, volume_modifier=1}
end

--Give notice that the wind blocked the placement of an entity. Input the player index
local function wind_block_notification(entity, player_index, message)
    if not player_index then return end --No player, no notice.
    if not entity or not entity.valid then return end --Entity is not valid. Can't do anything
    local player = game.get_player(player_index)
    if not player then return end --No player, no notice.

    if not message then message = "alert.wind_block_notification" end --Default
    player.create_local_flying_text({text = {message}, position= entity.position, surface=player.surface})
    player.play_sound{path="utility/cannot_build", position=player.position, volume_modifier=1}
    player.play_sound{path="rubia-wind-short1", position=player.position, volume_modifier=1}
end
--#endregion

--#region Inserters
--Given a valid adjustable inserter entity, apply adjustments that will work with adjustable inserter mods.
--Return true if an edit was made.
local function try_adjust_inserter(entity)
    local old_pickup_vector = {x=entity.pickup_position.x - entity.position.x, y=entity.pickup_position.y - entity.position.y}
    local old_drop_vector = {x=entity.drop_position.x - entity.position.x, y=entity.drop_position.y - entity.position.y}

    --If I don't fix the orientation, we get weird behavior when uninstalling
    entity.orientation = defines.direction.west
    entity.direction = defines.direction.west
    --First determine if any edit needs to be made:
    if old_pickup_vector.y == 0 and old_drop_vector.y ==0
        and old_pickup_vector.x <= 0 and old_drop_vector.x >= 0 then return false end

    --[[Show the issue
    game.print("Adjusting inserter with old pickup = (" .. old_pickup_vector.x .. "," .. old_pickup_vector.y
        .. "), old dropoff = (" .. old_drop_vector.x .. "," .. old_drop_vector.y .. ")"
        .. ". Checks: " .. serpent.block({old_pickup_vector.y == 0, old_drop_vector.y ==0 , old_pickup_vector.x <= 0 , old_drop_vector.x >= 0}))]]

    --keep the vector the same, but rotate it about the center of the inserter to make sure it goes left.
    entity.pickup_position = {x = entity.position.x - math.max(math.abs(old_pickup_vector.x), math.abs(old_pickup_vector.y)),
        y = entity.position.y}
    entity.drop_position = {x = entity.position.x + math.max(math.abs(old_drop_vector.x), math.abs(old_drop_vector.y)),
        y = entity.position.y}
    
    --local function vecstring(vec) return "(" .. vec.x .. "," .. vec.y .. ")" end
    --game.print("pos = " .. vecstring(entity.position) 
    --.. "\nold pickup = " .. vecstring(old_pickup_vector) .. "\n new pickup = " .. vecstring(entity.pickup_position)
    --.. "\nold drop = " .. vecstring(old_drop_vector) .. "\nnew drop = " .. vecstring(entity.drop_position) )
    
    return true
end


---Return true if the given unadjustable inserter is in a valid orientation.
---@param entity LuaEntity
---@return boolean
local function is_unadj_inserter_valid_orientation(entity)
    return entity.drop_position.x > entity.pickup_position.x + 0.5
end
--#endregion


--Dictionary of special cases to send different entity prototypes to specific wind behaviors.
--This takes priority over any prototype-type based calculations
local wind_entity_dic = {
    ["pumpjack"] = {wind_type = "free"},

    --Renai transportation
    ["DirectedBouncePlate"] =   {wind_type = "force-not", orient=defines.direction.west},
    ["DirectedBouncePlate5"] =   {wind_type = "force-not", orient=defines.direction.west},
    ["DirectedBouncePlate15"] = {wind_type = "force-not", orient=defines.direction.west},
    ["RTVacuumHatch"] =         {wind_type = "force-to", orient=defines.direction.west},
    ["RTThrower-EjectorHatchRT"] ={wind_type = "force-to", orient=defines.direction.west},
    ["RTRicochetPanel"] ={wind_type = "force-not-hashset", orient={[defines.direction.west]=true, [defines.direction.east]=true}},
    ["RTMergingChute"] ={wind_type = "force-not-hashset", orient={[defines.direction.west]=true, [defines.direction.south]=true}},
    ["RTItemCannon"] ={wind_type = "force-not-hashset", orient={[defines.direction.west]=true, [defines.direction.north]=true}},
    
    --{wind_type = "custom", custom = function(entity, player_index) ... end},
}

--Dictionary for prototype goes in, and a default wind-behavior comes out.
local wind_prototype_dic = {
    ["transport-belt"] = {wind_type = "force-not", orient=defines.direction.west},
    ["underground-belt"] = {wind_type = "force-not", orient=defines.direction.west},
    ["mining-drill"] = {wind_type = "force-not", orient=defines.direction.west},
    ["splitter"] = {wind_type = "splitter-like-to", orient=defines.direction.east},
    ["lane-splitter"] = {wind_type = "force-not", orient=defines.direction.west},
    ["loader"] = {wind_type = "splitter-like-to", orient=defines.direction.east},
    ["loader-1x1"] = {wind_type = "splitter-like-to", orient=defines.direction.east},
}

--Merge blacklist with the surface ban blacklist
--local prototype_blacklist = prototypes.mod_data["rubia-surface-blacklist"].data
--assert(prototype_blacklist and table_size(prototype_blacklist) > 5, "Another mod chose to delete Rubia's internal blacklist data, and caused a crash.")
local rubia_surface_blacklist = require("__rubia__.prototypes.data-script.rubia-surface-blacklist")
local prototype_blacklist = rubia_surface_blacklist.copy_blacklist_array()
for _, name in pairs(prototype_blacklist) do
    wind_entity_dic[name] =  {wind_type = "block"}
end

---Remove the last undo item from the given player index, if there is one.
---@param player_index uint?
local function squash_undo_actions(player_index)
    if not player_index then return end
    local player = game.players[player_index]
    if not player then return end
    local stack = player.undo_redo_stack

    --assert(stack.get_undo_item_count() > 1, "Fewer than 2 items on the undo stack!")

    if stack.get_undo_item_count() < 2 then return end
    local undo1 = stack.get_undo_item(1)
    local undo2 = stack.get_undo_item(2)

    if not undo1 or not undo2 then return end

    --Squash them together
    for _, action in pairs(undo1) do
        table.insert(undo2, action)
    end
    --Remove the last one
    stack.remove_undo_item(1)
end

--#region Making functions for wind correction. These assume valid entity.
---Force this entity's orientation to that direction.
---@param entity LuaEntity
---@param player_index uint?
local function force_orientation_to(entity, player_index, direction)
    if (entity.direction == direction) then return end
    wind_correction_notification(entity, player_index)
    for _ = 1, 3 do
        if entity.direction ~= direction then
            entity.rotate{by_player=player_index}
            squash_undo_actions(player_index)
        end
    end
end

--Force this entity to any orientation besides this one.
local function force_orientation_not(entity, player_index, direction)
    if entity.direction == direction then
        entity.rotate{by_player=player_index}
        squash_undo_actions(player_index)
        wind_correction_notification(entity, player_index)
    end
end

--[[Force this entity to any orientation except any of those in the hashset
local function force_orientation_not_hashset(entity, player_index, directions)
    if not directions[entity.direction] then return end --Done without issues
    wind_correction_notification(entity, player_index)

    for _ = 1,12,1 do
        if (not directions[entity.direction]) then return end --Happy
        entity.rotate{by_player=player_index}
    end
    
    error("Could not find an allowed orientation for an entity of type: " .. entity.prototype.name)
end]]

---Force this entity to any orientation until the input function returns TRUE on the entity.
---@param entity LuaEntity
---@param player_index any
---@param orientation_validator function Takes in a LuaEntity, and returns TRUE if the orientation is valid.
local function force_orientation_condition(entity, player_index, orientation_validator)
    if orientation_validator(entity) then return end --Done without issues
    
    for _ = 1,12,1 do
        if orientation_validator(entity) then 
            wind_correction_notification(entity, player_index);
            return end --Happy
        --game.print("Before: " .. tostring(game.players[player_index].undo_redo_stack.get_undo_item_count()))
        entity.rotate{by_player=player_index}
        --game.print("After: " .. tostring(game.players[player_index].undo_redo_stack.get_undo_item_count()))
        squash_undo_actions(player_index)
    end
    
    local true_type = (entity.type == "entity-ghost") and entity.ghost_type or entity.type
    error("Could not find an allowed orientation for an entity of type: " .. entity.prototype.name .. ", True type: " .. true_type)
end

--Force this entity to any orientation except any of those in the hashset
local function force_orientation_not_hashset(entity, player_index, directions)
    force_orientation_condition(entity, player_index, function(input_entity)
        return not directions[input_entity.direction] end)
end

--[[Force this unadjustable inserter to a valid orientation
local function force_orientation_unadj_inserter(entity, player_index)
    force_orientation_condition(entity, player_index, is_unadj_inserter_valid_orientation)
end]]

--Try to mine the given entity when placed by the given player_index
local function try_mine(entity, player_index)
    if entity.type == "entity-ghost" then entity.mine()
    else --Must mine real entity
        if player_index then game.get_player(player_index).mine_entity(entity, true) 
        else --Not placed by a player, so try to spill on the floor.
            local item = entity.prototype.items_to_place_this and entity.prototype.items_to_place_this[1]
            if item then --Only spill if something actually places this item.
                entity.surface.spill_item_stack {
                    position = entity.position,
                    stack = item,
                    enable_looted = true,
                    force = entity.force_index,
                    allow_belts = false
                }
            end
            entity.destroy()
        end
    end
end

--Force this entity to a specific orientation, but if it is placed orthogonal to the wind,
--then block its placement.
local function force_splitter_like_orientation_to(entity, player_index, direction)
    if entity.direction == direction then return end

    --If one rotation gets this entity to the right state, then we're good to just give notice.
    entity.rotate{by_player=player_index} --Do not raise event, because that causes an infinite loop
    squash_undo_actions(player_index)
    if entity.direction == direction then
        wind_correction_notification(entity, player_index)
        return
    end

    --otherwise, we can't reconcile it, and must mine it!
    wind_block_notification(entity, player_index, "alert.wind_block_notification")
    try_mine(entity, player_index)
end

--Try mine an entity, but set on a delay
rubia.timing_manager.register("try-mine-entity", function(entity, player_index)
    if entity and entity.valid then
        wind_block_notification(entity, player_index, "alert.wind_full_block_notification")
        try_mine(entity, player_index)
    end
    if entity and entity.valid then entity.active = false end --Just in case
end)
--An entity is being placed on Rubia that should not be placed. Block it.
local function block_entity_placement(entity, player_index)
    rubia.timing_manager.wait_then_do(1, "try-mine-entity", {entity, player_index})
    if entity and entity.valid then entity.active = false end --Just in case
end


--#region Renai
--Special case for thrower inserters, to adjust their orientation and trajectory
remote.add_interface("rubia-thrower-trajectories", {
    sinusoid = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = thrower.position, thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 
        
        local path = {}
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / total_ticks-- + 0.00001
            table.insert(path, {
                x=start_pos.x + dimensionless_time * delta_x,
                y = start_pos.y + dimensionless_time * delta_y 
                    + 2 * math.sin(3 * 2 * 3.14159 * dimensionless_time),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            })
        end
        --game.print(serpent.block(path))
        return path
    end,

    corkscrew = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = thrower.position, thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 
        
        local path = {}
        local revolutions = math.min(4, math.max(2, math.floor(delta_x / 4)))
        local radius = math.min(1.5, math.max(0.5, delta_x / 5))
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / total_ticks-- + 0.00001
            local theta = 2 * 3.14159 * revolutions * dimensionless_time
            table.insert(path, {
                x= start_pos.x + dimensionless_time * delta_x
                    + radius * math.cos(theta) - radius,
                y = start_pos.y + dimensionless_time * delta_y 
                    + radius * math.sin(theta),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            })
        end
        --game.print(serpent.block(path))
        return path
    end
})
local function force_thrower_orientation(entity, player_index)
    force_orientation_to(entity, player_index, defines.direction.west)

    --[[not ready yet. WIP
    --Make funny trajectory
    if remote.interfaces["RenaiTransportation"] then
        local delta_x = math.abs(entity.drop_position.x - entity.position.x)
        if delta_x > 5 then
            local trajectory = {type="interface", interface="rubia-thrower-trajectories", 
                name = "corkscrew",--name="sinusoid",
                parameters={start_pos = entity.position, end_pos = entity.drop_position}}

            remote.call("RenaiTransportation", "SetTrajectoryAdjust", entity, trajectory)
        else
            remote.call("RenaiTransportation", "ClearTrajectoryAdjust", entity)
        end
    end]]
end
--Special cases for compatibility with Renai
--local force_thrower_orientation
for _, prototype in pairs(prototypes.entity) do
    --Throwers must be rotated
    if (string.find(prototype.name, "RTThrower")) then 
        wind_entity_dic[prototype.name] = {wind_type = "custom", custom = force_thrower_orientation}
        --wind_entity_dic[prototype.name] = {wind_type = "force-to", orient=defines.direction.west} --Old version. Works until new interface
    end
end
--#endregion


--Parse wind behavior table to code in a specific function.
local function wind_behavior_to_function(wind_behavior)
    --Free = null function
    if wind_behavior.wind_type == "free" then return nil end
    if wind_behavior.wind_type == "custom" then return wind_behavior.custom end

    if wind_behavior.wind_type == "force-to" then 
        return function(entity, player_index)
            return force_orientation_to(entity, player_index, wind_behavior.orient) end
    elseif wind_behavior.wind_type == "force-not" then
        return function(entity, player_index)
            return force_orientation_not(entity, player_index, wind_behavior.orient) end
    elseif wind_behavior.wind_type == "force-not-hashset" then 
        return function(entity, player_index)
            return force_orientation_not_hashset(entity, player_index, wind_behavior.orient) end
    elseif wind_behavior.wind_type == "splitter-like-to" then 
        return function(entity, player_index)
            return force_splitter_like_orientation_to(entity, player_index, wind_behavior.orient) end
    elseif wind_behavior.wind_type == "block" then 
        return function(entity, player_index) 
            return block_entity_placement(entity, player_index) end
    end

    error("Invalid wind behavior: " .. serpent.block(wind_behavior))
end

--Make wind behavior dictionaries to return functions
local wind_entity_functions, wind_prototype_functions = {}, {}
for name, wind_behavior in pairs(wind_entity_dic) do
    wind_entity_functions[name] = wind_behavior_to_function(wind_behavior)
end
for name, wind_behavior in pairs(wind_prototype_dic) do
    wind_prototype_functions[name] = wind_behavior_to_function(wind_behavior)
end
--#endregion


--Wind mechanic: Restricting the directions of specific items. Entity passed in could be invalid.
--Code modified from Nancy B + Exfret the wise.
--Thanks to CodeGreen, for help sorting out horizontal splitters
--Warning: Player index could be nil
local function wind_correction(entity, player_index)
    if  not entity or not entity.valid
        or entity.surface.name ~= "rubia" then return end

    local entity_type = entity.type;
    if entity.type == "entity-ghost" then entity_type = entity.ghost_type end

    --Put a lock on responding to repeat rotation event callbacks.
    if storage.rubia_wind_callback_lock then return 
    else storage.rubia_wind_callback_lock = true
    end

    --Check wind behaviors. Prioritize specific entity, then prototype if relevant
    local behavior = wind_entity_functions[entity.prototype.name] or wind_prototype_functions[entity_type]    
    if behavior then
        behavior(entity, player_index); 
        storage.rubia_wind_callback_lock = false
        return
    end

    --Inserters are their own beast.
    --Rotate relevant items to not conflict with wind
    if entity_type == "inserter" then
        local true_prototype = entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
        if true_prototype.allow_custom_vectors then
            if try_adjust_inserter(entity) then 
                wind_correction_notification(entity, player_index)
            end
        else force_orientation_condition(entity, player_index, is_unadj_inserter_valid_orientation)
        end
    end

    --Undo the lock
    storage.rubia_wind_callback_lock = false
end

---Wind correction with more general timing.

---Correct the entities at the given position, placed by the given player.
---@param search_area data.BoundingBox
---@param player_index uint
local function wind_correct_position(search_area, player_index)
    if not storage.rubia_surface then return end
    local player_force_index = game.players[player_index].force_index
    local entities = storage.rubia_surface.find_entities(search_area)
    --local entities = storage.rubia_surface.find_entities({{map_position.x, map_position.y},{map_position.x, map_position.y}})
    for _, entity in pairs(entities) do
        if entity.valid and entity.force_index == player_force_index then
            wind_correction(entity, player_index)
        end
    end
end
rubia.timing_manager.register("wind-correct-position", wind_correct_position)


--Consistency check and correct whole Rubia surface. Super expensive!
local function global_wind_correction()
    if not storage.rubia_surface then return end
    local entities = storage.rubia_surface.find_entities()
    for _, entry in pairs(entities) do wind_correction(entry, nil) end
end

--#region Events
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_built("wind-correction", wind_correction)
event_lib.on_entity_gui_update("wind-correction", wind_correction)

event_lib.on_event({defines.events.on_player_flipped_entity, defines.events.on_player_rotated_entity},
  "wind-correction", function(event) 
    wind_correction(event.entity, event.player_index) end)
event_lib.on_event(defines.events.on_entity_settings_pasted,
  "wind-correction", function(event)
    wind_correction(event.destination, event.player_index) end)

--event_lib.on_configuration_changed("global-wind-correction", global_wind_correction)

--#region Force build bug workaround
local bplib = require("__rubia__.lib.bplib-blueprint")
local BlueprintBuild = bplib.BlueprintBuild

--This is needed for the current super force build bug.
event_lib.on_event(defines.events.on_pre_build,
  "wind-correction", function(event)
    local player = game.players[event.player_index]
    if storage.rubia_surface and player.surface_index == storage.rubia_surface.index 
        and event.build_mode == defines.build_mode.superforced then
            local bounding_box
            if not player.is_cursor_blueprint() then 
                bounding_box = {{event.position.x, event.position.y},{event.position.x, event.position.y}}
            else 
                local bp_build = BlueprintBuild:new(event)
                bounding_box = bp_build:make_blueprint_bounding_box()
            end

        rubia.timing_manager.wait_then_do(1, "wind-correct-position", {bounding_box, event.player_index})
    end
end)
--#endregion

--Special events for weird mods, especially adjustable inserters

--QAI events
if script.active_mods["quick-adjustable-inserters"] then
  script.on_event({defines.events.on_qai_inserter_direction_changed,  --defines.events.on_qai_inserter_vectors_changed, 
      defines.events.on_qai_inserter_adjustment_finished}, function(event)
    wind_correction(event.inserter, event.player_index) 
  end)
end

--Renai transportation: Focused flinging event calls.
if script.active_mods["RenaiTransportation"] then
    script.on_event({"RTtcaretnI", "RTInteract"}, function(event)
        local player = event.player_index and game.players[event.player_index]
        if not player.surface or player.surface.name ~= "rubia" then return end --wrong surface
        local entity = player.selected
        if entity and entity.valid then
            wind_correction(entity, player_index)
        end
        --local search_area = --local spot = event.cursor_position
        --wind_correct_position(search_area, player_index)
    end
)


    
end

--#endregion


return rubia_wind


--[[
--Special cases for compatibility
for _, prototype in pairs(prototypes.entity) do
    --Throwers must be rotated
    if (string.find(prototype.name, "RTThrower")) then 
        wind_entity_dic[prototype.name] = {wind_type = "force-to", orient=defines.direction.west}
    end
end


---Make list of thrower inserters
local thrower_inserter_names = {}
if script.active_mods["RenaiTransportation"] then
    for _, prototype in pairs(prototypes.entity) do
        if prototype.type == "inserter"
            and prototypes.get_history(prototype.type, prototype.name).created == "RenaiTransportation"
            and string.find(prototype.name, "RTThrower") then
            table.insert(thrower_inserter_names, prototype.name)
        end 
    end
end
remote.add_interface("RenaiTransportation", {
]]


--[[This is the previous version of the wind mechanic, for posterity.
--Restricting the directions of specific items. Entity passed in could be invalid.
--Code modified from Nancy B + Exfret the wise.
--Thanks to CodeGreen, for help sorting out horizontal splitters
--Warning: Player index could be nil
rubia_wind.wind_rotation = function(entity, player_index)
    --game.print(entity.type)

    if entity.surface.name ~= "rubia" or not entity or not entity.valid then
        do return end
    end

    local entity_type = entity.type;
    if entity.type == "entity-ghost" then entity_type = entity.ghost_type end

    --Rotate relevant items to not conflict with wind
    if entity_type == "inserter" then
        if entity.prototype.allow_custom_vectors then
            if try_adjust_inserter(entity) then 
                wind_correction_notification(entity, player_index)
            end
        elseif (entity.direction ~= defines.direction.west) then
            wind_correction_notification(entity, player_index)
            for _ = 1, 3 do
                if entity.direction ~= defines.direction.west then entity.rotate() end
            end
        end
    elseif entity.type == "underground-belt" and entity.direction == defines.direction.west then
        entity.rotate(); wind_correction_notification(entity, player_index)

    --Do not allow to go left.
    elseif (entity_type == "transport-belt" or (entity_type == "mining-drill" and entity.prototype.name ~= "pumpjack")) 
            and entity.direction == defines.direction.west then
        entity.rotate(); wind_correction_notification(entity, player_index)
        
    elseif entity_type == "splitter" then
        if entity.direction == defines.direction.east then do return end
        elseif entity.direction == defines.direction.west then
            entity.rotate(); wind_correction_notification(entity, player_index)
        --Case of horizontal splitters, we need a refund
        else 
            if entity.type == "entity-ghost" then entity.mine()
            else 
                wind_block_notification(entity, player_index)
                if player_index then game.get_player(player_index).mine_entity(entity, true) 
                else error("splitter going down wouldn't get mined!")
                end
            end
        end
    end
end]]

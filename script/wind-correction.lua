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
local function wind_block_notification(entity, player_index)
    if not player_index then return end --No player, no notice.
    local player = game.get_player(player_index)
    if not player then return end --No player, no notice.
    player.create_local_flying_text({text = {"alert.wind_block_notification"}, position= entity.position, surface=player.surface})
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

--#region Making functions for wind correction. These assume valid entity.
---Force this entity's orientation to that direction.
---@param entity LuaEntity
---@param player_index uint?
local function force_orientation_to(entity, player_index, direction)
    if (entity.direction == direction) then return end
    wind_correction_notification(entity, player_index)
    for _ = 1, 3 do
        if entity.direction ~= direction then entity.rotate{by_player=player_index} end
    end
end

--Force this entity to any orientation besides this one.
local function force_orientation_not(entity, player_index, direction)
    if entity.direction == direction then
        entity.rotate{by_player=player_index}
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
        entity.rotate{by_player=player_index}
    end
    
    error("Could not find an allowed orientation for an entity of type: " .. entity.prototype.name)
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


--Force this entity to a specific orientation, but if it is placed orthogonal to the wind,
--then block its placement.
local function force_splitter_like_orientation_to(entity, player_index, direction)
    if entity.direction == direction then return end

    --If one rotation gets this entity to the right state, then we're good to just give notice.
    entity.rotate{by_player=player_index} --Do not raise event, because that causes an infinite loop
    if entity.direction == direction then
        wind_correction_notification(entity, player_index)
        return
    end

    --otherwise, we can't reconcile it, and must mine it!
    wind_block_notification(entity, player_index)
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
            --error("Splitter-like entity going down wouldn't get mined!")
        end
    end
end


--Special case for thrower inserters, to adjust their orientation and trajectory
remote.add_interface("rubia-thrower-trajectories", {
    trajectory_function = function(parameters, total_ticks)
        local start_pos, end_pos = parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 
        
        local path = {}
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / total_ticks
            table.insert(path, {
                x=start_pos.x + dimensionless_time * delta_x,
                y = start_pos.y + dimensionless_time * delta_y 
                    + 2 * math.sin(2 * 3.14159 / dimensionless_time),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            })
        end
        --game.print(serpent.block(path))
        return path
    end
})
local function force_thrower_orientation(entity, player_index)
    force_orientation_to(entity, player_index, defines.direction.west)
    if remote.interfaces["RenaiTransportation"] then
        local trajectory = {type="interface", interface="rubia-thrower-trajectories", name="trajectory_function",
            parameters={start_pos = entity.position, end_pos = entity.drop_position}}

        remote.call("RenaiTransportation", "SetTrajectoryAdjust", entity, trajectory)
    end
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
rubia_wind.wind_rotation = function(entity, player_index)
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
        if entity.prototype.allow_custom_vectors then
            if try_adjust_inserter(entity) then 
                wind_correction_notification(entity, player_index)
            end
        else force_orientation_condition(entity, player_index, is_unadj_inserter_valid_orientation)
            --force_orientation_to(entity, player_index, defines.direction.west)
        end
    end

    --Undo the lock
    storage.rubia_wind_callback_lock = false
end


--#region Events
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_built("wind-rotation", rubia_wind.wind_rotation)
event_lib.on_entity_gui_update("wind-rotation", rubia_wind.wind_rotation)

event_lib.on_event({defines.events.on_player_flipped_entity, defines.events.on_player_rotated_entity},
  "wind-rotation", function(event) 
    rubia_wind.wind_rotation(event.entity, event.player_index) end)
event_lib.on_event(defines.events.on_entity_settings_pasted,
  "wind-rotation", function(event)
    rubia_wind.wind_rotation(event.destination, event.player_index) end)



--Special events for weird mods, especially adjustable inserters

--QAI events
if script.active_mods["quick-adjustable-inserters"] then
  script.on_event({defines.events.on_qai_inserter_direction_changed,  --defines.events.on_qai_inserter_vectors_changed, 
      defines.events.on_qai_inserter_adjustment_finished}, function(event)
    rubia_wind.wind_rotation(event.inserter, event.player_index) 
  end)
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

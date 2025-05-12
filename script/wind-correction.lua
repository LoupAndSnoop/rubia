--_G.rubia = _G.rubia or {}

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

--Given a valid adjustable inserter entity, apply adjustments that will work with adjustable inserter mods.
--Return true if an edit was made.
local function try_adjust_inserter(entity)
    local old_pickup_vector = {x=entity.pickup_position.x - entity.position.x, y=entity.pickup_position.y - entity.position.y}
    local old_drop_vector = {x=entity.drop_position.x - entity.position.x, y=entity.drop_position.y - entity.position.y}

    entity.orientation = defines.direction.west --If I don't fix the orientation, we get weird behavior when uninstalling

    --First determine if any edit needs to be made:
    if old_pickup_vector.y == 0 and old_drop_vector.y ==0
        and old_pickup_vector.x <= 0 and old_drop_vector.x >= 0 then return false end

    --keep the vector the same, but rotate it about the center of the inserter to make sure it goes left.
    --log(serpent.block(entity) .. "\npickup = " .. serpent.block(old_pickup_vector) .. "\ndropoff = " .. serpent.block(old_drop_vector) )
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


---TODO: Not implemented yet.
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
    ["loader"] = {wind_type = "splitter-like-to", orient=defines.direction.east},
}

--Special cases for compatibility
for _, prototype in pairs(prototypes.entity) do
    --Throwers must be rotated
    if (string.find(prototype.name, "RTThrower")) then 
        wind_entity_dic[prototype.name] = {wind_type = "force-to", orient=defines.direction.west}
    end
end

--#region Making functions for wind correction. These assume valid entity.
--Force this entity's orientation to that direction.
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

--Force this entity to any orientation except any of those in the hashset
local function force_orientation_not_hashset(entity, player_index, directions)
    if not directions[entity.direction] then return end --Done without issues
    wind_correction_notification(entity, player_index)

    for _ = 1,12,1 do
        if (not directions[entity.direction]) then return end --Happy
        entity.rotate{by_player=player_index}
    end
    
    error("Could not find an allowed orientation for an entity of type: " .. entity.prototype.name)
end

--Force this entity to a specific orientation, but if it is placed orthogonal to the wind,
--then block its placement.
local function force_splitter_like_orientation_to(entity, player_index, direction)
    if entity.direction == direction then return end

    --If one rotation gets this entity to the right state, then we're good to just give notice.
    entity.rotate() --Do not raise event, because that causes an infinite loop
    if entity.direction == direction then
        wind_correction_notification(entity, player_index)
        return
    end

    --otherwise, we can't reconcile it, and must mine it!
    if entity.type == "entity-ghost" then entity.mine()
    else 
        wind_block_notification(entity, player_index)
        if player_index then game.get_player(player_index).mine_entity(entity, true) 
        else error("Splitter-like entity going down wouldn't get mined!")
        end
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
    if  not entity or not entity.valid or entity.surface.name ~= "rubia" then return end

    local entity_type = entity.type;
    if entity.type == "entity-ghost" then entity_type = entity.ghost_type end

    --Check wind behaviors. Prioritize specific entity, then prototype if relevant
    local behavior = wind_entity_functions[entity.prototype.name] or wind_prototype_functions[entity_type]    
    if behavior then behavior(entity, player_index); return end

    --Inserters are their own beast.
    --Rotate relevant items to not conflict with wind
    if entity_type == "inserter" then
        if entity.prototype.allow_custom_vectors then
            if try_adjust_inserter(entity) then 
                wind_correction_notification(entity, player_index)
            end
        else force_orientation_to(entity, player_index, defines.direction.west)
        end
    end
end

--[[Wind mechanic: Restricting the directions of specific items. Entity passed in could be invalid.
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

return rubia_wind
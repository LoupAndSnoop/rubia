--_G.rubia = _G.rubia or {}

local rubia_wind = {}

--#region Notifications
--Give a notice that an entity's config was changed. Input player index
local function wind_correction_notification(entity, player_index)
    local player = game.get_player(player_index)
    if not player then return end --No player, no notice.
    player.create_local_flying_text({text = {"alert.wind_correction_notification"}, position= entity.position, surface=player.surface})
    player.play_sound{
        path="utility/rotated_large",
        position=player.position,
        volume_modifier=1
    }
end

--Give notice that the wind blocked the placement of an entity. Input the player index
local function wind_block_notification(entity, player_index)
    local player = game.get_player(player_index)
    player.create_local_flying_text({text = {"alert.wind_block_notification"}, position= entity.position, surface=player.surface})
    player.play_sound{
        path="utility/cannot_build",
        position=player.position,
        volume_modifier=1
    }
end
--#endregion

--Given a valid adjustable inserter entity, apply adjustments that will work with adjustable inserter mods.
--Return true if an edit was made.
local function try_adjust_inserter(entity)
    local old_pickup_vector = {x=entity.pickup_position.x - entity.position.x, y=entity.pickup_position.y - entity.position.y}
    local old_drop_vector = {x=entity.drop_position.x - entity.position.x, y=entity.drop_position.y - entity.position.y}

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



--Wind mechanic: Restricting the directions of specific items. Entity passed in could be invalid.
--Code modified from Nancy B + Exfret the wise.
--Thanks to CodeGreen, for help sorting out horizontal splitters
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
        entity.rotate()
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
                local player = game.get_player(player_index)
                player.mine_entity(entity, true)
                --[[player.play_sound{
                    path="utility/cannot_build",
                    position=player.position,
                    volume_modifier=1
                }]]
            end
        end
    end
end

return rubia_wind
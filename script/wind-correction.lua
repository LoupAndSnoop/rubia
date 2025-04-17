_G.rubia = _G.rubia or {}


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

--Wind mechanic: Restricting the directions of specific items
--Code modified from Nancy B + Exfret the wise.
--Thanks to CodeGreen, for help sorting out horizontal splitters
rubia.wind_rotation = function(entity, event)
    --game.print(entity.type)

    if entity.surface.name ~= "rubia" or not entity.valid then
        do return end
    end

    local entityType = entity.type;
    if entity.type == "entity-ghost" then entityType = entity.ghost_type end

    --Rotate relevant items to not conflict with wind
    if entityType == "inserter" and (entity.direction ~= defines.direction.west) then
        wind_correction_notification(entity, event.player_index)
        for _ = 1, 3 do
            if entity.direction ~= defines.direction.west then entity.rotate() end
        end
    elseif entity.type == "underground-belt" and entity.direction == defines.direction.west then
        entity.rotate(); wind_correction_notification(entity, event.player_index)
    elseif entityType == "transport-belt" and entity.direction == defines.direction.west then
        entity.rotate()
        entity.rotate(); wind_correction_notification(entity, event.player_index)
    else if entityType == "splitter" then
            if entity.direction == defines.direction.east then do return end
            elseif entity.direction == defines.direction.west then
                entity.rotate(); wind_correction_notification(entity, event.player_index)
            --Case of horizontal splitters, we need a refund
            else 
                if entity.type == "entity-ghost" then entity.mine()
                else 
                    local player = game.get_player(event.player_index)
                    player.mine_entity(entity, true)
                    wind_block_notification(entity, event.player_index)
                    --[[player.play_sound{
                        path="utility/cannot_build",
                        position=player.position,
                        volume_modifier=1
                    }]]
                end
            end
        end
    end
end

require("lib.timing-manager")
local util = require("util")

--Dictionary of ["player_index"] => array of event_id strings for the sub-cutscene events.
storage.active_cutscenes = storage.active_cutscenes or {}
--storage.player_characters = storage.player_characters or {}

--Cancel the cutscene currently playing for the player.
---@param player LuaPlayer
local function cancel_cutscene(player)
    --game.print("Cancelling: " .. serpent.block(storage.active_cutscenes[tostring(player.index)]))
    rubia.timing_manager.dequeue_events(storage.active_cutscenes[tostring(player.index)])
    storage.active_cutscenes[tostring(player.index)] = nil
    if (player.controller_type == defines.controllers.cutscene) then 
        player.exit_cutscene() end
end

--I need to make a script to go through the player's equipment grid, and change the shield.
local function set_character_shields(character, new_total_shield_value)
    if (not character.grid or not character.grid.valid) then return end --Nothing to do
    local remaining_total_shield = new_total_shield_value
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
        and equip.max_shield > 0) then
            equip.shield = math.min(remaining_total_shield, equip.max_shield)
            remaining_total_shield = remaining_total_shield - equip.shield
        end
    end
end


--Try to damage the player during the cutscene, but return control if the player is about to die.
local function cutscene_damage(character, player, damage)
    --I don't have a function to account for resistances from mod armor.
    --First do shield damage, if applicable.
    if character.grid and character.grid.valid then
        local ending_shield = math.max(0, character.grid.shield - damage)
        damage = damage - (character.grid.shield - ending_shield) --Damage soaked up
        set_character_shields(character, ending_shield)
    end

    --We are about to kill the player. Give back control
    if (character.health <= damage) and (player.controller_type == defines.controllers.cutscene) then 
        player.exit_cutscene()
        character.die(game.forces["enemy"])
    else 
        character.damage(damage,game.forces["enemy"]) --Otherwise just hurt him
    end
end

--Start the cutscene for the given player. Return an array of all the relevant event_id to be able to cancel it later.
---@param player LuaPlayer
local function start_cutscene(player)
    local event_ids = {}
    --game.print("Starting, active cutscene for player " .. serpent.block(player) .. " is ".. serpent.block(storage.active_cutscenes))--[player]))
    cancel_cutscene(player)

    --game.print("start tick = " .. tostring(game.tick))

    local cargo_pod = player.cargo_pod
    local character = cargo_pod.get_passenger()

    --TODO: I need my character reference. This isn't good enough
    --local character = player.character or player.cutscene_character
    assert(character, "Character not found.")

    --[[
    --Note: This destroys the background for the cutscene
    player.set_controller{type=defines.controllers.cutscene,
        character=character,
        waypoints={{target=cargo_pod, time_to_wait = 999999, transition_time = 0}}} --start_position?=…, 
        --start_zoom?=…, final_transition_time?=…, chart_mode_cutoff?=…,
        --position?=…, surface?=…}
    ]]

    --Bring character to max HP and full shields before we start, in case of jank
    character.health = character.max_health
    if (character.grid and character.grid.valid
        and ((character.grid.max_solar_energy + character.grid.get_generator_energy()) > 0)) then
        set_character_shields(character, character.grid.max_shield)
    end
        
    --NOTE: I measured the actual descent cutscene (from player changed surface invocation
    --to actually landing) is 599 ticks. Some of this is a slow descent animation,
    --which seems to start at 

    table.insert(event_ids, rubia.timing_manager.wait_then_do(5, function()
        player.play_sound{
            path="utility/cannot_build",
            position=player.position,
            volume_modifier=1
        }
        
    end))

    table.insert(event_ids, rubia.timing_manager.wait_then_do(60, function()
        player.play_sound{
            path="utility/rotated_large",
            position=player.position,
            volume_modifier=1
        }
        game.print({"alert.landing-cutscene-part1"}, {color={r=0.9,g=0,b=0,a=1}})
        cutscene_damage(character, player, 30)
    end))

    table.insert(event_ids, rubia.timing_manager.wait_then_do(200, function()
        player.play_sound{
            path="utility/rotated_large",
            position=player.position,
            volume_modifier=1
        }
        game.print({"alert.landing-cutscene-part2"}, {color={r=0.9,g=0,b=0,a=1}})
        cutscene_damage(character, player, 70)
    end))

    table.insert(event_ids, rubia.timing_manager.wait_then_do(300, function()
        player.play_sound{
            path="utility/rotated_large",
            position=player.position,
            volume_modifier=1
        }
        game.print({"alert.landing-cutscene-part3"}, {color={r=0.9,g=0,b=0,a=1}})
        cutscene_damage(character, player, 110)
    end))

    --End of the cutscene
    table.insert(event_ids, rubia.timing_manager.wait_then_do(480, function()
        player.play_sound{
            path="utility/cannot_build",
            position=player.position,
            volume_modifier=1
        }

        --cargo_pod.on_cargo_pod_finished_descending()
        --TODO: Explosion
        cargo_pod.force_finish_descending()
        cargo_pod.destroy()
        --if player and player.cargo_pod and player.cargo_pod.valid then player.cargo_pod.destroy() end

        cutscene_damage(character, player, 400)

        --Make sure a surviving player is damaged at least a little to their base HP, without killing
        if (character) then 
            character.health = math.min(math.random(3, 200), character.health)
        end

        cancel_cutscene(player)
    end))

    --[[- Emergency failsafe: Make sure we exit cutscene mode
    table.insert(event_ids, rubia.timing_manager.wait_then_do(1000, function()
        --cancel_cutscene(player)
        if (player.controller_type == defines.controllers.cutscene) then 
            player.exit_cutscene() end
    end))]]

    storage.active_cutscenes[tostring(player.index)] = event_ids--util.table.deepcopy(event_ids)--event_ids
    return event_ids
end

--#region External handles to start/end cutscene via events.

--Variable to store exposed cutscene functions
local landing_cutscene = {}


--Run cutscene if player lands
--See if we need to start a cutscene on a defines.events.on_player_changed_surface event.
landing_cutscene.try_start_cutscene = function(event)
    local player = game.get_player(event.player_index)
    local surface = game.get_surface(event.surface_index)

    --First, we need to check that we are going from a space platform down to rubia.
    if (not surface --Prev surface destroyed/deleted?
        or not surface.platform --Old surface was not a platform
        or player.surface.name ~= "rubia") then--new surface is not the right planet

        game.print("cancel cutscene")
        return
    end

    --Operation iron man cancels cutscene.
    if (player.force.technologies["planetslib-rubia-cargo-drops"].researched) then
        game.print("cancelling from operation iron man")
        return end
    
    --Secondary check based on the cargo pod
    local cargo_pod = player.cargo_pod
    --game.print("stats = " .. serpent.block(cargo_pod.cargo_pod_state)
    --.. ", destination = " .. serpent.block(cargo_pod.cargo_pod_destination))
    if (not cargo_pod
        or cargo_pod.cargo_pod_state ~= "descending"
        or not cargo_pod.cargo_pod_destination.surface
        or cargo_pod.cargo_pod_destination.surface.name ~= "rubia") then
        game.print("cancelling due to cargo pod state")
        return
    end

    --Passed all checks. Time to go for it!
    start_cutscene(player)
end



--Cancel if player dies. Feed in an event raise for event on_player_died
landing_cutscene.cancel_on_player_death = function(event)
    --If no cutscene playing, don't do anything.
    if not storage.active_cutscenes[tostring(event.player_index)] then return end

    local player = game.get_player(event.player_index)
    cancel_cutscene(player)
    --Give hint for next time.
    game.print({"alert.on-player-died-on-entry"}, {color={r=0.7,g=0.7,b=0,a=1}})
end

--Cancel if player dies
script.on_event(defines.events.on_player_died, function(event)
    local player = game.get_player(event.player_index)
    cancel_cutscene(player)
    --Give hint for next time.
    game.print({"alert.on-player-died-on-entry"}, {color={r=0.7,g=0.7,b=0,a=1}})
end)



------------Testing method
_G.rubia = _G.rubia or {}
rubia.test_cutscene = function() start_cutscene(game.get_player(1)) end
rubia.test_cutscene_cancel = function() cancel_cutscene(game.get_player(1)) end
--Copy this: /c __rubia__ rubia.test_cutscene()

--#endregion

return landing_cutscene
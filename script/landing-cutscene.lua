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

--Try to damage the player during the cutscene, but return control if the player is about to die.
local function cutscene_damage(character, player, damage)
    local effective_health = character.health
    if character.grid and character.grid.valid then effective_health = character.grid.shield + character.health end
    --I don't have a function to account for resistances from mod armor.

    --We are about to kill the player. Give back control
    if (effective_health < damage) and (player.controller_type == defines.controllers.cutscene) then 
        player.exit_cutscene()
    end
    character.damage(damage,game.forces["enemy"])
end

--Start the cutscene for the given player. Return an array of all the relevant event_id to be able to cancel it later.
---@param player LuaPlayer
local function start_cutscene(player)
    local event_ids = {}
    --game.print("Starting, active cutscene for player " .. serpent.block(player) .. " is ".. serpent.block(storage.active_cutscenes))--[player]))
    cancel_cutscene(player)

    --TODO: I need my character reference. This isn't good enough
    local character = player.character or player.cutscene_character
    assert(character, "Character not found.")

    player.set_controller{type=defines.controllers.cutscene,
        character=character,
        waypoints={{target=character, time_to_wait = 999999, transition_time = 0}}} --start_position?=…, 
        --start_zoom?=…, final_transition_time?=…, chart_mode_cutoff?=…,
        --position?=…, surface?=…}
    --Or we may need character.cargo_pod to get the entity of the cargo pod

        

    --TODO The actual cutscene
    table.insert(event_ids, rubia.timing_manager.wait_then_do(5, function()
        player.play_sound{
            path="utility/cannot_build",
            position=player.position,
            volume_modifier=1
        }
        
    end))

    table.insert(event_ids, rubia.timing_manager.wait_then_do(100, function()
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
        cutscene_damage(character, player, 60)
    end))

    table.insert(event_ids, rubia.timing_manager.wait_then_do(300, function()
        player.play_sound{
            path="utility/rotated_large",
            position=player.position,
            volume_modifier=1
        }
        game.print({"alert.landing-cutscene-part3"}, {color={r=0.9,g=0,b=0,a=1}})
        cutscene_damage(character, player, 60)
    end))

    --End of the cutscene
    table.insert(event_ids, rubia.timing_manager.wait_then_do(400, function()
        player.play_sound{
            path="utility/cannot_build",
            position=player.position,
            volume_modifier=1
        }

        --cargo_pod.on_cargo_pod_finished_descending()
        --TODO: Explosion

        cutscene_damage(character, player, 260)
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



--Run cutscene if player lands
--PlanetsLib.
--if technology...

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
rubia.test_cutscene2 = function() cancel_cutscene(game.get_player(1)) end
--Copy this: /c __rubia__ rubia.test_cutscene()
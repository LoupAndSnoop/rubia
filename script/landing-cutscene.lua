require("lib.timing-manager")
local util = require("util")

--Dictionary of ["player_index"] => array of event_id strings for the sub-cutscene events.
storage.active_cutscenes = storage.active_cutscenes or {}
--storage.player_characters = storage.player_characters or {}


--#region Permission-based immobilization for cutscene
local function immobilize_for_cutscene(player)
    --Keep a dictionary of players currently immobilzed, mapped to their initial permission groups.
    if not storage.immobile_players then storage.immobile_players = {} end
    
    --Remove from current group, and track it. Might be nil
    if player.permission_group then 
        --If this player doesn't have permissions, then don't mess with them. Log it. Sucks for you.
        if not player.permission_group.allows_action(defines.input_action.add_permission_group)
        or not player.permission_group.allows_action(defines.input_action.edit_permission_group)
        or not player.permission_group.allows_action(defines.input_action.delete_permission_group) then
            storage.immobile_players[player.index] = "no-permission-permissions"
            return
        end

        storage.immobile_players[player.index]=player.permission_group
        player.permission_group.remove_player(player)
    else storage.immobile_players[player.index]="nil" --Log that there were no permissions before.
    end
    
    --Strip their permissions
    local no_permissions = game.permissions.create_group("Rubia-cutscene-"..player.index)
    assert(no_permissions,"Rubia needs to be able to change permissions for the openning cutscene.")
    
    --[[local to_disable = {defines.input_action.open_blueprint_library_gui,
    defines.input_action.remote_view_entity, defines.input_action.remote_view_surface,
    --Open Guis
    defines.input_action.open_achievements_gui,
    defines.input_action.open_blueprint_library_gui, defines.input_action.open_blueprint_record,
    defines.input_action.open_bonus_gui, defines.input_action.open_character_gui,
    defines.input_action.open_current_vehicle_gui, defines.input_action.open_equipment,
    defines.input_action.open_global_electric_network_gui, defines.input_action.open_gui,
    defines.input_action.open_item, defines.input_action.open_logistics_gui,
    defines.input_action.open_mod_item, defines.input_action.open_new_platform_button_from_rocket_silo,
    defines.input_action.open_opened_entity_grid, defines.input_action.open_parent_of_opened_item,
    defines.input_action.open_production_gui, defines.input_action.open_train_gui,
    defines.input_action.open_train_station_gui, defines.input_action.open_trains_gui,
    }]]
    --for _, input in pairs(to_disable) do
    for _, input in pairs(defines.input_action) do
        if input ~= defines.input_action.write_to_console then
            no_permissions.set_allows_action(input, false)
        end
    end
    no_permissions.set_allows_action(defines.input_action.remote_view_entity, false)
    --no_permissions.set_allows_action(defines.input_action.remote_view_entity, false)
    --no_permissions.set_allows_action(defines.input_action.remote_view_surface, false)
    no_permissions.add_player(player)
    player.permission_group = no_permissions
end
--Give back player permissions
local function remobilize_from_cutscene(player)
    --You aren't immobilized in a cutscene I guess.
    if not storage.immobile_players or not storage.immobile_players[player.index] then return end
    --We never got to change your permissions.
    if storage.immobile_players[player.index] == "no-permission-permissions" then
        storage.immobile_players[player.index] = nil; return
    end

    --Break out of this permission group we made to immobilize
    local no_permissions = player.permission_group
    assert(no_permissions,"No block was found on this player!")
    no_permissions.remove_player(player)
    player.permission_group = nil
    no_permissions.destroy()

    --Get back the old one
    local old_permissions = storage.immobile_players[player.index]
    if storage.immobile_players[player.index] == "nil" then return end --There was no old one
    old_permissions.add_player(player)
    player.permission_group = old_permissions
end

rubia.emergency_failsafes = rubia.emergency_failsafes or {}
--Emergency failsafe to remove immobilization. WARNING: This may mess with player permission groups
--To invoke, do: /c __rubia__ rubia.emergency_failsafes.cutscene_remobilize()
rubia.emergency_failsafes.cutscene_remobilize = function()
    --Remobilize
    for _, player in pairs(game.players) do
        if player.permission_group and string.find(player.permission_group.name, "Rubia") then --This belongs to us!
            local old = player.permission_group
            old.remove_player(player)
            old.destroy()
            player.permission_group=nil
        end

        --Try to reapply old permissions
        if (storage.immobile_players and storage.immobile_players[player.index]) then
            if storage.immobile_players[player.index] == "nil" then return end

            player.permission_group = storage.immobile_players[player.index]
            storage.immobile_players[player.index].add_player(player)
            storage.immobile_players[player.index] = nil
        end
    end
end
--#endregion

--Cancel the cutscene currently playing for the player.
---@param player LuaPlayer
local function cancel_cutscene(player)
    --game.print("Cancelling: " .. serpent.block(storage.active_cutscenes[tostring(player.index)]))
    game.autosave_enabled = true
    remobilize_from_cutscene(player)
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
local function start_cutscene(player, cargo_pod)
    local event_ids = {}
    --game.print("Starting, active cutscene for player " .. serpent.block(player) .. " is ".. serpent.block(storage.active_cutscenes))--[player]))
    cancel_cutscene(player)

    game.autosave_enabled = false --Don't ruin cutscene with an autosave
    immobilize_for_cutscene(player)
    player.zoom = 2

    --game.print("start tick = " .. tostring(game.tick))
    local character = cargo_pod.get_passenger()
    assert(character, "Character not found.")
    
    player.teleport(character.position, character.surface, false) --break out of remote view

    --player.associate_character(character) --Connect

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
    --which seems to start around 450ish ticks

    local arguments = {player, cargo_pod, character}
    --local function play_sound(wait, path)
    --    table.insert(event_ids, rubia.timing_manager.wait_then_do(wait, "cutscene-sound", {player, path})) end
    table.insert(event_ids, rubia.timing_manager.wait_then_do(5, "cutscene-part1", arguments))
    table.insert(event_ids, rubia.timing_manager.wait_then_do(60, "cutscene-part2", arguments))
    table.insert(event_ids, rubia.timing_manager.wait_then_do(200, "cutscene-part3", arguments))
    table.insert(event_ids, rubia.timing_manager.wait_then_do(300, "cutscene-part4", arguments))
    table.insert(event_ids, rubia.timing_manager.wait_then_do(450, "cutscene-end", arguments))

    local SFX_schedule = {
        --["rubia-cutscene-crash"] = {8, 200, 40},
        ["rubia-cutscene-bullet-impact"] = {20,25,30,35,40,42,
                101, 120, 160, 188, 210, 260,
                304, 316, 370, 390, 420},
        ["rubia-cutscene-metal-impact"] = {200, 40},
        ["rubia-cutscene-large-impact"] = {87, 180, 251,321},
        ["rubia-cutscene-longer-woosh"] = {220,290},
        ["rubia-cutscene-fizzle"] = {90,400},
        ["rubia-cutscene-alert"] = {30, 240},
        ["rubia-cutscene-siren1"] = {450-60*5.5},
        ["rubia-cutscene-siren2"] = {450-60*3.9},
        --["rubia-cutscene-siren3"] = {450-60*3.1},
    }
    for path, schedule in pairs(SFX_schedule) do
        for _, time in pairs(schedule) do
            table.insert(event_ids, rubia.timing_manager.wait_then_do(time, "cutscene-sound", {player, path}))
        end
    end

    --player.add_custom_alert(character, {type="virtual",name="signal-alert"}, {"alert.landing-cutscene-part1"}, false)

    --[[- Emergency failsafe: Make sure we exit cutscene mode
    table.insert(event_ids, rubia.timing_manager.wait_then_do(1000, function()
        --cancel_cutscene(player)
        if (player.controller_type == defines.controllers.cutscene) then 
            player.exit_cutscene() end
    end))]]

    storage.active_cutscenes[tostring(player.index)] = event_ids--util.table.deepcopy(event_ids)--event_ids
    return event_ids
end

--#region Cutscene fragments
rubia.timing_manager.register("cutscene-sound", function(player, path, volume)
    player.play_sound{path=path, volume_modifier=volume or 1}
end)

--Whatever we do at the very start of the cutscene
rubia.timing_manager.register("cutscene-part1", function(player, cargo_pod, character)
    --player.play_sound{path="utility/cannot_build", volume_modifier=1}
end)

rubia.timing_manager.register("cutscene-part2", function(player, cargo_pod, character)
    game.print({"alert.landing-cutscene-part1"}, {color={r=0.9,g=0,b=0,a=1}})
    cutscene_damage(character, player, 30)
end)

rubia.timing_manager.register("cutscene-part3", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    game.print({"alert.landing-cutscene-part2"}, {color={r=0.9,g=0,b=0,a=1}})
    cutscene_damage(character, player, 70)
end)

rubia.timing_manager.register("cutscene-part4", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    game.print({"alert.landing-cutscene-part3"}, {color={r=0.9,g=0,b=0,a=1}})
    cutscene_damage(character, player, 110)
end)

--End of cutscene
rubia.timing_manager.register("cutscene-end", function(player, cargo_pod, character)
    player.play_sound{ path="rubia-cutscene-crash", volume = 1 }

    character.surface.create_entity({name = "nuclear-reactor-explosion", position = {x=0,y=0}})

    --cargo_pod.on_cargo_pod_finished_descending()
    cargo_pod.force_finish_descending()
    cargo_pod.destroy()
    --if player and player.cargo_pod and player.cargo_pod.valid then player.cargo_pod.destroy() end

    cutscene_damage(character, player, 400)

    --Make sure a surviving player is damaged at least a little to their base HP, without killing
    if (character) then 
        character.health = math.min(math.random(3, 150), character.health)
    end
    cancel_cutscene(player)

    --Check if they forgot a roboport in their armor before queuing failsafe
    --No grid = they did forget a roboport
    if character and character.grid then 
        --Check if failsafe must activate
        for _, entry in pairs(character.grid.get_contents()) do
            local prototype = prototypes.equipment[entry.name]
            --Found a roboport of some type. No failsafe needed
            if prototype and prototype.name and string.find(prototype.name, "roboport") then
                return
            end
        end
    end
    rubia.timing_manager.wait_then_do(600, "cutscene-roboport-failsafe", {player, character})
end)

--Give the player a roboport if they forgot to bring one
rubia.timing_manager.register("cutscene-roboport-failsafe", function(player, character)
    --First check that we have a valid player with a grid.
    if not (character and character.valid and character.surface and character.surface.name == "rubia") then return end
    
    --[[No grid = they did forget a roboport
    if character.grid then 
        --Check if failsafe must activate
        for _, entry in pairs(character.grid.get_contents()) do
            local prototype = prototypes.equipment[entry.name]
            --Found a roboport of some type. No failsafe needed
            if prototype and prototype.name and string.find(prototype.name, "roboport") then
                return
            end
        end
    end]]
    --Motherfucker forgot his roboport and needs to be bailed out.
    if not storage.rubia_roboport_failsafe then storage.rubia_roboport_failsafe = {} end
    if storage.rubia_roboport_failsafe[player.index] then return end --They already got their one roboport

    --Make sure to taunt him before giving him a roboport.
    game.print({"rubia-taunt.forgot-roboport-failsafe"})
    storage.rubia_roboport_failsafe[player.index] = true

    local inventory = player.get_inventory(defines.inventory.character_main)
    if inventory and inventory.can_insert({name="personal-roboport-equipment", count=1}) then
        inventory.insert({name="personal-roboport-equipment", count=1, enable_looted=true})
    else
        character.surface.spill_item_stack{
            position = character.position,
            stack = {name="personal-roboport-equipment", count=1},
            enable_looted  = true,
        }
    end
    rubia.timing_manager.wait_then_do(600, "cutscene-roboport-failsafe-part2", {player, character})
end)

rubia.timing_manager.register("cutscene-roboport-failsafe-part2", function(player, character)
    if not (character and character.valid and character.surface and character.surface.name == "rubia") then return end
    --SMITE
    game.print({"rubia-taunt.forgot-roboport-failsafe-part2"})
    character.health = 1
end)
--#endregion
----------------------------------

--#region External handles to start/end cutscene via events.

--Variable to store exposed cutscene functions
local landing_cutscene = {}

--See if we need to start a cutscene on a defines.events.on_cargo_pod_finished_ascending event.
landing_cutscene.try_start_cutscene = function(event)
    if not event.player_index then return end --Cargo pod had no player riding

    local cargo_pod = event.cargo_pod
    local player = game.get_player(event.player_index)
    --local surface = game.get_surface(event.surface_index)

    --[[First, we need to check that we are going from a space platform down to rubia.
    if (not surface --Prev surface destroyed/deleted?
        or not surface.platform --Old surface was not a platform
        or player.surface.name ~= "rubia") then--new surface is not the right planet

        game.print("cancel cutscene")
        return
    end]]

    --Operation iron man cancels cutscene.
    if (player.force.technologies["planetslib-rubia-cargo-drops"].researched) then
        return end
    
    --Secondary check based on the cargo pod
    --game.print(serpent.block(cargo_pod))
    --game.print("stats = " .. serpent.block(cargo_pod.cargo_pod_state)
    --.. ", destination = " .. serpent.block(cargo_pod.cargo_pod_destination))
    if (not cargo_pod
        or not cargo_pod.cargo_pod_origin --Origin dead
        --or cargo_pod.cargo_pod_state ~= "descending"
        or not cargo_pod.cargo_pod_origin.surface
        or not cargo_pod.cargo_pod_origin.surface.platform --Was not a space platform
        or not cargo_pod.cargo_pod_destination.surface --Destination blowed up
        or cargo_pod.cargo_pod_destination.surface.name ~= "rubia") then
        game.print("cancelling due to cargo pod state")
        return
    end

    --Passed all checks. Time to go for it!
    start_cutscene(player, cargo_pod)
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
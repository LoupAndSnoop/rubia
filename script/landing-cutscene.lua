require("lib.timing-manager")
local util = require("util")

--Variable to store exposed cutscene functions
local landing_cutscene = {}

--Dictionary of ["player_index"] => array of event_id strings for the sub-cutscene events.
storage.active_cutscenes = storage.active_cutscenes or {}


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


--If the player character is respawning on rubia mid-cutscene, we need to do this to send them back from Rubia.
landing_cutscene.check_respawn_off_rubia = function(event)
    --If we are responding to the event of a non-respawn-blocked player, then stop
    if not storage.rubia_respawn_blocked_players
        or not storage.rubia_respawn_blocked_players[event.player_index] 
        then return end

    --First we need to find a surface
    local target = nil--game.get_surface("nauvis") --Default
    for _, surface in pairs(game.surfaces) do
        local platform = surface.platform
        if surface.valid and platform and platform.last_visited_space_location
            and platform.last_visited_space_location.name == "rubia" then
            target = surface
            break
        end
    end

    --We need a backup because maybe the platform was destroyed. Find a vanilla planet.
    if not target then 
        local vanilla_surfaces = {"nauvis", "vulcanus", "gleba","fulgora", "aquilo"}
        for _, surface in pairs(vanilla_surfaces) do
            target = game.get_surface(surface)
            if target then break end
        end
    end

    --Need a backup for the backup
    if not target then
        local banned_surfaces = rubia_lib.array_to_hashset({"rubia", "blueprint-sandboxes"})
        for _, surface in pairs(game.surfaces) do
            if surface.valid and not banned_surfaces[surface.name] then
                target = surface; break
            end
        end
    end
    assert(target, "You are not allowed to respawn like that on Rubia, but we can't find a valid respawn point. Tell the mod creator.")

    --Go back to the target
    local player = game.get_player(event.player_index)
    player.teleport({x=0,y=0}, target)
    --If the target is a space platform hub, then we also need to enter
    if target.platform then player.enter_space_platform(target.platform) end

    --Unregister
    storage.rubia_respawn_blocked_players[event.player_index] = nil
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

    --We are about to kill the player. Give back control, if in a cutscene style implementation
    if (character.health <= damage) and (player.controller_type == defines.controllers.cutscene) then 
        player.exit_cutscene()
        character.die(game.forces["enemy"])
    else 
        character.damage(damage, game.forces["enemy"]) --Otherwise just hurt him
    end

    --If they died, set a respawn block
    if (not character.valid or character.health <= 0) then
        --Respawn block them. Keep a hashset of all player ID that are respawn blocked
        storage.rubia_respawn_blocked_players = storage.rubia_respawn_blocked_players or {}
        storage.rubia_respawn_blocked_players[player.index] = true
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

--Do the cutscene/congrats for the first win
local first_blast_off_cutscene = function()
    rubia.timing_manager.wait_then_do(1, "delayed-text-print", {{"rubia-taunt.rubia-first-blast-off-part1"}})
    rubia.timing_manager.wait_then_do(5 * 60, "delayed-text-print", {{"rubia-taunt.rubia-first-blast-off-part2"}})
    rubia.timing_manager.wait_then_do(10 * 60, "delayed-text-print", {{"rubia-taunt.rubia-first-blast-off-part3"}})
end


--#region Cutscene fragments
rubia.timing_manager.register("cutscene-sound", function(player, path, volume)
    player.play_sound{path=path, volume_modifier=volume or 1}
end)

--Whatever we do at the very start of the cutscene
rubia.timing_manager.register("cutscene-part1", function(player, cargo_pod, character)
end)

--Note: Realistically, a player might have 4-10 shields when coming to Rubia. => 500-800 total health. 
--Expect about 6 seconds worth of regen from shields, which charge at 12 HP/s each. 50 HP shield => about 120 HP /shield.
--First segment should not kill an unshielded player, so do just under 300 HP. 4 shields should
--fully heal off that damage via regen mostly. Final burst of dmg should be the actual check for your total HP upon arrival.
local CUTSCENE_TEXT_SETTINGS = {color={r=0.9,g=0,b=0,a=1}}
rubia.timing_manager.register("cutscene-part2", function(player, cargo_pod, character)
    player.print({"alert.landing-cutscene-part1"}, CUTSCENE_TEXT_SETTINGS)
    cutscene_damage(character, player, 90)
end)

rubia.timing_manager.register("cutscene-part3", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    player.print({"alert.landing-cutscene-part2"}, CUTSCENE_TEXT_SETTINGS)
    cutscene_damage(character, player, 90)
end)

rubia.timing_manager.register("cutscene-part4", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    player.print({"alert.landing-cutscene-part3"}, CUTSCENE_TEXT_SETTINGS)
    cutscene_damage(character, player, 110)
end)


local PLANNED_BIG_DAMAGE = 460 + 50
--End of cutscene
rubia.timing_manager.register("cutscene-end", function(player, cargo_pod, character)
    player.play_sound{ path="rubia-cutscene-crash", volume = 1 }

    character.surface.create_entity({name = "nuclear-reactor-explosion", position = {x=0,y=0}})


    cargo_pod.force_finish_descending()
    cargo_pod.destroy()
    --if player and player.cargo_pod and player.cargo_pod.valid then player.cargo_pod.destroy() end

    --If player has no shields, amplify the amount of damage they need to survive.
    local bonus_damage = 0
    if (not character.grid) or character.grid.max_shield == 0 then bonus_damage = 300 end

    --Main damage check here. Empirically, 460 = need 6 shields with no health upgrades.
    cutscene_damage(character, player, PLANNED_BIG_DAMAGE + bonus_damage)

    --Make sure a surviving player is damaged at least a little to their base HP, without killing
    if (character and character.valid) then 
        character.health = math.min(math.random(3, 150), character.health)
    end
    cancel_cutscene(player)

    --Check if they forgot a roboport in their armor before queuing failsafe
    --No grid = they did forget a roboport
    if character and character.valid and character.grid then 
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
    player.print({"rubia-taunt.forgot-roboport-failsafe"})
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
    player.print({"rubia-taunt.forgot-roboport-failsafe-part2"})
    character.health = 1
end)

rubia.timing_manager.register("delayed-text-print", function(player, local_string) 
    if player then player.print(local_string)
    else game.print(local_string)
    end
end)
--#endregion
----------------------------------

--#region External handles to start/end cutscene via events.





--See if we need to start a cutscene on a defines.events.on_cargo_pod_finished_ascending event.
landing_cutscene.try_start_cutscene = function(event)
    if not event.player_index then return end --Cargo pod had no player riding

    local cargo_pod = event.cargo_pod
    local player = game.get_player(event.player_index)
    --local surface = game.get_surface(event.surface_index)


    --Check for first blastoff:
    if (not storage.rubia_first_blastoff_complete
        and cargo_pod
        and cargo_pod.cargo_pod_destination
        and cargo_pod.cargo_pod_destination.type == defines.cargo_destination.station
        and cargo_pod.cargo_pod_destination.station.surface.platform
        and cargo_pod.cargo_pod_origin
        and cargo_pod.cargo_pod_origin.surface
        and cargo_pod.cargo_pod_origin.surface.name == "rubia") then
            storage.rubia_first_blastoff_complete = true
            first_blast_off_cutscene()
            
            return
    end

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
        --game.print("cancelling due to cargo pod state")
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
    player.print({"alert.on-player-died-on-entry"}, {color={r=0.7,g=0.7,b=0,a=1}})
end

--[[Cancel if player dies
script.on_event(defines.events.on_player_died, function(event)
    local player = game.get_player(event.player_index)
    cancel_cutscene(player)
    --Give hint for next time.
    player.print({"alert.on-player-died-on-entry"}, {color={r=0.7,g=0.7,b=0,a=1}})
end)]]


------
--Give warning when initially going to rubia. For an on_space_platform_changed_state event
landing_cutscene.check_initial_journey_warning = function(event)
    local platform = event.platform

    --Check if space platform is headed to rubia
    if not (platform and platform.state == defines.space_platform_state.on_the_path
        and platform.space_connection
        and (platform.space_connection.to.name == "rubia" or platform.space_connection.from.name == "rubia")) then
        --game.print("cancel due to space connection: " .. serpent.block(platform.space_connection))
        return
    end

    --Check player characters on board
    local characters = {}
    storage.rubia_initial_journey_warned = storage.rubia_initial_journey_warned or {}
    for _, player in pairs(game.players) do
        local char = player.character
        --If character is riding, not already warned, and project iron man no researched
        if char and char.surface and char.surface.index == platform.surface.index 
            and not storage.rubia_initial_journey_warned[player.index]
            and not player.force.technologies["planetslib-rubia-cargo-drops"].researched then
            table.insert(characters, {character = char, player = player})
            storage.rubia_initial_journey_warned[player.index] = true
        end
    end
    
    --if #characters == 0 then game.print("No characters to check") end

    --Evaluate type of warning for each
    for _, entry in pairs(characters) do
        local issue_warning = false

        local char = entry.character
        local effective_health = char.max_health
        if (char.grid and char.grid.valid
            and ((char.grid.max_solar_energy + char.grid.get_generator_energy()) > 0)) then
            effective_health = effective_health + char.grid.max_shield

            local expected_regen = 
                12 * char.grid.count("energy-shield-mk2-equipment")
                + 12 * char.grid.count("energy-shield-equipment")

            expected_regen = math.min(300, expected_regen * 6 * 0.5) --How much healing we expect max
            --If shields, then issue warning if total eff health too small
            if effective_health + expected_regen < PLANNED_BIG_DAMAGE + 300 then
                issue_warning = true
            end

        else issue_warning = true -- no shields => definitely issue warning
        end

        if issue_warning then entry.player.print({"alert.pre-rubia-cutscene-unprepared"}, CUTSCENE_TEXT_SETTINGS)
        else entry.player.print({"alert.pre-rubia-cutscene-prepared"}, CUTSCENE_TEXT_SETTINGS)
        end
    end
end


------------Testing method
_G.rubia = _G.rubia or {}
rubia.testing = rubia.testing or {}
rubia.testing.test_cutscene = function() start_cutscene(game.get_player(1)) end
rubia.testing.test_cutscene_cancel = function() cancel_cutscene(game.get_player(1)) end
--Copy this: /c __rubia__ rubia.test_cutscene()

--#endregion

return landing_cutscene
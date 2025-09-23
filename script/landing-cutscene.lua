require("__rubia__.lib.timing-manager")
local util = require("util")

--Variable to store exposed cutscene functions
local landing_cutscene = {}

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
    
    for _, input in pairs(defines.input_action) do
        if input ~= defines.input_action.write_to_console then
            no_permissions.set_allows_action(input, false)
        end
    end
    no_permissions.set_allows_action(defines.input_action.remote_view_entity, false)
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
    --Dictionary of ["player_index"] => array of event_id strings for the sub-cutscene events.
    storage.active_cutscenes = storage.active_cutscenes or {}

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


--#region Doing/reading damage/shields

--For troubleshooting. Get the character's current total shield.
local function get_character_shields(character)
    if (not character.grid or not character.grid.valid) then return 0 end --Nothing to do
    local total_shield = 0
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
        and equip.max_shield > 0) then
            total_shield = total_shield + equip.shield
        end
    end
    return total_shield
end

--[[ This version maximizes shield regen
--Go through the player's equipment grid, and change the shield to that total value
--This version engages as many shields as possible.
local function set_character_shields(character, new_total_shield_value)
    if (not character.grid or not character.grid.valid
        or character.grid.max_shield < 1) then return end --Nothing to do
    local final_shield_ratio = math.min(1,math.max(0, new_total_shield_value / character.grid.max_shield))
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
        and equip.max_shield > 0) then
            equip.shield = equip.max_shield * final_shield_ratio
        end
    end
end]]

--Go through the player's equipment grid, and change the shield to that total value
--Engages the minimal number of shields for regen. This can lead to slight inconsistencies in damage estimates,
--but it makes the shield bar clearly fill slowly.
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

--Go through the player's equipment grid, and remove all energy from the character's shields.\
--This reduces jank from the shield making a ton of shield the next frame.
--Leave an amount of energy on the shield equal to the amount it would need for 1 tick of energy
local function drain_character_shields(character)
    if (not character.grid or not character.grid.valid) then return end --Nothing to do
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
        and equip.max_shield > 0) then
            equip.energy = equip.prototype.get_energy_consumption(equip.quality)
        end
    end
end

---Get this character's total shield regen per second.
---@param character LuaEntity
---@return double
local function get_character_shield_regen(character)
    if (not character.grid or not character.grid.valid) then return 0 end --Nothing to do
    local regen = 0
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
            and equip.max_shield > 0) then
            local proto = equip.prototype
            local energy_consumption = proto.get_energy_consumption(equip.quality) --energy/tick
            regen = regen + energy_consumption / proto.energy_per_shield --Shield / tick
        end
    end
    return regen * 60 --Output in shield/sec
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
--#endregion

--Start the cutscene for the given player. Return an array of all the relevant event_id to be able to cancel it later.
---@param player LuaPlayer
local function start_cutscene(player, cargo_pod)
    local event_ids = {}
    --game.print("Starting, active cutscene for player " .. serpent.block(player) .. " is ".. serpent.block(storage.active_cutscenes))--[player]))
    cancel_cutscene(player)

    game.autosave_enabled = false --Don't ruin cutscene with an autosave
    immobilize_for_cutscene(player)
    player.zoom = 2

    local character = cargo_pod.get_passenger()
    assert(character, "Character not found.")
    
    --Some mods allow items in player inventory. We need to clear this so they actually land with nothing
    while player.crafting_queue_size > 0 do
        player.cancel_crafting{index = 1, count = player.crafting_queue[1].count}
    end
    local inventory = player.get_inventory(defines.inventory.character_main)
    if inventory then inventory.clear() end
    local inventory_trash = player.get_inventory(defines.inventory.character_trash)
    if inventory_trash then inventory_trash.clear() end
    
    
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

    storage.active_cutscenes = storage.active_cutscenes or {}
    storage.active_cutscenes[tostring(player.index)] = event_ids--util.table.deepcopy(event_ids)--event_ids
    return event_ids
end

--Do the cutscene/congrats for the first win
local first_blast_off_cutscene = function(player)
    rubia.timing_manager.wait_then_do(1, "delayed-text-print", {player, {"rubia-taunt.rubia-first-blast-off-part1"}})
    rubia.timing_manager.wait_then_do(5 * 60, "delayed-text-print", {player, {"rubia-taunt.rubia-first-blast-off-part2"}})
    rubia.timing_manager.wait_then_do(10 * 60, "delayed-text-print", {player, {"rubia-taunt.rubia-first-blast-off-part3"}})

    --Taunt when there is a multiplayer clear. Send it globally, but only once.
    if game.is_multiplayer() and (table_size(game.connected_players) > 1)
        and not storage.rubia_multiplayer_taunt then 
        storage.rubia_multiplayer_taunt = true
        rubia.timing_manager.wait_then_do(15 * 60, "delayed-text-print", {"game", {"rubia-taunt.rubia-first-blast-off-part4-mp", player.name or "this guy"}, nil})
        rubia.timing_manager.wait_then_do(40 * 60, "delayed-text-print", {"game", {"rubia-taunt.rubia-first-blast-off-part5-mp", player.name or "He"}, nil})
    end

    rubia.timing_manager.wait_then_do(15 * 60, "unlock-rubia-difficulty-achievement", {player})
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
    drain_character_shields(character) --Drain them to avoid jank in the calculation.
    cutscene_damage(character, player, 90)
end)

rubia.timing_manager.register("cutscene-part3", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    player.print({"alert.landing-cutscene-part2"}, CUTSCENE_TEXT_SETTINGS)
    cutscene_damage(character, player, 70)
end)

rubia.timing_manager.register("cutscene-part4", function(player, cargo_pod, character)
    player.play_sound{path="utility/alert_destroyed", volume_modifier=1}
    player.print({"alert.landing-cutscene-part3"}, CUTSCENE_TEXT_SETTINGS)
    cutscene_damage(character, player, 89)
end)


--local PLANNED_BIG_DAMAGE = 510 --510 = 8 shield Mk1
--For reference:
--510 = 8 shield Mk1
--These benchmarks are not with a totally full armor, but has a few bits and bobs, while being unreasonably full.
--8 shield1 = 400 shield
--Power armor2 + lots of shield1 = 750 shield
--Power Armor2 + 10 Shield2 = 1500 shield
--Rare Power armor2 + rare shield1 = 1600 shield
--Rare Power Armor2 + Shield2 = 3150 shield
--Normal Mech armor with many normal shield Mk2 = 2700  shield
--Normal mech armor + many Leg shield2 = 5.6k shield
--Epic Mech armor + many epic shield Mk2 = 7.6k shield
--Leg Mech armor + many leg shield Mk2 = 12k shield
--
--When shields drained, shield value for small amounts of shield: Mk1 = 122
--2400 shield and 2310 big dmg => 165.8 HP left
--240 => need 2 Mk1 shield.
--550 => need 8 Mk1 shield
--860 => need 700 shield
local planned_big_damage_dic = {
    ["easy"] = 200 + 40, --2 MK1 shield
    ["normal"] = 510 + 40, --8 Mk1 shield
    ["hard"] = 510 -400 + 770, --Does not need quality
    ["very-hard"] = 510 -400 + 2200 +40,
    ["very-very-hard"] = 6300 +40,
}

--Return the amount of burst damage the player will be taking as they land at the end
local function get_planned_big_damage() return planned_big_damage_dic[
        settings.global["rubia-difficulty-setting"].value] end


--End of cutscene
rubia.timing_manager.register("cutscene-end", function(player, cargo_pod, character)
    player.play_sound{ path="rubia-cutscene-crash", volume = 1 }

    character.surface.create_entity({name = "nuclear-reactor-explosion", position = {x=0,y=0}})

    cargo_pod.force_finish_descending()
    cargo_pod.destroy()
    --if player and player.cargo_pod and player.cargo_pod.valid then player.cargo_pod.destroy() end

    --If player has no shields, amplify the amount of damage they need to survive.
    local bonus_damage = 0
    if (not character.grid) or character.grid.max_shield == 0 then bonus_damage = 400 end

    --log("RUBIA TEST CODE NOT TO BE SHOWN")
    --game.print("TESTING: Expected eff health after = " .. tostring(character.health + get_character_shields(character) - get_planned_big_damage() - bonus_damage)
    --    .. ".  Current Character health = " .. tostring(character.health) .. ", shield = " .. tostring(get_character_shields(character))) --Testing
        
    --Main damage check here. Empirically, 460 = need 6 shields with no health upgrades.
    cutscene_damage(character, player, get_planned_big_damage() + bonus_damage)

    --Make sure a surviving player is damaged at least a little to their base HP, without killing
    if (character and character.valid) then 
        --game.print("TESTING: Character health = " .. tostring(character.health) .. ", shield = " .. tostring(get_character_shields(character))) --Testing
        character.health = math.min(math.random(3, 150), character.health)        
        set_character_shields(character, 0)
    end

    cancel_cutscene(player)

    --Check if they forgot a roboport in their armor before queuing failsafe
    --No grid = they did forget a roboport
    local need_roboport = true
    if character and character.valid and character.grid then 
        --Check if failsafe must activate
        for _, entry in pairs(character.grid.get_contents()) do
            local prototype = prototypes.equipment[entry.name]
            --Found a roboport of some type. No failsafe needed
            if prototype and prototype.name and string.find(prototype.name, "roboport") then
                need_roboport = false; break
            end
        end
    end
    if need_roboport then 
        rubia.timing_manager.wait_then_do(600, "cutscene-roboport-failsafe", {player, character})
    end

    --Survival achievement
    if character and character.valid then
        rubia.timing_manager.wait_then_do(300, "landing-survival-achievement", {player, character})
        --Log difficulty upon landing
        if not storage.difficulty_upon_landing then
            storage.difficulty_upon_landing = settings.global["rubia-difficulty-setting"].value
        end
    end
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

rubia.timing_manager.register("delayed-text-print", function(player, local_string, print_settings) 
    if game.simulation then return end --Do not print in simulations!
    if player and player ~= "game" then player.print(local_string, print_settings)
    else game.print(local_string, print_settings)
    end
end)

rubia.timing_manager.register("landing-survival-achievement", function(player, character) 
    if player and character and character.valid and player.character == character
        and character.surface.name == "rubia" then
        player.unlock_achievement("land-on-rubia")
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
        and cargo_pod.cargo_pod_destination.station
        and cargo_pod.cargo_pod_destination.station.surface.platform
        and cargo_pod.cargo_pod_origin
        and cargo_pod.cargo_pod_origin.surface
        and cargo_pod.cargo_pod_origin.surface.name == "rubia") then
            storage.rubia_first_blastoff_complete = true
            first_blast_off_cutscene(player)
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
    storage.active_cutscenes = storage.active_cutscenes or {}
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
local WARNING_COOLDOWN = 10 * 60 --Number of ticks to wait before sending another warning
--Give warning when initially going to rubia. For an on_space_platform_changed_state event
landing_cutscene.check_initial_journey_warning = function(event)
    local platform = event.platform

    --Check if space platform is headed to rubia
    if not (platform and platform.state == defines.space_platform_state.on_the_path
        and platform.space_connection
        and (platform.space_connection.to.name == "rubia" or platform.space_connection.from.name == "rubia")
        and not (platform.last_visited_space_location and platform.last_visited_space_location.name == "rubia")
        and not (platform.space_location and platform.space_location.name == "rubia")) then
        --game.print("cancel due to space connection: " .. serpent.block(platform.space_connection))
        return
    end

    --Check player characters on board
    local characters = {}
    storage.rubia_initial_journey_warned = storage.rubia_initial_journey_warned or {}
    for _, player in pairs(game.players) do
        local char = player.character
        local last_warned_tick = storage.rubia_initial_journey_warned[player.index] or -WARNING_COOLDOWN
        --If character is riding, not already warned, and project iron man no researched
        if char and char.surface and char.surface.index == platform.surface.index 
            and (last_warned_tick + WARNING_COOLDOWN) < game.tick--not storage.rubia_initial_journey_warned[player.index]
            and not player.force.technologies["planetslib-rubia-cargo-drops"].researched then
            table.insert(characters, {character = char, player = player})
            storage.rubia_initial_journey_warned[player.index] = game.tick
        end
    end
    
    --if #characters == 0 then game.print("No characters to check") end

    --Evaluate type of warning for each
    local warning_message = "alert.pre-rubia-cutscene-unprepared-naked"; --Changes based on how severe it is.
    for _, entry in pairs(characters) do
        local issue_warning = false

        local char = entry.character
        local effective_health = char.max_health
        if (char.grid and char.grid.valid
            and ((char.grid.max_solar_energy + char.grid.get_generator_energy()) > 0)) then
            effective_health = effective_health + char.grid.max_shield

            --Total regen winds up being off by 54 too small for small values because we take from shields in a way that minimizes regen.
            local expected_regen = math.min(249 -54, get_character_shield_regen(char) * 6.5) --How much healing we expect max
            --If shields, then issue warning if total eff health too small
            local planned_total_dmg = get_planned_big_damage() + 249
            --game.print("Expected final HP = " .. (effective_health + expected_regen - get_planned_big_damage() - 249)
            --.. ", Effective HP = " .. (effective_health) .. ", Expected regen = " .. expected_regen .. ", max shield = " .. (char.grid.max_shield or 0))
            issue_warning = effective_health + expected_regen < planned_total_dmg * 1.08 + 5 --Fudge factor

            --Shield ratio = fraction of shield you need / total
            local needed_shield = planned_total_dmg - char.max_health
            if needed_shield == 0 then needed_shield = 0.1 end
            local shield_ratio = (char.grid.max_shield + expected_regen) / needed_shield     
            if shield_ratio <= 0        then warning_message = "alert.pre-rubia-cutscene-unprepared-naked"
            elseif shield_ratio < 0.4  then warning_message = "alert.pre-rubia-cutscene-unprepared-low-shield"
            elseif shield_ratio < 0.7  then warning_message = "alert.pre-rubia-cutscene-unprepared-medium-shield"
            elseif shield_ratio < 0.9 then warning_message = "alert.pre-rubia-cutscene-unprepared-almost-shield"
            else warning_message = "alert.pre-rubia-cutscene-unprepared-too-close"
            end
            --game.print("shield_ratio = " .. tostring(shield_ratio))

        else issue_warning = true -- no shields => definitely issue warning
        end

        if issue_warning then 
            entry.player.print({"alert.pre-rubia-cutscene-unprepared"}, CUTSCENE_TEXT_SETTINGS)
            rubia.timing_manager.wait_then_do(60*5, "delayed-text-print",
             {entry.player, {warning_message}, CUTSCENE_TEXT_SETTINGS})
        else entry.player.print({"alert.pre-rubia-cutscene-prepared"}, CUTSCENE_TEXT_SETTINGS)
        end
    end
end
--#endregion

--#region Testing methods
_G.rubia = _G.rubia or {}
rubia.testing = rubia.testing or {}
rubia.testing.test_cutscene = function() start_cutscene(game.get_player(1)) end
rubia.testing.test_cutscene_cancel = function() cancel_cutscene(game.get_player(1)) end
--Copy this: /c __rubia__ rubia.test_cutscene()

--Shield value testing:
rubia.timing_manager.register("shield-value-testing", function(character, 
        shield_before_regen, start_tick, damage)
    local regen = get_character_shields(character) - shield_before_regen
    local regen_per_sec = (regen) / ((game.tick - start_tick) / 60)
    
    local string = "Shield regen test. Regen/s = " .. tostring(regen_per_sec) 
    string = string .. ". Ticks = " .. tostring(game.tick - start_tick)
    string = string .. ". Total regen = " .. tostring(regen)
    string = string .. ".   Final shield = " .. tostring(get_character_shields(character))

    if math.abs(regen - damage) < 0.1 then --Shield was maxed
        string = "\n   Regen stopped mid-test due to hitting max shield.\n"
    end

    game.print(string)
end)
---Deal damage to the player, then calculate the regenerated shield amount.
---@param damage_to_try int?
rubia.testing.test_shield_regen = function(damage_to_try)
    local character = game.players[1].character
    if not character then game.print("No character found") return end

    drain_character_shields(character)
    local pre_damage_shield = get_character_shields(character)
    if not damage_to_try then damage_to_try = pre_damage_shield * 0.9 end

    character.damage(damage_to_try, game.forces["player"])
    local shield_damage = pre_damage_shield - get_character_shields(character)
    game.print("Initial shield: Pre damage = " .. tostring(pre_damage_shield)
        .. ", Post-damage = " .. tostring(get_character_shields(character)))

    for _, test_ticks in pairs({1, 2, 5,10,50,120}) do
        rubia.timing_manager.wait_then_do(test_ticks, "shield-value-testing",
            {character, get_character_shields(character), game.tick, shield_damage})
    end
end
--call: /c __rubia__ rubia.testing.test_shield_regen()
--Or call with a specific damage argument

---Measure the character's shield regen.
rubia.testing.measure_shield_regen = function()
    local character = game.players[1].character
    if not character then game.print("No character found") return end
    game.print("Shield regen/s = " .. get_character_shield_regen(character))
end


--#endregion


--#region Event subscription
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_event(defines.events.on_cargo_pod_finished_ascending, "start-cutscene",
  landing_cutscene.try_start_cutscene)
event_lib.on_event(defines.events.on_player_respawned, "check-respawn",
  landing_cutscene.check_respawn_off_rubia)
event_lib.on_event(defines.events.on_space_platform_changed_state, "initial-journey-warning",
  landing_cutscene.check_initial_journey_warning)
event_lib.on_event(defines.events.on_player_died, "cancel-cutscene-death",
  landing_cutscene.cancel_on_player_death)
--#endregion

--#region Interface for weird mods that skip cutscene

---Return true if the given character should be able to land on Rubia roughly. NOT accurate: just rough for use on other mods.
---@param character LuaEntity
---@return boolean
local function can_land_on_rubia(character)
    if not character.valid then return false end
    --Operation iron man automatically lets you pass through
    if character.force.technologies["planetslib-rubia-cargo-drops"].researched then return true end
    local shields = get_character_shields(character)
    local expected_shield_req = get_planned_big_damage() - 130
    if shields < expected_shield_req then return false end
    return true
end

---When we externally cancel another mod sending a character to Rubia, send this error message:
---@param player LuaPlayer
local function on_aborted_rubia_travel(player)
    local print_target = player
    if not print_target then print_target = game end
    print_target.print({"alert.landing-cutscene-abort-external-mod"},rubia.WARNING_PRINT_SETTINGS)
    print_target.play_sound{path="utility/cannot_build"}
end

--Remote interface for other mods to abort landing.
remote.add_interface("rubia-travel-abort",{
    can_land_on_rubia = can_land_on_rubia,
    on_aborted_rubia_travel = on_aborted_rubia_travel
})
--Remote interface for just planet hoppers
remote.add_interface("Planet-Hopper-abort-rubia",{
    should_abort = function(character) return not can_land_on_rubia(character) end,
    on_launch_aborted = on_aborted_rubia_travel
})

--#endregion


return landing_cutscene
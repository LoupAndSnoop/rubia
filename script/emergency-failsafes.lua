--Some emergency failsafes are here

rubia.emergency_failsafes = rubia.emergency_failsafes or {}

--Fix issues where some entities were map genned on nauvis
rubia.emergency_failsafes.clear_rubia_entities_from_nauvis = function()
    local nauvis = game.get_surface("nauvis")

    local entities_to_check = {}
    local function add_type(subtype, main_type)
        for name, proto in pairs(prototypes[main_type]) do
            if proto.type == subtype then
                local history = prototypes.get_history(subtype, name)
                if history and history.created == "rubia" then
                    table.insert(entities_to_check, name)
                end
            end
        end
    end
    add_type("simple-entity","entity")

    local out_entity_table = {}
    for _, name in pairs(entities_to_check) do --names of surfaces are in keys
        local entity_array = nauvis.find_entities_filtered{name = name} --input_name

        if(table_size(entity_array) > 0) then 
            out_entity_table = rubia_lib.array_concat({entity_array, out_entity_table})
        end
    end
    for _, entity in pairs(out_entity_table) do
        if entity.valid then entity.destroy() end
    end


    entities_to_check = {}
    add_type("optimized-decorative","decorative")
    for _, name in pairs(entities_to_check) do --names of surfaces are in keys
        local entity_array = nauvis.find_decoratives_filtered{name = name} --input_name

        if(table_size(entity_array) > 0) then 
            out_entity_table = rubia_lib.array_concat({entity_array, out_entity_table})
        end
    end
    for _, entity in pairs(out_entity_table) do
        nauvis.destroy_decoratives{position = entity.position}
    end
end



--#region Testing scripts

--[[
---Test to see if the achievement unlocks look good.
---@param event EventData.on_console_chat
local function achievement_testing(event)
    local achievements = {
        ["land"] = "land-on-rubia",
        ["lore"] = "rubia-lore-complete",
        ["science"] = "research-with-biorecycling",
        ["fish"] = "so-long-and-thanks-for-all-the-fish",
    }
    for index, achievement in pairs(achievements) do
        if string.find(event.message, "achievement " .. index) then
            game.players[event.player_index].unlock_achievement(achievement)
            game.print("unlocked")
        end
    end
end

log("WARNING: Rubia achievement test code is active")
script.on_event(defines.events.on_console_chat, function(event)
    achievement_testing(event)
end)
]]




--[[
--Testing scripts

--To reach rubia with blank research.
/c game.planets["rubia"].create_surface();
game.players[1].teleport({x=0,y=0},game.surfaces["rubia"])
game.forces["player"].technologies["planet-discovery-rubia"].research_recursive()


/c game.planets["rubia"].create_surface();
game.players[1].character.teleport( {x=0,y=0}, "rubia");
game.forces["player"].technologies["planet-discovery-rubia"].research_recursive()

]]

--#endregion
--Based on work by ashkitten for Cubutt
local buttplug = {}

--storage.buttplug_status is a dictionary of LuaPlayer index => {intensity, end_timestamp}

-- Try to activate thle buttplug with the given parameters, if applicable.
local function ButtpugUpdate()
    if game.simulation then return end
    storage.buttplug_status = storage.buttplug_status or {}
    for player_index in pairs(game.players) do
        local status = storage.buttplug_status[player_index]

        if status.end_timestamp > game.tick then
            helpers.write_file("buttplug.commands", string.format("%f",status.intensity) .. "\n", false, player_index)
            --game.players[player_index].print("Buttplug = " .. status.intensity)
        elseif status.end_timestamp == game.tick then
            helpers.write_file("buttplug.commands", "0.0\n", false, player_index)
            --game.players[player_index].print("Buttplug off")
            storage.buttplug_status[player_index].intensity = 0
        end
    end
end

--Try to enqueue a specific buttplug intensity for the given number of ticks, for that LuaPlayer. If nil, then call for all players.
buttplug.TryEnqueueButtplug = function(intensity, ticks, player)
    storage.buttplug_status = storage.buttplug_status or {}
    
    local function TryEnqueueForPlayer(player_current_index)
        --Initialize
        local status = storage.buttplug_status[player_current_index]

        -- Priority is given to the most intense activation.
        if status.intensity < intensity then
            storage.buttplug_status[player_current_index] = {intensity = intensity, end_timestamp = game.tick + ticks}
        -- If equal, then allow the timer to extend.
        elseif status.intensity == intensity then
            storage.buttplug_status[player_current_index] = {intensity = intensity,
                end_timestamp = math.max(game.tick + ticks, status.end_timestamp)}
        end
    end

    --If no player specified, do it for all players.
    for each_player in pairs(player and {player.index} or game.players) do
        TryEnqueueForPlayer(each_player)
    end
end

local function InitializeButtplugStatus()
    storage.buttplug_status = storage.buttplug_status or {}
    for player in pairs(game.players) do
        storage.buttplug_status[player] = storage.buttplug_status[player] or {intensity = 0, end_timestamp = -1}
    end
end

if settings.startup["rubia-buttplug-integration"].value then
    local event_lib = require("__rubia__.lib.event-lib")
    event_lib.on_nth_tick(1, "buttplug_update", ButtpugUpdate)

    event_lib.on_init("buttplug_initialize", InitializeButtplugStatus)
    event_lib.on_configuration_changed("buttplug_initialize", InitializeButtplugStatus)
    event_lib.on_event({defines.events.on_player_changed_surface,
        defines.events.on_player_changed_position,
        defines.events.on_player_joined_game,
        defines.events.on_player_left_game,
        defines.events.on_player_banned,
        defines.events.on_player_kicked,
        defines.events.on_pre_player_removed
    }, "buttplug_initialize", InitializeButtplugStatus)
else 
    --Make the enqueue function a do-nothing functions, to save UPS
    buttplug.TryEnqueueButtplug = function(intensity, ticks, player) end
end

return buttplug
--local buttplug = require("__rubia__.compat.buttplug")
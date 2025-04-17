require("lib.timing-manager")

--Dictionary of [player] => array of event_id strings for the sub-cutscene events.
storage.active_cutscenes = storage.active_cutscenes or {}

--Start the cutscene for the given player. Return an array of all the relevant event_id to be able to cancel it later.
local function start_cutscene(player)
    local event_ids
    if (storage.active_cutscenes[player]) then cancel_cutscene(player) end

    --TODO
    rubia.timing_manager.wait_then_do(5)

    storage.active_cutscenes[player] = event_ids
    return event_ids
end

--Cancel the cutscene currently playing for the player.
local function cancel_cutscene(player)
    rubia.timing_manager.dequeue_events(storage.active_cutscenes[player])
end

--Run cutscene if player lands
--HOW?
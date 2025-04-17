--This file manages events in control stage, maintaining/executing a table of functions, to be executed after a specific number of ticks.

_G.rubia = _G.rubia or {}
storage.timing_queue = storage.timing_queue or {}
--Each event gets a unique ID. This is the one we are currently on.
storage.timing_queue_next_id = storage.timing_queue_next_id or 1
--Structure for an event:
--["event_id"] = {tick_to_execute=on what game tick do we execute?, to_call = function() to call}

rubia.timing_manager = {}

--Queue up a function to be called ticks_to_wait ticks before executing. Return a string to ID it.
---@param function_to_call function() 
---@return string event_id event_id that uniquely identifies this particular event
rubia.timing_manager.wait_then_do = function(ticks_to_wait, function_to_call)
    local event_id = tostring(storage.timing_queue_next_id)

    storage.timing_queue[event_id] = {
        to_call = function_to_call,
        tick_to_execute = ticks_to_wait + game.tick
    }

    --Increment for next ID and Overflow
    if storage.timing_queue_next_id > 2^40 then storage.timing_queue_next_id = 1
    else storage.timing_queue_next_id = storage.timing_queue_next_id + 1 end

    return event_id
end

-- Remove an event from the queue. Do nothing if said event isn't in the queue.
-- Can be used outside of the timing manager to cancel an event before it goes off.
---@param event_ids string[] Array of strings that uniquely identifies that particular event
rubia.timing_manager.dequeue_events = function(event_ids)
    for _, event_id in pairs(event_ids) do
        storage.timing_queue[event_id] = nil
    end
end

--Running the event checks
script.on_nth_tick(1,function()
    if not storage.timing_queue then return end --Nothing is queued

    local events_completed = {}
    for event_id, event in pairs(storage.timing_queue) do
        if (event.tick_to_execute <= game.tick) then --it is time!
            event.to_call()
            table.insert(events_compl, event_id)
        end    
    end
    rubia.timing_manager.dequeue_events(events_completed)
end)
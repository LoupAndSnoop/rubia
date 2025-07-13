--This file manages events in control stage, maintaining/executing a table of functions, to be executed after a specific number of ticks.

_G.rubia = _G.rubia or {}

local function initialize_storage()
    storage.timing_queue = storage.timing_queue or {}
    --Each event gets a unique ID. This is the one we are currently on.
    storage.timing_queue_next_id = storage.timing_queue_next_id or 1
end

--Structure for an event:
--["event_id"] = {tick_to_execute=on what game tick do we execute?, to_call = function() to call}

rubia.timing_manager = {}

--#region Make a lookup table of functions for invocation
--This is necessary to be able to serialize the data in case we have things going on and save-reload

--Dictionary of "function_name" => function
local function_register = {}

---Add a key to the table, so function_register[function_name] => function_to_invoke
--- The function should be of the form function(arguments[1], arguments[2]...)
---@param function_to_invoke function
---@param function_name string
rubia.timing_manager.register = function(function_name, function_to_invoke)
  if game then error("Cannot register a function outside the main chunk: " .. function_name) end
  assert(not function_register[function_name], "This function name has been added twice to the function lookup register: " .. function_name)
  function_register[function_name] = function_to_invoke
end

--Invoke a function by name, calling it on a set of serialized arguments.
--The function should be of the form function(arguments[1], arguments[2]...)
local function invoke(function_name, arguments)
    assert(function_register[function_name], "Function name not found in lookup table: " .. function_name)
    function_register[function_name](table.unpack(arguments))
end
--#endregion

--@param function_to_call function() 

--Queue up a function to be called ticks_to_wait ticks before executing. Return a string to ID it.
---@param function_name string
---@param arguments any[]  
---@return string event_id event_id that uniquely identifies this particular event
rubia.timing_manager.wait_then_do = function(ticks_to_wait, function_name, arguments)
    local event_id = tostring(storage.timing_queue_next_id)

    storage.timing_queue[event_id] = {
        to_call = function_name,
        arguments = arguments,
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
    if not event_ids or #event_ids == 0 then return end
    --game.print("dequeue:" .. serpent.block(event_ids))
    for _, event_id in pairs(event_ids) do
        storage.timing_queue[event_id] = nil
    end
end

--Run the event checks
rubia.timing_manager.update = function()
    if not storage.timing_queue then return end --Nothing is queued

    --Need to save the result of which things in the queue need done 
    --because the functions themselves can alter the queue while iterating.
    local events_completed = {} --Event IDs of the completed ones
    local functions_to_call = {} -- Actual functions. Need to split in case the function dequeues.
    local arguments = {}
    for event_id, event in pairs(storage.timing_queue) do
        if (event and event.tick_to_execute <= game.tick) then --it is time!
            table.insert(functions_to_call, event.to_call)
            table.insert(events_completed, event_id)
            table.insert(arguments, event.arguments)
        end
    end

    --if #events_completed > 0 then game.print("done:" .. serpent.block(events_completed)) end
    rubia.timing_manager.dequeue_events(events_completed)
    --Now we actually invoke
    --for index, func in pairs(functions_to_call) do func() end
    for index, function_name in pairs(functions_to_call) do 
        invoke(function_name, arguments[index]) end
end


--Event subscription
local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_init("timing-manager-initialize", initialize_storage)
event_lib.on_nth_tick(1, "timing-manager", rubia.timing_manager.update)
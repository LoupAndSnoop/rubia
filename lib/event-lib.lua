--Made by Code green. Modified to be worse by Loup :)
--This file manages events more centrally than my horrible spaghetti.

local lib = {}

--#region General event management
---@type table<defines.events, fun(event: EventData)[]>
local events = {}
---@type table<defines.events, string[]>
local events_names = {}

---@type function[]
local inits = {}
---@type string[]
local init_names = {}

---@type function[]
local configs = {}
---@type string[]
local configs_names = {}

---@type function[]
local loads = {}
---@type string[]
local loads_names = {}

---@type table<int, function[]>
local on_nth_ticks = {}
---@type table<int, string[]>
local on_nth_ticks_names = {}

---Take the given handle (identifier for the specific subscription),
---function to be assigned (or nil to unsub), the working array of handles and functions
---that should be synchronized. Make a modification as though it is a pseudo-dictionary.
---When nil, unsubscribe it. Otherwise, add it to the end.
---@param handle string
---@param func function | nil
---@param handle_array string[]
---@param function_array function[]
local function assign_function(handle, func, handle_array, function_array)
    assert(handle, "Handle cannot be nil!")
    assert(#handle_array == #function_array, "Handle array and function array are not of equal size!")
    --First find the relevant index
    local found = 0
    for index, str in ipairs(handle_array) do
        if str == handle then found = index; break; end
    end

    --Handle not found => New subscription
    if found == 0 then
        --Nil means unsubscribe, but we are already unsubscribed!
        if not func then return end
        handle_array[#handle_array+1] = handle
        function_array[#function_array+1] = func
    elseif func then --Handle was found, and func exists => overwrite
        function_array[found] = func
    else --Handle was found, but func does not exist => unsubscribe
        table.remove(handle_array, found)
        table.remove(function_array, found)
    end
end



---@param event_id LuaEventType
---@param handle string Unique identifier for this subscription.
---@param func fun(event: EventData) | nil
local function on_event(event_id, handle, func)
    events_names[event_id] = events_names[event_id] or {}
    events[event_id] = events[event_id] or {}
    local handler_array = events_names[event_id] 
    local func_array = events[event_id]
    assign_function(handle, func, handler_array, func_array)

    script.on_event(event_id, function(event)
        for _, fun in pairs(func_array) do
            fun(event)
        end
    end)
end


---Subscribe the given function to a given set of event(s) under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param event LuaEventType|LuaEventType[]
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_event(event, handle, func)
    local event_type = type(event)
    if event_type == "number" then
        ---@cast event defines.events
        on_event(event, handle, func)
    elseif type(event) == "userdata" then
        ---@cast event LuaCustomEventPrototype|LuaCustomInputPrototype
        on_event(event.event_id, handle, func)
    elseif type(event) == "string" then
        local ci = prototypes.custom_input[event]
        on_event(ci.event_id, handle, func)
    else
        for _, id in pairs(event) do
            lib.on_event(id, handle, func)
        end
    end
end

---Subscribe the given function to on_init under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_init(handle, func)
    assign_function(handle, func, init_names, inits)
    script.on_init(function()
        for _, init in pairs(inits) do init() end
    end)
end

---Subscribe the given function to on_config_changed under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_configuration_changed(handle, func)
    assign_function(handle, func, configs_names, configs)
    script.on_configuration_changed(function(event)
        for _, config in pairs(configs) do config(event) end
    end)
end

---Subscribe the given function to on_load under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_load(handle, func)
    assign_function(handle, func, loads_names, loads)
    script.on_load(function()
        for _, load in pairs(loads) do load() end
    end)
end

---Subscribe the given function to on_nth_tick under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param ticks uint
---@param handle string Unique identifier for this function.
---@param func function | nil Funtion of an on tick event
function lib.on_nth_tick(ticks, handle, func)
    on_nth_ticks[ticks] = on_nth_ticks[ticks] or {}
    on_nth_ticks_names[ticks] = on_nth_ticks_names[ticks] or {}
    local tick_functions = on_nth_ticks[ticks]
    assign_function(handle, func, on_nth_ticks_names[ticks], tick_functions)
    script.on_nth_tick(ticks, function(event)
        for _, handler in pairs(tick_functions) do
            handler(event)
        end
    end)
end

--#endregion

--#region Compound event managment


---@type fun(entity : LuaEntity, player_index? : uint)[], fun(entity : LuaEntity, player_index? : uint)[]
local on_built, on_built_early = {}, {}
---@type string[], string[]
local on_built_names, on_built_early_names = {}, {}
local on_built_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity,
  defines.events.script_raised_built, defines.events.script_raised_revive}


---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.script_raised_built | EventData.script_raised_revive | 
local function do_on_built(event)
    local entity = event.entity
    local player_index = event.player_index
    --Consolidate robot/player events, if possible. player index may stil be nil
    if not player_index and event.robot and event.robot.valid then
        local cell = event.robot.logistic_cell
        local owner = cell and cell.owner
        if owner and owner.is_player() then player_index = owner.player.index end
    end

    for _, fun in pairs(on_built_early) do 
        if not entity.valid then return end
        fun(entity, player_index)
    end
    for _, fun in pairs(on_built) do 
        if not entity.valid then return end
        fun(entity, player_index)
    end
end

---Assert that all normal events for the passed in event defines are blank.
---@param event_defines_array uint[]
local function assert_events_empty(event_defines_array)
    for _, define in pairs(event_defines_array) do
        if events[define] and (#events[define] > 0) then
            error("Cannot use this function if we already have separated defines for this event index: " 
                .. define .. ", Handlers: " .. serpent.block(events_names[define]))
        end
    end
end

---Subscribe the given function to build events under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func fun(entity:LuaEntity, player_index?:uint) | nil To subscribe, or nil to unsubscribe
function lib.on_built(handle, func)
    assign_function(handle, func, on_built_names, on_built)
    --This function is incompatible with assigning separate functions to each define. Check
    assert_events_empty(on_built_events)
    script.on_event(on_built_events, do_on_built)
end
---Subscribe the given function to build events under the given handle.
---Execute these functions BEFORE the normal priority functions.
---@param handle string Unique identifier for this function.
---@param func fun(entity:LuaEntity, player_index?:uint) | nil To subscribe, or nil to unsubscribe
function lib.on_built_early(handle, func)
    assign_function(handle, func, on_built_early_names, on_built_early)
    --This function is incompatible with assigning separate functions to each define. Check
    assert_events_empty(on_built_events)
    script.on_event(on_built_events, do_on_built)
end

--#endregion


--#region Debug
---Print a string representation of everything that is currently subscribed.
---@return string
function lib.to_string()
    ---@param array string[]
    ---@return string
    local function array_to_string(array)
        local array_str = "Total = " .. tostring(#array) .. ":\n"
        for ind, entry in pairs(array) do
            array_str = array_str .. "   " .. tostring(ind) .. ") " .. entry .. "\n"
        end
        return array_str
    end

    local str = "On init. " .. array_to_string(init_names)
    str = str .. "On config changed. " .. array_to_string(configs_names)
    str = str .. "On load. " .. array_to_string(loads_names)

    --Normal events
    for event_define, handler_array in pairs(events_names) do
        if handler_array and #handler_array > 0 then
            local event_str = "<event not found>"
            for key, val in pairs(defines.events) do
                if val == event_define then event_str = key; break; end
            end
            str = str .. "Event of " .. event_str .. ". " 
                .. array_to_string(handler_array)
        end
    end

    str = str .. "On built early. " .. array_to_string(on_built_early_names)
    str = str .. "On built. " .. array_to_string(on_built_names)

    --For Nth tick
    for tick_count, handler_array in pairs(on_nth_ticks_names) do
        if handler_array and (#handler_array) > 0 then
            str = str .. "On nth tick (" .. tostring(tick_count)
                .. " ticks). " .. array_to_string(handler_array)
        end
    end

    return str
end

--Give a global function call to print events.
_G.rubia = rubia or {}
--Print all event handlers, to see what is currently subscribed.
function rubia.print_events()
    game.print(lib.to_string())
    log("Rubia event log:")
    log(lib.to_string())
end
--#endregion

return lib
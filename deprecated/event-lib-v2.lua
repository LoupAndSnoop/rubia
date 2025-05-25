--Made by Code green. Modified to be worse by Loup :)

local lib = {}
---@type table<defines.events, fun(event: EventData)[]>
local events = {}
---@type table<string, function>
local inits = {}
---@type table<string, function>
local configs = {}
---@type table<string, function>
local loads = {}
---@type table<int, function[]>
local on_nth_ticks = {}


---@param event_id LuaEventType
---@param handle string Unique identifier for this subscription.
---@param fun fun(event: EventData) | nil
local function on_event(event_id, handle, fun)
    local handlers = events[event_id] or {} --[[@as fun(event: EventData)[] ]]
    events[event_id] = handlers
    handlers[handle] = fun
    script.on_event(event_id, function(event)
        for _, handler in pairs(handlers or {}) do
            handler(event)
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
    inits[handle] = func
    script.on_init(function()
        for _, init in pairs(inits) do
            init()
        end
    end)
end

---Subscribe the given function to on_config_changed under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_configuration_changed(handle, func)
    configs[handle] = func
    script.on_configuration_changed(function(event)
        for _, config in pairs(configs) do
            config(event)
        end
    end)
end

---Subscribe the given function to on_load under the given handle.
---Input nil for a function to unsubscribe whatever is on that handle.
---@param handle string Unique identifier for this function.
---@param func function | nil
function lib.on_load(handle, func)
    loads[handle] = func
    script.on_load(function()
        for _, load in pairs(loads) do
            load()
        end
    end)
end

---@param ticks uint
---@param func function Funtion of an on tick event
function lib.on_nth_tick(ticks, func)
    local tick_handlers = on_nth_ticks[ticks] or {}
    tick_handlers[#tick_handlers+1] = func
    on_nth_ticks[ticks] = tick_handlers
    script.on_nth_tick(ticks, function(event)
        for _, handler in pairs(tick_handlers) do
            handler(event)
        end
    end)
end

return lib